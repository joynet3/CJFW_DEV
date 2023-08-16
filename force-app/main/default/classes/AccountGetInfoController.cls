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
    public static List<Account> getAccInfo(String searchKey , String accountType){
        system.debug('AccountGetInfoController #getAccInfo => ' );
        if(accountType =='전체') accountType ='';
        List<Account> accList = new List<Account>();
        if(searchKey == null){
            System.debug('searchKey Null');
        }else if(accountType == null){
            System.debug('accountType Null');
        }else if( searchKey == null && accountType == null){
            System.debug('All Null');
        }else{
            System.debug('All Data');
            accList = [SELECT id ,CustomerID__c, Name ,searchKey__c, fm_empname__c , fm_empId__c , tolabel(CustomerStatus__c), toLabel(CustomerType__c) , CompanyRegisterNumber__c, PIC__r.Name, PICCode__c 
            FROM Account 
            WHERE (searchKey__c  LIKE :'%'+searchKey+'%' AND toLabel(CustomerType__c) LIKE :'%'+accountType+'%') ];   
        	
            system.debug('return => ' + accList.size() );
        }
        return accList;
    }
}