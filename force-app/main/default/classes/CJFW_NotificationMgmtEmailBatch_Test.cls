/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-07-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_NotificationMgmtEmailBatch_Test {
    @testSetup
    public static void makeData() {
        insert new IFMaster__c(Name = 'NotiAlert');

        List<CustomNotificationType> customNotiTypeList = [
            select
                Id, DeveloperName
            from CustomNotificationType 
        ];

        List<Notification__c> notiList = new List<Notification__c>();

        COMM_Util.SchemaInfo schemaInfo = new COMM_Util.SchemaInfo('Notification__c');
        Map<String, Schema.RecordTypeInfo> recordTypeMap = schemaInfo.getRecordTypeMapByDeveloperNames(); 
        Id eamilRecordTypeId = recordTypeMap.get('Email').getRecordTypeId();

        Notification__c emailNoti = new Notification__c();
        emailNoti.RecordTypeId = eamilRecordTypeId;
        emailNoti.Key__c = 'Notification_Mgmt_Noti_Mail';
        emailNoti.IsSendToSender__c = false;
        emailNoti.IsActive__c = true;
        emailNoti.sObject__c  = 'NotificationManagement__c';
        emailNoti.IsSystemEmail__c = false;
        emailNoti.IsDynamic__c = true;
        emailNoti.ClassName__c = 'CJFW_NotificationMgmtEmailNotiHandler';//CJFW_ContractExpirationEmailBatch_Test
        emailNoti.TargetFields__c = '0';
        notiList.add(emailNoti);

        insert notiList;

        //Template 부터 추가 
        schemaInfo.setSchema('NotificationTemplate__c');
        Map<String, Schema.RecordTypeInfo> recordTypeTemplateMap = schemaInfo.getRecordTypeMapByDeveloperNames(); 
        Id eamilTemplateRecordTypeId = recordTypeTemplateMap.get('Email').getRecordTypeId();

        List<NotificationTemplate__c> templateList = new List<NotificationTemplate__c>();
        
        NotificationTemplate__c emailTemplate = new NotificationTemplate__c();
        emailTemplate.RecordTypeId = eamilTemplateRecordTypeId;
        emailTemplate.EmailDeveloperName__c = 'NotificationMgmtEmailTemplete';
        emailTemplate.Notification__c = emailNoti.Id;
        templateList.add(emailTemplate);

        insert templateList;

    }

    @isTest
    static void test1() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

        Account acc = new Account(
            Name = 'testAccount',
            RecordTypeId = recordTypeId
        );
        insert acc;

        NotificationManagement__c noti = new NotificationManagement__c(
            Account__c = acc.Id,
            Cycle__c = '30',
            StartDate__c = Date.today().addMonths(-12).addDays(30),
            Period__c = '1Y'
        );
        insert noti;

        Test.startTest();
            DataBase.executeBatch( new CJFW_NotificationMgmtEmailBatch(), 50);
        Test.stopTest();
    }
}