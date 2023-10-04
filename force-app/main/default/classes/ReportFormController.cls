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
 * @last modified on  : 10-04-2023
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
    public String showtable { get; set; }


    public String fieldValue { get; private set; }

    /* 계산값 가져오기 */
    public Account accountInfo {get;set;}
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
    public Decimal input1 { get; set; }
    public Decimal input2 { get; set; }
    public Decimal result { get; set; }

    /* 날짜형식변환 */
    public String CollateralPeriod { get; set; } // 담보 제공 기간
    public String ContractPaymentDate { get; set; } // 약정결제일

    public void saveAccount() {
        savedAccountName = accountName;
    }

    public void multiply() {
        result = input1 * input2;
    }

    public void passValueToController(){
        fieldValue = selectedPayment;
        system.debug('fieldValue' + fieldValue);
    }
    

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

       // System.debug('# paymentPickList ->' + paymentPickList );
       // System.debug('# collateralPickList ->' + collateralPickList );

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

            List<CJFW_ExpectedIncomeExpenses__c> incomeExpensesList = [
            SELECT Id,
                Version__c,
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
            // WHERE id ='a1l0w000001Ma13AAC'  //예상손익 id
            //   WHERE Opportunity__c = '0060w00000D8uikAAB' // 예상손익 매핑o
            WHERE Opportunity__c =: opportunityId 
            ORDER BY Version__c DESC LIMIT 1
            ];  

            if (!incomeExpensesList.isEmpty()) {
                IncomeExpensesInfo = incomeExpensesList[0];
                versionCheck = ( incomeExpensesList[0].Version__c ) + 1 ;
                System.debug('버전 up ! '+ versionCheck);
                
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
            'ContractDepreciationRate__c',
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

            // System.debug(' 예상손익 : ' + fieldName + ': ' + fieldValue);
        }

        // ContractPaymentDate__c 필드를 yyyy-MM-dd 형식의 문자열로 변환
        String ContractPaymentDateString = String.valueOf(IncomeExpensesInfo.ContractPaymentDate__c); 
        String CollateralPeriodString = String.valueOf(IncomeExpensesInfo.CollateralPeriod__c);

        ContractPaymentDate = ContractPaymentDateString != null ? ContractPaymentDateString.substring(0, 10) : null;
        CollateralPeriod = CollateralPeriodString != null ? CollateralPeriodString.substring(0, 10) : null;


        System.debug('# paymentPickList ->' + paymentPickList ); 
        System.debug('# collateralPickList ->' + collateralPickList ); 
    }
    public void getIncomeExpenses_beta() {

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
            'ContractDepreciationSupport__c ' +
            'SalesFeeSupport__c ' +
            'DonationSupport__c ' +
            'OtherSupport__c ' +
            'PaymentMethod__c ' +
            'ContractPaymentDate__c ' +
            'ChefSupportCnt__c ' +
            'FarmSupportExpect__c ' +
            'MarineSupportExpect__c ' +
            'LivestockSupportExpect__c ' +
            'ManufactureSupportExpect__c ' +
            'NonFoodSupportExpect__c ' +
            'SalesSupportExpect__c ' +
            'IsReportCheck__c ' +
            'IncentiveSupport__c ' +
            'FROM CJFW_ExpectedIncomeExpenses__c';

            if (opportunityId != null) {
                query += ' WHERE Opportunity__c = :opportunityId';
            }else if (incomeExpensesId != null) {
                query += ' WHERE id = :incomeExpensesId';
            }
            query += ' ORDER BY Version__c DESC LIMIT 1';

            System.debug('# query ->' + query );
            List<CJFW_ExpectedIncomeExpenses__c> incomeExpensesList = Database.query(query);

            //List<CJFW_ExpectedIncomeExpenses__c> incomeExpensesList = [
            //SELECT Id,
            //    Version__c,
            //    ExpectSales__c,
            //    Opportunity__c,
            //    ResultExpectSales__c,
            //    ResultExpectRate__c,
            //    ExpectContributionProfit__c,
            //    ExpectContributionProfitRate__c,
            //    SupportFeeRate__c,
            //    ExpectSalesProfit__c,
            //    ExpectSalesProfitRate__c,
            //    ContractDepreciationRate__c,
            //    CollateralAmount__c,
            //    CollateralType__c,
            //    ExpectProfit__c,
            //    CollateralPeriod__c,
            //    CreditLoanAmount__c,
            //    ContractDepreciationSupport__c,
            //    SalesFeeSupport__c,
            //    DonationSupport__c,
            //    OtherSupport__c,
            //    PaymentMethod__c,
            //    ContractPaymentDate__c,
            //    ChefSupportCnt__c,
            //    FarmSupportExpect__c,
            //    MarineSupportExpect__c,
            //    LivestockSupportExpect__c,
            //    ManufactureSupportExpect__c,
            //    NonFoodSupportExpect__c,
            //    SalesSupportExpect__c,
            //    IsReportCheck__c,
            //    IncentiveSupport__c
            //FROM CJFW_ExpectedIncomeExpenses__c 
            // WHERE id ='a1l0w000001Ma13AAC'  //예상손익 id
            //   WHERE Opportunity__c = '0060w00000D8uikAAB' // 예상손익 매핑o
            //if(opportunityId <> null) WHERE Opportunity__c =: opportunityId 
            //ORDER BY Version__c DESC LIMIT 1
            //];  

            if (!incomeExpensesList.isEmpty()) {
                IncomeExpensesInfo = incomeExpensesList[0];
                versionCheck = ( incomeExpensesList[0].Version__c ) + 1 ;
                System.debug('버전 up ! '+ versionCheck);
                
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
            'ContractDepreciationRate__c',
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

            System.debug(' 예상손익 : ' + fieldName + ': ' + fieldValue);
        }

        // ContractPaymentDate__c 필드를 yyyy-MM-dd 형식의 문자열로 변환
        String ContractPaymentDateString = String.valueOf(IncomeExpensesInfo.ContractPaymentDate__c); 
        String CollateralPeriodString = String.valueOf(IncomeExpensesInfo.CollateralPeriod__c);

        ContractPaymentDate = ContractPaymentDateString != null ? ContractPaymentDateString.substring(0, 10) : null;
        CollateralPeriod = CollateralPeriodString != null ? CollateralPeriodString.substring(0, 10) : null;


        System.debug('# paymentPickList ->' + paymentPickList ); 
        System.debug('# collateralPickList ->' + collateralPickList ); 
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
/*     @RemoteAction
    public static String saveIncomeExpenses_before(String DataList , String opportunityId ) {
        System.debug(' 데이터 save !!!' );
        try {

            versionCheck();
            SaveDataList = DataList;
            System.debug(' 데이터 받아온것 -> ' + DataList);
            // String opptyId = ApexPages.currentPage().getParameters().get('opportunityId');
            System.debug(' opportunityId -> ' + opportunityId );
            CJFW_ExpectedIncomeExpenses__c record = new CJFW_ExpectedIncomeExpenses__c();
            // record.ChefSupportCnt__c = Integer.valueOf(fieldValue); // 필드 값을 설정
            record.saveResult__c = DataList; // 필드 값을 설정
            record.Opportunity__c = opportunityId ; // 필드 값을 설정
            
            // 데이터 저장
            insert record;
            System.debug(' 생성된 id -> ' +  record.id );

            return 'success';
        } catch (Exception e) {
            return 'error: ' + e.getMessage();
        }
    } */

    /* 
    CJFW_NewOpenReport_ProfitReview (VF Page) 에서 입력받은 값 update   
    */
    @RemoteAction
    public static String saveIncomeExpenses(String DataList  , String opportunityId , Decimal versionCheck , String incomeExpensesId) {
        System.debug(' 데이터 save !!!' );
        try {
            System.debug(' DataList ' + DataList );
            System.debug(' opportunityId  ' + opportunityId );
            System.debug(' versionCheck  ' + versionCheck );
            System.debug(' incomeExpensesId  ' + incomeExpensesId );
            
            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(DataList);
            Decimal deprecAmount = convertToDecimal(dataMap.get('detail-deprec-amount'));
            Decimal donationAmount = convertToDecimal(dataMap.get('detail-donation-amount'));
            Decimal feeAmount = convertToDecimal(dataMap.get('detail-fee-amount'));
            Decimal incentiveAmount = convertToDecimal(dataMap.get('detail-incentive-amount'));
            Decimal otherAmount = convertToDecimal(dataMap.get('detail-other-amount'));
            
            //Decimal farmBefore = convertToDecimal(dataMap.get('farm-before'));
            //Decimal livestockBefore = convertToDecimal(dataMap.get('livestock-before'));
            //Decimal manufactureBefore = convertToDecimal(dataMap.get('manufacture-before'));
            //Decimal marinBefore = convertToDecimal(dataMap.get('marin-before'));
            //Decimal nonfoodBefore = convertToDecimal(dataMap.get('nonfood-before'));

            System.debug('deprecAmount: ' + deprecAmount);
            System.debug('donationAmount: ' + donationAmount);
            System.debug('feeAmount: ' + feeAmount);
            System.debug('incentiveAmount: ' + incentiveAmount);
            System.debug('otherAmount: ' + otherAmount);

            //System.debug('farmBefore: ' + farmBefore);
            //System.debug('livestockBefore: ' + livestockBefore);
            //System.debug('manufactureBefore: ' + manufactureBefore);
            //System.debug('marinBefore: ' + marinBefore);
            //System.debug('nonfoodBefore: ' + nonfoodBefore);

            //System.debug(' dataMap get! 약정감가 2  ' + Decimal.valueOf(deprec) );

            if(incomeExpensesId <> null ){
                System.debug('update ->  ' + incomeExpensesId);
                CJFW_ExpectedIncomeExpenses__c expectIncome = [SELECT Id, ContractDepreciationSupport__c , IncentiveSupport__c ,  SalesFeeSupport__c , DonationSupport__c, OtherSupport__c  FROM CJFW_ExpectedIncomeExpenses__c WHERE  Id = :incomeExpensesId];
                expectIncome.ContractDepreciationSupport__c = deprecAmount;
                expectIncome.IncentiveSupport__c = incentiveAmount;
                expectIncome.SalesFeeSupport__c = feeAmount;
                expectIncome.DonationSupport__c = donationAmount;
                expectIncome.OtherSupport__c = otherAmount;
                update expectIncome;
            }else{
                System.debug('insert ->  ' + incomeExpensesId);
                CJFW_ExpectedIncomeExpenses__c expectIncome = new CJFW_ExpectedIncomeExpenses__c();
                expectIncome.ContractDepreciationSupport__c = deprecAmount;
                expectIncome.IncentiveSupport__c = incentiveAmount;
                expectIncome.SalesFeeSupport__c = feeAmount;
                expectIncome.DonationSupport__c = donationAmount;
                expectIncome.OtherSupport__c = otherAmount;
                insert expectIncome;
                System.debug(' expectIncome id -> ' + expectIncome.id );
                
            }

            // expectIncome.ContractDepreciationSupport__c = deprecAmount;
            // expectIncome.IncentiveSupport__c = incentiveAmount;
            // expectIncome.SalesFeeSupport__c = feeAmount;
            // expectIncome.DonationSupport__c = donationAmount;
            // expectIncome.OtherSupport__c = otherAmount;

            // expectIncome.ContractDepreciationSupport__c = Decimal.valueOf(dataMap.get('detail-deprec-amount'));
            // System.debug(' expectIncome ' + expectIncome );
            
            // insert expectIncome;
            // System.debug(' expectIncome id -> ' + expectIncome.id );

            return 'success';
        } catch (Exception e) {
            return 'error: ' + e.getMessage();
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
            CJFW_ExpectedIncomeExpenses__c RemoveList = [SELECT Id, IsReportCheck__c FROM CJFW_ExpectedIncomeExpenses__c WHERE Opportunity__c =: opportunityId AND Id != :incomeExpensesId];
            CJFW_ExpectedIncomeExpenses__c checkList = [SELECT Id, IsReportCheck__c FROM CJFW_ExpectedIncomeExpenses__c WHERE  Id = :incomeExpensesId];

            if(RemoveList <> null ){
                RemoveList.IsReportCheck__c =false;
                System.debug(' RemoveList ' + RemoveList );
                update RemoveList;
            }

            if(checkList <> null){
                checkList.IsReportCheck__c =true;
                System.debug(' checkList ' + checkList );
                update checkList;
            }
            return 'success';
        }catch (Exception e) {
            return 'error: ' + e.getMessage();
        }
    }

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

/*     public static void versionCheck() {
        System.debug(' versionCheck 호출' );
        System.debug(' version ' + versionCheck );
        System.debug(' save Data  ' + SaveDataList );

    }
 */

}