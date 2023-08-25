/**
 * @description       : MDM 고객정보 등록요청 결재 진행 현황 API
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
@RestResource(urlMapping='/mdm/customer/reg/result')
global with sharing class IF_MDM_SFDC_RES_ACCOUNT {
    global IF_MDM_SFDC_RES_ACCOUNT() {}

    global class Input {
        public List<Item> data;
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last;
    }

    global class Item {
        public String err_cd;
        public String err_msg_ctt;        
        public String INSTANCEID;
        //public String WF_INSTANCEID;
        public String PV_CRMNO;
        public String WF_STATUS;
        public List<Actor> WF_ACTOR;
        public List<NextActor> WF_NEXTACTOR;
        public String WF_DATE;
        public String WF_DESCRIPTION;
    }

    global class Actor {
        public String EMPLOYEE_NUM;
        public String NAME;
    }

    global class NextActor {
        public String EMPLOYEE_NUM;
        public String NAME;

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
                    Set<String> setMDMRequestCustomerId = new Set<String>();

                    List<MDMRegRequestCustomer__c> listMDMCustomer = new List<MDMRegRequestCustomer__c>();

                    for(Item obj : input.data) {
                        if(obj.PV_CRMNO <> null && obj.PV_CRMNO <> '') {
                            setMDMRequestCustomerId.add(obj.PV_CRMNO);
                        }
                    }

                    if(!setMDMRequestCustomerId.isEmpty()) {
                        Map<String, MDMRegRequestCustomer__c> mapMDMReqCustomer = new Map<String, MDMRegRequestCustomer__c>();
                        for(MDMRegRequestCustomer__c obj : [
                            SELECT  Id, Account__c, Status__c
                            FROM    MDMRegRequestCustomer__c
                            WHERE   Account__c In:setMDMRequestCustomerId
                        ]) {                            
                            mapMDMReqCustomer.put(obj.Account__c, obj);
                        }

                        if(mapMDMReqCustomer <> null && mapMDMReqCustomer.values().size() > 0) {
                            List<MDMRegRequestCustomer__c> listUpdateMDMCustomer = new List<MDMRegRequestCustomer__c>();
                            List<MDMRegRequestResult__c> listMDMResult = new List<MDMRegRequestResult__c>();

                            Set<String> setAccountExtChangeId = new Set<String>();

                            for(Item obj : input.data) {
                                MDMRegRequestResult__c objCustomer = new MDMRegRequestResult__c();

                                objCustomer.MDMRegRequestCustomer__c = mapMDMReqCustomer.get(obj.PV_CRMNO).Id;

                                objCustomer.ExtId__c = obj.PV_CRMNO+'_'+obj.INSTANCEID;
                                objCustomer.INSTANCEID__c = obj.INSTANCEID;
                                objCustomer.WF_STATUS__c = obj.WF_STATUS;
                                objCustomer.WF_INSTANCEID__c = obj.INSTANCEID;
                                objCustomer.PV_CRMNO__c = obj.PV_CRMNO;
                                objCustomer.WF_STATUS__c = obj.WF_STATUS;

                                if(obj.WF_ACTOR <> null && obj.WF_ACTOR.size() > 0) {
                                    String strWFActor = '';

                                    for(Actor objA : obj.WF_ACTOR) {
                                        strWFActor += objA.NAME+'('+objA.EMPLOYEE_NUM+')'+'|';
                                    }

                                    if(strWFActor.length() > 0) {
                                        strWFActor = strWFActor.substring(0, (strWFActor.length()-1));
                                    }

                                    objCustomer.WF_ACTOR__c = strWFActor;
                                }

                                Boolean isNotNextActor = false;

                                if(obj.WF_NEXTACTOR <> null && obj.WF_NEXTACTOR.size() > 0) {
                                    String strNEXTWFActor = '';

                                    for(NextActor objA : obj.WF_NEXTACTOR) {
                                        strNEXTWFActor += objA.NAME+'('+objA.EMPLOYEE_NUM+')'+'|';
                                    }

                                    if(strNEXTWFActor.length() > 0) {
                                        strNEXTWFActor = strNEXTWFActor.substring(0, (strNEXTWFActor.length()-1));
                                    }

                                    objCustomer.WF_NEXTACTOR__c = strNEXTWFActor;
                                }else {
                                    isNotNextActor = true;
                                }

                                // 다음 승인지가 없고 현재 승인이 되었을경우 최종승인이므로 가망고객을 기존고객으로 변경한다

                                if(obj.WF_STATUS == 'RJCT' || obj.WF_STATUS == 'STOP') {
                                    MDMRegRequestCustomer__c objTagetCustomer = mapMDMReqCustomer.get(obj.PV_CRMNO);
                                    objTagetCustomer.Status__c = 'Rejected';
                                    listUpdateMDMCustomer.add(objTagetCustomer);
                                }
                                else if(isNotNextActor && obj.WF_STATUS == 'APPR') {
                                    MDMRegRequestCustomer__c objTagetCustomer = mapMDMReqCustomer.get(obj.PV_CRMNO);
                                    objTagetCustomer.Status__c = 'Approved';
                                    listUpdateMDMCustomer.add(objTagetCustomer);
                                }
                                
                                objCustomer.WF_DATE__c = obj.WF_DATE <> null && obj.WF_DATE <> '' ? Datetime.valueOf(obj.WF_DATE) : null;
                                objCustomer.WF_DESCRIPTION__c = obj.WF_DESCRIPTION;

                                listMDMResult.add(objCustomer);
                            }

                            if(listMDMResult <> null && listMDMResult.size() > 0) {
                                insert listMDMResult;
                            }

                            if(listUpdateMDMCustomer <> null && listUpdateMDMCustomer.size() > 0) {
                                update listUpdateMDMCustomer;
                            }
                        }else {
                            strStatus = 'ERROR';
                            strCode = '0003';
                            strMessage = 'PV_CRMNO is invalid';
                        }
                    }else {
                        strStatus = 'ERROR';
                        strCode = '0002';
                        strMessage = 'PV_CRMNO is empty';
                    }
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
        
        IFUtil objIF = new IFUtil('IF_MDM_SFDC_RES_ACCOUNT');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}