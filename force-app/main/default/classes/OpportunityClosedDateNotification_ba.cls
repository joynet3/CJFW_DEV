/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

global without sharing class OpportunityClosedDateNotification_ba implements Database.Batchable<SObject>, Database.Stateful {
    global Date targetDate;
    global OpportunityClosedDateNotification_ba(Date targetDate) {
        this.targetDate = targetDate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String strQuery = '';
        
        strQuery += '    SELECT Id';
        strQuery += '           ,Name ,Email';
        strQuery += '    FROM   User ';
        strQuery += '    WHERE  Id = \'0050w000004LSydAAG\'';

        /*
        String strQuery = '';
        
        strQuery += '    SELECT Id';
        strQuery += '           ,Name ,OwnerId ,ClosedDate';
        strQuery += '    FROM   Opportunity';
        strQuery += '    WHERE  ClosedDate = true';
        strQuery += '    AND    Closed Won != true';
        */

        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.BatchableContext bc, List<User> scope) {
        Set<String> setUserId = new Set<String>();

        for(User obj : scope) {
            setUserId.add(obj.Id);
        }

        Map<String, List<Opportunity>> mapOpportunity = new Map<String, List<Opportunity>>();

        for(Opportunity obj : [
            SELECT  Id, Name, OwnerId, CloseDate
            FROM    Opportunity
            WHERE   CloseDate =: this.targetDate
            ORDER BY Name ASC
        ]) {
            List<Opportunity> listBefore = new List<Opportunity>();

            if(mapOpportunity <> null && mapOpportunity.get(obj.OwnerId) <> null) {
                listBefore = mapOpportunity.get(obj.OwnerId);
            }

            listBefore.add(obj);
            mapOpportunity.put(obj.OwnerId, listBefore);
        }

        CustomNotificationType objCustomNotification = [
            SELECT Id, DeveloperName 
            FROM CustomNotificationType 
            WHERE DeveloperName='CustomNotification'
        ];

        String strListViewId = '00B5i0000092uvwEAA';

        for(User obj : scope) {
            // 금일 마감일자인 영업기회가 있는 경우 User에게 Notification
            if(mapOpportunity <> null && mapOpportunity.get(obj.Id) <> null) {
                for(Opportunity objOppty : mapOpportunity.get(obj.Id)) {
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();

                    // Set the contents for the notification
                    notification.setTitle('내일의 마감일자 영업기회 안내');
                    notification.setBody('마감일자 : '+objOppty.CloseDate+'\n 영업기회명 : '+objOppty.Name);

                    // Set the notification type and target
                    notification.setNotificationTypeId(objCustomNotification.Id);
                    //notification.setTargetId(objOppty.Id);

                    String strPageReference = '{type:\'standard__objectPage\', attributes: {objectApiName: \'Opportunity\',actionName: \'list\'}, state:{filterName: \'ClosingThisMonth\'}}';

                    //String strPageReference = '{type: 'standard__objectPage',attributes: {objectApiName: 'ns__Widget__c',actionName: 'list'},state: {filterName: 'Recent'}}';

                    //String strUrl = Url.getOrgDomainUrl().toExternalForm()+'/lightning/o/Opportunity/list?filterName='+strListViewId;

                    notification.setTargetPageRef(strPageReference);
                    
                    // Actually send the notification
                    Set<String> setSendUserId = new Set<String>();
                    setSendUserId.add(String.valueOf(objOppty.OwnerId));
                    notification.send(setUserId);
                }
            }
        }

        /*
        for(User obj : scope) {
            String strTitle = '영업활동 마감일자 안내';
            String strBody = '';

            String strNotificationDesc = '';

            if(mapOpportunity <> null && mapOpportunity.get(obj.Id) <> null) {

            }

            Messaging.CustomNotification notification = new Messaging.CustomNotification();

            

            // Set the contents for the notification
            notification.setTitle('Apex Custom Notification');
            notification.setBody('The notifications are coming from INSIDE the Apex!');

            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(targetId);
            
            // Actually send the notification
            
            notification.send(recipientsIds);

        }

        // Create a new custom notification

        for() {

        }
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Apex Custom Notification');
        notification.setBody('The notifications are coming from INSIDE the Apex!');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        
        notification.send(recipientsIds);

        */
    }

    global void finish(Database.BatchableContext BC) {
    }
}