/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-17-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
@isTest
public with sharing class CJFW_CategoryFilePickList_test {

    @TestSetup
    static void makeData(){

        ContentVersion cv = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            Category__c = '파일',
            IsMajorVersion = true
        );
        insert cv;
    }

    @isTest
    static void getDefaultValue() {
        
        Test.startTest();
        CJFW_CategoryFilePickList pickList = new CJFW_CategoryFilePickList();

        VisualEditor.DataRow defaultValue = pickList.getDefaultValue();
        // VisualEditor.DynamicPickListRows result = pickList.getValues();

        System.assertEquals('파일', defaultValue.getLabel());
        System.assertEquals('파일', defaultValue.getValue());

        // System.assertNotEquals(null, result);
        // System.assertEquals(1, result.size()); 
        Test.stopTest();
    }

    @isTest
    static void testGetValues() {
        Test.startTest();
        CJFW_CategoryFilePickList pickList = new CJFW_CategoryFilePickList();
        VisualEditor.DynamicPickListRows values = pickList.getValues();

        List<ContentVersion> contentVersions = [SELECT Category__c FROM ContentVersion];

        System.assertEquals('파일', contentVersions[0].Category__c, 'Category__c 필드 값이 예상과 다릅니다.');

        Test.stopTest();
    }
}