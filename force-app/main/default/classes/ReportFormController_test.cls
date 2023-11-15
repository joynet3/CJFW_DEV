/**
 * @description       : 급식 품의서 전용 테스트코드 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 11-15-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
@IsTest
public with sharing class ReportFormController_Test {

    @TestSetup
    static void makeData(){
        
        // 계정
        Account objAcc = new Account();
        objAcc = COMM_ReportTestDataFactory.createAccount('test', 'ExistingCustomer');
        insert objAcc;
    
        // 기회
        Opportunity objOppty = new Opportunity();
        objOppty.Name = 'Test Oppty';
        objOppty.AccountId = objAcc.Id;
        objOppty.CloseDate = date.valueOf('2023-10-01');
        objOppty.StageName = 'Negotiation';
        insert objOppty;
    
        // 신규개설품의
        CJFW_ExpectedIncomeExpenses__c objIncome = new CJFW_ExpectedIncomeExpenses__c();
        objIncome.Opportunity__c = objOppty.Id;
        objIncome.Version__c = 1;
        insert objIncome;
    
        // 예상손익관리
        CJFW_ExpectedIncomeManager__c objIncomeManager = new CJFW_ExpectedIncomeManager__c();
        objIncomeManager.StartDate__c = date.valueOf('2023-01-01');
        insert objIncomeManager;
    
        // 물류비관리
        CJFW_DistributionCost__c objCost = new CJFW_DistributionCost__c();
        objCost.StartDate__c = date.valueOf('2023-01-01');
        insert objCost;
    }
    
    
    @isTest
    public static void test() {
        
        Test.startTest();
        
        String opptyId = [SELECT Id FROM Opportunity Limit 1].Id; // 영업기회 Id
        String exIncomeId = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c Limit 1].Id; // 신규개설품의 Id값
        
        
        String dataList = ' {"collateralType": "담보",'
        + ' "creditLoanAmount": "100.00", '
        + ' "chefSupport": "60.00", '
        + ' "contractType": "계약서", '
        + ' "summary": "요약", '
        + ' "accountName": "거래처1", '
        + ' "ownerName": "김대표", '
        + ' "accountChannel": "채널", '
        + ' "outwardEntire": "6", '
        + ' "outwardCompanySize": "60.00", '
        + ' "firstDraft": "2023-01-01", '
        + ' "exclusiveDeal": "단독", '
        + ' "accountAddress": "서울시 마포구", '
        + ' "accountPhone": "010-1111-1111", '
        + ' "existGoods": "기존", '
        + ' "exceptionPrice": "20.00", '
        + ' "unitPrice": "30", '
        + ' "exception": "80", '
        + ' "existCenter": "a센터", ' 
        + ' "comment": "기타", ' 
        + ' "contractStartDate": "2023-01-01", '
        + ' "contractEndDate": "2023-12-31", '
        + ' "collateralAmount": "20.00", '
        + ' "collateralAmountAdd": "30", '
        + ' "collateral-period": "2023-12-31", '
        + ' "collateralStart": "2023-01-01", '
        + ' "collateralEnd": "2023-12-31", '
        + ' "collateralStartAdd": "2023-01-01", '
        + ' "collateralEndAdd": "2023-12-31", '
        + ' "deprecAmount": "60.00", ' 
        + ' "incentiveSupport": "60.00", ' 
        + ' "salesFeeSupport": "60.00", ' 
        + ' "donationSupport": "60.00", ' 
        + ' "otherSupport": "60.00", ' 
        + ' "payment": "기타", ' 
        + ' "contractPaymentNum": "60.00", ' 
        + ' "commentASIS": "asis", ' 
        + ' "otherSupport": "60.00", ' 
        + ' "contract-payment-period": "2023-12-31", '
        + ' "contractStartDateTOBE": "2023-01-01", '
        + ' "contractEndDateTOBE": "2023-12-31", '
        + ' "collateralAmountTOBE": "80.00", '
        + ' "collateralAmountAddTOBE": "70.00", '
        + ' "collateralStartTOBE": "2023-01-01", '
        + ' "collateralEndTOBE": "2023-12-31", '
        + ' "collateralStartAddTOBE": "2023-01-01", '
        + ' "collateralEndAddTOBE": "2023-12-31", '
        + ' "deprecAmountTOBE": "70.00", ' 
        + ' "incentiveSupportTOBE": "60.00", ' 
        + ' "salesFeeSupportTOBE": "70.00", ' 
        + ' "donationSupportTOBE": "20.00", ' 
        + ' "otherSupportTOBE": "70.00", ' 
        + ' "paymentTOBE": "카드", ' 
        + ' "contractPaymentNumTOBE": "70.00", ' 
        + ' "commentTOBE": "메모", ' 
        + ' "bondCollateral": "true", ' 
        + ' "securityCollateral": "false", ' 
        + ' "primaryContract": "true", ' 
        + ' "specialCollateral": "false", ' 
        + ' "otherDetail": "세부", ' 
        + ' "paymentTOBE": "카드", ' 
        + ' "contractPaymentNumTOBE": "70.00", ' 
        + ' "commentTOBE": "메모", ' 
        + ' "farmBefore": "70.00", ' 
        + ' "marinBefore": "30.00", ' 
        + ' "livestockBefore": "10.00", ' 
        + ' "manufactureBefore": "90.00", ' 
        + ' "nonfoodBefore": "70.00", ' 
        + ' "salesSupportBefore": "30.00", ' 
        + ' "salesTwoMonth": "10.00", ' 
        + ' "salesOneMonth": "90.00", ' 
        + ' "salesMonth": "90.00", ' 
        + ' "salesBefore": "70.00", ' 
        + ' "salesSupportTwoMonth": "30.00", ' 
        + ' "salesSupportOneMonth": "10.00", ' 
        + ' "salesSupportMonth": "90.00", ' 
        + ' "salesSupportRateBefore": "90.00", ' 
        + ' "changeReason": "수정내용", ' 
        + ' "detailChef": "30.00", ' 
        + ' "selectedDelivery": "13회", ' 
        + ' "ImproveDetail": "개선방안", ' 
        + ' "Description": "특이점", ' 
        + ' "attachDoc": "파일명", ' 
        + ' "bondBefore": "50.00", ' 
        + ' "bondTwoMonth": "30.00", ' 

        + ' "stockSum": "51" } ';



        ReportFormController controller = new ReportFormController();
        
        controller.reportCheck = true;
        controller.accountName = '테스트';
        controller.savedAccountName = 'test';

        // controller.getPicklistValues();
        // controller.getAccountInfo();
        // controller.getIncomeExpenses();
        ReportFormController.saveIncomeExpenses(dataList, opptyId, 1, exIncomeId);
        ReportFormController.ReportCheck(exIncomeId, opptyId);
        

        Test.stopTest();
    }

    @isTest
    public static void test2(){
        
        Test.startTest();

        String opptyId = [SELECT Id FROM Opportunity Limit 1].Id; // 영업기회 Id
        CJFW_ExpectedIncomeExpenses__c objExIncome = [SELECT Id, RepresentativeName__c FROM CJFW_ExpectedIncomeExpenses__c LIMIT 1];

        String dataList = ' {"collateralType": "담보",'
        + ' "creditLoanAmount": "100.00", '
        + ' "chefSupport": "60.00", '
        + ' "contractType": "계약서", '
        + ' "summary": "요약", '
        + ' "accountName": "거래처1", '
        + ' "ownerName": "김대표", '
        + ' "accountChannel": "채널", '
        + ' "outwardEntire": "6", '
        + ' "outwardCompanySize": "60.00", '
        + ' "firstDraft": "2023-01-01", '
        + ' "exclusiveDeal": "단독", '
        + ' "accountAddress": "서울시 마포구", '
        + ' "accountPhone": "010-1111-1111", '
        + ' "existGoods": "기존", '
        + ' "exceptionPrice": "20.00", '
        + ' "unitPrice": "30", '
        + ' "exception": "80", '
        + ' "existCenter": "a센터", ' 
        + ' "comment": "기타", ' 
        + ' "contractStartDate": "2023-01-01", '
        + ' "contractEndDate": "2023-12-31", '
        + ' "collateralAmount": "20.00", '
        + ' "collateralAmountAdd": "30", '
        + ' "collateral-period": "2023-12-31", '
        + ' "collateralStart": "2023-01-01", '
        + ' "collateralEnd": "2023-12-31", '
        + ' "collateralStartAdd": "2023-01-01", '
        + ' "collateralEndAdd": "2023-12-31", '
        + ' "deprecAmount": "60.00", ' 
        + ' "incentiveSupport": "60.00", ' 
        + ' "salesFeeSupport": "60.00", ' 
        + ' "donationSupport": "60.00", ' 
        + ' "otherSupport": "60.00", ' 
        + ' "payment": "기타", ' 
        + ' "contractPaymentNum": "60.00", ' 
        + ' "commentASIS": "asis", ' 
        + ' "otherSupport": "60.00", ' 
        + ' "contract-payment-period": "2023-12-31", '
        + ' "contractStartDateTOBE": "2023-01-01", '
        + ' "contractEndDateTOBE": "2023-12-31", '
        + ' "collateralAmountTOBE": "80.00", '
        + ' "collateralAmountAddTOBE": "70.00", '
        + ' "collateralStartTOBE": "2023-01-01", '
        + ' "collateralEndTOBE": "2023-12-31", '
        + ' "collateralStartAddTOBE": "2023-01-01", '
        + ' "collateralEndAddTOBE": "2023-12-31", '
        + ' "deprecAmountTOBE": "70.00", ' 
        + ' "incentiveSupportTOBE": "60.00", ' 
        + ' "salesFeeSupportTOBE": "70.00", ' 
        + ' "donationSupportTOBE": "20.00", ' 
        + ' "otherSupportTOBE": "70.00", ' 
        + ' "paymentTOBE": "카드", ' 
        + ' "contractPaymentNumTOBE": "70.00", ' 
        + ' "commentTOBE": "메모", ' 
        + ' "bondCollateral": "true", ' 
        + ' "securityCollateral": "false", ' 
        + ' "primaryContract": "true", ' 
        + ' "specialCollateral": "false", ' 
        + ' "otherDetail": "세부", ' 
        + ' "paymentTOBE": "카드", ' 
        + ' "contractPaymentNumTOBE": "70.00", ' 
        + ' "commentTOBE": "메모", ' 
        + ' "farmBefore": "70.00", ' 
        + ' "marinBefore": "30.00", ' 
        + ' "livestockBefore": "10.00", ' 
        + ' "manufactureBefore": "90.00", ' 
        + ' "nonfoodBefore": "70.00", ' 
        + ' "salesSupportBefore": "30.00", ' 
        + ' "salesTwoMonth": "10.00", ' 
        + ' "salesOneMonth": "90.00", ' 
        + ' "salesMonth": "90.00", ' 
        + ' "salesBefore": "70.00", ' 
        + ' "salesSupportTwoMonth": "30.00", ' 
        + ' "salesSupportOneMonth": "10.00", ' 
        + ' "salesSupportMonth": "90.00", ' 
        + ' "salesSupportRateBefore": "90.00", ' 
        + ' "changeReason": "수정내용", ' 
        + ' "detailChef": "30.00", ' 
        + ' "selectedDelivery": "13회", ' 
        + ' "ImproveDetail": "개선방안", ' 
        + ' "Description": "특이점", ' 
        + ' "attachDoc": "파일명", ' 

        + ' "stockSum": "51" } ';

        

        // 객체생성
        ReportFormController controller = new ReportFormController();
        // controller class 필드값 초기화
        controller.opportunityId = opptyId;
        String exIncomeId = null; 

        controller.getIncomeExpenses();
        ReportFormController.saveIncomeExpenses(dataList, opptyId, 1, exIncomeId);

        Test.stopTest();
    }
}