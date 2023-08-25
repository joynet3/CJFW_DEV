/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class IF_DUMMY_DEL_ba_test {
    @testSetup
	static void setData() {
        IF_IFRESH_SFDC_VOC_INFO_DETAIL__c obj = new IF_IFRESH_SFDC_VOC_INFO_DETAIL__c();
                
        obj.transactionId__c = 'test12345';
        obj.IsUpdate__c = true;
        obj.IsNotVOC__c = false;

        insert obj;

	}
    @isTest 
    static void itShould() {
        IF_DUMMY_DEL_ba b = new IF_DUMMY_DEL_ba('IF_IFRESH_SFDC_VOC_INFO_DETAIL__c', 'test12345');
        Database.executeBatch(b);
    }

    @isTest 
    static void itShould2() {
        IF_DUMMY_DEL_sc scd = new IF_DUMMY_DEL_sc('IF_IFRESH_SFDC_VOC_INFO_DETAIL__c');
        SchedulableContext sc = null;
        scd.execute(sc);
    }
}