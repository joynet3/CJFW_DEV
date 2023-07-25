/*
* ==================================================================================
*   File Name   : ESM_CreateApprovalController.cls
*   Author      : Minje.kim
*   Date        : 2023.01.12
*   Tester      : ESM_CreateApprovalController_test.cls
*   Description : FS 전자결재 양식 (5종) Render Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2023.01.12    Minje.kim       Create
* ==================================================================================
*/
public without sharing class ESM_CreateApprovalController {

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

    /**
     * @description : 제안시산 Record
     */
    public Balance__c objProposalBalance {
        get {
            if(objProposalBalance == null) {
                objProposalBalance = [SELECT   Id, Name,
                                               SalesRevenueAmt__c, PurchasingCostAmt__c, PurchasingCostPct__c, ManufacturingCostAmt__c, 
                                               ManufacturingCostPct__c, CommonLaborCostAmt__c, ServiceLaborCostAmt__c, LogisticCostAmt__c, 
                                               DepreciationCostAmt__c, RentalCostAmt__c, UtilityCostAmt__c, ConsumableCostAmt__c, EtcCostAmt__c, 
                                               SalesProfitAmt__c, SalesProfitPct__c, FinancialBalanceAmt__c, FinancialProfitAmt__c, FinancialExpenseAmt__c, 
                                               EtcBalanceAmt__c, EtcProfitAmt__c, EtcExpenseAmt__c, MgmtProfitAmt__c, MgmtProfitPct__c
                                      FROM     Balance__c
                                      WHERE    Opportunity__c = :recordId
                                      AND      Classification__c = '제안시산'
                                      ORDER BY CreatedDate DESC
                                      LIMIT    1 ];
                system.debug('[objProposalBalance] :: ' + objProposalBalance);
            }
            return objProposalBalance;
        }
        set;
    }

    /**
     * @description : 제안시산 상세 (시산요약표) 리스트
     */
    public List<BalanceDetail__c> listProposalBalanceDetail_SUM {
        get {
            if(listProposalBalanceDetail_SUM == null) {
                system.debug('[listProposalBalanceDetail_SUM] :: ' + listProposalBalanceDetail_SUM);
                listProposalBalanceDetail_SUM = [
                    SELECT Id, Name, KeyCode__c,  
                        Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                        Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                    FROM   BalanceDetail__c
                    WHERE  Balance__c =: objProposalBalance.Id
                    AND    Name = 'SUM'
                    ORDER BY Balance__c, Name, KeyCode__c
                ];
                system.debug('[listProposalBalanceDetail_SUM] :: ' + listProposalBalanceDetail_SUM);
            }
            return listProposalBalanceDetail_SUM;
        }
        set;
    }

    /**
     * @description : 제안시산 상세 (PL) 리스트
     */
    public List<BalanceDetail__c> listProposalBalanceDetail_PL {
        get {
            if(listProposalBalanceDetail_PL == null) {
                listProposalBalanceDetail_PL = [
                    SELECT Id, Name, KeyCode__c,  
                        Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                        Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                    FROM   BalanceDetail__c
                    WHERE  Balance__c =: objProposalBalance.Id
                    AND    Name = 'PL'
                    ORDER BY Balance__c, Name, KeyCode__c
                ];
                system.debug('[listProposalBalanceDetail_PL] :: ' + listProposalBalanceDetail_PL);
            }
            return listProposalBalanceDetail_PL;
        }
        set;
    }


    /**
     * @description : 제안시산 상세 (IRR) 리스트
     */
    public List<BalanceDetail__c> listProposalBalanceDetail_IRR {
        get {
            if(listProposalBalanceDetail_IRR == null) {
                listProposalBalanceDetail_IRR = [
                    SELECT Id, Name, KeyCode__c,  
                        Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                        Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                    FROM   BalanceDetail__c
                    WHERE  Balance__c =: objProposalBalance.Id
                    AND    Name = 'IRR'
                    ORDER BY Balance__c, Name, KeyCode__c
                ];
                system.debug('[listProposalBalanceDetail_IRR] :: ' + listProposalBalanceDetail_IRR);
            }
            return listProposalBalanceDetail_IRR;
        }
        set;
    }

    /**
     * @description : 오픈시산 Record
     */
    public Balance__c objOpenBalance {
        get {
            if(objOpenBalance == null) {
                objOpenBalance = [SELECT   Id, Name, 
                                           SalesRevenueAmt__c, PurchasingCostAmt__c, PurchasingCostPct__c, ManufacturingCostAmt__c, 
                                           ManufacturingCostPct__c, CommonLaborCostAmt__c, ServiceLaborCostAmt__c, LogisticCostAmt__c, 
                                           DepreciationCostAmt__c, RentalCostAmt__c, UtilityCostAmt__c, ConsumableCostAmt__c, EtcCostAmt__c, 
                                           SalesProfitAmt__c, SalesProfitPct__c, FinancialBalanceAmt__c, FinancialProfitAmt__c, FinancialExpenseAmt__c, 
                                           EtcBalanceAmt__c, EtcProfitAmt__c, EtcExpenseAmt__c, MgmtProfitAmt__c, MgmtProfitPct__c
                                  FROM     Balance__c
                                  WHERE    Opportunity__c = :recordId
                                  AND      Classification__c = '오픈시산'
                                  ORDER BY CreatedDate DESC
                                  LIMIT    1 ];
                system.debug('[objOpenBalance] :: ' + objOpenBalance);
            }
            return objOpenBalance;
        }
        set;
    }

    
    /**
     * @description : 오픈시산 상세 (시산요약표) 리스트
     */
    public List<BalanceDetail__c> listOpenBalanceDetail_SUM {
        get {
            if(listOpenBalanceDetail_SUM == null) {
                listOpenBalanceDetail_SUM = [
                    SELECT Id, Name, KeyCode__c,  
                        Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                        Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                    FROM   BalanceDetail__c
                    WHERE  Balance__c =: objOpenBalance.Id
                    AND    Name = 'SUM'
                    ORDER BY Balance__c, Name, KeyCode__c
                ];
                system.debug('[listOpenBalanceDetail_SUM] :: ' + listOpenBalanceDetail_SUM);
            }
            return listOpenBalanceDetail_SUM;
        }
        set;
    }



    /**
     * @description : 오픈시산 상세 (PL) 리스트
     */
    public List<BalanceDetail__c> listOpenBalanceDetail_PL {
        get {
            if(listOpenBalanceDetail_PL == null) {
                listOpenBalanceDetail_PL = [
                    SELECT Id, Name, KeyCode__c,  
                        Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                        Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                    FROM   BalanceDetail__c
                    WHERE  Balance__c =: objOpenBalance.Id
                    AND    Name = 'PL'
                    ORDER BY Balance__c, Name, KeyCode__c
                ];
                system.debug('[listOpenBalanceDetail_PL] :: ' + listOpenBalanceDetail_PL);
            }
            return listOpenBalanceDetail_PL;
        }
        set;
    }


    /**
     * @description : 오픈시산 상세 (IRR) 리스트
     */
    public List<BalanceDetail__c> listOpenBalanceDetail_IRR {
        get {
            if(listOpenBalanceDetail_IRR == null) {
                listOpenBalanceDetail_IRR = [
                    SELECT Id, Name, KeyCode__c,  
                        Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                        Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                    FROM   BalanceDetail__c
                    WHERE  Balance__c =: objOpenBalance.Id
                    AND    Name = 'IRR'
                    ORDER BY Balance__c, Name, KeyCode__c
                ];
                system.debug('[listOpenBalanceDetail_IRR] :: ' + listOpenBalanceDetail_IRR);
            }
            return listOpenBalanceDetail_IRR;
        }
        set;
    }

}