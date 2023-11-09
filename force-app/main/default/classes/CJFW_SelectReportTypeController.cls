/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
public with sharing class CJFW_SelectReportTypeController {

    /*
     * cjfwChooseReportTypeModal lwc에서 사용 
     * Oppty Obj에서 유형, Owner의 본부 가져오기
     */
    @AuraEnabled
    public static List<Opportunity> getOpptyType(String Id) {
        try {
            System.debug('Id = ' + Id);
            List<Opportunity> typeData = [
                SELECT Id, Type, Owner.HeadOffice__c
                 FROM Opportunity
                 WHERE Id =: Id 
            ];

            return typeData.size()>0 ? typeData : new List<Opportunity>();
        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

    }


}