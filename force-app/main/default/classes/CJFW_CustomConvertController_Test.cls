/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-03-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
@isTest
public with sharing class CJFW_CustomConvertController_Test {
        
    @isTest
    static void test1() {

        // String convertInfoStr = '{"Account":{"view":true,"create":true,"fields":{"Name":"한별유치뤙"},"convert": true}, "Contact":{"view":true, "create":true,"fields":{"Salutation":"","FirstName":"","LastName":"한별유치원"},"convertedId":null,"convert":true}, "Opportunity" :{"view" :true, "create":true,"fields":{"Name":"한별유치원"},"convertedId":null,"convert":true}}';        
        // Map<String, Object> cvtInfoMap = (Map<String, Object>)JSON.deserializeUntyped(convertInfoStr);
        // Map<String, Map<String,Object>> convertInfo = new Map<String, Map<String,Object>>();
        // for(String key : cvtInfoMap.keySet()) {
        //     Map<String, Object> info = (Map<String, Object>)cvtInfoMap.get(key);
        //     convertInfo.put(key, info);
        // }
        
        Map<Object,Object> fields = new Map<Object,Object>{'Name' => '한별', 'LastName' => '한별'};
        Map<String,Object> objInfos = new Map<String,Object>{
            'create'=> true,
            'fields'=> fields,
            'convert'=>true,
            'convertedId'=> ''
        };
        
        Map<String, Map<String,Object>> convertInfo = new Map<String, Map<String,Object>>();
        convertInfo.put('Account', objInfos);
        convertInfo.put('Contact', objInfos);
        convertInfo.put('Opportunity', objInfos);

        CJFW_BiddingInformation__c bi = new CJFW_BiddingInformation__c(
            Name = 'Test입찰공고'
        );
        insert bi;

        CJFW_PublicBiddingInformation__c pbi = new CJFW_PublicBiddingInformation__c(
            Name = 'Test공공데이터'
        );
        insert pbi;

        Test.startTest();
            CJFW_CustomConvertController.getConvertObj(bi.Id);
            CJFW_CustomConvertController.convert(convertInfo, bi.Id, userInfo.getUserId());
            CJFW_CustomConvertController.convert(convertInfo, pbi.Id, userInfo.getUserId());
        Test.stopTest();
    }
}