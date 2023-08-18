/**
 * @description       : 매출/채권 메뉴탭 마다 다른 , header 정보 list 정보에 뿌려질 데이터를 모아놓은 object 를 조회하는 용도
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-18-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-07-2023   eunyoung.choi@dkbmc.com   Initial Version
 * 1.1   08-08-2023   eunyoung.choi@dkbmc.com   다이나믹 쿼리 추가..
 * 1.1   08-18-2023   eunyoung.choi@dkbmc.com   getWhereQuery 메소드에 type 이 date 로 들어오는것 한국시간에 맞게 조회기능 추가 
**/
public with sharing class CommSearchDataController {

    /**
    *@param  menuSearch : 어떤메뉴바를 선택했는지 구분값 
    *@return  CJFW_CommSearchData__c 리스트 반환 
     @description : Header에 어떤 컬럼을 노출할지 확인을 위해 해당 오브젝트에서 조회
     CommSearchDataController.getCommSearchData   
     @author : eunyoung
    */
   @AuraEnabled(cacheable=true)
   public static List<CJFW_CommSearchData__c> getCommSearchData(String menuSearch){
       system.debug('CommSearchDataController #getCommSearchData => ' );
       
       List<CJFW_CommSearchData__c> searList = new List<CJFW_CommSearchData__c>();
           System.debug('All Data');
           searList = [SELECT 
             Id
           , Object__c
           , OptionLabel__c
           , OptionValue__c
           , Type__c
           , Label__c
           , ApiName__c
           , Required__c
           , Disabled__c
           , FieldType__c
           , IsMobile__c
           , Description__c 
           , HeaderLine__c
           , HeadFilterOrder__c
           , ListOrder__c
           , DatePoint__c
           , IsActive__c
           FROM CJFW_CommSearchData__c  
           WHERE MenuName__c =: menuSearch AND IsActive__c = true
           // WHERE Object__c =: menuSearch OR MenuName__c ='All'
           ORDER BY HeadFilterOrder__c ASC ];   
           
           system.debug('return => ' + searList.size() );
           system.debug('return => ' + searList );

       return searList;
   }


    /**
    *@param  filterDataList : [ api name / objName / searchkey ] List
        @paramExample :  ({apiName=GD_NM__c, objName=SalesLedgerInformation__c, searchKey=3}) 
    *@return  String : WHERE 절 반환 
        @description : Header에 입력받은 값으로 WHERE절 생성 
        CommSearchDataController.getWhereQuery 
        @author : eunyoung
    */
   @AuraEnabled
   public static String getWhereQuery(List<Map<String, String>> filterDataList ){

       system.debug('CommSearchDataController #getWhereQuery=> ' + filterDataList);
       Boolean addWhereClause = true;
       String whereQuery=' WHERE ';
    
        for(Map<String,String> filterData : filterDataList){

            //파람으로 넘어오는 값들 
            String apiName = filterData.get('apiName');
            String objName = filterData.get('objName');
            String fieldType = filterData.get('fieldType');
            String datePointData = filterData.get('datePointData');
            String searchKey = filterData.get('searchKey');
            
            System.debug('getWhereQuery get param > ' + 'apiName: ' + apiName + ', objName: ' + objName + ', fieldType: ' + fieldType + ', datePointData: ' + datePointData + ', searchKey: ' + searchKey);
            
            if(fieldType =='date'){
                searchKey = searchKey + 'T00:00:00+09:00'; //한국시간 DateTime 
            }

            //WHERE 절
            if(addWhereClause){
                String condition='';

                if (fieldType == 'date') {
                    if (datePointData == 'start') {
                        condition = apiName + '>=' + searchKey;
                    }
                        whereQuery += condition;
                    if (datePointData == 'end') {
                        if(condition !=null) whereQuery  += ' AND ' ;
                        whereQuery += apiName + '<=' + searchKey;
                    }
                    system.debug('DATE -> ' + whereQuery);
                }else{
                    if(condition !=null) whereQuery += ' AND ';
                    whereQuery +=  apiName + ' LIKE \'%' + searchKey + '%\'';
                    addWhereClause = false;
                }

            }else{
                whereQuery += ' AND ' + apiName + ' LIKE \'%' + searchKey + '%\'';
            }
        }

        system.debug(' Final whereQuery -> ' + whereQuery );
        return whereQuery;
   }

    /**
    *@param  finalQuery : select from where 조합한 전체쿼리 
    *@return  조회된 데이터 반환
     @description : cjfwCommListView.js 에서 전체 쿼리조합 후 , 조회
     CommSearchDataController.getDataList 
     @author : eunyoung
    */
   @AuraEnabled
   public static List<Object> getDataList(String finalQuery){
       system.debug('CommSearchDataController #getDataList=> ');

       List<SObject> dataList = new List<SObject>();
       try{
           system.debug('data=>' + finalQuery);
           dataList = Database.query(finalquery); 
           system.debug('data=>' + dataList);
           system.debug('data size =>' + dataList.size());
       }catch(Exception e) {
           System.debug(' getDataList Error -> ' + e.getMessage());
       }
       return dataList;
   }

}