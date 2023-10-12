/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-11-2023
 * @last modified by  : seol.kim@dkbmc.com
**/

@isTest
public class CJFW_CategoryFileController_test {
    @isTest
    static void makeData(){
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        insert opp;

        ContentDocumentLink cdList = new ContentDocumentLink();
        cdList.LinkedEntityId = opp.Id;
        insert cdList;

        Test.startTest();
        CJFW_CategoryFileController.getFileList('계약 참고자료', opp.Id);
        Test.stopTest();

        
    }

}