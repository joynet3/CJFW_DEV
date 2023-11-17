/**
 * @description       : 급식관련 품의서에 노출시킬 데이터 가져오는 용도의 Controller
 * 
  [급식관련 품의서종류 참고사항]
  (급식솔루션,헬씨,아이누리) 신규개설품의 PAGE : CJFW_NewOpenReport
  (급식)보증금개설 PAGE: CJFW_DepositForm
  (급식)보증금변경 PAGE: CJFW_ChangeDepositForm

 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 11-16-2023
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

    public String reportType { get; set; } // 품의서 유형
    public String headOfficeLabel { get; set; } // 본부구분 

    public String fieldValue { get; private set; }

    public Decimal DistributeSchool {get;set;} // 급식용 
    public String paymentMethod {get;set;}    // 결제수단 value 가져오기 (급식 보증금 개설전용)

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
    public String selectedExclusiveDeal { get; set; }   //단독거래
    public String selectedpaymentTOBE { get; set; }   //TOBE 결제 수단

    /* picklist */
    public List<SelectOption> collateralPickList { get; set; } // 담보제공종류
    public List<SelectOption> paymentPickList { get; set; }    // 결제수단종류 
    public List<SelectOption> contractPickList { get; set; } // 계약서종류
    public List<SelectOption> deliveryPickList { get; set; } // 배송횟수종류
    public List<SelectOption> exclusiveDealPickList { get; set; } // 단독거래
    public List<SelectOption> paymentTOBEPickList { get; set; } // TOBE 결제 수단

    /* 날짜형식변환 */
    public String collateralPeriod { get; set; } // 담보 제공 기간
    public String contractPaymentDate { get; set; } // 약정결제일
    public String initialDate { get; set; } // 초도일자
    public String contractStartDate { get; set; } // 계약시작
    public String contractEndDate { get; set; } // 계약종료
    public String collateralStart { get; set; } // 담보 시작기간
    public String collateralEnd { get; set; } // 담보 종료기간
    public String collateralStartAdd { get; set; } // 담보 시작기간(추가)
    public String collateralEndAdd { get; set; } // 담보 종료기간(추가)
    public String contractStartDateTOBE { get; set; } // TOBE 계약시작
    public String contractEndDateTOBE { get; set; } // TOBE 계약종료
    public String collateralStartTOBE { get; set; } // TOBE 담보 시작기간
    public String collateralEndTOBE { get; set; } // TOBE 담보 종료기간
    public String collateralStartAddTOBE { get; set; } // TOBE 담보 시작기간(추가)
    public String collateralEndAddTOBE { get; set; } // TOBE 담보 종료기간(추가)
    public String salesPerformDate { get; set; } // 품의생성일자


    /* 
    컨트롤러가 호출되면 돌아가는 부분 
    순서 잘 맞추기
    */
    public ReportFormController() {

        this.opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
        this.incomeExpensesId = ApexPages.currentPage().getParameters().get('incomeExpensesId');
        this.showtable = ApexPages.currentPage().getParameters().get('showtable');
        this.reportType = ApexPages.currentPage().getParameters().get('type');
        this.headOfficeLabel = '3001'; // 급식코드 

        System.debug('# opportunityId ->' + opportunityId );
        System.debug('# incomeExpensesId ->' + incomeExpensesId );
        System.debug('# showtable ->' + showtable );
        System.debug('# reportType ->' + reportType );

        // String pageReferenceString = ApexPages.currentPage().getUrl();
        // String testReContract = '/apex/CJFW_NewOpenReport';
        // System.debug(' 급식신규 테스트 모드 ' + testReContract );
        // if (pageReferenceString == testReContract) {
        //     opportunityId = '0060w00000D8uikAAB';
        //     incomeExpensesId = 'a1lH2000001YZ22IAG';
        //     showtable = 'false';
        // }

        getPicklistValues(); // picklist label/value 값 담기 [1]
        getAccountInfo();    // 고객사 정보 가져오기 [2]
        getIncomeExpenses(); // 신규개설품의 obj 값 가져오기 [3]
        getExpectManager();  // 품의서 관리자 작성 obj 값 가져오기 [4] 
        getDistributeCost(); // 물류비관리 값 가져오기 [5]

    }

    public void getAccountInfo() {
        // 기회 레코드에서 계정 ID 가져오기
        List<Opportunity> opportunities = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
       
        if (opportunities.isEmpty()) {
            System.debug('# 해당 기회 ID에 대한 레코드를 찾을 수 없습니다.');
            return; // 레코드가 없으면 메소드를 종료
        }
 
        Id accountId = opportunities[0].AccountId;
       
        if (accountId != null) {
            // 계정 정보를 쿼리
            List<Account> accounts = [SELECT
                Id,
                Name,
                RepresentativeName__c,
                BusinessPath__c,
                SalesMonthly__c,
                OurSales__c,
                Address__c,
                Phone,
                PV_EXISTSUP__c,
                CustomerID__c
                FROM Account
                WHERE Id = :accountId
            ];
 
            if (!accounts.isEmpty()) {
                accountInfo = accounts[0];
 
                String[] defaultValSet = new String[] {
                    'RepresentativeName__c',
                    'BusinessPath__c',
                    'Address__c',
                    'PV_EXISTSUP__c',
                    'CustomerID__c'
                };
 
                for (String defaultSet : defaultValSet) {
                    Object fieldValue = accountInfo.get(defaultSet);
                    // 필드 값이 null이면 기본값을 공백
                    if (fieldValue == null)  fieldValue = '';
                    accountInfo.put(defaultSet, fieldValue);
                }
 
                // System.debug('# 잘 가져왔니 ?->' + accountInfo);
            } else {
                System.debug('# 해당 계정 ID에 대한 레코드를 찾을 수 없습니다.');
            }
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
       Schema.DescribeFieldResult exclusiveDealPick = CJFW_ExpectedIncomeExpenses__c.ExclusiveDeal__c.getDescribe(); // 단독거래
       Schema.DescribeFieldResult paymentTOBEPick = CJFW_ExpectedIncomeExpenses__c.PaymentTOBE__c.getDescribe(); // TOBE 결제 수단
       
       List<Schema.PicklistEntry> collateralValues = collateralResult.getPicklistValues();
       List<Schema.PicklistEntry> paymentValues = paymentPick.getPicklistValues();
       List<Schema.PicklistEntry> contractValues = contractTypePick.getPicklistValues();
       List<Schema.PicklistEntry> deliveryValues = deliveryTypePick.getPicklistValues();
       List<Schema.PicklistEntry> exclusiveDealValues = exclusiveDealPick.getPicklistValues();
       List<Schema.PicklistEntry> paymentTOBEValues = paymentTOBEPick.getPicklistValues();

       collateralPickList = new List<SelectOption>();
       paymentPickList = new List<SelectOption>();
       contractPickList = new List<SelectOption>();
       deliveryPickList = new List<SelectOption>();
       exclusiveDealPickList = new List<SelectOption>();
       paymentTOBEPickList = new List<SelectOption>();

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
        for (Schema.PicklistEntry picklistValue : exclusiveDealValues) { // 단독거래
            exclusiveDealPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }
        for (Schema.PicklistEntry picklistValue : paymentTOBEValues) { // TOBE 결제 수단
            paymentTOBEPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }

        // System.debug(' TOBE 결제 수단 PickList => ' + paymentTOBEPickList);

    }

    /* 
    예산손익(CJFW_ExpectedIncomeExpenses__c) 에서 값 가져오기
    VF Page 초기호출시  
    */
    public void getIncomeExpenses() {

        System.debug('# ReportFormController # getIncomeExpenses');
        
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
            'ChefFee__c, ' + // 예상손익관리 값에서 가져온값 수정시 예상손익에 담김
            'ChangeChefSupport__c, ' + // 쉐프지원 변경여부

            //개요
            'Summary__c, ' +              
            
            // 거래처현황 관련 필드 추가 
            'ClientCompanyName__c, ' +      
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
            'ChangeReason__c, ' +           // 변경내역 
            'ExclusiveDeal__c, ' +          // 단독거래       
            'UnitPrice__c, ' +              // 단가       
            'Exception__c, ' +              // 예외가       
            'Comment__c, ' +                // 비고       

            // 거래처 상세내용
            'ContractStartDate__c, ' +      // 계약시작기간
            'ContractEndDate__c, ' +        // 계약종료기간
            'ContractType__c, ' +           // 계약서 종류
            'CollateralStart__c, ' +        // 담보 시작기간
            'CollateralEnd__c, ' +          // 담보 종료기간
            'CollateralAmountAdd__c, ' +    // 담보 금액(추가)
            'CollateralStartAdd__c, ' +     // 담보 시작기간(추가)
            'CollateralEndAdd__c, ' +       // 담보 종료기간(추가)
            'ContractPaymentNum__c, ' +     // 약정결제일(일 수)
            'CommentASIS__c, ' +            // ASIS 비고

            'ContractStartDateTOBE__c, ' +      // TOBE 계약 시작기간
            'ContractEndDateTOBE__c, ' +        // TOBE 계약 종료기간
            'CollateralAmountTOBE__c, ' +       // TOBE 담보 금액
            'CollateralAmountAddTOBE__c, ' +    // TOBE 담보 금액(추가)
            'CollateralStartTOBE__c, ' +        // TOBE 담보 시작기간
            'CollateralEndTOBE__c, ' +          // TOBE 담보 종료기간
            'CollateralStartAddTOBE__c, ' +     // TOBE 담보 시작기간(추가)
            'CollateralEndAddTOBE__c, ' +       // TOBE 담보 종료기간(추가)
            'DeprecAmountTOBE__c, ' +           // TOBE 약정감가 지원(%)
            'IncentiveSupportTOBE__c, ' +       // TOBE 장려금 지원(%)
            'SalesFeeSupportTOBE__c, ' +        // TOBE 판매수수료 지원(%)
            'DonationSupportTOBE__c, ' +        // TOBE 후원금 지원(%)
            'OtherSupportTOBE__c, ' +           // TOBE 기타지원 식재, 기물 外 지원(%)
            'PaymentTOBE__c, ' +                // TOBE 결제 수단
            'ContractPaymentNumTOBE__c, ' +     // TOBE 약정결제일(일 수)
            'CommentTOBE__c, ' +                // TOBE 비고

            // 예상손익 (보증금 변경)
            'SalesTwoMonth__c, ' +                  // ASIS 매출 전전월 실적
            'SalesOneMonth__c, ' +                  // ASIS 매출 전월 실적
            'SalesMonth__c, ' +                     // ASIS 매출 당월 예상 실적
            'SalesBefore__c, ' +                    // TOBE 지원 전 매출실적
            'SalesSupportTwoMonth__c, ' +           // ASIS 매출이익 전전월 실적
            'SalesSupportOneMonth__c, ' +           // ASIS 매출이익 전월 실적
            'SalesSupportMonth__c, ' +              // ASIS 매출이익 당월 예상 실적
            'SalesSupportRateBefore__c, ' +         // TOBE 지원 전 매출이익실적

            'BondCollateral__c, ' +         // 채권담보
            'SecurityCollateral__c, ' +     // 보증금담보
            'PrimaryContract__c, ' +        // 상품공급기본계약서
            'SpecialCollateral__c, ' +      // 영업보증금 특약계약서
            
            // 예상손익 추가 2023-11-14
            'BondGuaranteeInsurance__c, ' +     // 채권보증보험료 (급식 보증금 개설)
            'BondPledgeFee__c, ' +              // 채권담보수수료 (급식 보증금 변경)

            // 기타
            'OtherSupportDetail__c, ' +     // 기타 지원세부 내역
            'AttachedDocument__c, ' +       // 첨부서류
            'OpptyDescription__c, ' +       // 특이사항
            
            'SalesPerformDate__c, ' +       // 실적현황 지정일
            'DeliveryCnt__c, ' +            // 배송횟수
            'InitialDate__c ' +             // 초도일자

            'FROM CJFW_ExpectedIncomeExpenses__c';

            if (incomeExpensesId != null) {
                query += ' WHERE id = :incomeExpensesId ';
            }else if (opportunityId != null) {
                query += ' WHERE Opportunity__c = :opportunityId  AND ReportType__c = :reportType';
            }

            if(showtable =='true'){
                query += ' ORDER BY IsReportCheck__c DESC LIMIT 1';
            }else{
                query += ' ORDER BY Version__c DESC LIMIT 1';
            }


            // query += ' ORDER BY Version__c DESC LIMIT 1';

            // System.debug('# query ->' + query );
            List<CJFW_ExpectedIncomeExpenses__c> incomeExpensesList = Database.query(query);

            // insert 인지 update 구분해서 version up _231101
            if (!incomeExpensesList.isEmpty()) {
                IncomeExpensesInfo = incomeExpensesList[0];

                if(incomeExpensesId == null){ // insert : 버전 업! 
                    versionCheck = ( incomeExpensesList[0].Version__c ) + 1 ;
                }else{ //update 
                    versionCheck = ( incomeExpensesList[0].Version__c );
                    reportCheck = ( incomeExpensesList[0].IsReportCheck__c );
                }
                //System.debug(' 업데이트 versionCheck ' + versionCheck );
                //System.debug(' 업데이트 품의지정여부 ' + reportCheck );
            } else { // 품의 초기생성시 
                versionCheck = 1;
                IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c();
            } 


            System.debug('versionCheck -> '+ versionCheck);

        }catch (Exception e) {
            IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c(); // 빈 레코드로 초기화
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
        }

        // System.debug('IncomeExpensesInfo '+ IncomeExpensesInfo);
        
        try {
            /* 값이없어도 화면에 0.00으로 default setting 되게함  */
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
                'ChefFee__c',
                'CreditLoanAmount__c',
                // TO-BE
                'DeprecAmountTOBE__c',
                'IncentiveSupportTOBE__c',
                'SalesFeeSupportTOBE__c',
                'DonationSupportTOBE__c',
                'OtherSupportTOBE__c',
                // 예상손익 (보증금 변경)
                'SalesTwoMonth__c',
                'SalesOneMonth__c',
                'SalesMonth__c',
                'SalesBefore__c',
                'SalesSupportTwoMonth__c',
                'SalesSupportOneMonth__c',
                'SalesSupportMonth__c',
                'SalesSupportRateBefore__c',
                // 예상손익 추가 2023-11-14
                'BondGuaranteeInsurance__c',    // 채권보증보험료 (급식 보증금 개설)
                'BondPledgeFee__c'              // 채권담보수수료 (급식 보증금 변경)
            };
            for (String defaultSet : defaultValSet) {
                Object fieldValue = IncomeExpensesInfo.get(defaultSet);

                if (fieldValue == null) fieldValue = 0.00; 
                IncomeExpensesInfo.put(defaultSet, fieldValue);
            }

            /* number 타입 갑이 없을 경우 0으로 초기값 세팅 */
            String[] defaultValPerSet = new String[] {
                'UnitPrice__c',               //단가
                'Exception__c',               //예외가
                'CollateralAmount__c',        //담보 제공 금액(백만)
                'CollateralAmountAdd__c',     //담보 금액(추가)
                'ContractPaymentNum__c',       //약정결제일(일 수)
                // TO-BE
                'CollateralAmountTOBE__c',           //TOBE 담보 금액
                'CollateralAmountAddTOBE__c',        //TOBE 담보 금액(추가)
                'ContractPaymentNumTOBE__c'          //TOBE 약정결제일(일 수)

            };
            for (String defaultSet : defaultValPerSet) {
                Object fieldPerValue = IncomeExpensesInfo.get(defaultSet);

                if (fieldPerValue == null) fieldPerValue = 0; 
                IncomeExpensesInfo.put(defaultSet, fieldPerValue);
            }

            /* pickList 값 담아주기 */
            selectedCollateral = IncomeExpensesInfo.CollateralType__c;  // 담보종류
            selectedPayment = IncomeExpensesInfo.PaymentMethod__c;      // 결제수단 
            selectedContract = IncomeExpensesInfo.ContractType__c	;   // 계약서종류 
            selectedDelivery = IncomeExpensesInfo.DeliveryCnt__c	;   // 배송횟수 
            selectedExclusiveDeal = IncomeExpensesInfo.ExclusiveDeal__c	;   // 단독거래
            selectedPaymentTOBE = IncomeExpensesInfo.PaymentTOBE__c	;       // TOBE 결제 수단

            /* ContractPaymentDate__c 필드를 yyyy-MM-dd 형식의 문자열로 변환 */
            String collateralPeriodString = String.valueOf(IncomeExpensesInfo.collateralPeriod__c);
            String contractPaymentDateString = String.valueOf(IncomeExpensesInfo.contractPaymentDate__c); 
            String initialDateString = String.valueOf(IncomeExpensesInfo.InitialDate__c);           // 초도일자 
            String contractStartString = String.valueOf(IncomeExpensesInfo.ContractStartDate__c);   // 계약시작일자
            String contractEndString = String.valueOf(IncomeExpensesInfo.ContractEndDate__c);       // 계약종료일자 
            String collateralStartString = String.valueOf(IncomeExpensesInfo.CollateralStart__c);       // 담보 시작기간 
            String collateralEndString = String.valueOf(IncomeExpensesInfo.CollateralEnd__c);           // 담보 종료기간 
            String collateralStartAddString = String.valueOf(IncomeExpensesInfo.CollateralStartAdd__c); // 담보 시작기간(추가) 
            String collateralEndAddString = String.valueOf(IncomeExpensesInfo.CollateralEndAdd__c);     // 담보 종료기간(추가) 
            String contractStartTOBEString = String.valueOf(IncomeExpensesInfo.ContractStartDateTOBE__c);       // TOBE 계약시작일자 
            String contractEndTOBEString = String.valueOf(IncomeExpensesInfo.ContractEndDateTOBE__c);           // TOBE 계약종료일자 
            String collateralStartTOBEString = String.valueOf(IncomeExpensesInfo.CollateralStartTOBE__c);       // TOBE 담보 시작기간 
            String collateralEndTOBEString = String.valueOf(IncomeExpensesInfo.CollateralEndTOBE__c);           // TOBE 담보 종료기간 
            String collateralStartAddTOBEString = String.valueOf(IncomeExpensesInfo.CollateralStartAddTOBE__c); // TOBE 담보 시작기간(추가) 
            String collateralEndAddTOBEString = String.valueOf(IncomeExpensesInfo.CollateralEndAddTOBE__c);     // TOBE 담보 종료기간(추가) 
            String salesPerformDateString = String.valueOf(IncomeExpensesInfo.SalesPerformDate__c);             // 예상손익 지정일자 

            collateralPeriod = collateralPeriodString != null ? collateralPeriodString.substring(0, 10) : null;
            contractPaymentDate = contractPaymentDateString != null ? contractPaymentDateString.substring(0, 10) : null;
            initialDate = initialDateString != null ? initialDateString.substring(0, 10) : null;
            contractStartDate = contractStartString != null ? contractStartString.substring(0, 10) : null;
            contractEndDate = contractEndString != null ? contractEndString.substring(0, 10) : null;
            collateralStart = collateralStartString != null ? collateralStartString.substring(0, 10) : null;
            collateralEnd = collateralEndString != null ? collateralEndString.substring(0, 10) : null;
            collateralStartAdd = collateralStartAddString != null ? collateralStartAddString.substring(0, 10) : null;
            collateralEndAdd = collateralEndAddString != null ? collateralEndAddString.substring(0, 10) : null;
            contractStartDateTOBE = contractStartTOBEString != null ? contractStartTOBEString.substring(0, 10) : null;
            contractEndDateTOBE = contractEndTOBEString != null ? contractEndTOBEString.substring(0, 10) : null;
            collateralStartTOBE = collateralStartTOBEString != null ? collateralStartTOBEString.substring(0, 10) : null;
            collateralEndTOBE = collateralEndTOBEString != null ? collateralEndTOBEString.substring(0, 10) : null;
            collateralStartAddTOBE = collateralStartAddTOBEString != null ? collateralStartAddTOBEString.substring(0, 10) : null;
            collateralEndAddTOBE = collateralEndAddTOBEString != null ? collateralEndAddTOBEString.substring(0, 10) : null;
            salesPerformDate = salesPerformDateString != null ? salesPerformDateString.substring(0, 10) : null;

            // 신규생성시엔 날짜가 안들어가 null 값이뜨는데 , 그럴경우 오늘날짜 기준 1년전을 default 값으로 세팅 
            if(salesPerformDate == null){
                DateTime todayDateTime = DateTime.now();
                salesPerformDate = todayDateTime.format('yyyy-MM-dd');
                // System.debug('salesPerformDate **************' + salesPerformDate);
            }

            // System.debug('# paymentPickList ->' + paymentPickList ); 
            // System.debug('# collateralPickList ->' + collateralPickList ); 
            // System.debug('# 담보제공 날짜 ->' + collateralPeriod ); 
            // System.debug('# 채권 날짜 ->' + contractPaymentDate ); 
            // System.debug('# 담보종류 ->' + selectedCollateral ); 
            // System.debug('# 결제수단 ->' + selectedPayment ); 

            // 급식 보증금개설에서 결제수단필드에 저장된 value값 담아서 넘겨주기 (예상손익에 결제수단에 따라 계산이 달라지기 때문)
            paymentMethod = IncomeExpensesInfo.PaymentMethod__c != null ? IncomeExpensesInfo.PaymentMethod__c : '';

            // 2. 거래처 현황 account info 값을 참고로 IncomeExpensesInfo 에 담아주기 : IncomeExpensesInfo 필드에 값이 있는지 먼저 체크 > 값이 없으면 accountInfo 에서 값 땡겨옴
            // 거래처명 (text)
            if( IncomeExpensesInfo.ClientCompanyName__c == '' || IncomeExpensesInfo.ClientCompanyName__c == null ){
                // [금식 보증금 변경 양식] Account에 고객코드가 있는 경우 거래처명에 "[고객코드]거래처명" 으로 담아주기
                if(accountInfo.get('CustomerID__c') == '' || accountInfo.get('CustomerID__c') == null){
                    // System.debug('====== 고객코드 없음 ========');
                    IncomeExpensesInfo.put('ClientCompanyName__c', accountInfo.get('Name') );
                }else {
                    // System.debug('====== 고객코드 있음 ========');
                    IncomeExpensesInfo.put('ClientCompanyName__c', '['+ accountInfo.get('CustomerID__c')+'] '+ accountInfo.get('Name'));
                }
                // System.debug('고개코드 확인!!!!! ' + IncomeExpensesInfo.get('ClientCompanyName__c'));
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
            

            // System.debug('# accountInfo  ->' + accountInfo ); 
            // System.debug('# 품의서정보  ->' + IncomeExpensesInfo ); 
            
        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
        }
    }


    /* 
    물류비 관리 (CJFW_DistributionCost__c)에서 값 가져오기 
    */
    public void getDistributeCost() {
        System.debug('# ReportFormController # getDistributeCost ');

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
                FROM CJFW_DistributionCost__c WHERE StartDate__c <= TODAY AND HeadOffice__c =: headOfficeLabel ];

            if (!DistributeCostList.isEmpty()) {

                for(CJFW_DistributionCost__c record : DistributeCostList){

                    if(headOfficeLabel == '3001'){ // 급식일때 
                        DistributeSchool = record.Cost__c;
                    }
                }
            } else {    //쿼리 결과가 없을때
                DistributeSchool = 0.00;
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
        // System.debug('# headOfficeLabel ~~ ' + headOfficeLabel );
 
        try{
 
            List<CJFW_ExpectedIncomeManager__c> IncomeManagerList  = [
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
                    Source__c, 
                    // 2023-11-13 추가) 급식 보증금 신규&변경 전용 ↓
                    CardPaymentFee__c,
                    BondCollateralFee__c,
                    DepositCollateralFee__c,
                    InterestRate__c,
                    SUCommon__c,
                    CompanyWide__c
                FROM CJFW_ExpectedIncomeManager__c WHERE StartDate__c <= TODAY AND HeadOffice__c =: headOfficeLabel LIMIT 1];
 
            if(IncomeManagerList.size()>0 ){
                System.debug(' 관리값 정상적으로 가져올경우');
            }else{
                IncomeManager = new CJFW_ExpectedIncomeManager__c();
                System.debug(' 적용날짜가 안맞아서 관리값 못가져올경우  ');
            }
               
                // 조회된내용이 없을때 계산식에 오류가 발생하기때문에 아래와같이 default로 0.00 으로 세팅한다
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
                'SupportFee__c',
                // 2023-11-13 추가) 급식 보증금 신규&변경 전용 ↓
                'CardPaymentFee__c',
                'BondCollateralFee__c',
                'CollateralFee__c',
                'InterestRate__c',
                'SUCommon__c',
                'CompanyWide__c'
            };
 
            if (IncomeManagerList.size() > 0) {
                IncomeManager = IncomeManagerList[0];
            }
           
            for (String defaultSet : defaultValSet) {
                Object fieldValue = IncomeManager.get(defaultSet);
                // 필드 값이 null이면 기본값을 0.00으로 설정
                if (fieldValue == null) fieldValue = 0.00;
                IncomeManager.put(defaultSet, fieldValue);
            }
 
        }catch(Exception e){
            String errorMessage = e.getMessage();
            String errorStackTrace = e.getStackTraceString();
            System.debug(' 예상손익관리자 에러 메시지: ' + errorMessage);
            System.debug(' 예상손익관리자 에러 라인: ' + errorStackTrace);
        }
    }
 
 
    /* 
    CJFW_NewOpenReport_ProfitReview (VF Page) 에서 입력받은 값 update   
    */
    @RemoteAction
    public static String saveIncomeExpenses(String DataList, String opportunityId, Decimal versionCheck, String incomeExpensesId) {
        System.debug('데이터 save !!!');
        try { 
            String reportType='';
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
                System.debug('incomeExpensesId ' + incomeExpensesId);
                
            } else { // insert 
                // System.debug('insert ★-> ');
                System.debug(' 품의서종류  -> ' + (String)dataMap.get('reportType')  );
                expectIncome = new CJFW_ExpectedIncomeExpenses__c();
                expectIncome.ReportType__c = (String)dataMap.get('reportType') ; // 리포트타입 필수값
                expectIncome.Version__c = versionCheck;      // 필수값
                expectIncome.Opportunity__c = opportunityId; // 필수값
                if(versionCheck == 1) expectIncome.IsReportCheck__c = true; // 초기 insert 시에 품의지정 default 세팅
            }

            expectIncome.saveResult__c = DataList;

            if (dataMap.containsKey('collateralType')) { // 담보제공종류
                expectIncome.CollateralType__c = (String) dataMap.get('collateralType');
            }
            if (dataMap.containsKey('creditLoanAmount')) { // 신용여신금액
                expectIncome.CreditLoanAmount__c = convertToDecimal(dataMap.get('creditLoanAmount'));
            }
            if (dataMap.containsKey('chefSupport')) { // 신용여신금액
                expectIncome.ChefSupportCnt__c = convertToDecimal(dataMap.get('chefSupport'));
            }
            if (dataMap.containsKey('contractType')) { // 계약서종류
                expectIncome.ContractType__c = (String) dataMap.get('contractType');
            }
            /* 개요 */
            if (dataMap.containsKey('summary')) { 
                expectIncome.Summary__c = (String) dataMap.get('summary');
            }
            /* 거래처 현황 */
            if (dataMap.containsKey('accountName') && dataMap.get('accountName') !='') { // 거래처명 (text)
                expectIncome.ClientCompanyName__c = (String) dataMap.get('accountName');
            }
            if (dataMap.containsKey('ownerName') && dataMap.get('ownerName') !='') { // 대표자명 (text)
                expectIncome.RepresentativeName__c = (String) dataMap.get('ownerName');
            }
            if (dataMap.containsKey('accountChannel') && dataMap.get('accountChannel') !='') { // 경로 (text)
                expectIncome.BusinessPath__c = (String) dataMap.get('accountChannel');
            }
            if (dataMap.containsKey('outwardEntire') && dataMap.get('outwardEntire') !='') { // 전체외형 (정수)
                expectIncome.SalesMonthly__c = convertToDecimal(dataMap.get('outwardEntire'));
            }
            if (dataMap.containsKey('outwardCompanySize') && dataMap.get('outwardCompanySize') !='') { // 당사규모 (decimal)
                expectIncome.OurSales__c = convertToDecimal(dataMap.get('outwardCompanySize'));
            }
            if (dataMap.containsKey('firstDraft') && dataMap.get('firstDraft') !='') { // 초도일자 (date)
                expectIncome.InitialDate__c = Date.valueOf(((String) dataMap.get('firstDraft')));
            }
            if (dataMap.containsKey('exclusiveDeal') && dataMap.get('exclusiveDeal') !='') { // 단독거래 (PickList)
                expectIncome.ExclusiveDeal__c = (String) dataMap.get('exclusiveDeal');
            }
            if (dataMap.containsKey('accountAddress') && dataMap.get('accountAddress') !='') { // 주소 (text)
                expectIncome.Address__c = (String) dataMap.get('accountAddress');
            }
            if (dataMap.containsKey('accountPhone') && dataMap.get('accountPhone') !='') { // 연락처 (phone)
                expectIncome.RepresentativePhone__c = (String)dataMap.get('accountPhone');
            }
            if (dataMap.containsKey('existGoods') && dataMap.get('existGoods') !='') { // 기존납품처 (text)
                expectIncome.PV_EXISTSUP__c = (String) dataMap.get('existGoods');
            }
            if (dataMap.containsKey('exceptionPrice') && dataMap.get('exceptionPrice') !='') { // 단가/예외가 (decimal)
                expectIncome.ExceptionPrice__c = convertToDecimal(dataMap.get('exceptionPrice')) ;
            }
            if (dataMap.containsKey('unitPrice') && dataMap.get('unitPrice') !='') { // 단가 (number)
                expectIncome.UnitPrice__c = convertToDecimal(dataMap.get('unitPrice')) ;
            }
            if (dataMap.containsKey('exception') && dataMap.get('exception') !='') { // 예외가 (number)
                expectIncome.Exception__c = convertToDecimal(dataMap.get('exception')) ;
            }
            if (dataMap.containsKey('existCenter') && dataMap.get('existCenter') !='') { // 센터
                expectIncome.Center__c = (String)dataMap.get('existCenter') ;
            }
            if (dataMap.containsKey('comment') && dataMap.get('comment') !='') { // 비고
                expectIncome.Comment__c = (String)dataMap.get('comment');
            }
            /* 거래처 상세 내용 */
            if (dataMap.containsKey('contractStartDate') && dataMap.get('contractStartDate') !='') { // 계약기간시작
                expectIncome.ContractStartDate__c = Date.valueOf(((String) dataMap.get('contractStartDate')));
            }
            if (dataMap.containsKey('contractEndDate') && dataMap.get('contractEndDate') !='') { // 계약기간종료
                expectIncome.ContractEndDate__c = Date.valueOf(((String) dataMap.get('contractEndDate')));
            }
            if (dataMap.containsKey('collateralAmount') && dataMap.get('collateralAmount') !='') { // 담보 금액 
                expectIncome.CollateralAmount__c = convertToDecimal(dataMap.get('collateralAmount')) ;
            }
            if (dataMap.containsKey('collateralAmountAdd') && dataMap.get('collateralAmountAdd') !='') { // 담보 금액(추가)
                expectIncome.CollateralAmountAdd__c = convertToDecimal(dataMap.get('collateralAmountAdd')) ;
            }
            if (dataMap.containsKey('collateral-period') && dataMap.get('collateral-period') !='') { // 담보제공기간
                expectIncome.CollateralPeriod__c = Date.valueOf(((String) dataMap.get('collateral-period')));
            }
            if (dataMap.containsKey('collateralStart') && dataMap.get('collateralStart') !='') { // 담보 시작기간
                expectIncome.CollateralStart__c = Date.valueOf(((String) dataMap.get('collateralStart')));
            }
            if (dataMap.containsKey('collateralEnd') && dataMap.get('collateralEnd') !='') { // 담보 종료기간
                expectIncome.CollateralEnd__c = Date.valueOf(((String) dataMap.get('collateralEnd')));
            }
            if (dataMap.containsKey('collateralStartAdd') && dataMap.get('collateralStartAdd') !='') { // 담보 시작기간(추가)
                expectIncome.CollateralStartAdd__c = Date.valueOf(((String) dataMap.get('collateralStartAdd')));
            }
            if (dataMap.containsKey('collateralEndAdd') && dataMap.get('collateralEndAdd') !='') { // 담보 종료기간(추가)
                expectIncome.CollateralEndAdd__c = Date.valueOf(((String) dataMap.get('collateralEndAdd')));
            }
            //지원(%)
            if (dataMap.containsKey('deprecAmount') && dataMap.get('deprecAmount') !='') { // 약정감가
                expectIncome.ContractDepreciationSupport__c = convertToDecimal(dataMap.get('deprecAmount')) ;
            } 
            if (dataMap.containsKey('incentiveSupport') && dataMap.get('incentiveSupport') !='') { // 장려금
                expectIncome.IncentiveSupport__c = convertToDecimal(dataMap.get('incentiveSupport')) ;
            } 
            if (dataMap.containsKey('salesFeeSupport') && dataMap.get('salesFeeSupport') !='') { // 판매수수료
                expectIncome.SalesFeeSupport__c = convertToDecimal(dataMap.get('salesFeeSupport')) ;
            } 
            if (dataMap.containsKey('donationSupport') && dataMap.get('donationSupport') !='') { // 후원금
                expectIncome.DonationSupport__c = convertToDecimal(dataMap.get('donationSupport')) ;
            } 
            if (dataMap.containsKey('otherSupport') && dataMap.get('otherSupport') !='') { // 기타지원
                expectIncome.OtherSupport__c = convertToDecimal(dataMap.get('otherSupport')) ;
            } 
            if (dataMap.containsKey('payment')) { // 결제수단 (PickList)
                expectIncome.PaymentMethod__c = (String) dataMap.get('payment');
            }
            if (dataMap.containsKey('contractPaymentNum') && dataMap.get('contractPaymentNum') !='') { // 약정결제일(일 수)
                expectIncome.ContractPaymentNum__c = convertToDecimal(dataMap.get('contractPaymentNum')) ;
            }
            if (dataMap.containsKey('commentASIS') && dataMap.get('commentASIS') !='') { // ASIS 비고
                expectIncome.CommentASIS__c = (String) dataMap.get('commentASIS');
            }
            if (dataMap.containsKey('contract-payment-period') && dataMap.get('contract-payment-period') !='') { // 채권담보
                expectIncome.ContractPaymentDate__c = Date.valueOf(((String) dataMap.get('contract-payment-period')));
            }
            /* 거래처 상세 내용 TO-BE (보증금 변경 전용) */
            if (dataMap.containsKey('contractStartDateTOBE') && dataMap.get('contractStartDateTOBE') !='') { // 계약기간시작 TOBE 
                expectIncome.ContractStartDateTOBE__c = Date.valueOf(((String) dataMap.get('contractStartDateTOBE')));
            }
            if (dataMap.containsKey('contractEndDateTOBE') && dataMap.get('contractEndDateTOBE') !='') { // 계약기간종료 TOBE
                expectIncome.ContractEndDateTOBE__c = Date.valueOf(((String) dataMap.get('contractEndDateTOBE')));
            }
            if (dataMap.containsKey('collateralAmountTOBE') && dataMap.get('collateralAmountTOBE') !='') { // 담보 금액 TOBE
                expectIncome.CollateralAmountTOBE__c = convertToDecimal(dataMap.get('collateralAmountTOBE')) ;
            }
            if (dataMap.containsKey('collateralAmountAddTOBE') && dataMap.get('collateralAmountAddTOBE') !='') { // 담보 금액(추가) TOBE
                expectIncome.CollateralAmountAddTOBE__c = convertToDecimal(dataMap.get('collateralAmountAddTOBE')) ;
            }
            if (dataMap.containsKey('collateralStartTOBE') && dataMap.get('collateralStartTOBE') !='') { // 담보 시작기간 TOBE
                expectIncome.CollateralStartTOBE__c = Date.valueOf(((String) dataMap.get('collateralStartTOBE')));
            }
            if (dataMap.containsKey('collateralEndTOBE') && dataMap.get('collateralEndTOBE') !='') { // 담보 종료기간 TOBE
                expectIncome.CollateralEndTOBE__c = Date.valueOf(((String) dataMap.get('collateralEndTOBE')));
            }
            if (dataMap.containsKey('collateralStartAddTOBE') && dataMap.get('collateralStartAddTOBE') !='') { // 담보 시작기간(추가) TOBE
                expectIncome.CollateralStartAddTOBE__c = Date.valueOf(((String) dataMap.get('collateralStartAddTOBE')));
            }
            if (dataMap.containsKey('collateralEndAddTOBE') && dataMap.get('collateralEndAddTOBE') !='') { // 담보 종료기간(추가) TOBE
                expectIncome.CollateralEndAddTOBE__c = Date.valueOf(((String) dataMap.get('collateralEndAddTOBE')));
            }
            //지원(%)
            if (dataMap.containsKey('deprecAmountTOBE') && dataMap.get('deprecAmountTOBE') !='') { // 약정감가 TOBE
                expectIncome.DeprecAmountTOBE__c = convertToDecimal(dataMap.get('deprecAmountTOBE')) ;
            } 
            if (dataMap.containsKey('incentiveSupportTOBE') && dataMap.get('incentiveSupportTOBE') !='') { // 장려금 TOBE
                expectIncome.IncentiveSupportTOBE__c = convertToDecimal(dataMap.get('incentiveSupportTOBE')) ;
            } 
            if (dataMap.containsKey('salesFeeSupportTOBE') && dataMap.get('salesFeeSupportTOBE') !='') { // 판매수수료 TOBE
                expectIncome.SalesFeeSupportTOBE__c = convertToDecimal(dataMap.get('salesFeeSupportTOBE')) ;
            } 
            if (dataMap.containsKey('donationSupportTOBE') && dataMap.get('donationSupportTOBE') !='') { // 후원금 TOBE
                expectIncome.DonationSupportTOBE__c = convertToDecimal(dataMap.get('donationSupportTOBE')) ;
            } 
            if (dataMap.containsKey('otherSupportTOBE') && dataMap.get('otherSupportTOBE') !='') { // 기타지원 TOBE
                expectIncome.OtherSupportTOBE__c = convertToDecimal(dataMap.get('otherSupportTOBE')) ;
            } 
            if (dataMap.containsKey('paymentTOBE')) { // 결제수단 (PickList) TOBE
                expectIncome.PaymentTOBE__c = (String) dataMap.get('paymentTOBE');
            }
            if (dataMap.containsKey('contractPaymentNumTOBE') && dataMap.get('contractPaymentNumTOBE') !='') { // 약정결제일(일 수) TOBE
                expectIncome.ContractPaymentNumTOBE__c = convertToDecimal(dataMap.get('contractPaymentNumTOBE')) ;
            }
            if (dataMap.containsKey('commentTOBE') && dataMap.get('commentTOBE') !='') { // TOBE 비고
                expectIncome.commentTOBE__c = (String) dataMap.get('commentTOBE');
            }

            // boolean
            if (dataMap.containsKey('bondCollateral') && dataMap.get('bondCollateral') !='') { // 채권담보
                expectIncome.BondCollateral__c = Boolean.valueOf(dataMap.get('bondCollateral'));
            }
            if (dataMap.containsKey('securityCollateral') && dataMap.get('securityCollateral') !='') { // 보증금담보
                expectIncome.SecurityCollateral__c = Boolean.valueOf(dataMap.get('securityCollateral'));
            }
            if (dataMap.containsKey('primaryContract') && dataMap.get('primaryContract') !='') { // 상품공급기본계약서
                expectIncome.PrimaryContract__c = Boolean.valueOf(dataMap.get('primaryContract'));
            }
            if (dataMap.containsKey('specialCollateral') && dataMap.get('specialCollateral') !='') { // 영업보증금 특약계약서
                expectIncome.SpecialCollateral__c = Boolean.valueOf(dataMap.get('specialCollateral'));
            }

            if (dataMap.containsKey('otherDetail')) { // 기타 세부 내역
                expectIncome.OtherSupportDetail__c = (String)dataMap.get('otherDetail') ;
            }
            /* 신규 개설 예상 손익 */
            if (dataMap.containsKey('farmBefore') && dataMap.get('farmBefore') !='') { // 농산물
                expectIncome.FarmSupportExpect__c = convertToDecimal(dataMap.get('farmBefore')) ;
            }
            if (dataMap.containsKey('marinBefore') && dataMap.get('marinBefore') !='') { // 수산물
                expectIncome.MarineSupportExpect__c = convertToDecimal(dataMap.get('marinBefore')) ;
            }
            if (dataMap.containsKey('livestockBefore') && dataMap.get('livestockBefore') !='') { // 축산물
                expectIncome.LivestockSupportExpect__c = convertToDecimal(dataMap.get('livestockBefore')) ;
            }
            if (dataMap.containsKey('manufactureBefore') && dataMap.get('manufactureBefore') !='') { // 가공상품
                expectIncome.ManufactureSupportExpect__c = convertToDecimal(dataMap.get('manufactureBefore')) ;
            }
            if (dataMap.containsKey('nonfoodBefore') && dataMap.get('nonfoodBefore') !='') { // 비식품
                expectIncome.NonFoodSupportExpect__c = convertToDecimal(dataMap.get('nonfoodBefore')) ;
            }
            if (dataMap.containsKey('salesSupportBefore')) { //  매출이익 데이터
                expectIncome.SalesSupportExpect__c = convertToDecimal(dataMap.get('salesSupportBefore')) ;
            }
            // 급식 보증금 변경양식 전용 ↓
            if (dataMap.containsKey('salesTwoMonth') && dataMap.get('salesTwoMonth') !='') { // ASIS 매출 전전월 실적
                expectIncome.SalesTwoMonth__c = convertToDecimal(dataMap.get('salesTwoMonth')) ;
            }
            if (dataMap.containsKey('salesOneMonth') && dataMap.get('salesOneMonth') !='') { // ASIS 매출 전월 실적
                expectIncome.SalesOneMonth__c = convertToDecimal(dataMap.get('salesOneMonth')) ;
            }
            if (dataMap.containsKey('salesMonth') && dataMap.get('salesMonth') !='') { // ASIS 매출 당월 예상 실적
                expectIncome.SalesMonth__c = convertToDecimal(dataMap.get('salesMonth')) ;
            }
            if (dataMap.containsKey('salesBefore') && dataMap.get('salesBefore') !='') { // TOBE 지원 전 매출실적
                expectIncome.SalesBefore__c = convertToDecimal(dataMap.get('salesBefore')) ;
            }
            if (dataMap.containsKey('salesSupportTwoMonth') && dataMap.get('salesSupportTwoMonth') !='') { // ASIS 매출이익 전전월 실적
                expectIncome.SalesSupportTwoMonth__c = convertToDecimal(dataMap.get('salesSupportTwoMonth')) ;
            }
            if (dataMap.containsKey('salesSupportOneMonth') && dataMap.get('salesSupportOneMonth') !='') { // ASIS 매출이익 전월 실적
                expectIncome.SalesSupportOneMonth__c = convertToDecimal(dataMap.get('salesSupportOneMonth')) ;
            }
            if (dataMap.containsKey('salesSupportMonth') && dataMap.get('salesSupportMonth') !='') { // ASIS 매출이익 당월 예상 실적
                expectIncome.SalesSupportMonth__c = convertToDecimal(dataMap.get('salesSupportMonth')) ;
            }
            if (dataMap.containsKey('salesSupportRateBefore') && dataMap.get('salesSupportRateBefore') !='') { // TOBE 지원 전 매출이익실적
                expectIncome.SalesSupportRateBefore__c = convertToDecimal(dataMap.get('salesSupportRateBefore')) ;
            }
            if (dataMap.containsKey('changeReason')) { // 회당 20만원 산정 수정내역 (급식신규사용)
                expectIncome.ChangeReason__c = (String)dataMap.get('changeReason') ;
            }
            if (dataMap.containsKey('detailChef')) { // 회당 20만원 산정 금액 변경 (급식신규사용)
                expectIncome.ChefFee__c =  convertToDecimal(dataMap.get('detailChef'));
                expectIncome.ChangeChefSupport__c = true; // 지원변경을 하면 flag 값주기 
            }
            /* 추가 */
            if (dataMap.containsKey('bondBefore') && dataMap.get('bondBefore') !='') { // 채권보증보험료 (개설)
                expectIncome.BondGuaranteeInsurance__c = convertToDecimal(dataMap.get('bondBefore')) ;
            }
            if (dataMap.containsKey('bondTwoMonth') && dataMap.get('bondTwoMonth') !='') { // 채권담보수수료 (변경)
                expectIncome.BondPledgeFee__c = convertToDecimal(dataMap.get('bondTwoMonth')) ;
            }

            /* 그 외 */
            if (dataMap.containsKey('selectedDelivery')) { // 배송횟수
                expectIncome.DeliveryCnt__c = (String)dataMap.get('selectedDelivery'); 
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
            if (dataMap.containsKey('salesPerformDate')) {  // 예상손익 지정일자 
                expectIncome.SalesPerformDate__c = Date.valueOf(((String) dataMap.get('salesPerformDate')));
            }

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
    public static String ReportCheck(String incomeExpensesId , String opportunityId , String reportType ){

        System.debug(' 품의서 ID : ' + incomeExpensesId );
        System.debug(' 옵티 ID : ' + opportunityId );
        System.debug(' 리포트타입 ID : ' + reportType );

        try{
            //CJFW_ExpectedIncomeExpenses__c RemoveList = [SELECT Id, IsReportCheck__c FROM CJFW_ExpectedIncomeExpenses__c WHERE Opportunity__c =: opportunityId AND Id != :incomeExpensesId];
            List<CJFW_ExpectedIncomeExpenses__c> RemoveList = [
                SELECT 
                    Id, 
                    IsReportCheck__c 
                FROM CJFW_ExpectedIncomeExpenses__c 
                WHERE Opportunity__c = :opportunityId 
                AND Id != :incomeExpensesId 
                AND ReportType__c =:reportType ];

            if(RemoveList <> null ){
                for(CJFW_ExpectedIncomeExpenses__c data : RemoveList) {
                    data.IsReportCheck__c = false;
                }
                update RemoveList;
            }

            CJFW_ExpectedIncomeExpenses__c checkList = [SELECT Id, IsReportCheck__c FROM CJFW_ExpectedIncomeExpenses__c WHERE  Id = :incomeExpensesId];

            System.debug(' 품의체크 checkList ' + checkList.IsReportCheck__c );
            if(checkList <> null){
                checkList.IsReportCheck__c = !checkList.IsReportCheck__c;
                update checkList;
                return String.valueOf(checkList.IsReportCheck__c);
            }

            return 'false';

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
        Decimal decimalValue = 0.00; // 기본값 설정

        // 입력값이 3자리이상일 경우 1,234 숫자사이에 있는 반점 제거 
        //String changeStr = (String)objValue;
        //objValue = changeStr.replace(',', '');
    
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