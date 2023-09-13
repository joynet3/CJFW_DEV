/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 09-13-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
**/
public with sharing class CJFW_MDMSecondaryController {

    @AuraEnabled
    public static List<Account> getHKUNNR(String selectedId) {
        List<Account> accList = [SELECT Id, ParentId
                                FROM Account
                                WHERE Id =: selectedId
                                LIMIT 1];
        return accList;
    }
}