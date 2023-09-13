/**
* 커뮤니티 게시판 관련 컨트롤러
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 조형준
*@since 2023-08-16  내용 작성
*/
public without sharing class CommunityBoardController {

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
    public static List<boardWrapper> getBoard(String categoryURL, String siteDivision){
        List<boardWrapper> result= new List<boardWrapper>();
        List<CommunityBoard__c> communityBoards = new List<CommunityBoard__c>();
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
                         +  '    , ContentId__c'
                         +  '    , Views__c'
                         +  '    , CreatedDate'
                         +  ' FROM CommunityBoard__c';
            String queryWhere = ' WHERE CommunityGroupDetail__c = \'' + communityGroupDetail.Id + '\'';
            queryWhere += ' AND (SiteDivision__c = \'common\''
                        + ' OR SiteDivision__c = :siteDivision)';
            String queryOrder = ' ORDER BY CreatedDate DESC';

            communityBoards = Database.query(querySelect + queryWhere + queryOrder);

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
                                            AND Name LIKE 'thumbNail_%'
                                            ];

                for(ContentDistribution obj : contentDistributions){
                    thumbnailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
                }

                for(CommunityBoard__c obj : communityBoards){
                    result.add(new boardWrapper(obj, thumbnailUrlMap.get(obj.Id)));
                }
            }

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
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

    public class boardWrapper{
        @AuraEnabled public String title            {get;set;}      //제목
        @AuraEnabled public String content          {get;set;}      //내용
        @AuraEnabled public String contentImage     {get;set;}      //이미지
        @AuraEnabled public Integer views           {get;set;}     //조회수
        @AuraEnabled public String createdDate      {get;set;}     //생성일

        public boardWrapper(CommunityBoard__c obj, String imageUrl){
            this.title = obj.Name;
            this.content = obj.Content__c;
            this.contentImage = imageUrl;
            this.views = Integer.valueOf(obj.Views__c);
            this.createdDate = obj.CreatedDate.format();
        }
    }

    /**
    * 상품안내 Wrapper
    */
    public class brochureWrapper{
        @AuraEnabled public String title            {get;set;}      //제목
        @AuraEnabled public String contentImage     {get;set;}      //이미지
        @AuraEnabled public String pdfUrl           {get;set;}      //pdf 

        public brochureWrapper(Brochure__c obj, String imageUrl, String pdfUrl){
            this.title = obj.Name;
            this.contentImage = imageUrl;
            this.pdfUrl = pdfUrl;
        }
    }
}