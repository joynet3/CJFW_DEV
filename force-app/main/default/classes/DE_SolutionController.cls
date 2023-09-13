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
    * A01 : 주방
    * A02 : 홀
    * A03 : 사무실
    * A04 : 비즈니스
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
    public static List<DE_CommonController.valuesWrapper> getServiceTags(String area, String function){
        List<DE_CommonController.valuesWrapper> result= new List<DE_CommonController.valuesWrapper>();
        List<ServiceTagMapping__c> serviceTags = new List<ServiceTagMapping__c>();
        Map<String, DE_CommonController.valuesWrapper> valuesWrapperMap = new Map<String, DE_CommonController.valuesWrapper>();

        try{
            String querySelect = 'SELECT ServiceTag__c'
                               + '       , ServiceTag__r.Name'
                               + '   FROM ServiceTagMapping__c';

            String queryWhere = ' WHERE ServiceTag__r.isActive__c = true';

            if(String.isNotBlank(area) && !area.equals('ALL')) queryWhere += ' AND Solution__r.AreaCategory__c includes (:area)';
            if(String.isNotBlank(function) && !function.equals('ALL')) queryWhere += ' AND Solution__r.FunctionCategory__c includes (:function)';

            String queryOrder = ' ORDER BY ServiceTag__r.Name';

            serviceTags = Database.query(querySelect + queryWhere + queryOrder);
        
            for(ServiceTagMapping__c obj : serviceTags){
                valuesWrapperMap.put(obj.ServiceTag__r.Name, new DE_CommonController.valuesWrapper(obj.ServiceTag__r.Name, obj.ServiceTag__c));
            }

            result = valuesWrapperMap.values();

        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    /**
    * 선택한 필터 값에 따른 솔루션 목록 가져오기
    *
    *@param  area : 공간 영역 값 / All 혹은 픽리스트 값
    *        function : 기능 영역 값 / All 혹은 픽리스트 값
    *        tags : 서비스 태그 값 / 서비스 태그 id 목록
    *        isAll : 전체 조회 or CJ프레시웨이만 조회
    *@return  List<FilterResultWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static FilterResultWrapper getFilterSolutions(String area, String function, List<String> tags, Boolean isAll, String orderBy, String siteDivision){
        FilterResultWrapper result = new FilterResultWrapper();
        List<SolutionWrapper> solutionWrappers = new List<SolutionWrapper>();
        List<ServiceTagMapping__c> serviceTagMappings = new List<ServiceTagMapping__c>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<String, String> thumbnailUrlMap = new Map<String, String>();
        Map<String, String> synopsisUrlMap = new Map<String, String>();
        Map<String, SolutionWrapper> SolutionWrapperMap = new Map<String, SolutionWrapper>();
        Set<String> setSolutionId = new Set<String>();
        Set<String> setTag = new Set<String>();

        try{

            if(tags != null && tags.size() > 0) setTag = new Set<String>(tags);

            String querySelect = 'SELECT Solution__c'
                               + '       , Solution__r.Name'
                               + '       , toLabel(Solution__r.FunctionCategory__c) FunctionCategoryLabel'
                               + '       , Solution__r.FunctionCategory__c'
                               + '       , Solution__r.ExternalURL__c'
                               + '   FROM ServiceTagMapping__c';

            String queryWhere = ' WHERE Name != null';

            if(String.isNotBlank(area) && !area.equals('ALL')) queryWhere += ' AND Solution__r.AreaCategory__c includes (:area)';
            if(String.isNotBlank(function) && !function.equals('ALL')) queryWhere += ' AND Solution__r.FunctionCategory__c includes (:function)';
            // if(setTag != null && setTag.size() > 0) 

            //23.09.07 파트너사 정보에 CJ프레시웨이 레코드 추가(필수 값 요청으로 인한 조치)
            if(!isAll) {
                String cjFreshwayId = [SELECT Id
                                        FROM PartnerCompany__c
                                        WHERE Name = 'CJ프레시웨이'
                                        LIMIT 1
                                        ].Id;
                queryWhere += ' AND Solution__r.PartnerCompany__c = :cjFreshwayId'; 
            }
            
            queryWhere += ' AND ServiceTag__c IN :setTag';
            queryWhere += ' AND (Solution__r.SiteDivision__c = \'common\''
                        + ' OR Solution__r.SiteDivision__c = :siteDivision)';

            String queryOrder = ' ORDER BY Solution__r.LastModifiedDate DESC';
            if(String.isNotBlank(orderBy)) {
                switch on orderBy {
                    when 'date'{
                        queryOrder = ' ORDER BY Solution__r.LastModifiedDate DESC';
                    }
                    when 'views'{
                        if(siteDivision.equals('school')) queryOrder = ' ORDER BY Solution__r.SchoolViews__c DESC';
                        else if(siteDivision.equals('food')) queryOrder = ' ORDER BY Solution__r.FoodViews__c DESC';
                    }
                    when 'alphabet'{
                        queryOrder = ' ORDER BY Solution__r.Name ASC';
                    }
                }
            }
            
            serviceTagMappings = Database.query(querySelect + queryWhere + queryOrder);

            for(ServiceTagMapping__c obj : serviceTagMappings){
                setSolutionId.add(obj.Solution__c);
            }
            //썸네일 url 가져오기
            contentDistributions = [SELECT Id
                                        , Name
                                        , RelatedRecordId
                                        , DistributionPublicUrl
                                        , ContentDownloadUrl
                                    FROM ContentDistribution
                                    WHERE RelatedRecordId IN :setSolutionId
                                    AND (Name LIKE 'thumbNail_%'
                                    OR Name LIKE 'synopsis_%')
                                    ORDER BY CreatedDate DESC
                                    ];

            for(ContentDistribution obj : contentDistributions){
                if(obj.Name.startsWith('thumbNail_')) thumbnailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
                if(obj.Name.startsWith('synopsis_')) synopsisUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
            }

            for(ServiceTagMapping__c obj : serviceTagMappings){
                if(thumbnailUrlMap.containsKey(obj.Solution__c)) SolutionWrapperMap.put(obj.Solution__c, new SolutionWrapper(obj, thumbnailUrlMap.get(obj.Solution__c)));
                else SolutionWrapperMap.put(obj.Solution__c, new SolutionWrapper(obj, synopsisUrlMap.get(obj.Solution__c)));
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
    * 솔루션 전체 목록 가져오기(내부, 파트너 솔루션만 구분)
    *
    *@param  area : 공간 영역 값
    *        function : 기능 영역 값
    *        tags : 서비스 태그 값
    *        division : cjfreshway/내부 솔루션, partner/파트너사 솔루션, 공백 시 전체
    *@return  List<FilterResultWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static FilterResultWrapper getSolutions(String division, String orderBy, String siteDivision){
        FilterResultWrapper result = new FilterResultWrapper();
        List<SolutionWrapper> solutionWrappers = new List<SolutionWrapper>();
        List<ServiceTagMapping__c> serviceTagMappings = new List<ServiceTagMapping__c>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<String, String> thumbnailUrlMap = new Map<String, String>();
        Map<String, String> synopsisUrlMap = new Map<String, String>();
        Map<String, SolutionWrapper> SolutionWrapperMap = new Map<String, SolutionWrapper>();
        Set<String> setSolutionId = new Set<String>();

        try{

            String querySelect = 'SELECT Solution__c'
                               + '       , Solution__r.Name'
                               + '       , toLabel(Solution__r.FunctionCategory__c) FunctionCategoryLabel'
                               + '       , Solution__r.FunctionCategory__c'
                               + '   FROM ServiceTagMapping__c';

            String queryWhere = ' WHERE Name != null';
            queryWhere += ' AND ServiceTag__r.isActive__c = true'; //사용하지 않는 서비스 태그에 대한 솔루션 조회x
            queryWhere += ' AND (Solution__r.SiteDivision__c = \'common\''
                        + ' OR Solution__r.SiteDivision__c = :siteDivision)';

            //23.09.07 파트너사 정보에 CJ프레시웨이 레코드 추가(필수 값 요청으로 인한 조치)
            if(division.equals('cjfreshway')) {
                String cjFreshwayId = [SELECT Id
                                        FROM PartnerCompany__c
                                        WHERE Name = 'CJ프레시웨이'
                                        LIMIT 1
                                        ].Id;
                queryWhere += ' AND Solution__r.PartnerCompany__c = :cjFreshwayId'; 
            }
            else if(division.equals('partner')) queryWhere += ' AND Solution__r.PartnerCompany__c != null'; //파트너사 매핑O : 파트너사 솔루션, 파트너사 매핑X : CJ프레시웨이 솔루션

            //정렬, 기본 값은 최신 날짜순, 값이 별도로 있을 경우 해당 값으로 정렬
            String queryOrder = ' ORDER BY Solution__r.LastModifiedDate DESC';
            if(String.isNotBlank(orderBy)) {
                switch on orderBy {
                    when 'date'{
                        queryOrder = ' ORDER BY Solution__r.LastModifiedDate DESC';
                    }
                    when 'views'{
                        if(siteDivision.equals('school')) queryOrder = ' ORDER BY Solution__r.SchoolViews__c DESC';
                        else if(siteDivision.equals('food')) queryOrder = ' ORDER BY Solution__r.FoodViews__c DESC';
                    }
                    when 'alphabet'{
                        queryOrder = ' ORDER BY Solution__r.Name ASC';
                    }
                }
            }
            
            serviceTagMappings = Database.query(querySelect + queryWhere + queryOrder);

            for(ServiceTagMapping__c obj : serviceTagMappings){
                setSolutionId.add(obj.Solution__c);
            }
            //썸네일 url 가져오기
            contentDistributions = [SELECT Id
                                        , Name
                                        , RelatedRecordId
                                        , DistributionPublicUrl
                                        , ContentDownloadUrl
                                    FROM ContentDistribution
                                    WHERE RelatedRecordId IN :setSolutionId
                                    AND (Name LIKE 'thumbNail_%'
                                    OR Name LIKE 'synopsis_%')
                                    ORDER BY CreatedDate DESC
                                    ];

            for(ContentDistribution obj : contentDistributions){
                if(obj.Name.startsWith('thumbNail_')) thumbnailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
                if(obj.Name.startsWith('synopsis_')) synopsisUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
            }

            for(ServiceTagMapping__c obj : serviceTagMappings){
                if(thumbnailUrlMap.containsKey(obj.Solution__c)) SolutionWrapperMap.put(obj.Solution__c, new SolutionWrapper(obj, thumbnailUrlMap.get(obj.Solution__c)));
                else SolutionWrapperMap.put(obj.Solution__c, new SolutionWrapper(obj, synopsisUrlMap.get(obj.Solution__c)));
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
    * 추천 솔루션 정보 가져오기
    *
    *@param  
    *@return  List<FilterResultWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<SolutionWrapper> getProperSolutions(String orderBy, String siteDivision){
        List<SolutionWrapper> result = new List<SolutionWrapper>();
        List<Solution__c> solutions = new List<Solution__c>();
        List<Solution__c> visibleSolutions = new List<Solution__c>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<String, String> thumbnailUrlMap = new Map<String, String>();
        Map<String, String> synopsisUrlMap = new Map<String, String>();
        Set<String> setSolutionId = new Set<String>();

        try{
            String querySelect = 'SELECT Id'
                               + '           , Name'
                               + '           , toLabel(FunctionCategory__c) FunctionCategory__c'
                               + '           , VisibleStartDatetime__c'
                               + '           , VisibleEndDatetime__c'
                               + '           , ExternalURL__c'
                               + '   FROM Solution__c';
            
            String queryWhere = ' WHERE isProper__c = true';
            queryWhere += ' AND (SiteDivision__c = \'common\''
                        + ' OR SiteDivision__c = :siteDivision)';

            //정렬, 기본 값은 최신 날짜순, 값이 별도로 있을 경우 해당 값으로 정렬
            String queryOrder = ' ORDER BY LastModifiedDate DESC';
            
            if(String.isNotBlank(orderBy)) {
                switch on orderBy {
                    when 'date'{
                        queryOrder = ' ORDER BY LastModifiedDate DESC';
                    }
                    when 'views'{
                        if(siteDivision.equals('school')) queryOrder = ' ORDER BY Solution__r.SchoolViews__c DESC';
                        else if(siteDivision.equals('food')) queryOrder = ' ORDER BY Solution__r.FoodViews__c DESC';
                    }
                    when 'alphabet'{
                        queryOrder = ' ORDER BY Name ASC';
                    }
                    //23.09.05 추천 솔루션의 경우 BO에서 순서를 결정할 수 있도록 변경 요청
                    when 'position'{
                        queryOrder = ' ORDER BY ProperPosition__c ASC';   
                    }
                }
            }

            solutions = Database.query(querySelect + queryWhere + queryOrder);

            //23.09.06 솔루션 노출 기간 요청으로 인한 추가
            for(Solution__c obj : solutions){
                //노출 기간(시작, 종료) 필드가 둘다 null일 경우 add
                if(obj.VisibleStartDatetime__c == null && obj.VisibleEndDatetime__c == null){
                    visibleSolutions.add(obj);
                }
                //노출 기간(시작) 필드만 있고 조건 충족 시 추가 
                else if(obj.VisibleStartDatetime__c != null && obj.VisibleEndDatetime__c == null){
                    if(obj.VisibleStartDatetime__c < System.now()) visibleSolutions.add(obj);
                }
                //노출 기간(종료) 필드만 있고 조건 충족 시 추가 
                else if(obj.VisibleStartDatetime__c == null && obj.VisibleEndDatetime__c != null){
                    if(obj.VisibleEndDatetime__c > System.now()) visibleSolutions.add(obj);
                }
                //노출 기간(시작, 종료) 둘다 있고 조건 충족 시 추가 
                else if(obj.VisibleStartDatetime__c != null && obj.VisibleEndDatetime__c != null){
                    if(obj.VisibleStartDatetime__c < System.now() && obj.VisibleEndDatetime__c > System.now()) visibleSolutions.add(obj);
                }
            }

            for(Solution__c obj : visibleSolutions){
                setSolutionId.add(obj.Id);
            }

            contentDistributions = [SELECT Id
                                        , Name
                                        , RelatedRecordId
                                        , ContentDownloadUrl
                                    FROM ContentDistribution
                                    WHERE RelatedRecordId IN :setSolutionId
                                    AND (Name LIKE 'thumbNail_%'
                                    OR Name LIKE 'synopsis_%')
                                    ORDER BY CreatedDate DESC
                                    ];

            for(ContentDistribution obj : contentDistributions){
                if(obj.Name.startsWith('thumbNail_')) thumbnailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
                if(obj.Name.startsWith('synopsis_')) synopsisUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
            }

            for(Solution__c obj : visibleSolutions){
                if(thumbnailUrlMap.containsKey(obj.Id)) result.add(new SolutionWrapper(obj, thumbnailUrlMap.get(obj.Id)));
                else result.add(new SolutionWrapper(obj, synopsisUrlMap.get(obj.Id)));
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
        Map<String, SolutionDetailWrapper> SolutionDetailWrapperMap = new Map<String, SolutionDetailWrapper>();
        List<ServiceTagMapping__c> serviceMappings = new List<ServiceTagMapping__c>();
        List<String> serviceTags = new List<String>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Set<String> setSolutionId = new Set<String>();
        Map<String, String> synopsisUrlMap = new Map<String, String>();
        Map<String, String> thumbNailUrlMap = new Map<String, String>();

        try{
            String query = 'SELECT Id'
                         + '         , Solution__c'
                         + '         , Solution__r.Name'
                         + '         , toLabel(Solution__r.FunctionCategory__c) FunctionCategoryLabel'
                         + '         , Solution__r.FunctionCategory__c'
                         + '         , Solution__r.Content__c'
                         + '         , ServiceTag__c'
                         + '         , ServiceTag__r.Name'
                         + '         , Solution__r.ServiceReport__c'
                         + '         , Solution__r.RelatedUrl__c'
                         + '         , Solution__r.ExternalURL__c'
                         + '         , toLabel(Solution__r.LocationStateProvince__c)'
                         + ' FROM ServiceTagMapping__c'
                         + ' WHERE Solution__c = :recordId';

            serviceMappings = Database.query(query);

            System.debug('serviceMappings : ' + JSON.serialize(serviceMappings));

            for(ServiceTagMapping__c obj : serviceMappings){
                serviceTags.add(obj.ServiceTag__r.Name);
                setSolutionId.add(obj.Solution__c);
            }

            contentDistributions = [SELECT Id
                                        , RelatedRecordId
                                        , ContentDownloadUrl
                                        , Name
                                    FROM ContentDistribution
                                    WHERE RelatedRecordId IN :setSolutionId
                                    AND (Name LIKE 'synopsis_%'
                                    OR Name LIKE 'thumbNail_%')
                                    ORDER BY CreatedDate DESC
                                    ];

            for(ContentDistribution obj : contentDistributions){
                if(obj.Name.startsWith('synopsis_'))synopsisUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
                if(obj.Name.startsWith('thumbNail_'))thumbNailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
            }

            for(ServiceTagMapping__c obj : serviceMappings){
                SolutionDetailWrapperMap.put(obj.Id, new SolutionDetailWrapper(obj, synopsisUrlMap.get(obj.Solution__c), thumbNailUrlMap.get(obj.Solution__c), serviceTags));
            }
            
            result = SolutionDetailWrapperMap.values();

        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    /**
    * 솔루션 상세 페이지로 이동 시 조회수 증가
    *
    *@param  recordId 레코드 아이디
    *@return  
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static void updateSolutionViews(String recordId, String siteDivision){
        try{
            Solution__c solution = [SELECT Id
                                            , SchoolViews__c
                                            , FoodViews__c
                                            FROM Solution__c
                                            WHERE Id = :recordId
                                            ];
        
            if(siteDivision.equals('food')) solution.FoodViews__c += 1;
            else if(siteDivision.equals('school')) solution.SchoolViews__c += 1;
            
            Update solution;
        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }
    }

    public class SolutionWrapper {
        @AuraEnabled public String label                    {get; set;} // 솔루션 명
        @AuraEnabled public String recordId                 {get; set;} // 솔루션 레코드 Id
        @AuraEnabled public String functionCategory         {get; set;} // 솔루션 기능 영역 값
        @AuraEnabled public String thumbnailUrl              {get; set;} // 썸네일 이미지 url
        @AuraEnabled public String          externalUrl               {get; set;} // 외부상담 페이지 URL
        
        public SolutionWrapper(){}             
        public SolutionWrapper(ServiceTagMapping__c obj, String imageUrl){
            this.label                = obj.Solution__r.Name;
            this.recordId             = obj.Solution__c;
            this.functionCategory     = obj.Solution__r.FunctionCategory__c;
            this.thumbnailUrl          = imageUrl;
            this.externalUrl           = obj.Solution__r.ExternalURL__c;
            
        }

        public SolutionWrapper(Solution__c obj, String imageUrl){
            this.label                = obj.Name;
            this.recordId             = obj.Id;
            this.functionCategory     = obj.FunctionCategory__c;
            this.thumbnailUrl          = imageUrl;
            this.externalUrl           = obj.ExternalURL__c;
        }
    }

    public class SolutionDetailWrapper {
        @AuraEnabled public String          label                    {get; set;} // 솔루션 명
        @AuraEnabled public String          recordId                 {get; set;} // 솔루션 레코드 Id
        @AuraEnabled public String          functionCategory         {get; set;} // 솔루션 기능 영역 값
        @AuraEnabled public String          synopsisUrl              {get; set;} // 요약 이미지 url
        @AuraEnabled public List<String>    serviceTags              {get; set;} // 서비스 태그 목록
        @AuraEnabled public String          ServiceReport            {get; set;} // 요약 설명
        @AuraEnabled public String          content                  {get; set;} // 상세 내용
        @AuraEnabled public String          relatedUrl               {get; set;} // 관련 정보 페이지 URL
        @AuraEnabled public String          externalUrl               {get; set;} // 외부상담 페이지 URL
        @AuraEnabled public String          location               {get; set;} // 서비스 가능 지역
        
        public SolutionDetailWrapper(){}             
        public SolutionDetailWrapper(ServiceTagMapping__c obj, String synopsisUrl, String thumbNailUrl, List<String> serviceTags){
            this.label                = obj.Solution__r.Name;
            this.recordId             = obj.Solution__c;
            this.functionCategory     = String.valueOf(obj.Solution__r.get('FunctionCategoryLabel'));
            this.synopsisUrl          = String.isNotBlank(synopsisUrl) ? synopsisUrl : thumbNailUrl;
            this.serviceTags          = serviceTags;
            this.content              = obj.Solution__r.Content__c;
            this.ServiceReport        = obj.Solution__r.ServiceReport__c;
            this.relatedUrl           = obj.Solution__r.RelatedUrl__c;
            this.externalUrl           = obj.Solution__r.ExternalURL__c;
            this.location           = obj.Solution__r.LocationStateProvince__c;
        }

        public SolutionDetailWrapper(Solution__c obj, String synopsisUrl, String thumbNailUrl, List<String> serviceTags){
            this.label                = obj.Name;
            this.recordId             = obj.Id;
            this.functionCategory     = String.valueOf(obj.get('FunctionCategoryLabel'));
            this.synopsisUrl          = String.isNotBlank(synopsisUrl) ? synopsisUrl : thumbNailUrl;
            this.serviceTags          = serviceTags;
            this.content              = obj.Content__c;
            this.ServiceReport        = obj.ServiceReport__c;
            this.relatedUrl           = obj.RelatedUrl__c;
            this.externalUrl           = obj.ExternalURL__c;
            this.location           = obj.LocationStateProvince__c;
        }
    }

    public class FilterResultWrapper {
        @AuraEnabled public Integer totalCnt{get;set;} //총 건수
        @AuraEnabled public List<SolutionWrapper> solutions{get;set;} // 솔루션 목록
        public FilterResultWrapper() {}
    }
}