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
 * @last modified on  : 09-08-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-24-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
public with sharing class ReportFormController {

    /* 꼐산값 가져오기 */
    public Account accountInfo {get;set;}
    public CJFW_ExpectedIncomeExpenses__c IncomeExpensesInfo {get;set;}

    public String accountName { get; set; }
    public String savedAccountName { get; set; }

    /* picklist 값 가져오기 위한 선언 */
    public String selectedType { get; set; }
    public List<SelectOption> typeOptions { get; set; }

    /* 계산로직 test */
    public Decimal input1 { get; set; }
    public Decimal input2 { get; set; }
    public Decimal result { get; set; }

    public void saveAccount() {
        savedAccountName = accountName;
    }

    public void multiply() {
        result = input1 * input2;
    }
    
    //public ReportFormController_before() {


        // Pick list Type 가져오는 부분 
/*         Schema.DescribeFieldResult fieldResult = CJFW_ExpectedIncomeExpenses__c.CollateralType__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        typeOptions = new List<SelectOption>();
        for (Schema.PicklistEntry picklistValue : picklistValues) {
            typeOptions.add(new SelectOption(picklistValue.getLabel(), picklistValue.getValue()));
        } */



        // 거래처 현황 테이블 - 고객사정보 (개발테스트용으로 값 1개만 출력되게함, 추후수정예정)
/*         accountInfo = [SELECT id 
        , searchKey__c 
        , Type
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
        ]; */

    //}

    /* 
    컨트롤러가 호출되면 돌아가는 부분 
    */
    public ReportFormController() {
        getPicklistValues();
        getAccountInfo();
        getIncomeExpenses();
    }


    /* 
    Picklist 값을 가져오는 메소드
    */
    public void getPicklistValues() {

        Schema.DescribeFieldResult fieldResult = CJFW_ExpectedIncomeExpenses__c.CollateralType__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        typeOptions = new List<SelectOption>();
        for (Schema.PicklistEntry picklistValue : picklistValues) {
            typeOptions.add(new SelectOption(picklistValue.getLabel(), picklistValue.getValue()));
        }

        System.debug('# ReportFormController picklist ->' + typeOptions );

    }


    /*
    거래처 정보를 가져오는 메소드
     */
    public void getAccountInfo() {
        accountInfo = [SELECT Id,
                            searchKey__c,
                            Type,
                            RepresentativeName__c,
                            BusinessPath__c,
                            PV_CSHAPE__c,
                            OurSales__c,
                            InitialDeliveryRequestDate__c,
                            Address__c,
                            InitialDeliveryContact__c,
                            PV_EXISTSUP__c,
                            UnitPriceGroup__c,
                            FWReleaseCenter__c,
                            CaptialSales__c
                    FROM Account 
                    WHERE searchKey__c ='[25109]이로운나라의앨리스'
                    //LIMIT 1
                    ];
    }

    /* 
    예산손익 : CJFW_ExpectedIncomeExpenses__c 에서 값 가져오기
    */
    public void getIncomeExpenses() {

        System.debug('# ReportFormController # getIncomeExpenses');

        IncomeExpensesInfo = [
        SELECT Id,
            ExpectSales__c,
            Opportunity__c,
            ResultExpectSales__c,
            ResultExpectRate__c,
            ExpectContributionProfit__c,
            ExpectContributionProfitRate__c,
            SupportFeeRate__c,
            ExpectSalesProfit__c,
            ExpectSalesProfitRate__c,
            ContractDepreciationRate__c,
            CollateralAmount__c,
            CollateralType__c,
            ExpectProfit__c,
            CollateralPeriod__c,
            CreditLoanAmount__c,
            ContractDepreciationSupport__c,
            SalesFeeSupport__c,
            DonationSupport__c,
            OtherSupport__c,
            PaymentMethod__c,
            ContractPaymentDate__c,
            ChefSupportCnt__c,
            FarmSupportExpect__c,
            MarineSupportExpect__c,
            LivestockSupportExpect__c,
            ManufactureSupportExpect__c,
            NonFoodSupportExpect__c,
            SalesSupportExpect__c,
            IsReportCheck__c,
            IncentiveSupport__c
        FROM CJFW_ExpectedIncomeExpenses__c
        WHERE id ='a1l0w000001MmAMAA0'
        ];

        System.debug('# 손익계산 ' + IncomeExpensesInfo);
    }
}