/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class VOCImageView_test {
    @testSetup 
    public static void setup(){
        
    }

    @isTest 
    static void itShould() {
        VOC__c objVOC = TestObjectCreator.objVOC;
        objVOC.img_file_url1__c = 'https://www.naver.com';
        objVOC.img_file_url2__c = 'https://www.naver.com';
        objVOC.img_file_url3__c = 'https://www.naver.com';

        insert objVOC;

        VOCImageView.doInit(objVOC.Id);
    }
}