/**
* Email 알림 전송
*
*@group  Notification
*@author 진현욱
*@since 2023-07-25  최초작성
*/
public with sharing class EmailAlert implements NotiAlert{
    public EmailAlert() {

    }

    /**
    * App 알림 전송
    *
    *@param  sendData App 알림 Template 을 파라미터로 전송
    */
    public void send(List<NotiTemplate> sendData) {

        for(EmailTemplate sendDatum : (List<EmailTemplate>) sendData) {
            
            Messaging.SingleEmailMessage email= new Messaging.SingleEmailMessage();
            // if(orgWideEmailId != null)
            //     email.setOrgWideEmailAddressId(orgWideEmailId);
            // if(templateId != null){
            //     email.setTargetObjectId(targetId);
            //     email.setTemplateId(templateId);            
            // }
            // else{
            // }
            // email.setSubject(Subject);
            // email.setHTMLBody(htmlValue);
            // if() {
            //     email.setWhatId(objId);
            //     email.setSaveAsActivity(true);
            // }

            // email.setToAddresses(sendDatum.getToAddresses());
            // if(String.isNotBlank(sendDatum.getCcAddresses())) email.setCcAddresses(sendDatum.getCcAddresses());
            // if(String.isNotBlank(sendDatum.getBccAddresses())) email.setBccAddresses(sendDatum.getBccAddresses());

            // email.setBccSender(false);
            // email.setTreatTargetObjectAsRecipient(false);
            
        }

    }
}