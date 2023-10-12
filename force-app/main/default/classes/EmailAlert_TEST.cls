@isTest
public with sharing class EmailAlert_TEST {
    
    @TestSetup
    static void makeData(){
        NotificationManager_TEST.makeData();

        List<Case> caseList = new List<Case>();
        Case c1 = new Case(Subject = 'test');
        caseList.add(c1);
        insert caseList;

        List<Contact> conList = new List<Contact>();
        Contact targetObject = new Contact(LastName='test');
        conList.add(targetObject);
        insert conList;

        CJFW_ModuleSetting__c setting = CJFW_ModuleSetting__c.getInstance();
        setting.SystemEmailWhatId__c = targetObject.id;
        insert setting;

    }

    @isTest
    static void successAlert() {
        test.startTest();

        List<Account> acList = [ select id from Account];

        List<NotiEmailTemplate> templateList = new List<NotiEmailTemplate>();
        NotiEmailTemplate template = new NotiEmailTemplate();
        template.setTemplateId('ExtraServiceRejectedEmailTemplate');
        template.setTargetId(acList[0].id);
        template.setAttachmentIds(new Set<String>());
        template.setFieldsMap(new Map<String,String>{'Name'=>'test'});
        template.setToAddresses(new Set<String>{'test@test.com'});
        template.setCcAddresses(new Set<String>{'test2@test.com'});
        template.setBccAddresses(new Set<String>{'test3@test.com'});
        templateList.add(template);

        //저장된 Title, Body 로 데이터 보내기
        NotiEmailTemplate template2 = new NotiEmailTemplate();
        template2.setTemplateId('ExtraServiceRejectedEmailTemplate');
        template2.setTargetId(acList[0].id);
        template2.setAttachmentIds(new Set<String>());
        template2.setTitle('testTtile');
        template2.setBody('testBody');
        template2.setIsCustom(true);
        template2.setToAddresses(new Set<String>{'test@test.com'});
        templateList.add(template2);
        
        List<Case> caseList = [select id from case];

        //저장된 Title, Body 로 데이터 보내기
        NotiEmailTemplate template3 = new NotiEmailTemplate();
        template3.setTemplateId('ExtraServiceRejectedEmailTemplate');
        template3.setTargetId(caseList[0].id);
        template3.setAttachmentIds(new Set<String>());
        template3.setToAddresses(new Set<String>{'test@test.com'});
        template.setIsSystem(true);
        templateList.add(template3);

        EmailAlert alert = new EmailAlert();
        alert.send(templateList);

        test.stopTest();
    }

    @isTest
    static void successAlertByBatch() {
        test.startTest();

        List<Account> acList = [ select id from Account];
        EmailAlert alert = new EmailAlert();

        for(Integer i=0; i<11; i++) {
            List<NotiEmailTemplate> templateList = new List<NotiEmailTemplate>();
            NotiEmailTemplate template = new NotiEmailTemplate();
            template.setTemplateId('ExtraServiceRejectedEmailTemplate');
            template.setTargetId(acList[0].id);
            template.setAttachmentIds(new Set<String>());
            template.setFieldsMap(new Map<String,String>{'Name'=>'test'});
            template.setToAddresses(new Set<String>{'test@test.com'});
            template.setCcAddresses(new Set<String>{'test2@test.com'});
            template.setBccAddresses(new Set<String>{'test3@test.com'});
            templateList.add(template);
    
            alert.send(templateList);
        }

        test.stopTest();
    }


    @isTest
    static void errorAlert() {
        test.startTest();

        Set<String> recipientSet = new Set<String>();
        for(Integer i=0; i < 151; i ++) {
            recipientSet.add('test'+String.valueOf(i)+'@test.com');
        }

        List<Account> acList = [ select id from Account];

        List<NotiEmailTemplate> templateList = new List<NotiEmailTemplate>();
        //Recipient Limits Exceeded Exception
        NotiEmailTemplate template = new NotiEmailTemplate();
        template.setTemplateId('ExtraServiceRejectedEmailTemplate');
        template.setTargetId(acList[0].id);
        template.setAttachmentIds(new Set<String>());
        template.setFieldsMap(new Map<String,String>{'Name'=>'test'});
        template.setToAddresses(recipientSet);
        template.setCcAddresses(new Set<String>{'test2@test.com'});
        template.setBccAddresses(new Set<String>{'test3@test.com'});
        templateList.add(template);

        //Not use Email Template Exception
        NotiEmailTemplate template2 = new NotiEmailTemplate();
        template2.setTemplateId('test');
        template2.setTargetId(acList[0].id);
        template2.setAttachmentIds(new Set<String>());
        template2.setFieldsMap(new Map<String,String>{'Name'=>'test'});
        template2.setToAddresses(new Set<String>{'test@test.com'});
        template2.setCcAddresses(new Set<String>{'test2@test.com'});
        template2.setBccAddresses(new Set<String>{'test3@test.com'});
        templateList.add(template2);

        
        EmailAlert alert = new EmailAlert();
        alert.send(templateList);

        test.stopTest();
    }

    @isTest
    static void errorAlert_EmailFormat(){
        test.startTest();

        List<Account> acList = [ select id from Account];

        List<NotiEmailTemplate> templateList = new List<NotiEmailTemplate>();
        
        //Email format Exception
        NotiEmailTemplate template = new NotiEmailTemplate();
        template.setTemplateId('ExtraServiceRejectedEmailTemplate');
        template.setTargetId(acList[0].id);
        template.setAttachmentIds(new Set<String>());
        template.setFieldsMap(new Map<String,String>{'Name'=>'test'});
        template.setToAddresses(new Set<String>{'test'});
        template.setCcAddresses(new Set<String>{'test2@test.com'});
        template.setBccAddresses(new Set<String>{'test3@test.com'});
        templateList.add(template);

        EmailAlert alert = new EmailAlert();
        alert.isTestException = true;
        alert.send(templateList);

        test.stopTest();
    }

    @isTest
    static void getSettingOWEByUser_TEST() {
        test.startTest();
        CJFW_ModuleSetting__c userSetting = CJFW_ModuleSetting__c.getValues(UserInfo.getUserId());
        userSetting.OrgWideEmail__c = 'test@test.com';
        upsert userSetting;

        EmailAlert alert = new EmailAlert();

        test.stopTest();
    }

    @isTest
    static void getSettingOWEByProfile_TEST() {
        test.startTest();

        CJFW_ModuleSetting__c profileSetting = new CJFW_ModuleSetting__c();
        profileSetting.OrgWideEmail__c = 'test@test.com';
        profileSetting.Name = 'CustomSettingName (Profile)';
        profileSetting.SetupOwnerId = UserInfo.getProfileId();
        insert profileSetting;

        EmailAlert alert = new EmailAlert();

        test.stopTest();
    }

    @isTest
    static void getSettingOWEByOrg_TEST() {
        test.startTest();
        CJFW_ModuleSetting__c orgSetting = new CJFW_ModuleSetting__c();
        orgSetting.OrgWideEmail__c = 'test@test.com';
        orgSetting.SetupOwnerId = UserInfo.getOrganizationId();
        insert orgSetting;

        EmailAlert alert = new EmailAlert();
        test.stopTest();
    }
}