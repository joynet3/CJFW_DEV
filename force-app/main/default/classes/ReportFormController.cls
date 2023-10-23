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
 * @last modified on  : 10-23-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-24-2023   eunyoung.choi@dkbmc.com   Initial Version 작성
**/
public with sharing class ReportFormController {
    // public static Decimal versionCheck;
    public static String SaveDataList;

    public Account accountInfo {get;set;}

    public String opportunityId { get; set; }
    public String incomeExpensesId { get; set;} // 예상손익 id
    public Decimal versionCheck { get; set; }
    public Boolean reportCheck { get; set; }
    public String showtable { get; set; }

    public String fieldValue { get; private set; }

    // 물류비 - 외식(SU)
    public Decimal DistributeDirCap {get;set;}  // 수도권-직접
    public Decimal DistributeDirEast {get;set;} // 동부권-직접
    public Decimal DistributeDirWest {get;set;} // 서부권-직접
    public Decimal DistributeDirJeju {get;set;} // 제주권-직접

    public Decimal DistributeInDirCap {get;set;} // 수도권-간접
    public Decimal DistributeInDirEast {get;set;} // 동부권-간접
    public Decimal DistributeInDirWest {get;set;} // 서부권-간접
    public Decimal DistributeInDirJeju {get;set;} // 제주권-간접

    /* 계산값 가져오기 */
    public CJFW_ExpectedIncomeExpenses__c IncomeExpensesInfo {get;set;} //예상손익 
    public CJFW_ExpectedIncomeManager__c IncomeManager {get;set;} // 예상손익관리 
    public CJFW_DistributionCost__c DistributeCost {get;set;} // 물류비관리 


    public String accountName { get; set; }
    public String savedAccountName { get; set; }

    /* picklist 저장된 값 가져오기 위한 선언 */
    public String selectedCollateral { get; set; } // 담보제공종류
    public String selectedPayment { get; set; }    // 결제수단종류 
    public String selectedContract { get; set; }   //계약서 종류
    public String selectedDelivery { get; set; }   //배송횟수

    /* picklist */
    public List<SelectOption> collateralPickList { get; set; } // 담보제공종류
    public List<SelectOption> paymentPickList { get; set; }    // 결제수단종류 
    public List<SelectOption> contractPickList { get; set; } // 계약서종류
    public List<SelectOption> deliveryPickList { get; set; } // 배송횟수종류

    /* 날짜형식변환 */
    public String collateralPeriod { get; set; } // 담보 제공 기간
    public String contractPaymentDate { get; set; } // 약정결제일
    public String initialDate { get; set; } // 초도일자
    public String contractStartDate { get; set; } // 계약시작
    public String contractEndDate { get; set; } // 계약종료

    /* 
    컨트롤러가 호출되면 돌아가는 부분 
    순서 잘 맞추기
    */
    public ReportFormController() {
        getPicklistValues(); // picklist label/value 값 담기 [1]
        //getAccountInfo();    // 고객사 정보 가져오기 [2]
        //getIncomeExpenses(); // 신규개설품의 obj 값 가져오기 [3]
        getExpectManager();  // 품의서 관리자 작성 obj 값 가져오기 [4] 
        //getDistributeCost(); // 물류비관리 값 가져오기 [5]

        getIncomeExpensesTest();
        getDistributeCostTest();
    }

    /* 
    Oppty 에 있는 Account 값을 가져오는 메소드
    */
   public void getAccountInfo() {

    opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
    incomeExpensesId = ApexPages.currentPage().getParameters().get('incomeExpensesId');
    showtable = ApexPages.currentPage().getParameters().get('showtable');

    System.debug('# opportunityId ->' + opportunityId );
    System.debug('# incomeExpensesId ->' + incomeExpensesId );
    System.debug('# showtable ->' + showtable );

    
    // 기회 레코드에서 계정 ID 가져오기
    Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1].AccountId;
    
    if (accountId != null) {
        // 계정 정보를 쿼리
        accountInfo = [SELECT 
                            Id,
                            Name,
                            RepresentativeName__c,
                            BusinessPath__c, // picklist 너무 많아서 텍스트로 입력하는것으로
                            SalesMonthly__c, // 포뮬라
                            OurSales__c, // currency
                            Address__c,
                            Phone ,
                            PV_EXISTSUP__c 
                        FROM Account 
                        WHERE Id = :accountId 
                    ];

        String[] defaultValSet = new String[] {
            'RepresentativeName__c',
            'BusinessPath__c',
            'Address__c',
            'PV_EXISTSUP__c'
        };

        for (String defaultSet : defaultValSet) {
            Object fieldValue = accountInfo.get(defaultSet);
            // 필드 값이 null이면 기본값을 공백
            if (fieldValue == null)  fieldValue = ''; 
            accountInfo.put(defaultSet, fieldValue);
        }

        System.debug('# 잘 가져왔니 ?->' + accountInfo );
    } else {
        System.debug('# 계정 ID를 찾을 수 없습니다.');
    }
}


    /* 
    Picklist 값을 가져오는 메소드
    */
    public void getPicklistValues() {

       Schema.DescribeFieldResult collateralResult = CJFW_ExpectedIncomeExpenses__c.CollateralType__c.getDescribe();
       Schema.DescribeFieldResult paymentPick = CJFW_ExpectedIncomeExpenses__c.PaymentMethod__c.getDescribe(); // 추가 
       Schema.DescribeFieldResult contractTypePick = CJFW_ExpectedIncomeExpenses__c.ContractType__c.getDescribe(); // 계약서종류 
       Schema.DescribeFieldResult deliveryTypePick = CJFW_ExpectedIncomeExpenses__c.DeliveryCnt__c.getDescribe(); // 배송횟수 
       
       List<Schema.PicklistEntry> collateralValues = collateralResult.getPicklistValues();
       List<Schema.PicklistEntry> paymentValues = paymentPick.getPicklistValues();
       List<Schema.PicklistEntry> contractValues = contractTypePick.getPicklistValues();
       List<Schema.PicklistEntry> deliveryValues = deliveryTypePick.getPicklistValues();

       collateralPickList = new List<SelectOption>();
       paymentPickList = new List<SelectOption>();
       contractPickList = new List<SelectOption>();
       deliveryPickList = new List<SelectOption>();

        for (Schema.PicklistEntry picklistValue : collateralValues) {
            collateralPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }

        for (Schema.PicklistEntry picklistValue : paymentValues) {
            paymentPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }

        for (Schema.PicklistEntry picklistValue : contractValues) { // 계약서종류
            contractPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }
        for (Schema.PicklistEntry picklistValue : deliveryValues) { // 배송횟수
            deliveryPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }

        System.debug(' 배송횟수 테스트  test ' + deliveryPickList);

    }

    /* 
    예산손익(CJFW_ExpectedIncomeExpenses__c) 에서 값 가져오기
    VF Page 초기호출시  
    */
    public void getIncomeExpenses() {

        System.debug('# ReportFormController # getIncomeExpenses');
        
        //opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
        //incomeExpensesId = ApexPages.currentPage().getParameters().get('incomeExpensesId');
        //showtable = ApexPages.currentPage().getParameters().get('showtable');

        //System.debug('# opportunityId ->' + opportunityId );
        //System.debug('# incomeExpensesId ->' + incomeExpensesId );
        //System.debug('# showtable ->' + showtable );

        try {
            String query = 'SELECT Id, ' +
            'Version__c, ' +
            'ExpectSales__c, ' +
            'Opportunity__c, ' +
            'ResultExpectSales__c, ' +
            'ResultExpectRate__c, ' +
            'ExpectContributionProfit__c, ' +
            'ExpectContributionProfitRate__c, ' +
            'SupportFeeRate__c, ' +
            'ExpectSalesProfit__c, ' +
            'ExpectSalesProfitRate__c, ' +
            'CollateralAmount__c, ' +
            'CollateralType__c, ' +
            'ExpectProfit__c, ' +
            'CollateralPeriod__c, ' +
            'CreditLoanAmount__c, ' +
            'ContractDepreciationSupport__c, ' +
            'SalesFeeSupport__c, ' +
            'DonationSupport__c, ' +
            'OtherSupport__c, ' +
            'PaymentMethod__c, ' +
            'ContractPaymentDate__c, ' +
            'ChefSupportCnt__c, ' +
            'FarmSupportExpect__c, ' +
            'MarineSupportExpect__c, ' +
            'LivestockSupportExpect__c, ' +
            'ManufactureSupportExpect__c, ' +
            'NonFoodSupportExpect__c, ' +
            'SalesSupportExpect__c, ' +
            'IsReportCheck__c, ' +
            'ContractDepreciationRate__c, ' +
            'Summary__c, ' +
            'ContractStartDate__c, ' +
            'ContractEndDate__c, ' +
            'ContractType__c, ' +
            'ClientCompanyName__c, ' + // 거래처현황 관련 필드 추가 
            'RepresentativeName__c, ' +  
            'BusinessPath__c, ' +  
            'SalesMonthly__c, ' +  
            'OurSales__c, ' +  
            'Address__c, ' +  
            'RepresentativePhone__c, ' +  
            'PV_EXISTSUP__c, ' +  
            'ExceptionPrice__c, ' +  
            'Center__c, ' +  
            'IncentiveSupport__c, ' +
            'ImprovementPlanDetails__c, ' +
            'OtherSupportDetail__c, ' + // 기타 지원세부 내역
            'AttachedDocument__c, ' + // 첨부서류
            'OpptyDescription__c, ' + // 특이사항
            'InitialDate__c ' + // 초도일자
            'FROM CJFW_ExpectedIncomeExpenses__c';

            if (incomeExpensesId != null) {
                query += ' WHERE id = :incomeExpensesId ';
            }else if (opportunityId != null) {
                query += ' WHERE Opportunity__c = :opportunityId ';
            }

            if(showtable =='true'){
                query += ' ORDER BY IsReportCheck__c DESC LIMIT 1';
            }else{
                query += ' ORDER BY Version__c DESC LIMIT 1';
            }


            // query += ' ORDER BY Version__c DESC LIMIT 1';

            System.debug('# query ->' + query );
            List<CJFW_ExpectedIncomeExpenses__c> incomeExpensesList = Database.query(query);

            if (!incomeExpensesList.isEmpty()) {
                IncomeExpensesInfo = incomeExpensesList[0];
                versionCheck = ( incomeExpensesList[0].Version__c ) + 1 ;
                reportCheck = ( incomeExpensesList[0].IsReportCheck__c );
            } else {
                versionCheck = 1;
                IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c();
            }

        }catch (QueryException e) {
            IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c(); // 빈 레코드로 초기화
        }

        System.debug('IncomeExpensesInfo '+ IncomeExpensesInfo);

        String[] defaultValSet = new String[] {
            'ContractDepreciationSupport__c',
            'IncentiveSupport__c',
            'SalesFeeSupport__c',
            'DonationSupport__c',
            'OtherSupport__c',
            'ChefSupportCnt__c',
            'FarmSupportExpect__c',
            'MarineSupportExpect__c',
            'LivestockSupportExpect__c',
            'ManufactureSupportExpect__c',
            'NonFoodSupportExpect__c',
            'SalesSupportExpect__c',
            'CollateralAmount__c',
            'CreditLoanAmount__c'
        };

        for (String defaultSet : defaultValSet) {
            Object fieldValue = IncomeExpensesInfo.get(defaultSet);

            if (fieldValue == null) fieldValue = 0.0; 
            IncomeExpensesInfo.put(defaultSet, fieldValue);
        }

        selectedCollateral = IncomeExpensesInfo.CollateralType__c; // 담보종류
        selectedPayment = IncomeExpensesInfo.PaymentMethod__c; // 결제수단 
        selectedContract = IncomeExpensesInfo.ContractType__c	; // 계약서종류 
        selectedDelivery = IncomeExpensesInfo.DeliveryCnt__c	; // 배송횟수 

        // ContractPaymentDate__c 필드를 yyyy-MM-dd 형식의 문자열로 변환
        String collateralPeriodString = String.valueOf(IncomeExpensesInfo.collateralPeriod__c);
        String contractPaymentDateString = String.valueOf(IncomeExpensesInfo.contractPaymentDate__c); 
        String initialDateString = String.valueOf(IncomeExpensesInfo.InitialDate__c); // 초도일자 
        String contractStartString = String.valueOf(IncomeExpensesInfo.ContractStartDate__c); // 계약시작일자
        String contractEndString = String.valueOf(IncomeExpensesInfo.ContractEndDate__c); // 계약종료일자 

        collateralPeriod = collateralPeriodString != null ? collateralPeriodString.substring(0, 10) : null;
        contractPaymentDate = contractPaymentDateString != null ? contractPaymentDateString.substring(0, 10) : null;
        initialDate = initialDateString != null ? initialDateString.substring(0, 10) : null;
        contractStartDate = contractStartString != null ? contractStartString.substring(0, 10) : null;
        contractEndDate = contractEndString != null ? contractEndString.substring(0, 10) : null;


       // System.debug('# paymentPickList ->' + paymentPickList ); 
       // System.debug('# collateralPickList ->' + collateralPickList ); 
       // System.debug('# 담보제공 날짜 ->' + collateralPeriod ); 
       // System.debug('# 채권 날짜 ->' + contractPaymentDate ); 
       // System.debug('# 담보종류 ->' + selectedCollateral ); 
       // System.debug('# 결제수단 ->' + selectedPayment ); 


        // 2. 거래처 현황 account info 값을 참고로 IncomeExpensesInfo 에 담아주기 : IncomeExpensesInfo 필드에 값이 있는지 먼저 체크 > 값이 없으면 accountInfo 에서 값 땡겨옴
        // 거래처명 (text)
        if( IncomeExpensesInfo.ClientCompanyName__c == '' || IncomeExpensesInfo.ClientCompanyName__c == null ){
            System.debug('1 > ' + IncomeExpensesInfo.ClientCompanyName__c );
            IncomeExpensesInfo.put('ClientCompanyName__c', accountInfo.get('Name') );
        }
        // 대표자명 (text)
        if(IncomeExpensesInfo.RepresentativeName__c == '' || IncomeExpensesInfo.RepresentativeName__c == null ){
            IncomeExpensesInfo.put('RepresentativeName__c', accountInfo.get('RepresentativeName__c') );
        }
        // 경로 
        if(IncomeExpensesInfo.BusinessPath__c == '' || IncomeExpensesInfo.BusinessPath__c == null ){
            IncomeExpensesInfo.put('BusinessPath__c', accountInfo.get('BusinessPath__c') );
        }
        // System.debug('고객사 정보 > ' + accountInfo);

        // 전체외형 (decimal)
        if(IncomeExpensesInfo.SalesMonthly__c == 0 || IncomeExpensesInfo.SalesMonthly__c == null){
            IncomeExpensesInfo.put('SalesMonthly__c', accountInfo.get('SalesMonthly__c') );
        }

        System.debug('당사규모 확인용 > ' + IncomeExpensesInfo.OurSales__c );
        System.debug('당사규모 정보 확인용 > ' +  accountInfo.get('OurSales__c') );

        // 당사규모 (decimal)
        if(IncomeExpensesInfo.OurSales__c == 0 || IncomeExpensesInfo.OurSales__c == null){
            if(accountInfo.get('OurSales__c') == null){
                IncomeExpensesInfo.put('OurSales__c', 0 );
            }else{
                IncomeExpensesInfo.put('OurSales__c', accountInfo.get('OurSales__c') );

            } 
        }
        // 초도일자 (Account에 정보없음) 

        // 주소 (text)
        if( IncomeExpensesInfo.Address__c == '' || IncomeExpensesInfo.Address__c == null ){
            IncomeExpensesInfo.put('Address__c', accountInfo.get('Address__c') );
        }
        // 연락처 (decimal)
        if(IncomeExpensesInfo.RepresentativePhone__c == '' || IncomeExpensesInfo.RepresentativePhone__c == null ){
            IncomeExpensesInfo.put('RepresentativePhone__c', accountInfo.get('Phone') );
        }
        // 기존납품처 
        if(IncomeExpensesInfo.PV_EXISTSUP__c == '' || IncomeExpensesInfo.PV_EXISTSUP__c == null ){
            IncomeExpensesInfo.put('PV_EXISTSUP__c', accountInfo.get('PV_EXISTSUP__c') );
        }
        // 단가/예외가 (Account에 정보없음) 
        // 센터 (Account에 정보없음) 
        // 3. 거래처 상세내용 

        System.debug('# accountInfo  ->' + accountInfo ); 
        System.debug('# 품의서정보  ->' + IncomeExpensesInfo ); 
    }

    /* 
    CJFW_OrderConsiderNewForm_TEST 용 개발 
    */
    public void getIncomeExpensesTest() {

        System.debug('# ReportFormController # getIncomeExpenses');

        opportunityId = '0060w00000D8uikAAB'; // 테스트용 하드코딩 

        try {
            String query = 'SELECT Id, ' +
            'Version__c, ' +
            'ExpectSales__c, ' +
            'Opportunity__c, ' +
            'ResultExpectSales__c, ' +
            'ResultExpectRate__c, ' +
            'ExpectContributionProfit__c, ' +
            'ExpectContributionProfitRate__c, ' +
            'SupportFeeRate__c, ' +
            'ExpectSalesProfit__c, ' +
            'ExpectSalesProfitRate__c, ' +
            'CollateralAmount__c, ' +
            'CollateralType__c, ' +
            'ExpectProfit__c, ' +
            'CollateralPeriod__c, ' +
            'CreditLoanAmount__c, ' +
            'ContractDepreciationSupport__c, ' +
            'SalesFeeSupport__c, ' +
            'DonationSupport__c, ' +
            'OtherSupport__c, ' +
            'PaymentMethod__c, ' +
            'ContractPaymentDate__c, ' +
            'ChefSupportCnt__c, ' +
            'FarmSupportExpect__c, ' +
            'MarineSupportExpect__c, ' +
            'LivestockSupportExpect__c, ' +
            'ManufactureSupportExpect__c, ' +
            'NonFoodSupportExpect__c, ' +
            'SalesSupportExpect__c, ' +
            'IsReportCheck__c, ' +
            'ContractDepreciationRate__c, ' +
            'Summary__c, ' +
            'ContractStartDate__c, ' +
            'ContractEndDate__c, ' +
            'ContractType__c, ' +
            'ClientCompanyName__c, ' + // 거래처현황 관련 필드 추가 
            'RepresentativeName__c, ' +  
            'BusinessPath__c, ' +  
            'SalesMonthly__c, ' +  
            'OurSales__c, ' +  
            'Address__c, ' +  
            'RepresentativePhone__c, ' +  
            'PV_EXISTSUP__c, ' +  
            'ExceptionPrice__c, ' +  
            'Center__c, ' +  
            'IncentiveSupport__c, ' +
            'ImprovementPlanDetails__c, ' +
            'OtherSupportDetail__c, ' + // 기타 지원세부 내역
            'AttachedDocument__c, ' + // 첨부서류
            'OpptyDescription__c, ' + // 특이사항

            'SalesCapitalExclusive__c, ' + // 외식전용 필드 ↓ :매출 수도권 전용
            'SalesCapitalGeneral__c, ' + // 매출 수도권 일반
            'SalesEastExclusive__c, ' + // 매출 동부권 전용
            'SalesEastGeneral__c, ' + // 매출 동부권 일반
            'SalesWestExclusive__c, ' + // 매출 서부권 전용
            'SalesWestGeneral__c, ' + // 매출 서부권 일반 
            'SalesJejuExclusive__c, ' + // 매출 제주권 전용 
            'SalesJejuGeneral__c, ' + // 매출 제주권 일반 
            'SalesSolutionExclusive__c, ' + // 매출 솔루션 전용 
            'SalesSolutionGeneral__c, ' + // 매출 솔루션 전용 
            'SalesImproveResultExclusive__c, ' + // 매출 개선실적 전용
            'SalesImproveResultGeneral__c, ' + // 매출 개선실적 전용

            'SalesProfitCaptialExclusive__c, ' + // 매출이익 수도권 전용
            'SalesProfitCapitalGeneral__c, ' + // 매출이익 수도권 일반
            'SalesProfitEastExclusive__c, ' + // 매출이익 동부권 전용
            'SalesProfitEastGeneral__c, ' + // 매출이익 동부권 일반
            'SalesProfitWestExclusive__c, ' + // 매출이익 서부권 전용
            'SalesProfitWestGeneral__c, ' + // 매출이익 서부권 일반
            'SalesProfitJejuExclusive__c, ' + // 매출이익 제주권 전용
            'SalesProfitJejuGeneral__c, ' + // 매출이익 제주권 일반


            'ProfitRateCapitalExclusive__c, ' + // 매익률 수도권 전용
            'ProfitRateEastExclusive__c, ' + // 매익률 동부권 전용
            'ProfitRateWestExclusive__c, ' + // 매익률 서부권 전용
            'ProfitRateJejuExclusive__c, ' + // 매익률 제주권 전용
            'ProfitRateCapitalGeneral__c, ' + // 매익률 수도권 일반
            'ProfitRateEastGeneral__c, ' + // 매익률 동부권 일반
            'ProfitRateWestGeneral__c, ' + // 매익률 서부권 일반
            'ProfitRateJejuGeneral__c, ' + // 매익률 제주권 일반
            'ProfitRateExclusive__c, ' + // 전용매익률
            'ProfitRateGeneral__c, ' + // 전용매익률 (지급후)

            'SalesLocationCntCapital__c, ' + // 매익률 수도권 판매처수
            'SalesLocationCntEast__c, ' + // 매익률 동부권 판매처수
            'SalesLocationCntWest__c, ' + // 매익률 서부권 판매처수
            'SalesLocationCntJeju__c, ' + // 매익률 제주권 판매처수

            'SalesPerStoreCapital__c, ' + // 매익률 수도권 점당매출
            'SalesPerStoreEast__c, ' + // 매익률 동부권 점당매출
            'SalesPerStoreWest__c, ' + // 매익률 서부권 점당매출
            'SalesPerStoreJeju__c, ' + // 매익률 제주권 점당매출

            'DropSizeCapital__c, ' + // 매익률 수도권 DROP-SIZE
            'DropSizeEast__c, ' + // 매익률 동부권 DROP-SIZE
            'DropSizeWest__c, ' + // 매익률 서부권 DROP-SIZE
            'DropSizeJeju__c, ' + // 매익률 제주권 DROP-SIZE

            //'SalesProfitCaptialExclusive__c, ' + // 매익이익(수수료지급후) 수도권
            //'SalesProfitEastExclusive__c, ' + // 매익이익(수수료지급후) 동부권
            //'SalesProfitWestExclusive__c, ' + // 매익이익(수수료지급후) 서부권
            //'SalesProfitJejuExclusive__c, ' + // 매익이익(수수료지급후) 제주권

            'DeliveryCnt__c, ' + // 배송횟수


            'InitialDate__c ' + // 초도일자
            'FROM CJFW_ExpectedIncomeExpenses__c';

            if (incomeExpensesId != null) {
                query += ' WHERE id = :incomeExpensesId ';
            }else if (opportunityId != null) {
                query += ' WHERE Opportunity__c = :opportunityId ';
            }

            if(showtable =='true'){
                query += ' ORDER BY IsReportCheck__c DESC LIMIT 1';
            }else{
                query += ' ORDER BY Version__c DESC LIMIT 1';
            }


            // query += ' ORDER BY Version__c DESC LIMIT 1';

            System.debug('# query ->' + query );
            List<CJFW_ExpectedIncomeExpenses__c> incomeExpensesList = Database.query(query);

            if (!incomeExpensesList.isEmpty()) {
                IncomeExpensesInfo = incomeExpensesList[0];
                versionCheck = ( incomeExpensesList[0].Version__c ) + 1 ;
                reportCheck = ( incomeExpensesList[0].IsReportCheck__c );
            } else {
                versionCheck = 1;
                IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c();
            }

        }catch (QueryException e) {
            IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c(); // 빈 레코드로 초기화
        }

        System.debug('IncomeExpensesInfo '+ IncomeExpensesInfo);

        //값이 없어도 ↓ 추가하면 디폴트값 세팅가능 
        String[] defaultValSet = new String[] {
            'ContractDepreciationSupport__c',
            'IncentiveSupport__c',
            'SalesFeeSupport__c',
            'DonationSupport__c',
            'OtherSupport__c',
            'ChefSupportCnt__c',
            'FarmSupportExpect__c',
            'MarineSupportExpect__c',
            'LivestockSupportExpect__c',
            'ManufactureSupportExpect__c',
            'NonFoodSupportExpect__c',
            'SalesSupportExpect__c',
            'CollateralAmount__c',
            'CreditLoanAmount__c',
            'SalesCapitalExclusive__c', // 외식 매출 전용 
            'SalesEastExclusive__c',
            'SalesWestExclusive__c',
            'SalesJejuExclusive__c',
            'SalesCapitalGeneral__c', // 외식 매출 일반
            'SalesEastGeneral__c', 
            'SalesWestGeneral__c', 
            'SalesSolutionExclusive__c', 
            'SalesSolutionGeneral__c', 
            'SalesImproveResultExclusive__c', 
            'SalesImproveResultGeneral__c', 
            'SalesProfitCaptialExclusive__c', 
            'SalesProfitEastExclusive__c', 
            'SalesProfitWestExclusive__c', 
            'SalesProfitJejuExclusive__c', 
            'SalesProfitCapitalGeneral__c', 
            'SalesProfitEastGeneral__c', 
            'SalesProfitWestGeneral__c', 
            'SalesProfitJejuGeneral__c', 
            'ProfitRateCapitalExclusive__c', 
            'ProfitRateEastExclusive__c', 
            'ProfitRateWestExclusive__c', 
            'ProfitRateJejuExclusive__c', 
            'ProfitRateCapitalGeneral__c', 
            'ProfitRateEastGeneral__c', 
            'ProfitRateWestGeneral__c', 
            'ProfitRateJejuGeneral__c', 
            'SalesLocationCntCapital__c',  
            'SalesLocationCntEast__c', 
            'SalesLocationCntWest__c',  
            'SalesLocationCntJeju__c',  
            'SalesPerStoreCapital__c',  // 점당매출 
            'SalesPerStoreEast__c',  
            'SalesPerStoreWest__c',  
            'SalesPerStoreJeju__c',  
            'DropSizeCapital__c',  // Drop-Size
            'DropSizeEast__c',  
            'DropSizeWest__c',  
            'DropSizeJeju__c',  
            'ProfitRateExclusive__c',  //전용 매익률
            'ProfitRateGeneral__c',  //전용 매익률(지급후)
            'SalesJejuGeneral__c' 
        };

        for (String defaultSet : defaultValSet) {
            Object fieldValue = IncomeExpensesInfo.get(defaultSet);

            if (fieldValue == null) fieldValue = 0.00; 
            IncomeExpensesInfo.put(defaultSet, fieldValue);
        }

        selectedCollateral = IncomeExpensesInfo.CollateralType__c; // 담보종류
        selectedPayment = IncomeExpensesInfo.PaymentMethod__c; // 결제수단 
        selectedContract = IncomeExpensesInfo.ContractType__c	; // 계약서종류 
        selectedDelivery = IncomeExpensesInfo.DeliveryCnt__c	; // 배송횟수

        // ContractPaymentDate__c 필드를 yyyy-MM-dd 형식의 문자열로 변환
        String collateralPeriodString = String.valueOf(IncomeExpensesInfo.collateralPeriod__c);
        String contractPaymentDateString = String.valueOf(IncomeExpensesInfo.contractPaymentDate__c); 
        String initialDateString = String.valueOf(IncomeExpensesInfo.InitialDate__c); // 초도일자 
        String contractStartString = String.valueOf(IncomeExpensesInfo.ContractStartDate__c); // 계약시작일자
        String contractEndString = String.valueOf(IncomeExpensesInfo.ContractEndDate__c); // 계약종료일자 

        collateralPeriod = collateralPeriodString != null ? collateralPeriodString.substring(0, 10) : null;
        contractPaymentDate = contractPaymentDateString != null ? contractPaymentDateString.substring(0, 10) : null;
        initialDate = initialDateString != null ? initialDateString.substring(0, 10) : null;
        contractStartDate = contractStartString != null ? contractStartString.substring(0, 10) : null;
        contractEndDate = contractEndString != null ? contractEndString.substring(0, 10) : null;

        system.debug('IncomeExpensesInfo >>> ' + IncomeExpensesInfo);
    }

    /* 
    CJFW_OrderConsiderNewForm_TEST 용 개발 : 물류비 가져오기 
     */
    public void getDistributeCostTest() {
        System.debug('# ReportFormController # getDistributeCostTest ');

        try{

            List<CJFW_DistributionCost__c> DistributeCostList  = [
                SELECT Id, 
                    Name,
                    StartDate__c,  
                    Region__c, 
                    Type__c, 
                    Cost__c, 
                    HeadOffice__c, 
                    SU__c 
                FROM CJFW_DistributionCost__c WHERE StartDate__c <= TODAY AND HeadOffice__c ='외식SU' ];

            system.debug('DistributeCost 외식용 -> ' +  DistributeCostList );

            // 본부별 최대 8개까지 존재가능한 물류비값을 각각 담아주기 
            for(CJFW_DistributionCost__c record : DistributeCostList){

                if(record.Region__c =='수도권' && record.Type__c  =='직접'){ // Distribute list 안에 CapDirect로 담아주고 싶어 
                    DistributeDirCap = record.Cost__c;
                }else if(record.Region__c =='수도권' && record.Type__c  =='간접'){
                    DistributeInDirCap = record.Cost__c;
                }else if(record.Region__c =='동부권' && record.Type__c  =='직접'){
                    DistributeDirEast = record.Cost__c;
                }else if(record.Region__c =='동부권' && record.Type__c  =='간접'){
                    DistributeInDirEast = record.Cost__c;
                }else if(record.Region__c =='서부권' && record.Type__c  =='직접'){
                    DistributeDirWest = record.Cost__c;
                }else if(record.Region__c =='서부권' && record.Type__c  =='간접'){
                    DistributeInDirWest = record.Cost__c;
                }else if(record.Region__c =='제주권' && record.Type__c  =='직접'){
                    DistributeDirJeju = record.Cost__c;
                }else if(record.Region__c =='제주권' && record.Type__c  =='간접'){
                    DistributeInDirJeju = record.Cost__c;
                }
            }

        }catch(Exception e){
            String errorMessage = e.getMessage();
            String errorStackTrace = e.getStackTraceString(); 
            System.debug('에러 메시지: ' + errorMessage);
            System.debug('에러 라인: ' + errorStackTrace);
        }

    }


    /* 
    예산손익관리(CJFW_ExpectedIncomeManager__c) 에서 값 가져오기
    적용시작일 기준으로 값 가져와야함 
    */
    public void getExpectManager() {
        System.debug('# ReportFormController # getExpectManager');

        IncomeManager = [
        SELECT Id, 
               Name,
               CurrencyIsoCode,  
               DistributionCost__c, 
               LaborCost__c, 
               GroupCommonCost__c, 
               GroupCommonCostExclusive__c, 
               GroupCommonCostGeneral__c, 
               PromotionFee__c, 
               CardFee__c, 
               CollateralFee__c, 
               ChefFee__c, 
               OtherFee__c, 
               SupportFee__c, 
               StartDate__c, 
               HeadOffice__c, 
               SU__c, 
               Source__c 
        FROM CJFW_ExpectedIncomeManager__c WHERE StartDate__c <= TODAY LIMIT 1];

        String[] defaultValSet = new String[] {
            'DistributionCost__c',
            'LaborCost__c',
            'GroupCommonCost__c',
            'GroupCommonCostExclusive__c',
            'GroupCommonCostGeneral__c',
            'PromotionFee__c',
            'CardFee__c',
            'CollateralFee__c',
            'ChefFee__c',
            'OtherFee__c',
            'SupportFee__c'
        };

        for (String defaultSet : defaultValSet) {
            Object fieldValue = IncomeManager.get(defaultSet);
            // 필드 값이 null이면 기본값을 0.00 으로 설정
            if (fieldValue == null)  fieldValue = 0.00; 
            IncomeManager.put(defaultSet, fieldValue);
        }

    }

    /* 
    물류비관리(CJFW_DistributionCost__c) 에서 값 가져오기 
     */
    public void getDistributeCost() {
        System.debug('# ReportFormController # getDistributeCost');

        DistributeCost = [
            SELECT Id, 
                   Name,
                   StartDate__c,  
                   Region__c, 
                   Type__c, 
                   Cost__c, 
                   HeadOffice__c, 
                   SU__c 
            FROM CJFW_DistributionCost__c WHERE StartDate__c <= TODAY];

        String[] defaultValSet = new String[] {
            'Cost__c'
        };

        for (String defaultSet : defaultValSet) {
            Object fieldValue = DistributeCost.get(defaultSet);
            // 필드 값이 null이면 기본값을 0 으로 설정
            if (fieldValue == null)  fieldValue = 0.00; 
            DistributeCost.put(defaultSet, fieldValue);
        }

        system.debug('DistributeCost' +  DistributeCost);

    }


    /* 
    CJFW_NewOpenReport_ProfitReview (VF Page) 에서 입력받은 값 update   
    */
    @RemoteAction
    public static String saveIncomeExpenses(String DataList, String opportunityId, Decimal versionCheck, String incomeExpensesId) {
        System.debug('데이터 save !!!');
        try {
            System.debug('DataList ' + DataList);
            System.debug('opportunityId ' + opportunityId);
            System.debug('versionCheck ' + versionCheck);
            System.debug('incomeExpensesId ' + incomeExpensesId);
            
            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(DataList);
            System.debug('넘어온 데이터! ' + dataMap);
            
            CJFW_ExpectedIncomeExpenses__c expectIncome;

            if (incomeExpensesId != null && incomeExpensesId != '') {
                System.debug('update ★-> ' + incomeExpensesId);
                expectIncome = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c WHERE Id = :incomeExpensesId];
            } else { // insert 
                System.debug('insert ★-> ');
                expectIncome = new CJFW_ExpectedIncomeExpenses__c();
                expectIncome.Version__c = versionCheck; // 필수값
                expectIncome.Opportunity__c = opportunityId; // 필수값
                if(versionCheck == 1) expectIncome.IsReportCheck__c = true; // 초기 insert 시에 품의지정 default 세팅
            }
            expectIncome.saveResult__c = DataList;

            expectIncome.CollateralType__c = (String)dataMap.get('detail-collateral-kind') != null ? (String)dataMap.get('detail-collateral-kind') : ''; // 담보제공 종류
            expectIncome.PaymentMethod__c = (String)dataMap.get('payment-picklist') != null ? (String)dataMap.get('payment-picklist') : ''; // 결제수단 종류

            expectIncome.CreditLoanAmount__c = convertToDecimal(dataMap.get('detail-creditLoan-amount')); // 신용여신금액 

            expectIncome.ContractDepreciationSupport__c = convertToDecimal(dataMap.get('detail-deprec-amount'));
            expectIncome.IncentiveSupport__c = convertToDecimal(dataMap.get('detail-incentive-amount'));
            expectIncome.SalesFeeSupport__c = convertToDecimal(dataMap.get('detail-fee-amount'));
            expectIncome.DonationSupport__c = convertToDecimal(dataMap.get('detail-donation-amount'));
            expectIncome.OtherSupport__c = convertToDecimal(dataMap.get('detail-other-amount'));

            expectIncome.FarmSupportExpect__c = convertToDecimal(dataMap.get('farm-before'));  //농산 지원 월예상 
            expectIncome.MarineSupportExpect__c = convertToDecimal(dataMap.get('marin-before')); //수산 지원 월예상
            expectIncome.LivestockSupportExpect__c = convertToDecimal(dataMap.get('livestock-before')); // 축산 지원 월예상
            expectIncome.ManufactureSupportExpect__c = convertToDecimal(dataMap.get('manufacture-before')); // 가공식품 지원 월예상
            expectIncome.NonFoodSupportExpect__c = convertToDecimal(dataMap.get('nonfood-before')); // 비식품 지원 월예상

            expectIncome.SalesSupportExpect__c = convertToDecimal(dataMap.get('sales-support')); // 매출이익률
            expectIncome.CollateralAmount__c = convertToDecimal(dataMap.get('detail-collateral-amount')); // 담보제공금액 

            expectIncome.ChefSupportCnt__c = convertToDecimal(dataMap.get('chef-support')); // 쉐프지원 

            String collateralPeriod = (String)dataMap.get('collateral-period');
            String contractPeriod = (String)dataMap.get('contract-payment-period');

            // 거래처 화면에서 받아온 데이터 예상손익 object 에 저장 
            // expectIncome.ClientCompanyName__c = dataMap.containsKey('accountName') ? (String) dataMap.get('accountName') : expectIncome.ClientCompanyName__c;
            // expectIncome.RepresentativeName__c = dataMap.containsKey('ownerName') ? (String) dataMap.get('ownerName') : expectIncome.RepresentativeName__c;
            // expectIncome.BusinessPath__c = dataMap.containsKey('accountChannel') ? (String) dataMap.get('accountChannel') : expectIncome.BusinessPath__c;
            
            // 개요
            if (dataMap.containsKey('summary')) { 
                expectIncome.Summary__c = (String) dataMap.get('summary');
            }
            // 저장 
            if (dataMap.containsKey('accountName')) { // 거래처명 (text)
                expectIncome.ClientCompanyName__c = (String) dataMap.get('accountName');
            }
            if (dataMap.containsKey('ownerName')) { // 대표자명 (text)
                expectIncome.RepresentativeName__c = (String) dataMap.get('ownerName');
            }
            if (dataMap.containsKey('accountChannel')) { // 경로 (text)
                expectIncome.BusinessPath__c = (String) dataMap.get('accountChannel');
            }
            if (dataMap.containsKey('outwardEntire')) { // 전체외형 (정수)
                expectIncome.SalesMonthly__c = convertToDecimal(dataMap.get('outwardEntire'));
            }
            if (dataMap.containsKey('outwardCompanySize')) { // 당사규모 (decimal)
                expectIncome.OurSales__c = convertToDecimal(dataMap.get('outwardCompanySize'));
            }
            //System.debug('초도일자' + dataMap.get('firstDraft') ); 
            if (dataMap.containsKey('firstDraft') && dataMap.get('firstDraft') !='') { // 초도일자 (date)
                expectIncome.InitialDate__c = Date.valueOf(((String) dataMap.get('firstDraft')));
            }
            if (dataMap.containsKey('accountAddress')) { // 주소 (text)
                expectIncome.Address__c = (String) dataMap.get('accountAddress');
            }
            if (dataMap.containsKey('accountPhone')) { // 연락처 (phone)
                expectIncome.RepresentativePhone__c = (String)dataMap.get('accountPhone');
            }
            if (dataMap.containsKey('existGoods')) { // 기존납품처 (text)
                expectIncome.PV_EXISTSUP__c = (String) dataMap.get('existGoods');
            }
            // System.debug('단가/예외가' + dataMap.get('exceptionPrice') );
            if (dataMap.containsKey('exceptionPrice') && dataMap.get('exceptionPrice') !='') { // 단가/예외가 (decimal)
                expectIncome.ExceptionPrice__c = convertToDecimal(dataMap.get('exceptionPrice')) ;
            }
            if (dataMap.containsKey('existCenter')) { // 센터
                expectIncome.Center__c = (String)dataMap.get('existCenter') ;
            }

            if (dataMap.containsKey('otherDetail')) { // 기타 세부 내역
                expectIncome.OtherSupportDetail__c = (String)dataMap.get('otherDetail') ;
            }
            if (dataMap.containsKey('ImproveDetail')) { // 개선방안내역
                expectIncome.ImprovementPlanDetails__c = (String)dataMap.get('ImproveDetail') ;
            }
            if (dataMap.containsKey('Description')) { // 특이사항
                expectIncome.OpptyDescription__c = (String)dataMap.get('Description') ;
            }
            if (dataMap.containsKey('attachDoc')) { // 첨부파일
                expectIncome.AttachedDocument__c = (String)dataMap.get('attachDoc') ;
            }

            if (dataMap.containsKey('contract-payment-period') && dataMap.get('contract-payment-period') !='') { // 약정결제일
                expectIncome.ContractPaymentDate__c = Date.valueOf(((String) dataMap.get('contract-payment-period')));
            }
            
            if (dataMap.containsKey('collateral-period') && dataMap.get('collateral-period') !='') { // 담보제공기간
                expectIncome.CollateralPeriod__c = Date.valueOf(((String) dataMap.get('collateral-period')));
            }
            
            
            //expectIncome.BusinessPath__c = (String)dataMap.get('accountChannel');
            //expectIncome.SalesMonthly__c = convertToDecimal(dataMap.get('outwardEntire'));
            //expectIncome.OurSales__c = convertToDecimal(dataMap.get('outwardCompanySize'));
            //expectIncome.InitialDate__c = convertToDecimal(dataMap.get('firstDraft'));
            //expectIncome.Address__c = (String)dataMap.get('accountAddress');
            //expectIncome.RepresentativePhone__c = (String)dataMap.get('accountPhone');
            //expectIncome.PV_EXISTSUP__c = (String)dataMap.get('existGoods');
            //expectIncome.ExceptionPrice__c = convertToDecimal(dataMap.get('exceptionPrice'));
            //expectIncome.Center__c = (String)dataMap.get('existCenter');

            //if(collateralPeriod <> null && contractPeriod <> '') {
            //    Date collateralPeriodDate = Date.valueOf(collateralPeriod); // 담보제공기간
            //    expectIncome.CollateralPeriod__c = collateralPeriodDate;
            //}

            //if(contractPeriod <> null && contractPeriod <> '') {
            //    Date contractPeriodDate = Date.valueOf(contractPeriod); // 약정결제일
            //    expectIncome.ContractPaymentDate__c = contractPeriodDate;
            //}
            
            upsert expectIncome;
            return 'success';
        } catch (Exception e) {

            String errorMessage = e.getMessage();
            String errorStackTrace = e.getStackTraceString(); 
            System.debug('에러 메시지: ' + errorMessage);
            System.debug('에러 라인: ' + errorStackTrace);

            return 'error';
        }
    }

    /* 
    품의지정 버튼 클릭시 , 품의지정 check 
    : 기존 품의지정된 내역은 삭제 후 신규 품의지정된 1개만 품의체크
    */
    @RemoteAction
    public static String ReportCheck(String incomeExpensesId , String opportunityId ){

        try{
            //CJFW_ExpectedIncomeExpenses__c RemoveList = [SELECT Id, IsReportCheck__c FROM CJFW_ExpectedIncomeExpenses__c WHERE Opportunity__c =: opportunityId AND Id != :incomeExpensesId];
            List<CJFW_ExpectedIncomeExpenses__c> RemoveList = [SELECT Id, IsReportCheck__c FROM CJFW_ExpectedIncomeExpenses__c WHERE Opportunity__c = :opportunityId AND Id != :incomeExpensesId];
            CJFW_ExpectedIncomeExpenses__c checkList = [SELECT Id, IsReportCheck__c FROM CJFW_ExpectedIncomeExpenses__c WHERE  Id = :incomeExpensesId];

            if(RemoveList <> null ){
                for(CJFW_ExpectedIncomeExpenses__c data : RemoveList) {
                    data.IsReportCheck__c = false;
                }
                update RemoveList;
            }

            if(checkList <> null){
                checkList.IsReportCheck__c =true;
                System.debug(' checkList ' + checkList );
                update checkList;
            }

            return 'success';

        }catch (Exception e) {

            String errorMessage = e.getMessage(); // 에러 메시지
            String errorStackTrace = e.getStackTraceString(); // 에러 스택 트레이스

            System.debug('에러 메시지: ' + errorMessage);
            System.debug('에러 라인: ' + errorStackTrace);
            return 'error';
        }
    }


    /* 
    Decimal 값으로 변환하기위해 사용되는 메소드
    */
    public static Decimal convertToDecimal(Object objValue) {  
        Decimal decimalValue = 0.0; // 기본값 설정
    
        if (objValue != null || objValue != '') {
            if (objValue instanceof Decimal) {
                decimalValue = (Decimal)objValue;
            } else if (objValue instanceof String) {
                // 문자열로 된 값을 Decimal로 변환
                decimalValue = Decimal.valueOf((String)objValue);
            }
        }
    
        return decimalValue;
    }

}