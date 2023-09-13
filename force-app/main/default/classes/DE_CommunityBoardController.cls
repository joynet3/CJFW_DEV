/**
* 커뮤니티 게시판 관련 컨트롤러
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 조형준
*@since 2023-08-16  내용 작성
*/
public without sharing class DE_CommunityBoardController {

    /**
    * 카테고리 url에 해당하는 게시글 정보 가져오기
    *
    *@param  categoryURL 커뮤니티 페이지 url ex) /success-story
    *@return  List<boardWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static FilterResultWrapper getBoards(String categoryURL, String SearchText){
        FilterResultWrapper result= new FilterResultWrapper();
        List<boardWrapper> boards= new List<boardWrapper>();
        List<List<SObject>> searchs = new List<List<SObject>>();
        List<CommunityBoard__c> communityBoards = new List<CommunityBoard__c>();
        Set<String> setCommunityBoardId = new Set<String>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<String, String> thumbnailUrlMap = new Map<String, String>();

        try {
            CommunityGroupDetail__c communityGroupDetail = [SELECT Id
                                                            FROM CommunityGroupDetail__c
                                                            WHERE CommunityURL__c =: categoryURL
                                                            ];

            //검색 값이 있을 경우 Search, 없을 경우 Query
            if(String.isNotBlank(SearchText)){
                searchs = [FIND :SearchText IN ALL FIELDS
                                RETURNING CommunityBoard__c(Id, Name, Content__c, Views__c, CreatedDate, CommunityGroupDetail__r.CommunityURL__c
                                                            WHERE CommunityGroupDetail__c = :communityGroupDetail.Id
                                                            ORDER BY CreatedDate DESC)
                                                            ];

                if(searchs.size() > 0) communityBoards = (List<CommunityBoard__c>)searchs[0];
            }else{
                String querySelect = 'SELECT Id'
                                +  '    , Name'
                                +  '    , Content__c'
                                +  '    , Views__c'
                                +  '    , CreatedDate'
                                +  '    , CommunityGroupDetail__r.CommunityURL__c'
                                +  ' FROM CommunityBoard__c';
                String queryWhere = ' WHERE CommunityGroupDetail__c = \'' + communityGroupDetail.Id + '\'';
                if(String.isNotBlank(SearchText)) queryWhere += ' AND Name LIKE \'%' + SearchText + '%\'';
                String queryOrder = ' ORDER BY CreatedDate DESC';

                communityBoards = Database.query(querySelect + queryWhere + queryOrder);
            }

            if(communityBoards.size() > 0){
                for(CommunityBoard__c obj : communityBoards){
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

                for(CommunityBoard__c obj : communityBoards){
                    boards.add(new boardWrapper(obj, thumbnailUrlMap.get(obj.Id)));
                }

                result.boards = boards;
                result.totalCnt = boards.size();
            }

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    /**
    * 커뮤니티 상세 페이지 정보 가져오기
    *
    *@param  String recordId 레코드 아이디
    *@return  List<boardWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<boardWrapper> getBoard(String recordId){
        List<boardWrapper> result = new List<boardWrapper>();
        List<CommunityBoard__c> boards = new List<CommunityBoard__c>();
        List<CommunityBoard__c> beforeBoards = new List<CommunityBoard__c>();
        List<CommunityBoard__c> afterBoards = new List<CommunityBoard__c>();
        Map<String, String> boardNumberMap = new Map<String, String>();
        Map<String, CommunityBoard__c> beforeBoardMap = new Map<String, CommunityBoard__c>();
        Map<String, CommunityBoard__c> afterBoardMap = new Map<String, CommunityBoard__c>();
        Set<String> beforeBoardsNumber = new Set<String>();
        Set<String> afterBoardsNumber = new Set<String>();

        try{
            boards = [
                SELECT Id
                    , Name
                    , CreatedDate
                    , Content__c
                    , boardNumber__c
                    , Views__c
                    , CommunityGroupDetail__r.CommunityURL__c
                FROM CommunityBoard__c
                WHERE Id = :recordId
                ORDER BY boardNumber__c DESC
            ];
                        
            for(CommunityBoard__c obj : boards){
                boardNumberMap.put(obj.Id, obj.boardNumber__c);
                beforeBoardsNumber.add(String.valueOf(Integer.valueOf(obj.boardNumber__c) - 1).leftPad(8, '0'));
                afterBoardsNumber.add(String.valueOf(Integer.valueOf(obj.boardNumber__c) + 1).leftPad(8, '0'));
            }

            beforeBoards = [
                SELECT Id
                        , Name
                        , boardNumber__c
                FROM CommunityBoard__c
                WHERE boardNumber__c IN :beforeBoardsNumber
                ORDER BY boardNumber__c DESC
            ];

            for(CommunityBoard__c obj : beforeBoards){
                beforeBoardMap.put(obj.boardNumber__c, obj);
            }

            afterBoards = [
                SELECT Id
                        , Name
                        , boardNumber__c
                FROM CommunityBoard__c
                WHERE boardNumber__c IN :afterBoardsNumber
                ORDER BY boardNumber__c DESC
            ];

            for(CommunityBoard__c obj : afterBoards){
                afterBoardMap.put(obj.boardNumber__c, obj);
            }

            for(CommunityBoard__c obj : boards){
                CommunityBoard__c beforeBoard = beforeBoardMap.containsKey(String.valueOf(Integer.valueOf(obj.boardNumber__c) - 1).leftPad(8, '0'))
                                            ? beforeBoardMap.get(String.valueOf(Integer.valueOf(obj.boardNumber__c) - 1).leftPad(8, '0'))
                                            : new CommunityBoard__c();
                CommunityBoard__c afterBoard = afterBoardMap.containsKey(String.valueOf(Integer.valueOf(obj.boardNumber__c) + 1).leftPad(8, '0'))
                                            ? afterBoardMap.get(String.valueOf(Integer.valueOf(obj.boardNumber__c) + 1).leftPad(8, '0'))
                                            : new CommunityBoard__c();
                result.add(new boardWrapper(obj, beforeBoard, afterBoard));
            }   
        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }

        return result;
    }

    /**
    * 커뮤니티 게시글 상세 페이지로 이동 시 조회수 증가
    *
    *@param  recordId 레코드 아이디
    *@return  
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static void updateCommunityBoardViews(String recordId){
        try{
            CommunityBoard__c communityBoard = [SELECT Id
                                                    , Views__c
                                            FROM CommunityBoard__c
                                            WHERE Id = :recordId
                                            ];
        
            communityBoard.Views__c += 1;
            
            Update communityBoard;
        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
        }
    }

    public class boardWrapper{
        @AuraEnabled public String title            {get;set;}      //제목
        @AuraEnabled public String content          {get;set;}      //내용
        @AuraEnabled public String contentImage     {get;set;}      //이미지
        @AuraEnabled public Integer views           {get;set;}     //조회수
        @AuraEnabled public String createdDate      {get;set;}     //생성일
        @AuraEnabled public String recordId         {get;set;}     //레코드 아이디
        @AuraEnabled public String communityUrl     {get;set;}     //레코드 아이디

        //상세 페이지용
        @AuraEnabled public String beforeBoardId           {get;set;}//이전 게시글 Id
        @AuraEnabled public String beforeoardName          {get;set;}//이전 게시글 이름
        @AuraEnabled public String afterBoardId            {get;set;}//다음 게시글 Id
        @AuraEnabled public String afterBoardName          {get;set;}//다음 게시글 이름

        //썸네일x
        public boardWrapper(CommunityBoard__c obj){
            this.title = obj.Name;
            this.content = obj.Content__c;
            this.views = Integer.valueOf(obj.Views__c);
            this.createdDate = obj.CreatedDate.format('yyyy.MM.dd');
            this.recordId = obj.Id;
            this.communityUrl = obj.CommunityGroupDetail__r.CommunityURL__c;
        }
        
        //썸네일o
        public boardWrapper(CommunityBoard__c obj, String imageUrl){
            this.title = obj.Name;
            this.content = obj.Content__c;
            this.contentImage = imageUrl;
            this.views = Integer.valueOf(obj.Views__c);
            this.createdDate = obj.CreatedDate.format('yyyy.MM.dd');
            this.recordId = obj.Id;
            this.communityUrl = obj.CommunityGroupDetail__r.CommunityURL__c;
        }

        public boardWrapper(CommunityBoard__c obj, CommunityBoard__c beforeObj, CommunityBoard__c afterObj){
            this.title = obj.Name;
            this.content = obj.Content__c;
            // this.contentImage = imageUrl;
            this.views = Integer.valueOf(obj.Views__c);
            this.createdDate = obj.CreatedDate.format('yyyy.MM.dd');
            this.recordId = obj.Id;
            this.communityUrl = obj.CommunityGroupDetail__r.CommunityURL__c;

            this.beforeBoardId  = beforeObj.Id;
            this.beforeoardName = beforeObj.Name;
            this.afterBoardId   = afterObj.Id;
            this.afterBoardName = afterObj.Name;
        }
    }

    public class FilterResultWrapper {
        @AuraEnabled public Integer totalCnt{get;set;} //총 건수
        @AuraEnabled public List<boardWrapper> boards{get;set;} // 커뮤니티 목록
        public FilterResultWrapper() {}
    }
}