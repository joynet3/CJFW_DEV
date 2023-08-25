/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-23-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class MIG_ORDER_DEL_ba_test {
    @testSetup
	static void setData() {
        SalesLedgerInformation__c obj = new SalesLedgerInformation__c();
                
        obj.SALES_YMD__c = Date.today();        

        insert obj;

	}
    @isTest 
    static void itShould() {
        MIG_ORDER_DEL_ba b = new MIG_ORDER_DEL_ba(null, Date.today().addDays(1));
        Database.executeBatch(b);
    }
}