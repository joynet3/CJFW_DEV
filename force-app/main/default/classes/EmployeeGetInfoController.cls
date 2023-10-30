/**
 * @description       : 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-30-2023
 * @last modified by  : hyeeun.song@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-30-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
public with sharing class EmployeeGetInfoController {


    /*
    searchKey - 사원코드 or 명 검색어
    customerType - 부서 select 된것 
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getEmpInfo(String searchKey , String employeeType , Integer pageNumber, Integer pageSize ){

        system.debug('#EmployeeGetInfoController #getEmpInfo' );

        Map<String,Object> getEmpMap = new Map<String,Object>();

        String searchKeyTerm = '%' + searchKey + '%';

        system.debug('searchKey -> ' + searchKeyTerm );
         
        String queryString = ' SELECT id, Name, EmployeeNumber, CJTitle__c, Username, Email ' +
                              ' FROM User ' + 
                              ' WHERE EmployeeNumber LIKE :searchKeyTerm ' +
                              ' OR Name LIKE :searchKeyTerm ';
         
        List<User> empList = new List<User>();
        System.debug('query ->  ' + queryString);
        
        List<User> allEmployees = Database.query(queryString);

        Integer startIndex = (pageNumber - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, allEmployees.size());

        System.debug('startIndex: ' + startIndex);
        System.debug('endIndex: ' + endIndex);
        System.debug('allEmployees size: ' + allEmployees.size() );
        Integer totalCnt = allEmployees.size() ;

            if(endIndex > startIndex){
                for (Integer i = startIndex; i < endIndex; i++) {
                    empList.add(allEmployees[i]);
                }
                getEmpMap.put('empList', empList);
            }

        getEmpMap.put('totalCnt',allEmployees.size());

        System.debug('Query: ' + queryString);
        System.debug('pageSize: ' + pageSize);

        return getEmpMap;
    }
}