/**
* App 알림 전송
*
*@group  Notification
*@author 진현욱
*@since 2023-07-24  최초생성
*/
public with sharing class CJFW_AppAlert implements CJFW_NotiAlert {
    public CJFW_AppAlert() {

    }

    /**
    * App 알림 전송
    *
    *@param  sendData App 알림 Template 을 파라미터로 전송
    */
    public void send(List<CJFW_NotiTemplate> sendData) {

        for(CJFW_AppTemplate sendDatum : (List<CJFW_AppTemplate>) sendData) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
    
            String subject = sendDatum.getTitle();
            String body    = sendDatum.getMessage();
    
            notification.setTitle(subject);
            notification.setBody(body);
    
            // Set the notification type and target
            notification.setNotificationTypeId(sendDatum.getTemplateId());
    
            String pageReference = sendDatum.getPageReference();
            if(String.isNotBlank(pageReference)) notification.setTargetPageRef(pageReference);
            else notification.setTargetId(sendDatum.getTargetId());
    
            try {
                notification.send(sendDatum.getToAddresses());    
            }catch (Exception e) {
                
                System.debug('Problem sending notification: ' + e.getMessage());
    
            }
            
        }

    }
}