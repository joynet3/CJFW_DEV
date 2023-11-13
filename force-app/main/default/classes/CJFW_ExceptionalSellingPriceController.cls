/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-10-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
public with sharing class CJFW_ExceptionalSellingPriceController {

    @AuraEnabled
    public static Map<String, Object> getInitData(String recordId) {
        System.debug('getInitData !! : ' + recordId);
        Map<String, Object> mapInitData = new Map<String, Object>();

        List<Quote> objQuote = [SELECT  Id, Name, OwnerId, EffectiveStartDate__c, ExpirationDate
                                    FROM    Quote
                                    WHERE   Id = :recordId];

        System.debug('objQuote : ' + objQuote);
        mapInitData.put('quote', objQuote);

        List<CJFW_QuoteLineItem__c> objItemList = [SELECT   Id, QuoteId__c, ProductName__c, ProductCode__c, LogisticsCenter__c, Batch__c
                                                    FROM     CJFW_QuoteLineItem__c
                                                    WHERE    QuoteId__c = :recordId
                                                    ORDER BY SortOrder__c ASC
                                                    ];

        System.debug('objItemList : ' + objItemList);
        mapInitData.put('itemList', objItemList);

        return mapInitData;

    }
}