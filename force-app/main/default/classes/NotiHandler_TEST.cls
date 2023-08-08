@isTest
public with sharing class NotiHandler_TEST {
    @testSetup
    static void makeData() {
        NotificationManager_TEST.makeData();
        
    }

    @isTest
    static void testCase() {
        //RecordType: App
        List<Notification__c> notiList = [
            select 
                ClassName__c
                , IsDynamic__c
                , Key__c
                , Description__c
                , CustomNotificationTypeId__c
                , PageReference__c
                , sObject__c
                , TargetFields__c
                , IsSendToSender__c
                , RecordType.DeveloperName
                , IsNotiTest__c
                , IsSystemEmail__c
                , IsUseOWE__c
                , IsSaveAsActivity__c
                ,(   select 
                        Title__c
                        , Message__c
                        , Language__c
                        , EmailDeveloperName__c
                        , RecordType.DeveloperName 
                    from Notification_Template__r
                )
                ,(   select 
                        GroupId__c
                        , GroupName__c
                        , RoleId__c
                        , RoleName__c
                        , User__c
                        , RecordType.DeveloperName 
                    from Notification_Target__r
                )
            from Notification__c
            where 
                IsActive__c = true
                and Key__c = 'Sample_Noti_App'
        ];
        
        NotiHandler notiHandler = new NotiHandler();
        notiHandler.setNotiData(notiList[0]);

        //getMappingClass_TEST
        System.assert('Set<AppTemplate>'.equals(notiHandler.getMappingClass('Set', notiList[0].RecordType.DeveloperName)));
        System.assert('List<AppTemplate>'.equals(notiHandler.getMappingClass('List', notiList[0].RecordType.DeveloperName)));


        //getTemplate_TEST
        notiHandler.getTemplate();

        //getRicipientIdSet_TEST
        notiHandler.getRicipientIdSet();

        //setCategorySendDataListMap_TEST 알림 전송시에 필수적인 값: notiHandler.categorySendDataListMap
        Map<String, Map<String,NotiTemplate>> categoryTemplateMapMap = notiHandler.categoryTemplateMapMap;
        notiHandler.setCategorySendDataListMap(notiHandler.categorySendDataListMap ,'App', categoryTemplateMapMap.get('App').get('ko'));

        //notiHandler_TEST
        notiHandler.setExcludeRecipient();

        List<Account> targetAccountList = [select Id, Name, Owner.Name from Account];
        Set<String> targetIds = new Set<String>();

        Map<String,List<NotiTarget>> recipientMap = new Map<String,List<NotiTarget>>();
        NotiTarget recipientId = new NotiTarget('id');
        recipientId.setToAddresses(new Set<String>{UserInfo.getUserId()});

        for(Account ac : targetAccountList) {
            targetIds.add(ac.Id);
            recipientMap.put(ac.Id, new List<NotiTarget>{recipientId});
        }

        Id targetId = targetAccountList[0].Id;
        String targetName = targetAccountList[0].Name;

        String message = 'Name : '+targetName+' , Id '+String.valueOf(targetId);
        //초기화
        notiHandler.setNotiData(notiList[0]);
        //수신자 set
        NotificationManager.getInstance().setRecipientListMap(recipientMap);

        //execute_TEST App
        notiHandler.execute(targetIds, null, null);
        for(String category : notiHandler.categorySendDataListMap.keySet()) {
            for(NotiTemplate sendTemplate : notiHandler.categorySendDataListMap.get(category)) {
                if(targetId == sendTemplate.getTargetId()){
                    System.assert(message.equals(sendTemplate.getBody()));
                }
            }
        }

        notiList = [
            select 
                ClassName__c
                , IsDynamic__c
                , Key__c
                , Description__c
                , CustomNotificationTypeId__c
                , PageReference__c
                , sObject__c
                , TargetFields__c
                , IsSendToSender__c
                , RecordType.DeveloperName
                , IsNotiTest__c
                , IsSystemEmail__c
                , IsUseOWE__c
                , IsSaveAsActivity__c
                ,(   select 
                        Title__c
                        , Message__c
                        , Language__c
                        , EmailDeveloperName__c
                        , RecordType.DeveloperName 
                    from Notification_Template__r
                )
                ,(   select 
                        GroupId__c
                        , GroupName__c
                        , RoleId__c
                        , RoleName__c
                        , User__c
                        , RecordType.DeveloperName 
                    from Notification_Target__r
                )
            from Notification__c
            where 
                IsActive__c = true
                and Key__c = 'Sample_Noti_Email'
        ];

        //초기화
        notiHandler.setNotiData(notiList[0]);

        //수신자 set
        NotificationManager.getInstance().setRecipientListMap(recipientMap);

        //execute_TEST App
        notiHandler.execute(targetIds, null, null);

        recipientMap = new Map<String,List<NotiTarget>>();
        NotiTarget recipientEmail = new NotiTarget('email');
        recipientEmail.setToAddresses(new Set<String>{'test@test.com'});
        recipientEmail.setCcAddresses(new Set<String>{'test2@test.com'});
        recipientEmail.setBccAddresses(new Set<String>{'test3@test.com'});

        NotiTarget recipientEmail2 = new NotiTarget('email');
        recipientEmail2.setToAddresses(new Set<String>{'test4@test.com','test5@test.com'});
        recipientEmail2.setCcAddresses(new Set<String>{'test6@test.com','test7@test.com'});
        recipientEmail2.setBccAddresses(new Set<String>{'test8@test.com','test9@test.com'});

        for(Account ac : targetAccountList) {
            recipientMap.put(ac.Id, new List<NotiTarget>{recipientEmail});
        }

        targetId = targetAccountList[1].Id;
        recipientMap.get(targetId).add(recipientEmail2);

         //초기화
         notiHandler.setNotiData(notiList[0]);

        //수신자 set
        NotificationManager.getInstance().setRecipientListMap(recipientMap);

        //execute_TEST Email 단건, 다건
        notiHandler.execute(targetIds, null, null);
        for(String category : notiHandler.categorySendDataListMap.keySet()) {
            for(NotiTemplate sendTemplate : notiHandler.categorySendDataListMap.get(category)) {
                if(targetId == sendTemplate.getTargetId()){
                    if(sendTemplate.getToAddresses().size() > 1) {
                        System.assert(sendTemplate.getToAddresses().contains('test5@test.com'));
                    }
                    else {
                        System.debug(sendTemplate.getToAddresses());
                        if(new List<String>(sendTemplate.getToAddresses())[0].contains('@'))
                        System.assert(sendTemplate.getToAddresses().contains('test@test.com'));
                    }
                }
            }
        }



    }


}