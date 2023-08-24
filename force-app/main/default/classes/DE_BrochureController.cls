/**
* 상품안내 관련 컨트롤러
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 조형준
*@since 2023-08-16  내용 작성
*/
public without sharing class DE_BrochureController {

    /**
    * 상품 검색을 위한 년 값 가져오기
    *
    *@param 
    *@return List<valuesWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<valuesWrapper> getSearchYears(){
        List<valuesWrapper> result = new List<valuesWrapper>();
        List<AggregateResult> aggregateResults = new List<AggregateResult>();
        Map<String, valuesWrapper> valueWrapperMap = new Map<string, valuesWrapper>();

        try{
            aggregateResults = [SELECT CALENDAR_YEAR(issueDate__c) year
                                FROM Brochure__c
                                WHERE issueDate__c != null
                                GROUP BY issueDate__c
                                ORDER BY issueDate__c DESC
                                ];

            for(AggregateResult obj : aggregateResults){
                valueWrapperMap.put(String.valueOf(obj.get('year')), new valuesWrapper(String.valueOf(obj.get('year')), String.valueOf(obj.get('year'))));
            }

            result = valueWrapperMap.values();

        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    /**
    * 상품 검색을 위한 년에 해당하는 월 가져오기
    *
    *@param 
    *@return List<valuesWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<valuesWrapper> getSearchMonths(String year){
        List<valuesWrapper> result = new List<valuesWrapper>();
        List<AggregateResult> aggregateResults = new List<AggregateResult>();

        try{
            aggregateResults = [SELECT CALENDAR_YEAR(issueDate__c) year
                                        , CALENDAR_MONTH(issueDate__c) month
                                FROM Brochure__c
                                WHERE issueDate__c != null
                                AND CALENDAR_YEAR(issueDate__c) = :Integer.valueOf(year)
                                GROUP BY issueDate__c
                                ORDER BY issueDate__c DESC
                                ];

            for(AggregateResult obj : aggregateResults){
                result.add(new valuesWrapper(String.valueOf(obj.get('month')), String.valueOf(obj.get('month'))));
            }
        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('STACK TRACE : ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    /**
    * 상품안내 url에 해당하는 브로셔 정보 가져오기
    *
    *@param  categoryURL 상품안내 url ex) /success-story
    *@return  FilterResultWrapper
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static FilterResultWrapper getBrochure(String categoryURL, String year, String month){
        FilterResultWrapper result= new FilterResultWrapper();
        List<brochureWrapper> brochureWrappers= new List<brochureWrapper>();
        List<Brochure__c> brochures = new List<Brochure__c>();
        Set<String> setBrochureId = new Set<String>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<String, String> thumbnailUrlMap = new Map<String, String>();
        Map<String, String> pdfUrlMap = new Map<String, String>();

        try {
            BrochureGroup__c brochureGroup = [SELECT Id
                                                FROM BrochureGroup__c
                                                WHERE CommunityURL__c =: categoryURL
                                                ];

            String querySelect = 'SELECT Id'
                         +  '    , Name'
                         +  ' FROM Brochure__c';
            String queryWhere = ' WHERE BrochureGroup__c = \'' + brochureGroup.Id + '\'';
                    if(String.isNotBlank(year)
                        &&String.isNotBlank(month))queryWhere += ' AND issueDate__c = ' + DateTime.newInstance(Integer.valueOf(year),Integer.valueOf(month),01).format('yyyy-MM-dd');
            String queryOrder = ' ORDER BY CreatedDate DESC';

            brochures = Database.query(querySelect + queryWhere + queryOrder);

            if(brochures.size() > 0){
                for(Brochure__c obj : brochures){
                    setBrochureId.add(obj.Id);
                }

                //썸네일 url 가져오기
                contentDistributions = [SELECT Id
                                                , Name
                                                , RelatedRecordId
                                                , DistributionPublicUrl
                                                , ContentDownloadUrl
                                            FROM ContentDistribution
                                            WHERE RelatedRecordId IN :setBrochureId
                                            AND (Name LIKE 'thumbNail_%'
                                            OR Name LIKE '%.pdf')
                                            ];

                for(ContentDistribution obj : contentDistributions){
                    if(obj.Name.startsWith('thumbNail_'))thumbnailUrlMap.put(obj.RelatedRecordId, obj.ContentDownloadUrl);
                    else if(obj.Name.endsWith('.pdf'))pdfUrlMap.put(obj.RelatedRecordId, obj.DistributionPublicUrl);
                }

                for(Brochure__c obj : brochures){
                    brochureWrappers.add(new brochureWrapper(obj, thumbnailUrlMap.get(obj.Id), pdfUrlMap.get(obj.Id)));
                }

                result.brochures = brochureWrappers;
                result.totalCnt = brochureWrappers.size();
            }

        } catch (Exception e) {
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

    public class FilterResultWrapper {
        @AuraEnabled public Integer totalCnt{get;set;} //총 건수
        @AuraEnabled public List<brochureWrapper> brochures{get;set;} // 상품(브로셔) 목록
        public FilterResultWrapper() {}
    }
}