/**
 * @description       : CjfwAccountDamBoSearch comp에서 호출되는 controller
 * @author            : doyeon.kim@dkbmc.com
 * @since 2023-08-07  내용 작성
 * @group             : 
 * @last modified on  : 08-11-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
public with sharing class CJFW_AccountDamBoSearchController {
    //담보 조회 메서드
    @AuraEnabled(cacheable=true)
    public static List<CJFW_CollateralEnrollment__c> getAccDamBoInfo(String searchKey , String Dambovalue , String searchCertiCode){

        System.debug('Check searchKey : ' +searchKey);//Customer__c
        System.debug('Check Dambovalue : ' +Dambovalue);//CollateralType__c
        System.debug('Check searchCertiCode : ' +searchCertiCode);//CertificateNo__c

        List<CJFW_CollateralEnrollment__c> resultList = new List<CJFW_CollateralEnrollment__c>();
        List<CJFW_CollateralEnrollment__c> certiResultList = new List<CJFW_CollateralEnrollment__c>();
        
        //담보쿼리문
        String strQuery = 'SELECT Id, Name, Customer__c, FM_Customer__c, CollateralType__c, CollateralNo__c, ';//거래처코드, 담보구분, 담보번호
                                        //담보종류
                strQuery +=         ' RecordTypeId, RecordType.Name, Category__c,';
                                        //증서번호, 발행처, 채무자, 제공자, 보증(발행)금액, 발행일, 개시일, 지급(만기)일
                strQuery +=         ' CertificateNo__c, Issuer__c, Debtor__c, Provider__c, GuaranteeAmount__c, IssueDate__c, CommencementDate__c, DueDate__c,';
                                        //주소, 세부주소, 채무자와의 관계, 담보감정가액, 담보감정일, 근저당 설정 금액, 근저당 설정일
                strQuery +=         ' CollateralAddress__c, CollateralAddressDetail__c, DebtorRelationship__c, CollateralValue__c, AppraisalDate__c, MortgageAmount__c, MortgageDate__c,';
                                        //구입금액, 입금금액, 현금담보전표번호, 감정가액, 입금일
                strQuery +=         ' PurchaseAmount__c, Deposit__c, CashCollateralReceipt__c, FM_CollateralValue__c, DepositDate__c,';
                                        //총담보, 실담보, 처리구분, 승인일, 만기여부, 해지여부, 비고
                strQuery +=         ' TotalCollateralAmount__c, ActualCollateralAmount__c, ProcessStatus__c, ApprovalDate__c, ExpirationStatus__c, CloseStatus__c, Description__c';
                strQuery += ' FROM       CJFW_CollateralEnrollment__c';

        
        if(searchKey == null){
            System.debug('searchKey Null');
        }else if( searchKey == null && Dambovalue == null){
            System.debug('All Null');
        }else{
            System.debug('All Data');
            
            if (searchKey != null) {//거래처 + 담보구분 쿼리문
                System.debug('strQuery CHECK >>>>>' + strQuery);
                strQuery +=         '   WHERE       Customer__r.CustomerId__c = :searchKey';
                strQuery +=         '   AND       CollateralType__c = :Dambovalue';
                System.debug('strQuery CHECK >>>>>' + strQuery);

                resultList = Database.query(strQuery);
                System.debug('collResultList CHECK >>>>>' + resultList);

            }else if(searchCertiCode != null){//증서번호 쿼리문
                // strQuery +=         '   WHERE       CollateralNo__c = :searchCertiCode';
                strQuery +=         '   WHERE       CertificateNo__c = :searchCertiCode';
                System.debug('strQuery CHECK >>>>>' + strQuery);

                resultList = Database.query(strQuery);
                System.debug('certiResultList CHECK >>>>>' + resultList);

            }

        }
        
        if (!resultList.isEmpty()) {
            system.debug('return => ' + resultList.size() );
        }
        
        return resultList;
    }

    //증서 조회 메서드
    @AuraEnabled(cacheable=true)
    public static List<CJFW_CollateralEnrollment__c> getAccCertiInfo(String searchCertiCode){

        System.debug('Check searchCertiCode : ' +searchCertiCode);//CertificateNo__c

        List<CJFW_CollateralEnrollment__c> certiResultList = new List<CJFW_CollateralEnrollment__c>();
        
        //보증보험 쿼리문
        String strQuery = 'SELECT Id, Name, Customer__c, FM_Customer__c, CollateralType__c, CollateralNo__c, ';//거래처코드, 담보구분, 담보번호
                                        //담보종류, 종류
                strQuery +=         ' RecordTypeId, RecordType.Name, Category__c,';
                                        //증서번호, 발행처, 채무자, 보증(발행)금액, 발행일, 개시일, 지급(만기)일
                strQuery +=         ' CertificateNo__c, Issuer__c, Debtor__c, GuaranteeAmount__c, IssueDate__c, CommencementDate__c, DueDate__c,';
                                        //총담보, 실담보, 처리구분, 승인일, 만기여부, 해지여부, 비고
                strQuery +=         ' TotalCollateralAmount__c, ActualCollateralAmount__c, ProcessStatus__c, ApprovalDate__c, ExpirationStatus__c, CloseStatus__c, Description__c';
                strQuery += ' FROM       CJFW_CollateralEnrollment__c';

        
        if(searchCertiCode == null){
            System.debug('searchCertiCode Null Check (((' + searchCertiCode);
        }else if(searchCertiCode != null){//증서번호 쿼리문
            System.debug('strQuery CHECK >>>>>' + strQuery);

            strQuery +=         '   WHERE       CertificateNo__c = :searchCertiCode';
            System.debug('strQuery += WHERE CertificateNo__c = :  ' + searchCertiCode);

            certiResultList = Database.query(strQuery);
            System.debug('certiResultList CHECK >>>>>' + certiResultList);

        }
        
        if (!certiResultList.isEmpty()) {
            system.debug('return => ' + certiResultList.size() );
        }
        
        return certiResultList;
    }

    //부서별 배부 데이터 조회 메서드
    @AuraEnabled(cacheable=true)
    public static List<CJFW_DepartmentAllocation__c> getDepartInfo(String searchKey){
        
        System.debug('Check searchKey : ' +searchKey);//Customer__c
        List<CJFW_DepartmentAllocation__c> departList = new List<CJFW_DepartmentAllocation__c>();

        try {
            
            if (searchKey != null) {

                //부서별 배부 쿼리문
                String departQuery ='SELECT Id, Name, Customer__c, Customer__r.Name, DeptCode__c, DeptName__c, CollateralEnrollment__c, CollateralEnrollment__r.Name, FM_CustomerId__c,';
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