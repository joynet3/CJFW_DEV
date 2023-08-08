/**
* App 알림 전송
*
*@group  Notification
*@author 진현욱
*@since 2023-07-24  최초생성
*/
public without sharing class AppAlert implements NotiAlert {
    public AppAlert() {

    }

    /**
    * App 알림 전송
    *
    *@param  sendData App 알림 Template 을 파라미터로 전송
    */
    public void send(List<NotiTemplate> sendData) {
        /* 임시 저장 Log */
        List<IFLog__c> objLogList = new List<IFLog__c>();

        List<AppTemplate> successList = new List<AppTemplate>();
        List<AppTemplate> errorList = new List<AppTemplate>();

        for(AppTemplate sendDatum : (List<AppTemplate>) sendData) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
    
            String subject = sendDatum.getTitle();
            String body    = sendDatum.getBody();
    
            notification.setTitle(subject);
            notification.setBody(body);
    
            // Set the notification type and target
            notification.setNotificationTypeId(sendDatum.getTemplateId());
    
            String pageReference = sendDatum.getPageReference();
            if(String.isNotBlank(pageReference)) notification.setTargetPageRef(pageReference);
            else notification.setTargetId(sendDatum.getTargetId());
    
            try {

                notification.send(sendDatum.getToAddresses());    
                successList.add(sendDatum);
                
            }catch (Exception e) {
                
                System.debug('Problem sending notification: ' + e.getMessage());

                String errorMsg = 'Messaging.CustomNotification e.getMessage() = ' + e.getMessage() + ' , e.getStackTraceString() = '+e.getStackTraceString() + ', e.getLineNumber() = '+ e.getLineNumber() + ' , e.getTypeName() ' + e.getTypeName() ;
                sendDatum.setErrorMsg(errorMsg);
                errorList.add(sendDatum);

            }
            
        }

        if(!successList.isEmpty()) {
            IFLog__c objLog = new IFLog__c();
            objLog.Status__c = 'SUCCESS';
            String resultDataStr = JSON.serialize(successList);
            objLog.ResultMessage__c = resultDataStr <> null && resultDataStr.length() > 130000 ? resultDataStr.substring(0,130000) : resultDataStr;
            objLogList.add(objLog);
        }


        if(!errorList.isEmpty()) {
            IFLog__c errorobjLog = new IFLog__c();
            errorobjLog.Status__c = 'ERROR';
            String errorDataStr = JSON.serialize(errorList);
            errorobjLog.ResultMessage__c = errorDataStr <> null && errorDataStr.length() > 130000 ? errorDataStr.substring(0,130000) : errorDataStr;
            objLogList.add(errorobjLog);
        }

        NotificationManager.saveHistory(objLogList);

    }
}