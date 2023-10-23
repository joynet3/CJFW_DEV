/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
public with sharing class CJFW_SelectReportTypeController {

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