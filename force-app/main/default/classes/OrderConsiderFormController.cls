/**
 * @description       : 하위 품의서에 노출시킬 데이터 가져오는 용도의 Controller
 * 
    (외식)_수주심의양식(신규) page : CJFW_OrderConsiderNewForm

 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
public with sharing class OrderConsiderFormController {
    public static String SaveDataList;

    public String opportunityId { get; set; }
    public String incomeExpensesId { get; set;} // 신규개설품의 id
    public Decimal versionCheck { get; set; }
    public Boolean reportCheck { get; set; }
    public String showtable { get; set; }
    public String reportType { get; set; } // 품의서 유형
    public String headOfficeLabel { get; set; } // Label
    
    public String fieldValue { get; private set; }


    /* 가져온 데이터 담는 object */
    public Opportunity opptyInfo {get;set;}
    public Account accountInfo {get;set;}
    public CJFW_ExpectedIncomeExpenses__c IncomeExpensesInfo {get;set;} 

    /* 계산값 가져오기 */
    public CJFW_ExpectedIncomeManager__c IncomeManager {get;set;} // 예상손익관리 
    // public CJFW_DistributionCost__c DistributeCost {get;set;} // 물류비관리 


    /* picklist 저장된 값 가져오기 위한 선언 */
    public String selectedBrandChannel { get; set; } // 브랜드 경로
    public String selectedCollateral { get; set; } // 담보제공종류
    public String selectedLoanManage { get; set; }   // 여신관리
    public String selectedPayment { get; set; }    // 결제수단종류 
    public String selectedContract { get; set; }   // 계약서 종류
    public String selectedDelivery { get; set; }   //배송횟수

    /* picklist */
    public List<SelectOption> brandChannelPickList { get; set; } // 브랜드 경로
    public List<SelectOption> collateralPickList { get; set; } // 담보제공종류
    public List<SelectOption> loanManagePickList { get; set; } // 여신관리
    public List<SelectOption> paymentPickList { get; set; }    // 결제수단종류 
    public List<SelectOption> contractPickList { get; set; }   // 계약서종류
    public List<SelectOption> deliveryPickList { get; set; } // 배송횟수종류


    /* 날짜형식변환 */
    public String firstContact { get; set; } // 최초접촉시기
    public String initialDate { get; set; } // 초도일자
    public String contractStartDate { get; set; } // 계약시작
    public String contractEndDate { get; set; } // 계약종료
    public String collateralPeriod { get; set; } // 담보 제공 기간
    public String contractPaymentDate { get; set; } // 약정결제일

    // 물류비 - 외식(SU)
    public Decimal distributeDirCap {get;set;}  // 수도권-직접
    public Decimal distributeDirEast {get;set;} // 동부권-직접
    public Decimal distributeDirWest {get;set;} // 서부권-직접
    public Decimal distributeDirJeju {get;set;} // 제주권-직접

    public Decimal distributeInDirCap {get;set;} // 수도권-간접
    public Decimal distributeInDirEast {get;set;} // 동부권-간접
    public Decimal distributeInDirWest {get;set;} // 서부권-간접
    public Decimal distributeInDirJeju {get;set;} // 제주권-간접


    public Decimal distributeSchool {get;set;} // 급식용 



    /* 생성자 */
    public OrderConsiderFormController(){
        // this.opportunityId = '0060w00000D9x0BAAR'; // 테스트 
        // this.incomeExpensesId = 'a1l0w000001N1yUAAS'; // 테스트

        this.opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
        this.incomeExpensesId = ApexPages.currentPage().getParameters().get('incomeExpensesId');
        this.showtable = ApexPages.currentPage().getParameters().get('showtable');
        this.reportType = ApexPages.currentPage().getParameters().get('type');




        // 리포트 타입에 따라서 물류비 picklist 선정해주기 
        if( reportType == 'CRM009' || reportType == 'CRM010' ){ // 외식 품의서 
            this.headOfficeLabel = '6000'; // 외식코드
            this.showtable = 'false';
        }else{ // 급식품의서 
            this.headOfficeLabel = '3001'; // 급식코드 
        }







        System.debug('# opportunityId ->' + opportunityId );
        System.debug('# incomeExpensesId ->' + incomeExpensesId );
        System.debug('# showtable ->' + showtable );
        System.debug('# reportType ->' + reportType );



        System.debug('#########################################->' + Test.isRunningTest() );

        // test Class에서 객체 생성시 다른 메소드들이 실행되지 않게 분기처리
        if(Test.isRunningTest()){
            System.debug('test code 실행중');
        }else{
            System.debug('실제 환경에서 실행할 로직');
            getPicklistValues();    // picklist label/value 값 담기
            getOpptyInfo();         // 담당자 정보 가져오기
            getAccountInfo();       // 고객사 정보 가져오기
            getIncomeExpenses();    // 신규개설품의 obj 값 가져오기
            getExpectManager();  // 품의서 관리자 작성 obj 값 가져오기 [4] 
            getDistributeCost(); // 물류비관리 값 가져오기 [5]
        }







    }

    /* 
    Picklist 값을 가져오는 메소드
    */
    public void getPicklistValues() {
        // 브랜드 경로
        Schema.DescribeFieldResult brandChannelResult = CJFW_ExpectedIncomeExpenses__c.BrandChannel__c.getDescribe();
        // 담보 종류
        Schema.DescribeFieldResult collateralResult = CJFW_ExpectedIncomeExpenses__c.CollateralType__c.getDescribe();
        // 여신 관리
        Schema.DescribeFieldResult loanManageResult = CJFW_ExpectedIncomeExpenses__c.LoanManage__c.getDescribe();
        // 결제 수단
        Schema.DescribeFieldResult paymentPick = CJFW_ExpectedIncomeExpenses__c.PaymentMethod__c.getDescribe();
        // 계약서종류 
        Schema.DescribeFieldResult contractTypePick = CJFW_ExpectedIncomeExpenses__c.ContractType__c.getDescribe(); 
        // 배송 횟수
        Schema.DescribeFieldResult deliveryTypePick = CJFW_ExpectedIncomeExpenses__c.DeliveryCnt__c.getDescribe(); 

        List<Schema.PicklistEntry> brandChannelValues = brandChannelResult.getPicklistValues();
        List<Schema.PicklistEntry> collateralValues = collateralResult.getPicklistValues();
        List<Schema.PicklistEntry> loanManageValues = loanManageResult.getPicklistValues();
        List<Schema.PicklistEntry> paymentValues = paymentPick.getPicklistValues();
        List<Schema.PicklistEntry> contractValues = contractTypePick.getPicklistValues();
        List<Schema.PicklistEntry> deliveryValues = deliveryTypePick.getPicklistValues();

        
        brandChannelPickList = new List<SelectOption>();
        collateralPickList = new List<SelectOption>();
        loanManagePickList = new List<SelectOption>();
        paymentPickList = new List<SelectOption>();
        contractPickList = new List<SelectOption>();
        deliveryPickList = new List<SelectOption>();

        for (Schema.PicklistEntry picklistValue : brandChannelValues) {
            brandChannelPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }
        for (Schema.PicklistEntry picklistValue : collateralValues) {
            collateralPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }
        for (Schema.PicklistEntry picklistValue : loanManageValues) {
            loanManagePickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }
        for (Schema.PicklistEntry picklistValue : paymentValues) {
            paymentPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }
        for (Schema.PicklistEntry picklistValue : contractValues) {
            contractPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }
        for (Schema.PicklistEntry picklistValue : deliveryValues) { // 배송횟수
            deliveryPickList.add(new SelectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }
        System.debug(' 배송횟수 테스트  test ' + deliveryPickList);
        // System.debug(' 브랜드 경로 pickList 값 ' + brandChannelPickList);
        // System.debug(' 담보제공종류 pickList 값 ' + collateralPickList);
        // System.debug(' 여신관리 pickList 값 ' + loanManagePickList);
        // System.debug(' 결제수단종류 pickList 값 ' + paymentPickList);
        // System.debug(' 계약서종류 pickList 값 ' + contractPickList);
    }





    /* 
    Oppty 에 있는 Account 값을 가져오는 메소드
    */
    public void getOpptyInfo() {

        
        Opportunity getOppty = [SELECT Id, Name, Owner.TeamLabel__c, Owner.Name
                            FROM Opportunity
                            WHERE Id = :opportunityId
        ];

        // System.debug('#oppty => '+ oppty);
        // System.debug('#getOppty.Owner.teamlable__c => '+ getOppty.Owner.TeamLabel__c);
        // System.debug('#getOppty.Owner.Name => '+ getOppty.Owner.Name);
        
        // 필드 값이 null일 경우 빈값으로 처리
        getOppty.Owner.TeamLabel__c = getOppty.Owner.TeamLabel__c != null ? getOppty.Owner.TeamLabel__c : ''; 
        opptyInfo = getOppty;
    }

    
    /* 
    Oppty 에 있는 Account 값을 가져오는 메소드
    */
   public void getAccountInfo() {

        // System.debug('# opportunityId ->' + opportunityId );
        // System.debug('# incomeExpensesId ->' + incomeExpensesId );
        // System.debug('# showtable ->' + showtable );

        
        // 기회 레코드에서 계정 ID 가져오기 
        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1].AccountId;

        if (accountId != null) {
            // 계정 정보를 쿼리
            accountInfo = [SELECT 
                                Id,
                                Name,
                                RepresentativeName__c,
                                SalesMonthly__c,
                                Address__c,
                                PV_EXISTSUP__c 
                            FROM Account 
                            WHERE Id = :accountId 
                        ];

            String[] defaultValSet = new String[] {
                'RepresentativeName__c',
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
    예산손익(CJFW_ExpectedIncomeExpenses__c) 에서 값 가져오기
    VF Page 초기호출시  
    */
    public void getIncomeExpenses() {
        System.debug('# ReportFormController # getIncomeExpenses');
        try {
            String query = ' SELECT Id, ' +
            'Version__c, ' +                        
            'IsReportCheck__c, ' +                        
            'KeyMan__c, ' +                         //키맨    
            'ContactMethod__c, ' +                  //접촉방법
            'FirstContact__c, ' +                   //최초접촉시기
            'ObtainOrder__c, ' +                    //수주팀
            'MainMA__c, ' +                         //담당MA

            'ClientCompanyName__c, ' +              //거래처명
            'RepresentativeName__c, ' +             //대표자명
            'BrandLaunching__c, ' +                 //브랜드 런칭
            'BrandManage__c, ' +                    //운영 브랜드
            'BrandChannel__c, ' +                   //브랜드 경로
            'BrandBusinessCondition__c, ' +         //업태
            'SalesMonthly__c, ' +                  //외형 전체
            'OutwardCompanySize__c, ' +             //당사규모
            'OutwardDifference__c, ' +              //외형 차이
            'InitialDate__c, ' +                    //초도일자
            'Address__c, ' +                        //주소
            'PV_EXISTSUP__c, ' +                    //기존납품처

            'ContractStartDate__c, ' +              //계약시작기간
            'ContractEndDate__c, ' +                //계약종료기간
            'CollateralType__c, ' +                 //담보종류
            'CollateralAmount__c, ' +               //담보금액
            'CollateralPeriod__c, ' +               //담보기간
            'CreditLoanAmount__c, ' +               //신용여신금액
            'SalesFeeGeneral__c, ' +                //AS-IS일반
            'SalesFeeExclusive__c, ' +              //AS-IS전용
            'SalesFeeCountryside__c, ' +            //AS-IS지방
            'SalesFeeGeneralTOBE__c, ' +            //TO-BE일반
            'SalesFeeExclusiveTOBE__c, ' +          //TO-BE전용
            'SalesFeeCountrysideTOBE__c, ' +        //TO-BE지방
            'LoanManage__c, ' +                     //여신관리
            'PaymentMethod__c, ' +                  //결제수단
            'ContractPaymentDate__c, ' +            //약정결제일
            'ContractType__c, ' +                   //계약서 종류
            //김설 추가
            // 매출
            'SalesNameOne__c, ' +
            'SalesNameTwo__c, ' +
            'SalesNameThree__c, ' +
            'SalesNameFour__c, ' +

            'SalesCapOne__c, ' +
            'SalesCapTwo__c, ' +
            'SalesCapThree__c, ' +
            'SalesCapFour__c, ' +

            'SalesEastOne__c, ' +
            'SalesEastTwo__c, ' +
            'SalesEastThree__c, ' +
            'SalesEastFour__c, ' +

            'SalesWestOne__c, ' +
            'SalesWestTwo__c, ' +
            'SalesWestThree__c, ' +
            'SalesWestFour__c, ' +

            'SalesJejuOne__c, ' +
            'SalesJejuTwo__c, ' +
            'SalesJejuThree__c, ' +
            'SalesJejuFour__c, ' +

            'SalesMonthFoOne__c, ' +
            'SalesMonthFoTwo__c, ' +
            'SalesMonthFoThree__c, ' +
            'SalesMonthFoFour__c, ' +

            'SalesSoluOne__c, ' +
            'SalesSoluTwo__c, ' +
            'SalesSoluThree__c, ' +
            'SalesSoluFour__c, ' +
            // 매출이익
            'SalesProfitNameOne__c, ' +
            'SalesProfitNameTwo__c, ' +
            'SalesProfitNameThree__c, ' +
            'SalesProfitNameFour__c, ' +

            'SalesProfitCapOne__c, ' +
            'SalesProfitCapTwo__c, ' +
            'SalesProfitCapThree__c, ' +
            'SalesProfitCapFour__c, ' +

            'SalesProfitEastOne__c, ' +
            'SalesProfitEastTwo__c, ' +
            'SalesProfitEastThree__c, ' +
            'SalesProfitEastFour__c, ' +

            'SalesProfitWestOne__c, ' +
            'SalesProfitWestTwo__c, ' +
            'SalesProfitWestThree__c, ' +
            'SalesProfitWestFour__c, ' +

            'SalesProfitJejuOne__c, ' +
            'SalesProfitJejuTwo__c, ' +
            'SalesProfitJejuThree__c, ' +
            'SalesProfitJejuFour__c, ' +

            'SalesProfitFoOne__c, ' +
            'SalesProfitFoTwo__c, ' +
            'SalesProfitFoThree__c, ' +
            'SalesProfitFoFour__c, ' +

            'SalesProfitSoluOne__c, ' +
            'SalesProfitSoluTwo__c, ' +
            'SalesProfitSoluThree__c, ' +
            'SalesProfitSoluFour__c, ' +

            // 매익률
            'ProfitRateNameOne__c, ' +
            'ProfitRateNameTwo__c, ' +
            'ProfitRateNameThree__c, ' +
            'ProfitRateNameFour__c, ' +

            // 판매처 수     
            'SalesLocationCntFo__c, ' +          
 
            //물류비 직접비
            'DistributeDirCap__c, ' +
            'DistributeDirEast__c, ' +
            'DistributeDirWest__c, ' +
            'DistributeDirJeju__c, ' +          
            'DistributeDirFo__c, ' +   

            //물류비 간접비
            'DistributeInDirCap__c, ' +
            'DistributeInDirEast__c, ' +
            'DistributeInDirWest__c, ' +
            'DistributeInDirJeju__c, ' +          
            'DistributeInDirFo__c, ' +   

            'SalesFoEx__c, ' +   
            'SalesFoGen__c, ' +   
            'SalesProfitFoEx__c, ' +   
            'SalesProfitFoGen__c, ' +   
            'SalesProfitSoluEx__c, ' +   

            // 김설 추가 끝
            'Sales__c, ' +                           //매출
            'ExclusiveSaveSkuSales__c, ' +           //전용저장 sku매출
            'DropSize__c, ' +                        //회당 Drop Size
            'AverageSales__c, ' +                    //점당 평균매출
            'DeliveryNumber__c, ' +                  //배송 횟수
            'ContributionMargin__c, ' +              //공헌이익%
            'KgExclusiveProduct__c, ' +              //전용상품
            'KgGeneralProduct__c, ' +                //일반상품
            'KgTotalAmount__c, ' +                   //계
            'SkuReleaseEa__c,' +                     //출고단위 EA
            'SkuReleaseBox__c, ' +                   //출고단위 BOX

            'SalesCapitalExclusive__c, ' +           // 외식전용 필드 ↓ :매출 수도권 전용
            'SalesCapitalGeneral__c, ' +             // 매출 수도권 일반
            'SalesEastExclusive__c, ' +              // 매출 동부권 전용
            'SalesEastGeneral__c, ' +                // 매출 동부권 일반
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
            'DeliveryCnt__c, ' + // 배송횟수

            'SalesMoreThousand__c, ' +               //매출액 1천이상
            'SalesMoreFiveHundred__c, ' +            //매출액 5백이상
            'SalesLessFiveHundred__c, ' +            //매출액 5백미만
            'SalesLessThreeHundred__c, ' +           //매출액 3백미만
            'StoreMoreThousand__c, ' +               //점포수 1천이상
            'StoreMoreFiveHundred__c, ' +            //점포수 5백이상
            'StoreLessFiveHundred__c, ' +            //점포수 5백미만
            'StoreLessThreeHundred__c, ' +            //점포수 3백미만    

            'ProductNameOne__c, ' +             //상품명 1 
            'StorageConditionOne__c, ' +        //저장조건 1 
            'ReleaseUnitOne__c, ' +             //출고단위 1 
            'EnforcementMonthOne__c, ' +        //시행월 1
            'PltOriginalOne__c, ' +             //PTL운영 계획 1  
            'PltPlanOne__c, ' +                 //PTL운영 기존 1  
            'StockMoneyOriginalOne__c, ' +      //재고금액 기존 1  
            'StockMoneyPlanOne__c, ' +          //재고금액 계획 1
            'MonthSaleOne__c, ' +               //매출 1
            'MonthSalesProfitOne__c, ' +        //매출이익 1 

            'ProductNameTwo__c, ' +            //상품명 2 
            'StorageConditionTwo__c, ' +            //저장조건 2 
            'ReleaseUnitTwo__c, ' +            //출고단위 2 
            'EnforcementMonthTwo__c, ' +            //시행월 2
            'PltOriginalTwo__c, ' +            //PTL운영 기존 2  
            'PltPlanTwo__c, ' +            //PTL운영 계획 2  
            'StockMoneyOriginalTwo__c, ' +            //재고금액 기존 2  
            'StockMoneyPlanTwo__c, ' +            //재고금액 계획 2
            'MonthSaleTwo__c, ' +            //매출 2
            'MonthSalesProfitTwo__c, ' +            //매출이익 2 

            'ProductNameThree__c, ' +            //상품명 3 
            'StorageConditionThree__c, ' +            //저장조건 3 
            'ReleaseUnitThree__c, ' +            //출고단위 3 
            'EnforcementMonthThree__c, ' +            //시행월 3
            'PltOriginalThree__c, ' +            //PTL운영 기존 3  
            'PltPlanThree__c, ' +            //PTL운영 계획 3  
            'StockMoneyOriginalThree__c, ' +            //재고금액 기존 3  
            'StockMoneyPlanThree__c, ' +            //재고금액 계획 3
            'MonthSaleThree__c, ' +            //매출 3
            'MonthSalesProfitThree__c, ' +            //매출이익 3 

            'ProductNameFour__c, ' +            //상품명 4
            'StorageConditionFour__c, ' +            //저장조건 4 
            'ReleaseUnitFour__c, ' +            //출고단위 4 
            'EnforcementMonthFour__c, ' +            //시행월 4
            'PltOriginalFour__c, ' +            //PTL운영 기존 4  
            'PltPlanFour__c, ' +            //PTL운영 계획 4  
            'StockMoneyOriginalFour__c, ' +            //재고금액 기존 4  
            'StockMoneyPlanFour__c, ' +            //재고금액 계획 4
            'MonthSaleFour__c, ' +            //매출 4
            'MonthSalesProfitFour__c, ' +            //매출이익 4 

            'ProductNameFive__c, ' +            //상품명 5
            'StorageConditionFive__c, ' +            //저장조건 5 
            'ReleaseUnitFive__c, ' +            //출고단위 5 
            'EnforcementMonthFive__c, ' +            //시행월 5
            'PltOriginalFive__c, ' +            //PTL운영 기존 5  
            'PltPlanFive__c, ' +            //PTL운영 계획 5  
            'StockMoneyOriginalFive__c, ' +            //재고금액 기존 5  
            'StockMoneyPlanFive__c, ' +            //재고금액 계획 5
            'MonthSaleFive__c, ' +            //매출 5
            'MonthSalesProfitFive__c, ' +            //매출이익 5 
            
            'ProductNameSix__c, ' +            //상품명 6
            'StorageConditionSix__c, ' +            //저장조건 6 
            'ReleaseUnitSix__c, ' +            //출고단위 6 
            'EnforcementMonthSix__c, ' +            //시행월 6
            'PltOriginalSix__c, ' +            //PTL운영 기존 6  
            'PltPlanSix__c, ' +            //PTL운영 계획 6  
            'StockMoneyOriginalSix__c, ' +            //재고금액 기존 6  
            'StockMoneyPlanSix__c, ' +            //재고금액 계획 6
            'MonthSaleSix__c, ' +            //매출 6
            'MonthSalesProfitSix__c, ' +            //매출이익 6 
            
            'ProductNameSeven__c, ' +            //상품명 7
            'StorageConditionSeven__c, ' +            //저장조건 7 
            'ReleaseUnitSeven__c, ' +            //출고단위 7 
            'EnforcementMonthSeven__c, ' +            //시행월 7
            'PltOriginalSeven__c, ' +            //PTL운영 기존 7  
            'PltPlanSeven__c, ' +            //PTL운영 계획 7  
            'StockMoneyOriginalSeven__c, ' +            //재고금액 기존 7  
            'StockMoneyPlanSeven__c, ' +            //재고금액 계획 7
            'MonthSaleSeven__c, ' +            //매출 7
            'MonthSalesProfitSeven__c, ' +            //매출이익 7 
            
            'ProductNameEight__c, ' +            //상품명 8
            'StorageConditionEight__c, ' +            //저장조건 8 
            'ReleaseUnitEight__c, ' +            //출고단위 8 
            'EnforcementMonthEight__c, ' +            //시행월 8
            'PltOriginalEight__c, ' +            //PTL운영 기존 8  
            'PltPlanEight__c, ' +            //PTL운영 계획 8  
            'StockMoneyOriginalEight__c, ' +            //재고금액 기존 8  
            'StockMoneyPlanEight__c, ' +            //재고금액 계획 8
            'MonthSaleEight__c, ' +            //매출 8
            'MonthSalesProfitEight__c, ' +            //매출이익 8 
            
            'ProductNameNine__c, ' +            //상품명 9
            'StorageConditionNine__c, ' +            //저장조건 9 
            'ReleaseUnitNine__c, ' +            //출고단위 9 
            'EnforcementMonthNine__c, ' +            //시행월 9
            'PltOriginalNine__c, ' +            //PTL운영 기존 9  
            'PltPlanNine__c, ' +            //PTL운영 계획 9  
            'StockMoneyOriginalNine__c, ' +            //재고금액 기존 9  
            'StockMoneyPlanNine__c, ' +            //재고금액 계획 9
            'MonthSaleNine__c, ' +            //매출 9
            'MonthSalesProfitNine__c, ' +            //매출이익 9 
            
            'ProductNameTen__c, ' +            //상품명 10
            'StorageConditionTen__c, ' +            //저장조건 10 
            'ReleaseUnitTen__c, ' +            //출고단위 10 
            'EnforcementMonthTen__c, ' +            //시행월 10
            'PltOriginalTen__c, ' +            //PTL운영 기존 10  
            'PltPlanTen__c, ' +            //PTL운영 계획 10  
            'StockMoneyOriginalTen__c, ' +            //재고금액 기존 10  
            'StockMoneyPlanTen__c, ' +            //재고금액 계획 10
            'MonthSaleTen__c, ' +            //매출 10
            'MonthSalesProfitTen__c' +            //매출이익 10 
            
            

            ' FROM CJFW_ExpectedIncomeExpenses__c';

            if (incomeExpensesId != null) {
                query += ' WHERE id = :incomeExpensesId ';
            }else if (opportunityId != null) {
                query += ' WHERE Opportunity__c = :opportunityId AND ReportType__c =:reportType';
            }

            if(showtable =='true'){
                query += ' ORDER BY IsReportCheck__c DESC LIMIT 1';
            }else{
                query += ' ORDER BY Version__c DESC LIMIT 1';
            }


            System.debug('# query ->' + query );
            List<CJFW_ExpectedIncomeExpenses__c> incomeExpensesList = Database.query(query);

            if (!incomeExpensesList.isEmpty()) {    //값이 있을때 
                IncomeExpensesInfo = incomeExpensesList[0];
                versionCheck = ( incomeExpensesList[0].Version__c ) + 1 ;
                reportCheck = ( incomeExpensesList[0].IsReportCheck__c );
            } else {    //값이 없을때 
                versionCheck = 1;
                IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c();
            }

        }catch (QueryException e) {
            IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c(); // 빈 레코드로 초기화
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
        }

        System.debug('IncomeExpensesInfo 결과 = '+ IncomeExpensesInfo);
        
        /* number 타입 갑이 없을 경우 0.00으로 초기값 세팅 */
        String[] defaultValSet = new String[] {
            'SalesFeeGeneral__c',                //AS-IS일반
            'SalesFeeExclusive__c',              //AS-IS전용
            'SalesFeeCountryside__c',            //AS-IS지방
            'SalesFeeGeneralTOBE__c',            //TO-BE일반
            'SalesFeeExclusiveTOBE__c',          //TO-BE전용
            'SalesFeeCountrysideTOBE__c',        //TO-BE지방

            'SalesMoreThousand__c',              //매출액 1천이상
            'SalesMoreFiveHundred__c',           //매출액 5백이상
            'SalesLessFiveHundred__c',           //매출액 5백미만
            'SalesLessThreeHundred__c',           //매출액 3백미만

            'Sales__c',                          //수주가이드 매출
            'ExclusiveSaveSkuSales__c',          //전용저장 sku매출
            'DropSize__c',                       //회당 Drop Size
            'AverageSales__c',                   //점당 평균매출
            'ContributionMargin__c',              //공헌이익%

            'SalesCapitalExclusive__c',         
            'SalesEastExclusive__c',
            'SalesWestExclusive__c',
            'SalesJejuExclusive__c',

            'SalesCapitalGeneral__c',
            'SalesEastGeneral__c',
            'SalesWestGeneral__c',
            'SalesJejuGeneral__c',

            'ProfitRateExclusive__c',
            'ProfitRateGeneral__c',

            'SalesSolutionExclusive__c',
            'SalesSolutionGeneral__c',
            'SalesImproveResultExclusive__c',
            'SalesImproveResultGeneral__c',

            'ProfitRateCapitalExclusive__c',
            'ProfitRateEastExclusive__c',
            'ProfitRateWestExclusive__c',
            'ProfitRateJejuExclusive__c',

            'ProfitRateCapitalGeneral__c',
            'ProfitRateEastGeneral__c',
            'ProfitRateWestGeneral__c',
            'ProfitRateJejuGeneral__c',

            'SalesProfitCaptialExclusive__c',
            'SalesProfitEastExclusive__c',
            'SalesProfitWestExclusive__c',
            'SalesProfitJejuExclusive__c',

            'SalesLocationCntCapital__c',
            'SalesLocationCntEast__c',
            'SalesLocationCntWest__c',
            'SalesLocationCntJeju__c',

            'SalesPerStoreCapital__c',
            'SalesPerStoreEast__c',
            'SalesPerStoreWest__c',
            'SalesPerStoreJeju__c',

            'DropSizeCapital__c',
            'DropSizeEast__c',
            'DropSizeWest__c',
            'DropSizeJeju__c',

            'SalesProfitCapitalGeneral__c',
            'SalesProfitEastGeneral__c',
            'SalesProfitWestGeneral__c',
            'SalesProfitJejuGeneral__c',

            //김설 추가 
            'SalesCapOne__c',
            'SalesCapTwo__c',
            'SalesCapThree__c',
            'SalesCapFour__c',
            'SalesEastOne__c',
            'SalesEastTwo__c',
            'SalesEastThree__c',
            'SalesEastFour__c',
            'SalesWestOne__c',
            'SalesWestTwo__c',
            'SalesWestThree__c',
            'SalesWestFour__c',
            'SalesJejuOne__c',
            'SalesJejuTwo__c',
            'SalesJejuThree__c',
            'SalesJejuFour__c',
            'SalesMonthFoOne__c',
            'SalesMonthFoTwo__c',
            'SalesMonthFoThree__c',
            'SalesMonthFoFour__c',
            'SalesSoluOne__c',
            'SalesSoluTwo__c',
            'SalesSoluThree__c',
            'SalesSoluFour__c',
            'SalesProfitCapOne__c',
            'SalesProfitCapTwo__c',
            'SalesProfitCapThree__c',
            'SalesProfitCapFour__c',
            'SalesProfitEastOne__c',
            'SalesProfitEastTwo__c',
            'SalesProfitEastThree__c',
            'SalesProfitEastFour__c',
            'SalesProfitWestOne__c',
            'SalesProfitWestTwo__c',
            'SalesProfitWestThree__c',
            'SalesProfitWestFour__c',
            'SalesProfitJejuOne__c',
            'SalesProfitJejuTwo__c',
            'SalesProfitJejuThree__c',
            'SalesProfitJejuFour__c',
            'SalesProfitFoOne__c',
            'SalesProfitFoTwo__c',
            'SalesProfitFoThree__c',
            'SalesProfitFoFour__c',
            'SalesProfitSoluOne__c',
            'SalesProfitSoluTwo__c',
            'SalesProfitSoluThree__c',
            'SalesProfitSoluFour__c',
            'SalesLocationCntFo__c',
            'DistributeDirCap__c',
            'DistributeDirEast__c',
            'DistributeDirWest__c',
            'DistributeDirJeju__c',
            'DistributeDirFo__c',
            'DistributeInDirCap__c',
            'DistributeInDirEast__c',
            'DistributeInDirWest__c',
            'DistributeInDirJeju__c',
            'DistributeInDirFo__c',
            'SalesFoEx__c',
            'SalesFoGen__c',
            'SalesProfitFoEx__c',
            'SalesProfitFoGen__c',
            'SalesProfitSoluEx__c',

            'PltOriginalOne__c',
            'PltPlanOne__c',
            'StockMoneyOriginalOne__c',
            'StockMoneyPlanOne__c',
            'MonthSaleOne__c',
            'MonthSalesProfitOne__c',


            'PltOriginalTwo__c',
            'PltPlanTwo__c',
            'StockMoneyOriginalTwo__c',
            'StockMoneyPlanTwo__c',
            'MonthSaleTwo__c',
            'MonthSalesProfitTwo__c',


            
            'PltOriginalThree__c',
            'PltPlanThree__c',
            'StockMoneyOriginalThree__c',
            'StockMoneyPlanThree__c',
            'MonthSaleThree__c',
            'MonthSalesProfitThree__c',

            'PltOriginalFour__c',
            'PltPlanFour__c',
            'StockMoneyOriginalFour__c',
            'StockMoneyPlanFour__c',
            'MonthSaleFour__c',
            'MonthSalesProfitFour__c',


            'PltOriginalFive__c',
            'PltPlanFive__c',
            'StockMoneyOriginalFive__c',
            'StockMoneyPlanFive__c',
            'MonthSaleFive__c',
            'MonthSalesProfitFive__c',


            'PltOriginalSix__c',
            'PltPlanSix__c',
            'StockMoneyOriginalSix__c',
            'StockMoneyPlanSix__c',
            'MonthSaleSix__c',
            'MonthSalesProfitSix__c',


            'PltOriginalSeven__c',
            'PltPlanSeven__c',
            'StockMoneyOriginalSeven__c',
            'StockMoneyPlanSeven__c',
            'MonthSaleSeven__c',
            'MonthSalesProfitSeven__c',


            'PltOriginalEight__c',
            'PltPlanEight__c',
            'StockMoneyOriginalEight__c',
            'StockMoneyPlanEight__c',
            'MonthSaleEight__c',
            'MonthSalesProfitEight__c',


            'PltOriginalNine__c',
            'PltPlanNine__c',
            'StockMoneyOriginalNine__c',
            'StockMoneyPlanNine__c',
            'MonthSaleNine__c',
            'MonthSalesProfitNine__c',


            'PltOriginalTen__c',
            'PltPlanTen__c',
            'StockMoneyOriginalTen__c',
            'StockMoneyPlanTen__c',
            'MonthSaleTen__c',
            'MonthSalesProfitTen__c'
            
        };

        for (String defaultSet : defaultValSet) {
            Object fieldValue = IncomeExpensesInfo.get(defaultSet);

            if (fieldValue == null) fieldValue = 0.00; 
            IncomeExpensesInfo.put(defaultSet, fieldValue);

        }

        /* number 타입 갑이 없을 경우 0으로 초기값 세팅 */
        String[] defaultValPerSet = new String[] {
            'CollateralAmount__c',               //담보금액
            'CreditLoanAmount__c',               //신용여신금액
            'StoreMoreThousand__c',              //점포수 1천이상
            'StoreMoreFiveHundred__c',           //점포수 5백이상
            'StoreLessFiveHundred__c',           //점포수 5백미만
            'StoreLessThreeHundred__c',          //점포수 3백미만    
                   
            'DeliveryNumber__c',                 //배송 횟수
            'KgExclusiveProduct__c',             //전용상품
            'KgGeneralProduct__c',               //일반상품
            'KgTotalAmount__c',                  //계
            'SkuReleaseBox__c',                  //출고단위 BOX
            'SkuReleaseEa__c'                    //출고단위 EA           
        };
        for (String defaultSet : defaultValPerSet) {
            Object fieldPerValue = IncomeExpensesInfo.get(defaultSet);

            if (fieldPerValue == null) fieldPerValue = 0; 
            IncomeExpensesInfo.put(defaultSet, fieldPerValue);
        }

        /* Date 필드를 yyyy-MM-dd 형식의 문자열로 변환 */
        String firstContactString = String.valueOf(IncomeExpensesInfo.FirstContact__c); // 최초접촉시기
        String initialDateString = String.valueOf(IncomeExpensesInfo.InitialDate__c); // 초도일자 
        String contractStartString = String.valueOf(IncomeExpensesInfo.ContractStartDate__c); // 계약시작일자
        String contractEndString = String.valueOf(IncomeExpensesInfo.ContractEndDate__c); // 계약종료일자 
        String collateralPeriodString = String.valueOf(IncomeExpensesInfo.CollateralPeriod__c); // 담보기간
        String contractPaymentDateString = String.valueOf(IncomeExpensesInfo.ContractPaymentDate__c);   //약정결제일

        firstContact = firstContactString != null ? firstContactString.substring(0, 10) : null;
        initialDate = initialDateString != null ? initialDateString.substring(0, 10) : null;
        contractStartDate = contractStartString != null ? contractStartString.substring(0, 10) : null;
        contractEndDate = contractEndString != null ? contractEndString.substring(0, 10) : null;
        collateralPeriod = collateralPeriodString != null ? collateralPeriodString.substring(0, 10) : null;
        contractPaymentDate = contractPaymentDateString != null ? contractPaymentDateString.substring(0, 10) : null;


        /* pickList 저장된 값 가져오기 */
        selectedBrandChannel = IncomeExpensesInfo.BrandChannel__c;  // 브랜드 경로
        selectedCollateral = IncomeExpensesInfo.CollateralType__c;  // 담보종류
        selectedLoanManage = IncomeExpensesInfo.LoanManage__c	;   // 여신관리
        selectedPayment = IncomeExpensesInfo.PaymentMethod__c;      // 결제수단 
        selectedContract = IncomeExpensesInfo.ContractType__c	;   // 계약서종류 
        selectedDelivery = IncomeExpensesInfo.DeliveryCnt__c	; // 배송횟수 

        /* 2. 거래처 현황 account info 값을 참고로 IncomeExpensesInfo 에 담아주기 
            -> IncomeExpensesInfo 필드에 값이 있는지 먼저 체크 > 값이 없으면 accountInfo 에서 값 땡겨옴 */
        // 거래처명 (text)
        if( IncomeExpensesInfo.ClientCompanyName__c == '' || IncomeExpensesInfo.ClientCompanyName__c == null ){
            IncomeExpensesInfo.put('ClientCompanyName__c', accountInfo.get('Name') );
        }
        // 대표자명 (text)
        if(IncomeExpensesInfo.RepresentativeName__c == '' || IncomeExpensesInfo.RepresentativeName__c == null ){
            IncomeExpensesInfo.put('RepresentativeName__c', accountInfo.get('RepresentativeName__c') );
        }
        // 주소 (text)
        if( IncomeExpensesInfo.Address__c == '' || IncomeExpensesInfo.Address__c == null ){
            IncomeExpensesInfo.put('Address__c', accountInfo.get('Address__c') );
        }
        // 기존납품처 
        if(IncomeExpensesInfo.PV_EXISTSUP__c == '' || IncomeExpensesInfo.PV_EXISTSUP__c == null ){
            IncomeExpensesInfo.put('PV_EXISTSUP__c', accountInfo.get('PV_EXISTSUP__c') );
        }
        // 전체외형 (decimal)
        if(IncomeExpensesInfo.SalesMonthly__c == 0 || IncomeExpensesInfo.SalesMonthly__c == null){
            IncomeExpensesInfo.put('SalesMonthly__c', accountInfo.get('SalesMonthly__c') );
        }

        System.debug('# 품의서정보  ->' + IncomeExpensesInfo ); 
    }

    /* 
    CJFW_OrderConsiderNewForm (VF Page) 에서 입력받은 값 update   
    */
    @RemoteAction
    public static String saveIncomeExpenses(String DataList, String opportunityId, Decimal versionCheck, String incomeExpensesId, String reportType) {
        try {
            System.debug('DataList ' + DataList);
            System.debug('opportunityId ' + opportunityId);
            System.debug('versionCheck ' + versionCheck);
            System.debug('incomeExpensesId ' + incomeExpensesId);
            System.debug('saveIncomeExpenses reportType ' + reportType);

            
            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(DataList);
            System.debug('넘어온 데이터! ' + dataMap);
            
            CJFW_ExpectedIncomeExpenses__c expectIncome;

            if (incomeExpensesId != null && incomeExpensesId != '') {
                System.debug('update ★-> ' + incomeExpensesId);
                expectIncome = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c WHERE Id = :incomeExpensesId];
            } else { // insert 
                System.debug('insert ★-> ');
                expectIncome = new CJFW_ExpectedIncomeExpenses__c();
                expectIncome.Version__c = versionCheck;      // 필수값
                expectIncome.Opportunity__c = opportunityId; //필수값
                if(versionCheck == 1) expectIncome.IsReportCheck__c = true; // 초기 insert 시에 품의지정 default 세팅
            }

            expectIncome.saveResult__c = DataList;
            expectIncome.ReportType__c = reportType;  //품의서 종류에 따라 타입설정 (CRM009: 외식SU 계약 품의서)
           

            /* ===== 1. 개요 ===== */
            if (dataMap.containsKey('keyMan')) { // keyMan
                expectIncome.KeyMan__c = (String)dataMap.get('keyMan');
            }
            if (dataMap.containsKey('contactMethod')) { // 접촉방법
                expectIncome.ContactMethod__c = (String)dataMap.get('contactMethod');
            }
            if (dataMap.containsKey('firstContact') && dataMap.get('firstContact') !='') { // 최초접촉시기
                expectIncome.FirstContact__c = Date.valueOf(((String) dataMap.get('firstContact')));
            }
            if (dataMap.containsKey('obtainOrder')) { // 수주팀
                expectIncome.ObtainOrder__c = (String)dataMap.get('obtainOrder');
            }
            if (dataMap.containsKey('mainMA')) { // 담당MA
                expectIncome.MainMA__c = (String)dataMap.get('mainMA');
            }

            /* ===== 2. 거래처 현황 ===== */
            if (dataMap.containsKey('accountName')) { // 거래처명 (text)
                expectIncome.ClientCompanyName__c = (String) dataMap.get('accountName');
            }
            if (dataMap.containsKey('ownerName')) { // 대표자명 (text)
                expectIncome.RepresentativeName__c = (String) dataMap.get('ownerName');
            }
            if (dataMap.containsKey('brandLaunching')) { // 브랜드 런칭	
                expectIncome.BrandLaunching__c = (String) dataMap.get('brandLaunching');
            }
            if (dataMap.containsKey('brandManage')) { // 운영 브랜드	
                expectIncome.BrandManage__c = (String) dataMap.get('brandManage');
            }
            if (dataMap.containsKey('brandChannel')) { // 경로
                expectIncome.BrandChannel__c = (String) dataMap.get('brandChannel');
            }
            if (dataMap.containsKey('brandBusinessCondition')) { // 업태
                expectIncome.BrandBusinessCondition__c = (String) dataMap.get('brandBusinessCondition');
            }
            if (dataMap.containsKey('outwardEntire')) { // 전체외형 (정수)
                expectIncome.SalesMonthly__c = convertToDecimal(dataMap.get('outwardEntire'));
            }
            if (dataMap.containsKey('outwardCompanySize')) { // 당사규모
                expectIncome.OutwardCompanySize__c = (String) dataMap.get('outwardCompanySize');
            }
            if (dataMap.containsKey('outwardDifference')) { // 차이
                expectIncome.OutwardDifference__c = (String) dataMap.get('outwardDifference');
            }
            if (dataMap.containsKey('initialDate') && dataMap.get('initialDate') !='') { // 초도일자 (date)
                expectIncome.InitialDate__c = Date.valueOf(((String) dataMap.get('initialDate')));
            }
            if (dataMap.containsKey('accountAddress')) { // 주소 (text)
                expectIncome.Address__c = (String) dataMap.get('accountAddress');
            }
            if (dataMap.containsKey('existGoods')) { // 기존납품처 (text)
                expectIncome.PV_EXISTSUP__c = (String) dataMap.get('existGoods');
            }

            /* ===== 3. 거래 상세내용 ===== */
            if (dataMap.containsKey('contractStartDate') && dataMap.get('contractStartDate') !='') { // 계약기간시작
                expectIncome.ContractStartDate__c = Date.valueOf(((String) dataMap.get('contractStartDate')));
            }
            if (dataMap.containsKey('contractEndDate') && dataMap.get('contractEndDate') !='') { // 계약기간종료
                expectIncome.ContractEndDate__c = Date.valueOf(((String) dataMap.get('contractEndDate')));
            }
            if (dataMap.containsKey('collateralType')) { // 담보종류
                expectIncome.CollateralType__c = (String) dataMap.get('collateralType');
            }
            if (dataMap.containsKey('collateralAmount')) { //담보금액
                expectIncome.CollateralAmount__c = convertToDecimal(dataMap.get('collateralAmount'));
            }
            if (dataMap.containsKey('collateralPeriod') && dataMap.get('collateralPeriod') !='') { // 담보기간
                expectIncome.CollateralPeriod__c = Date.valueOf(((String) dataMap.get('collateralPeriod')));
            }
            if (dataMap.containsKey('creditLoanAmount')) { //신용여신금액
                expectIncome.CreditLoanAmount__c = convertToDecimal(dataMap.get('creditLoanAmount'));
            }
            if (dataMap.containsKey('salesFeeGeneral')) { //AS-IS일반
                expectIncome.SalesFeeGeneral__c = convertToDecimal(dataMap.get('salesFeeGeneral'));
            }
            if (dataMap.containsKey('salesFeeExclusive')) { //AS-IS전용
                expectIncome.SalesFeeExclusive__c = convertToDecimal(dataMap.get('salesFeeExclusive'));
            }
            if (dataMap.containsKey('salesFeeCountryside')) { //AS-IS지방
                expectIncome.SalesFeeCountryside__c = convertToDecimal(dataMap.get('salesFeeCountryside'));
            }
            if (dataMap.containsKey('salesFeeGeneralTOBE')) { //TO-BE일반
                expectIncome.SalesFeeGeneralTOBE__c = convertToDecimal(dataMap.get('salesFeeGeneralTOBE'));
            }
            if (dataMap.containsKey('salesFeeExclusiveTOBE')) { //TO-BE전용
                expectIncome.SalesFeeExclusiveTOBE__c = convertToDecimal(dataMap.get('salesFeeExclusiveTOBE'));
            }
            if (dataMap.containsKey('salesFeeCountrysideTOBE')) { ///TO-BE지방
                expectIncome.SalesFeeCountrysideTOBE__c = convertToDecimal(dataMap.get('salesFeeCountrysideTOBE'));
            }
            if (dataMap.containsKey('loanManage')) { // 여신관리
                expectIncome.LoanManage__c = (String) dataMap.get('loanManage');
            }
            if (dataMap.containsKey('paymentMethod')) { // 결제수단
                expectIncome.PaymentMethod__c = (String) dataMap.get('paymentMethod');
            }
            if (dataMap.containsKey('contractPaymentDate') && dataMap.get('contractPaymentDate') !='') { // 약정결제일
                expectIncome.ContractPaymentDate__c = Date.valueOf(((String) dataMap.get('contractPaymentDate')));
            }
            if (dataMap.containsKey('contractType')) { // 계약서종류
                expectIncome.ContractType__c = (String) dataMap.get('contractType');
            }

            /* ===== 4. 수주가이드 충족 여부 ===== */     
            if (dataMap.containsKey('sales')) { // 매출
                expectIncome.Sales__c = convertToDecimal(dataMap.get('sales'));
            }
            if (dataMap.containsKey('exclusiveSaveSkuSales')) { //전용 저장 SKU 매출
                expectIncome.ExclusiveSaveSkuSales__c = convertToDecimal(dataMap.get('exclusiveSaveSkuSales'));
            }
            if (dataMap.containsKey('dropSize')) { // 회당 Drop Size
                expectIncome.DropSize__c = convertToDecimal(dataMap.get('dropSize'));
            }
            if (dataMap.containsKey('averageSales')) { // 점당 평균매출매출
                expectIncome.AverageSales__c = convertToDecimal(dataMap.get('averageSales'));
            }
            if (dataMap.containsKey('deliveryNumber')) { // 배송 횟수
                expectIncome.DeliveryNumber__c = convertToDecimal(dataMap.get('deliveryNumber'));
            }
            if (dataMap.containsKey('contributionMargin')) { // 공헌이익%
                expectIncome.ContributionMargin__c = convertToDecimal(dataMap.get('contributionMargin'));
            }
            if (dataMap.containsKey('kgExclusiveProduct')) { // 전용상품
                expectIncome.KgExclusiveProduct__c = convertToDecimal(dataMap.get('kgExclusiveProduct'));
            }
            if (dataMap.containsKey('kgGeneralProduct')) { // 일반상품
                expectIncome.KgGeneralProduct__c = convertToDecimal(dataMap.get('kgGeneralProduct'));
            }
            if (dataMap.containsKey('kgTotalAmount')) { // 계
                expectIncome.KgTotalAmount__c = convertToDecimal(dataMap.get('kgTotalAmount'));
            }
            if (dataMap.containsKey('skuReleaseBox')) { // 출고단위 BOX
                expectIncome.SkuReleaseBox__c = convertToDecimal(dataMap.get('skuReleaseBox'));
            }
            if (dataMap.containsKey('skuReleaseEa')) { // 출고단위 EA
                expectIncome.SkuReleaseEa__c = convertToDecimal(dataMap.get('skuReleaseEa'));
            }



            /* ===== 5. 신규 개설 예상 손익 ===== */


            if (dataMap.containsKey('salesNameOne')) { // 매출-전용 이름 1 (text) 
                expectIncome.SalesNameOne__c = (String) dataMap.get('salesNameOne');
            }
            if (dataMap.containsKey('salesNameTwo')) { // 매출-전용 이름 2 (text) 
                expectIncome.SalesNameTwo__c = (String) dataMap.get('salesNameTwo');
            }
            if (dataMap.containsKey('salesNameThree')) { // 매출-전용 이름 3 (text) 
                expectIncome.SalesNameThree__c = (String) dataMap.get('salesNameThree');
            }
            if (dataMap.containsKey('salesNameFour')) { // 매출-전용 이름 4 (text) 
                expectIncome.SalesNameFour__c = (String) dataMap.get('salesNameFour');
            }
            if (dataMap.containsKey('profitRateNameOne')) { // 매익률-전용 이름 1 (text) 
                expectIncome.ProfitRateNameOne__c = (String) dataMap.get('profitRateNameOne');
            }
            if (dataMap.containsKey('profitRateNameTwo')) { // 매익률-전용 이름 2 (text) 
                expectIncome.ProfitRateNameTwo__c = (String) dataMap.get('profitRateNameTwo');
            }
            if (dataMap.containsKey('profitRateNameThree')) { // 매익률-전용 이름 3 (text) 
                expectIncome.ProfitRateNameThree__c = (String) dataMap.get('profitRateNameThree');
            }
            if (dataMap.containsKey('profitRateNameFour')) { // 매익률-전용 이름 4 (text) 
                expectIncome.ProfitRateNameFour__c = (String) dataMap.get('profitRateNameFour');
            }            
            if (dataMap.containsKey('salesCapEx')) { // 매출-전용 : 수도권 
                expectIncome.SalesCapitalExclusive__c = convertToDecimal(dataMap.get('salesCapEx'));
            }
            if (dataMap.containsKey('salesEastEx')) { // 매출-전용 : 동부권 
                expectIncome.SalesEastExclusive__c = convertToDecimal(dataMap.get('salesEastEx'));
            }
            if (dataMap.containsKey('salesWestEx')) { // 매출-전용 : 서부권 
                expectIncome.SalesWestExclusive__c = convertToDecimal(dataMap.get('salesWestEx'));
            }
            if (dataMap.containsKey('salesJejuEx')) { // 매출-전용 : 제주권 
                expectIncome.SalesJejuExclusive__c = convertToDecimal(dataMap.get('salesJejuEx'));
            }
            if (dataMap.containsKey('salesCapGen')) { // 매출-일반 : 수도권 
                expectIncome.SalesCapitalGeneral__c = convertToDecimal(dataMap.get('salesCapGen'));
            }
            if (dataMap.containsKey('salesEastGen')) { // 매출-일반 : 동부권 
                expectIncome.SalesEastGeneral__c = convertToDecimal(dataMap.get('salesEastGen'));
            }
            if (dataMap.containsKey('salesWestGen')) { // 매출-일반 : 서부권 
                expectIncome.SalesWestGeneral__c = convertToDecimal(dataMap.get('salesWestGen'));
            }
            if (dataMap.containsKey('salesJejuGen')) { // 매출-일반 : 제주권 
                expectIncome.SalesJejuGeneral__c = convertToDecimal(dataMap.get('salesJejuGen'));
            }
            if (dataMap.containsKey('salesProfitNameOne')) { // 매출이익(수수료 지급 後)-전용 이름 1 (text) 
                expectIncome.SalesProfitNameOne__c = (String) dataMap.get('salesProfitNameOne');
            }
            if (dataMap.containsKey('salesProfitNameTwo')) { // 매출이익(수수료 지급 後)-전용 이름 2 (text) 
                expectIncome.SalesProfitNameTwo__c = (String) dataMap.get('salesProfitNameTwo');
            }
            if (dataMap.containsKey('salesProfitNameThree')) { // 매출이익(수수료 지급 後)-전용 이름 3 (text) 
                expectIncome.SalesProfitNameThree__c = (String) dataMap.get('salesProfitNameThree');
            }
            if (dataMap.containsKey('salesProfitNameFour')) { // 매출이익(수수료 지급 後)-전용 이름 4 (text) 
                expectIncome.SalesProfitNameFour__c = (String) dataMap.get('salesProfitNameFour');
            }           
            if (dataMap.containsKey('salesProfitCapEx')) { // 매출이익(수수료 지급 後)-직송 : 수도권 
                expectIncome.SalesProfitCaptialExclusive__c = convertToDecimal(dataMap.get('salesProfitCapEx'));
            }
            if (dataMap.containsKey('salesProfitEastEx')) { // 매출이익(수수료 지급 後)-직송 : 동부권 
                expectIncome.SalesProfitEastExclusive__c = convertToDecimal(dataMap.get('salesProfitEastEx'));
            }
            if (dataMap.containsKey('salesProfitWestEx')) { // 매출이익(수수료 지급 後)-직송 : 서부권 
                expectIncome.SalesProfitWestExclusive__c = convertToDecimal(dataMap.get('salesProfitWestEx'));
            }
            if (dataMap.containsKey('salesProfitJejuEx')) { // 매출이익(수수료 지급 後)-직송 : 제주권 
                expectIncome.SalesProfitJejuExclusive__c = convertToDecimal(dataMap.get('salesProfitJejuEx'));
            }
            if (dataMap.containsKey('salesProfitFoEx')) { // 매출이익(수수료 지급 後)-직송 : FO센터 
                expectIncome.SalesProfitFoEx__c = convertToDecimal(dataMap.get('salesProfitFoEx'));
            }
            if (dataMap.containsKey('salesProfitCapGen')) { // 매출이익(수수료 지급 後)-일반 : 수도권 
                expectIncome.SalesProfitCapitalGeneral__c = convertToDecimal(dataMap.get('salesProfitCapGen'));
            }
            if (dataMap.containsKey('salesProfitEastGen')) { // 매출이익(수수료 지급 後)-일반 : 동부권 
                expectIncome.SalesProfitEastGeneral__c = convertToDecimal(dataMap.get('salesProfitEastGen'));
            }
            if (dataMap.containsKey('salesProfitWestGen')) { // 매출이익(수수료 지급 後)-일반 : 서부권 
                expectIncome.SalesProfitWestGeneral__c = convertToDecimal(dataMap.get('salesProfitWestGen'));
            }
            if (dataMap.containsKey('salesProfitJejuGen')) { // 매출이익(수수료 지급 後)-일반 : 제주권 
                expectIncome.SalesProfitJejuGeneral__c = convertToDecimal(dataMap.get('salesProfitJejuGen'));
            }
            if (dataMap.containsKey('salesProfitFoGen')) { // 매출이익(수수료 지급 後)-일반 : FO센터 
                expectIncome.SalesProfitFoGen__c = convertToDecimal(dataMap.get('salesProfitFoGen'));
            }

            if (dataMap.containsKey('locationCntCap')) { // 판매처수 : 수도권 
                expectIncome.SalesLocationCntCapital__c = convertToDecimal(dataMap.get('locationCntCap'));
            }
            if (dataMap.containsKey('locationCntEast')) { // 판매처수 : 동부권
                expectIncome.SalesLocationCntEast__c = convertToDecimal(dataMap.get('locationCntEast'));
            }
            if (dataMap.containsKey('locationCntWest')) { // 판매처수 : 서부권
                expectIncome.SalesLocationCntWest__c = convertToDecimal(dataMap.get('locationCntWest'));
            }
            if (dataMap.containsKey('locationCntJeju')) { // 판매처수 : 제주권
                expectIncome.SalesLocationCntJeju__c = convertToDecimal(dataMap.get('locationCntJeju'));
            }
            if (dataMap.containsKey('locationCntFo')) { // 판매처수 : FO센터
                expectIncome.SalesLocationCntFo__c = convertToDecimal(dataMap.get('locationCntFo'));
            }

            if (dataMap.containsKey('profitRateEx')) { // 전용 매익률
                expectIncome.ProfitRateExclusive__c = convertToDecimal(dataMap.get('profitRateEx'));
            }
            if (dataMap.containsKey('profitRateGen')) { // 범용 매익률(지급후)
                expectIncome.ProfitRateGeneral__c = convertToDecimal(dataMap.get('profitRateGen'));
            }
            if (dataMap.containsKey('selectedDelivery')) { // 배송횟수
                expectIncome.DeliveryCnt__c = (String)dataMap.get('selectedDelivery'); // 결제수단 종류
            }

            if (dataMap.containsKey('salesCapOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesCapOne__c = convertToDecimal(dataMap.get('salesCapOne'));
            }
            if (dataMap.containsKey('salesCapTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesCapTwo__c = convertToDecimal(dataMap.get('salesCapTwo'));
            }
            if (dataMap.containsKey('salesCapThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesCapThree__c = convertToDecimal(dataMap.get('salesCapThree'));
            }
            if (dataMap.containsKey('salesCapFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesCapFour__c = convertToDecimal(dataMap.get('salesCapFour'));
            }
            if (dataMap.containsKey('salesEastOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesEastOne__c = convertToDecimal(dataMap.get('salesEastOne'));
            }
            if (dataMap.containsKey('salesEastTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesEastTwo__c = convertToDecimal(dataMap.get('salesEastTwo'));
            }
            if (dataMap.containsKey('salesEastThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesEastThree__c = convertToDecimal(dataMap.get('salesEastThree'));
            }
            if (dataMap.containsKey('salesEastFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesEastFour__c = convertToDecimal(dataMap.get('salesEastFour'));
            }
            if (dataMap.containsKey('salesWestOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesWestOne__c = convertToDecimal(dataMap.get('salesWestOne'));
            }
            if (dataMap.containsKey('salesWestTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesWestTwo__c = convertToDecimal(dataMap.get('salesWestTwo'));
            }
            if (dataMap.containsKey('salesWestThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesWestThree__c = convertToDecimal(dataMap.get('salesWestThree'));
            }
            if (dataMap.containsKey('salesWestFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesWestFour__c = convertToDecimal(dataMap.get('salesWestFour'));
            }
            if (dataMap.containsKey('salesJejuOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesJejuOne__c = convertToDecimal(dataMap.get('salesJejuOne'));
            }
            if (dataMap.containsKey('salesJejuTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesJejuTwo__c = convertToDecimal(dataMap.get('salesJejuTwo'));
            }
            if (dataMap.containsKey('salesJejuThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesJejuThree__c = convertToDecimal(dataMap.get('salesJejuThree'));
            }
            if (dataMap.containsKey('salesJejuFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesJejuFour__c = convertToDecimal(dataMap.get('salesJejuFour'));
            }
            if (dataMap.containsKey('salesMonthFoOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesMonthFoOne__c = convertToDecimal(dataMap.get('salesMonthFoOne'));
            }
            if (dataMap.containsKey('salesMonthFoTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesMonthFoTwo__c = convertToDecimal(dataMap.get('salesMonthFoTwo'));
            }
            if (dataMap.containsKey('salesMonthFoThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesMonthFoThree__c = convertToDecimal(dataMap.get('salesMonthFoThree'));
            }
            if (dataMap.containsKey('salesMonthFoFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesMonthFoFour__c = convertToDecimal(dataMap.get('salesMonthFoFour'));
            }

            if (dataMap.containsKey('salesFoEx')) { // 매출-전용 : 수도권 
                expectIncome.SalesFoEx__c = convertToDecimal(dataMap.get('salesFoEx'));
            }
            if (dataMap.containsKey('salesFoGen')) { // 매출-전용 : 수도권 
                expectIncome.SalesFoGen__c = convertToDecimal(dataMap.get('salesFoGen'));
            }


            if (dataMap.containsKey('salesSoluOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesSoluOne__c = convertToDecimal(dataMap.get('salesSoluOne'));
            }
            if (dataMap.containsKey('salesSoluTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesSoluTwo__c = convertToDecimal(dataMap.get('salesSoluTwo'));
            }
            if (dataMap.containsKey('salesSoluThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesSoluThree__c = convertToDecimal(dataMap.get('salesSoluThree'));
            }
            if (dataMap.containsKey('salesSoluFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesSoluFour__c = convertToDecimal(dataMap.get('salesSoluFour'));
            }

            if (dataMap.containsKey('salesProfitCapOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitCapOne__c = convertToDecimal(dataMap.get('salesProfitCapOne'));
            }
            if (dataMap.containsKey('salesProfitCapTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitCapTwo__c = convertToDecimal(dataMap.get('salesProfitCapTwo'));
            }
            if (dataMap.containsKey('salesProfitCapThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitCapThree__c = convertToDecimal(dataMap.get('salesProfitCapThree'));
            }
            if (dataMap.containsKey('salesProfitCapFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitCapFour__c = convertToDecimal(dataMap.get('salesProfitCapFour'));
            }
            if (dataMap.containsKey('salesProfitEastOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitEastOne__c = convertToDecimal(dataMap.get('salesProfitEastOne'));
            }
            if (dataMap.containsKey('salesProfitEastTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitEastTwo__c = convertToDecimal(dataMap.get('salesProfitEastTwo'));
            }
            if (dataMap.containsKey('salesProfitEastThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitEastThree__c = convertToDecimal(dataMap.get('salesProfitEastThree'));
            }
            if (dataMap.containsKey('salesProfitEastFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitEastFour__c = convertToDecimal(dataMap.get('salesProfitEastFour'));
            }
            if (dataMap.containsKey('salesProfitWestOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitWestOne__c = convertToDecimal(dataMap.get('salesProfitWestOne'));
            }
            if (dataMap.containsKey('salesProfitWestTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitWestTwo__c = convertToDecimal(dataMap.get('salesProfitWestTwo'));
            }
            if (dataMap.containsKey('salesProfitWestThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitWestThree__c = convertToDecimal(dataMap.get('salesProfitWestThree'));
            }
            if (dataMap.containsKey('salesProfitWestFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitWestFour__c = convertToDecimal(dataMap.get('salesProfitWestFour'));
            }
            if (dataMap.containsKey('salesProfitJejuOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitJejuOne__c = convertToDecimal(dataMap.get('salesProfitJejuOne'));
            }
            if (dataMap.containsKey('salesProfitJejuTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitJejuTwo__c = convertToDecimal(dataMap.get('salesProfitJejuTwo'));
            }
            if (dataMap.containsKey('salesProfitJejuThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitJejuThree__c = convertToDecimal(dataMap.get('salesProfitJejuThree'));
            }
            if (dataMap.containsKey('salesProfitJejuFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitJejuFour__c = convertToDecimal(dataMap.get('salesProfitJejuFour'));
            }
            if (dataMap.containsKey('salesProfitFoOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitFoOne__c = convertToDecimal(dataMap.get('salesProfitFoOne'));
            }
            if (dataMap.containsKey('salesProfitFoTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitFoTwo__c = convertToDecimal(dataMap.get('salesProfitFoTwo'));
            }
            if (dataMap.containsKey('salesProfitFoThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitFoThree__c = convertToDecimal(dataMap.get('salesProfitFoThree'));
            }
            if (dataMap.containsKey('salesProfitFoFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitFoFour__c = convertToDecimal(dataMap.get('salesProfitFoFour'));
            }
            if (dataMap.containsKey('salesProfitSoluOne')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitSoluOne__c = convertToDecimal(dataMap.get('salesProfitSoluOne'));
            }
            if (dataMap.containsKey('salesProfitSoluTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitSoluTwo__c = convertToDecimal(dataMap.get('salesProfitSoluTwo'));
            }
            if (dataMap.containsKey('salesProfitSoluThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitSoluThree__c = convertToDecimal(dataMap.get('salesProfitSoluThree'));
            }
            if (dataMap.containsKey('salesProfitSoluFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitSoluFour__c = convertToDecimal(dataMap.get('salesProfitSoluFour'));
            }

            if (dataMap.containsKey('distributeDirCap')) { // 물류비(라우팅) - 직접비 : 수도권 
                expectIncome.DistributeDirCap__c = convertToDecimal(dataMap.get('distributeDirCap'));
            }
            if (dataMap.containsKey('distributeDirEast')) { // 물류비(라우팅) - 직접비 : 동부권 
                expectIncome.DistributeDirEast__c = convertToDecimal(dataMap.get('distributeDirEast'));
            }
            if (dataMap.containsKey('distributeDirWest')) { // 물류비(라우팅) - 직접비 : 서부권 
                expectIncome.DistributeDirWest__c = convertToDecimal(dataMap.get('distributeDirWest'));
            }
            if (dataMap.containsKey('distributeDirJeju')) { // 물류비(라우팅) - 직접비 : 제주권 
                expectIncome.DistributeDirJeju__c = convertToDecimal(dataMap.get('distributeDirJeju'));
            }
            if (dataMap.containsKey('distributeDirFo')) { // 물류비(라우팅) - 직접비 : FO센터 
               expectIncome.DistributeDirFo__c = convertToDecimal(dataMap.get('distributeDirFo'));
            }
            if (dataMap.containsKey('distributeInDirCap')) { // 매출-전용 - 간접비 : 수도권 
                expectIncome.DistributeInDirCap__c = convertToDecimal(dataMap.get('distributeInDirCap'));
            }
            if (dataMap.containsKey('distributeInDirEast')) { // 매출-전용 - 간접비 : 동부권 
                expectIncome.DistributeInDirEast__c = convertToDecimal(dataMap.get('distributeInDirEast'));
            }
            if (dataMap.containsKey('distributeInDirWest')) { // 매출-전용 - 간접비 : 서부권 
                expectIncome.DistributeInDirWest__c = convertToDecimal(dataMap.get('distributeInDirWest'));
            }
            if (dataMap.containsKey('distributeInDirJeju')) { // 매출-전용 - 간접비 : 제주권 
                expectIncome.DistributeInDirJeju__c = convertToDecimal(dataMap.get('distributeInDirJeju'));
            }
            if (dataMap.containsKey('distributeInDirFo')) { // 매출-전용 - 간접비 : FO센터 
               expectIncome.DistributeInDirFo__c = convertToDecimal(dataMap.get('distributeInDirFo'));
            }
           


            

            // -------------------------------------------외식(재계약) / 예상손익 저장 추가-------------------------------------------

            if (dataMap.containsKey('salesThreeEx')) { // 매출 전용 - 3개월 평균실적 
                expectIncome.SalesReAverageResultExclusive__c = convertToDecimal(dataMap.get('salesThreeEx'));
            }
            if (dataMap.containsKey('salesThreeGen')) { // 매출 일반- 3개월 평균실적 
                expectIncome.SalesReAverageResultGeneral__c = convertToDecimal(dataMap.get('salesThreeGen'));
            }
            if (dataMap.containsKey('salesProfitThreeEx')) { // 매출이익 전용 - 3개월 평균실적 
                expectIncome.SalesProfitReAverageResultExclusive__c = convertToDecimal(dataMap.get('salesProfitThreeEx'));
            }
            if (dataMap.containsKey('salesProfitThreeGen')) { // 매출이익 전용 - 3개월 평균실적 
                expectIncome.SalesProfitReAverageResultGeneral__c = convertToDecimal(dataMap.get('salesProfitThreeGen'));
            }
            if (dataMap.containsKey('locationThree')) { // 판매처수 - 3개월 평균실적 
                expectIncome.LocationReAverageResult__c = convertToDecimal(dataMap.get('locationThree'));
            }
            if (dataMap.containsKey('distributeDirThree')) { // 물류비 -직접 
                expectIncome.DistDirReAverageResult__c = convertToDecimal(dataMap.get('DistributeDirThree'));
            }
            if (dataMap.containsKey('distributeInDirThree')) { // 물류비 -간접 
                expectIncome.DistInDirReAverageResult__c = convertToDecimal(dataMap.get('distributeInDirThree'));
            }
            if (dataMap.containsKey('salesSoluEx')) { // 솔루션 - 전용 개선
                expectIncome.SalesSolutionExclusive__c = convertToDecimal(dataMap.get('salesSoluEx'));
            }
            if (dataMap.containsKey('salesSoluGen')) { // 솔루션 - 일반 개선
                expectIncome.SalesSolutionGeneral__c = convertToDecimal(dataMap.get('salesSoluGen'));
            }
            if (dataMap.containsKey('salesProfitSoluEx')) { // 솔루션 - 일반 개선
                expectIncome.SalesProfitSoluEx__c = convertToDecimal(dataMap.get('salesProfitSoluEx'));
            }
            if (dataMap.containsKey('salesImpMonthEx')) { // 월 예상실적 - 전용 개선
                expectIncome.SalesImproveResultExclusive__c = convertToDecimal(dataMap.get('salesImpMonthEx'));
            }
            if (dataMap.containsKey('salesImpMonthGen')) { // 월 예상실적 - 일반 개선
                expectIncome.SalesImproveResultGeneral__c = convertToDecimal(dataMap.get('salesImpMonthGen'));
            }

            /* ===== 6. 점당 매출액 ===== */
            if (dataMap.containsKey('salesMoreThousand')) { // 매출액 첫번째 칸
                expectIncome.SalesMoreThousand__c = convertToDecimal(dataMap.get('salesMoreThousand'));
            }
            if (dataMap.containsKey('salesMoreFiveHundred')) { // 매출액 두번째 칸
                expectIncome.SalesMoreFiveHundred__c = convertToDecimal(dataMap.get('salesMoreFiveHundred'));
            }
            if (dataMap.containsKey('salesLessFiveHundred')) { // 매출액 세번째 칸
                expectIncome.SalesLessFiveHundred__c = convertToDecimal(dataMap.get('salesLessFiveHundred'));
            }
            if (dataMap.containsKey('salesLessThreeHundred')) { // 매출액 네번째 칸
                expectIncome.SalesLessThreeHundred__c = convertToDecimal(dataMap.get('salesLessThreeHundred'));
            }
            if (dataMap.containsKey('storeMoreThousand')) { // 점포수 첫번째 칸
                expectIncome.StoreMoreThousand__c = convertToDecimal(dataMap.get('storeMoreThousand'));
            }
            if (dataMap.containsKey('storeMoreFiveHundred')) { // 점포수 두번째 칸
                expectIncome.StoreMoreFiveHundred__c = convertToDecimal(dataMap.get('storeMoreFiveHundred'));
            }
            if (dataMap.containsKey('storeLessFiveHundred')) { // 점포수 세번째 칸
                expectIncome.StoreLessFiveHundred__c = convertToDecimal(dataMap.get('storeLessFiveHundred'));
            }
            if (dataMap.containsKey('storeLessThreeHundred')) { // 점포수 네번째 칸
                expectIncome.StoreLessThreeHundred__c = convertToDecimal(dataMap.get('storeLessThreeHundred'));
            }


            /* ===== 8. 재고 운영 개선사항(체인 전용) ===== */

            if (dataMap.containsKey('ProductNameOne')) { // 테스트
                expectIncome.ProductNameOne__c = (String) dataMap.get('ProductNameOne');
            }            
            if (dataMap.containsKey('StorageConditionOne')) { // 테스트
                expectIncome.StorageConditionOne__c = (String) dataMap.get('StorageConditionOne');
            }            
            if (dataMap.containsKey('ReleaseUnitOne')) { // 테스트
                expectIncome.ReleaseUnitOne__c = (String) dataMap.get('ReleaseUnitOne');
            }            
            if (dataMap.containsKey('EnforcementMonthOne')) { // 테스트
                expectIncome.EnforcementMonthOne__c = (String) dataMap.get('EnforcementMonthOne');
            }            
            if (dataMap.containsKey('PltOriginalOne')) { // 테스트
                expectIncome.PltOriginalOne__c = convertToDecimal(dataMap.get('PltOriginalOne'));
            }
            if (dataMap.containsKey('PltPlanOne')) { // 테스트
                expectIncome.PltPlanOne__c = convertToDecimal(dataMap.get('PltPlanOne'));
            }
            if (dataMap.containsKey('StockMoneyOriginalOne')) { // 테스트
                expectIncome.StockMoneyOriginalOne__c = convertToDecimal(dataMap.get('StockMoneyOriginalOne'));
            }
            if (dataMap.containsKey(' StockMoneyPlanOne')) { // 테스트
                expectIncome.StockMoneyPlanOne__c = convertToDecimal(dataMap.get('StockMoneyPlanOne'));
            }
            if (dataMap.containsKey('MonthSaleOne')) { // 테스트
                expectIncome.MonthSaleOne__c = convertToDecimal(dataMap.get('MonthSaleOne'));
            }
            if (dataMap.containsKey('MonthSalesProfitOne')) { // 테스트
                expectIncome.MonthSalesProfitOne__c = convertToDecimal(dataMap.get('MonthSalesProfitOne'));
            }

            
            if (dataMap.containsKey('ProductNameTwo')) { // 테스트
                expectIncome.ProductNameTwo__c = (String) dataMap.get('ProductNameTwo');
            }            
            if (dataMap.containsKey('StorageConditionTwo')) { // 테스트
                expectIncome.StorageConditionTwo__c = (String) dataMap.get('StorageConditionTwo');
            }            
            if (dataMap.containsKey('ReleaseUnitTwo')) { // 테스트
                expectIncome.ReleaseUnitTwo__c = (String) dataMap.get('ReleaseUnitTwo');
            }            
            if (dataMap.containsKey('EnforcementMonthTwo')) { // 테스트
                expectIncome.EnforcementMonthTwo__c = (String) dataMap.get('EnforcementMonthTwo');
            }            
            if (dataMap.containsKey('PltOriginalTwo')) { // 테스트
                expectIncome.PltOriginalTwo__c = convertToDecimal(dataMap.get('PltOriginalTwo'));
            }
            if (dataMap.containsKey('PltPlanTwo')) { // 테스트
                expectIncome.PltPlanTwo__c = convertToDecimal(dataMap.get('PltPlanTwo'));
            }
            if (dataMap.containsKey('StockMoneyOriginalTwo')) { // 테스트
                expectIncome.StockMoneyOriginalTwo__c = convertToDecimal(dataMap.get('StockMoneyOriginalTwo'));
            }
            if (dataMap.containsKey('StockMoneyPlanTwo')) { // 테스트
                expectIncome.StockMoneyPlanTwo__c = convertToDecimal(dataMap.get('StockMoneyPlanTwo'));
            }
            if (dataMap.containsKey('MonthSaleTwo')) { // 테스트
                expectIncome.MonthSaleTwo__c = convertToDecimal(dataMap.get('MonthSaleTwo'));
            }
            if (dataMap.containsKey('MonthSalesProfitTwo')) { // 테스트
                expectIncome.MonthSalesProfitTwo__c = convertToDecimal(dataMap.get('MonthSalesProfitTwo'));
            }

            if (dataMap.containsKey('ProductNameThree')) { // 테스트
                expectIncome.ProductNameThree__c = (String) dataMap.get('ProductNameThree');
            }            
            if (dataMap.containsKey('StorageConditionThree')) { // 테스트
                expectIncome.StorageConditionThree__c = (String) dataMap.get('StorageConditionThree');
            }            
            if (dataMap.containsKey('ReleaseUnitThree')) { // 테스트
                expectIncome.ReleaseUnitThree__c = (String) dataMap.get('ReleaseUnitThree');
            }            
            if (dataMap.containsKey('EnforcementMonthThree')) { // 테스트
                expectIncome.EnforcementMonthThree__c = (String) dataMap.get('EnforcementMonthThree');
            }            
            if (dataMap.containsKey('PltOriginalThree')) { // 테스트
                expectIncome.PltOriginalThree__c = convertToDecimal(dataMap.get('PltOriginalThree'));
            }
            if (dataMap.containsKey('PltPlanThree')) { // 테스트
                expectIncome.PltPlanThree__c = convertToDecimal(dataMap.get('PltPlanThree'));
            }
            if (dataMap.containsKey('StockMoneyOriginalThree')) { // 테스트
                expectIncome.StockMoneyOriginalThree__c = convertToDecimal(dataMap.get('StockMoneyOriginalThree'));
            }
            if (dataMap.containsKey('StockMoneyPlanThree')) { // 테스트
                expectIncome.StockMoneyPlanThree__c = convertToDecimal(dataMap.get('StockMoneyPlanThree'));
            }
            if (dataMap.containsKey('MonthSaleThree')) { // 테스트
                expectIncome.MonthSaleThree__c = convertToDecimal(dataMap.get('MonthSaleThree'));
            }
            if (dataMap.containsKey('MonthSalesProfitThree')) { // 테스트
                expectIncome.MonthSalesProfitThree__c = convertToDecimal(dataMap.get('MonthSalesProfitThree'));
            }

            if (dataMap.containsKey('ProductNameFour')) { // 테스트
                expectIncome.ProductNameFour__c = (String) dataMap.get('ProductNameFour');
            }            
            if (dataMap.containsKey('StorageConditionFour')) { // 테스트
                expectIncome.StorageConditionFour__c = (String) dataMap.get('StorageConditionFour');
            }            
            if (dataMap.containsKey('ReleaseUnitFour')) { // 테스트
                expectIncome.ReleaseUnitFour__c = (String) dataMap.get('ReleaseUnitFour');
            }            
            if (dataMap.containsKey('EnforcementMonthFour')) { // 테스트
                expectIncome.EnforcementMonthFour__c = (String) dataMap.get('EnforcementMonthFour');
            }            
            if (dataMap.containsKey('PltOriginalFour')) { // 테스트
                expectIncome.PltOriginalFour__c = convertToDecimal(dataMap.get('PltOriginalFour'));
            }
            if (dataMap.containsKey('PltPlanFour')) { // 테스트
                expectIncome.PltPlanFour__c = convertToDecimal(dataMap.get('PltPlanFour'));
            }
            if (dataMap.containsKey('StockMoneyOriginalFour')) { // 테스트
                expectIncome.StockMoneyOriginalFour__c = convertToDecimal(dataMap.get('StockMoneyOriginalFour'));
            }
            if (dataMap.containsKey('StockMoneyPlanFour')) { // 테스트
                expectIncome.StockMoneyPlanFour__c = convertToDecimal(dataMap.get('StockMoneyPlanFour'));
            }
            if (dataMap.containsKey('MonthSaleFour')) { // 테스트
                expectIncome.MonthSaleFour__c = convertToDecimal(dataMap.get('MonthSaleFour'));
            }
            if (dataMap.containsKey('MonthSalesProfitFour')) { // 테스트
                expectIncome.MonthSalesProfitFour__c = convertToDecimal(dataMap.get('MonthSalesProfitFour'));
            }

            if (dataMap.containsKey('ProductNameFive')) { // 테스트
                expectIncome.ProductNameFive__c = (String) dataMap.get('ProductNameFive');
            }            
            if (dataMap.containsKey('StorageConditionFive')) { // 테스트
                expectIncome.StorageConditionFive__c = (String) dataMap.get('StorageConditionFive');
            }            
            if (dataMap.containsKey('ReleaseUnitFive')) { // 테스트
                expectIncome.ReleaseUnitFive__c = (String) dataMap.get('ReleaseUnitFive');
            }            
            if (dataMap.containsKey('EnforcementMonthFive')) { // 테스트
                expectIncome.EnforcementMonthFive__c = (String) dataMap.get('EnforcementMonthFive');
            }            
            if (dataMap.containsKey('PltOriginalFive')) { // 테스트
                expectIncome.PltOriginalFive__c = convertToDecimal(dataMap.get('PltOriginalFive'));
            }
            if (dataMap.containsKey('PltPlanFive')) { // 테스트
                expectIncome.PltPlanFive__c = convertToDecimal(dataMap.get('PltPlanFive'));
            }
            if (dataMap.containsKey('StockMoneyOriginalFive')) { // 테스트
                expectIncome.StockMoneyOriginalFive__c = convertToDecimal(dataMap.get('StockMoneyOriginalFive'));
            }
            if (dataMap.containsKey('StockMoneyPlanFive')) { // 테스트
                expectIncome.StockMoneyPlanFive__c = convertToDecimal(dataMap.get('StockMoneyPlanFive'));
            }
            if (dataMap.containsKey('MonthSaleFive')) { // 테스트
                expectIncome.MonthSaleFive__c = convertToDecimal(dataMap.get('MonthSaleFive'));
            }
            if (dataMap.containsKey('MonthSalesProfitFive')) { // 테스트
                expectIncome.MonthSalesProfitFive__c = convertToDecimal(dataMap.get('MonthSalesProfitFive'));
            }

            if (dataMap.containsKey('ProductNameSix')) { // 테스트
                expectIncome.ProductNameSix__c = (String) dataMap.get('ProductNameSix');
            }            
            if (dataMap.containsKey('StorageConditionSix')) { // 테스트
                expectIncome.StorageConditionSix__c = (String) dataMap.get('StorageConditionSix');
            }            
            if (dataMap.containsKey('ReleaseUnitSix')) { // 테스트
                expectIncome.ReleaseUnitSix__c = (String) dataMap.get('ReleaseUnitSix');
            }            
            if (dataMap.containsKey('EnforcementMonthSix')) { // 테스트
                expectIncome.EnforcementMonthSix__c = (String) dataMap.get('EnforcementMonthSix');
            }            
            if (dataMap.containsKey('PltOriginalSix')) { // 테스트
                expectIncome.PltOriginalSix__c = convertToDecimal(dataMap.get('PltOriginalSix'));
            }
            if (dataMap.containsKey('PltPlanSix')) { // 테스트
                expectIncome.PltPlanSix__c = convertToDecimal(dataMap.get('PltPlanSix'));
            }
            if (dataMap.containsKey('StockMoneyOriginalSix')) { // 테스트
                expectIncome.StockMoneyOriginalSix__c = convertToDecimal(dataMap.get('StockMoneyOriginalSix'));
            }
            if (dataMap.containsKey('StockMoneyPlanSix')) { // 테스트
                expectIncome.StockMoneyPlanSix__c = convertToDecimal(dataMap.get('StockMoneyPlanSix'));
            }
            if (dataMap.containsKey('MonthSaleSix')) { // 테스트
                expectIncome.MonthSaleSix__c = convertToDecimal(dataMap.get('MonthSaleSix'));
            }
            if (dataMap.containsKey('MonthSalesProfitSix')) { // 테스트
                expectIncome.MonthSalesProfitSix__c = convertToDecimal(dataMap.get('MonthSalesProfitSix'));
            }

            if (dataMap.containsKey('ProductNameSeven')) { // 테스트
                expectIncome.ProductNameSeven__c = (String) dataMap.get('ProductNameSeven');
            }            
            if (dataMap.containsKey('StorageConditionSeven')) { // 테스트
                expectIncome.StorageConditionSeven__c = (String) dataMap.get('StorageConditionSeven');
            }            
            if (dataMap.containsKey('ReleaseUnitSeven')) { // 테스트
                expectIncome.ReleaseUnitSeven__c = (String) dataMap.get('ReleaseUnitSeven');
            }            
            if (dataMap.containsKey('EnforcementMonthSeven')) { // 테스트
                expectIncome.EnforcementMonthSeven__c = (String) dataMap.get('EnforcementMonthSeven');
            }            
            if (dataMap.containsKey('PltOriginalSeven')) { // 테스트
                expectIncome.PltOriginalSeven__c = convertToDecimal(dataMap.get('PltOriginalSeven'));
            }
            if (dataMap.containsKey('PltPlanSeven')) { // 테스트
                expectIncome.PltPlanSeven__c = convertToDecimal(dataMap.get('PltPlanSeven'));
            }
            if (dataMap.containsKey('StockMoneyOriginalSeven')) { // 테스트
                expectIncome.StockMoneyOriginalSeven__c = convertToDecimal(dataMap.get('StockMoneyOriginalSeven'));
            }
            if (dataMap.containsKey('StockMoneyPlanSeven')) { // 테스트
                expectIncome.StockMoneyPlanSeven__c = convertToDecimal(dataMap.get('StockMoneyPlanSeven'));
            }
            if (dataMap.containsKey('MonthSaleSeven')) { // 테스트
                expectIncome.MonthSaleSeven__c = convertToDecimal(dataMap.get('MonthSaleSeven'));
            }
            if (dataMap.containsKey('MonthSalesProfitSeven')) { // 테스트
                expectIncome.MonthSalesProfitSeven__c = convertToDecimal(dataMap.get('MonthSalesProfitSeven'));
            }

            if (dataMap.containsKey('ProductNameEight')) { // 테스트
                expectIncome.ProductNameEight__c = (String) dataMap.get('ProductNameEight');
            }            
            if (dataMap.containsKey('StorageConditionEight')) { // 테스트
                expectIncome.StorageConditionEight__c = (String) dataMap.get('StorageConditionEight');
            }            
            if (dataMap.containsKey('ReleaseUnitEight')) { // 테스트
                expectIncome.ReleaseUnitEight__c = (String) dataMap.get('ReleaseUnitEight');
            }            
            if (dataMap.containsKey('EnforcementMonthEight')) { // 테스트
                expectIncome.EnforcementMonthEight__c = (String) dataMap.get('EnforcementMonthEight');
            }            
            if (dataMap.containsKey('PltOriginalEight')) { // 테스트
                expectIncome.PltOriginalEight__c = convertToDecimal(dataMap.get('PltOriginalEight'));
            }
            if (dataMap.containsKey('PltPlanEight')) { // 테스트
                expectIncome.PltPlanEight__c = convertToDecimal(dataMap.get('PltPlanEight'));
            }
            if (dataMap.containsKey('StockMoneyOriginalEight')) { // 테스트
                expectIncome.StockMoneyOriginalEight__c = convertToDecimal(dataMap.get('StockMoneyOriginalEight'));
            }
            if (dataMap.containsKey('StockMoneyPlanEight')) { // 테스트
                expectIncome.StockMoneyPlanEight__c = convertToDecimal(dataMap.get('StockMoneyPlanEight'));
            }
            if (dataMap.containsKey('MonthSaleEight')) { // 테스트
                expectIncome.MonthSaleEight__c = convertToDecimal(dataMap.get('MonthSaleEight'));
            }
            if (dataMap.containsKey('MonthSalesProfitEight')) { // 테스트
                expectIncome.MonthSalesProfitEight__c = convertToDecimal(dataMap.get('MonthSalesProfitEight'));
            }

            if (dataMap.containsKey('ProductNameNine')) { // 테스트
                expectIncome.ProductNameNine__c = (String) dataMap.get('ProductNameNine');
            }            
            if (dataMap.containsKey('StorageConditionNine')) { // 테스트
                expectIncome.StorageConditionNine__c = (String) dataMap.get('StorageConditionNine');
            }            
            if (dataMap.containsKey('ReleaseUnitNine')) { // 테스트
                expectIncome.ReleaseUnitNine__c = (String) dataMap.get('ReleaseUnitNine');
            }            
            if (dataMap.containsKey('EnforcementMonthNine')) { // 테스트
                expectIncome.EnforcementMonthNine__c = (String) dataMap.get('EnforcementMonthNine');
            }            
            if (dataMap.containsKey('PltOriginalNine')) { // 테스트
                expectIncome.PltOriginalNine__c = convertToDecimal(dataMap.get('PltOriginalNine'));
            }
            if (dataMap.containsKey('PltPlanNine')) { // 테스트
                expectIncome.PltPlanNine__c = convertToDecimal(dataMap.get('PltPlanNine'));
            }
            if (dataMap.containsKey('StockMoneyOriginalNine')) { // 테스트
                expectIncome.StockMoneyOriginalNine__c = convertToDecimal(dataMap.get('StockMoneyOriginalNine'));
            }
            if (dataMap.containsKey('StockMoneyPlanNine')) { // 테스트
                expectIncome.StockMoneyPlanNine__c = convertToDecimal(dataMap.get('StockMoneyPlanNine'));
            }
            if (dataMap.containsKey('MonthSaleNine')) { // 테스트
                expectIncome.MonthSaleNine__c = convertToDecimal(dataMap.get('MonthSaleNine'));
            }
            if (dataMap.containsKey('MonthSalesProfitNine')) { // 테스트
                expectIncome.MonthSalesProfitNine__c = convertToDecimal(dataMap.get('MonthSalesProfitNine'));
            }

            if (dataMap.containsKey('ProductNameTen')) { // 테스트
                expectIncome.ProductNameTen__c = (String) dataMap.get('ProductNameTen');
            }            
            if (dataMap.containsKey('StorageConditionTen')) { // 테스트
                expectIncome.StorageConditionTen__c = (String) dataMap.get('StorageConditionTen');
            }            
            if (dataMap.containsKey('ReleaseUnitTen')) { // 테스트
                expectIncome.ReleaseUnitTen__c = (String) dataMap.get('ReleaseUnitTen');
            }            
            if (dataMap.containsKey('EnforcementMonthTen')) { // 테스트
                expectIncome.EnforcementMonthTen__c = (String) dataMap.get('EnforcementMonthTen');
            }            
            if (dataMap.containsKey('PltOriginalTen')) { // 테스트
                expectIncome.PltOriginalTen__c = convertToDecimal(dataMap.get('PltOriginalTen'));
            }
            if (dataMap.containsKey('PltPlanTen')) { // 테스트
                expectIncome.PltPlanTen__c = convertToDecimal(dataMap.get('PltPlanTen'));
            }
            if (dataMap.containsKey('StockMoneyOriginalTen')) { // 테스트
                expectIncome.StockMoneyOriginalTen__c = convertToDecimal(dataMap.get('StockMoneyOriginalTen'));
            }
            if (dataMap.containsKey('StockMoneyPlanTen')) { // 테스트
                expectIncome.StockMoneyPlanTen__c = convertToDecimal(dataMap.get('StockMoneyPlanTen'));
            }
            if (dataMap.containsKey('MonthSaleTen')) { // 테스트
                expectIncome.MonthSaleTen__c = convertToDecimal(dataMap.get('MonthSaleTen'));
            }
            if (dataMap.containsKey('MonthSalesProfitTen')) { // 테스트
                expectIncome.MonthSalesProfitTen__c = convertToDecimal(dataMap.get('MonthSalesProfitTen'));
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

    /* 
    물류비 가져오기
     */
    public void getDistributeCost() {
        System.debug('# ReportFormController # getDistributeCost ');

        
        

        // 파람값 들어오면 변경예정 231024
        //String ReportType1 ='외식SU';
        //String ReportType2 ='급식SU';
        
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

            system.debug('DistributeCost 외식용 -> ' +  DistributeCostList );

            // 본부별 최대 8개까지 존재가능한 물류비값을 각각 담아주기 
            for(CJFW_DistributionCost__c record : DistributeCostList){

                if(headOfficeLabel == '6000'){ // 외식일때 
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
                }else if(headOfficeLabel == '3001'){ // 급식일때 
                    DistributeSchool =record.Cost__c;
                }
            }
            // IncomeExpensesInfo 에 담아주기 
            // IncomeExpensesInfo 필드에 값이 있는지 먼저 체크 > 값이 없으면 물류비값 넣어주기 */

            if (IncomeExpensesInfo.DistributeDirCap__c == 0 || IncomeExpensesInfo.DistributeDirCap__c == null){
                IncomeExpensesInfo.put('DistributeDirCap__c', DistributeDirCap );
            }
            if (IncomeExpensesInfo.DistributeDirEast__c == 0 || IncomeExpensesInfo.DistributeDirEast__c == null){
                IncomeExpensesInfo.put('DistributeDirEast__c', DistributeDirEast );
            }
            if (IncomeExpensesInfo.DistributeDirWest__c == 0 || IncomeExpensesInfo.DistributeDirWest__c == null){
                IncomeExpensesInfo.put('DistributeDirWest__c', DistributeDirWest );
            }
            if (IncomeExpensesInfo.DistributeDirJeju__c == 0 || IncomeExpensesInfo.DistributeDirJeju__c == null){
                IncomeExpensesInfo.put('DistributeDirJeju__c', DistributeDirJeju );
            }

            if (IncomeExpensesInfo.DistributeInDirCap__c == 0 || IncomeExpensesInfo.DistributeInDirCap__c == null){
                IncomeExpensesInfo.put('DistributeInDirCap__c', DistributeInDirCap );
            }
            if (IncomeExpensesInfo.DistributeInDirEast__c == 0 || IncomeExpensesInfo.DistributeInDirEast__c == null){
                IncomeExpensesInfo.put('DistributeInDirEast__c', DistributeInDirEast );
            }
            if (IncomeExpensesInfo.DistributeInDirWest__c == 0 || IncomeExpensesInfo.DistributeInDirWest__c == null){
                IncomeExpensesInfo.put('DistributeInDirWest__c', DistributeInDirWest );
            }
            if (IncomeExpensesInfo.DistributeInDirJeju__c == 0 || IncomeExpensesInfo.DistributeInDirJeju__c == null){
                IncomeExpensesInfo.put('DistributeInDirJeju__c', DistributeInDirJeju );
            }
            System.debug('# IncomeExpensesInfo 값 넣어줘  ->' + IncomeExpensesInfo ); 


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
    예산손익관리(CJFW_ExpectedIncomeManager__c) 에서 값 가져오기
    적용시작일 기준으로 값 가져와야함 
    */
    public void getExpectManager_be() {
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

        System.debug('IncomeManager !! check > '+  IncomeManager );

    }
}