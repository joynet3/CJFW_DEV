/**
* 솔루션 화면 컨트롤러
*
*@group  DE
*@author 조형준
*@since 2023-08-18  내용 작성
*/
public without sharing class DE_SolutionController {
    /**
    * 솔루션 공간 영역 카테고리 값 가져오기
    *
    *@param  
    *@return  List<valuesWrapper> List<label, value> 형태
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<DE_CommonController.valuesWrapper> getAreaCategory(){
        List<DE_CommonController.valuesWrapper> result= new List<DE_CommonController.valuesWrapper>();
        
        result.add(new DE_CommonController.valuesWrapper('모든 공간', 'ALL'));
        result.addAll(DE_CommonController.getPicklistValues('Solution__c', 'AreaCategory__c'));

        return result;
    }

    /**
    * 솔루션 공간 영역 카테고리 값 가져오기
    *
    *@param  
    *@return  List<valuesWrapper> List<label, value> 형태
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<DE_CommonController.valuesWrapper> getFunctionCategory(){
        List<DE_CommonController.valuesWrapper> result= new List<DE_CommonController.valuesWrapper>();
        
        result.add(new DE_CommonController.valuesWrapper('전체', 'ALL'));
        result.addAll(DE_CommonController.getPicklistValues('Solution__c', 'FunctionCategory__c'));

        return result;
    }

    /**
    * 서비스 태그 값 가져오기
    *
    *@param  
    *@return  List<DE_CommonController.valuesWrapper> List<label, value> 형태
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<DE_CommonController.valuesWrapper> getServiceTags(){
        List<DE_CommonController.valuesWrapper> result= new List<DE_CommonController.valuesWrapper>();
        List<ServiceTag__c> serviceTags = new List<ServiceTag__c>();

        try{
            serviceTags = [SELECT Id
                        , Name
                    FROM ServiceTag__c
                    WHERE isActive__c = true
                    ];
        
            for(ServiceTag__c obj : serviceTags){
                result.add(new DE_CommonController.valuesWrapper(obj.Name, obj.Id));
            }
        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    /**
    * 선택한 필터 값에 따른 솔루션 목록 가져오기
    *
    *@param  
    *@return  List<FilterResultWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static FilterResultWrapper getFilterSolutions(String area, String function, List<String> tags){
        FilterResultWrapper result = new FilterResultWrapper();
        List<SolutionWrapper> solutionWrappers = new List<SolutionWrapper>();
        List<ServiceTagMapping__c> serviceTagMappings = new List<ServiceTagMapping__c>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<String, String> thumbnailUrlMap = new Map<String, String>();
        Map<String, SolutionWrapper> SolutionWrapperMap = new Map<String, SolutionWrapper>();
        Set<String> setSolutionId = new Set<String>();
        Set<String> setTag = new Set<String>();

        try{

            if(tags != null && tags.size() > 0) setTag = new Set<String>(tags);

            String querySelect = 'SELECT Solution__c'
                               + '       , Solution__r.Name'
                               + '       , toLabel(Solution__r.FunctionCategory__c) FunctionCategory__c'
                               + '   FROM ServiceTagMapping__c';

            String queryWhere = ' WHERE Name != null';

            if(String.isNotBlank(area) && !area.equals('ALL')) queryWhere += ' AND Solution__r.AreaCategory__c = :area';
            if(String.isNotBlank(function) && !function.equals('ALL')) queryWhere += ' AND Solution__r.FunctionCategory__c = :function';
            if(setTag != null && setTag.size() > 0) queryWhere += ' AND ServiceTag__c IN :setTag';

            String queryOrder = ' ORDER BY Solution__r.CreatedDate DESC';
            
            serviceTagMappings = Database.query(querySelect + queryWhere + queryOrder);

            for(ServiceTagMapping__c obj : serviceTagMappings){
                setSolutionId.add(obj.Solution__c);
            }
            //썸네일 url 가져오기
            contentDistributions = [SELECT Id
                                        , RelatedRecordId
                                        , DistributionPublicUrl
                                        , ContentDownloadUrl
                                    FROM ContentDistribution
                                    WHERE RelatedRecordId IN :setSolutionId
                                    AND Name LIKE 'thumbNail_%'
                                    ];

            for(ContentDistribution obj : contentDistributions){
                thumbnailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
            }

            for(ServiceTagMapping__c obj : serviceTagMappings){
                SolutionWrapperMap.put(obj.Solution__c, new SolutionWrapper(obj, thumbnailUrlMap.get(obj.Solution__c)));
            }

            result.solutions = SolutionWrapperMap.values();
            result.totalCnt = solutionWrappers.size();

        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    /**
    * 내게 맞는 솔루션 정보 가져오기
    *
    *@param  
    *@return  List<FilterResultWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<SolutionWrapper> getProperSolutions(){
        List<SolutionWrapper> result = new List<SolutionWrapper>();
        List<Solution__c> Solutions = new List<Solution__c>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<String, String> thumbnailUrlMap = new Map<String, String>();
        Set<String> setSolutionId = new Set<String>();

        try{
            Solutions = [SELECT Id
                                , Name
                                , toLabel(FunctionCategory__c) FunctionCategory__c
                        FROM Solution__c
                        WHERE isProper__c = true
                        ORDER BY LastModifiedDate DESC
                        LIMIT 8
                        ];

            for(Solution__c obj : Solutions){
                setSolutionId.add(obj.Id);
            }

            contentDistributions = [SELECT Id
                                        , RelatedRecordId
                                        , ContentDownloadUrl
                                    FROM ContentDistribution
                                    WHERE RelatedRecordId IN :setSolutionId
                                    AND Name LIKE 'thumbNail_%'
                                    ];

            for(ContentDistribution obj : contentDistributions){
                thumbnailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
            }

            for(Solution__c obj : Solutions){
                result.add(new SolutionWrapper(obj, thumbnailUrlMap.get(obj.Id)));
            }
        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    /**
    * 솔루션 상세 정보 가져오기
    *
    *@param  
    *@return  List<SolutionDetailWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<SolutionDetailWrapper> getSolution(String recordId){
        List<SolutionDetailWrapper> result = new List<SolutionDetailWrapper>();
        List<ServiceTagMapping__c> serviceMappings = new List<ServiceTagMapping__c>();
        List<String> serviceTags = new List<String>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Set<String> setSolutionId = new Set<String>();
        Map<String, String> sysnposisUrlMap = new Map<String, String>();
        Map<String, String> detailUrlMap = new Map<String, String>();

        try{
            serviceMappings = [SELECT Id
                                        , Solution__c
                                        , Solution__r.Name
                                        , toLabel(Solution__r.FunctionCategory__c) FunctionCategory__c
                                        , Solution__r.Content__c
                                        , ServiceTag__c
                                        , ServiceTag__r.Name
                                        , Solution__r.ServiceReport__c
                                FROM ServiceTagMapping__c
                                WHERE Solution__c = :recordId
                                ];

            for(ServiceTagMapping__c obj : serviceMappings){
                serviceTags.add(obj.ServiceTag__r.Name);
                setSolutionId.add(obj.Solution__c);
            }

            contentDistributions = [SELECT Id
                                        , RelatedRecordId
                                        , ContentDownloadUrl
                                    FROM ContentDistribution
                                    WHERE RelatedRecordId IN :setSolutionId
                                    AND (Name LIKE 'synopsis_%'
                                    OR Name LIKE 'detail_%')
                                    ];

            for(ContentDistribution obj : contentDistributions){
                if(obj.Name.startsWith('thumbNail_'))sysnposisUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
                else if(obj.Name.startsWith('detail_'))detailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
            }

            for(ServiceTagMapping__c obj : serviceMappings){
                result.add(new SolutionDetailWrapper(obj, sysnposisUrlMap.get(obj.Solution__c), detailUrlMap.get(obj.Solution__c), serviceTags));
            }
            
        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    public class SolutionWrapper {
        @AuraEnabled public String label                    {get; set;} // 솔루션 명
        @AuraEnabled public String recordId                 {get; set;} // 솔루션 레코드 Id
        @AuraEnabled public String functionCategory         {get; set;} // 솔루션 기능 영역 값
        @AuraEnabled public String thumbnailUrl              {get; set;} // 썸네일 이미지 url
        
        public SolutionWrapper(){}             
        public SolutionWrapper(ServiceTagMapping__c obj, String imageUrl){
            this.label                = obj.Solution__r.Name;
            this.recordId             = obj.Solution__c;
            this.functionCategory     = obj.Solution__r.FunctionCategory__c;
            this.thumbnailUrl          = imageUrl;
        }

        public SolutionWrapper(Solution__c obj, String imageUrl){
            this.label                = obj.Name;
            this.recordId             = obj.Id;
            this.functionCategory     = obj.FunctionCategory__c;
            this.thumbnailUrl          = imageUrl;
        }
    }

    public class SolutionDetailWrapper {
        @AuraEnabled public String          label                    {get; set;} // 솔루션 명
        @AuraEnabled public String          recordId                 {get; set;} // 솔루션 레코드 Id
        @AuraEnabled public String          functionCategory         {get; set;} // 솔루션 기능 영역 값
        @AuraEnabled public String          synopsisUrl              {get; set;} // 요약 이미지 url
        @AuraEnabled public String          detailUrl                {get; set;} // 상세 이미지 url
        @AuraEnabled public List<String>    serviceTags              {get; set;} // 서비스 태그 목록
        @AuraEnabled public String          content                  {get; set;} // 상세 내용
        
        public SolutionDetailWrapper(){}             
        public SolutionDetailWrapper(ServiceTagMapping__c obj, String synopsisUrl, String detailUrl, List<String> serviceTags){
            this.label                = obj.Solution__r.Name;
            this.recordId             = obj.Solution__c;
            this.functionCategory     = obj.Solution__r.FunctionCategory__c;
            this.synopsisUrl          = synopsisUrl;
            this.detailUrl            = detailUrl;
            this.serviceTags          = serviceTags;
            this.content              = obj.Solution__r.ServiceReport__c;
        }

        public SolutionDetailWrapper(Solution__c obj, String synopsisUrl, String detailUrl, List<String> serviceTags){
            this.label                = obj.Name;
            this.recordId             = obj.Id;
            this.functionCategory     = obj.FunctionCategory__c;
            this.synopsisUrl          = synopsisUrl;
            this.detailUrl            = detailUrl;
            this.serviceTags          = serviceTags;
            this.content              = obj.ServiceReport__c;
        }
    }

    public class FilterResultWrapper {
        @AuraEnabled public Integer totalCnt{get;set;} //총 건수
        @AuraEnabled public List<SolutionWrapper> solutions{get;set;} // 솔루션 목록
        public FilterResultWrapper() {}
    }
}