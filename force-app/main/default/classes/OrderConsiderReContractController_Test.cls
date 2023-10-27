/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-26-2023
 * @last modified by  : yeonji.lim@dkbmc.com
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
        objOppty = COMM_ReportTestDataFactory.createOpportunity('0120w0000022cWgAAI', '테스트', objAcc.Id, date.valueOf('2022-01-01'));
        insert objOppty;

        // 신규개설품의
        CJFW_ExpectedIncomeExpenses__c objExIncome = new CJFW_ExpectedIncomeExpenses__c();
        objExIncome = COMM_ReportTestDataFactory.createExpectedIncome(objOppty.Id);
        insert objExIncome;
    }
    
    @isTest
    public static void test(){
        
        Test.startTest();
        
        String opptyId = [SELECT Id FROM Opportunity Limit 1].Id; // 영업기회 Id
        String exIncomeId = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c Limit 1].Id; // 신규개설품의 Id값 
        String dataList = '{"keyMan":"12","competitor":"12","competitorSuggestions":"12","obtainOrder":"","mainMA":"임연지님","accountName":"000가망고객","ownerName":"최은영","brandLaunching":"qwer","brandManage":"123456","brandChannel":"FC","brandBusinessCondition":"3","outwardEntire":"4","outwardCompanySize":"4","outwardDifference":"4","initialDate":"2023-10-31","accountAddress":"서울특별시 성동구 상원12길 34 (성수동1가)","existGoods":"","contractStartDate":"2023-10-26","contractEndDate":"2023-10-30","collateralType":"예적금","collateralAmount":"111.00","collateralPeriod":"2023-12-31","creditLoanAmount":"22.00","salesFeeGeneral":"33.33","salesFeeExclusive":"44.44","salesFeeCountryside":"55.55","salesFeeGeneralTOBE":"66.66","salesFeeExclusiveTOBE":"77.77","salesFeeCountrysideTOBE":"88.88","loanManage":"개별 여신관리","paymentMethod":"예적금","contractPaymentDate":"2023-10-26","contractType":"표준","sales":"30.00","exclusiveSaveSkuSales":"10.00","dropSize":"20.00","averageSales":"3.00","deliveryNumber":"2","contributionMargin":"2.50","kgExclusiveProduct":"500","kgGeneralProduct":"500","kgTotalAmount":"500","skuReleaseBox":"1","skuReleaseEa":"2","salesMoreThousand":"1.10","salesMoreFiveHundred":"1.10","salesLessFiveHundred":"1.10","salesLessThreeHundred":"1.10","storeMoreThousand":"1.00","storeMoreFiveHundred":"2.00","storeLessFiveHundred":"3.00","storeLessThreeHundred":"4.00","frozenMonth":"1","frozenTwoMonth":"4","frozenThreeMonth":"7","frozenFourMonth":"1","refrigerationMonth":"2","refrigerationTwoMonth":"5","refrigerationThreeMonth":"8","refrigerationFourMonth":"2","temperatureMonth":"3","temperatureTwoMonth":"6","temperatureThreeMonth":"9","temperatureFourMonth":"3","skuReleaseSum":"3","revenueSum":"4.40","storeSum":"10","positionOne":"10.00","positionTwo":"20.00","positionThree":"30.00","positionFour":"40.00","positionSum":"100.00","revenuePerBranch":"0.44","stockMonthSum":"6","stockTwoMonthSum":"15","stockThreeMonthSum":"24","stockFourMonthSum":"6","frozenSum":"13","refrigerationSum":"17","temperatureSum":"21","stockSum":"51"}';
        
        // 객체생성
        OrderConsiderReContractFormController controller = new OrderConsiderReContractFormController();
        // controller class 필드값 초기화
        controller.opportunityId = opptyId;
       	controller.incomeExpensesId = exIncomeId;
        
        // Picklist 값을 가져오는 메소드
        controller.getPicklistValues();
        // Oppty 에 있는 Owner 정보 가져오는 메소드
        controller.getOpptyInfo();
        // Oppty 에 있는 Account 값을 가져오는 메소드
        controller.getAccountInfo();
        // 신규개설품의(CJFW_ExpectedIncomeExpenses__c) 에서 값 가져오기
        controller.getIncomeExpenses();


        /* =========== static 메소드는 직접 호출 ============== */

        // CJFW_NewOpenReport_ProfitReview (VF Page) 에서 입력받은 값 update 
        OrderConsiderReContractFormController.saveIncomeExpenses(dataList, opptyId, 1, exIncomeId, 'CRM010');
        // 품의지정 버튼 클릭시 , 품의지정 check 
        OrderConsiderReContractFormController.ReportCheck(exIncomeId, opptyId);
        // Decimal 값으로 변환하기위해 사용되는 메소드
        OrderConsiderReContractFormController.convertToDecimal('1.23');
        
        Test.stopTest();
    }

}