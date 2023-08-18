/**
 * @Class : IFN_LIF1002_OD003_MD006.cls
 * @group Framework : 주문
 * @Author : 조일근
 * @Date : 2023-08-17
 * @Version : 1.0
 * @Description : 교육신청데이터갱신
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.17 | 조일근         | 최초작성
 * */
@RestResource(urlMapping='/LIF1002/OD003/MD006')
global with sharing class IFN_LIF1002_OD003_MD006 {

    global IFN_LIF1002_OD003_MD006() {}

    global class Input {
        public String cttId     {get;set;}
        public String mdmCd     {get;set;}
        public String accNm     {get;set;}
        public String mngNm     {get;set;}
        public String accCall   {get;set;}
        public String reqDt     {get;set;}
        public String svcTm     {get;set;}
        public String svcTgtNm  {get;set;}
        public String svcTgtCd  {get;set;}
        public String reqMemCnt {get;set;}
        public String avgAge    {get;set;}
        public String addr      {get;set;}
        public String dscrt     {get;set;}
    }
    
    global class Output {
        public String interface_id{get;set;}
        public String err_cd{get;set;}
        public String err_msg_ctt{get;set;}
        public String svcRcdId{get;set;}
    }

    @HttpPost
    global static Output doPost() {
        String strCode = '0000';
        String strMessage = 'Success.';
        String interfaceId = 'IFN_LIF1002_OD003_MD006';

        IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
        IFN_CommonLog commlog = new IFN_CommonLog();

        Output objOutput = new Output();
        objOutput.interface_id = interfaceId;
        String requestBody = '';

        try {

            
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            logWrap.requestBody = requestBody;   

            if(requestBody == '' || requestBody == null) {
                strCode = IFN_Util.STATUS_BODYCTT_EMPTY_ERROR.split(':')[0];
                strMessage = IFN_Util.STATUS_BODYCTT_EMPTY_ERROR.split(':')[1];
                logWrap.ErrorCode = strCode;
                logWrap.ErrorText.add(strMessage);
            }else {

                Input input = (Input)JSON.deserialize(requestBody,  Input.class);          

                if(String.isEmpty(input.cttId) || String.isEmpty(input.mdmCd)) {
                    // 필수 파라메터 누락
                    strCode = IFN_Util.STATUS_RQMT_PARAM_ERROR.split(':')[0];
                    strMessage = IFN_Util.STATUS_RQMT_PARAM_ERROR.split(':')[1];
                    strMessage = strMessage + ' 누락 항목 : [ ';
                    strMessage = String.isBlank(input.cttId) ? strMessage + 'cttId ,' : strMessage;
                    strMessage = String.isBlank(input.mdmCd) ? strMessage + 'mdmCd ,' : strMessage;

                    strMessage = String.isBlank(input.accNm) ? strMessage + 'accNm ,' : strMessage;
                    strMessage = String.isBlank(input.mngNm) ? strMessage + 'mngNm ,' : strMessage;
                    strMessage = String.isBlank(input.accCall) ? strMessage + 'accCall ,' : strMessage;
                    strMessage = String.isBlank(input.svcTgtNm) ? strMessage + 'svcTgtNm ,' : strMessage;
                    strMessage = String.isBlank(input.svcTgtCd) ? strMessage + 'svcTgtCd ,' : strMessage;
                    strMessage = String.isBlank(input.reqMemCnt) ? strMessage + 'reqMemCnt ,' : strMessage;
                    strMessage = String.isBlank(input.addr) ? strMessage + 'addr ' : strMessage;

                    strMessage = strMessage + ' ]';
                    logWrap.ErrorCode = strCode;
                    logWrap.ErrorText.add(strMessage);
                } else {
                    ClassService__c clsreq = new ClassService__c();
                    Map<String, String> plTargetGroup = CommonUtil.getMapPickListLabel('ClassService__c', 'TargetGroup__c');

                    try{
                        AggregateResult ar = [select count(id) cnt from ClassService__c 
                        where ServiceContent__c = :input.cttId
                        and MDMCode__c = :input.mdmCd];
                        Integer selCnt = Integer.valueOf(ar.get('cnt'));
                        logWrap.LogText.add(' 교육신청 데이터 selCnt ======> ' + selCnt);
                        if(selCnt > 0) {
                            clsreq = [select id 
                                        ,ServiceContent__c
                                        ,MDMCode__c
                                        ,Customer__c
                                        ,Manager__c
                                        ,CustomerPhone__c
                                        ,Status__c
                                        ,TargetGroup__c
                                        ,ApplicantsNumber__c
                                        ,CustomerAgeGroup__c
                                        ,Address__c
                                        ,Description__c
                                        from ClassService__c
                                        where ServiceContent__c = :input.cttId
                                        and MDMCode__c = :input.mdmCd];
                                        logWrap.LogText.add(' 교육신청 데이터 존재 ======> ' + Json.serialize(clsreq));

                        }

                        clsreq.ServiceContent__c  = input.cttId;
                        clsreq.MDMCode__c          = input.mdmCd;

                        List<Account> acclst = [select id from Account where CustomerID__c = :input.mdmCd];
                        if(acclst.size() > 0) {
                            clsreq.Customer__c = acclst[0].id;
                        } else {
                            acclst = [select id from Account where Name = :input.accNm];
                            if(acclst.size() > 0) clsreq.Customer__c = acclst[0].id;
                        }                        
                        clsreq.Manager__c          = input.mngNm;
                        clsreq.CustomerPhone__c    = input.accCall;
                        clsreq.TargetGroup__c      = plTargetGroup.get(input.svcTgtNm) !=null ?  input.svcTgtNm 
                                                    : (plTargetGroup.get(input.svcTgtCd) !=null ?  input.svcTgtCd : null ) ;                                                    
                        clsreq.ApplicantsNumber__c = input.reqMemCnt;

                        //clsreq.CustomerAgeGroup__c = input.avgAge; // 평균연령

                        clsreq.Address__c          = input.addr;
                        clsreq.Description__c      = input.dscrt;
                        clsreq.Status__c = String.isBlank(clsreq.Status__c) ? 'H' : clsreq.Status__c;

                        logWrap.LogText.add(' 교육신청 upsert data  ======> ' + Json.serialize(clsreq));

                        upsert clsreq;


                    } catch (Exception e) {
                        strCode = IFN_Util.STATUS_EXCEPT.split(':')[0];
                        strMessage = IFN_Util.STATUS_EXCEPT.split(':')[1];
                        strMessage +=  '[' + e.getMessage()+' Line : '+e.getLineNumber() + ']';
                        logWrap.ErrorCode = strCode;
                        logWrap.ErrorText.add(strMessage);
                    }                    

                }
            }            

        } catch (Exception e) {
            strCode = IFN_Util.STATUS_EXCEPT.split(':')[0];
            strMessage = IFN_Util.STATUS_EXCEPT.split(':')[1];
            strMessage +=  '[' + e.getMessage()+' Line : '+e.getLineNumber() + ']';
            logWrap.ErrorCode = strCode;
            logWrap.ErrorText.add(strMessage);

        }


        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strMessage;
        logWrap.ResponseBody = Json.serialize(objOutput);
        commlog.insertLog(logWrap);

        return objOutput;

    }


}