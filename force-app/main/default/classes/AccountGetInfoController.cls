/**
* class 설명 : cjfwAccountSearchModal cmp 에서 호출되는  Controller 
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author eunyoung.choi
*@since 2023-07-31  내용 작성
*/
public with sharing class AccountGetInfoController {

    /*
    searchKey - 고객사명 or 고객사코드 
    customerType - 고객사 유형 : 본점 or 판매처 or 관리처
    */
    @AuraEnabled(cacheable=true)
    public static Account getAccInfo(String searchKey , String customerType){
         system.debug('AccountGetInfoController #getAccInfo => ' );
         Account accList = [SELECT id ,CustomerID__c, Name , CompanyRegisterNumber__c, CustomerStatus__c, PIC__r.Name, PICCode__c 
         FROM Account 
         WHERE searchKey__c  LIKE :'%'+searchKey+'%' AND toLabel(CustomerType__c) =: customerType];
         
         system.debug('return => ' + accList);
        return accList;
    }
}