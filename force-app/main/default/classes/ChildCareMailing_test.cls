@IsTest
private class ChildCareMailing_test {
    @TestSetup
    static void  ChildCareMailing_testSetUp() {
        try{
            String recordtypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('KindergartenLead').getRecordTypeId();
            Lead objLead =  new Lead();
            objLead.recordTypeId = recordtypeId;
            objLead.Region__c = '서울특별시은평구';
            objLead.AuthorizationDate__c = date.today();
            objLead.NumberofChildren__c = 0;
            objLead.LastName = 'CJFW';
            objLead.Company = '어린이집';
            insert objLead;

            String recordtypeId2 = Schema.SObjectType.MailRecipientMaster__c.getRecordTypeInfosByDeveloperName().get('NewChildCare').getRecordTypeId();
            MailRecipientMaster__c objMR = new MailRecipientMaster__c();
            objMR.Name = 'test user';
            objMR.RegionList__c = '서울특별시은평구';
            objMR.MailAddress__c = 'test@test.com';
            objMR.recordTypeId = recordtypeId2;
            insert objMR;

        } catch (Exception e) {
            System.debug('CalcNoPriceFuelActivity_test line : ' + e.getLineNumber());
            System.debug('CalcNoPriceFuelActivity_test message : ' + e.getMessage());
            System.debug('CalcNoPriceFuelActivity_test cause : ' + e.getCause());
        }
    }

    @IsTest
    static void ChildCareMailing_test() {
        String recordtypeId2 = Schema.SObjectType.MailRecipientMaster__c.getRecordTypeInfosByDeveloperName().get('NewChildCare').getRecordTypeId();
        MailRecipientMaster__c objMR2 = new MailRecipientMaster__c();
        objMR2.Name = 'test user';
        objMR2.RegionList__c = '서울특별시은평구';
        objMR2.MailAddress__c = 'test@test.com';
        objMR2.recordTypeId = recordtypeId2;
        insert objMR2;

        Test.startTest();
        ChildCareMailing_Scheduler_sc sc = new ChildCareMailing_Scheduler_sc();
        System.schedule('ChildCareMailing_Scheduler_sc','0 0 2 1/1 * ? *', sc);

        Test.stopTest();
    }

    
}