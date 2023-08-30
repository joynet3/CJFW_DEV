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
    public static List<Account> getAccInfo_before(String searchKey , String accountType , Integer pageNumber, Integer pageSize){

        system.debug('#AccountGetInfoController #getAccInfo' );

        if(accountType =='전체') accountType ='';
        
        // pageNumber : 현재 페이지 
        // pageSize : 몇개를 받아올지 지정 

        // 전체 13만건의 account 를 pagesize 에 따라서 나누기 
         String searchKeyTerm = '%' + searchKey + '%';
         String accountTypeTerm = '%' + accountType + '%';
         
         String queryString = 'SELECT id, CustomerID__c, Name, searchKey__c, fm_empname__c, fm_empId__c, tolabel(CustomerStatus__c), toLabel(CustomerType__c), CompanyRegisterNumber__c, PIC__r.Name, PICCode__c ' +
                                'FROM Account ' +
                                'WHERE searchKey__c LIKE :searchKeyTerm AND toLabel(CustomerType__c) LIKE :accountTypeTerm ';
         
        List<Account> accList = new List<Account>();
        List<Account> allAccounts = Database.query(queryString);

        Integer startIndex = (pageNumber - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, allAccounts.size());

        System.debug('startIndex: ' + startIndex);
        System.debug('endIndex: ' + endIndex);
        System.debug('allAccSize: ' + allAccounts.size() );
        Integer totalCnt = allAccounts.size() ;

        for (Integer i = startIndex; i < endIndex; i++) {
            accList.add(allAccounts[i]);
        }

        System.debug('Query: ' + queryString);
        System.debug('pageSize: ' + pageSize);

        system.debug('#getAccInforeturn size =>' + accList.size() );

        return accList;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getAccInfo(String searchKey , String accountType , Integer pageNumber, Integer pageSize){

        system.debug('#AccountGetInfoController #getAccInfo' );

        if(accountType =='전체') accountType ='';
        Map<String,Object> getAccMap = new Map<String,Object>();
        
        // 전체 13만건의 account 를 pagesize 에 따라서 나누기 
         String searchKeyTerm = '%' + searchKey + '%';
         String accountTypeTerm = '%' + accountType + '%';
         
         String queryString = 'SELECT id, CustomerID__c, Name, searchKey__c, fm_empname__c, fm_empId__c, tolabel(CustomerStatus__c), toLabel(CustomerType__c), CompanyRegisterNumber__c, PIC__r.Name, PICCode__c ' +
                                'FROM Account ' +
                                'WHERE searchKey__c LIKE :searchKeyTerm AND toLabel(CustomerType__c) LIKE :accountTypeTerm ';
         
        List<Account> accList = new List<Account>();
        List<Account> allAccounts = Database.query(queryString);

        Integer startIndex = (pageNumber - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, allAccounts.size());

        System.debug('startIndex: ' + startIndex);
        System.debug('endIndex: ' + endIndex);
        System.debug('allAccSize: ' + allAccounts.size() );
        Integer totalCnt = allAccounts.size() ;

        // search key 가 없을땐 너무 많은 데이터가 쿼리되기 때문에 , pagesize 에 따라서 나눠줌
        //if(searchKey == null){
            if(endIndex > startIndex){
                for (Integer i = startIndex; i < endIndex; i++) {
                    accList.add(allAccounts[i]);
                }
                getAccMap.put('accList', accList);
            }

        //}else{
           // system.debug(' search key 있을때! ->' + searchKey );
           // getAccMap.put('accList',allAccounts);
        //}

        getAccMap.put('totalCnt',allAccounts.size());

        System.debug('Query: ' + queryString);
        System.debug('pageSize: ' + pageSize);
        system.debug('#getAccInforeturn size =>' + accList.size() );

        return getAccMap;
    }


}