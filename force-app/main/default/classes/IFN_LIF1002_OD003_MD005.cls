/**
 * @Class : IFN_LIF1002_OD003_MD005.cls
 * @group Framework : 주문
 * @Author : 조일근
 * @Date : 2023-08-11
 * @Version : 1.0
 * @Description : 교육신청상세조회(신청한 서비스 조회)
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.11 | 조일근 | 최초작성
 * */
@RestResource(urlMapping='/LIF1002/OD003/MD005')
global with sharing class IFN_LIF1002_OD003_MD005 {

    global IFN_LIF1002_OD003_MD005() {}

    global class Input {
        public String cttId {get;set;}
        public String mdmCd {get;set;}

    }

    global class Output {
        public String interface_id{get;set;}
        public String err_cd{get;set;}
        public String err_msg_ctt{get;set;}
        public selData response{get;set;}
    }

    global class selData {

        public String cttId     {get;set;} // 교육컨텐츠아이디()
        public String mdmCd     {get;set;} // 신청고객MDM코드
        public String cttSttsNm {get;set;} // 선택한 교육서비스 진행상태 명
        public String cttSttsCd {get;set;} // 선택한 교육서비스 진행상태 코드
        public String cttRg     {get;set;} // 교육지역
        public String cttTp     {get;set;} // 교육구분
        public String cttStDt   {get;set;} // 교육시작일
        public String cttTtl    {get;set;} // 교육명
        public String istrt     {get;set;} // 메인강사
        public String istrt2    {get;set;} // 보조강사1
        public String istrt3    {get;set;} // 보조강사2
        public String reqStts   {get;set;} // 신청상태
        public String accNm     {get;set;} // 고객사명
        public String mngNm     {get;set;} // 고객사담당자
        public String accCall   {get;set;} // 담당자연락처
        public String svcTgtNm  {get;set;} // 교육대상 명
        public String svcTgtCd  {get;set;} // 교육대상 코드
        public String reqMemCnt {get;set;} // 신청 인원수
        public String avgAge    {get;set;} // 방문주소
        public String addr      {get;set;} // 평균연령  
        public String dscrt     {get;set;} // 비고
        public String reqDt     {get;set;} // 교육 신청일
        public String svcTm     {get;set;} // 교육진행시간
    }

    @HttpPost
    global static Output doPost() {
        String strCode = '0000';
        String strMessage = 'Success.';
        String interfaceId = 'IFN_LIF1002_OD003_MD005';

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
                    strMessage = String.isBlank(input.mdmCd) ? strMessage + 'mdmCd ' : strMessage;
                    strMessage = strMessage + ' ]';
                    logWrap.ErrorCode = strCode;
                    logWrap.ErrorText.add(strMessage);
                } else {

                    Map<String, String> plClassServiceStatus = CommonUtil.getMapPickListLabel('ClassService__c', 'Status__c');
                    Map<String, String> plClassTargetGroup = CommonUtil.getMapPickListLabel('ClassService__c', 'TargetGroup__c');                
                    Map<String, String> plServiceContentRegion = CommonUtil.getMapPickListLabel('ServiceContents__c', 'Region__c');
    
                    ClassService__c classInfo = new ClassService__c();
                    try{
                        // 교육 서비스 상세조회
                        classInfo = [Select Id, ServiceContent__c
                        , MDMCode__c
                        ,ServiceContent__r.IsUsage__c
                        ,ServiceContent__r.Region__c
                        ,ServiceContent__r.Category__c
                        ,ServiceContent__r.OpenDate__c
                        ,ServiceContent__r.Name
                        ,ServiceContent__r.Instructor__r.Name
                        ,ServiceContent__r.Instructor2__r.Name
                        ,ServiceContent__r.Instructor3__r.Name
                        ,Status__c
                        ,Customer__r.Name
                        ,Manager__c
                        ,CustomerPhone__c
                        ,TargetGroup__c
                        ,ApplicantsNumber__c
                        ,GroupMealAge__c
                        ,Address__c
                        ,Description__c
                        from ClassService__c
                        where ServiceContent__c = :input.cttId
                        and MDMCode__c = :input.mdmCd];
    
                        selData resData = new selData();
    
                        resData.cttId      = classInfo.ServiceContent__c;
                        resData.mdmCd      = classInfo.MDMCode__c;
                        resData.cttSttsNm  = classInfo.ServiceContent__r.IsUsage__c  == true ? '진행중' : '미진행';
                        resData.cttSttsCd  = classInfo.ServiceContent__r.IsUsage__c  == true ? '진행중' : '미진행';
                        resData.cttRg      = String.isEmpty(classInfo.ServiceContent__r.Region__c) ? '': plServiceContentRegion.get(classInfo.ServiceContent__r.Region__c);
                        resData.cttTp      = classInfo.ServiceContent__r.Category__c;
                        resData.cttStDt    = IFN_Util.converDateTimeToStrFormat(classInfo.ServiceContent__r.OpenDate__c);
                        resData.cttTtl     = classInfo.ServiceContent__r.Name;
                        resData.istrt      = classInfo.ServiceContent__r.Instructor__r.Name;
                        resData.istrt2     = classInfo.ServiceContent__r.Instructor2__r.Name;
                        resData.istrt3     = classInfo.ServiceContent__r.Instructor3__r.Name;
                        resData.reqStts    = String.isEmpty(classInfo.Status__c) ? '': plClassServiceStatus.get(classInfo.Status__c);
                        resData.accNm      = classInfo.Customer__r.Name;
                        resData.mngNm      = classInfo.Manager__c;
                        resData.accCall    = classInfo.CustomerPhone__c;
                        resData.svcTgtNm   = classInfo.TargetGroup__c;
                        resData.svcTgtCd   = classInfo.TargetGroup__c;
                        resData.reqMemCnt  = classInfo.ApplicantsNumber__c;
                        resData.avgAge     = classInfo.GroupMealAge__c;
                        resData.addr       = classInfo.Address__c;
                        resData.dscrt      = classInfo.Description__c;
    
                        try {
                            ExtraService__c exService =  [select id,ServiceStartDateTime__c,ProgressTime__c from ExtraService__c where  ServiceContents__c = :classInfo.ServiceContent__c Limit 1];
                            resData.reqDt = IFN_Util.converDateTimeToStrFormat(exService.ServiceStartDateTime__c,'yyyy-MM-dd a hh');
                            resData.reqDt = resData.reqDt.replace('AM', '오전');
                            resData.reqDt = resData.reqDt.replace('PM', '오후');
                            resData.reqDt = String.isNotEmpty(resData.reqDt) ? resData.reqDt.replace('PM', '오후') + '시' : '';
                            resData.svcTm = String.valueOf(exService.ProgressTime__c) + '시간';
                      
                        } catch (Exception e) {
                            
                        }

                        objOutput.response = resData;   
                        
    
                    } catch(Exception e) {
                        // 조회 파라메터에서 
                        strCode = IFN_Util.STATUS_DATA_NOTFOUND_ERROR.split(':')[0];
                        strMessage = IFN_Util.STATUS_DATA_NOTFOUND_ERROR.split(':')[1];
                        logWrap.ErrorCode = strCode;
                        logWrap.ErrorText.add(e.getMessage() + '/' + e.getLineNumber());
                    }
                }

            }
        } catch(Exception e) {
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       
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