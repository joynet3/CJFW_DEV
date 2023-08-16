@isTest
public with sharing class NotiEmailSendBatch_TEST {
    @TestSetup
    static void makeData(){
        NotificationManager_TEST.makeData();
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

        Database.executeBatch(new NotiEmailSendBatch(templateList), 50);

        new NotiEmailSendBatch();

        test.stopTest();
    }
}