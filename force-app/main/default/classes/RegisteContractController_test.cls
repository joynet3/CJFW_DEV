/**
 * Created by kw on 2023-01-06.
 */

@IsTest
private class RegisteContractController_test {
    @IsTest
    static void RegisteContractController_test() {
        Account objAccount = TestObjectCreator.objExAccount;
        insert objAccount;
        Opportunity objOppty = new Opportunity();
        objOppty.RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('BiddingContract').getRecordTypeId();
        objOppty.Name = 'Test Oppty';
        objOppty.AccountId = objAccount.Id;
        objOppty.CloseDate = Date.today() + 7;
        objOppty.StageName = 'Negotiation';
        insert objOppty;

        Test.startTest();

        System.debug(RegisteContractController.doInit(objOppty.Id));

        objOppty.StageName = 'Closed Won';
        objOppty.ClosedReason__c = '단가 - (단가가 저렴함/비쌈)';
        update objOppty;
        System.debug(RegisteContractController.doInit(objOppty.Id));

        Date contractStartDate = Date.today();
        String contractTerm = '12';
        String ownerExpirationNotice = '15';
        String description = 'test';
        System.debug(RegisteContractController.registContract(objOppty.Id, contractStartDate,contractTerm, ownerExpirationNotice, description));
        System.debug(RegisteContractController.registContract('123', contractStartDate,contractTerm, ownerExpirationNotice, description));

        Test.stopTest();
    }
}