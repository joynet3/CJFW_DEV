/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-09-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
public with sharing class CJFW_ExceptionalSellingPriceController {

    @AuraEnabled
    public static void getInitData(String recordId) {
        System.debug('getInitData !! : ' + recordId);
    }
}