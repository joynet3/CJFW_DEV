/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-15-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class NaverMapController {

    // public String sido {get;set;}
    // public String name {get;set;}

    public string lexOrigin {get{ 
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
        } set;}

    public NaverMapController() {
        // name = 'test';
    }

    // public void show(){
    //     this.name = '22';
    // }

    // public List<SelectOption> getSidoval() {
    //     List<SelectOption> options = new List<SelectOption>();
    //     options.add(new SelectOption('US','US'));
    //     options.add(new SelectOption('CANADA','Canada'));
    //     options.add(new SelectOption('MEXICO','Mexico'));
    //     return options;
    // }

    @AuraEnabled(cacheable=true)
    public static String getVFOrigin() {
        String vfOrigin = '';
        String baseURL = URL.getOrgDomainUrl().toExternalForm(); // Expected Format = https://domain.my.salesforce.com
        // Expected Format for DE, Sandbox & Production ORgs = https://domain--c.vf.force.com
        if(baseURL.contains('sandbox')){
            vfOrigin = baseURL.split('.sandbox.')[0] + '--c.' + 'sandbox.vf.force.com';
        } else {
            vfOrigin = baseURL.split('.my.')[0] + '--c.' + 'vf.force.com';
        }
        
        return vfOrigin;
    }

    @AuraEnabled
    public static Map<String, Object> getInitInfo(String recordId) {
        Map<String,Object> resultMap = new  Map<String,Object>();

        CJFW_PublicBiddingInformation__c center = [SELECT Id, RecordType.Name, Name
                                                        , AddressDetails__c
                                                        , Address__c
                                                        , Location__Latitude__s
                                                        , Location__Longitude__s
                                                        , City__c
                                                        , State__c
                                                        , Account__r.RecordType.Name
                                                        , Account__c
                                                        , Phone__c
                                                        , Homepage__c
                                                        , CreatedDate
                                                    FROM CJFW_PublicBiddingInformation__c 
                                                    WHERE Id = :recordId];
        resultMap.put('center', center);

        String state = center.State__c;
        String city = center.City__c;

        List<AggregateResult> countList = [SELECT COUNT(Id) cnt, RecordType.Name
                                                FROM CJFW_PublicBiddingInformation__c 
                                                WHERE State__c = :state AND City__c = :city 
                                                    AND (RecordType.Name = 'ChildCenter' OR RecordType.Name = 'Kindergarten') 
                                                GROUP BY RecordType.Name, State__c, City__c ];

        List<AggregateResult> exCountList = [SELECT COUNT(Id) cnt, RecordType.Name
                                                FROM CJFW_PublicBiddingInformation__c 
                                                WHERE State__c = :state AND City__c = :city 
                                                    AND (RecordType.Name = 'ChildCenter' OR RecordType.Name = 'Kindergarten') 
                                                    AND Account__r.RecordType.Name LIKE 'Existing Customer%'
                                                GROUP BY RecordType.Name, State__c, City__c ];

        Map<Object, Object> totalCntMap = new Map<Object, Object>();
        for (AggregateResult rs : countList) {
            totalCntMap.put(rs.get('Name'), rs.get('cnt'));
        }
        resultMap.put('totalCntMap', totalCntMap);

        Map<Object, Object> exCntMap = new Map<Object, Object>();
        for (AggregateResult rs : exCountList) {
            totalCntMap.put(rs.get('Name'), rs.get('cnt'));
        }
        resultMap.put('exCntMap', exCntMap);

        List<CJFW_PublicBiddingInformation__c> searchList = [SELECT Id, RecordType.Name, Name
                                                                , AddressDetails__c
                                                                , Address__c
                                                                , Location__Latitude__s
                                                                , Location__Longitude__s
                                                                , City__c
                                                                , State__c
                                                                , Account__r.RecordType.Name
                                                                , Account__c
                                                                , Phone__c
                                                                , Homepage__c
                                                                , CreatedDate
                                                            FROM CJFW_PublicBiddingInformation__c 
                                                            WHERE State__c = :state AND City__c = :city 
                                                                AND (RecordType.Name = 'ChildCenter' OR RecordType.Name = 'Kindergarten') 
                                                                AND Id != :recordId
                                                            ];
        resultMap.put('searchList', searchList);
        return resultMap;
    }

    
    @AuraEnabled
    public static Map<String, Object> search(String state, String city) {
        Map<String,Object> resultMap = new  Map<String,Object>();
        
        List<AggregateResult> countList = [SELECT COUNT(Id) cnt, RecordType.Name
                                                FROM CJFW_PublicBiddingInformation__c 
                                                WHERE State__c = :state AND City__c = :city 
                                                    AND (RecordType.Name = 'ChildCenter' OR RecordType.Name = 'Kindergarten') 
                                                GROUP BY RecordType.Name, State__c, City__c ];

        List<AggregateResult> exCountList = [SELECT COUNT(Id) cnt, RecordType.Name
                                                FROM CJFW_PublicBiddingInformation__c 
                                                WHERE State__c = :state AND City__c = :city 
                                                    AND (RecordType.Name = 'ChildCenter' OR RecordType.Name = 'Kindergarten') 
                                                    AND Account__r.RecordType.Name LIKE 'Existing Customer%'
                                                GROUP BY RecordType.Name, State__c, City__c ];

        Map<Object, Object> totalCntMap = new Map<Object, Object>();
        for (AggregateResult rs : countList) {
            totalCntMap.put(rs.get('Name'), rs.get('cnt'));
        }
        resultMap.put('totalCntMap', totalCntMap);

        Map<Object, Object> exCntMap = new Map<Object, Object>();
        for (AggregateResult rs : exCountList) {
            totalCntMap.put(rs.get('Name'), rs.get('cnt'));
        }
        resultMap.put('exCntMap', exCntMap);

        List<CJFW_PublicBiddingInformation__c> searchList = [SELECT Id, RecordType.Name, Name
                                                                , AddressDetails__c
                                                                , Address__c
                                                                , Location__Latitude__s
                                                                , Location__Longitude__s
                                                                , City__c
                                                                , State__c
                                                                , Account__r.RecordType.Name
                                                                , Account__c
                                                                , Phone__c
                                                                , Homepage__c
                                                                , CreatedDate
                                                            FROM CJFW_PublicBiddingInformation__c 
                                                            WHERE State__c = :state AND City__c = :city 
                                                                AND (RecordType.Name = 'ChildCenter' OR RecordType.Name = 'Kindergarten') 
                                                            ];
        
        resultMap.put('searchList', searchList);
        return resultMap;
    }

}