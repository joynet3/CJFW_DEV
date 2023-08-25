/**
 * @description       : MDM 참조코드 API
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
@RestResource(urlMapping='/mdm/refercode/info')
global with sharing class IF_MDM_SFDC_INFO_REFCODE {
    global IF_MDM_SFDC_INFO_REFCODE() {}

    global class Input {
        public List<Item> data;
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last;
    }

    global class Item {
        public String INSTANCEID;
        public String GROUPID;
        public String CODE;
        public String NAME_KO;
        public String NAME_EN;
        public String NAME_ZH;
        public String NAME_VI;
        public String ATTR1;
        public String ATTR2;
        public String ATTR3;
        public String ACTIVE;        
    }

    global class Output {
        public String err_cd;
        public String err_msg_ctt;
        /*
        public Result result;
        public ResultData resultData;
        */
    }

    global class Result {
        public String resultCode;
        public String resultMessage;
    }

    global class ResultData {
    }

    @HttpPost
    global static Output doPost() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Data has successfully upserted.';

        /*
        Result objResult = new Result();
        ResultData resultData = new ResultData();
        */

        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String requestBody = '';

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            LogWrapper.requestBody = requestBody;   
            if(requestBody == '' || requestBody == null) {
                strStatus = 'ERROR';
                strCode = '-1';
                strMessage = 'request body value does not exist';
            }else {
                Input input = (input)JSON.deserialize(requestBody,  Input.class);                
                
                if (input.data == null || input.data.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'item list is empty';
                }else {
                    
                    List<MDMReferenceCode__c> listData = new List<MDMReferenceCode__c>();

                    Boolean isNotError = true;

                    for(Item obj : input.data) {
                        if((obj.GROUPID == '' || obj.GROUPID == null) && (obj.CODE == '' || obj.CODE == null)) {
                            strStatus = 'ERROR';
                            strCode = '0001';
                            strMessage += 'GROUPID is empty or CODE is empty (INSTANCEID value : '+obj.INSTANCEID+')|';
                            isNotError = false;
                            break;
                        }else {
                            MDMReferenceCode__c objTarget = new MDMReferenceCode__c();

                            objTarget.ExtId__c = obj.GROUPID+'_'+obj.CODE;
                            objTarget.INSTANCEID__c = obj.INSTANCEID;
                            objTarget.GROUPID__c = obj.GROUPID;
                            objTarget.CODE__c = obj.CODE;
                            objTarget.NAME_KO__c = obj.NAME_KO;
                            objTarget.NAME_EN__c = obj.NAME_EN;
                            objTarget.NAME_ZH__c = obj.NAME_ZH;
                            objTarget.NAME_VI__c = obj.NAME_VI;
                            objTarget.ATTR1__c = obj.ATTR1;                            
                            objTarget.ATTR2__c = obj.ATTR2;
                            objTarget.ATTR3__c = obj.ATTR3;
                            objTarget.ACTIVE__c = obj.ACTIVE;
                            Boolean isActive = false;
                            if(obj.ACTIVE == 'Y') {
                                isActive = true;
                            }

                            objTarget.IsActive__c = isActive;

                            listData.add(objTarget);
                        }
                    }

                    if(isNotError && (listData <> null && listData.size() > 0)) {
                        upsert listData ExtId__c;
                    }

                    System.debug('==============> input : '+JSON.serialize(input));
                }
            }
        }catch(Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       

            System.debug('========================> strMessage : '+strMessage);
        }

        /*
        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        
        objOutput.resultData = resultData;
        objOutput.result = objResult;
        */

        // 2022-11-11 Response 변경
        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strMessage;                
        
        LogWrapper.status = strStatus;
        LogWrapper.resultCode = strCode;
        LogWrapper.resultMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestBody = requestBody;
        LogWrapper.responseBody = JSON.serialize(objOutput);
        
        IFUtil objIF = new IFUtil('IF_MDM_SFDC_INFO_REFCODE');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}