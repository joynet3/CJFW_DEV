@isTest
public with sharing class NotificationManager_TEST {
    
    @testSetup
    static void makeData() {
        insert new IFMaster__c(Name = 'NotiAlert');

        List<CustomNotificationType> customNotiTypeList = [
            select
                Id, DeveloperName
            from CustomNotificationType 
        ];

        List<Notification__c> notiList = new List<Notification__c>();

        COMM_Util.SchemaInfo schemaInfo = new COMM_Util.SchemaInfo('Notification__c');
        Map<String, Schema.RecordTypeInfo> recordTypeMap = schemaInfo.getRecordTypeMapByDeveloperNames(); 
        Id appRecordTypeId = recordTypeMap.get('App').getRecordTypeId();
        Id eamilRecordTypeId = recordTypeMap.get('Email').getRecordTypeId();

        List<Account> testAccountList = new List<Account>();
        Account testAccount = new Account(Name='App Noti Test');
        testAccountList.add(testAccount);
        insert testAccountList;
        
        Notification__c appNoti = new Notification__c();
        appNoti.RecordTypeId = appRecordTypeId;
        appNoti.Key__c = 'Sample_Noti_App';
        appNoti.IsSendToSender__c = true;
        appNoti.IsActive__c = true;
        appNoti.sObject__c  = 'Account';
        appNoti.TargetFields__c = 'Id,Name,Owner.Name';
        appNoti.CustomNotificationTypeId__c = customNotiTypeList[0].DeveloperName;
        notiList.add(appNoti);

        Notification__c emailNoti = new Notification__c();
        emailNoti.RecordTypeId = eamilRecordTypeId;
        emailNoti.Key__c = 'Sample_Noti_Email';
        emailNoti.IsSendToSender__c = true;
        emailNoti.IsActive__c = true;
        emailNoti.sObject__c  = 'Account';
        emailNoti.TargetFields__c = 'Id,Name,Owner.Name';
        notiList.add(emailNoti);

        insert notiList;

        //NotiTarget 추가
        schemaInfo.setSchema('NotificationTarget__c');
        Map<String, Schema.RecordTypeInfo> recordTypeNotiTargetMap = schemaInfo.getRecordTypeMapByDeveloperNames(); 
        Id userRecordTypeId = recordTypeNotiTargetMap.get('User').getRecordTypeId();
        Id groupRecordTypeId = recordTypeNotiTargetMap.get('Group').getRecordTypeId();
        Id roleRecordTypeId = recordTypeNotiTargetMap.get('Role').getRecordTypeId();

        List<NotificationTarget__c> notiTargetList = new List<NotificationTarget__c>();
        NotificationTarget__c userTypeTarget = new NotificationTarget__c();
        userTypeTarget.User__c = UserInfo.getUserId();
        userTypeTarget.RecordTypeId = userRecordTypeId;
        userTypeTarget.Notification__c = emailNoti.Id;
        notiTargetList.add(userTypeTarget);

        insert notiTargetList;

        //Template 부터 추가 
        schemaInfo.setSchema('NotificationTemplate__c');
        Map<String, Schema.RecordTypeInfo> recordTypeTemplateMap = schemaInfo.getRecordTypeMapByDeveloperNames(); 
        Id appTemplateRecordTypeId = recordTypeTemplateMap.get('App').getRecordTypeId();
        Id eamilTemplateRecordTypeId = recordTypeTemplateMap.get('Email').getRecordTypeId();

        List<NotificationTemplate__c> templateList = new List<NotificationTemplate__c>();

        NotificationTemplate__c appTemplate = new NotificationTemplate__c();
        appTemplate.RecordTypeId = appTemplateRecordTypeId;
        appTemplate.Title__c = 'Test Title';
        appTemplate.Message__c = 'Name : {1} , Id {0}';
        appTemplate.Notification__c = appNoti.Id;
        templateList.add(appTemplate);

        NotificationTemplate__c emailTemplate = new NotificationTemplate__c();
        emailTemplate.RecordTypeId = eamilTemplateRecordTypeId;
        emailTemplate.EmailDeveloperName__c = 'ExtraServiceRejectedEmailTemplate';
        emailTemplate.Notification__c = emailNoti.Id;
        templateList.add(emailTemplate);


        insert templateList;
        
    }

    @isTest
    static void appAlertExecute_test() {

        String userId = UserInfo.getUserId();

        /*
            1. 수신자 Id 기준 
            2. 알림 개인화시 RecordId 기준
        */
        List<Account> targetAccountList = [select Id, Name, Owner.Name from Account];
        String targetId = targetAccountList[0].Id;
        NotiTarget recipientId = new NotiTarget('id');
        recipientId.setToAddresses(new Set<String>{userId});
        NotificationManager.getInstance()
                            .setTargetIdSet(new Set<String>{targetId})
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientId}
                            })
                            .execute('Sample_Noti_App');


        /*
            1. 수신자 Id 기준 
            2. 알림 개인화시 sObject List 기준
         */ 
        recipientId.setToAddresses(new Set<String>{userId});
        NotificationManager.getInstance()
                            .setTargetSObjectList(targetAccountList)
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientId}
                            })
                            .execute('Sample_Noti_App');
                           

        /*
            1. 수신자 Id 기준 
            2. 알림 개인화시 Object 기준
        */
        recipientId.setToAddresses(new Set<String>{userId});
        NotificationManager.getInstance()
                            .setTargetObject(targetAccountList)
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientId}
                            })
                            .execute('Sample_Noti_App');
        
    }

    @isTest
    static void emailAlertExecute_test() {

        String userId = UserInfo.getUserId();

        /*
            1. 수신자 Id 기준 
            2. 알림 개인화시 RecordId 기준
        */
        List<Account> targetAccountList = [select Id, Name, Owner.Name from Account];
        String targetId = targetAccountList[0].Id;
        NotiTarget recipientId = new NotiTarget('id');
        recipientId.setToAddresses(new Set<String>{userId});
        NotificationManager.getInstance()
                            .setTargetIdSet(new Set<String>{targetId})
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientId}
                            })
                            .execute('Sample_Noti_Email');


        /*
            1. 수신자 Id 기준 
            2. 알림 개인화시 sObject List 기준
         */ 
        recipientId.setToAddresses(new Set<String>{userId});
        NotificationManager.getInstance()
                            .setTargetSObjectList(targetAccountList)
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientId}
                            })
                            .execute('Sample_Noti_Email');
                           

        /*
            1. 수신자 Id 기준 
            2. 알림 개인화시 Object 기준
        */
        recipientId.setToAddresses(new Set<String>{userId});
        NotificationManager.getInstance()
                            .setTargetObject(targetAccountList)
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientId}
                            })
                            .execute('Sample_Noti_Email');

        
        /*
            1. 수신자 Email 기준 
            2. 알림 개인화시 RecordId 기준
        */
        NotiTarget recipientEmail = new NotiTarget('email');
        recipientEmail.setToAddresses(new Set<String>{'test@test.com'});
        NotificationManager.getInstance()
                            .setTargetIdSet(new Set<String>{targetId})
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientEmail}
                            })
                            .execute('Sample_Noti_Email');

                            
         /*
            1. 수신자 Email 기준 
            2. 알림 개인화시 sObject List 기준
         */ 
        
        recipientEmail.setToAddresses(new Set<String>{'test@test.com'});
        NotificationManager.getInstance()
                            .setTargetSObjectList(targetAccountList)
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientEmail}
                            })
                            .execute('Sample_Noti_Email');
                           

        /*
            1. 수신자 Email 기준 
            2. 알림 개인화시 Object 기준
        */
        recipientEmail.setToAddresses(new Set<String>{'test@test.com'});
        NotificationManager.getInstance()
                            .setTargetObject(targetAccountList)
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientEmail}
                            })
                            .execute('Sample_Noti_Email');
        
    }

    @isTest
    static void sendTest() {
        CJFW_ModuleSetting__c module = CJFW_ModuleSetting__c.getInstance();
        module.IsNotiTest__c = true;
        insert module;

        List<Notification__c> notiList = [ select Id from Notification__c ];
        for(Notification__c noti : notiList) {
            noti.IsNotiTest__c = true;
        }
        update notiList;

        String userId = UserInfo.getUserId();
        /*
            1. 수신자 Id 기준 
            2. 알림 개인화시 RecordId 기준
        */
        List<Account> targetAccountList = [select Id, Name, Owner.Name from Account];
        String targetId = targetAccountList[0].Id;
        NotiTarget recipientId = new NotiTarget('id');
        recipientId.setToAddresses(new Set<String>{userId});
        NotificationManager.getInstance()
                            .setTargetIdSet(new Set<String>{targetId})
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientId}
                            })
                            .execute('Sample_Noti_App');


        /*
            1. 수신자 Email 기준 
            2. 알림 개인화시 RecordId 기준
        */
        NotiTarget recipientEmail = new NotiTarget('email');
        recipientEmail.setToAddresses(new Set<String>{'test@test.com'});
        NotificationManager.getInstance()
                            .setTargetIdSet(new Set<String>{targetId})
                            .setRecipientListMap(new Map<String,List<NotiTarget>>{
                                targetId => new List<NotiTarget>{recipientEmail}
                            })
                            .execute('Sample_Noti_Email');
    }
}