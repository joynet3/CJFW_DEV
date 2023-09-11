public with sharing class CJFW_ExpectedIncoExpenRelatedController {

    @AuraEnabled
    public static List<CJFW_ExpectedIncomeExpenses__c> getList(String Id){
        try {
            System.debug('Id'+ Id);
            
            return [
                SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, ExpectSales__c, Opportunity__c, ResultExpectSales__c, ResultExpectRate__c, ExpectContributionProfit__c, ExpectContributionProfitRate__c, SupportFeeRate__c, ExpectSalesProfit__c, ExpectSalesProfitRate__c, ContractDepreciationRate__c, CollateralAmount__c, CollateralType__c, ExpectProfit__c, CollateralPeriod__c, CreditLoanAmount__c, ContractDepreciationSupport__c, SalesFeeSupport__c, DonationSupport__c, OtherSupport__c, PaymentMethod__c, ChefSupportCnt__c, FarmSupportExpect__c, MarineSupportExpect__c, LivestockSupportExpect__c, ManufactureSupportExpect__c, NonFoodSupportExpect__c, SalesSupportExpect__c, IsReportCheck__c, IncentiveSupport__c, ContractPaymentDate__c
                FROM CJFW_ExpectedIncomeExpenses__c
                WHERE Opportunity__c = :Id
            ];

        } catch (Exception e) {
            System.debug('message =>' + e.getMessage());
            System.debug('trace =>' + e.getStackTraceString());

            throw new AuraHandledException(e.getMessage());
        }
    }
}