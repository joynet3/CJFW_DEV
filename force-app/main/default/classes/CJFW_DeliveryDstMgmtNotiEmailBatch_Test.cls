/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_DeliveryDstMgmtNotiEmailBatch_Test {
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
        emailNoti.Key__c = 'Delivery_Destination_Noti_Mail';
        emailNoti.IsSendToSender__c = false;
        emailNoti.IsActive__c = true;
        emailNoti.sObject__c  = 'CJFW_DeliveryDestinationMgmt__c';
        emailNoti.IsSystemEmail__c = false;
        emailNoti.IsDynamic__c = true;
        emailNoti.ClassName__c = 'CJFW_DeliveryDstMgmtNotiHandler';//CJFW_DeliveryDstMgmtNotiHandler_Test
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
        emailTemplate.EmailDeveloperName__c = 'DeliveryDstMgmtNotiEmailTemplete';
        emailTemplate.Notification__c = emailNoti.Id;
        templateList.add(emailTemplate);

        insert templateList;

        //
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

        Account acc = new Account(
            Name = 'testAccount',
            RecordTypeId = recordTypeId
        );
        insert acc;

        CJFW_DeliveryDestinationMgmt__c mgmt = new CJFW_DeliveryDestinationMgmt__c(
            LogisticsCenter__c = '장성센터',
            Account__c = acc.Id,
            LoadingInfo__c = '적온적재',
            // OrderForm__c = '당사 웹',
            ContactName__c = '릴리',
            Phone__c = '010-123-1234',
            InitialDate__c = System.today()
        );
        insert mgmt;
    }

    @isTest
    static void test1() {

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

        Account acc = new Account(
            Name = 'testAccount',
            RecordTypeId = recordTypeId
        );
        insert acc;

        CJFW_DeliveryDestinationMgmt__c mgmt = new CJFW_DeliveryDestinationMgmt__c(
            LogisticsCenter__c = '장성센터',
            Account__c = acc.Id,
            LoadingInfo__c = '적온적재',
            // OrderForm__c = '당사 웹',
            ContactName__c = '릴리',
            Phone__c = '010-123-1234',
            InitialDate__c = System.today()
        );
        insert mgmt;

        Test.startTest();
        
            DataBase.executeBatch( new CJFW_DeliveryDstMgmtNotiEmailBatch(), 50);
        
        Test.stopTest();
    }
}