/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-17-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
@isTest
public with sharing class OrderConsiderReContractController_Test {

    private String opId {get; set;}

    
    @TestSetup
    static void makeData(){
        // 계정 
        Account objAcc = new Account();
        objAcc = COMM_ReportTestDataFactory.createAccount('test', 'ExistingCustomer');
        insert objAcc;

        // 기회
        Opportunity objOppty = new Opportunity();
        // 아래와 같이 id 값 직접입력하면 안됨 
        //objOppty = COMM_ReportTestDataFactory.createOpportunity('0120w0000022cWgAAI', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        objOppty = COMM_ReportTestDataFactory.createOpportunity('General', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        insert objOppty;
        
        // 신규개설품의 (master)
        CJFW_ExpectedIncomeExpenses__c objExIncome = new CJFW_ExpectedIncomeExpenses__c();
        objExIncome = COMM_ReportTestDataFactory.createExpectedIncome(objOppty.Id);
        insert objExIncome;
        
        // 실적현황 (detail)  objExIncome.id
        CJFW_SalesPerformance__c objSales = new CJFW_SalesPerformance__c();
        objSales.ExpectedIncomeExpensesId__c =  objExIncome.id;
        insert objSales;

        //추진사항 (detail)  objExIncome.id
        CJFW_PromoteIssues__c objPromote = new CJFW_PromoteIssues__c();
        objPromote.ExpectedIncomeExpensesId__c = objExIncome.id;
        insert objPromote;

    }
    
    @isTest
    public static void test(){
        
        Test.startTest();
        
        String opptyId = [SELECT Id FROM Opportunity Limit 1].Id; // 영업기회 Id
        String exIncomeId = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c Limit 1].Id; // 신규개설품의 Id값 
        String reportType ='CRM008';

        //String dataList = '{"keyMan":"12","competitor":"12","competitorSuggestions":"12","obtainOrder":"","mainMA":"임연지님","accountName":"000가망고객","ownerName":"최은영","brandLaunching":"qwer","brandManage":"123456","brandChannel":"FC","brandBusinessCondition":"3","outwardEntire":"4","outwardCompanySize":"4","outwardDifference":"4","initialDate":"2023-10-31","accountAddress":"서울특별시 성동구 상원12길 34 (성수동1가)","existGoods":"","contractStartDate":"2023-10-26","contractEndDate":"2023-10-30","collateralType":"예적금","collateralAmount":"111.00","collateralPeriod":"2023-12-31","creditLoanAmount":"22.00","salesFeeGeneral":"33.33","salesFeeExclusive":"44.44","salesFeeCountryside":"55.55","salesFeeGeneralTOBE":"66.66","salesFeeExclusiveTOBE":"77.77","salesFeeCountrysideTOBE":"88.88","loanManage":"개별 여신관리","paymentMethod":"예적금","contractPaymentDate":"2023-10-26","contractType":"표준","sales":"30.00","exclusiveSaveSkuSales":"10.00","dropSize":"20.00","averageSales":"3.00","deliveryNumber":"2","contributionMargin":"2.50","kgExclusiveProduct":"500","kgGeneralProduct":"500","kgTotalAmount":"500","skuReleaseBox":"1","skuReleaseEa":"2","salesMoreThousand":"1.10","salesMoreFiveHundred":"1.10","salesLessFiveHundred":"1.10","salesLessThreeHundred":"1.10","storeMoreThousand":"1.00","storeMoreFiveHundred":"2.00","storeLessFiveHundred":"3.00","storeLessThreeHundred":"4.00","frozenMonth":"1","frozenTwoMonth":"4","frozenThreeMonth":"7","frozenFourMonth":"1","refrigerationMonth":"2","refrigerationTwoMonth":"5","refrigerationThreeMonth":"8","refrigerationFourMonth":"2","temperatureMonth":"3","temperatureTwoMonth":"6","temperatureThreeMonth":"9","temperatureFourMonth":"3","skuReleaseSum":"3","revenueSum":"4.40","storeSum":"10","positionOne":"10.00","positionTwo":"20.00","positionThree":"30.00","positionFour":"40.00","positionSum":"100.00","revenuePerBranch":"0.44","stockMonthSum":"6","stockTwoMonthSum":"15","stockThreeMonthSum":"24","stockFourMonthSum":"6","frozenSum":"13","refrigerationSum":"17","temperatureSum":"21","stockSum":"51"}';
        String dataList = ' {"keyMan": "12",' 
           + ' "competitor": "12", '
           + ' "competitorSuggestions": "12",  '
           + ' "obtainOrder": "", '
           + ' "mainMA": "임연지님", '
           + ' "accountName": "000가망고객", '
           + ' "ownerName": "최은영", '
           + ' "brandLaunching": "qwer", '
           + ' "brandManage": "123456", '
           + ' "brandChannel": "FC", '
           + ' "brandBusinessCondition": "3", '
           + ' "outwardEntire": "4", '
           + ' "outwardCompanySize": "4", '
           + ' "outwardDifference": "4", '
           + ' "initialDate": "2023-10-31", '
           + ' "accountAddress": "서울특별시 성동구 상원12길 34 (성수동1가)", '
           + ' "existGoods": "", '
           + ' "contractStartDate": "2023-10-26", '
           + ' "contractEndDate": "2023-10-30", '
           + ' "collateralType": "예적금", '
           + ' "collateralAmount": "111.00", '
           + ' "collateralPeriod": "2023-12-31", '
           + ' "creditLoanAmount": "22.00", '
           + ' "salesFeeGeneral": "33.33", '
           + ' "salesFeeExclusive": "44.44", '
           + ' "salesFeeCountryside": "55.55", '
           + ' "salesFeeGeneralTOBE": "66.66", '
           + ' "salesFeeExclusiveTOBE": "77.77", '
           + ' "salesFeeCountrysideTOBE": "88.88", '
           + ' "loanManage": "개별 여신관리", '
           + ' "paymentMethod": "예적금", '
           + ' "contractPaymentDate": "2023-10-26", '
           + ' "contractType": "표준", '
           + ' "sales": "30.00", '
           + ' "exclusiveSaveSkuSales": "10.00", '
           + ' "dropSize": "20.00", '
           + ' "averageSales": "3.00", '
           + ' "deliveryNumber": "2", '
           + ' "contributionMargin": "2.50", '
           + ' "kgExclusiveProduct": "500", '
           + ' "kgGeneralProduct": "500", '
           + ' "kgTotalAmount": "500", '
           + ' "skuReleaseBox": "1", '
           + ' "skuReleaseEa": "2", '
           + ' "salesMoreThousand": "1.10", '
           + ' "salesMoreFiveHundred": "1.10", '
           + ' "salesLessFiveHundred": "1.10", '
           + ' "salesLessThreeHundred": "1.10", '
           + ' "storeMoreThousand": "1.00", '
           + ' "storeMoreFiveHundred": "2.00", '
           + ' "storeLessFiveHundred": "3.00", '
           + ' "storeLessThreeHundred": "4.00", '
           + ' "frozenMonth": "1", '
           + ' "frozenTwoMonth": "4", '
           + ' "frozenThreeMonth": "7", '
           + ' "frozenFourMonth": "1", '
           + ' "refrigerationMonth": "2", '
           + ' "refrigerationTwoMonth": "5", '
           + ' "refrigerationThreeMonth": "8", '
           + ' "refrigerationFourMonth": "2", '
           + ' "temperatureMonth": "3", '
           + ' "temperatureTwoMonth": "6", '
           + ' "temperatureThreeMonth": "9", '
           + ' "temperatureFourMonth": "3", '
           + ' "skuReleaseSum": "3", '
           + ' "revenueSum": "4.40", '
           + ' "storeSum": "10", '
           + ' "positionOne": "10.00", '
           + ' "positionTwo": "20.00", '
           + ' "positionThree": "30.00", '
           + ' "positionFour": "40.00", '
           + ' "positionSum": "100.00", '
           + ' "revenuePerBranch": "0.44", '
           + ' "stockMonthSum": "6", '
           + ' "stockTwoMonthSum": "15", '
           + ' "stockThreeMonthSum": "24", '
           + ' "stockFourMonthSum": "6", '
           + ' "frozenSum": "13", '
           + ' "refrigerationSum": "17", '
           + ' "temperatureSum": "21", '

           // ▼ 추가 231113
           + ' "selectedDelivery": "13", ' 
           + ' "salesNameOne": "국물류", '
           + ' "salesThreeOne": "10.00", '
           + ' "salesCapOne": "20.00", '
           + ' "salesEastOne": "30.00", '
           + ' "salesWestOne": "40.00", '
           + ' "salesJejuOne": "50.00", '
           + ' "salesMonthFoOne": "60.00", '
           + ' "salesImpMonthOne": "70.00", '
           + ' "salesNameTwo": "라면", '
           + ' "salesThreeTwo": "10.00", '
           + ' "salesCapTwo": "20.00", '
           + ' "salesEastTwo": "30.00", '
           + ' "salesWestTwo": "40.00", '
           + ' "salesJejuTwo": "50.00", '
           + ' "salesMonthFoTwo": "60.00", '
           + ' "salesImpMonthTwo": "70.00", '
           + ' "salesNameThree": "과자", '
           + ' "salesThreeThree": "10.00", '
           + ' "salesCapThree": "20.00", '
           + ' "salesEastThree": "30.00", '
           + ' "salesWestThree": "40.00", '
           + ' "salesJejuThree": "50.00", '
           + ' "salesMonthFoThree": "60.00", '
           + ' "salesImpMonthThree": "70.00", '
           + ' "salesNameFour": "텀블러", '
           + ' "salesThreeFour": "10.00", '
           + ' "salesCapFour": "20.00", '
           + ' "salesEastFour": "30.00", '
           + ' "salesWestFour": "40.00", '
           + ' "salesJejuFour": "50.00", '
           + ' "salesMonthFoFour": "60.00", '
           + ' "salesImpMonthFour": "70.00", '
           + ' "salesThreeEx": "10.00", '
           + ' "salesCapEx": "10.00", '
           + ' "salesEastEx": "20.00", '
           + ' "salesWestEx": "30.00", '
           + ' "salesJejuEx": "40.00", '
           + ' "salesFoEx": "50.00", '
           + ' "salesImpMonthEx": "60.00", '
           + ' "salesThreeGen": "50.00", '
           + ' "salesCapGen": "30.00", '
           + ' "salesEastGen": "40.00", '
           + ' "salesWestGen": "60.00", '
           + ' "salesJejuGen": "70.00", '
           + ' "salesFoGen": "80.00", '
           + ' "salesImpMonthGen": "90.00", '
           + ' "salesProfitNameOne": "사탕", '
           + ' "salesProfitThreeOne": "10.00", '
           + ' "salesProfitCapOne": "20.00", '
           + ' "salesProfitEastOne": "30.00", '
           + ' "salesProfitWestOne": "60.00", '
           + ' "salesProfitJejuOne": "50.00", '
           + ' "salesProfitFoOne": "40.00", '
           + ' "salesProfitImpMonthOne": "30.00", '
           + ' "salesProfitNameTwo": "치킨", '
           + ' "salesProfitThreeTwo": "30.00", '
           + ' "salesProfitCapTwo": "20.00", '
           + ' "salesProfitEastTwo": "30.00", '
           + ' "salesProfitWestTwo": "60.00", '
           + ' "salesProfitJejuTwo": "50.00", '
           + ' "salesProfitFoTwo": "40.00", '
           + ' "salesProfitImpMonthTwo": "20.00", '
           + ' "salesProfitNameThree": "피자", '
           + ' "salesProfitThreeThree": "30.00", '
           + ' "salesProfitCapThree": "10.00", '
           + ' "salesProfitEastThree": "20.00", '
           + ' "salesProfitWestThree": "30.00", '
           + ' "salesProfitJejuThree": "60.00", '
           + ' "salesProfitFoThree": "50.00", '
           + ' "salesProfitImpMonthThree": "40.00", '
           + ' "salesProfitNameFour": "파스타", '
           + ' "salesProfitThreeFour": "30.00", '
           + ' "salesProfitCapFour": "10.00", '
           + ' "salesProfitEastFour": "20.00", '
           + ' "salesProfitWestFour": "30.00", '
           + ' "salesProfitJejuFour": "60.00", '
           + ' "salesProfitFoFour": "50.00", '
           + ' "salesProfitImpMonthFour": "40.00", '
           + ' "salesProfitThreeEx": "20.00", '
           + ' "salesProfitCapEx": "30.00", '
           + ' "salesProfitEastEx": "60.00", '
           + ' "salesProfitWestEx": "50.00", '
           + ' "salesProfitJejuEx": "40.00", '
           + ' "salesProfitFoEx": "40.00", '
           + ' "salesProfitImpMonthEx": "40.00", '
           + ' "salesProfitThreeGen": "50.00", '
           + ' "salesProfitCapGen": "60.00", '
           + ' "salesProfitEastGen": "50.00", '
           + ' "salesProfitWestGen": "30.00", '
           + ' "salesProfitJejuGen": "20.00", '
           + ' "salesProfitFoGen": "50.00", '
           + ' "salesProfitImpMonthGen": "30.00", '
           + ' "profitRateEx": "20.00", '
           + ' "profitRateNameOne": "귤", '
           + ' "profitRateNameTwo": "오렌지", '
           + ' "profitRateNameThree": "주스", '
           + ' "profitRateNameFour": "콜라", '
           + ' "distributeDirThree": "30.00", '
           + ' "distributeDirCap": "10.00", '
           + ' "distributeDirEast": "20.00", '
           + ' "distributeDirWest": "30.00", '
           + ' "distributeDirJeju": "60.00", '
           + ' "distributeDirFo": "50.00", '
           + ' "distributeDirImpMonth": "80.00", '
           + ' "distributeInDirThree": "30.00", '
           + ' "distributeInDirCap": "10.00", '
           + ' "distributeInDirEast": "20.00", '
           + ' "distributeInDirWest": "30.00", '
           + ' "distributeInDirJeju": "60.00", '
           + ' "distributeInDirFo": "50.00", '
           + ' "distributeInDirImpMonth": "80.00", '
           + ' "beforeSales": "80.00", '
           + ' "salesElevenAgo": "70.00", '
           + ' "salesTenAgo": "60.00", '
           + ' "salesNineAgo": "50.00", '
           + ' "salesEightAgo": "40.00", '
           + ' "salesSevenAgo": "30.00", '
           + ' "salesSixAgo": "20.00", '
           + ' "salesFiveAgo": "10.00", '
           + ' "salesFourAgo": "20.00", '
           + ' "salesThreeAgo": "60.00", '
           + ' "salesTwoAgo": "70.00", '
           + ' "salesOneAgo": "50.00", '
           + ' "beforesalesProfit": "50.00", '
           + ' "salesProfitElevenAgo": "100.00", '
           + ' "salesProfitTenAgo": "60.00", '
           + ' "salesProfitNineAgo": "50.00", '
           + ' "salesProfitEightAgo": "20.00", '
           + ' "salesProfitSevenAgo": "30.00", '
           + ' "salesProfitSixAgo": "70.00", '
           + ' "salesProfitFiveAgo": "50.00", '
           + ' "salesProfitFourAgo": "50.00", '
           + ' "salesProfitThreeAgo": "100.00", '
           + ' "salesProfitTwoAgo": "60.00", '
           + ' "salesProfitOneAgo": "50.00", '
           + ' "beforeSalesStore": "20.00", '
           + ' "salesStoreElevenAgo": "30.00", '
           + ' "salesStoreTenAgo": "30.00", '
           + ' "salesStoreNineAgo": "70.00", '
           + ' "salesStoreEightAgo": "50.00", '
           + ' "salesStoreSevenAgo": "50.00", '
           + ' "salesStoreSixAgo": "100.00", '
           + ' "salesStoreFiveAgo": "60.00", '
           + ' "salesStoreFourAgo": "50.00", '
           + ' "salesStoreThreeAgo": "20.00", '
           + ' "salesStoreTwoAgo": "30.00", '
           + ' "salesStoreOneAgo": "10.00", '
           + ' "beforeDistribute": "30.00", '
           + ' "distributeElevenAgo": "70.00", '
           + ' "distributeTenAgo": "50.00", '
           + ' "distributeNineAgo": "50.00", '
           + ' "distributeEightAgo": "100.00", '
           + ' "distributeSevenAgo": "60.00", '
           + ' "distributeSixAgo": "50.00", '
           + ' "distributeFiveAgo": "20.00", '
           + ' "distributeFourAgo": "30.00", '
           + ' "distributeThreeAgo": "80.00", '
           + ' "distributeTwoAgo": "80.00", '
           + ' "distributeOneAgo": "60.00", '
           + ' "beforedistributeDir": "70.00", '
           + ' "distributeDirElevenAgo": "50.00", '
           + ' "distributeDirTenAgo": "50.00", '
           + ' "distributeDirNineAgo": "100.00", '
           + ' "distributeDirEightAgo": "60.00", '
           + ' "distributeDirSevenAgo": "50.00", '
           + ' "distributeDirSixAgo": "20.00", '
           + ' "distributeDirFiveAgo": "30.00", '
           + ' "distributeDirFourAgo": "80.00", '
           + ' "distributeDirThreeAgo": "80.00", '
           + ' "distributeDirTwoAgo": "60.00", '
           + ' "distributeDirOneAgo": "60.00", '
           + ' "beforedistributeInDir": "70.00", '
           + ' "distributeInDirElevenAgo": "50.00", '
           + ' "distributeInDirTenAgo": "50.00", '
           + ' "distributeInDirNineAgo": "100.00", '
           + ' "distributeInDirEightAgo": "60.00", '
           + ' "distributeInDirSevenAgo": "50.00", '
           + ' "distributeInDirSixAgo": "20.00", '
           + ' "distributeInDirFiveAgo": "30.00", '
           + ' "distributeInDirFourAgo": "80.00", '
           + ' "distributeInDirThreeAgo": "80.00", '
           + ' "distributeInDirTwoAgo": "60.00", '
           + ' "distributeInDirOneAgo": "60.00", '
           + ' "beforeContribute": "50.00", '
           + ' "contributeElevenAgo": "50.00", '
           + ' "contributeTenAgo": "100.00", '
           + ' "contributeNineAgo": "60.00", '
           + ' "contributeEightAgo": "50.00", '
           + ' "contributeSevenAgo": "20.00", '
           + ' "contributeSixAgo": "30.00", '
           + ' "contributeFiveAgo": "80.00", '
           + ' "contributeFourAgo": "80.00", '
           + ' "contributeThreeAgo": "60.00", '
           + ' "contributeTwoAgo": "60.00", '
           + ' "contributeOneAgo": "60.00", '
           + ' "synergyDivisionOne": "비타민", '
           + ' "synergyTypeOne": "립밤", '
           + ' "synergySaleOne": "60.00", '
           + ' "synergySaleRateOne": "50.00", '
           + ' "synergyRemarkOne": "가방", '
           + ' "synergyDivisionTwo": "의자", '
           + ' "synergyTypeTwo": "책상", '
           + ' "synergySaleTwo": "80.00", '
           + ' "synergySaleRateTwo": "60.00", '
           + ' "synergyRemarkTwo": "비타민", '
           + ' "synergyDivisionThree": "비타민", '
           + ' "synergyTypeThree": "비타민", '
           + ' "synergySaleThree": "80.00", '
           + ' "synergySaleRateThree": "60.00", '
           + ' "synergyRemarkTwo": "비타민", '
           

           // ▲ 추가 231113

           + ' "stockSum": "51" } ';
        
        





        // 객체생성
        OrderConsiderReContractFormController controller = new OrderConsiderReContractFormController();
        // controller class 필드값 초기화
        controller.opportunityId = opptyId;
       	controller.incomeExpensesId = exIncomeId;
        
        // Picklist 값을 가져오는 메소드
        controller.getPicklistValues();
        // OpportunityContactRole에 있는 key-man 정보 가져오는 메소드
        controller.getKeymanInfo();
        // Oppty 에 있는 Owner 정보 가져오는 메소드
        controller.getOpptyInfo();
        // Oppty 에 있는 Account 값을 가져오는 메소드
        controller.getAccountInfo();
        // 신규개설품의(CJFW_ExpectedIncomeExpenses__c) 에서 값 가져오기
        controller.getIncomeExpenses();
        // 품의서 관리자 작성 obj 에서 값 가져오기
        controller.getExpectManager();
        // 물류비 관리 (CJFW_DistributionCost__c)에서 값 가져오기
        controller.getDistributeCost();
        // 에서 값 가져오기
        controller.getSalesPerform(exIncomeId);
        controller.getPromoteIssue(exIncomeId);


        /* =========== static 메소드는 직접 호출 ============== */

        // CJFW_NewOpenReport_ProfitReview (VF Page) 에서 입력받은 값 update 
        OrderConsiderReContractFormController.saveIncomeExpenses(dataList, opptyId, 1, exIncomeId, 'CRM010');
        // 품의지정 버튼 클릭시 , 품의지정 check 
        OrderConsiderReContractFormController.ReportCheck(exIncomeId, opptyId, reportType);
        // Decimal 값으로 변환하기위해 사용되는 메소드
        OrderConsiderReContractFormController.convertToDecimal('1.23');
        
        Test.stopTest();
    }

    @isTest
    public static void test2(){
        Test.startTest();

        String opptyId = [SELECT Id FROM Opportunity Limit 1].Id; // 영업기회 Id

        // 객체생성
        OrderConsiderReContractFormController controller = new OrderConsiderReContractFormController();
        // controller class 필드값 초기화
        controller.opportunityId = opptyId;
        String exIncomeId = null; 
        controller.getSalesPerform(exIncomeId);
        controller.getPromoteIssue(exIncomeId);

        Test.stopTest();
    }

}