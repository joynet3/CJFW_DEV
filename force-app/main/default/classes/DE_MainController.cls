/**
* 커뮤니티 메인 기능 컨트롤러
*
*@group  DE
*@author 조형준
*@since 2023-08-18  내용 작성
*/
public without sharing class DE_MainController {

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
                            , CommunityBoard__c(Id, Name, Views__c, CreatedDate, CommunityGroupDetail__r.communityURL__c
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

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItemWrapper> getNavigationLabelItems(
        String menuName,
        String publishedState
    ) {
        List<NavigationMenuItemWrapper> result = new List<NavigationMenuItemWrapper>();
        if (String.isEmpty(menuName)) {
            return result;
        }

        // String networkId = Network.getNetworkId();

        // testCoverage
        // if (Test.isRunningTest()) {
        //     networkId = [SELECT Id FROM Network ORDER BY CreatedDate LIMIT 1].Id;
        // }
        
        // find the link set belonging to the navigation menuName and active networkId
        List<NavigationLinkSet> linkSets = [
            SELECT Id
            FROM NavigationLinkSet
            WHERE MasterLabel = :menuName 
            // AND NetworkId = :networkId
        ];
        System.debug('linkSets : ' + linkSets);
        
        Id linkSetId = linkSets.get(0).Id;
        // collect all the menu items belonging to the link set
        // published state is either Draft or Live

        List<NavigationMenuItem> navigationMenuItemList = [SELECT Id
            , toLabel(Label) menuitemlabel
            , Label
            , Target
            , Type
            , DefaultListViewId
            , AccessRestriction
            , ParentId
            , Position
            , Status
            , TargetPrefs
        FROM NavigationMenuItem
        WHERE NavigationLinkSetId = :linkSetId AND Status = :publishedState
        ORDER BY Position];

        System.debug('navigationMenuItemList : ' + navigationMenuItemList);

        // Guest User 제외되는 메뉴 대상
        // List<String> exceptionMenuItemOfGuestUser = new List<String>{
        //     'SN_Complaint_Claim'
        // };
        for (NavigationMenuItem obj : navigationMenuItemList) {
            // 「Complaint & Claim」 메뉴는 로그인 사용자만 가능
            // if ( !(UserInfo.getUserType().equals('Guest') && exceptionMenuItemOfGuestUser.contains(obj.Label)) ) {
                result.add( new NavigationMenuItemWrapper(obj) );
            // }
        }

        return result;
    }

    public class CommonWrapper{
        @AuraEnabled public Boolean isSuccess   {get;set;} 
        @AuraEnabled public String message      {get;set;} 
        @AuraEnabled public String result       {get;set;} 

        public CommonWrapper(){
            this.isSuccess 		= true;
            this.message 	= '';
            this.result 	= '';
        }
    }

    public class valuesWrapper{
        @AuraEnabled public String label    {get;set;}
        @AuraEnabled public String value    {get;set;}

        public valuesWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    public class headerWrapper{
        @AuraEnabled public String label                        {get;set;}
        @AuraEnabled public String url                          {get;set;}
        
        public headerWrapper(String label, String url){
            this.label = label;
            this.url = url;
        }
    }

    public class globalSearchWrapper{
        @AuraEnabled public DE_SolutionController.FilterResultWrapper       cjSolutions   {get;set;}
        @AuraEnabled public DE_SolutionController.FilterResultWrapper       bizSolutions  {get;set;}
        @AuraEnabled public DE_CommunityBoardController.FilterResultWrapper boards        {get;set;}
    }

    public class NavigationMenuItemWrapper {
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Label {get;set;}
        @AuraEnabled public Decimal Position {get;set;}
        @AuraEnabled public String Target {get;set;}
        @AuraEnabled public String Type {get;set;}
        @AuraEnabled public String AccessRestriction {get;set;}
        @AuraEnabled public Object debugMsg {get;set;}

        public NavigationMenuItemWrapper() {}
        public NavigationMenuItemWrapper(NavigationMenuItem obj) {
            this.Id                 = obj.Id;
            this.Label              = obj.get('menuitemlabel') == null ? '' : (String)obj.get('menuitemlabel');
            this.Position           = obj.Position;
            this.Target             = obj.Target;
            this.Type               = obj.Type;
            this.AccessRestriction  = obj.AccessRestriction;
            this.debugMsg           = obj;
        }
    }
}