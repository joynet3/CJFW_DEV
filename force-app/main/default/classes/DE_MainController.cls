/**
* 커뮤니티 메인 기능 컨트롤러
*
*@group  DE
*@author 조형준
*@since 2023-08-18  내용 작성
*/
public without sharing class DE_MainController {

    /**
    * 카테고리 url에 해당하는 게시글 정보 가져오기(메인화면용)
    * 23.09.08 메인 커뮤니티 노출 게시물에 대한 선택과 기간 설정 요구로 인하여 기능 추가
    *
    *@param  categoryURL 커뮤니티 페이지 url ex) /success-story
    *@return  List<boardWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static DE_CommunityBoardController.FilterResultWrapper getMainBoards(String categoryURL){
        DE_CommunityBoardController.FilterResultWrapper result= new DE_CommunityBoardController.FilterResultWrapper();
        List<DE_CommunityBoardController.boardWrapper> boards= new List<DE_CommunityBoardController.boardWrapper>();
        List<List<SObject>> searchs = new List<List<SObject>>();
        List<CommunityBoard__c> communityBoards = new List<CommunityBoard__c>();
        List<CommunityBoard__c> communityVisibleBoards = new List<CommunityBoard__c>();
        Set<String> setCommunityBoardId = new Set<String>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<String, String> thumbnailUrlMap = new Map<String, String>();

        try {
            CommunityGroupDetail__c communityGroupDetail = [SELECT Id
                                                            FROM CommunityGroupDetail__c
                                                            WHERE CommunityURL__c =: categoryURL
                                                            ];

            String querySelect = 'SELECT Id'
                                +  '    , Name'
                                +  '    , Content__c'
                                +  '    , Views__c'
                                +  '    , CreatedDate'
                                +  '    , CommunityGroupDetail__r.CommunityURL__c'
                                +  '    , VisibleStartDatetime__c'
                                +  '    , VisibleEndDatetime__c'
                                +  ' FROM CommunityBoard__c';
            String queryWhere = ' WHERE CommunityGroupDetail__c = \'' + communityGroupDetail.Id + '\''
                              + ' AND isMainVisible__c = true';
            String queryOrder = ' ORDER BY CreatedDate DESC';

            communityBoards = Database.query(querySelect + queryWhere + queryOrder);

            if(communityBoards.size() > 0){
                for(CommunityBoard__c obj : communityBoards){
                    //노출 기간(시작, 종료) 필드가 둘다 null일 경우 add
                    if(obj.VisibleStartDatetime__c == null && obj.VisibleEndDatetime__c == null){
                        communityVisibleBoards.add(obj);
                    }
                    //노출 기간(시작) 필드만 있고 조건 충족 시 추가 
                    else if(obj.VisibleStartDatetime__c != null && obj.VisibleEndDatetime__c == null){
                        if(obj.VisibleStartDatetime__c < System.now()) communityVisibleBoards.add(obj);
                    }
                    //노출 기간(종료) 필드만 있고 조건 충족 시 추가 
                    else if(obj.VisibleStartDatetime__c == null && obj.VisibleEndDatetime__c != null){
                        if(obj.VisibleEndDatetime__c > System.now()) communityVisibleBoards.add(obj);
                    }
                    //노출 기간(시작, 종료) 둘다 있고 조건 충족 시 추가 
                    else if(obj.VisibleStartDatetime__c != null && obj.VisibleEndDatetime__c != null){
                        if(obj.VisibleStartDatetime__c < System.now() && obj.VisibleEndDatetime__c > System.now()) communityVisibleBoards.add(obj);
                    }
                }

                if(communityVisibleBoards.size() > 0){
                    for(CommunityBoard__c obj : communityVisibleBoards){
                        setCommunityBoardId.add(obj.id);
                    }
    
                    //썸네일 url 가져오기
                    contentDistributions = [SELECT Id
                                                    , RelatedRecordId
                                                    , ContentDownloadUrl
                                                FROM ContentDistribution
                                                WHERE RelatedRecordId IN :setCommunityBoardId
                                                AND Name LIKE 'thumbnail_%'
                                                ORDER BY CreatedDate DESC
                                                ];
    
                    for(ContentDistribution obj : contentDistributions){
                        thumbnailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
                    }
    
                    for(CommunityBoard__c obj : communityVisibleBoards){
                        boards.add(new DE_CommunityBoardController.boardWrapper(obj, thumbnailUrlMap.get(obj.Id)));
                    }
    
                    result.boards = boards;
                    result.totalCnt = boards.size();
                }
            }

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }
    /**
    * 배너 영역에 들어갈 서비스 태그 정보
    *
    *@param  
    *@return  리턴값 설명 (있는경우)
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static Map<String, List<DE_CommonController.valuesWrapper>> getBannerServiceTags(){
        Map<String, List<DE_CommonController.valuesWrapper>> result = new Map<String, List<DE_CommonController.valuesWrapper>>();
        List<DE_CommonController.valuesWrapper> areaCategories = DE_CommonController.getPicklistValues('Solution__c', 'AreaCategory__c');//영역 값 조회

        for(DE_CommonController.valuesWrapper obj1 : areaCategories){
            List<DE_CommonController.valuesWrapper> serviceTags = new List<DE_CommonController.valuesWrapper>();
            List<DE_CommonController.valuesWrapper> temps = new List<DE_CommonController.valuesWrapper>();

            //영역 필터 값에 해당하는 서비스 태그 값 조회
            serviceTags = DE_SolutionController.getServiceTags(obj1.value, '');

            //배너에 표시할 태그 값은 최대 6개까지만.
            Integer i = 0;
            for(DE_CommonController.valuesWrapper obj2 : serviceTags){
                if(i > 5) continue;

                temps.add(obj2);
                i++;
            }

            result.put(obj1.label, temps);
        }

        return result;
    }

    @AuraEnabled
    public static globalSearchWrapper getGlobalSearch(String SearchText){
        //Wrapper
        globalSearchWrapper result = new globalSearchWrapper();
        DE_SolutionController.FilterResultWrapper cjSolutionsFilterWrapper = new DE_SolutionController.FilterResultWrapper();
        DE_SolutionController.FilterResultWrapper bizSolutionsFilterWrapper = new DE_SolutionController.FilterResultWrapper();
        DE_CommunityBoardController.FilterResultWrapper boardsFilterWrapper = new DE_CommunityBoardController.FilterResultWrapper();
        List<DE_SolutionController.SolutionWrapper> cjSolutionsWrapper = new List<DE_SolutionController.SolutionWrapper>();
        List<DE_SolutionController.SolutionWrapper> bizSolutionsWrapper = new List<DE_SolutionController.SolutionWrapper>();
        List<DE_CommunityBoardController.boardWrapper> boardsWrapper= new List<DE_CommunityBoardController.boardWrapper>();
        //Objects
        List<List<SObject>> searchs = new List<List<SObject>>();
        List<Solution__c> solutions = new List<Solution__c>();
        List<CommunityBoard__c> boards = new List<CommunityBoard__c>();

        //썸네일
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<String, String> thumbnailUrlMap = new Map<String, String>();
        Set<String> setSolutionId = new Set<String>();

        try {
            if(String.isNotBlank(SearchText)){
                searchs = [FIND :SearchText IN ALL FIELDS
                            RETURNING Solution__c(Id, Name, FunctionCategory__c, PartnerCompany__c//+ imageUrl
                                                ORDER BY CreatedDate DESC)
                            , CommunityBoard__c(Id, Name, Content__c, Views__c, CreatedDate, CommunityGroupDetail__r.communityURL__c
                                                ORDER BY CreatedDate DESC)
                            ];
            }

            if(searchs[0].size() > 0) solutions = (List<Solution__c>)searchs[0];
            if(searchs[1].size() > 0) boards = (List<CommunityBoard__c>)searchs[1];

            //Biz솔루션, CJ솔루션 가져오기
            if(solutions != null && solutions.size() > 0){
                for(Solution__c obj : solutions){
                    setSolutionId.add(obj.Id);
                }

                //썸네일 url 가져오기
                contentDistributions = [SELECT Id
                                            , RelatedRecordId
                                            , DistributionPublicUrl
                                            , ContentDownloadUrl
                                        FROM ContentDistribution
                                        WHERE RelatedRecordId IN :setSolutionId
                                        AND Name LIKE 'thumbNail_%'
                                        ORDER BY CreatedDate DESC
                                        ];

                for(ContentDistribution obj : contentDistributions){
                    thumbnailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
                }

                for(Solution__c obj : solutions){
                    //파트너사 존재하면 Biz솔루션, 없으면 CJ솔루션
                    if(String.isBlank(obj.PartnerCompany__c)){
                        cjSolutionsWrapper.add(new DE_SolutionController.SolutionWrapper(obj, thumbnailUrlMap.get(obj.Id)));
                    }else{
                        bizSolutionsWrapper.add(new DE_SolutionController.SolutionWrapper(obj, thumbnailUrlMap.get(obj.Id)));
                    }
                }

                cjSolutionsFilterWrapper.totalCnt = cjSolutionsWrapper.size();
                cjSolutionsFilterWrapper.solutions = cjSolutionsWrapper;
                bizSolutionsFilterWrapper.totalCnt = bizSolutionsWrapper.size();
                bizSolutionsFilterWrapper.solutions = bizSolutionsWrapper;
            }

            //커뮤니티 게시글 가져오기/썸네일x
            if(boards != null && boards.size() > 0){
                for(CommunityBoard__c obj : boards){
                    boardsWrapper.add(new DE_CommunityBoardController.boardWrapper(obj));
                }

                boardsFilterWrapper.boards = boardsWrapper;
                boardsFilterWrapper.totalCnt = boards.size();
            }

            result.cjSolutions = cjSolutionsFilterWrapper;
            result.bizSolutions = bizSolutionsFilterWrapper;
            result.boards = boardsFilterWrapper;
            result.totalCnt = 0;
            if(cjSolutionsFilterWrapper.totalCnt != null) result.totalCnt += cjSolutionsFilterWrapper.totalCnt;
            if(bizSolutionsFilterWrapper.totalCnt != null) result.totalCnt += bizSolutionsFilterWrapper.totalCnt + boardsFilterWrapper.totalCnt;
            if(boardsFilterWrapper.totalCnt != null) result.totalCnt += boardsFilterWrapper.totalCnt;

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    /**
    * Biz 포탈 메뉴 정보 가져오기
    *
    *@group DE
    *@author 조형준
    *@since 2023-08-28  내용 작성
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<MenuItemWrapper>> getMenuItems(String siteDivision) {
        Map<String, List<MenuItemWrapper>> result = new Map<String, List<MenuItemWrapper>>();
        Map<String, List<MenuItemWrapper>> communityGroupDetailMap = new Map<String, List<MenuItemWrapper>>();
        List<MenuItemWrapper> menuItemWrappers = new List<MenuItemWrapper>();
        List<SolutionGroup__c> solutionGroups = new List<SolutionGroup__c>();
        List<BrochureGroup__c> brochureGroups = new List<BrochureGroup__c>();
        List<CommunityGroup__c> communityGroups = new List<CommunityGroup__c>();
        List<CommunityGroupDetail__c> communityGroupDetails = new List<CommunityGroupDetail__c>();
        List<InqueryGroup__c> inqueryGroups = new List<InqueryGroup__c>();

        try{
            //솔루션 메뉴
            solutionGroups = [SELECT Id
                                    , Name
                                    , Position__c
                                    , CommunityURL__c
                                FROM SolutionGroup__c
                                WHERE isActive__c = true
                                AND (SiteDivision__c = 'common'
                                OR SiteDivision__c = :siteDivision)
                                ORDER BY Position__c
                                ];
            for(SolutionGroup__c obj : solutionGroups){
                List<MenuItemWrapper> tempList = new List<MenuItemWrapper>();
                
                if(result.containsKey('BIZ 솔루션')) tempList = result.get('BIZ 솔루션');
                tempList.add(new menuItemWrapper(obj));

                result.put('BIZ 솔루션', tempList);
            }

            //상품안내 메뉴
            brochureGroups = [SELECT Id
                                    , Name
                                    , Position__c
                                    , CommunityURL__c
                                FROM BrochureGroup__c
                                WHERE isActive__c = true
                                AND (SiteDivision__c = 'common'
                                OR SiteDivision__c = :siteDivision)
                                ORDER BY Position__c
                                ];
            for(BrochureGroup__c obj : brochureGroups){
                List<MenuItemWrapper> tempList = new List<MenuItemWrapper>();
                
                if(result.containsKey('상품안내')) tempList = result.get('상품안내');
                tempList.add(new menuItemWrapper(obj));

                result.put('상품안내', tempList);
            }

            //커뮤니티 소메뉴
            communityGroupDetails = [SELECT Id
                                    , Name
                                    , Position__c
                                    , CommunityURL__c
                                    , CommunityGroup__c
                                FROM CommunityGroupDetail__c
                                WHERE isActive__c = true
                                AND (SiteDivision__c = 'common'
                                OR SiteDivision__c = :siteDivision)
                                ORDER BY Position__c
                                ];
            for(CommunityGroupDetail__c obj : communityGroupDetails){
                List<MenuItemWrapper> tempList = new List<MenuItemWrapper>();
                
                if(communityGroupDetailMap.containsKey(obj.CommunityGroup__c)) tempList = communityGroupDetailMap.get(obj.CommunityGroup__c);
                tempList.add(new menuItemWrapper(obj));

                communityGroupDetailMap.put(obj.CommunityGroup__c, tempList);
            }

            //커뮤니티 중메뉴
            communityGroups = [SELECT Id
                                    , Name
                                    , Position__c
                                    , CommunityURL__c
                                FROM CommunityGroup__c
                                WHERE isActive__c = true
                                AND (SiteDivision__c = 'common'
                                OR SiteDivision__c = :siteDivision)
                                ORDER BY Position__c
                                ];
            for(CommunityGroup__c obj : communityGroups){
                List<MenuItemWrapper> tempList = new List<MenuItemWrapper>();
                
                if(result.containsKey('커뮤니티')) tempList = result.get('커뮤니티');
                tempList.add(new menuItemWrapper(obj, communityGroupDetailMap.get(obj.Id)));

                result.put('커뮤니티', tempList);
            }

            //상담신청 메뉴
            inqueryGroups = [SELECT Id
                                    , Name
                                    , Position__c
                                    , CommunityURL__c
                                FROM InqueryGroup__c
                                WHERE isActive__c = true
                                AND (SiteDivision__c = 'common'
                                OR SiteDivision__c = :siteDivision)
                                ORDER BY Position__c
                                ];
            for(InqueryGroup__c obj : inqueryGroups){
                List<MenuItemWrapper> tempList = new List<MenuItemWrapper>();
                
                if(result.containsKey('상담신청')) tempList = result.get('상담신청');
                tempList.add(new menuItemWrapper(obj));

                result.put('상담신청', tempList);
            }

        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    public class valuesWrapper{
        @AuraEnabled public String label    {get;set;}
        @AuraEnabled public String value    {get;set;}

        public valuesWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    public class globalSearchWrapper{
        @AuraEnabled public DE_SolutionController.FilterResultWrapper       cjSolutions   {get;set;}
        @AuraEnabled public DE_SolutionController.FilterResultWrapper       bizSolutions  {get;set;}
        @AuraEnabled public DE_CommunityBoardController.FilterResultWrapper boards        {get;set;}
        @AuraEnabled public Integer totalCnt                                              {get;set;}
    }

    public class MenuItemWrapper{
        @AuraEnabled public String Id {get;set;}                            //레코드 아이디
        @AuraEnabled public String Label {get;set;}                         //메뉴명
        @AuraEnabled public Decimal Position {get;set;}                     //메뉴 순서
        @AuraEnabled public String pageUrl {get;set;}                       //페이지 URL
        @AuraEnabled public List<MenuItemWrapper> subMenuItem {get;set;}    //하위 메뉴 목록

        public MenuItemWrapper() {}
        //솔루션
        public MenuItemWrapper(SolutionGroup__c obj) {
            this.Id                 = obj.Id;
            this.Label              = obj.Name;
            this.Position           = obj.Position__c;
            this.pageUrl            = obj.CommunityURL__c;
        }

        // public MenuItemWrapper(SolutionGroup__c obj, List<MenuItemWrapper> subMenuItem) {
        //     this.Id                 = obj.Id;
        //     this.Label              = obj.Name;
        //     this.Position           = obj.Position__c;
        //     this.pageUrl            = obj.CommunityURL__c;
        //     this.subMenuItem        = subMenuItem;
        // }
        //상품안내
        public MenuItemWrapper(BrochureGroup__c obj) {
            this.Id                 = obj.Id;
            this.Label              = obj.Name;
            this.Position           = obj.Position__c;
            this.pageUrl            = obj.CommunityURL__c;
        }

        // public MenuItemWrapper(BrochureGroup__c obj, List<MenuItemWrapper> subMenuItem) {
        //     this.Id                 = obj.Id;
        //     this.Label              = obj.Name;
        //     this.Position           = obj.Position__c;
        //     this.pageUrl            = obj.CommunityURL__c;
        //     this.subMenuItem        = subMenuItem;
        // }
        //커뮤니티 중
        public MenuItemWrapper(CommunityGroup__c obj) {
            this.Id                 = obj.Id;
            this.Label              = obj.Name;
            this.Position           = obj.Position__c;
            this.pageUrl            = obj.CommunityURL__c;
        }

        public MenuItemWrapper(CommunityGroup__c obj, List<MenuItemWrapper> subMenuItem) {
            this.Id                 = obj.Id;
            this.Label              = obj.Name;
            this.Position           = obj.Position__c;
            this.pageUrl            = obj.CommunityURL__c;
            this.subMenuItem        = subMenuItem;
        }
        //커뮤니티 소
        public MenuItemWrapper(CommunityGroupDetail__c obj) {
            this.Id                 = obj.Id;
            this.Label              = obj.Name;
            this.Position           = obj.Position__c;
            this.pageUrl            = obj.CommunityURL__c;
        }

        // public MenuItemWrapper(CommunityGroupDetail__c obj, List<MenuItemWrapper> subMenuItem) {
        //     this.Id                 = obj.Id;
        //     this.Label              = obj.Name;
        //     this.Position           = obj.Position__c;
        //     this.pageUrl            = obj.CommunityURL__c;
        //     this.subMenuItem        = subMenuItem;
        // }
        //상담신청
        public MenuItemWrapper(InqueryGroup__c obj) {
            this.Id                 = obj.Id;
            this.Label              = obj.Name;
            this.Position           = obj.Position__c;
            this.pageUrl            = obj.CommunityURL__c;
        }

        // public MenuItemWrapper(InqueryGroup__c obj, List<MenuItemWrapper> subMenuItem) {
        //     this.Id                 = obj.Id;
        //     this.Label              = obj.Name;
        //     this.Position           = obj.Position__c;
        //     this.pageUrl            = obj.CommunityURL__c;
        //     this.subMenuItem        = subMenuItem;
        // }
    }
}