/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class MDMReferenceCode_tr_test {
    @testSetup
	static void setData() {
        MDMReferenceCode__c obj = new MDMReferenceCode__c();
        obj.GROUPID__c = 'TEST';
        obj.Code__c = '001';
        obj.NAME_KO__c = '테스트';
        obj.IsDefault__c = true;
        obj.IsActive__c = true;

        insert obj;
	}
    @isTest 
    static void itShoud() {
        Test.startTest();

        MDMReferenceCode__c obj = new MDMReferenceCode__c();
        obj.GROUPID__c = 'TEST';
        obj.Code__c = '002';
        obj.NAME_KO__c = '테스트2';
        obj.IsDefault__c = true;
        obj.IsActive__c = true;
        obj.ParentCode__c = '001';
        obj.ParentGroupId__c = 'TEST';

        insert obj;

        Test.stopTest();
    }
}