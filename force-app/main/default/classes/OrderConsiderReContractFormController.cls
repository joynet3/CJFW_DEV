/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-27-2023
 * @last modified by  : yeonji.lim@dkbmc.com
**/
public with sharing class OrderConsiderReContractFormController {
    public static String SaveDataList;

    public String opportunityId { get; set; }
    public String incomeExpensesId { get; set;} // 신규개설품의 id
    public Decimal versionCheck { get; set; }
    public Boolean reportCheck { get; set; }
    public String showtable { get; set; }
    public String reportType { get; set; } // 품의서 유형

    /* 가져온 데이터 담는 object */
    public Opportunity opptyInfo {get;set;}
    public Account accountInfo {get;set;}
    public CJFW_ExpectedIncomeExpenses__c IncomeExpensesInfo {get;set;}

    /* picklist 저장된 값 가져오기 위한 선언 */
    public String selectedBrandChannel { get; set; } // 브랜드 경로
    public String selectedCollateral { get; set; } // 담보제공종류
    public String selectedLoanManage { get; set; }   // 여신관리
    public String selectedPayment { get; set; }    // 결제수단종류 
    public String selectedContract { get; set; }   // 계약서 종류

    /* picklist */
    public List<SelectOption> brandChannelPickList { get; set; } // 브랜드 경로
    public List<SelectOption> collateralPickList { get; set; } // 담보제공종류
    public List<SelectOption> loanManagePickList { get; set; } // 여신관리
    public List<SelectOption> paymentPickList { get; set; }    // 결제수단종류 
    public List<SelectOption> contractPickList { get; set; }    // 계약서종류


    /* 날짜형식변환 */
    public String initialDate { get; set; } // 초도일자
    public String contractStartDate { get; set; } // 계약시작
    public String contractEndDate { get; set; } // 계약종료
    public String collateralPeriod { get; set; } // 담보 제공 기간
    public String contractPaymentDate { get; set; } // 약정결제일

    
    /* 생성자 */
    public OrderConsiderReContractFormController() {
        // this.opportunityId = '0060w00000D8yoKAAR';      //테스트를 위한 아이디값
        // this.incomeExpensesId = 'a1lH2000001NWe6IAG';   //테스트를 위한 아이디값
        this.opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
        this.incomeExpensesId = ApexPages.currentPage().getParameters().get('incomeExpensesId');
        this.showtable = ApexPages.currentPage().getParameters().get('showtable');
        this.reportType = ApexPages.currentPage().getParameters().get('type');

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
        
        List<Schema.PicklistEntry> brandChannelValues = brandChannelResult.getPicklistValues();
        List<Schema.PicklistEntry> collateralValues = collateralResult.getPicklistValues();
        List<Schema.PicklistEntry> loanManageValues = loanManageResult.getPicklistValues();
        List<Schema.PicklistEntry> paymentValues = paymentPick.getPicklistValues();
        List<Schema.PicklistEntry> contractValues = contractTypePick.getPicklistValues();
        
        brandChannelPickList = new List<SelectOption>();
        collateralPickList = new List<SelectOption>();
        loanManagePickList = new List<SelectOption>();
        paymentPickList = new List<SelectOption>();
        contractPickList = new List<SelectOption>();
 
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

        // System.debug(' 브랜드 경로 pickList 값 ' + brandChannelPickList);
        // System.debug(' 담보제공종류 pickList 값 ' + collateralPickList);
        // System.debug(' 여신관리 pickList 값 ' + loanManagePickList);
        // System.debug(' 결제수단종류 pickList 값 ' + paymentPickList);
        // System.debug(' 계약서종류 pickList 값 ' + contractPickList);
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
    신규개설품의(CJFW_ExpectedIncomeExpenses__c) 에서 값 가져오기
    VF Page 초기호출시  
    */
    public void getIncomeExpenses() {
        System.debug('# ReportFormController # getIncomeExpenses  ==================================');
        
        try {
            String query = 'SELECT Id, ' +
            'Version__c, ' +                        
            'IsReportCheck__c, ' +                        
            'KeyMan__c, ' +                         //키맨    
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
            'OutwardEntire__c, ' +                  //외형 전체
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

            'Sales__c, ' +                           //수주가이드 매출
            'ExclusiveSaveSkuSales__c, ' +           //전용저장 sku매출
            'DropSize__c, ' +                        //회당 Drop Size
            'AverageSales__c, ' +                    //점당 평균매출
            'DeliveryNumber__c, ' +                  //배송 횟수
            'ContributionMargin__c, ' +              //공헌이익%
            'KgExclusiveProduct__c, ' +              //전용상품
            'KgGeneralProduct__c, ' +                //일반상품
            'KgTotalAmount__c, ' +                   //KG단가 계
            'SkuReleaseEa__c,' +                    //출고단위 EA
            'SkuReleaseBox__c, ' +                  //출고단위 BOX

            'SalesMoreThousand__c, ' +              //매출액 1천이상
            'SalesMoreFiveHundred__c, ' +           //매출액 5백이상
            'SalesLessFiveHundred__c, ' +           //매출액 5백미만
            'SalesLessThreeHundred__c, ' +          //매출액 3백미만
            'StoreMoreThousand__c, ' +              //점포수 1천이상
            'StoreMoreFiveHundred__c, ' +           //점포수 5백이상
            'StoreLessFiveHundred__c, ' +           //점포수 5백미만
            'StoreLessThreeHundred__c, ' +           //점포수 3백미만

            'FrozenMonth__c, ' +                    //냉동(30일)
            'FrozenTwoMonth__c, ' +                 //냉동(60일)
            'FrozenThreeMonth__c, ' +               //냉동(90일)
            'FrozenFourMonth__c, ' +                //냉동(120일)
            'RefrigerationMonth__c, ' +             //냉장(30일)
            'RefrigerationTwoMonth__c, ' +          //냉장(60일)
            'RefrigerationThreeMonth__c, ' +        //냉장(90일)
            'RefrigerationFourMonth__c, ' +         //냉장(120일)
            'TemperatureMonth__c, ' +               //상온(30일)
            'TemperatureTwoMonth__c, ' +            //상온(60일)
            'TemperatureThreeMonth__c, ' +          //상온(90일)
            'TemperatureFourMonth__c ' +           //상온(120일)

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

            if (!incomeExpensesList.isEmpty()) {
                // 품의서 업데이트시 
                IncomeExpensesInfo = incomeExpensesList[0];
                versionCheck = ( incomeExpensesList[0].Version__c ) + 1 ;
                reportCheck = ( incomeExpensesList[0].IsReportCheck__c );
                if(reportCheck){
                    versionCheck = versionCheck-1;
                }
                //System.debug(' 업데이트 versionCheck ' + versionCheck );
                //System.debug(' 업데이트 품의지정여부 ' + reportCheck );
            } else {
                // 품의서 초기 생성시 
                versionCheck = 1;
                IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c();
            }

            System.debug('versionCheck -> '+ versionCheck);

        }catch (QueryException e) {
            IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c(); // 빈 레코드로 초기화
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
        }

        System.debug('IncomeExpensesInfo 쿼리결과 = '+ IncomeExpensesInfo);

        /* number 타입 갑이 없을 경우 0.00으로 초기값 세팅 */
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
            'SalesLessThreeHundred__c'           //매출액 3백미만
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
            'SkuReleaseEa__c',                    //출고단위 EA

            'FrozenMonth__c' ,                    //냉동(30일)
            'FrozenTwoMonth__c',                  //냉동(60일)
            'FrozenThreeMonth__c',                //냉동(90일)
            'FrozenFourMonth__c',                 //냉동(120일)
            'RefrigerationMonth__c',              //냉장(30일)
            'RefrigerationTwoMonth__c',           //냉장(60일)
            'RefrigerationThreeMonth__c',         //냉장(90일)
            'RefrigerationFourMonth__c',          //냉장(120일)
            'TemperatureMonth__c',                //상온(30일)
            'TemperatureTwoMonth__c',             //상온(60일)
            'TemperatureThreeMonth__c',           //상온(90일)
            'TemperatureFourMonth__c'             //상온(120일)
        };
        for (String defaultSet : defaultValPerSet) {
            Object fieldPerValue = IncomeExpensesInfo.get(defaultSet);

            if (fieldPerValue == null) fieldPerValue = 0; 
            IncomeExpensesInfo.put(defaultSet, fieldPerValue);
        }


        /* Date 필드를 yyyy-MM-dd 형식의 문자열로 변환 */
        String initialDateString = String.valueOf(IncomeExpensesInfo.InitialDate__c); // 초도일자 
        String contractStartString = String.valueOf(IncomeExpensesInfo.ContractStartDate__c); // 계약시작일자
        String contractEndString = String.valueOf(IncomeExpensesInfo.ContractEndDate__c); // 계약종료일자 
        String collateralPeriodString = String.valueOf(IncomeExpensesInfo.CollateralPeriod__c); // 담보기간
        String contractPaymentDateString = String.valueOf(IncomeExpensesInfo.ContractPaymentDate__c);   //약정결제일

        initialDate = initialDateString != null ? initialDateString.substring(0, 10) : null;
        contractStartDate = contractStartString != null ? contractStartString.substring(0, 10) : null;
        contractEndDate = contractEndString != null ? contractEndString.substring(0, 10) : null;
        collateralPeriod = collateralPeriodString != null ? collateralPeriodString.substring(0, 10) : null;
        contractPaymentDate = contractPaymentDateString != null ? contractPaymentDateString.substring(0, 10) : null;


        /* pickList 저장된 값 가져오기 */
        selectedBrandChannel = IncomeExpensesInfo.BrandChannel__c;  // 브랜드 경로
        selectedCollateral = IncomeExpensesInfo.CollateralType__c; // 담보종류
        selectedLoanManage = IncomeExpensesInfo.LoanManage__c	;       // 여신관리
        selectedPayment = IncomeExpensesInfo.PaymentMethod__c;      // 결제수단 
        selectedContract = IncomeExpensesInfo.ContractType__c	; // 계약서종류 

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

        System.debug('# 품의서정보  ->' + IncomeExpensesInfo ); 
    }


    /* 
    CJFW_NewOpenReport_ProfitReview (VF Page) 에서 입력받은 값 update   
    */
    @RemoteAction
    public static String saveIncomeExpenses(String DataList, String opportunityId, Decimal versionCheck, String incomeExpensesId, String reportType) {
        try {
            System.debug('saveIncomeExpenses DataList ' + DataList);
            System.debug('saveIncomeExpenses opportunityId ' + opportunityId);
            System.debug('saveIncomeExpenses versionCheck ' + versionCheck);
            System.debug('saveIncomeExpenses incomeExpensesId ' + incomeExpensesId);
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
                expectIncome.OutwardEntire__c = (String) dataMap.get('outwardEntire');
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
            
            
            /* ===== 8-2. 전용SKU 재고 회전일 ===== */
            if (dataMap.containsKey('frozenMonth')) { // 냉동(30일)
                expectIncome.FrozenMonth__c = convertToDecimal(dataMap.get('frozenMonth'));
            }
            if (dataMap.containsKey('frozenTwoMonth')) { // 냉동(60일)
                expectIncome.FrozenTwoMonth__c = convertToDecimal(dataMap.get('frozenTwoMonth'));
            }
            if (dataMap.containsKey('frozenThreeMonth')) { // 냉동(90일)
                expectIncome.FrozenThreeMonth__c = convertToDecimal(dataMap.get('frozenThreeMonth'));
            }
            if (dataMap.containsKey('frozenFourMonth')) { // 냉동(120일)
                expectIncome.FrozenFourMonth__c = convertToDecimal(dataMap.get('frozenFourMonth'));
            }
            if (dataMap.containsKey('refrigerationMonth')) { // 냉장(30일)
                expectIncome.RefrigerationMonth__c = convertToDecimal(dataMap.get('refrigerationMonth'));
            }
            if (dataMap.containsKey('refrigerationTwoMonth')) { // 냉장(60일)
                expectIncome.RefrigerationTwoMonth__c = convertToDecimal(dataMap.get('refrigerationTwoMonth'));
            }
            if (dataMap.containsKey('refrigerationThreeMonth')) { // 냉장(90일)
                expectIncome.RefrigerationThreeMonth__c = convertToDecimal(dataMap.get('refrigerationThreeMonth'));
            }
            if (dataMap.containsKey('refrigerationFourMonth')) { // 냉장(120일)
                expectIncome.RefrigerationFourMonth__c = convertToDecimal(dataMap.get('refrigerationFourMonth'));
            }
            if (dataMap.containsKey('temperatureMonth')) { // 상온(30일)
                expectIncome.TemperatureMonth__c = convertToDecimal(dataMap.get('temperatureMonth'));
            }
            if (dataMap.containsKey('temperatureTwoMonth')) { // 상온(60일)
                expectIncome.TemperatureTwoMonth__c = convertToDecimal(dataMap.get('temperatureTwoMonth'));
            }
            if (dataMap.containsKey('temperatureThreeMonth')) { // 상온(90일)
                expectIncome.TemperatureThreeMonth__c = convertToDecimal(dataMap.get('temperatureThreeMonth'));
            }
            if (dataMap.containsKey('temperatureFourMonth')) { // 상온(120일)
                expectIncome.TemperatureFourMonth__c = convertToDecimal(dataMap.get('temperatureFourMonth'));
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