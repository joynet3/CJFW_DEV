/**
 * @description       : 하위 품의서에 노출시킬 데이터 가져오는 용도의 Controller
 * 
  [품의서종류 참고사항]
  (급식솔루션,헬씨,아이누리)_신규개설품의 page : CJFW_NewOpenReport
  (급식)_보증금양식 page : CJFW_DepositForm
  (아이누리)_신규개설품의 page : CJFW_NewInuriOpenReport
  (외식)_수주심의운영 page : CJFW_OrderConsiderManage
  (외식)_수주심의양식(신규) page : CJFW_OrderConsiderNewForm
  (외식)_수주심의양식(재계약) page : CJFW_OrderConsiderReContractForm

 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-28-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-24-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
public with sharing class ReportFormController {
    public Account accountInfo {get;set;}

    public String accountName { get; set; }
    public String savedAccountName { get; set; }
    
    public void saveAccount() {
        savedAccountName = accountName;
    }
    
    public ReportFormController() {
        // 거래처 현황 테이블 - 고객사정보 (개발테스트용으로 값 1개만 출력되게함, 추후수정예정)
        accountInfo = [SELECT id 
        , searchKey__c 
        , RepresentativeName__c 
        , BusinessPath__c 
        , PV_CSHAPE__c
        , OurSales__c 
        , InitialDeliveryRequestDate__c 
        , Address__c
        , InitialDeliveryContact__c
        , PV_EXISTSUP__c
        , UnitPriceGroup__c 
        , FWReleaseCenter__c
        FROM Account 
        WHERE searchKey__c ='[25109]이로운나라의앨리스'
        //LIMIT 1
        ];

    }
}