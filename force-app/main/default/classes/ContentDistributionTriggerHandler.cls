/**
* ContentDistributionTriggerHandler
*
*@group  file
*@author 조형준
*@since 2023-08-14  최초작성
*/
public without sharing class ContentDistributionTriggerHandler extends TriggerHandler{
    @testVisible private List<ContentDistribution> news; 
    @testVisible private List<ContentDistribution> olds; 
    @testVisible private Map<Id, ContentDistribution> oldMap; 
    @testVisible private Map<Id, ContentDistribution> newMap;
    @testVisible private static Map<String, Schema.RecordTypeInfo> recordTypeMap;

    
    public ContentDistributionTriggerHandler() {
        news = (List<ContentDistribution>) Trigger.new;
        olds = (List<ContentDistribution>) Trigger.old;
        newMap  = (Map<Id,ContentDistribution>) Trigger.newMap;
        oldMap  = (Map<Id,ContentDistribution>) Trigger.oldMap;
    }

    public override void beforeInsert() {        
    }

    public override void afterInsert() {       
        createContentDistribution(newMap);
    }

    /**
    * 상품안내 pdf파일 생성 시 public url 세팅
    *
    *@param  news 신규 생성 레코드
    *@return  
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    private void createContentDistribution(Map<Id, ContentDistribution> newMap){
        Map<String, ContentDistribution> relatedRecordMap = new Map<String, ContentDistribution>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        List<Brochure__c> brochures = new List<Brochure__c>();

        //DistributionPublicUrl 값을 위한 재쿼리
        contentDistributions = [SELECT Id
                                        , DistributionPublicUrl
                                        , Name
                                        , RelatedRecordId
                                FROM ContentDistribution 
                                WHERE Id IN :newMap.keySet()];

        //상품안내에 대한 파일 등록, pdf인 경우에만 처리
        for(ContentDistribution obj : contentDistributions){
            System.debug(obj.RelatedRecordId.getSObjectType().getDescribe().getName());
            System.debug(obj.Name);
            if(obj.RelatedRecordId.getSObjectType().getDescribe().getName().equals('Brochure__c')
            && obj.Name.endsWith('.pdf')) {
                relatedRecordMap.put(obj.RelatedRecordId, obj);
            }
        }

        brochures = [SELECT Id 
                        FROM Brochure__c 
                        WHERE Id IN :relatedRecordMap.keySet()
                        ];
                        
        if(brochures.size() > 0){
            for(Brochure__c obj : brochures){
                System.debug(relatedRecordMap.get(obj.Id).DistributionPublicUrl);
                obj.pdfUrl__c = relatedRecordMap.containsKey(obj.Id) ? relatedRecordMap.get(obj.Id).DistributionPublicUrl : null;
            }
        }

        Update brochures;
    }
}