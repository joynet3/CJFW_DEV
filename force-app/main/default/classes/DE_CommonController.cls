/**
* 커뮤니티 공통 기능 컨트롤러
*
*@group  DE
*@author 조형준
*@since 2023-08-18  내용 작성
*/
public without sharing class DE_CommonController {
    /**
    * 픽리스트 값 가져오기
    *
    *@param  objectName 오브젝트 명, fieldName 필드 명
    *@return  List<valuesWrapper> List<label, value> 형태
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<valuesWrapper> getPicklistValues(String objectName, String fieldName){
        List<valuesWrapper> result= new List<valuesWrapper>();
        
        try {
            Schema.DescribeSobjectResult[] objects = Schema.describeSObjects(new String[]{objectName});
            for(Schema.DescribeSobjectResult res : objects){
                for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                    if (entry.isActive()) {
                        result.add(new valuesWrapper(entry.getLabel(), entry.getValue()));
                    }
                 }
            }  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        System.debug(result);
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
}