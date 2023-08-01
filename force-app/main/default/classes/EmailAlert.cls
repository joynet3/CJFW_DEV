/**
* Email 알림 전송
*
*@group  Notification
*@author 진현욱
*@since 2023-07-25  최초작성
*/
public without sharing class EmailAlert implements NotiAlert{
    
    final Integer emaliLimitNum = 10;       // System Limit 으로 트랜잭션에서 이메일 전송 메소드 호출 가능 수
    final Integer recipientLimitNum = 150;  // System Limit 으로 한 Email 에 보낼 수 있는 수신자,참조,숨은참조 총 수
    Boolean isBatch = false;
    
    public EmailAlert() {
       
    }

    /**
    * Email 알림 전송
    *
    *@param  sendData Email 알림 Template 을 파라미터로 전송
    */
    public void send(List<NotiTemplate> sendData) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<NotiEmailTemplate> errorDataList = new List<NotiEmailTemplate>();
        List<NotiEmailTemplate> tmpSendData = (List<NotiEmailTemplate>) sendData;
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
        

        for(NotiEmailTemplate sendDatum : tmpSendData) {
            Integer recipientNum = 0;
            EmailTemplate template = templateMap.get(sendDatum.getTemplateId());
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            //TBD 고객채널 관련해서 게스트유저에게 보내는 메일은 OrgWideEmailAddress 필수
            // if(orgWideEmailId != null)
            //     email.setOrgWideEmailAddressId(orgWideEmailId);
            // if(templateId != null){
            //     email.setTargetObjectId(targetId);
            //     email.setTemplateId(templateId);            
            // }
            // else{
            // }
            if(sendDatum.getIsCustom()) {
                email.setSubject(sendDatum.getTitle());
                email.setHTMLBody(sendDatum.getBody());
            }else {
                email.setSubject(sendDatum.setMessage(template.Subject));
                email.setHTMLBody(sendDatum.setMessage(template.htmlValue));
            }

            if(String.isNotBlank(sendDatum.getTargetId())) {
                email.setWhatId(sendDatum.getTargetId());
                email.setSaveAsActivity(true);
            }

            email.setToAddresses(new List<String>(sendDatum.getToAddresses()));
            recipientNum += sendDatum.getToAddresses().size();
            if(sendDatum.getCcAddresses() != null && !sendDatum.getCcAddresses().isEmpty()) {
                email.setCcAddresses(new List<String>(sendDatum.getCcAddresses()));
                recipientNum += sendDatum.getCcAddresses().size();
            } 
            if(sendDatum.getBccAddresses() != null && !sendDatum.getBccAddresses().isEmpty()) {
                email.setBccAddresses(new List<String>(sendDatum.getBccAddresses()));
                recipientNum += sendDatum.getBccAddresses().size();
            }
            email.setBccSender(false);
            email.setTreatTargetObjectAsRecipient(false);
            
            if(recipientLimitNum >= recipientNum) emailList.add(email);
            else errorDataList.add(sendDatum);
        }

        //한 트랜잭션당 가능한 Email Send 검사
        if(Limits.getEmailInvocations() <= emaliLimitNum || isBatch) {
            Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(emailList, false);
            for(Messaging.SendEmailResult sendResult : sendResults) {
                //System.debug(sendResult.isSuccess());
                if(!sendResult.isSuccess()) {
                    Messaging.SendEmailError[] errors = sendResult.getErrors();
                    Set<String> errorMsgSet = new Set<String>();
                    for(Messaging.SendEmailError error : errors) {
                        errorMsgSet.add(' getFields() :: '+ error.getFields() + '\n'+' getMessage() :: '+ error.getMessage()+'\n'+ ' getStatusCode() :: '+ error.getStatusCode()+'\n'+' getTargetObjectId() :: '+ error.getTargetObjectId());
                        System.debug(' getFields() :: '+ error.getFields());
                        System.debug(' getMessage() :: '+ error.getMessage());
                        System.debug(' getStatusCode() :: '+ error.getStatusCode());
                        System.debug(' getTargetObjectId() :: '+ error.getTargetObjectId());
                    }
                    if(!errorMsgSet.isEmpty()) {
                        //TBD 메일 전송 실패 이력 생성
                    }
                }
            }
        }else{
            //TBD 한 트랜잭션에 Email Send 호출 수 Limit 보다 클때 트랜잭션 분리를 위해 Batch로 전송
        }

        if(!errorDataList.isEmpty()) {
            //TBD Error Data 이력 생성
        }

        System.debug('getEmailInvocations ::' +Limits.getEmailInvocations()); //한 트랜잭션에서 호출한 수

    }

   
}