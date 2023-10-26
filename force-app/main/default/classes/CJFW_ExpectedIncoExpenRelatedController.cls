/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
public with sharing class CJFW_ExpectedIncoExpenRelatedController {

    /* 
     * cjfwRelatedExpectedProfit lwc에서 사용
     * @param  recordId  oppty record id 
     * 영업기회 -> relatedList(예상손익Obj) 가져오기
     */
    @AuraEnabled
    public static List<CJFW_ExpectedIncomeExpenses__c> getList(String Id){
        try {
             System.debug('옵티 Id'+ Id);
            
            User objUser = [
                SELECT  Id, HeadOfficeLabel__c
                 FROM    User
                 WHERE   Id =: UserInfo.getUserId()
                ];

            Opportunity objOppty = [
                SELECT Id, Type
                 FROM Opportunity
                 WHERE Id =: Id
            ];
                
            String headLabel = objUser.HeadOfficeLabel__c;
            String type = objOppty.Type;
            System.debug('headlabel'+ headLabel);
            if(!String.isEmpty(headLabel) && headLabel =='급식SU'){

                return [
                    SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, ExpectSales__c, Opportunity__c, ResultExpectSales__c, ResultExpectRate__c, ExpectContributionProfit__c, ExpectContributionProfitRate__c, SupportFeeRate__c, ExpectSalesProfit__c, ExpectSalesProfitRate__c, ContractDepreciationRate__c, CollateralAmount__c, CollateralType__c, ExpectProfit__c, CollateralPeriod__c, CreditLoanAmount__c, ContractDepreciationSupport__c, SalesFeeSupport__c, DonationSupport__c, OtherSupport__c
                    , PaymentMethod__c
                    , ChefSupportCnt__c, FarmSupportExpect__c, MarineSupportExpect__c, LivestockSupportExpect__c, ManufactureSupportExpect__c, NonFoodSupportExpect__c, SalesSupportExpect__c, IsReportCheck__c, IncentiveSupport__c, ContractPaymentDate__c, Version__c, MoveUrl__c,ReportType__c 
                     FROM CJFW_ExpectedIncomeExpenses__c
                     WHERE Opportunity__c = :Id AND ReportType__c = 'CRM008'
                    ];
            }else if(!String.isEmpty(headLabel)  && headLabel =='외식SU' && type == 'New Business'){
                return [
                    SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, ExpectSales__c, Opportunity__c, ResultExpectSales__c, ResultExpectRate__c, ExpectContributionProfit__c, ExpectContributionProfitRate__c, SupportFeeRate__c, ExpectSalesProfit__c, ExpectSalesProfitRate__c, ContractDepreciationRate__c, CollateralAmount__c, CollateralType__c, ExpectProfit__c, CollateralPeriod__c, CreditLoanAmount__c, ContractDepreciationSupport__c, SalesFeeSupport__c, DonationSupport__c, OtherSupport__c
                    , PaymentMethod__c
                    , ChefSupportCnt__c, FarmSupportExpect__c, MarineSupportExpect__c, LivestockSupportExpect__c, ManufactureSupportExpect__c, NonFoodSupportExpect__c, SalesSupportExpect__c, IsReportCheck__c, IncentiveSupport__c, ContractPaymentDate__c, Version__c, MoveUrl__c,ReportType__c
                     FROM CJFW_ExpectedIncomeExpenses__c
                     WHERE Opportunity__c = :Id AND ReportType__c = 'CRM009'
                    ];
            }else if(!String.isEmpty(headLabel)  && headLabel =='외식SU' && type == 'Existing Business'){
                return [
                    SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, ExpectSales__c, Opportunity__c, ResultExpectSales__c, ResultExpectRate__c, ExpectContributionProfit__c, ExpectContributionProfitRate__c, SupportFeeRate__c, ExpectSalesProfit__c, ExpectSalesProfitRate__c, ContractDepreciationRate__c, CollateralAmount__c, CollateralType__c, ExpectProfit__c, CollateralPeriod__c, CreditLoanAmount__c, ContractDepreciationSupport__c, SalesFeeSupport__c, DonationSupport__c, OtherSupport__c
                    , PaymentMethod__c
                    , ChefSupportCnt__c, FarmSupportExpect__c, MarineSupportExpect__c, LivestockSupportExpect__c, ManufactureSupportExpect__c, NonFoodSupportExpect__c, SalesSupportExpect__c, IsReportCheck__c, IncentiveSupport__c, ContractPaymentDate__c, Version__c, MoveUrl__c,ReportType__c
                     FROM CJFW_ExpectedIncomeExpenses__c
                     WHERE Opportunity__c = :Id AND ReportType__c = 'CRM010'
                    ];
            }else{
                return [
                    SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, ExpectSales__c, Opportunity__c, ResultExpectSales__c, ResultExpectRate__c, ExpectContributionProfit__c, ExpectContributionProfitRate__c, SupportFeeRate__c, ExpectSalesProfit__c, ExpectSalesProfitRate__c, ContractDepreciationRate__c, CollateralAmount__c, CollateralType__c, ExpectProfit__c, CollateralPeriod__c, CreditLoanAmount__c, ContractDepreciationSupport__c, SalesFeeSupport__c, DonationSupport__c, OtherSupport__c
                    , PaymentMethod__c
                    , ChefSupportCnt__c, FarmSupportExpect__c, MarineSupportExpect__c, LivestockSupportExpect__c, ManufactureSupportExpect__c, NonFoodSupportExpect__c, SalesSupportExpect__c, IsReportCheck__c, IncentiveSupport__c, ContractPaymentDate__c, Version__c, MoveUrl__c,ReportType__c
                     FROM CJFW_ExpectedIncomeExpenses__c
                     WHERE Opportunity__c = :Id 
                    ];
            }
        } catch (Exception e) {
            System.debug('message =>' + e.getMessage());
            System.debug('trace =>' + e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }
    }


}