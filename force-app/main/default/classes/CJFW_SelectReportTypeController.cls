/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
public with sharing class CJFW_SelectReportTypeController {

    /*
     * Oppty Obj에서 유형 가져오기
     */
    @AuraEnabled
    public static List<Opportunity> getOpptyType(String Id) {
        try {
            System.debug('Id = ' + Id);
            List<Opportunity> typeData = [
                SELECT Id, Type
                FROM Opportunity
                WHERE Id =: Id 
            ];

            return typeData.size()>0 ? typeData : new List<Opportunity>();
        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

    }


    /*
     * User Obj에서 본부명 가져오기
     */
    @AuraEnabled
    public static List<User> getHeadLabel(String userId) {
        try {
            System.debug('userId = ' + userId);
            List<User> headLabelData = [
                SELECT Id, HeadOfficeLabel__c 
                FROM User
                WHERE Id =: userId 
            ];

            return headLabelData.size()>0 ? headLabelData : new List<User>();
        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

    }

}