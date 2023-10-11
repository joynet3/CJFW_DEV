/**
 * @Class : IFN_LIF1002_OD001_MD001.cls
 * @group Framework : 주문
 * @Author : 김동영
 * @Date : 2023-08-16
 * @Version : 1.0
 * @Description : 식자재 신청 고객 정보 CRM Lead로 생성
 *                주문시스템 -> 중계서버 -> 세일즈포스
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.16 | 김동영          | 최초작성
 *  
 * */
@RestResource(urlMapping='/LIF1002/OD001/MD001')
global with sharing class IFN_LIF1002_OD001_MD001 {
    
    global IFN_LIF1002_OD001_MD001() {}
    
    /** 
     * 고객 유형 / 코드
     * 외식사업자 : 01
     * 급식사업자 : 02
     * 유통사업자 : 03
     */
    global class Input {
        public String cstTp{get;set;}   //고객유형
        public String cstTpCd{get;set;} //고객유형코드
        public String cstNm{get;set;}   //이름
        public String callNo{get;set;}  //휴대폰번호
        public String bsnsNo{get;set;}  //사업자등록번호
        public String cpnNm{get;set;}   //업체명
        public String sect{get;set;}    //업종
        public String addr{get;set;}    //업체주소
        public String agrYn{get;set;}   //이용약관동의여부
    }

    global class Output {
        public String interface_id{get;set;}
        public String err_cd{get;set;}
        public String err_msg_ctt{get;set;}
        public ResData response{get;set;}
    }

    global class ResData {
        public String IdRcdId{get;set;} //저장된 레코드 ID
        public String RcdTp{get;set;}   //레코드 타입    
        public String RcdTpCd{get;set;} //레코드 타입 코드
    }

    @HttpPost
    global static Output doPost() {

        String strCode = '0000';
        String strMessage = 'Success.';
        String interfaceId = 'IFN_LIF1002_OD001_MD001';

        IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
        IFN_CommonLog commlog = new IFN_CommonLog();

        Output objOutput = new Output();
        
        String requestBody = '';
        IFN_CMM_ERRUTIL.ErrorValueWrapper errWr = new IFN_CMM_ERRUTIL.ErrorValueWrapper();

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            logWrap.requestBody = requestBody;   

            if(requestBody == '' || requestBody == null) {
                errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_BODYCTT_EMPTY_ERROR);
                strCode = errWr.err_code;
                strMessage = errWr.err_msg;
                logWrap.ErrorCode = strCode;
                logWrap.ErrorText.add(strMessage);
            } else {
                //Map<String, String> plCustomType = CommonUtil.getMapPickListLabel('Lead', 'CustomType__c');
                Input input = (Input)JSON.deserialize(requestBody, Input.class);

                // 필수 파라미터 체크
                if (String.isBlank(input.cstTp) || String.isBlank(input.cstTpCd) || String.isBlank(input.cstNm) || String.isBlank(input.callNo)
                    || String.isBlank(input.bsnsNo) || String.isBlank(input.cpnNm) || String.isBlank(input.sect) || String.isBlank(input.addr)
                    || String.isBlank(input.agrYn)) {

                    errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_RQMT_PARAM_ERROR);
                    strCode = errWr.err_code;
                    strMessage = errWr.err_msg;

                    strMessage = String.isBlank(input.cstTp) ? strMessage + ',[cstTp]' : strMessage;
                    strMessage = String.isBlank(input.cstTpCd) ? strMessage + ',[cstTpCd]' : strMessage;
                    strMessage = String.isBlank(input.cstNm) ? strMessage + ',[cstNm]' : strMessage;
                    strMessage = String.isBlank(input.callNo) ? strMessage + ',[callNo]' : strMessage;
                    strMessage = String.isBlank(input.bsnsNo) ? strMessage + ',[bsnsNo]' : strMessage;
                    strMessage = String.isBlank(input.cpnNm) ? strMessage + ',[cpnNm]' : strMessage;
                    strMessage = String.isBlank(input.sect) ? strMessage + ',[sect]' : strMessage;
                    strMessage = String.isBlank(input.addr) ? strMessage + ',[addr]' : strMessage;
                    strMessage = String.isBlank(input.agrYn) ? strMessage + ',[agrYn]' : strMessage;
                    
                    logWrap.ErrorCode = strCode;
                    logWrap.ErrorText.add(strMessage);
                } else {
                    String companyRegNum = IFN_Util.replaceText(input.bsnsNo);
                    
                    // 기존 Account 존재 여부
                    String qry = 'select count() from account Where CompanyRegisterNumber__c = :companyRegNum';
                    integer isExistAccount = database.countQuery(qry);
                    
                    String rcdTpDevName = '';
                    
                    switch on input.cstTpCd {
                        when '01' {
                            rcdTpDevName = 'food_service_business';
                        }
                        when '02' {
                            rcdTpDevName = 'catering_business';
                        }
                        when '03' {
                            rcdTpDevName = 'distributor';
                        }
                    }
                    
                    if(String.isBlank(rcdTpDevName)) {
                        errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_PARAMETER_ERROR);                        
                        strCode = errWr.err_code;
                        strMessage = errWr.err_msg;

                        logWrap.ErrorCode = strCode;
                        logWrap.ErrorText.add(strMessage);
                        return objOutput;
                    }

                    // 고객유형에 따른 RecordTypeId
                    Id leadRcdTp = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(rcdTpDevName).getRecordTypeId();
                    
                    try {
                        Lead newLead = new Lead(
                            CustomType__c = input.cstTpCd
                            , LastName = input.cstNm
                            , Phone = input.callNo
                            , CompanyRegisterNumber__c = companyRegNum
                            , Company = input.cpnNm
                            , BusinessConditions__c = input.sect
                            , Address__c = input.addr
                            , AgreeYN__c = (input.agrYn == 'Y') ? true : false
                            , RecordTypeId = leadRcdTp
                            , newLeadCheck__c = (isExistAccount > 0) ? true : false
                        );

                        Database.SaveResult result = Database.insert(newLead);
                        
                        if (result.isSuccess()) {
                            ResData resData = new ResData(); 
                            resData.IdRcdId = result.getId();
                            resData.RcdTp = input.cstTpCd;  
                            resData.RcdTpCd = leadRcdTp;    //sfid
                            objOutput.response = resData;
                        } else {
                            for(Database.Error err : result.getErrors()) {
                                strCode = '-1';
                                strMessage = err.getStatusCode() + ': ' + err.getMessage();
                                logWrap.ErrorCode = strCode;
                                logWrap.ErrorText.add(strMessage);
                            }
                        }
                        
                    } catch (DmlException e) {
                        strCode = '-1';
                        strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       
                        logWrap.ErrorCode = strCode;
                        logWrap.ErrorText.add(strMessage);
                    }   
                }
            }
        } catch(Exception e) {
            errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_SERVER_ERROR);
            strCode = errWr.err_code;
            strMessage = errWr.err_msg;
            strMessage +=  '[' + e.getMessage()+' Line : '+e.getLineNumber() + ']';
            logWrap.ErrorCode = strCode;
            logWrap.ErrorText.add(strMessage);
        }
        objOutput.interface_id = interfaceId;
        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strMessage;
        commlog.insertLog(logWrap);

        return objOutput;
    }
}