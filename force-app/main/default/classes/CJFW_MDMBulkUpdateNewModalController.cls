/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 10-24-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   10-24-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMBulkUpdateNewModalController {
    public CJFW_MDMBulkUpdateNewModalController(ApexPages.StandardSetController controller){
    }

     /**
     * @description 워크플로우 Lv1 카테고리 리스트 조회
     * 
     * @return      `List<workflow__c>`
     */
    @AuraEnabled
    public static List<workflow__c> getCategoryLevel1() {
        try {
            List<workflow__c> categoryLevel1 = new List<workflow__c>();
            String p2BulkUpdateLevel1 = '1';
            categoryLevel1 = [SELECT Id, Name, P2BulkUpdateLargeCode__c , P2BulkUpdateLevel__c, Page2ProcessId__c FROM workflow__c WHERE P2BulkUpdateLevel__c = :p2BulkUpdateLevel1 ORDER BY Page2ProcessId__c asc];
            
            return categoryLevel1;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * 워크플로우 Lv2 카테고리 리스트 조회
     *      
     * @return List<workflow__c>
     *
     **/
    @AuraEnabled
    public static List<workflow__c> getCategoryLevel2(String page2LargeCode) {
        system.debug(' ### CjfwMDMManagementNewModalController > getCategoryLevel2 ');
        system.debug(' >>> getCategoryLevel2 > 판매처 or 관리처  ' + page2LargeCode);

        try {
            List<workflow__c> categoryLevel2 = new List<workflow__c>();
            String p2BulkCraeteLevel2 = '2';
			categoryLevel2 = [SELECT Id, Name, P2BulkUpdateMidCategory__c, P2BulkUpdateLevel__c FROM workflow__c WHERE P2BulkUpdateLevel__c = :p2BulkCraeteLevel2 AND P2BulkUpdateLargeCode__c = :page2LargeCode];
            
            return categoryLevel2;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 워크플로우 Lv3 카테고리 리스트 조회
     *      
     * @return List<workflow__c>
     *
    **/
    @AuraEnabled
    public static List<workflow__c> getCategoryLevel3() {
        try {
            List<workflow__c> categoryLevel3 = new List<workflow__c>();
            String page2CatLevel3 = '3';
            categoryLevel3 = [SELECT Id, Name, P2BulkUpdateMidCategory__c, P2BulkUpdateLevel__c 
                              FROM workflow__c WHERE P2BulkUpdateLevel__c = :page2CatLevel3];
            
            return categoryLevel3;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}