/**
 * @description       : CjfwAccountDamBoSearch comp에서 호출되는 controller
 * @author            : doyeon.kim@dkbmc.com
 * @since 2023-08-07  내용 작성
 * @group             : 
 * @last modified on  : 08-08-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
public with sharing class CJFW_AccountDamBoSearchController {
    
    @AuraEnabled(cacheable=true)
    public static List<CJFW_CollateralEnrollment__c> getAccDamBoInfo(String searchKey , String Dambovalue , String searchCertiCode){

        System.debug('Check searchKey : ' +searchKey);//Customer__c
        System.debug('Check Dambovalue : ' +Dambovalue);//CollateralType__c
        System.debug('Check searchCertiCode : ' +searchCertiCode);//CertificateNo__c
        
        //담보쿼리문
        String strQuery = 'SELECT Id, Name, Customer__c, Customer__r.Name, CollateralType__c, CollateralNo__c,';//거래처코드, 담보구분
                strQuery +=         ' RecordTypeId, Category__c';//담보종류
                strQuery +=         ' CertificateNo__c, Issuer__c, Debtor__c, GuaranteeAmount__c, IssueDate__c, CommencementDate__c, DueDate__c,';
                strQuery +=         ' TotalCollateralAmount__c, ActualCollateralAmount__c, ProcessStatus__c, ApprovalDate__c, ExpirationStatus__c, CloseStatus__c, Description__c,';//보증보험 컬럼
                strQuery +=         ' CollateralAddress__c, CollateralAddressDetail__c, DebtorRelationship__c, ApprovalDate__c, ExpirationStatus__c, CloseStatus__c, Description__c,';
                strQuery +=         ' TotalCollateralAmount__c, ActualCollateralAmount__c, ProcessStatus__c, ApprovalDate__c, ExpirationStatus__c, CloseStatus__c, Description__c,';//부동산 컬럼
                strQuery +=         '   FROM       CJFW_CollateralEnrollment__c';
                strQuery +=         '   WHERE       RecordTypeId = :recordIdSchool';

        List<CJFW_CollateralEnrollment__c> resultList = new List<CJFW_CollateralEnrollment__c>();
        
        if(searchKey == null){
            System.debug('searchKey Null');
        }else if( searchKey == null && Dambovalue == null){
            System.debug('All Null');
        }else{
            System.debug('All Data');
            
            if (searchKey != null) {//거래처 + 담보구분 쿼리문
                resultList = [SELECT id , 
                                    Name, 
                                    Customer__c, 
                                    CollateralType__c
                                FROM CJFW_CollateralEnrollment__c 
                                WHERE Customer__c =: searchKey 
                                And CollateralType__c =: Dambovalue];  
            }else {//증서번호 쿼리문
                
            }
        	
            system.debug('return => ' + resultList.size() );
        }

        return null;
    }

    //부서별 배부 데이터 조회 메서드
    @AuraEnabled(cacheable=true)
    public static List<CJFW_DepartmentAllocation__c> getDepartInfo(String searchKey){
        
        System.debug('Check searchKey : ' +searchKey);//Customer__c
        List<CJFW_DepartmentAllocation__c> departList = new List<CJFW_DepartmentAllocation__c>();

        try {
            
            if (searchKey != null) {

                //부서별 배부 쿼리문
                String departQuery ='SELECT Id, Name, Customer__c, DeptCode__c, DeptName__c, CollateralEnrollment__c, FM_CustomerId__c,';
                        departQuery += ' FM_TotalCollateralAmount__c, ActualCollateralAmount__c, CloseStatus__c, ExpirationStatus__c, Description__c';
                        departQuery += ' FROM CJFW_DepartmentAllocation__c';
                        departQuery += ' WHERE FM_CustomerId__c =: searchKey';
        
                departList = Database.query(departQuery);
                System.debug('check departList : '+ departList);
                    
                if (!departList.isEmpty()) {
                    System.debug('departList >>>> ' + departList.size());
                }
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        return departList;

    }
}