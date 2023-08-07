@isTest
public with sharing class NotiHandler_TEST {
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
    static void getMappingClass_TEST() {
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
        System.assert('Set<AppTemplate>'.equals(notiHandler.getMappingClass('Set', notiList[0].RecordType.DeveloperName)));
        System.assert('List<AppTemplate>'.equals(notiHandler.getMappingClass('List', notiList[0].RecordType.DeveloperName)));
    }
}