/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-15-2023
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
        
        System.debug('옵티 Id'+ Id);
        
        Opportunity objOppty = [
            SELECT Id, Type, OwnerId, Owner.HeadOffice__c
                FROM Opportunity
                WHERE Id =: Id
        ];
            
        List<CJFW_ExpectedIncomeExpenses__c> relatedList = new List<CJFW_ExpectedIncomeExpenses__c>();
        relatedList = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, ExpectSales__c, Opportunity__c, ResultExpectSales__c, ResultExpectRate__c, ExpectContributionProfit__c, ExpectContributionProfitRate__c, SupportFeeRate__c, ExpectSalesProfit__c, ExpectSalesProfitRate__c, ContractDepreciationRate__c, CollateralAmount__c, CollateralType__c, ExpectProfit__c, CollateralPeriod__c, CreditLoanAmount__c, ContractDepreciationSupport__c, SalesFeeSupport__c, DonationSupport__c, OtherSupport__c
                        , PaymentMethod__c
                        , ChefSupportCnt__c, FarmSupportExpect__c, MarineSupportExpect__c, LivestockSupportExpect__c, ManufactureSupportExpect__c, NonFoodSupportExpect__c, SalesSupportExpect__c, IsReportCheck__c, IncentiveSupport__c, ContractPaymentDate__c, Version__c, MoveUrl__c,ReportType__c 
                        FROM CJFW_ExpectedIncomeExpenses__c
                        WHERE Opportunity__c = :Id AND (ReportType__c = 'CRM008' OR ReportType__c = 'CRM011' OR ReportType__c = 'CRM012')
                        ];

        List<CJFW_ExpectedIncomeExpenses__c> relatedList2 = new List<CJFW_ExpectedIncomeExpenses__c>();
        relatedList2 = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, ExpectSales__c, Opportunity__c, ResultExpectSales__c, ResultExpectRate__c, ExpectContributionProfit__c, ExpectContributionProfitRate__c, SupportFeeRate__c, ExpectSalesProfit__c, ExpectSalesProfitRate__c, ContractDepreciationRate__c, CollateralAmount__c, CollateralType__c, ExpectProfit__c, CollateralPeriod__c, CreditLoanAmount__c, ContractDepreciationSupport__c, SalesFeeSupport__c, DonationSupport__c, OtherSupport__c
                        , PaymentMethod__c
                        , ChefSupportCnt__c, FarmSupportExpect__c, MarineSupportExpect__c, LivestockSupportExpect__c, ManufactureSupportExpect__c, NonFoodSupportExpect__c, SalesSupportExpect__c, IsReportCheck__c, IncentiveSupport__c, ContractPaymentDate__c, Version__c, MoveUrl__c,ReportType__c
                            FROM CJFW_ExpectedIncomeExpenses__c
                            WHERE Opportunity__c = :Id AND ReportType__c = 'CRM009'];

        List<CJFW_ExpectedIncomeExpenses__c> relatedList3 = new List<CJFW_ExpectedIncomeExpenses__c>();
        relatedList3 = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, ExpectSales__c, Opportunity__c, ResultExpectSales__c, ResultExpectRate__c, ExpectContributionProfit__c, ExpectContributionProfitRate__c, SupportFeeRate__c, ExpectSalesProfit__c, ExpectSalesProfitRate__c, ContractDepreciationRate__c, CollateralAmount__c, CollateralType__c, ExpectProfit__c, CollateralPeriod__c, CreditLoanAmount__c, ContractDepreciationSupport__c, SalesFeeSupport__c, DonationSupport__c, OtherSupport__c
                        , PaymentMethod__c
                        , ChefSupportCnt__c, FarmSupportExpect__c, MarineSupportExpect__c, LivestockSupportExpect__c, ManufactureSupportExpect__c, NonFoodSupportExpect__c, SalesSupportExpect__c, IsReportCheck__c, IncentiveSupport__c, ContractPaymentDate__c, Version__c, MoveUrl__c,ReportType__c
                        FROM CJFW_ExpectedIncomeExpenses__c
                        WHERE Opportunity__c = :Id AND ReportType__c = 'CRM010'];
        List<CJFW_ExpectedIncomeExpenses__c> relatedList4 = new List<CJFW_ExpectedIncomeExpenses__c>();
        relatedList4 = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, ExpectSales__c, Opportunity__c, ResultExpectSales__c, ResultExpectRate__c, ExpectContributionProfit__c, ExpectContributionProfitRate__c, SupportFeeRate__c, ExpectSalesProfit__c, ExpectSalesProfitRate__c, ContractDepreciationRate__c, CollateralAmount__c, CollateralType__c, ExpectProfit__c, CollateralPeriod__c, CreditLoanAmount__c, ContractDepreciationSupport__c, SalesFeeSupport__c, DonationSupport__c, OtherSupport__c
                        , PaymentMethod__c
                        , ChefSupportCnt__c, FarmSupportExpect__c, MarineSupportExpect__c, LivestockSupportExpect__c, ManufactureSupportExpect__c, NonFoodSupportExpect__c, SalesSupportExpect__c, IsReportCheck__c, IncentiveSupport__c, ContractPaymentDate__c, Version__c, MoveUrl__c,ReportType__c
                            FROM CJFW_ExpectedIncomeExpenses__c
                            WHERE Opportunity__c = :Id ];


        //System.debug('objoppty '+ objOppty);
        //System.debug('objoppty headoffice '+ objOppty.Owner.HeadOffice__c);
        String headLabel = objOppty.Owner.HeadOffice__c;
        String type = objOppty.Type;
        //System.debug('headlabel'+ headLabel);
        if(!String.isEmpty(headLabel) && headLabel =='3001'){ //Owner의 본부가 급식

            return relatedList;
        }else if(!String.isEmpty(headLabel)  && headLabel =='6000' && type == 'New Business'){ //Owner의 본부가 외식이고 유형이 신규 

            return relatedList2;
        }else if(!String.isEmpty(headLabel)  && headLabel =='6000' && type == 'Existing Business'){ //Owner의 본부가 외식이고 유형이 기존

            return relatedList3;
        }else{
            return relatedList4;
        
    }


    }
}