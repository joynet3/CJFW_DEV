/**
 * @description       : 하위 품의서에 노출시킬 데이터 가져오는 용도의 Controller
 * 
  [품의서종류 참고사항]
  (급식솔루션,헬씨,아이누리)_신규개설품의 page : CJFW_NewOpenReport
  (급식)_보증금양식 page : CJFW_DepositForm
  (아이누리)_신규개설품의 page : CJFW_NewInuriOpenReport

 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 11-07-2023
 * @last modified by  : yeonji.lim@dkbmc.com
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

    /* picklist */
    public List<SelectOption> collateralPickList { get; set; } // 담보제공종류
    public List<SelectOption> paymentPickList { get; set; }    // 결제수단종류 
    public List<SelectOption> contractPickList { get; set; } // 계약서종류
    public List<SelectOption> deliveryPickList { get; set; } // 배송횟수종류
    public List<SelectOption> exclusiveDealPickList { get; set; } // 단독거래

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

        getPicklistValues(); // picklist label/value 값 담기 [1]
        getAccountInfo();    // 고객사 정보 가져오기 [2]
        getIncomeExpenses(); // 신규개설품의 obj 값 가져오기 [3]
        getExpectManager();  // 품의서 관리자 작성 obj 값 가져오기 [4] 
        getDistributeCost(); // 물류비관리 값 가져오기 [5]

    }

    /* 
    Oppty 에 있는 Account 값을 가져오는 메소드
    */
   public void getAccountInfo() {

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
       Schema.DescribeFieldResult exclusiveDealPick = CJFW_ExpectedIncomeExpenses__c.ExclusiveDeal__c.getDescribe(); // 단독거래
       
       List<Schema.PicklistEntry> collateralValues = collateralResult.getPicklistValues();
       List<Schema.PicklistEntry> paymentValues = paymentPick.getPicklistValues();
       List<Schema.PicklistEntry> contractValues = contractTypePick.getPicklistValues();
       List<Schema.PicklistEntry> deliveryValues = deliveryTypePick.getPicklistValues();
       List<Schema.PicklistEntry> exclusiveDealValues = exclusiveDealPick.getPicklistValues();

       collateralPickList = new List<SelectOption>();
       paymentPickList = new List<SelectOption>();
       contractPickList = new List<SelectOption>();
       deliveryPickList = new List<SelectOption>();
       exclusiveDealPickList = new List<SelectOption>();

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

        // System.debug(' 배송횟수 테스트  test ' + deliveryPickList);

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
            
            'BondCollateral__c, ' +         // 채권담보
            'SecurityCollateral__c, ' +     // 보증금담보
            'PrimaryContract__c, ' +        // 상품공급기본계약서
            'SpecialCollateral__c, ' +      // 영업보증금 특약계약서
            
            // 기타
            'OtherSupportDetail__c, ' +     // 기타 지원세부 내역
            'AttachedDocument__c, ' +       // 첨부서류
            'OpptyDescription__c, ' +       // 특이사항
            
            'DeliveryCnt__c, ' +            // 배송횟수
            'InitialDate__c ' +             // 초도일자

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

        System.debug('IncomeExpensesInfo '+ IncomeExpensesInfo);
        
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
                'CollateralAmount__c',
                'ChefFee__c',
                'CreditLoanAmount__c'
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
                'ContractPaymentNum__c'       //약정결제일(일 수)
            };
            for (String defaultSet : defaultValPerSet) {
                Object fieldPerValue = IncomeExpensesInfo.get(defaultSet);

                if (fieldPerValue == null) fieldPerValue = 0; 
                IncomeExpensesInfo.put(defaultSet, fieldPerValue);
            }

            selectedCollateral = IncomeExpensesInfo.CollateralType__c;  // 담보종류
            selectedPayment = IncomeExpensesInfo.PaymentMethod__c;      // 결제수단 
            selectedContract = IncomeExpensesInfo.ContractType__c	;   // 계약서종류 
            selectedDelivery = IncomeExpensesInfo.DeliveryCnt__c	;   // 배송횟수 
            selectedExclusiveDeal = IncomeExpensesInfo.ExclusiveDeal__c	;   // 단독거래

            // ContractPaymentDate__c 필드를 yyyy-MM-dd 형식의 문자열로 변환
            String collateralPeriodString = String.valueOf(IncomeExpensesInfo.collateralPeriod__c);
            String contractPaymentDateString = String.valueOf(IncomeExpensesInfo.contractPaymentDate__c); 
            String initialDateString = String.valueOf(IncomeExpensesInfo.InitialDate__c);           // 초도일자 
            String contractStartString = String.valueOf(IncomeExpensesInfo.ContractStartDate__c);   // 계약시작일자
            String contractEndString = String.valueOf(IncomeExpensesInfo.ContractEndDate__c);       // 계약종료일자 
            String collateralStartString = String.valueOf(IncomeExpensesInfo.CollateralStart__c);       // 담보 시작기간 
            String collateralEndString = String.valueOf(IncomeExpensesInfo.CollateralEnd__c);           // 담보 종료기간 
            String collateralStartAddString = String.valueOf(IncomeExpensesInfo.CollateralStartAdd__c); // 담보 시작기간(추가) 
            String collateralEndAddString = String.valueOf(IncomeExpensesInfo.CollateralEndAdd__c);     // 담보 종료기간(추가) 

            System.debug('contractStartString ===' + contractStartString);
            System.debug('contractEndString ===' + contractEndString);
            
            collateralPeriod = collateralPeriodString != null ? collateralPeriodString.substring(0, 10) : null;
            contractPaymentDate = contractPaymentDateString != null ? contractPaymentDateString.substring(0, 10) : null;
            initialDate = initialDateString != null ? initialDateString.substring(0, 10) : null;
            contractStartDate = contractStartString != null ? contractStartString.substring(0, 10) : null;
            contractEndDate = contractEndString != null ? contractEndString.substring(0, 10) : null;
            collateralStart = contractEndString != null ? collateralStartString.substring(0, 10) : null;
            collateralEnd = contractEndString != null ? collateralEndString.substring(0, 10) : null;
            collateralStartAdd = contractEndString != null ? collateralStartAddString.substring(0, 10) : null;
            collateralEndAdd = contractEndString != null ? collateralEndAddString.substring(0, 10) : null;
            
            System.debug('contractStartDate ===' + contractStartDate);
            System.debug('contractEndDate ===' + contractEndDate);

            // System.debug('# paymentPickList ->' + paymentPickList ); 
            // System.debug('# collateralPickList ->' + collateralPickList ); 
            // System.debug('# 담보제공 날짜 ->' + collateralPeriod ); 
            // System.debug('# 채권 날짜 ->' + contractPaymentDate ); 
            // System.debug('# 담보종류 ->' + selectedCollateral ); 
            System.debug('# 결제수단 ->' + selectedPayment ); 

            // 급식 보증금개설에서 결제수단필드에 저장된 value값 담아서 넘겨주기 (예상손익에 결제수단에 따라 계산이 달라지기 때문)
            paymentMethod = IncomeExpensesInfo.PaymentMethod__c != null ? IncomeExpensesInfo.PaymentMethod__c : '';

            // 2. 거래처 현황 account info 값을 참고로 IncomeExpensesInfo 에 담아주기 : IncomeExpensesInfo 필드에 값이 있는지 먼저 체크 > 값이 없으면 accountInfo 에서 값 땡겨옴
            // 거래처명 (text)
            if( IncomeExpensesInfo.ClientCompanyName__c == '' || IncomeExpensesInfo.ClientCompanyName__c == null ){
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
            

            System.debug('# accountInfo  ->' + accountInfo ); 
            System.debug('# 품의서정보  ->' + IncomeExpensesInfo ); 
            
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

            // 본부별 최대 8개까지 존재가능한 물류비값을 각각 담아주기 
            for(CJFW_DistributionCost__c record : DistributeCostList){

                if(headOfficeLabel == '3001'){ // 급식일때 
                    DistributeSchool =record.Cost__c;
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
        System.debug('# headOfficeLabel ~~ ' + headOfficeLabel );
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
                Source__c 
            FROM CJFW_ExpectedIncomeManager__c WHERE StartDate__c <= TODAY AND HeadOffice__c =: headOfficeLabel LIMIT 1];

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

            if (IncomeManagerList.size() > 0) {
                //CJFW_ExpectedIncomeManager__c IncomeManager = IncomeManagerList[0];
                IncomeManager = IncomeManagerList[0];
                
                for (String defaultSet : defaultValSet) {
                    Object fieldValue = IncomeManager.get(defaultSet);
                    // 필드 값이 null이면 기본값을 0.00으로 설정
                    if (fieldValue == null) fieldValue = 0.00; 
                    IncomeManager.put(defaultSet, fieldValue);
                }

                System.debug('IncomeManager !! check > '+  IncomeManager );
                System.debug('IncomeManager 라바코스트 > '+  IncomeManager.LaborCost__c );

                //for (String defaultSet : defaultValSet) {
                //    Object fieldValue = IncomeManager.get(defaultSet);
                //    // 필드 값이 null이면 기본값을 0.00 으로 설정
                //    if (fieldValue == null)  fieldValue = 0.00; 
                //    IncomeManager.put(defaultSet, fieldValue);
                //}
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
                System.debug('insert ★-> ');
                System.debug(' 품의서종류  -> ' + (String)dataMap.get('reportType')  );
                expectIncome = new CJFW_ExpectedIncomeExpenses__c();
                expectIncome.ReportType__c = (String)dataMap.get('reportType') ; // 리포트타입 필수값
                expectIncome.Version__c = versionCheck;      // 필수값
                expectIncome.Opportunity__c = opportunityId; // 필수값
                if(versionCheck == 1) expectIncome.IsReportCheck__c = true; // 초기 insert 시에 품의지정 default 세팅
            }

            expectIncome.saveResult__c = DataList;

            // 개요
            if (dataMap.containsKey('summary')) { 
                expectIncome.Summary__c = (String) dataMap.get('summary');
            }
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

            /* 개요 */
            if (dataMap.containsKey('summary')) { 
                expectIncome.Summary__c = (String) dataMap.get('summary');
            }

            /* 거래처 현황 */
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
            if (dataMap.containsKey('exclusiveDeal')) { // 단독거래 (PickList)
                expectIncome.ExclusiveDeal__c = (String) dataMap.get('exclusiveDeal');
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
            if (dataMap.containsKey('unitPrice') && dataMap.get('unitPrice') !='') { // 단가 (number)
                expectIncome.UnitPrice__c = convertToDecimal(dataMap.get('unitPrice')) ;
            }
            if (dataMap.containsKey('exception') && dataMap.get('exception') !='') { // 예외가 (number)
                expectIncome.Exception__c = convertToDecimal(dataMap.get('exception')) ;
            }
            if (dataMap.containsKey('existCenter')) { // 센터
                expectIncome.Center__c = (String)dataMap.get('existCenter') ;
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
            if (dataMap.containsKey('contract-payment-period') && dataMap.get('contract-payment-period') !='') { // 채권담보
                expectIncome.ContractPaymentDate__c = Date.valueOf(((String) dataMap.get('contract-payment-period')));
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
            if (dataMap.containsKey('salesSupportBefore') && dataMap.get('salesSupportBefore') !='') { //  매출이익 데이터
                expectIncome.SalesSupportExpect__c = convertToDecimal(dataMap.get('salesSupportBefore')) ;
            }

            if (dataMap.containsKey('changeReason')) { // 회당 20만원 산정 수정내역 (급식신규사용)
                expectIncome.ChangeReason__c = (String)dataMap.get('changeReason') ;
            }
            if (dataMap.containsKey('detail-chef')) { // 회당 20만원 산정 금액 변경 (급식신규사용)
                expectIncome.ChefFee__c =  convertToDecimal(dataMap.get('detail-chef'));
                expectIncome.ChangeChefSupport__c = true; // 지원변경을 하면 flag 값주기 
            }

            /* 그 외 */
            if (dataMap.containsKey('selectedDelivery')) { // 배송횟수
                expectIncome.DeliveryCnt__c = (String)dataMap.get('selectedDelivery'); // 결제수단 종류
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