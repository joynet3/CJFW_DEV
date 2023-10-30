/**
 * @description       : 
 * @author            : jieun.lee3@dkbmc.com
 * @group             : 
 * @last modified on  : 10-27-2023
 * @last modified by  : jieun.lee3@dkbmc.com
**/
public with sharing class CJFW_ContractSealUseFormController {
    /**
     * @description : 현재 접속한 User Id
     */
    public User objUser {
        get {
            if(objUser == null) {
                objUser = [
                    SELECT  Id, EmployeeNumber, HeadOffice__c, SU__c, ToLabel(Team__c), Name, LastName
                    FROM    User
                    WHERE   Id =: UserInfo.getUserId()
                ];
                system.debug('[objUser] :: ' + objUser);
            }
            return objUser;
        }
        set;
    }

    /**
     * @description : 영업기회 Record Id
     */
    public Id recordId {
        get {
            if(recordId == null) {
                recordId = ApexPages.currentPage().getParameters().get('Id');
                system.debug('[recordId] :: ' + recordId);
            }
            return recordId;
        }
        set;
    }

    /**
     * @description : 영업기회 Record
     */
    public Opportunity objOpportunity {
        get {
            if(objOpportunity == null) {
                objOpportunity = [SELECT   Id, Account.name, Account.CustomerID__c, Proposal_Type__c, Address__c, AddressDetails__c, FoodPrice__c,
                                           Proposal_Partner_Background__c, Proposal_Operating_Industry__c, Proposal_ProposedCompany__c, 
                                           Proposal_ContractExpireDate__c, Proposal_ProposalDate__c, Proposal_OpenDate__c, Proposal_SafetyHealthAppointment__c, 
                                           Proposal_ProposedFoodPrice__c,  Proposal_ExpectDailyMeals__c, Proposal_DifferenceAmountProposalFee__c,
                                           Proposal_DailyMeal__c, Proposal_FacilityInvestmentAmount__c, IRRPct__c, CloseDate, ProposalDate__c,
                                           ContractPeriod__c, Proposal_Rentfeemillionwon__c, Proposal_Utility__c, Proposal_Meal__c, Proposal_BSType__c, 
                                           Proposal_InputManpower__c, Proposal_MenuOther__c, Proposal_All__c, Proposal_NewInvestment__c,
                                           Proposal_AcquisitionNegotiation__c, Proposal_UrgentB__c, fm_Proposal_ApplicationBalanceAmountAB__c, 
                                           Proposal_Reason__c, Account.CustID__c
                                    FROM     Opportunity 
                                    WHERE    Id = :recordId
                                    ORDER BY CreatedDate DESC
                                    LIMIT    1 ];
                system.debug('[objOpportunity] :: ' + objOpportunity);
            }
            return objOpportunity;
        }
        set;
    }
}