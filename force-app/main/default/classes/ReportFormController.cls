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
 * @last modified on  : 10-05-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-24-2023   eunyoung.choi@dkbmc.com   Initial Version 작성
**/
public with sharing class ReportFormController {
    // public static Decimal versionCheck;
    public static String SaveDataList;

    public String opportunityId { get; set; }
    public String incomeExpensesId { get; set;} // 예상손익 id
    public Decimal versionCheck { get; set; }
    public Boolean reportCheck { get; set; }
    public String showtable { get; set; }

    public String fieldValue { get; private set; }

    /* 계산값 가져오기 */
    public CJFW_ExpectedIncomeExpenses__c IncomeExpensesInfo {get;set;} //예상손익 
    public CJFW_ExpectedIncomeManager__c IncomeManager {get;set;} // 예상손익관리 

    public String accountName { get; set; }
    public String savedAccountName { get; set; }

    /* picklist 값 가져오기 위한 선언 */
    public String selectedCollateral { get; set; }
    public String selectedPayment { get; set; }

    /* picklist */
    public List<SelectOption> paymentPickList { get; set; }    // 결제수단종류 
    public List<SelectOption> collateralPickList { get; set; } // 담보제공종류

    /* 계산로직 test */
/*     public Decimal input1 { get; set; }
    public Decimal input2 { get; set; }
    public Decimal result { get; set; } */

    /* 날짜형식변환 */
    public String collateralPeriod { get; set; } // 담보 제공 기간
    public String contractPaymentDate { get; set; } // 약정결제일

/*     public void saveAccount() {
        savedAccountName = accountName;
    } */

/*     public void multiply() {
        result = input1 * input2;
    } */

/*     public void passValueToController(){
        fieldValue = selectedPayment;
        system.debug('fieldValue' + fieldValue);
    } */
    

    /* 
    컨트롤러가 호출되면 돌아가는 부분 
    */
    public ReportFormController() {
        getPicklistValues(); 
        getIncomeExpenses(); // oppty 값 담아주는 메소드 
        getExpectManager();
    }


    /* 
    Picklist 값을 가져오는 메소드
    */
    public void getPicklistValues() {

       Schema.DescribeFieldResult collateralResult = CJFW_ExpectedIncomeExpenses__c.CollateralType__c.getDescribe();
       Schema.DescribeFieldResult paymentPick = CJFW_ExpectedIncomeExpenses__c.PaymentMethod__c.getDescribe(); // 추가 
       
       List<Schema.PicklistEntry> collateralValues = collateralResult.getPicklistValues();
       List<Schema.PicklistEntry> paymentValues = paymentPick.getPicklistValues();

       collateralPickList = new List<SelectOption>();
       paymentPickList = new List<SelectOption>();

        for (Schema.PicklistEntry picklistValue : collateralValues) {
            collateralPickList.add(new SelectOption(picklistValue.getLabel(), picklistValue.getValue()));
        }

        for (Schema.PicklistEntry picklistValue : paymentValues) {
            paymentPickList.add(new SelectOption(picklistValue.getLabel(), picklistValue.getValue()));
        }

    }

    /* 
    예산손익 : CJFW_ExpectedIncomeExpenses__c 에서 값 가져오기
    VF Page 초기호출시  
    */
    public void getIncomeExpenses() {

        System.debug('# ReportFormController # getIncomeExpenses');
        
        opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
        incomeExpensesId = ApexPages.currentPage().getParameters().get('incomeExpensesId');
        showtable = ApexPages.currentPage().getParameters().get('showtable');

        System.debug('# opportunityId ->' + opportunityId );
        System.debug('# incomeExpensesId ->' + incomeExpensesId );
        System.debug('# showtable ->' + showtable );

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
            'IncentiveSupport__c ' +
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
                System.debug('버전 up ! '+ versionCheck);
                reportCheck = ( incomeExpensesList[0].IsReportCheck__c );
                System.debug(' 품의지정 체크 '+ reportCheck);
                
            } else {
                versionCheck = 1;
                System.debug('버전2 ! '+ versionCheck );
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

        for (String fieldName : defaultValSet) {
            Object fieldValue = IncomeExpensesInfo.get(fieldName);
            
            if (fieldValue == null) fieldValue = 0.0; 
            IncomeExpensesInfo.put(fieldName, fieldValue);

            //System.debug(' 예상손익 : ' + fieldName + ': ' + fieldValue);
        }

        // ContractPaymentDate__c 필드를 yyyy-MM-dd 형식의 문자열로 변환
        String collateralPeriodString = String.valueOf(IncomeExpensesInfo.collateralPeriod__c);
        String contractPaymentDateString = String.valueOf(IncomeExpensesInfo.contractPaymentDate__c); 

        collateralPeriod = collateralPeriodString != null ? collateralPeriodString.substring(0, 10) : null;
        contractPaymentDate = contractPaymentDateString != null ? contractPaymentDateString.substring(0, 10) : null;

        selectedCollateral = IncomeExpensesInfo.CollateralType__c; // 담보종류
        selectedPayment = IncomeExpensesInfo.PaymentMethod__c; // 결제수단 

        System.debug('# paymentPickList ->' + paymentPickList ); 
        System.debug('# collateralPickList ->' + collateralPickList ); 
        System.debug('# 담보제공 날짜 ->' + collateralPeriod ); 
        System.debug('# 채권 날짜 ->' + contractPaymentDate ); 
        
        System.debug('# 담보종류 ->' + selectedCollateral ); 
        System.debug('# 결제수단 ->' + selectedPayment ); 
    }


    /* 
    예산손익관리 : CJFW_ExpectedIncomeManager__c 에서 값 가져오기
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
               CardFee__c, 
               CollateralFee__c, 
               ChefFee__c, 
               OtherFee__c, 
               SupportFee__c, 
               StartDate__c, 
               HeadOffice__c, 
               SU__c, 
               Source__c 
        FROM CJFW_ExpectedIncomeManager__c WHERE StartDate__c <= TODAY ];

        String[] defaultValSet = new String[] {
            'DistributionCost__c',
            'LaborCost__c',
            'GroupCommonCost__c',
            'CardFee__c',
            'CollateralFee__c',
            'ChefFee__c',
            'OtherFee__c',
            'SupportFee__c'
        };

        for (String fieldName : defaultValSet) {
            Object fieldValue = IncomeManager.get(fieldName);
            
            // 필드 값이 null이면 기본값을 0 으로 설정
            if (fieldValue == null)  fieldValue = 0; 
            IncomeManager.put(fieldName, fieldValue);
            
            // System.debug(' 예상손익관리 : ' + fieldName + ': ' + fieldValue);
        }

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
            System.debug(' collateralPeriod-> ' + collateralPeriod);
            System.debug(' contractPeriod-> ' + contractPeriod);
            if(collateralPeriod <> null && contractPeriod <> '') {
                Date collateralPeriodDate = Date.valueOf(collateralPeriod); // 담보제공기간
                expectIncome.CollateralPeriod__c = collateralPeriodDate;
                System.debug(' 담보제공일자 1 -> ' + collateralPeriodDate);
            }
            if(contractPeriod <> null && contractPeriod <> '') {
                Date contractPeriodDate = Date.valueOf(contractPeriod); // 약정결제일
                expectIncome.ContractPaymentDate__c = contractPeriodDate;
                System.debug(' 담보제공일자 2 -> ' + contractPeriodDate);
            }
            
           // Date collateralPeriodDate = Date.valueOf((String)dataMap.get('collateral-period')); // 담보제공기간
           // Date contractPeriodDate = Date.valueOf((String)dataMap.get('contract-payment-period')); // 약정결제일
            // System.debug(' 담보제공일자 1 -> ' + Date.valueOf((String)dataMap.get('collateral-period')) );
            // System.debug(' 담보제공일자 2 -> ' + Date.valueOf((String)dataMap.get('contract-payment-period')) );

            //if(collateralPeriodDate <> null ){
            //    System.debug(' 담보제공일자  -> ' + collateralPeriodDate);
            //    expectIncome.CollateralPeriod__c = collateralPeriodDate;
            //} 
            //if(contractPeriodDate <> null ) {
            //    System.debug(' 약정결제일자  -> ' + collateralPeriodDate);
            //    expectIncome.ContractPaymentDate__c = contractPeriodDate;
            //}

            upsert expectIncome;
            return 'success';
        } catch (Exception e) {
            String errorMessage = e.getMessage(); // 에러 메시지
            String errorStackTrace = e.getStackTraceString(); // 에러 스택 트레이스

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
        System.debug(' ReportCheck ');
        System.debug(' incomeExpensesId =>  ' + incomeExpensesId + ' oppty =>' + opportunityId );
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
    
        if (objValue != null) {
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