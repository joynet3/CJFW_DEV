/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   10-23-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CjfwMDMBulkCreateNewModalController {
    public CjfwMDMBulkCreateNewModalController(ApexPages.StandardSetController controller){
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
            String p2BulkCreateLevel1 = '1';
            categoryLevel1 = [SELECT Id, Name, P2BulkCreateLargeCode__c , P2BulkCreateLevel__c, Page2ProcessId__c FROM workflow__c WHERE P2BulkCreateLevel__c = :p2BulkCreateLevel1 ORDER BY Page2ProcessId__c asc];
            
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
        system.debug(' >>> getCategoryLevel2 >  ' + page2LargeCode);

        try {
            List<workflow__c> categoryLevel2 = new List<workflow__c>();
            String page2catLevel2 = '2';
			categoryLevel2 = [SELECT Id, Name, Page2MidCategory__c, Page2Level__c FROM workflow__c WHERE Page2Level__c = :Page2CatLevel2 AND Page2LargeCode__c = :page2LargeCode];
            system.debug('>>> categoryLevel2 ' + categoryLevel2);
            
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
    public static List<workflow__c> getCategoryLevel3(String pageMidCode) {
        try {
            system.debug('pageMidCode' + pageMidCode);
            List<workflow__c> categoryLevel3 = new List<workflow__c>();
            String page2CatLevel3 = '3';
            categoryLevel3 = [SELECT Id, Name, Page2MidCategory__c, Page2getCategory__c,Page2level__c 
                              FROM workflow__c WHERE Page2Level__c = :page2CatLevel3 AND Page2MidCategory__c = :pageMidCode];

            system.debug('>>> page2CatLevel3 ' + categoryLevel3);
            system.debug('>>> page2CatLevel3 ' + Json.serialize(categoryLevel3));

            
            return categoryLevel3;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}