@isTest
public class MDMReferenceCodeSearch_test {
    @TestSetup
    static void makeData(){
        MDMReferenceCode__c code = new MDMReferenceCode__c();
        code.GROUPID__c = 'GROUPID__c';
        code.CODE__c = '0001';
        code.NAME_KO__c = 'Test';
        code.Name = 'Test';
        insert code;
    }

    @IsTest
    static void test_001(){
        Test.startTest();
        MDMReferenceCodeSearch.doInit('GROUPID__c', '0001');
        Test.stopTest();
        
    }

    @IsTest
    static void test_002(){
        MDMReferenceCodeSearch.SearchResult sr = new MDMReferenceCodeSearch.SearchResult();
        sr.strId = '';
        sr.strName = '';
        sr.strGroupId = '';
        sr.strCode = '';
        Test.startTest();
        MDMReferenceCodeSearch.doSearch('GROUPID__c', 'Test');
        Test.stopTest();
        
    }
}