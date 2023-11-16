/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-16-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
public with sharing class OrderConsiderReContractFormController {
    public static String SaveDataList;

    public String opportunityId { get; set; }
    public String incomeExpensesId { get; set;} // 신규개설품의 id
    public Decimal versionCheck { get; set; }
    public Boolean reportCheck { get; set; }
    public String showtable { get; set; }
    public String reportType { get; set; } // 품의서 유형
    public String headOfficeLabel { get; set; } // 본부구분 
    public Decimal defaultZero { get; set; } // 0.00 기본세팅
    public String refExInfoId { get; set; } // 예상손익 version 2 이상 신규 insert 시 전버전 참고값 

    // 물류비 - 외식(SU)
    public Decimal DistributeDirCap {get;set;}  // 수도권-직접
    public Decimal DistributeDirEast {get;set;} // 동부권-직접
    public Decimal DistributeDirWest {get;set;} // 서부권-직접
    public Decimal DistributeDirJeju {get;set;} // 제주권-직접

    public Decimal DistributeInDirCap {get;set;} // 수도권-간접
    public Decimal DistributeInDirEast {get;set;} // 동부권-간접
    public Decimal DistributeInDirWest {get;set;} // 서부권-간접
    public Decimal DistributeInDirJeju {get;set;} // 제주권-간접

    public Decimal DistributeSchool {get;set;} // 급식용 

    /* 계산값 가져오기 */
    public CJFW_ExpectedIncomeExpenses__c IncomeExpensesInfo {get;set;} //예상손익 
    public CJFW_ExpectedIncomeManager__c IncomeManager {get;set;} // 예상손익관리 
    public CJFW_DistributionCost__c DistributeCost {get;set;} // 물류비관리 
    public CJFW_SalesPerformance__c SalesPerformance {get;set;} // 실적현황
    public CJFW_PromoteIssues__c PromoteIssues {get;set;} // 실적현황

    /* 가져온 데이터 담는 object */
    public Contact keymanInfo {get;set;}
    public Opportunity opptyInfo {get;set;}
    public Account accountInfo {get;set;}

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
    public List<SelectOption> contractPickList { get; set; }    // 계약서종류
    public List<SelectOption> deliveryPickList { get; set; }    // 배송횟수종류


    /* 날짜형식변환 */
    public String firstContact { get; set; } // 최초접촉시기

    public String initialDate { get; set; } // 초도일자
    public String contractStartDate { get; set; } // 계약시작
    public String contractEndDate { get; set; } // 계약종료
    public String collateralPeriod { get; set; } // 담보 제공 기간
    public String contractPaymentDate { get; set; } // 약정결제일
    public String salesPerformDate { get; set; } // 품의생성일자

    
    /* 생성자 */
    public OrderConsiderReContractFormController() {
        this.opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
        this.incomeExpensesId = ApexPages.currentPage().getParameters().get('incomeExpensesId');
        this.showtable = ApexPages.currentPage().getParameters().get('showtable');
        this.reportType = ApexPages.currentPage().getParameters().get('type');
        this.defaultZero = 0.00;
        //System.debug('# opportunityId ->' + opportunityId );
        //System.debug('# incomeExpensesId ->' + incomeExpensesId );
        //System.debug('# showtable ->' + showtable );
        //System.debug('# reportType ->' + reportType );

        // 리포트 타입에 따라서 물류비 picklist 선정해주기 
        if( reportType == 'CRM009' || reportType == 'CRM010' ){ // 외식 품의서 
            this.headOfficeLabel = '6000'; // 외식코드
        }else{ // 급식품의서 
            this.headOfficeLabel = '3001'; // 급식코드 
        }
        
        String pageReferenceString = ApexPages.currentPage().getUrl();
        String testReContract = '/apex/CJFW_OrderConsiderReContractForm';

        // 테스트용 (삭제예정)
        //System.debug(' 테스트 모드1' + pageReferenceString );
        //System.debug(' 테스트 모드2' + testReContract );
        //if (pageReferenceString == testReContract) {
        //    System.debug(' 테스트 모드3');
        //    opportunityId = '006H200000DTM7EIAX';
        //    incomeExpensesId = 'a1lH2000001YWdgIAG';
        //    showtable = 'false';
        //    this.headOfficeLabel = '6000'; // 외식코드
        //}

        // test Class에서 객체 생성시 다른 메소드들이 실행되지 않게 분기처리
        if(Test.isRunningTest()){
            System.debug('test code 실행중');
        }else{
            System.debug('실제 환경에서 실행할 로직');
            getPicklistValues();    // picklist label/value 값 담기
            getKeymanInfo();        // key-man 정보 가져오기 
            getOpptyInfo();         // 담당자 정보 가져오기
            getAccountInfo();       // 고객사 정보 가져오기
            getIncomeExpenses();    // 신규개설품의 obj 값 가져오기
            getExpectManager();     // 품의서 관리자 작성 obj 값 가져오기    
            getDistributeCost();    // 물류비관리 값 가져오기

            
            getSalesPerform(incomeExpensesId); // 실적현황 가져오기
            getPromoteIssue(incomeExpensesId); // 추진사항정보 가져오기
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
        // 배송횟수  
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


        // System.debug(' 브랜드 경로 pickList 값 ' + brandChannelPickList);
        // System.debug(' 담보제공종류 pickList 값 ' + collateralPickList);
        // System.debug(' 여신관리 pickList 값 ' + loanManagePickList);
        // System.debug(' 결제수단종류 pickList 값 ' + paymentPickList);
        // System.debug(' 계약서종류 pickList 값 ' + contractPickList);
    }

    /* 
    OpportunityContactRole에 있는 key-man 정보 가져오는 메소드
    */
    public void getKeymanInfo() {
        try {
            List<OpportunityContactRole> opptyConRoles = [SELECT Id, ContactId FROM OpportunityContactRole WHERE OpportunityId =:opportunityId AND IsPrimary = true LIMIT 1];
            
            if(opptyConRoles != null && !opptyConRoles.isEmpty()) {
                OpportunityContactRole opptyConRole = opptyConRoles[0];
                Id contactId = opptyConRole.ContactId;
    
                keymanInfo = [SELECT Id, Name
                                FROM Contact
                                WHERE Id =:contactId 
                                LIMIT 1];
        
                }
                System.debug('keymanInfo =>' + keymanInfo);

        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
        }
    }

    /* 
    Oppty 에 있는 Owner 정보 가져오는 메소드
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

            // System.debug('# account 정보 ->' + accountInfo );
        } else {
            // System.debug('# 계정 ID를 찾을 수 없습니다.');
        }
    }

    /* 
    신규개설품의(CJFW_ExpectedIncomeExpenses__c) 에서 값 가져오기
    VF Page 초기호출시  
    */
    public void getIncomeExpenses() {
        System.debug('# ReportFormController # getIncomeExpenses #신규개설품의에서 값가져오기');
        
        try {
            String query = 'SELECT Id, ' +
            'Version__c, ' +                        
            'IsReportCheck__c, ' +                        
            'KeyMan__c, ' +                         //키맨  

            'ContactMethod__c, ' +                  //접촉방법
            'FirstContact__c, ' +                   //최초접촉시기           
            
            'Competitor__c, ' +                     //경쟁업체
            'CompetitorSuggestions__c, ' +          //경제업제 제안 
            'ObtainOrder__c, ' +                    //수주팀
            'MainMA__c, ' +                         //담당MA
            'ClientCompanyName__c, ' +              //거래처명
            'RepresentativeName__c, ' +             //대표자명
            'BrandLaunching__c, ' +                 //브랜드 런칭
            'BrandManage__c, ' +                    //운영 브랜드
            'BrandChannel__c, ' +                   //브랜드 경로
            'BrandBusinessCondition__c, ' +         //업태
            'SalesMonthly__c, ' +                   //외형 전체
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
            'Sales__c, ' +                          //수주가이드 매출
            'ExclusiveSaveSkuSales__c, ' +          //전용저장 sku매출
            'DropSize__c, ' +                       //회당 Drop Size
            'AverageSales__c, ' +                   //점당 평균매출
            'DeliveryNumber__c, ' +                 //배송 횟수
            'ContributionMargin__c, ' +             //공헌이익%
            'KgExclusiveProduct__c, ' +             //전용상품
            'KgGeneralProduct__c, ' +               //일반상품
            'KgTotalAmount__c, ' +                  //KG단가 계
            'SkuReleaseEa__c,' +                    //출고단위 EA
            'SkuReleaseBox__c, ' +                  //출고단위 BOX
            'SalesMoreThousand__c, ' +              //매출액 1천이상
            'SalesMoreFiveHundred__c, ' +           //매출액 5백이상
            'SalesLessFiveHundred__c, ' +           //매출액 5백미만
            'SalesLessThreeHundred__c, ' +          //매출액 3백미만
            'StoreMoreThousand__c, ' +              //점포수 1천이상
            'StoreMoreFiveHundred__c, ' +           //점포수 5백이상
            'StoreLessFiveHundred__c, ' +           //점포수 5백미만
            'StoreLessThreeHundred__c, ' +          //점포수 3백미만
            'OtherSupportDetail__c, ' +             // 기타 지원세부 내역
            'AttachedDocument__c, ' +               // 첨부서류
            'OpptyDescription__c, ' +               // 특이사항
            'SalesCapitalExclusive__c, ' +          // 외식전용 필드 ↓ :매출 수도권 전용
            'SalesNameOne__c, ' +                   // 매출 전용입력1
            'SalesNameTwo__c, ' +                   // 매출 전용입력2
            'SalesNameThree__c, ' +                 // 매출 전용입력3
            'SalesNameFour__c, ' +                  // 매출 전용입력4
            'SalesCapitalGeneral__c, ' +            // 매출 수도권 일반
            'SalesEastExclusive__c, ' +             // 매출 동부권 전용
            'SalesEastGeneral__c, ' +               // 매출 동부권 일반
            'SalesWestExclusive__c, ' +             // 매출 서부권 전용
            'SalesWestGeneral__c, ' +               // 매출 서부권 일반 
            'SalesJejuExclusive__c, ' +             // 매출 제주권 전용 
            'SalesJejuGeneral__c, ' +               // 매출 제주권 일반 
            'SalesSolutionExclusive__c, ' +         // 매출 솔루션 전용 
            'SalesSolutionGeneral__c, ' +           // 매출 솔루션 전용 
            'SalesImproveResultExclusive__c, ' +    // 매출 개선실적 전용
            'SalesImproveResultGeneral__c, ' +      // 매출 개선실적 전용
            'SalesProfitCaptialExclusive__c, ' +    // 매출이익 수도권 전용
            'SalesProfitCapitalGeneral__c, ' +      // 매출이익 수도권 일반
            'SalesProfitEastExclusive__c, ' +       // 매출이익 동부권 전용
            'SalesProfitEastGeneral__c, ' +         // 매출이익 동부권 일반
            'SalesProfitWestExclusive__c, ' +       // 매출이익 서부권 전용
            'SalesProfitWestGeneral__c, ' +         // 매출이익 서부권 일반
            'SalesProfitJejuExclusive__c, ' +       // 매출이익 제주권 전용
            'SalesProfitJejuGeneral__c, ' +         // 매출이익 제주권 일반
            'SalesProfitNameOne__c, ' +             // 매출이익 전용입력1
            'SalesProfitNameTwo__c, ' +             // 매출이익 전용입력2
            'SalesProfitNameThree__c, ' +           // 매출이익 전용입력3
            'SalesProfitNameFour__c, ' +            // 매출이익 전용입력4
            'ProfitRateCapitalExclusive__c, ' +     // 매익률 수도권 전용
            'ProfitRateEastExclusive__c, ' +        // 매익률 동부권 전용
            'ProfitRateWestExclusive__c, ' +        // 매익률 서부권 전용
            'ProfitRateJejuExclusive__c, ' +        // 매익률 제주권 전용
            'ProfitRateCapitalGeneral__c, ' +       // 매익률 수도권 일반
            'ProfitRateEastGeneral__c, ' +          // 매익률 동부권 일반
            'ProfitRateWestGeneral__c, ' +          // 매익률 서부권 일반
            'ProfitRateJejuGeneral__c, ' +          // 매익률 제주권 일반
            'ProfitRateExclusive__c, ' +            // 전용매익률
            'ProfitRateGeneral__c, ' +              // 전용매익률 (지급후)
            'SalesLocationCntThree__c, ' +          // 매익률 3개월전 판매처수
            'SalesLocationCntCapital__c, ' +        // 매익률 수도권 판매처수
            'SalesLocationCntEast__c, ' +           // 매익률 동부권 판매처수
            'SalesLocationCntWest__c, ' +           // 매익률 서부권 판매처수
            'SalesLocationCntJeju__c, ' +           // 매익률 제주권 판매처수
            'SalesLocationCntFo__c, ' +             // 매익률 FO 판매처수
            'SalesLocationCntImpMonth__c, ' +       // 매익률 솔루션 예상실적
            'SalesPerStoreCapital__c, ' +           // 매익률 수도권 점당매출
            'SalesPerStoreEast__c, ' +              // 매익률 동부권 점당매출
            'SalesPerStoreWest__c, ' +              // 매익률 서부권 점당매출
            'SalesPerStoreJeju__c, ' +              // 매익률 제주권 점당매출
            'DropSizeCapital__c, ' +                // 매익률 수도권 DROP-SIZE
            'DropSizeEast__c, ' +                   // 매익률 동부권 DROP-SIZE
            'DropSizeWest__c, ' +                   // 매익률 서부권 DROP-SIZE
            'DropSizeJeju__c, ' +                   // 매익률 제주권 DROP-SIZE
            'DeliveryCnt__c, ' +                    // 배송횟수
            'SalesPerformDate__c, ' +               // 실적현황 지정일
            'SalesReAverageResultExclusive__c, ' + 
            'SalesReAverageResultGeneral__c, ' + 
            'SalesProfitReAverageResultExclusive__c, ' + 
            'SalesProfitReAverageResultGeneral__c, ' + 
            'LocationReAverageResult__c, ' + 
            'DistDirReAverageResult__c, ' + 
            'SalesThreeOne__c, ' + 
            'SalesThreeTwo__c, ' + 
            'SalesThreeThree__c, ' + 
            'SalesThreeFour__c, ' + 
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
            'SalesFoEx__c, ' + 
            'SalesFoGen__c, ' + 
            'SalesImpMonthOne__c, ' + 
            'SalesImpMonthTwo__c, ' + 
            'SalesImpMonthThree__c, ' + 
            'SalesImpMonthFour__c, ' + 
            'salesProfitThreeOne__c, ' + 
            'salesProfitThreeTwo__c, ' + 
            'salesProfitThreeThree__c, ' + 
            'salesProfitThreeFour__c, ' + 
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
            'SalesProfitImpMonthOne__c, ' + 
            'SalesProfitImpMonthTwo__c, ' + 
            'SalesProfitImpMonthThree__c, ' + 
            'SalesProfitImpMonthFour__c, ' + 
            'SalesProfitFoEx__c, ' + 
            'SalesProfitFoGen__c, ' + 
            'SalesProfitImpMonthEx__c, ' + 
            'SalesProfitImpMonthGen__c, ' + 
            'ProfitRateNameOne__c, ' + 
            'ProfitRateNameTwo__c, ' + 
            'ProfitRateNameThree__c, ' + 
            'ProfitRateNameFour__c, ' + 
            'DistributeDirImpMonth__c, ' + 
            'DistributeInDirImpMonth__c, ' + 
            'DistributeDirCap__c, ' + 
            'DistributeDirEast__c, ' + 
            'DistributeDirWest__c, ' + 
            'DistributeDirJeju__c, ' + 
            'DistributeInDirCap__c, ' + 
            'DistributeInDirEast__c, ' + 
            'DistributeInDirWest__c, ' + 
            'DistributeInDirJeju__c, ' + 
            'DistributeDirFo__c, ' + 
            'DistributeInDirFo__c, ' + 
            'DistInDirReAverageResult__c, ' + 

            'MultipleSkuRoomTemperature__c, ' +     // 점당매출액 관련 
            'MultipleSkuRefrigeration__c, ' +     
            'MultipleSkuFreezer__c, ' +              
            'MultiplePltRoomTemperature__c, ' +     
            'MultiplePltRefrigeration__c, ' +     
            'MultiplePltFreezer__c, ' +     

            'StorageSkuRoomTemperature__c, ' + 
            'StorageSkuRefrigeration__c, ' +        
            'StorageSkuFreezer__c, ' +        
            'StoragePltRoomTemperature__c, ' +        
            'StoragePltRefrigeration__c, ' +        
            'StoragePltFreezer__c, ' +        

            'ReductionSkuRoomTemperature__c, ' +           
            'ReductionSkuRefrigeration__c, ' +           
            'ReductionSkuFreezer__c, ' +           
            'ReductionPltRoomTemperature__c, ' +           
            'ReductionPltRefrigeration__c, ' +      
            'ReductionPltFreezer__c,' +   

            'ProductNameOne__c, ' +             // 재고운영사항 (체인전용)
            'StorageConditionOne__c, ' +        //저장조건 1 
            'ReleaseUnitOne__c, ' +             //출고단위 1 
            'EnforcementMonthOne__c, ' +        //시행월 1
            'PltOriginalOne__c, ' +             //PTL운영 계획 1  
            'PltPlanOne__c, ' +                 //PTL운영 기존 1  
            'StockMoneyOriginalOne__c, ' +      //재고금액 기존 1  
            'StockMoneyPlanOne__c, ' +          //재고금액 계획 1
            'MonthSaleOne__c, ' +               //매출 1
            'MonthSalesProfitOne__c, ' +        //매출이익 1 

            'ProductNameTwo__c, ' +     
            'StorageConditionTwo__c, ' +      
            'ReleaseUnitTwo__c, ' +      
            'EnforcementMonthTwo__c, ' +    
            'PltOriginalTwo__c, ' +           
            'PltPlanTwo__c, ' +           
            'StockMoneyOriginalTwo__c, ' +          
            'StockMoneyPlanTwo__c, ' +        
            'MonthSaleTwo__c, ' +   
            'MonthSalesProfitTwo__c, ' +      

            'ProductNameThree__c, ' +     
            'StorageConditionThree__c, ' +      
            'ReleaseUnitThree__c, ' +      
            'EnforcementMonthThree__c, ' +    
            'PltOriginalThree__c, ' +           
            'PltPlanThree__c, ' +           
            'StockMoneyOriginalThree__c, ' +          
            'StockMoneyPlanThree__c, ' +        
            'MonthSaleThree__c, ' +   
            'MonthSalesProfitThree__c, ' +      

            'ProductNameFour__c, ' +     
            'StorageConditionFour__c, ' +      
            'ReleaseUnitFour__c, ' +      
            'EnforcementMonthFour__c, ' +    
            'PltOriginalFour__c, ' +           
            'PltPlanFour__c, ' +           
            'StockMoneyOriginalFour__c, ' +          
            'StockMoneyPlanFour__c, ' +        
            'MonthSaleFour__c, ' +   
            'MonthSalesProfitFour__c, ' +      

            'ProductNameFive__c, ' +     
            'StorageConditionFive__c, ' +      
            'ReleaseUnitFive__c, ' +      
            'EnforcementMonthFive__c, ' +    
            'PltOriginalFive__c, ' +           
            'PltPlanFive__c, ' +           
            'StockMoneyOriginalFive__c, ' +          
            'StockMoneyPlanFive__c, ' +        
            'MonthSaleFive__c, ' +   
            'MonthSalesProfitFive__c, ' +   

            'ProductNameSix__c, ' +     
            'StorageConditionSix__c, ' +      
            'ReleaseUnitSix__c, ' +      
            'EnforcementMonthSix__c, ' +    
            'PltOriginalSix__c, ' +           
            'PltPlanSix__c, ' +           
            'StockMoneyOriginalSix__c, ' +          
            'StockMoneyPlanSix__c, ' +        
            'MonthSaleSix__c, ' +   
            'MonthSalesProfitSix__c, ' +      

            'ProductNameSeven__c, ' +     
            'StorageConditionSeven__c, ' +      
            'ReleaseUnitSeven__c, ' +      
            'EnforcementMonthSeven__c, ' +    
            'PltOriginalSeven__c, ' +           
            'PltPlanSeven__c, ' +           
            'StockMoneyOriginalSeven__c, ' +          
            'StockMoneyPlanSeven__c, ' +        
            'MonthSaleSeven__c, ' +   
            'MonthSalesProfitSeven__c, ' +      

            'ProductNameEight__c, ' +     
            'StorageConditionEight__c, ' +      
            'ReleaseUnitEight__c, ' +      
            'EnforcementMonthEight__c, ' +    
            'PltOriginalEight__c, ' +           
            'PltPlanEight__c, ' +           
            'StockMoneyOriginalEight__c, ' +          
            'StockMoneyPlanEight__c, ' +        
            'MonthSaleEight__c, ' +   
            'MonthSalesProfitEight__c, ' +      

            'ProductNameNine__c, ' +     
            'StorageConditionNine__c, ' +      
            'ReleaseUnitNine__c, ' +      
            'EnforcementMonthNine__c, ' +    
            'PltOriginalNine__c, ' +           
            'PltPlanNine__c, ' +           
            'StockMoneyOriginalNine__c, ' +          
            'StockMoneyPlanNine__c, ' +        
            'MonthSaleNine__c, ' +   
            'MonthSalesProfitNine__c, ' +      
            
            'ProductNameTen__c, ' +     
            'StorageConditionTen__c, ' +      
            'ReleaseUnitTen__c, ' +      
            'EnforcementMonthTen__c, ' +    
            'PltOriginalTen__c, ' +           
            'PltPlanTen__c, ' +           
            'StockMoneyOriginalTen__c, ' +          
            'StockMoneyPlanTen__c, ' +        
            'MonthSaleTen__c, ' +   
            'MonthSalesProfitTen__c, ' +      

            'SalesProfitSoluOne__c, ' +
            'SalesProfitSoluTwo__c, ' +
            'SalesProfitSoluThree__c, ' +
            'SalesProfitSoluFour__c, ' +
            'SalesProfitSoluEx__c, ' +   

            'CreatedDate ' + 

            'FROM CJFW_ExpectedIncomeExpenses__c';

            if (incomeExpensesId != null) {
                query += ' WHERE id = :incomeExpensesId';
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


            // insert 인지 update 구분해서 version up _231101
            if (!incomeExpensesList.isEmpty()) {
                IncomeExpensesInfo = incomeExpensesList[0];

                if(incomeExpensesId == null){ // insert : 버전 업! 
                    versionCheck = ( incomeExpensesList[0].Version__c ) + 1 ;
                }else{ //update 
                    versionCheck = ( incomeExpensesList[0].Version__c );
                    reportCheck = ( incomeExpensesList[0].IsReportCheck__c );
                }
            } else { // 품의 초기생성시 
                versionCheck = 1;
                IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c();
            } 
            System.debug('versionCheck -> '+ versionCheck);

        }catch (QueryException e) {
            IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c(); // 빈 레코드로 초기화
            System.debug(' 신규개설품의 조회 에러 message => ' + e.getMessage());
            System.debug(' 신규개설품의 조회 에러 trace => ' + e.getStackTraceString());
        }

        // System.debug('IncomeExpensesInfo 쿼리결과 = '+ IncomeExpensesInfo);

        // 조회된내용이 없을때 계산식에 오류가 발생하기때문에 아래와같이 default로 0.00 으로 세팅한다 
        String[] defaultValSet = new String[] {
            'SalesFeeGeneral__c',                //AS-IS일반
            'SalesFeeExclusive__c',              //AS-IS전용
            'SalesFeeCountryside__c',            //AS-IS지방
            'SalesFeeGeneralTOBE__c',            //TO-BE일반
            'SalesFeeExclusiveTOBE__c',          //TO-BE전용
            'SalesFeeCountrysideTOBE__c',        //TO-BE지방
            'Sales__c',                          //매출
            'ExclusiveSaveSkuSales__c',          //전용저장 sku매출
            'DropSize__c',                       //회당 Drop Size
            'AverageSales__c',                   //점당 평균매출
            'ContributionMargin__c',             //공헌이익%
            'SalesMoreThousand__c',              //매출액 1천이상
            'SalesMoreFiveHundred__c',           //매출액 5백이상
            'SalesLessFiveHundred__c',           //매출액 5백미만
            'SalesLessThreeHundred__c',          //매출액 3백미만
            'CollateralAmount__c',
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
            // 'SalesLocationCntCapital__c',
            // 'SalesLocationCntEast__c',
            // 'SalesLocationCntWest__c',
            // 'SalesLocationCntJeju__c',
            // 'SalesLocationCntFo__c' ,
            // 'SalesLocationCntThree__c' , 
            // 'SalesLocationCntImpMonth__c' , 
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
            'SalesReAverageResultExclusive__c', // 외식(재계약)전용 ▼
            'SalesReAverageResultGeneral__c',
            'SalesProfitReAverageResultExclusive__c',
            'SalesProfitReAverageResultGeneral__c',
            'LocationReAverageResult__c',
            'DistDirReAverageResult__c',
            'DistInDirReAverageResult__c',
            'SalesThreeOne__c' ,
            'SalesThreeTwo__c' ,
            'SalesThreeThree__c' ,
            'SalesThreeFour__c' ,
            'SalesCapOne__c' ,
            'SalesCapTwo__c' ,
            'SalesCapThree__c' ,
            'SalesCapFour__c' ,
            'SalesEastOne__c' ,
            'SalesEastTwo__c' ,
            'SalesEastThree__c' ,
            'SalesEastFour__c' ,
            'SalesWestOne__c' ,
            'SalesWestTwo__c' ,
            'SalesWestThree__c' ,
            'SalesWestFour__c' ,
            'SalesJejuOne__c' ,
            'SalesJejuTwo__c' ,
            'SalesJejuThree__c' ,
            'SalesJejuFour__c' ,
            'SalesMonthFoOne__c' ,
            'SalesMonthFoTwo__c' ,
            'SalesMonthFoThree__c',
            'SalesMonthFoFour__c' ,
            'SalesSoluOne__c' ,
            'SalesSoluTwo__c' ,
            'SalesSoluThree__c',
            'SalesSoluFour__c' ,
            'SalesFoEx__c' ,
            'SalesFoGen__c' ,
            'SalesImpMonthOne__c' ,
            'SalesImpMonthTwo__c' ,
            'SalesImpMonthThree__c' ,
            'SalesImpMonthFour__c' ,
            'SalesProfitThreeOne__c' , // 매출이익(수수료 지급 後) 전용 
            'SalesProfitThreeTwo__c' ,
            'SalesProfitThreeThree__c' , 
            'SalesProfitThreeFour__c' ,
            'SalesProfitCapOne__c' ,  
            'SalesProfitCapTwo__c' , 
            'SalesProfitCapThree__c' , 
            'SalesProfitCapFour__c' , 
            'SalesProfitEastOne__c' ,  
            'SalesProfitEastTwo__c' , 
            'SalesProfitEastThree__c' , 
            'SalesProfitEastFour__c' , 
            'SalesProfitWestOne__c' ,  
            'SalesProfitWestTwo__c' , 
            'SalesProfitWestThree__c' , 
            'SalesProfitWestFour__c' , 
            'SalesProfitJejuOne__c' ,  
            'SalesProfitJejuTwo__c' , 
            'SalesProfitJejuThree__c' , 
            'SalesProfitJejuFour__c' , 
            'SalesProfitFoOne__c' ,
            'SalesProfitFoTwo__c' ,
            'SalesProfitFoThree__c' ,
            'SalesProfitFoFour__c' ,
            'SalesProfitImpMonthOne__c' ,
            'SalesProfitImpMonthTwo__c' ,
            'SalesProfitImpMonthThree__c' ,
            'SalesProfitImpMonthFour__c' ,
            'SalesProfitFoEx__c' , 
            'SalesProfitFoGen__c' , 
            'SalesProfitImpMonthEx__c' , 
            'SalesProfitImpMonthGen__c' , 
            'SalesProfitSoluOne__c' , 
            'SalesProfitSoluTwo__c' , 
            'SalesProfitSoluThree__c' , 
            'SalesProfitSoluFour__c' , 
            'SalesProfitSoluEx__c' , 
            'DistributeDirImpMonth__c' , 
            'DistributeInDirImpMonth__c' , 
            'DistributeDirCap__c' ,
            'DistributeDirEast__c' ,
            'DistributeDirWest__c' ,
            'DistributeDirJeju__c' ,
            'DistributeInDirCap__c' ,
            'DistributeInDirEast__c' ,
            'DistributeInDirWest__c' ,
            'DistributeInDirJeju__c' ,
            'DistributeDirFo__c' , 
            'DistributeInDirFo__c' , 

            'MultipleSkuRoomTemperature__c',
            'MultipleSkuRefrigeration__c',
            'MultipleSkuFreezer__c',
            'MultiplePltRoomTemperature__c',
            'MultiplePltRefrigeration__c',
            'MultiplePltFreezer__c',

            'StorageSkuRoomTemperature__c',
            'StorageSkuRefrigeration__c',
            'StorageSkuFreezer__c',
            'StoragePltRoomTemperature__c',
            'StoragePltRefrigeration__c',
            'StoragePltFreezer__c',

            'ReductionSkuRoomTemperature__c',
            'ReductionSkuRefrigeration__c',
            'ReductionSkuFreezer__c',
            'ReductionPltRoomTemperature__c',
            'ReductionPltRefrigeration__c',
            'ReductionPltFreezer__c',

            'PltOriginalOne__c', // 재고 운영 개선사항 (체인전용)
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
            'MonthSalesProfitTen__c',



            'CreditLoanAmount__c'

        };

        // 조회된내용이 없을때 계산식에 오류가 발생하기때문에 아래와같이 default로 defaultZero 으로 세팅한다 
        for (String defaultSet : defaultValSet) {
            Object fieldValue = IncomeExpensesInfo.get(defaultSet);

            if (fieldValue == null) fieldValue = defaultZero; 
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
            'SkuReleaseEa__c',                   //출고단위 EA

            'SalesLocationCntCapital__c',        //판매처수
            'SalesLocationCntEast__c',
            'SalesLocationCntWest__c',
            'SalesLocationCntJeju__c',
            'SalesLocationCntFo__c' ,
            'SalesLocationCntThree__c' , 
            'SalesLocationCntImpMonth__c' 
        };
        for (String defaultSet : defaultValPerSet) {
            Object fieldPerValue = IncomeExpensesInfo.get(defaultSet);

            if (fieldPerValue == null) fieldPerValue = 0; 
            IncomeExpensesInfo.put(defaultSet, fieldPerValue);
        }


        /* Date 필드를 yyyy-MM-dd 형식의 문자열로 변환 */
        String firstContactString = String.valueOf(IncomeExpensesInfo.FirstContact__c);                 // 최초접촉시기

        String initialDateString = String.valueOf(IncomeExpensesInfo.InitialDate__c);                   // 초도일자 
        String contractStartString = String.valueOf(IncomeExpensesInfo.ContractStartDate__c);           // 계약시작일자
        String contractEndString = String.valueOf(IncomeExpensesInfo.ContractEndDate__c);               // 계약종료일자 
        String collateralPeriodString = String.valueOf(IncomeExpensesInfo.CollateralPeriod__c);         // 담보기간
        String contractPaymentDateString = String.valueOf(IncomeExpensesInfo.ContractPaymentDate__c);   // 약정결제일
        String salesPerformDateString = String.valueOf(IncomeExpensesInfo.SalesPerformDate__c);         // 실적현황 지정일자 
        
        firstContact = firstContactString != null ? firstContactString.substring(0, 10) : null;

        initialDate = initialDateString != null ? initialDateString.substring(0, 10) : null;
        contractStartDate = contractStartString != null ? contractStartString.substring(0, 10) : null;
        contractEndDate = contractEndString != null ? contractEndString.substring(0, 10) : null;
        collateralPeriod = collateralPeriodString != null ? collateralPeriodString.substring(0, 10) : null;
        contractPaymentDate = contractPaymentDateString != null ? contractPaymentDateString.substring(0, 10) : null;
        salesPerformDate = salesPerformDateString != null ? salesPerformDateString.substring(0, 10) : null;
        
        // 신규생성시엔 날짜가 안들어가 null 값이뜨는데 , 그럴경우 오늘날짜 기준 1년전을 default 값으로 세팅 
        if(salesPerformDate == null){
            DateTime todayDateTime = DateTime.now();
            salesPerformDate = (todayDateTime.addMonths(-12)).format('yyyy-MM-dd');
        }

        /* pickList 저장된 값 가져오기 */
        selectedBrandChannel = IncomeExpensesInfo.BrandChannel__c;      // 브랜드 경로
        selectedCollateral = IncomeExpensesInfo.CollateralType__c;      // 담보종류
        selectedLoanManage = IncomeExpensesInfo.LoanManage__c	;       // 여신관리
        selectedPayment = IncomeExpensesInfo.PaymentMethod__c;          // 결제수단 
        selectedContract = IncomeExpensesInfo.ContractType__c	;       // 계약서종류 
        selectedDelivery = IncomeExpensesInfo.DeliveryCnt__c	;       // 배송횟수 

        /* keyman info 값을 참고로 IncomeExpensesInfo 에 담아주기 
            -> IncomeExpensesInfo 필드에 값이 있는지 먼저 체크 > 값이 없고 keymanInfo가 null이 아닐때 keymanInfo 에서 값 땡겨옴 
        */
        if( (IncomeExpensesInfo.KeyMan__c == '' || IncomeExpensesInfo.KeyMan__c == null) && keymanInfo != null){
            IncomeExpensesInfo.put('KeyMan__c', keymanInfo.get('Name'));
        }

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

        //System.debug('# 품의서정보  ->' + IncomeExpensesInfo.id ); 
        refExInfoId = IncomeExpensesInfo.id;
    }

    /* 
    실적현황 가져오기 
    @param : 신규개설품의Id
    */
    public void getSalesPerform(String expectIncomeId) {

        // System.debug(' 실적현황 가져오기 ~ ' + expectIncomeId );
        // System.debug(' 실적현황  refExInfoId check  ~ ' + refExInfoId );
        List < CJFW_SalesPerformance__c > salesPerformanceList = new List < CJFW_SalesPerformance__c >();
        try{

            if (refExInfoId != null) {
                salesPerformanceList = [
                    SELECT  Id,
                            BeforeSales__c,     // 매출라인
                            SalesElevenAgo__c, 
                            SalesTenAgo__c, 
                            SalesNineAgo__c, 
                            SalesEightAgo__c, 
                            SalesSevenAgo__c, 
                            SalesSixAgo__c, 
                            SalesFiveAgo__c, 
                            SalesFourAgo__c, 
                            SalesThreeAgo__c, 
                            SalesTwoAgo__c, 
                            SalesOneAgo__c, 
                            BeforeSalesProfit__c,     // 매출이익라인
                            SalesProfitElevenAgo__c, 
                            SalesProfitTenAgo__c, 
                            SalesProfitNineAgo__c, 
                            SalesProfitEightAgo__c, 
                            SalesProfitSevenAgo__c, 
                            SalesProfitSixAgo__c, 
                            SalesProfitFiveAgo__c, 
                            SalesProfitFourAgo__c, 
                            SalesProfitThreeAgo__c, 
                            SalesProfitTwoAgo__c, 
                            SalesProfitOneAgo__c, 
                            BeforeSalesStore__c,      // 매장수 
                            SalesStoreElevenAgo__c, 
                            SalesStoreTenAgo__c, 
                            SalesStoreNineAgo__c, 
                            SalesStoreEightAgo__c, 
                            SalesStoreSevenAgo__c, 
                            SalesStoreSixAgo__c, 
                            SalesStoreFiveAgo__c, 
                            SalesStoreFourAgo__c, 
                            SalesStoreThreeAgo__c, 
                            SalesStoreTwoAgo__c, 
                            SalesStoreOneAgo__c, 
                            BeforeDistribute__c,      // 물류비 
                            DistributeElevenAgo__c, 
                            DistributeTenAgo__c, 
                            DistributeNineAgo__c, 
                            DistributeEightAgo__c, 
                            DistributeSevenAgo__c, 
                            DistributeSixAgo__c, 
                            DistributeFiveAgo__c, 
                            DistributeFourAgo__c, 
                            DistributeThreeAgo__c, 
                            DistributeTwoAgo__c, 
                            DistributeOneAgo__c, 
                            BeforeDistributeDir__c,    // 직접물류비 
                            DistributeDirElevenAgo__c, 
                            DistributeDirTenAgo__c, 
                            DistributeDirNineAgo__c, 
                            DistributeDirEightAgo__c, 
                            DistributeDirSevenAgo__c, 
                            DistributeDirSixAgo__c, 
                            DistributeDirFiveAgo__c, 
                            DistributeDirFourAgo__c, 
                            DistributeDirThreeAgo__c, 
                            DistributeDirTwoAgo__c, 
                            DistributeDirOneAgo__c, 
                            BeforeDistributeInDir__c,   // 간접물류비
                            DistributeInDirElevenAgo__c, 
                            DistributeInDirTenAgo__c, 
                            DistributeInDirNineAgo__c, 
                            DistributeInDirEightAgo__c, 
                            DistributeInDirSevenAgo__c, 
                            DistributeInDirSixAgo__c, 
                            DistributeInDirFiveAgo__c, 
                            DistributeInDirFourAgo__c, 
                            DistributeInDirThreeAgo__c, 
                            DistributeInDirTwoAgo__c, 
                            DistributeInDirOneAgo__c, 
                            BeforeContribute__c,        // 공헌이익
                            ContributeElevenAgo__c, 
                            ContributeTenAgo__c, 
                            ContributeNineAgo__c, 
                            ContributeEightAgo__c, 
                            ContributeSevenAgo__c, 
                            ContributeSixAgo__c, 
                            ContributeFiveAgo__c, 
                            ContributeFourAgo__c, 
                            ContributeThreeAgo__c, 
                            ContributeTwoAgo__c, 
                            ContributeOneAgo__c, 
                            ExpectedIncomeExpensesId__c 
                    FROM CJFW_SalesPerformance__c WHERE ExpectedIncomeExpensesId__c =: refExInfoId LIMIT 1  ];
                
            }

            // expectIncomeId를 key 값으로 신규개설품의(master) id 값이 없으면 신규생성 
            if(expectIncomeId ==null && refExInfoId ==null ){ 
                // System.debug( ' version 1 , 초기 신규 생성 '  );
                salesPerformance = new CJFW_SalesPerformance__c();
            }else if(expectIncomeId ==null && !salesPerformanceList.isEmpty() ){
                // System.debug( ' version 2 이상  , 신규 생성 '  );
                salesPerformance = new CJFW_SalesPerformance__c();
                salesPerformance = salesPerformanceList[0];
            }else{ 
                // System.debug( ' update '  );
                salesPerformance = salesPerformanceList[0];
            }

            // 조회된내용이 없을때 계산식에 오류가 발생하기때문에 아래와같이 default로 0.00 으로 세팅한다 
            String[] defaultValSet = new String[] {
                'BeforeSales__c', // 매출
                'SalesElevenAgo__c',
                'SalesTenAgo__c',
                'SalesNineAgo__c',
                'SalesEightAgo__c',
                'SalesSevenAgo__c',
                'SalesSixAgo__c',
                'SalesFiveAgo__c',
                'SalesFourAgo__c',
                'SalesThreeAgo__c',
                'SalesTwoAgo__c',
                'SalesOneAgo__c',
                'BeforeSalesProfit__c', // 매출이익
                'SalesProfitElevenAgo__c',
                'SalesProfitTenAgo__c',
                'SalesProfitNineAgo__c',
                'SalesProfitEightAgo__c',
                'SalesProfitSevenAgo__c',
                'SalesProfitSixAgo__c',
                'SalesProfitFiveAgo__c',
                'SalesProfitFourAgo__c',
                'SalesProfitThreeAgo__c',
                'SalesProfitTwoAgo__c',
                'SalesProfitOneAgo__c',
                'BeforeDistribute__c', // 물류비
                'DistributeElevenAgo__c',
                'DistributeTenAgo__c',
                'DistributeNineAgo__c',
                'DistributeEightAgo__c',
                'DistributeSevenAgo__c',
                'DistributeSixAgo__c',
                'DistributeFiveAgo__c',
                'DistributeFourAgo__c',
                'DistributeThreeAgo__c',
                'DistributeTwoAgo__c',
                'DistributeOneAgo__c',
                'BeforeDistributeDir__c', // 직접물류비
                'DistributeDirElevenAgo__c',
                'DistributeDirTenAgo__c',
                'DistributeDirNineAgo__c',
                'DistributeDirEightAgo__c',
                'DistributeDirSevenAgo__c',
                'DistributeDirSixAgo__c',
                'DistributeDirFiveAgo__c',
                'DistributeDirFourAgo__c',
                'DistributeDirThreeAgo__c',
                'DistributeDirTwoAgo__c',
                'DistributeDirOneAgo__c',
                'BeforeDistributeInDir__c', // 간접물류비
                'DistributeInDirElevenAgo__c',
                'DistributeInDirTenAgo__c',
                'DistributeInDirNineAgo__c',
                'DistributeInDirEightAgo__c',
                'DistributeInDirSevenAgo__c',
                'DistributeInDirSixAgo__c',
                'DistributeInDirFiveAgo__c',
                'DistributeInDirFourAgo__c',
                'DistributeInDirThreeAgo__c',
                'DistributeInDirTwoAgo__c',
                'DistributeInDirOneAgo__c',
                'BeforeContribute__c', // 공헌이익
                'ContributeElevenAgo__c',
                'ContributeTenAgo__c',
                'ContributeNineAgo__c',
                'ContributeEightAgo__c',
                'ContributeSevenAgo__c',
                'ContributeSixAgo__c',
                'ContributeFiveAgo__c',
                'ContributeFourAgo__c',
                'ContributeThreeAgo__c',
                'ContributeTwoAgo__c',
                'ContributeOneAgo__c'
                
            };

            String[] defaultZeroSet = new String[] {
                'BeforeSalesStore__c', // 매장수 (매장수는 정수)
                'SalesStoreElevenAgo__c',
                'SalesStoreTenAgo__c',
                'SalesStoreNineAgo__c',
                'SalesStoreEightAgo__c',
                'SalesStoreSevenAgo__c',
                'SalesStoreSixAgo__c',
                'SalesStoreFiveAgo__c',
                'SalesStoreFourAgo__c',
                'SalesStoreThreeAgo__c',
                'SalesStoreTwoAgo__c',
                'SalesStoreOneAgo__c'
            };    

            for (String defaultSet : defaultValSet) {
                Object fieldValue = salesPerformance.get(defaultSet);
                // 필드 값이 null이면 기본값을 0.00으로 설정
                if (fieldValue == null) fieldValue = defaultZero; 
                salesPerformance.put(defaultSet, fieldValue);
            }

            for (String defaultSet : defaultZeroSet) {
                Object fieldValue = salesPerformance.get(defaultSet);
                // 필드 값이 null이면 기본값을 0으로 설정
                if (fieldValue == null) fieldValue = 0; 
                salesPerformance.put(defaultSet, fieldValue);
            }
                

        }catch(Exception e){
            String errorMessage = e.getMessage();
            String errorStackTrace = e.getStackTraceString(); 
            System.debug(' 실적현황쪽 에러 메시지: ' + errorMessage);
            System.debug(' 실적현황쪽 에러 라인: ' + errorStackTrace);
        }

    }


    /* 
    #추진사항정보 (CJFW_PromoteIssues__c) 가져오기 
    @param : 신규개설품의Id
    */
    public void getPromoteIssue(String expectIncomeId) {
        System.debug(' 추진사항 정보가져가기 ');
        System.debug(' 추진사항 expectIncomeId => ' + expectIncomeId );
        System.debug(' 추진사항 refExInfoId => ' + refExInfoId );
        List<CJFW_PromoteIssues__c> promoteIssuesList = new List<CJFW_PromoteIssues__c>();

        try {
            if (refExInfoId != null) {
                promoteIssuesList = [
                    SELECT Id,
                    SolutionDivisionOne__c,     // 솔루션 구분
                    SolutionDivisionTwo__c,
                    SolutionDivisionThree__c,
                    SolutionDivisionFour__c,
                    SolutionDivisionFive__c,
                    SolutionDetailsOne__c,      // 솔루션 세부구분
                    SolutionDetailsTwo__c,
                    SolutionDetailsThree__c,
                    SolutionDetailsFour__c,
                    SolutionDetailsFive__c,
                    SolutionNewOne__c,         // 솔루션 신규/상품전환
                    SolutionNewTwo__c,
                    SolutionNewThree__c,
                    SolutionNewFour__c,
                    SolutionNewFive__c,
                    SolutionUseOne__c,          //솔류션 전용/범용
                    SolutionUseTwo__c,
                    SolutionUseThree__c,
                    SolutionUseFour__c,
                    SolutionUseFive__c,
                    SolutionProductNameOne__c,  // 솔루션 상품명
                    SolutionProductNameTwo__c,
                    SolutionProductNameThree__c,
                    SolutionProductNameFour__c,
                    SolutionProductNameFive__c,
                    SolutionStoreOne__c,            //솔루션 저장조건
                    SolutionStoreTwo__c,
                    SolutionStoreThree__c,
                    SolutionStoreFour__c,
                    SolutionStoreFive__c,
                    SolutionReleaseUnitOne__c,      // 솔루션 출고단위
                    SolutionReleaseUnitTwo__c,
                    SolutionReleaseUnitThree__c,
                    SolutionReleaseUnitFour__c,
                    SolutionReleaseUnitFive__c,
                    ManageEnforcementMonthOne__c,   // 재고운영 시행월
                    ManageEnforcementMonthTwo__c,
                    ManageEnforcementMonthThree__c,
                    ManageEnforcementMonthFour__c,
                    ManageEnforcementMonthFive__c,
                    ManagePltOne__c,                // 재고운영 PLT
                    ManagePltTwo__c,
                    ManagePltThree__c,
                    ManagePltFour__c,
                    ManagePltFive__c,
                    ManageStockMoneyOne__c, // 재고운영 재고금액
                    ManageStockMoneyTwo__c,
                    ManageStockMoneyThree__c,
                    ManageStockMoneyFour__c,
                    ManageStockMoneyFive__c,
                    ResultSaleOne__c,   // 상품실적 매출
                    ResultSaleTwo__c,
                    ResultSaleThree__c,
                    ResultSaleFour__c,
                    ResultSaleFive__c,
                    ResultSalesProfitOne__c, // 상품실적 매출이익
                    ResultSalesProfitTwo__c,
                    ResultSalesProfitThree__c,
                    ResultSalesProfitFour__c,
                    ResultSalesProfitFive__c,

                    SynergyDivisionOne__c, // 시너지 1
                    SynergyTypeOne__c,
                    SynergySaleOne__c,
                    SynergySaleRateOne__c,
                    SynergyRemarkOne__c,
                    SynergyDivisionTwo__c,
                    SynergyTypeTwo__c, // 시너지 2
                    SynergySaleTwo__c,
                    SynergySaleRateTwo__c,
                    SynergyRemarkTwo__c,
                    SynergyDivisionThree__c, // 시너지 3
                    SynergyTypeThree__c,
                    SynergySaleThree__c,
                    SynergySaleRateThree__c,
                    SynergyRemarkThree__c,
                    CreatedDate
                    FROM CJFW_PromoteIssues__c WHERE ExpectedIncomeExpensesId__c =: refExInfoId LIMIT 1
                ];
            }

            if(expectIncomeId ==null && refExInfoId ==null ){ 
                    System.debug( ' version 1 , 초기 신규 생성 '  );
                promoteIssues = new CJFW_PromoteIssues__c();
            }else if(expectIncomeId ==null && !promoteIssuesList.isEmpty() ){
                    System.debug( ' version 2 이상  , 신규 생성 '  );
                promoteIssues = new CJFW_PromoteIssues__c();
                promoteIssues = promoteIssuesList[0];
            }else{ 
                    System.debug( ' update '  );
                promoteIssues = promoteIssuesList[0];
            }


            // 매출 , 매익률 값이 없을경우 default 0.00 으로 세팅 
            String[] defaultValSet = new String[] {
                'ManagePltOne__c',          // 솔루션
                'ManagePltTwo__c', 
                'ManagePltThree__c', 
                'ManagePltFour__c', 
                'ManagePltFive__c', 
    
                'ManageStockMoneyOne__c', 
                'ManageStockMoneyTwo__c', 
                'ManageStockMoneyThree__c', 
                'ManageStockMoneyFour__c', 
                'ManageStockMoneyFive__c', 
    
                'ResultSaleOne__c', 
                'ResultSaleTwo__c', 
                'ResultSaleThree__c', 
                'ResultSaleFour__c', 
                'ResultSaleFive__c', 
    
                'ResultSalesProfitOne__c', 
                'ResultSalesProfitTwo__c', 
                'ResultSalesProfitThree__c', 
                'ResultSalesProfitFour__c', 
                'ResultSalesProfitFive__c',
    
                'SynergySaleOne__c',          // 시너지   
                'SynergySaleRateOne__c',
                'SynergySaleTwo__c',
                'SynergySaleRateTwo__c',
                'SynergySaleThree__c',
                'SynergySaleRateThree__c'
            };

            // 시행월 0 으로 세팅 
            String[] defaultZeroSet = new String[] {
                'ManageEnforcementMonthOne__c',   
                'ManageEnforcementMonthTwo__c',
                'ManageEnforcementMonthThree__c',
                'ManageEnforcementMonthFour__c',
                'ManageEnforcementMonthFive__c'

            };  


            for (String defaultSet: defaultValSet) {
                Object fieldValue = promoteIssues.get(defaultSet);
                // 필드 값이 null이면 기본값을 0.00으로 설정
                if (fieldValue == null) fieldValue = defaultZero;
                promoteIssues.put(defaultSet, fieldValue);
            }

            for (String defaultSet : defaultZeroSet) {
                Object fieldValue = promoteIssues.get(defaultSet);
                // 필드 값이 null이면 기본값을 0으로 설정
                if (fieldValue == null) fieldValue = 0; 
                promoteIssues.put(defaultSet, fieldValue);
            }


        } catch (Exception e) {
            String errorMessage = e.getMessage();
            String errorStackTrace = e.getStackTraceString();
            System.debug(' 추진사항정보 에러 메시지: ' + errorMessage);
            System.debug(' 추진사항정보 에러 라인: ' + errorStackTrace);
        }
    }


    /* 
    물류비 관리 (CJFW_DistributionCost__c)에서 값 가져오기 
     */
    public void getDistributeCost() {
        System.debug('# ReportFormController # getDistributeCost # 물류비관리 값');
        
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

            if ( !DistributeCostList.isEmpty() ) {
                System.debug(' 물류비관리 정상적으로 가져올경우 ');
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

            } else {
                System.debug(' 적용날짜가 안맞아서 물류비관리 못가져올경우 ' + defaultZero );
                
                DistributeDirCap = defaultZero;
                DistributeInDirCap = defaultZero;
                DistributeDirEast = defaultZero;
                DistributeInDirEast = defaultZero;
                DistributeDirWest = defaultZero;
                DistributeInDirWest = defaultZero;
                DistributeDirJeju = defaultZero;
                DistributeInDirJeju = defaultZero;
                
            }

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

        }catch(Exception e){
            String errorMessage = e.getMessage();
            String errorStackTrace = e.getStackTraceString(); 
            System.debug('에러 메시지: ' + errorMessage);
            System.debug('에러 라인: ' + errorStackTrace);
        }

    }

    /* 
    예상손익관리(CJFW_ExpectedIncomeManager__c) 에서 값 가져오기
    적용시작일 기준으로 값 가져와야함 
    */
    public void getExpectManager() {
        System.debug('# ReportFormController # getExpectManager # 예상손익관리');
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
                    Source__c 
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
                'SupportFee__c'
            };

            if (IncomeManagerList.size() > 0) {
                IncomeManager = IncomeManagerList[0];
            }
            
            for (String defaultSet : defaultValSet) {
                Object fieldValue = IncomeManager.get(defaultSet);
                // 필드 값이 null이면 기본값을 0.00으로 설정
                if (fieldValue == null) fieldValue = defaultZero; 
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
    public static String saveIncomeExpenses(String DataList, String opportunityId, Decimal versionCheck, String incomeExpensesId, String reportType) {

        try {
            // System.debug('saveIncomeExpenses DataList ' + DataList);
            // System.debug('saveIncomeExpenses opportunityId ' + opportunityId);
            // System.debug('saveIncomeExpenses versionCheck ' + versionCheck);
            // System.debug('saveIncomeExpenses incomeExpensesId ' + incomeExpensesId);
            // System.debug('saveIncomeExpenses reportType ' + reportType);

            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(DataList);
            System.debug('넘어온 데이터! ' + dataMap);
            
            CJFW_ExpectedIncomeExpenses__c expectIncome;

            if (incomeExpensesId != null && incomeExpensesId != '') {
                System.debug('신규개설품의 update ★-> ' + incomeExpensesId);
                expectIncome = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c WHERE Id = :incomeExpensesId];
            } else { // insert 
                System.debug('신규개설품의 insert ★-> ');
                expectIncome = new CJFW_ExpectedIncomeExpenses__c();
                expectIncome.Version__c = versionCheck; // 필수값
                expectIncome.Opportunity__c = opportunityId; //필수값
                if(versionCheck == 1) expectIncome.IsReportCheck__c = true; // 초기 insert 시에 품의지정 default 세팅
            }

            expectIncome.saveResult__c = DataList;
            expectIncome.ReportType__c = reportType;  //품의서 종류에 따라 타입설정 (CRM010: 외식SU 재계약 품의서)

            /* ===== 1. 개요 ===== */
            if (dataMap.containsKey('keyMan')) { // keyMan
                expectIncome.KeyMan__c = (String)dataMap.get('keyMan');
            }
            if (dataMap.containsKey('competitor')) { // 경쟁업체
                expectIncome.Competitor__c = (String)dataMap.get('competitor');
            }
            if (dataMap.containsKey('competitorSuggestions')) { // 경쟁업체 제안
                expectIncome.CompetitorSuggestions__c = (String)dataMap.get('competitorSuggestions');
            }
            if (dataMap.containsKey('obtainOrder')) { // 수주팀
                expectIncome.ObtainOrder__c = (String)dataMap.get('obtainOrder');
            }
            if (dataMap.containsKey('mainMA')) { // 담당MA
                expectIncome.MainMA__c = (String)dataMap.get('mainMA');
            }

            if (dataMap.containsKey('contactMethod')) { // 접촉방법
                expectIncome.ContactMethod__c = (String)dataMap.get('contactMethod');
            }
            if (dataMap.containsKey('firstContact') && dataMap.get('firstContact') !='') { // 최초접촉시기
                expectIncome.FirstContact__c = Date.valueOf(((String) dataMap.get('firstContact')));
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
            if (dataMap.containsKey('outwardEntire')) { // 전체
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

            /* ===== 7. 점당 매출액 ===== */
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
            
            if (dataMap.containsKey('selectedDelivery')) { // 배송횟수
                expectIncome.DeliveryCnt__c = (String)dataMap.get('selectedDelivery'); // 결제수단 종류
            }

            // 개선이후 추가 231106 ( 매출 전용 1)

            if (dataMap.containsKey('salesNameOne')) { 
                expectIncome.SalesNameOne__c = (String)dataMap.get('salesNameOne');
            }
            if (dataMap.containsKey('salesThreeOne')) {
                expectIncome.SalesThreeOne__c = convertToDecimal(dataMap.get('salesThreeOne'));
            }
            if (dataMap.containsKey('salesCapOne')) { 
                expectIncome.SalesCapOne__c = convertToDecimal(dataMap.get('salesCapOne'));
            }
            if (dataMap.containsKey('salesEastOne')) { 
                expectIncome.SalesEastOne__c = convertToDecimal(dataMap.get('salesEastOne'));
            }
            if (dataMap.containsKey('salesWestOne')) { 
                expectIncome.SalesWestOne__c = convertToDecimal(dataMap.get('salesWestOne'));
            }
            if (dataMap.containsKey('salesJejuOne')) { 
                expectIncome.SalesJejuOne__c = convertToDecimal(dataMap.get('salesJejuOne'));
            }
            if (dataMap.containsKey('salesMonthFoOne')) { 
                expectIncome.SalesMonthFoOne__c = convertToDecimal(dataMap.get('salesMonthFoOne'));
            }
            if (dataMap.containsKey('salesImpMonthOne')) { 
                expectIncome.SalesImpMonthOne__c = convertToDecimal(dataMap.get('salesImpMonthOne'));
            }
            if (dataMap.containsKey('salesSoluOne')) { 
                expectIncome.SalesSoluOne__c = convertToDecimal(dataMap.get('salesSoluOne'));
            }    
            // ( 매출 전용 2)
            if (dataMap.containsKey('salesNameTwo')) { 
                expectIncome.SalesNameTwo__c = (String)dataMap.get('salesNameTwo');
            }
            if (dataMap.containsKey('salesThreeTwo')) {
                expectIncome.SalesThreeTwo__c = convertToDecimal(dataMap.get('salesThreeTwo'));
            }
            if (dataMap.containsKey('salesCapTwo')) { 
                expectIncome.SalesCapTwo__c = convertToDecimal(dataMap.get('salesCapTwo'));
            }
            if (dataMap.containsKey('salesEastTwo')) { 
                expectIncome.SalesEastTwo__c = convertToDecimal(dataMap.get('salesEastTwo'));
            }
            if (dataMap.containsKey('salesWestTwo')) { 
                expectIncome.SalesWestTwo__c = convertToDecimal(dataMap.get('salesWestTwo'));
            }
            if (dataMap.containsKey('salesJejuTwo')) { 
                expectIncome.SalesJejuTwo__c = convertToDecimal(dataMap.get('salesJejuTwo'));
            }
            if (dataMap.containsKey('salesMonthFoTwo')) { 
                expectIncome.SalesMonthFoTwo__c = convertToDecimal(dataMap.get('salesMonthFoTwo'));
            }
            if (dataMap.containsKey('salesImpMonthTwo')) { 
                expectIncome.SalesImpMonthTwo__c = convertToDecimal(dataMap.get('salesImpMonthTwo'));
            }
            if (dataMap.containsKey('salesSoluTwo')) { // 매출-전용 : 수도권 
                expectIncome.SalesSoluTwo__c = convertToDecimal(dataMap.get('salesSoluTwo'));
            }           
            // ( 매출 전용 3)
            if (dataMap.containsKey('salesNameThree')) { 
                expectIncome.SalesNameThree__c = (String)dataMap.get('salesNameThree');
            }
            if (dataMap.containsKey('salesThreeThree')) {
                expectIncome.SalesThreeThree__c = convertToDecimal(dataMap.get('salesThreeThree'));
            }
            if (dataMap.containsKey('salesCapThree')) { 
                expectIncome.SalesCapThree__c = convertToDecimal(dataMap.get('salesCapThree'));
            }
            if (dataMap.containsKey('salesEastThree')) { 
                expectIncome.SalesEastThree__c = convertToDecimal(dataMap.get('salesEastThree'));
            }
            if (dataMap.containsKey('salesWestThree')) { 
                expectIncome.SalesWestThree__c = convertToDecimal(dataMap.get('salesWestThree'));
            }
            if (dataMap.containsKey('salesJejuThree')) { 
                expectIncome.SalesJejuThree__c = convertToDecimal(dataMap.get('salesJejuThree'));
            }
            if (dataMap.containsKey('salesMonthFoThree')) { 
                expectIncome.SalesMonthFoThree__c = convertToDecimal(dataMap.get('salesMonthFoThree'));
            }
            if (dataMap.containsKey('salesImpMonthThree')) { 
                expectIncome.SalesImpMonthThree__c = convertToDecimal(dataMap.get('salesImpMonthThree'));
            }
            if (dataMap.containsKey('salesSoluThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesSoluThree__c = convertToDecimal(dataMap.get('salesSoluThree'));
            }           
            // ( 매출 전용 4)
            if (dataMap.containsKey('salesNameFour')) { 
                expectIncome.SalesNameFour__c = (String)dataMap.get('salesNameFour');
            }
            if (dataMap.containsKey('salesThreeFour')) {
                expectIncome.SalesThreeFour__c = convertToDecimal(dataMap.get('salesThreeFour'));
            }
            if (dataMap.containsKey('salesCapFour')) { 
                expectIncome.SalesCapFour__c = convertToDecimal(dataMap.get('salesCapFour'));
            }
            if (dataMap.containsKey('salesEastFour')) { 
                expectIncome.SalesEastFour__c = convertToDecimal(dataMap.get('salesEastFour'));
            }
            if (dataMap.containsKey('salesWestFour')) { 
                expectIncome.SalesWestFour__c = convertToDecimal(dataMap.get('salesWestFour'));
            }
            if (dataMap.containsKey('salesJejuFour')) { 
                expectIncome.SalesJejuFour__c = convertToDecimal(dataMap.get('salesJejuFour'));
            }
            if (dataMap.containsKey('salesMonthFoFour')) { 
                expectIncome.SalesMonthFoFour__c = convertToDecimal(dataMap.get('salesMonthFoFour'));
            }
            if (dataMap.containsKey('salesImpMonthFour')) { 
                expectIncome.SalesImpMonthFour__c = convertToDecimal(dataMap.get('salesImpMonthFour'));
            }
            if (dataMap.containsKey('salesSoluFour')) { // 매출-전용 : 수도권 
                expectIncome.SalesSoluFour__c = convertToDecimal(dataMap.get('salesSoluFour'));
            }
            // ( 매출 직송)
            if (dataMap.containsKey('salesThreeEx')) { // 매출 전용 - 3개월 평균실적 
                expectIncome.SalesReAverageResultExclusive__c = convertToDecimal(dataMap.get('salesThreeEx'));
            }
            if (dataMap.containsKey('salesCapEx')) { // 매출-직송 : 수도권 
                expectIncome.SalesCapitalExclusive__c = convertToDecimal(dataMap.get('salesCapEx'));
            }
            if (dataMap.containsKey('salesEastEx')) { // 매출-직송 : 동부권 
                expectIncome.SalesEastExclusive__c = convertToDecimal(dataMap.get('salesEastEx'));
            }
            if (dataMap.containsKey('salesWestEx')) { // 매출-직송 : 서부권 
                expectIncome.SalesWestExclusive__c = convertToDecimal(dataMap.get('salesWestEx'));
            }
            if (dataMap.containsKey('salesJejuEx')) { // 매출-직송 : 제주권 
                expectIncome.SalesJejuExclusive__c = convertToDecimal(dataMap.get('salesJejuEx'));
            }
            if (dataMap.containsKey('salesFoEx')) { // 매출-직송 : FO
                expectIncome.SalesFoEx__c = convertToDecimal(dataMap.get('salesFoEx'));
            }
            if (dataMap.containsKey('salesImpMonthEx')) { // 매출-직송 - 월 개선실적 
                expectIncome.SalesImproveResultExclusive__c = convertToDecimal(dataMap.get('salesImpMonthEx'));
            }
            if (dataMap.containsKey('salesSoluEx')) { // 매출-직송 - 솔루션 개선실적
                expectIncome.SalesSolutionExclusive__c = convertToDecimal(dataMap.get('salesSoluEx'));
            }            

            // ( 매출 일반 )
            if (dataMap.containsKey('salesThreeGen')) { // 매출 일반- 3개월 평균실적 
                expectIncome.SalesReAverageResultGeneral__c = convertToDecimal(dataMap.get('salesThreeGen'));
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
            if (dataMap.containsKey('salesFoGen')) { // 매출-일반 : FO
                expectIncome.SalesFoGen__c = convertToDecimal(dataMap.get('salesFoGen'));
            }
            if (dataMap.containsKey('salesImpMonthGen')) { //  매출-일반 : 월 예상실적 
                expectIncome.SalesImproveResultGeneral__c = convertToDecimal(dataMap.get('salesImpMonthGen'));
            }
            if (dataMap.containsKey('salesSoluGen')) { // 매출-일반 - 솔루션 개선실적
                expectIncome.SalesSolutionGeneral__c = convertToDecimal(dataMap.get('salesSoluGen'));
            }
            // 매출이익 전용1 
            if (dataMap.containsKey('salesProfitNameOne')) { 
                expectIncome.SalesProfitNameOne__c = (String)dataMap.get('salesProfitNameOne');
            }
            if (dataMap.containsKey('salesProfitThreeOne')) { 
                expectIncome.SalesProfitThreeOne__c = convertToDecimal(dataMap.get('salesProfitThreeOne'));
            }
            if (dataMap.containsKey('salesProfitCapOne')) {
                expectIncome.SalesProfitCapOne__c = convertToDecimal(dataMap.get('salesProfitCapOne'));
            }
            if (dataMap.containsKey('salesProfitEastOne')) { 
                expectIncome.SalesProfitEastOne__c = convertToDecimal(dataMap.get('salesProfitEastOne'));
            }
            if (dataMap.containsKey('salesProfitWestOne')) { 
                expectIncome.SalesProfitWestOne__c = convertToDecimal(dataMap.get('salesProfitWestOne'));
            }
            if (dataMap.containsKey('salesProfitJejuOne')) { 
                expectIncome.SalesProfitJejuOne__c = convertToDecimal(dataMap.get('salesProfitJejuOne'));
            }
            if (dataMap.containsKey('salesProfitFoOne')) { 
                expectIncome.SalesProfitFoOne__c = convertToDecimal(dataMap.get('salesProfitFoOne'));
            }
            if (dataMap.containsKey('salesProfitImpMonthOne')) { 
                expectIncome.SalesProfitImpMonthOne__c = convertToDecimal(dataMap.get('salesProfitImpMonthOne'));
            }
            if (dataMap.containsKey('salesProfitSoluOne')) { 
                expectIncome.SalesProfitSoluOne__c = convertToDecimal(dataMap.get('salesProfitSoluOne'));
            }
            // 매출이익 전용2  
            if (dataMap.containsKey('salesProfitNameTwo')) { 
                expectIncome.SalesProfitNameTwo__c = (String)dataMap.get('salesProfitNameTwo');
            }
            if (dataMap.containsKey('salesProfitThreeTwo')) { 
                expectIncome.SalesProfitThreeTwo__c = convertToDecimal(dataMap.get('salesProfitThreeTwo'));
            }
            if (dataMap.containsKey('salesProfitCapTwo')) {
                expectIncome.SalesProfitCapTwo__c = convertToDecimal(dataMap.get('salesProfitCapTwo'));
            }
            if (dataMap.containsKey('salesProfitEastTwo')) { 
                expectIncome.SalesProfitEastTwo__c = convertToDecimal(dataMap.get('salesProfitEastTwo'));
            }
            if (dataMap.containsKey('salesProfitWestTwo')) { 
                expectIncome.SalesProfitWestTwo__c = convertToDecimal(dataMap.get('salesProfitWestTwo'));
            }
            if (dataMap.containsKey('salesProfitJejuTwo')) { 
                expectIncome.SalesProfitJejuTwo__c = convertToDecimal(dataMap.get('salesProfitJejuTwo'));
            }
            if (dataMap.containsKey('salesProfitFoTwo')) { 
                expectIncome.SalesProfitFoTwo__c = convertToDecimal(dataMap.get('salesProfitFoTwo'));
            }
            if (dataMap.containsKey('salesProfitImpMonthTwo')) { 
                expectIncome.SalesProfitImpMonthTwo__c = convertToDecimal(dataMap.get('salesProfitImpMonthTwo'));
            }
            if (dataMap.containsKey('salesProfitSoluTwo')) { 
                expectIncome.SalesProfitSoluTwo__c = convertToDecimal(dataMap.get('salesProfitSoluTwo'));
            }           
            // 매출이익 전용3  
            if (dataMap.containsKey('salesProfitNameThree')) { 
                expectIncome.SalesProfitNameThree__c = (String)dataMap.get('salesProfitNameThree');
            }
            if (dataMap.containsKey('salesProfitThreeThree')) { 
                expectIncome.SalesProfitThreeThree__c = convertToDecimal(dataMap.get('salesProfitThreeThree'));
            }
            if (dataMap.containsKey('salesProfitCapThree')) {
                expectIncome.SalesProfitCapThree__c = convertToDecimal(dataMap.get('salesProfitCapThree'));
            }
            if (dataMap.containsKey('salesProfitEastThree')) { 
                expectIncome.SalesProfitEastThree__c = convertToDecimal(dataMap.get('salesProfitEastThree'));
            }
            if (dataMap.containsKey('salesProfitWestThree')) { 
                expectIncome.SalesProfitWestThree__c = convertToDecimal(dataMap.get('salesProfitWestThree'));
            }
            if (dataMap.containsKey('salesProfitJejuThree')) { 
                expectIncome.SalesProfitJejuThree__c = convertToDecimal(dataMap.get('salesProfitJejuThree'));
            }
            if (dataMap.containsKey('salesProfitFoThree')) { 
                expectIncome.SalesProfitFoThree__c = convertToDecimal(dataMap.get('salesProfitFoThree'));
            }
            if (dataMap.containsKey('salesProfitImpMonthThree')) { 
                expectIncome.SalesProfitImpMonthThree__c = convertToDecimal(dataMap.get('salesProfitImpMonthThree'));
            }
            if (dataMap.containsKey('salesProfitSoluThree')) { // 매출-전용 : 수도권 
                expectIncome.SalesProfitSoluThree__c = convertToDecimal(dataMap.get('salesProfitSoluThree'));
            }           
            // 매출이익 전용4  
            if (dataMap.containsKey('salesProfitNameFour')) { 
                expectIncome.SalesProfitNameFour__c = (String)dataMap.get('salesProfitNameFour');
            }
            if (dataMap.containsKey('salesProfitThreeFour')) { 
                expectIncome.SalesProfitThreeFour__c = convertToDecimal(dataMap.get('salesProfitThreeFour'));
            }
            if (dataMap.containsKey('salesProfitCapFour')) {
                expectIncome.SalesProfitCapFour__c = convertToDecimal(dataMap.get('salesProfitCapFour'));
            }
            if (dataMap.containsKey('salesProfitEastFour')) { 
                expectIncome.SalesProfitEastFour__c = convertToDecimal(dataMap.get('salesProfitEastFour'));
            }
            if (dataMap.containsKey('salesProfitWestFour')) { 
                expectIncome.SalesProfitWestFour__c = convertToDecimal(dataMap.get('salesProfitWestFour'));
            }
            if (dataMap.containsKey('salesProfitJejuFour')) { 
                expectIncome.SalesProfitJejuFour__c = convertToDecimal(dataMap.get('salesProfitJejuFour'));
            }
            if (dataMap.containsKey('salesProfitFoFour')) { 
                expectIncome.SalesProfitFoFour__c = convertToDecimal(dataMap.get('salesProfitFoFour'));
            }
            if (dataMap.containsKey('salesProfitImpMonthFour')) { 
                expectIncome.SalesProfitImpMonthFour__c = convertToDecimal(dataMap.get('salesProfitImpMonthFour'));
            }
            if (dataMap.containsKey('salesProfitSoluFour')) { 
                expectIncome.SalesProfitSoluFour__c = convertToDecimal(dataMap.get('salesProfitSoluFour'));
            }
            // 매출이익 직송 
            if (dataMap.containsKey('salesProfitThreeEx')) { 
                expectIncome.SalesProfitReAverageResultExclusive__c = convertToDecimal(dataMap.get('salesProfitThreeEx'));
            }
            if (dataMap.containsKey('salesProfitCapEx')) { 
                expectIncome.SalesProfitCaptialExclusive__c = convertToDecimal(dataMap.get('salesProfitCapEx'));
            }
            if (dataMap.containsKey('salesProfitEastEx')) { 
                expectIncome.SalesProfitEastExclusive__c = convertToDecimal(dataMap.get('salesProfitEastEx'));
            }
            if (dataMap.containsKey('salesProfitWestEx')) { 
                expectIncome.SalesProfitWestExclusive__c = convertToDecimal(dataMap.get('salesProfitWestEx'));
            }
            if (dataMap.containsKey('salesProfitJejuEx')) { 
                expectIncome.SalesProfitJejuExclusive__c = convertToDecimal(dataMap.get('salesProfitJejuEx'));
            }
            if (dataMap.containsKey('salesProfitFoEx')) { 
                expectIncome.SalesProfitFoEx__c = convertToDecimal(dataMap.get('salesProfitFoEx'));
            }
            if (dataMap.containsKey('salesProfitImpMonthEx')) { 
                expectIncome.salesProfitImpMonthEx__c = convertToDecimal(dataMap.get('salesProfitImpMonthEx'));
            }
            if (dataMap.containsKey('salesProfitSoluEx')) {
                expectIncome.SalesProfitSoluEx__c = convertToDecimal(dataMap.get('salesProfitSoluEx'));
            }
            // 매출이익 일반
            if (dataMap.containsKey('salesProfitThreeGen')) { 
                expectIncome.SalesProfitReAverageResultGeneral__c = convertToDecimal(dataMap.get('salesProfitThreeGen'));
            }
            if (dataMap.containsKey('salesProfitCapGen')) { 
                expectIncome.SalesProfitCapitalGeneral__c = convertToDecimal(dataMap.get('salesProfitCapGen'));
            }
            if (dataMap.containsKey('salesProfitEastGen')) { 
                expectIncome.SalesProfitEastGeneral__c = convertToDecimal(dataMap.get('salesProfitEastGen'));
            }
            if (dataMap.containsKey('salesProfitWestGen')) { 
                expectIncome.SalesProfitWestGeneral__c = convertToDecimal(dataMap.get('salesProfitWestGen'));
            }
            if (dataMap.containsKey('salesProfitJejuGen')) { 
                expectIncome.SalesProfitJejuGeneral__c = convertToDecimal(dataMap.get('salesProfitJejuGen'));
            }
            if (dataMap.containsKey('salesProfitFoGen')) { 
                expectIncome.SalesProfitFoGen__c = convertToDecimal(dataMap.get('salesProfitFoGen'));
            }
            if (dataMap.containsKey('salesProfitImpMonthGen')) { 
                expectIncome.salesProfitImpMonthGen__c = convertToDecimal(dataMap.get('salesProfitImpMonthGen'));
            }
            if (dataMap.containsKey('profitRateEx')) { 
                expectIncome.ProfitRateExclusive__c = convertToDecimal(dataMap.get('profitRateEx'));
            }

            // 매익률 전용1 

            if (dataMap.containsKey('profitRateNameOne')) { 
                expectIncome.ProfitRateNameOne__c = (String)dataMap.get('profitRateNameOne');
            }
            if (dataMap.containsKey('profitRateNameTwo')) { 
                expectIncome.ProfitRateNameTwo__c = (String)dataMap.get('profitRateNameTwo');
            }
            if (dataMap.containsKey('profitRateNameThree')) { 
                expectIncome.ProfitRateNameThree__c = (String)dataMap.get('profitRateNameThree');
            }
            if (dataMap.containsKey('profitRateNameFour')) { 
                expectIncome.ProfitRateNameFour__c = (String)dataMap.get('profitRateNameFour');
            }
            

            // 물류비(실제) - 직접 
            if (dataMap.containsKey('distributeDirThree')) { // 재계약 3개월전
                expectIncome.DistDirReAverageResult__c = convertToDecimal(dataMap.get('distributeDirThree'));
            }
            if (dataMap.containsKey('distributeDirCap')) {  // 수도권 
                expectIncome.DistributeDirCap__c = convertToDecimal(dataMap.get('distributeDirCap'));
            }
            if (dataMap.containsKey('distributeDirEast')) { // 동부권 
                expectIncome.DistributeDirEast__c = convertToDecimal(dataMap.get('distributeDirEast'));
            }
            if (dataMap.containsKey('distributeDirWest')) { // 서부권 
                expectIncome.DistributeDirWest__c = convertToDecimal(dataMap.get('distributeDirWest'));
            }
            if (dataMap.containsKey('distributeDirJeju')) { // 제주권 
                expectIncome.DistributeDirJeju__c = convertToDecimal(dataMap.get('distributeDirJeju'));
            }
            if (dataMap.containsKey('distributeDirFo')) {   // FO센터 
               expectIncome.DistributeDirFo__c = convertToDecimal(dataMap.get('distributeDirFo'));
            }
            if (dataMap.containsKey('distributeDirImpMonth')) { // 솔루션
               expectIncome.DistributeDirImpMonth__c = convertToDecimal(dataMap.get('distributeDirImpMonth'));
            }
            // 물류비(실제) - 간접

            if (dataMap.containsKey('distributeInDirThree')) { // 재계약 3개월전
                expectIncome.DistInDirReAverageResult__c = convertToDecimal(dataMap.get('distributeInDirThree'));
            }
            if (dataMap.containsKey('distributeInDirCap')) {   // 수도권 
                expectIncome.DistributeInDirCap__c = convertToDecimal(dataMap.get('distributeInDirCap'));
            }
            if (dataMap.containsKey('distributeInDirEast')) {  // 동부권 
                expectIncome.DistributeInDirEast__c = convertToDecimal(dataMap.get('distributeInDirEast'));
            }
            if (dataMap.containsKey('distributeInDirWest')) {  // 서부권 
                expectIncome.DistributeInDirWest__c = convertToDecimal(dataMap.get('distributeInDirWest'));
            }
            if (dataMap.containsKey('distributeInDirJeju')) {  // 제주권 
                expectIncome.DistributeInDirJeju__c = convertToDecimal(dataMap.get('distributeInDirJeju'));
            }
            if (dataMap.containsKey('distributeInDirFo')) {    // FO센터 
               expectIncome.DistributeInDirFo__c = convertToDecimal(dataMap.get('distributeInDirFo'));
            }
            if (dataMap.containsKey('distributeInDirImpMonth')) {    // 솔루션 
               expectIncome.DistributeInDirImpMonth__c = convertToDecimal(dataMap.get('distributeInDirImpMonth'));
            }

            // 실적현황 지정일자 
            if (dataMap.containsKey('salesPerformDate')) { 
                expectIncome.SalesPerformDate__c = Date.valueOf(((String) dataMap.get('salesPerformDate')));
            }

            upsert expectIncome;

            // 실적현황 insert 
            if(expectIncome.Id !=null){
                upsertSalesPerform(expectIncome.Id , dataMap);
                upsertPromoteIssues(expectIncome.Id , dataMap);
            }

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
    추진사항(CJFW_PromoteIssues__c) upsert
    @param : 신규개설품의Id , VF page 에서 수정데이터가 내용이담긴 dataMap
    */
    public static void upsertPromoteIssues(String expectIncomeId , Map<String, Object> dataMap) {

        CJFW_PromoteIssues__c salesPromoteIssue;

        List<CJFW_PromoteIssues__c> salesPromoteIssueList = [SELECT Id FROM CJFW_PromoteIssues__c WHERE ExpectedIncomeExpensesId__c  = :expectIncomeId LIMIT 1];
        if(!salesPromoteIssueList.isEmpty()){
            System.debug('추진사항 update ★-> ' + expectIncomeId);
            salesPromoteIssue = salesPromoteIssueList[0];
        }else{
            System.debug('추진사항 insert ★-> ' );
            salesPromoteIssue = new CJFW_PromoteIssues__c();
            salesPromoteIssue.ExpectedIncomeExpensesId__c = expectIncomeId;
        }

        // 솔루션 ㅣㅣ구분
        if (dataMap.containsKey('solutionDivisionOne')) { 
            salesPromoteIssue.SolutionDivisionOne__c = (String)dataMap.get('solutionDivisionOne');
        }
        if (dataMap.containsKey('solutionDivisionTwo')) { 
            salesPromoteIssue.SolutionDivisionTwo__c = (String)dataMap.get('solutionDivisionTwo');
        }
        if (dataMap.containsKey('solutionDivisionThree')) { 
            salesPromoteIssue.SolutionDivisionThree__c = (String)dataMap.get('solutionDivisionThree');
        }
        if (dataMap.containsKey('solutionDivisionFour')) { 
            salesPromoteIssue.SolutionDivisionFour__c = (String)dataMap.get('solutionDivisionFour');
        }
        if (dataMap.containsKey('solutionDivisionFive')) { 
            salesPromoteIssue.SolutionDivisionFive__c = (String)dataMap.get('solutionDivisionFive');
        }
        // 솔루션 ㅣㅣ 세부구분        
        if (dataMap.containsKey('solutionDetailsOne')) { 
            salesPromoteIssue.SolutionDetailsOne__c = (String)dataMap.get('solutionDetailsOne');
        }
        if (dataMap.containsKey('solutionDetailsTwo')) { 
            salesPromoteIssue.SolutionDetailsTwo__c = (String)dataMap.get('solutionDetailsTwo');
        }
        if (dataMap.containsKey('solutionDetailsThree')) { 
            salesPromoteIssue.SolutionDetailsThree__c = (String)dataMap.get('solutionDetailsThree');
        }
        if (dataMap.containsKey('solutionDetailsFour')) { 
            salesPromoteIssue.SolutionDetailsFour__c = (String)dataMap.get('solutionDetailsFour');
        }
        if (dataMap.containsKey('solutionDetailsFive')) { 
            salesPromoteIssue.SolutionDetailsFive__c = (String)dataMap.get('solutionDetailsFive');
        }
        // 솔루션 ㅣㅣ 신규/상품전환        
        if (dataMap.containsKey('solutionNewOne')) { 
            salesPromoteIssue.SolutionNewOne__c = (String)dataMap.get('solutionNewOne');
        }
        if (dataMap.containsKey('solutionNewTwo')) { 
            salesPromoteIssue.SolutionNewTwo__c = (String)dataMap.get('solutionNewTwo');
        }
        if (dataMap.containsKey('solutionNewThree')) { 
            salesPromoteIssue.SolutionNewThree__c = (String)dataMap.get('solutionNewThree');
        }
        if (dataMap.containsKey('solutionNewFour')) { 
            salesPromoteIssue.SolutionNewFour__c = (String)dataMap.get('solutionNewFour');
        }
        if (dataMap.containsKey('solutionNewFive')) { 
            salesPromoteIssue.SolutionNewFive__c = (String)dataMap.get('solutionNewFive');
        }
        // 솔루션 ㅣㅣ 전용/범용        
        if (dataMap.containsKey('solutionUseOne')) { 
            salesPromoteIssue.SolutionUseOne__c = (String)dataMap.get('solutionUseOne');
        }
        if (dataMap.containsKey('solutionUseTwo')) { 
            salesPromoteIssue.SolutionUseTwo__c = (String)dataMap.get('solutionUseTwo');
        }
        if (dataMap.containsKey('solutionUseThree')) { 
            salesPromoteIssue.SolutionUseThree__c = (String)dataMap.get('solutionUseThree');
        }
        if (dataMap.containsKey('solutionUseFour')) { 
            salesPromoteIssue.SolutionUseFour__c = (String)dataMap.get('solutionUseFour');
        }
        if (dataMap.containsKey('solutionUseFive')) { 
            salesPromoteIssue.SolutionUseFive__c = (String)dataMap.get('solutionUseFive');
        }
        // 솔루션 ㅣㅣ 상품명        
        if (dataMap.containsKey('solutionProductNameOne')) { 
            salesPromoteIssue.SolutionProductNameOne__c = (String)dataMap.get('solutionProductNameOne');
        }
        if (dataMap.containsKey('solutionProductNameTwo')) { 
            salesPromoteIssue.SolutionProductNameTwo__c = (String)dataMap.get('solutionProductNameTwo');
        }
        if (dataMap.containsKey('solutionProductNameThree')) { 
            salesPromoteIssue.SolutionProductNameThree__c = (String)dataMap.get('solutionProductNameThree');
        }
        if (dataMap.containsKey('solutionProductNameFour')) { 
            salesPromoteIssue.SolutionProductNameFour__c = (String)dataMap.get('solutionProductNameFour');
        }
        if (dataMap.containsKey('solutionProductNameFive')) { 
            salesPromoteIssue.SolutionProductNameFive__c = (String)dataMap.get('solutionProductNameFive');
        }
        // 솔루션 ㅣㅣ 저장조건        
        if (dataMap.containsKey('solutionStoreOne')) { 
            salesPromoteIssue.SolutionStoreOne__c = (String)dataMap.get('solutionStoreOne');
        }
        if (dataMap.containsKey('solutionStoreTwo')) { 
            salesPromoteIssue.SolutionStoreTwo__c = (String)dataMap.get('solutionStoreTwo');
        }
        if (dataMap.containsKey('solutionStoreThree')) { 
            salesPromoteIssue.SolutionStoreThree__c = (String)dataMap.get('solutionStoreThree');
        }
        if (dataMap.containsKey('solutionStoreFour')) { 
            salesPromoteIssue.SolutionStoreFour__c = (String)dataMap.get('solutionStoreFour');
        }
        if (dataMap.containsKey('solutionStoreFive')) { 
            salesPromoteIssue.SolutionStoreFive__c = (String)dataMap.get('solutionStoreFive');
        }
        // 솔루션 ㅣㅣ 출고단위        
        if (dataMap.containsKey('solutionReleaseUnitOne')) { 
            salesPromoteIssue.SolutionReleaseUnitOne__c = (String)dataMap.get('solutionReleaseUnitOne');
        }
        if (dataMap.containsKey('solutionReleaseUnitTwo')) { 
            salesPromoteIssue.SolutionReleaseUnitTwo__c = (String)dataMap.get('solutionReleaseUnitTwo');
        }
        if (dataMap.containsKey('solutionReleaseUnitThree')) { 
            salesPromoteIssue.SolutionReleaseUnitThree__c = (String)dataMap.get('solutionReleaseUnitThree');
        }
        if (dataMap.containsKey('solutionReleaseUnitFour')) { 
            salesPromoteIssue.SolutionReleaseUnitFour__c = (String)dataMap.get('solutionReleaseUnitFour');
        }
        if (dataMap.containsKey('solutionReleaseUnitFive')) { 
            salesPromoteIssue.SolutionReleaseUnitFive__c = (String)dataMap.get('solutionReleaseUnitFive');
        }
        // 재고운영 ㅣㅣ 시행월        
        if (dataMap.containsKey('manageEnforcementMonthOne')) { 
            salesPromoteIssue.ManageEnforcementMonthOne__c = convertToDecimal(dataMap.get('manageEnforcementMonthOne'));
        }
        if (dataMap.containsKey('manageEnforcementMonthTwo')) { 
            salesPromoteIssue.ManageEnforcementMonthTwo__c = convertToDecimal(dataMap.get('manageEnforcementMonthTwo'));
        }
        if (dataMap.containsKey('manageEnforcementMonthThree')) { 
            salesPromoteIssue.ManageEnforcementMonthThree__c = convertToDecimal(dataMap.get('manageEnforcementMonthThree'));
        }
        if (dataMap.containsKey('manageEnforcementMonthFour')) { 
            salesPromoteIssue.ManageEnforcementMonthFour__c = convertToDecimal(dataMap.get('manageEnforcementMonthFour'));
        }
        if (dataMap.containsKey('manageEnforcementMonthFive')) { 
            salesPromoteIssue.ManageEnforcementMonthFive__c = convertToDecimal(dataMap.get('manageEnforcementMonthFive'));
        }
        // 재고운영 ㅣㅣ PLT        
        if (dataMap.containsKey('managePltOne')) { 
            salesPromoteIssue.ManagePltOne__c = convertToDecimal(dataMap.get('managePltOne'));
        }
        if (dataMap.containsKey('managePltTwo')) { 
            salesPromoteIssue.ManagePltTwo__c = convertToDecimal(dataMap.get('managePltTwo'));
        }
        if (dataMap.containsKey('managePltThree')) { 
            salesPromoteIssue.ManagePltThree__c = convertToDecimal(dataMap.get('managePltThree'));
        }
        if (dataMap.containsKey('managePltFour')) { 
            salesPromoteIssue.ManagePltFour__c = convertToDecimal(dataMap.get('managePltFour'));
        }
        if (dataMap.containsKey('managePltFive')) { 
            salesPromoteIssue.ManagePltFive__c = convertToDecimal(dataMap.get('managePltFive'));
        }
        // 재고운영 ㅣㅣ 재고금액        
        if (dataMap.containsKey('manageStockMoneyOne')) { 
            salesPromoteIssue.ManageStockMoneyOne__c = convertToDecimal(dataMap.get('manageStockMoneyOne'));
        }
        if (dataMap.containsKey('manageStockMoneyTwo')) { 
            salesPromoteIssue.ManageStockMoneyTwo__c = convertToDecimal(dataMap.get('manageStockMoneyTwo'));
        }
        if (dataMap.containsKey('manageStockMoneyThree')) { 
            salesPromoteIssue.ManageStockMoneyThree__c = convertToDecimal(dataMap.get('manageStockMoneyThree'));
        }
        if (dataMap.containsKey('manageStockMoneyFour')) { 
            salesPromoteIssue.ManageStockMoneyFour__c = convertToDecimal(dataMap.get('manageStockMoneyFour'));
        }
        if (dataMap.containsKey('manageStockMoneyFive')) { 
            salesPromoteIssue.ManageStockMoneyFive__c = convertToDecimal(dataMap.get('manageStockMoneyFive'));
        }
        // 상품실적 ㅣㅣ 매출        
        if (dataMap.containsKey('resultSaleOne')) { 
            salesPromoteIssue.ResultSaleOne__c = convertToDecimal(dataMap.get('resultSaleOne'));
        }
        if (dataMap.containsKey('resultSaleTwo')) { 
            salesPromoteIssue.ResultSaleTwo__c = convertToDecimal(dataMap.get('resultSaleTwo'));
        }
        if (dataMap.containsKey('resultSaleThree')) { 
            salesPromoteIssue.ResultSaleThree__c = convertToDecimal(dataMap.get('resultSaleThree'));
        }
        if (dataMap.containsKey('resultSaleFour')) { 
            salesPromoteIssue.ResultSaleFour__c = convertToDecimal(dataMap.get('resultSaleFour'));
        }
        if (dataMap.containsKey('resultSaleFive')) { 
            salesPromoteIssue.ResultSaleFive__c = convertToDecimal(dataMap.get('resultSaleFive'));
        }
        // 상품실적 ㅣㅣ 매출이익      
        if (dataMap.containsKey('resultSalesProfitOne')) { 
            salesPromoteIssue.ResultSalesProfitOne__c = convertToDecimal(dataMap.get('resultSalesProfitOne'));
        }
        if (dataMap.containsKey('resultSalesProfitTwo')) { 
            salesPromoteIssue.ResultSalesProfitTwo__c = convertToDecimal(dataMap.get('resultSalesProfitTwo'));
        }
        if (dataMap.containsKey('resultSalesProfitThree')) { 
            salesPromoteIssue.ResultSalesProfitThree__c = convertToDecimal(dataMap.get('resultSalesProfitThree'));
        }
        if (dataMap.containsKey('resultSalesProfitFour')) { 
            salesPromoteIssue.ResultSalesProfitFour__c = convertToDecimal(dataMap.get('resultSalesProfitFour'));
        }
        if (dataMap.containsKey('resultSalesProfitFive')) { 
            salesPromoteIssue.ResultSalesProfitFive__c = convertToDecimal(dataMap.get('resultSalesProfitFive'));
        }

        // 시너지 1
        if (dataMap.containsKey('synergyDivisionOne')) {  // 구분
            salesPromoteIssue.SynergyDivisionOne__c = (String)dataMap.get('synergyDivisionOne');
        }
        if (dataMap.containsKey('synergyTypeOne')) {      // 경로구분
            salesPromoteIssue.SynergyTypeOne__c = (String)dataMap.get('synergyTypeOne');
        }
        if (dataMap.containsKey('synergySaleOne')) {      // 매출 (소수)
            salesPromoteIssue.SynergySaleOne__c = convertToDecimal(dataMap.get('synergySaleOne'));
        }
        if (dataMap.containsKey('synergySaleRateOne')) {  // 매익률 (소수)
            salesPromoteIssue.SynergySaleRateOne__c = convertToDecimal(dataMap.get('synergySaleRateOne'));
        }
        if (dataMap.containsKey('synergyRemarkOne')) {    // 주요내용
            salesPromoteIssue.SynergyRemarkOne__c = (String)dataMap.get('synergyRemarkOne');
        }
        // 시너지 2
        if (dataMap.containsKey('synergyDivisionTwo')) {  // 구분
            salesPromoteIssue.SynergyDivisionTwo__c = (String)dataMap.get('synergyDivisionTwo');
        }
        if (dataMap.containsKey('synergyTypeTwo')) {      // 경로구분
            salesPromoteIssue.SynergyTypeTwo__c = (String)dataMap.get('synergyTypeTwo');
        }
        if (dataMap.containsKey('synergySaleTwo')) {      // 매출 (소수)
            salesPromoteIssue.SynergySaleTwo__c = convertToDecimal(dataMap.get('synergySaleTwo'));
        }
        if (dataMap.containsKey('synergySaleRateTwo')) {  // 매익률 (소수)
            salesPromoteIssue.SynergySaleRateTwo__c = convertToDecimal(dataMap.get('synergySaleRateTwo'));
        }
        if (dataMap.containsKey('synergyRemarkTwo')) {    // 주요내용
            salesPromoteIssue.SynergyRemarkTwo__c = (String)dataMap.get('synergyRemarkTwo');
        }

        // 시너지 3
        if (dataMap.containsKey('synergyDivisionThree')) {  // 구분
            salesPromoteIssue.SynergyDivisionThree__c = (String)dataMap.get('synergyDivisionThree');
        }
        if (dataMap.containsKey('synergyTypeThree')) {      // 경로구분
            salesPromoteIssue.SynergyTypeThree__c = (String)dataMap.get('synergyTypeThree');
        }
        if (dataMap.containsKey('synergySaleThree')) {      // 매출 (소수)
            salesPromoteIssue.SynergySaleThree__c = convertToDecimal(dataMap.get('synergySaleThree'));
        }
        if (dataMap.containsKey('synergySaleRateThree')) {  // 매익률 (소수)
            salesPromoteIssue.SynergySaleRateThree__c = convertToDecimal(dataMap.get('synergySaleRateThree'));
        }
        if (dataMap.containsKey('synergyRemarkThree')) {    // 주요내용
            salesPromoteIssue.SynergyRemarkThree__c = (String)dataMap.get('synergyRemarkThree');
        }

        upsert salesPromoteIssue;

    }

    /* 
    실적현황정보(CJFW_SalesPerformance__c) upsert
    @param : 신규개설품의Id , VF page 에서 수정데이터가 내용이담긴 dataMap
    */
    public static void upsertSalesPerform(String expectIncomeId , Map<String, Object> dataMap) {


        try{
     
            CJFW_SalesPerformance__c salesPerform;

            List<CJFW_SalesPerformance__c> salesPerformList = [SELECT Id FROM CJFW_SalesPerformance__c WHERE ExpectedIncomeExpensesId__c = :expectIncomeId LIMIT 1];

            if(!salesPerformList.isEmpty()){
                salesPerform = salesPerformList[0];
                System.debug('실적현황 update ★-> ' + expectIncomeId);

            }else{
                System.debug('실적현황 insert ★-> ' );
                salesPerform = new CJFW_SalesPerformance__c();
                salesPerform.ExpectedIncomeExpensesId__c = expectIncomeId; // 필수값 
            }

            if (dataMap.containsKey('beforeSales')) { 
                salesPerform.BeforeSales__c = convertToDecimal(dataMap.get('beforeSales'));
            }
            if (dataMap.containsKey('salesElevenAgo')) { 
                salesPerform.SalesElevenAgo__c = convertToDecimal(dataMap.get('salesElevenAgo'));
            }
            if (dataMap.containsKey('salesTenAgo')) { 
                salesPerform.SalesTenAgo__c = convertToDecimal(dataMap.get('salesTenAgo'));
            }
            if (dataMap.containsKey('salesNineAgo')) { 
                salesPerform.SalesNineAgo__c = convertToDecimal(dataMap.get('salesNineAgo'));
            }
            if (dataMap.containsKey('salesEightAgo')) { 
                salesPerform.SalesEightAgo__c = convertToDecimal(dataMap.get('salesEightAgo'));
            }
            if (dataMap.containsKey('salesSevenAgo')) { 
                salesPerform.SalesSevenAgo__c = convertToDecimal(dataMap.get('salesSevenAgo'));
            }
            if (dataMap.containsKey('salesSixAgo')) { 
                salesPerform.SalesSixAgo__c = convertToDecimal(dataMap.get('salesSixAgo'));
            }
            if (dataMap.containsKey('salesFiveAgo')) { 
                salesPerform.SalesFiveAgo__c = convertToDecimal(dataMap.get('salesFiveAgo'));
            }
            if (dataMap.containsKey('salesFourAgo')) { 
                salesPerform.SalesFourAgo__c = convertToDecimal(dataMap.get('salesFourAgo'));
            }
            if (dataMap.containsKey('salesThreeAgo')) { 
                salesPerform.SalesThreeAgo__c = convertToDecimal(dataMap.get('salesThreeAgo'));
            }
            if (dataMap.containsKey('salesTwoAgo')) { 
                salesPerform.SalesTwoAgo__c = convertToDecimal(dataMap.get('salesTwoAgo'));
            }
            if (dataMap.containsKey('salesOneAgo')) { 
                salesPerform.SalesOneAgo__c = convertToDecimal(dataMap.get('salesOneAgo'));
            }
            // 매출 이익 
            if (dataMap.containsKey('beforesalesProfit')) { 
                salesPerform.BeforeSalesProfit__c = convertToDecimal(dataMap.get('beforesalesProfit'));
            }
            if (dataMap.containsKey('salesProfitElevenAgo')) { 
                salesPerform.SalesProfitElevenAgo__c = convertToDecimal(dataMap.get('salesProfitElevenAgo'));
            }
            if (dataMap.containsKey('salesProfitTenAgo')) { 
                salesPerform.SalesProfitTenAgo__c = convertToDecimal(dataMap.get('salesProfitTenAgo'));
            }
            if (dataMap.containsKey('salesProfitNineAgo')) { 
                salesPerform.SalesProfitNineAgo__c = convertToDecimal(dataMap.get('salesProfitNineAgo'));
            }
            if (dataMap.containsKey('salesProfitEightAgo')) { 
                salesPerform.SalesProfitEightAgo__c = convertToDecimal(dataMap.get('salesProfitEightAgo'));
            }
            if (dataMap.containsKey('salesProfitSevenAgo')) { 
                salesPerform.SalesProfitSevenAgo__c = convertToDecimal(dataMap.get('salesProfitSevenAgo'));
            }
            if (dataMap.containsKey('salesProfitSixAgo')) { 
                salesPerform.SalesProfitSixAgo__c = convertToDecimal(dataMap.get('salesProfitSixAgo'));
            }
            if (dataMap.containsKey('salesProfitFiveAgo')) { 
                salesPerform.SalesProfitFiveAgo__c = convertToDecimal(dataMap.get('salesProfitFiveAgo'));
            }
            if (dataMap.containsKey('salesProfitFourAgo')) { 
                salesPerform.SalesProfitFourAgo__c = convertToDecimal(dataMap.get('salesProfitFourAgo'));
            }
            if (dataMap.containsKey('salesProfitThreeAgo')) { 
                salesPerform.SalesProfitThreeAgo__c = convertToDecimal(dataMap.get('salesProfitThreeAgo'));
            }
            if (dataMap.containsKey('salesProfitTwoAgo')) { 
                salesPerform.SalesProfitTwoAgo__c = convertToDecimal(dataMap.get('salesProfitTwoAgo'));
            }
            if (dataMap.containsKey('salesProfitOneAgo')) { 
                salesPerform.SalesProfitOneAgo__c = convertToDecimal(dataMap.get('salesProfitOneAgo'));
            }
            // 매장수 
            if (dataMap.containsKey('beforeSalesStore')) { 
                salesPerform.BeforeSalesStore__c = convertToDecimal(dataMap.get('beforeSalesStore'));
            }
            if (dataMap.containsKey('salesStoreElevenAgo')) { 
                salesPerform.SalesStoreElevenAgo__c = convertToDecimal(dataMap.get('salesStoreElevenAgo'));
            }
            if (dataMap.containsKey('salesStoreTenAgo')) { 
                salesPerform.SalesStoreTenAgo__c = convertToDecimal(dataMap.get('salesStoreTenAgo'));
            }
            if (dataMap.containsKey('salesStoreNineAgo')) { 
                salesPerform.SalesStoreNineAgo__c = convertToDecimal(dataMap.get('salesStoreNineAgo'));
            }
            if (dataMap.containsKey('salesStoreEightAgo')) { 
                salesPerform.SalesStoreEightAgo__c = convertToDecimal(dataMap.get('salesStoreEightAgo'));
            }
            if (dataMap.containsKey('salesStoreSevenAgo')) { 
                salesPerform.SalesStoreSevenAgo__c = convertToDecimal(dataMap.get('salesStoreSevenAgo'));
            }
            if (dataMap.containsKey('salesStoreSixAgo')) { 
                salesPerform.SalesStoreSixAgo__c = convertToDecimal(dataMap.get('salesStoreSixAgo'));
            }
            if (dataMap.containsKey('salesStoreFiveAgo')) { 
                salesPerform.SalesStoreFiveAgo__c = convertToDecimal(dataMap.get('salesStoreFiveAgo'));
            }
            if (dataMap.containsKey('salesStoreFourAgo')) { 
                salesPerform.SalesStoreFourAgo__c = convertToDecimal(dataMap.get('salesStoreFourAgo'));
            }
            if (dataMap.containsKey('salesStoreThreeAgo')) { 
                salesPerform.SalesStoreThreeAgo__c = convertToDecimal(dataMap.get('salesStoreThreeAgo'));
            }
            if (dataMap.containsKey('salesStoreTwoAgo')) { 
                salesPerform.SalesStoreTwoAgo__c = convertToDecimal(dataMap.get('salesStoreTwoAgo'));
            }
            if (dataMap.containsKey('salesStoreOneAgo')) { 
                salesPerform.SalesStoreOneAgo__c = convertToDecimal(dataMap.get('salesStoreOneAgo'));
            }
            // 물류비 
            if (dataMap.containsKey('beforeDistribute')) { 
                salesPerform.BeforeDistribute__c = convertToDecimal(dataMap.get('beforeDistribute'));
            }
            if (dataMap.containsKey('distributeElevenAgo')) { 
                salesPerform.DistributeElevenAgo__c = convertToDecimal(dataMap.get('distributeElevenAgo'));
            }
            if (dataMap.containsKey('distributeTenAgo')) { 
                salesPerform.DistributeTenAgo__c = convertToDecimal(dataMap.get('distributeTenAgo'));
            }
            if (dataMap.containsKey('distributeNineAgo')) { 
                salesPerform.DistributeNineAgo__c = convertToDecimal(dataMap.get('distributeNineAgo'));
            }
            if (dataMap.containsKey('distributeEightAgo')) { 
                salesPerform.DistributeEightAgo__c = convertToDecimal(dataMap.get('distributeEightAgo'));
            }
            if (dataMap.containsKey('distributeSevenAgo')) { 
                salesPerform.DistributeSevenAgo__c = convertToDecimal(dataMap.get('distributeSevenAgo'));
            }
            if (dataMap.containsKey('distributeSixAgo')) { 
                salesPerform.DistributeSixAgo__c = convertToDecimal(dataMap.get('distributeSixAgo'));
            }
            if (dataMap.containsKey('distributeFiveAgo')) { 
                salesPerform.DistributeFiveAgo__c = convertToDecimal(dataMap.get('distributeFiveAgo'));
            }
            if (dataMap.containsKey('distributeFourAgo')) { 
                salesPerform.DistributeFourAgo__c = convertToDecimal(dataMap.get('distributeFourAgo'));
            }
            if (dataMap.containsKey('distributeThreeAgo')) { 
                salesPerform.DistributeThreeAgo__c = convertToDecimal(dataMap.get('distributeThreeAgo'));
            }
            if (dataMap.containsKey('distributeTwoAgo')) { 
                salesPerform.DistributeTwoAgo__c = convertToDecimal(dataMap.get('distributeTwoAgo'));
            }
            if (dataMap.containsKey('distributeOneAgo')) { 
                salesPerform.DistributeOneAgo__c = convertToDecimal(dataMap.get('distributeOneAgo'));
            }
            // 직접 물류비 
            if (dataMap.containsKey('beforedistributeDir')) { 
                salesPerform.BeforeDistributeDir__c = convertToDecimal(dataMap.get('beforedistributeDir'));
            }
            if (dataMap.containsKey('distributeDirElevenAgo')) { 
                salesPerform.DistributeDirElevenAgo__c = convertToDecimal(dataMap.get('distributeDirElevenAgo'));
            }
            if (dataMap.containsKey('distributeDirTenAgo')) { 
                salesPerform.DistributeDirTenAgo__c = convertToDecimal(dataMap.get('distributeDirTenAgo'));
            }
            if (dataMap.containsKey('distributeDirNineAgo')) { 
                salesPerform.DistributeDirNineAgo__c = convertToDecimal(dataMap.get('distributeDirNineAgo'));
            }
            if (dataMap.containsKey('distributeDirEightAgo')) { 
                salesPerform.DistributeDirEightAgo__c = convertToDecimal(dataMap.get('distributeDirEightAgo'));
            }
            if (dataMap.containsKey('distributeDirSevenAgo')) { 
                salesPerform.DistributeDirSevenAgo__c = convertToDecimal(dataMap.get('distributeDirSevenAgo'));
            }
            if (dataMap.containsKey('distributeDirSixAgo')) { 
                salesPerform.DistributeDirSixAgo__c = convertToDecimal(dataMap.get('distributeDirSixAgo'));
            }
            if (dataMap.containsKey('distributeDirFiveAgo')) { 
                salesPerform.DistributeDirFiveAgo__c = convertToDecimal(dataMap.get('distributeDirFiveAgo'));
            }
            if (dataMap.containsKey('distributeDirFourAgo')) { 
                salesPerform.DistributeDirFourAgo__c = convertToDecimal(dataMap.get('distributeDirFourAgo'));
            }
            if (dataMap.containsKey('distributeDirThreeAgo')) { 
                salesPerform.DistributeDirThreeAgo__c = convertToDecimal(dataMap.get('distributeDirThreeAgo'));
            }
            if (dataMap.containsKey('distributeDirTwoAgo')) { 
                salesPerform.DistributeDirTwoAgo__c = convertToDecimal(dataMap.get('distributeDirTwoAgo'));
            }
            if (dataMap.containsKey('distributeDirOneAgo')) { 
                salesPerform.DistributeDirOneAgo__c = convertToDecimal(dataMap.get('distributeDirOneAgo'));
            }
            // 간접 물류비 
            if (dataMap.containsKey('beforedistributeInDir')) { 
                salesPerform.BeforeDistributeInDir__c = convertToDecimal(dataMap.get('beforedistributeInDir'));
            }
            if (dataMap.containsKey('distributeInDirElevenAgo')) { 
                salesPerform.DistributeInDirElevenAgo__c = convertToDecimal(dataMap.get('distributeInDirElevenAgo'));
            }
            if (dataMap.containsKey('distributeInDirTenAgo')) { 
                salesPerform.DistributeInDirTenAgo__c = convertToDecimal(dataMap.get('distributeInDirTenAgo'));
            }
            if (dataMap.containsKey('distributeInDirNineAgo')) { 
                salesPerform.DistributeInDirNineAgo__c = convertToDecimal(dataMap.get('distributeInDirNineAgo'));
            }
            if (dataMap.containsKey('distributeInDirEightAgo')) { 
                salesPerform.DistributeInDirEightAgo__c = convertToDecimal(dataMap.get('distributeInDirEightAgo'));
            }
            if (dataMap.containsKey('distributeInDirSevenAgo')) { 
                salesPerform.DistributeInDirSevenAgo__c = convertToDecimal(dataMap.get('distributeInDirSevenAgo'));
            }
            if (dataMap.containsKey('distributeInDirSixAgo')) { 
                salesPerform.DistributeInDirSixAgo__c = convertToDecimal(dataMap.get('distributeInDirSixAgo'));
            }
            if (dataMap.containsKey('distributeInDirFiveAgo')) { 
                salesPerform.DistributeInDirFiveAgo__c = convertToDecimal(dataMap.get('distributeInDirFiveAgo'));
            }
            if (dataMap.containsKey('distributeInDirFourAgo')) { 
                salesPerform.DistributeInDirFourAgo__c = convertToDecimal(dataMap.get('distributeInDirFourAgo'));
            }
            if (dataMap.containsKey('distributeInDirThreeAgo')) { 
                salesPerform.DistributeInDirThreeAgo__c = convertToDecimal(dataMap.get('distributeInDirThreeAgo'));
            }
            if (dataMap.containsKey('distributeInDirTwoAgo')) { 
                salesPerform.DistributeInDirTwoAgo__c = convertToDecimal(dataMap.get('distributeInDirTwoAgo'));
            }
            if (dataMap.containsKey('distributeInDirOneAgo')) { 
                salesPerform.DistributeInDirOneAgo__c = convertToDecimal(dataMap.get('distributeInDirOneAgo'));
            }
            // 공헌이익 
            if (dataMap.containsKey('beforeContribute')) { 
                salesPerform.BeforeContribute__c = convertToDecimal(dataMap.get('beforeContribute'));
            }
            if (dataMap.containsKey('contributeElevenAgo')) { 
                salesPerform.ContributeElevenAgo__c = convertToDecimal(dataMap.get('contributeElevenAgo'));
            }
            if (dataMap.containsKey('contributeTenAgo')) { 
                salesPerform.ContributeTenAgo__c = convertToDecimal(dataMap.get('contributeTenAgo'));
            }
            if (dataMap.containsKey('contributeNineAgo')) { 
                salesPerform.ContributeNineAgo__c = convertToDecimal(dataMap.get('contributeNineAgo'));
            }
            if (dataMap.containsKey('contributeEightAgo')) { 
                salesPerform.ContributeEightAgo__c = convertToDecimal(dataMap.get('contributeEightAgo'));
            }
            if (dataMap.containsKey('contributeSevenAgo')) { 
                salesPerform.ContributeSevenAgo__c = convertToDecimal(dataMap.get('contributeSevenAgo'));
            }
            if (dataMap.containsKey('contributeSixAgo')) { 
                salesPerform.ContributeSixAgo__c = convertToDecimal(dataMap.get('contributeSixAgo'));
            }
            if (dataMap.containsKey('contributeFiveAgo')) { 
                salesPerform.ContributeFiveAgo__c = convertToDecimal(dataMap.get('contributeFiveAgo'));
            }
            if (dataMap.containsKey('contributeFourAgo')) { 
                salesPerform.ContributeFourAgo__c = convertToDecimal(dataMap.get('contributeFourAgo'));
            }
            if (dataMap.containsKey('contributeThreeAgo')) { 
                salesPerform.ContributeThreeAgo__c = convertToDecimal(dataMap.get('contributeThreeAgo'));
            }
            if (dataMap.containsKey('contributeTwoAgo')) { 
                salesPerform.ContributeTwoAgo__c = convertToDecimal(dataMap.get('contributeTwoAgo'));
            }
            if (dataMap.containsKey('contributeOneAgo')) { 
                salesPerform.ContributeOneAgo__c = convertToDecimal(dataMap.get('contributeOneAgo'));
            }

            upsert salesPerform;


        }catch (Exception e) {
            System.debug('실적현황 upsert 에러 메시지: ' + e.getMessage());
            System.debug('실적현황 upsert 에러 메시지: ' + e.getStackTraceString());
        }
    }


    /* 
    품의지정 버튼 클릭시 , 품의지정 check 
    : 기존 품의지정된 내역은 삭제 후 신규 품의지정된 1개만 품의체크
    */

    @RemoteAction
    public static String ReportCheck(String incomeExpensesId, String opportunityId) {
        try {
            List<CJFW_ExpectedIncomeExpenses__c> expenseList = [SELECT Id, IsReportCheck__c FROM CJFW_ExpectedIncomeExpenses__c WHERE Opportunity__c = :opportunityId AND Id != :incomeExpensesId];
   
            for (CJFW_ExpectedIncomeExpenses__c expense : expenseList) {
                expense.IsReportCheck__c = false;
            }
            update expenseList;
   
            CJFW_ExpectedIncomeExpenses__c currentExpense = [SELECT Id, IsReportCheck__c FROM CJFW_ExpectedIncomeExpenses__c WHERE Id = :incomeExpensesId];
            if (currentExpense != null) {
                currentExpense.IsReportCheck__c = !currentExpense.IsReportCheck__c;
                update currentExpense;
 
                return String.valueOf(currentExpense.IsReportCheck__c);
            }
   
            return 'false';
   
        } catch (Exception e) {
            System.debug('에러 메시지: ' + e.getMessage());
            System.debug('에러 라인: ' + e.getStackTraceString());
            return 'error';
        }
    }

    /* 
    Decimal 값으로 변환하기위해 사용되는 메소드
    */
    public static Decimal convertToDecimal(Object objValue) {  
        Decimal decimalValue = 0.00; // 기본값 설정
        
        // 입력값이 3자리이상일 경우 1,234 숫자사이에 있는 반점 제거 
        String changeStr = (String)objValue;
        objValue = changeStr.replace(',', '');
        

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