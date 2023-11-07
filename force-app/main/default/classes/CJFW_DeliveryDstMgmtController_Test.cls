/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-03-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_DeliveryDstMgmtController_Test {
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
        emailNoti.Key__c = 'Delivery_Destination_Mail';
        emailNoti.IsSendToSender__c = false;
        emailNoti.IsActive__c = true;
        emailNoti.sObject__c  = 'CJFW_DeliveryDestinationMgmt__c';
        emailNoti.IsSystemEmail__c = false;
        emailNoti.IsDynamic__c = true;
        emailNoti.ClassName__c = 'CJFW_DeliveryDstMgmtCtrlNotiHandler';//CJFW_DeliveryDstMgmtNotiHandler_Test
        emailNoti.TargetFields__c = 'LC,AN,CID,CN,Ph,CT_1,CT_2,Ad,MA,TS,IniD,ST_1,ST_2,AT_1,AT_2,Key,InspYn,Insp,DL,Cd,Img,LR,RL,AV,OF,HOC,CR';
        notiList.add(emailNoti);

        insert notiList;

        //Template 부터 추가 
        schemaInfo.setSchema('NotificationTemplate__c');
        Map<String, Schema.RecordTypeInfo> recordTypeTemplateMap = schemaInfo.getRecordTypeMapByDeveloperNames(); 
        Id eamilTemplateRecordTypeId = recordTypeTemplateMap.get('Email').getRecordTypeId();

        List<NotificationTemplate__c> templateList = new List<NotificationTemplate__c>();

        NotificationTemplate__c emailTemplate = new NotificationTemplate__c();
        emailTemplate.RecordTypeId = eamilTemplateRecordTypeId;
        emailTemplate.EmailDeveloperName__c = 'DeliveryDstMgmtEmailTemplate';
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

        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
        Id mailRecordTypeId = Schema.SObjectType.MailRecipientMaster__c.getRecordTypeInfosByName().get('물류센터 담당자 설정').getRecordTypeId();

        Account acc = new Account(
            Name = 'testAccount',
            RecordTypeId = accRecordTypeId
        );
        insert acc;

        MailRecipientMaster__c mailmaster = new MailRecipientMaster__c(
            RecordTypeId = mailRecordTypeId,
            MailAddress__c = 'test@test.com',
            LogisticsCenter__c = '장성센터'
        );
        insert mailmaster;

        String imgBase64 = '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';

        CJFW_DeliveryDestinationMgmt__c mgmt = new CJFW_DeliveryDestinationMgmt__c(
            LogisticsCenter__c = '장성센터',
            Account__c = acc.Id,
            LoadingInfo__c = '적온적재',
            // OrderForm__c = '당사 웹',
            ContactName__c = '릴리',
            Phone__c = '010-123-1234',
            Photo__c = '<img src="'+imgBase64+'" />',
            InitialDate__c = System.today()
        );
        insert mgmt;

        Test.startTest();
            CJFW_DeliveryDstMgmtController.changeCompleted(mgmt.Id);
            CJFW_DeliveryDstMgmtController.sendEmail(mgmt.Id);
        Test.stopTest();
    }
}