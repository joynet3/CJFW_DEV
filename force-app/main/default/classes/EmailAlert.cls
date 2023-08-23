/**
* Email 알림 전송
*
*@group  Notification
*@author 진현욱
*@since 2023-07-25  최초작성
*/
public without sharing class EmailAlert implements NotiAlert{
    @testVisible private boolean isTestException = false;   //test 코드 Exception 용
    
    final Integer emaliLimitNum = 10;       // System Limit 으로 트랜잭션에서 이메일 전송 메소드 호출 가능 수
    final Integer recipientLimitNum = 150;  // System Limit 으로 한 Email 에 보낼 수 있는 수신자,참조,숨은참조 총 수
    private Boolean isBatch = false;
    public static String orgWideEmailId;
    
    public EmailAlert() {

        if(String.isBlank(orgWideEmailId)) {

            List<OrgWideEmailAddress> oweaList= [ select 
                                            Id
                                            , Address
                                            , DisplayName
                                            , IsAllowAllProfiles
                                            , Purpose
                                        from OrgWideEmailAddress  
                                        //조건문 추가 필요
            ];
           
            if(!oweaList.isEmpty()) orgWideEmailId = oweaList[0].Id;                      
        }
    
    }

    public void setIsBatch(Boolean isBatch) {
        this.isBatch = isBatch;
    }
    /**
    * Email 알림 전송
    *
    *@param  sendData Email 알림 Template 을 파라미터로 전송
    */
    public void send(List<NotiTemplate> sendData) {

        List<IFLog__c> objLogList = new List<IFLog__c>();

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Integer,Integer> mappingIdxMap = new Map<Integer,Integer>();  //SingleEmailMessage 와 NotiEmailTemplate 의 Idx 값 매핑 오브젝트
        List<NotiEmailTemplate> errorDataList = new List<NotiEmailTemplate>();
        List<NotiEmailTemplate> tmpSendData = (List<NotiEmailTemplate>) sendData;
        List<NotiEmailTemplate> batchSendData = new List<NotiEmailTemplate>();
        Set<String> templateDevNameSet = new Set<String>();
        Map<String, EmailTemplate> templateMap = new Map<String, EmailTemplate>();
        for(NotiEmailTemplate sendDatum : tmpSendData) {
            if(String.isNotBlank(sendDatum.getTemplateId())) templateDevNameSet.add(sendDatum.getTemplateId());
        }

        for(EmailTemplate emailTemplate : [ select
                                                subject
                                                , HtmlValue
                                                ,Id
                                                ,Name
                                                ,DeveloperName
                                            from EmailTemplate
                                            where 
                                                DeveloperName IN :templateDevNameSet
                                                and IsActive = true
                                        ]) {
                templateMap.put(emailTemplate.DeveloperName,  emailTemplate);                           
        }
        
        Integer idx = 0;
        for(NotiEmailTemplate sendDatum : tmpSendData) {
            Integer recipientNum = 0;
            EmailTemplate template = templateMap.get(sendDatum.getTemplateId());
            String recipientSizeStr = ' toAddresses size: ';

            if(template == null) {
                sendDatum.setErrorMsg('[Dont use Email Template] - Template Developer Name:'+sendDatum.getTemplateId());
                errorDataList.add(sendDatum);
                continue;
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTreatTargetObjectAsRecipient(false);
            if(String.isNotBlank(sendDatum.getTargetId())) {
                email.setWhatId(sendDatum.getTargetId());
                email.setSaveAsActivity(sendDatum.getIsSaveAsActivity());
            }

            //첨부파일
            if(sendDatum.getAttachmentIds() != null) {
                email.setEntityAttachments(new List<String>(sendDatum.getAttachmentIds()));
            }
            
            //TBD 고객채널 관련해서 게스트유저에게 보내는 메일은 OrgWideEmailAddress 필수
            if(String.isNotBlank(orgWideEmailId) && sendDatum.getIsUseOWE())
                email.setOrgWideEmailAddressId(orgWideEmailId);

            if(sendDatum.getIsSystem()) {
                email.setTemplateId(template.Id);  
                if(sendDatum.getIsTargetObjectId()) {
                    String recipientId = new List<String>(sendDatum.getToAddresses())[0];
                    email.setTargetObjectId(recipientId);
                    email.setTreatTargetObjectAsRecipient(true);
                    
                    //Id 가 User 일 경우 saveAsActivity 사용불가
                    if(Schema.User.SObjectType == Id.valueOf('0050w000005XKvNAAW').getSObjectType())
                    email.setSaveAsActivity(false);
                }else {
                    email.setTargetObjectId(CJFW_ModuleSetting__c.getInstance().SystemEmailWhatId__c);
                } 
                email.setSaveAsActivity(true);
            }else if(sendDatum.getIsCustom()) {
                email.setSubject(sendDatum.getTitle());
                email.setHTMLBody(sendDatum.getBody());
            }else {
                email.setSubject(sendDatum.setMessage(template.Subject));
                email.setHTMLBody(sendDatum.setMessage(template.htmlValue));
            }

            if(sendDatum.getIsTargetObjectId()) {
                String recipientId = new List<String>(sendDatum.getToAddresses())[0];
                email.setTargetObjectId(recipientId);
                email.setTreatTargetObjectAsRecipient(true);
                
                //Id 가 User 일 경우 saveAsActivity 사용불가
                if(Schema.User.SObjectType == Id.valueOf('0050w000005XKvNAAW').getSObjectType())
                email.setSaveAsActivity(false);
            }else {
                email.setToAddresses(new List<String>(sendDatum.getToAddresses()));
            }

            recipientNum += sendDatum.getToAddresses().size();
            recipientSizeStr += String.valueOf(recipientNum);
            if(sendDatum.getCcAddresses() != null && !sendDatum.getCcAddresses().isEmpty()) {
                email.setCcAddresses(new List<String>(sendDatum.getCcAddresses()));
                recipientNum += sendDatum.getCcAddresses().size();
                recipientSizeStr += ', ccAddresses size : '+String.valueOf(recipientNum);
            } 
            if(sendDatum.getBccAddresses() != null && !sendDatum.getBccAddresses().isEmpty()) {
                email.setBccAddresses(new List<String>(sendDatum.getBccAddresses()));
                recipientNum += sendDatum.getBccAddresses().size();
                recipientSizeStr += ', bccAddresses size : '+String.valueOf(recipientNum);
            }
            email.setBccSender(false);
            
            //System.debug('html :: '+email.getHtmlBody());
            if(recipientLimitNum >= recipientNum) {
                emailList.add(email);
                batchSendData.add(sendDatum);
                mappingIdxMap.put(emailList.size()-1, idx);
            }
            else {
                sendDatum.setErrorMsg('[Recipients Limit Exceeded] -'+recipientSizeStr);
                errorDataList.add(sendDatum);
            }
            idx++;
        }
        //System.debug('getEmailInvocations ::' +Limits.getEmailInvocations()); //한 트랜잭션에서 호출한 수
        //System.debug(Limits.getEmailInvocations() <= emaliLimitNum);

        //한 트랜잭션당 가능한 Email Send 검사
        if(Limits.getEmailInvocations() < emaliLimitNum || isBatch) {
            //System.debug('일반 Email 전송');
            
            IFLog__c objLog = new IFLog__c();
            objLog.Status__c = 'SUCCESS';

            IFLog__c errorobjLog = new IFLog__c();
            errorobjLog.Status__c = 'ERROR';

            Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(emailList, false);
            List<NotiEmailTemplate> successList = new List<NotiEmailTemplate>();
            List<NotiEmailTemplate> errorList = new List<NotiEmailTemplate>();
            Integer i = 0;
            for(Messaging.SendEmailResult sendResult : sendResults) {
                //System.debug(sendResult.isSuccess());
                if(!sendResult.isSuccess()) {
                    Messaging.SendEmailError[] errors = sendResult.getErrors();
                    Set<String> errorMsgSet = new Set<String>();
                    for(Messaging.SendEmailError error : errors) {
                        errorMsgSet.add(' getFields() :: '+ error.getFields() + '\n'+' getMessage() :: '+ error.getMessage()+'\n'+ ' getStatusCode() :: '+ error.getStatusCode()+'\n'+' getTargetObjectId() :: '+ error.getTargetObjectId());
                        // System.debug(' getFields() :: '+ error.getFields());
                        // System.debug(' getMessage() :: '+ error.getMessage());
                        // System.debug(' getStatusCode() :: '+ error.getStatusCode());
                        // System.debug(' getTargetObjectId() :: '+ error.getTargetObjectId());
                    }
                    if(!errorMsgSet.isEmpty()) {
                        //TBD 메일 전송 실패 이력 생성
                        tmpSendData[mappingIdxMap.get(i)].setErrorMsg(JSON.serialize(errorMsgSet)+'\n');
                        errorList.add(tmpSendData[mappingIdxMap.get(i)]);
                    }
                }else {
                    //메일 전송 성공 이력 생성
                    successList.add(tmpSendData[mappingIdxMap.get(i)]);
                    
                }
                i++;
            }

            if(!successList.isEmpty()) {
                String resultDataStr = JSON.serialize(successList);
                objLog.ResultMessage__c = resultDataStr <> null && resultDataStr.length() > 130000 ? resultDataStr.substring(0,130000) : resultDataStr;
                objLogList.add(objLog);
            }

            if(!errorList.isEmpty()) {
                String resultDataStr = JSON.serialize(errorList);
                errorobjLog.ResultMessage__c = resultDataStr <> null && resultDataStr.length() > 130000 ? resultDataStr.substring(0,130000) : resultDataStr;
                objLogList.add(errorobjLog);
            }
        }else{
            //TBD 한 트랜잭션에 Email Send 호출 수 Limit 보다 클때 트랜잭션 분리를 위해 Batch로 전송
            
            Database.executeBatch(new NotiEmailSendBatch(batchSendData), 50);
        }

        if(!errorDataList.isEmpty()) {
            //TBD Error Data 이력 생성
            
            //임시 IFLog에 저장
            String resultDataStr = JSON.serialize(errorDataList);
            IFLog__c objLog = new IFLog__c();
            objLog.Status__c = 'ERROR';
            objLog.ResultMessage__c = resultDataStr <> null && resultDataStr.length() > 130000 ? resultDataStr.substring(0,130000) : resultDataStr;
            objLogList.add(objLog);
        }

        
        NotificationManager.saveHistory(objLogList);
        

    }

   
}