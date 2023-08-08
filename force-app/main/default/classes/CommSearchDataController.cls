/**
 * @description       : CommSearchDataController.getCommSearchData
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-07-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-07-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
public with sharing class CommSearchDataController {

    /**
    *@param  menuSearch : 어떤메뉴바를 선택했는지 구분값 
    *@return  CommSearchData__c 리스트 반환 
     @description : Header에 어떤 컬럼을 노출할지 확인을 위해 해당 오브젝트에서 조회   
    */
   @AuraEnabled(cacheable=true)
   public static List<CommSearchData__c> getCommSearchData(String menuSearch){
       system.debug('CommSearchDataController #getCommSearchData => ' );
       
       List<CommSearchData__c> searList = new List<CommSearchData__c>();
           System.debug('All Data');
           searList = [SELECT 
             Id
           , Object__c
           , Type__c
           , Label__c
           , ApiName__c
           , Required__c
           , Editable__c
           , FieldType__c
           , IsMobile__c
           , Description__c 
           , HeaderLine__c
           , HeadFilterOrder__c
           , ListOrder__c
           FROM CommSearchData__c  
           WHERE Object__c =: menuSearch 
           ORDER BY HeadFilterOrder__c ASC ];   
           
           system.debug('return => ' + searList.size() );

       return searList;
   }
}