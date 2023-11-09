/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   10-23-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CjfwMDMBulkCreateNewModalController {
    // public CjfwMDMBulkCreateNewModalController(ApexPages.StandardSetController controller){
    // }

    //  /**
    //  * @description 워크플로우 Lv1 카테고리 리스트 조회
    //  * 
    //  * @return      `List<workflow__c>`
    //  */
    // @AuraEnabled
    // public static List<workflow__c> getCategoryLevel1() {
    //     try {
    //         List<workflow__c> categoryLevel1 = new List<workflow__c>();
    //         String p2BulkCreateLevel1 = '1';
    //         categoryLevel1 = [SELECT Id, Name, P2BulkCreateLargeCode__c , P2BulkCreateLevel__c, Page2ProcessId__c FROM workflow__c WHERE P2BulkCreateLevel__c = :p2BulkCreateLevel1 ORDER BY Page2ProcessId__c asc];
            
    //         return categoryLevel1;
            
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    
    // /**
    //  * 워크플로우 Lv2 카테고리 리스트 조회
    //  *      
    //  * @return List<workflow__c>
    //  *
    //  **/
    // @AuraEnabled
    // public static List<workflow__c> getCategoryLevel2(String page2LargeCode) {
    //     system.debug(' ### CjfwMDMManagementNewModalController > getCategoryLevel2 ');
    //     system.debug(' >>> getCategoryLevel2 > 판매처 or 관리처  ' + page2LargeCode);

    //     try {
    //         List<workflow__c> categoryLevel2 = new List<workflow__c>();
    //         String p2BulkCraeteLevel2 = '2';
	// 		categoryLevel2 = [SELECT Id, Name, P2BulkCreateMidCategory__c, P2BulkCreateLevel__c FROM workflow__c WHERE P2BulkCreateLevel__c = :p2BulkCraeteLevel2 AND P2BulkCreateLargeCode__c = :page2LargeCode];
            
    //         return categoryLevel2;
            
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // /**
    //  * 워크플로우 Lv3 카테고리 리스트 조회
    //  *      
    //  * @return List<workflow__c>
    //  *
    // **/
    // @AuraEnabled
    // public static List<workflow__c> getCategoryLevel3() {
    //     try {
    //         List<workflow__c> categoryLevel3 = new List<workflow__c>();
    //         String page2CatLevel3 = '3';
    //         categoryLevel3 = [SELECT Id, Name, P2BulkCreateMidCategory__c, P2BulkCreateLevel__c 
    //                           FROM workflow__c WHERE P2BulkCreateLevel__c = :page2CatLevel3];
            
    //         return categoryLevel3;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
}