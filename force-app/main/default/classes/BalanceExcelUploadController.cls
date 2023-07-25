/*
* ==================================================================================
*   File Name   : BalanceExcelUploadController.cls
*   Author      : Minje.kim
*   Date        : 2022.08.02
*   Tester      : BalanceExcelUploadController_test.cls
*   Description : 시산 업로드 관리 Controller (4개 코드 공용 사용 - 아래 참고)
*                 BalanceTableMgmt.cmp, BalanceExcelUpload.cmp, BalanceCompareView.vfp, BalanceExcelUploadView.vfp 
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.08.02    Minje.kim       Create
* ==================================================================================
*/

public without sharing class BalanceExcelUploadController {

    /**
     * @description : 영업기회 레코드 Id
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
     * @description : 시산 타입 1 (시산요약표 / PL / IRR)
     */
    public String selectedTab {
        get {
            if(selectedTab == null) {
                selectedTab = ApexPages.currentPage().getParameters().get('viewType');
                system.debug('[selectedTab] :: ' + selectedTab);
            }
            return selectedTab;
        }
        set;
    }
    
    /**
     * @description : 시산 타입 2 (제안시산 / 오픈시산)
     */
    public String balanceType {
        get {
            if(balanceType == null) {
                balanceType = ApexPages.currentPage().getParameters().get('balanceType');
                system.debug('[balanceType] :: ' + balanceType);
            }
            return balanceType;
        }
        set;
    }
   

    /**
     * @description : 제안시산 레코드
     */
    public Balance__c objProposalBalance {
        get {
            if(objProposalBalance == null) {
                List<Balance__c> listProposalBalance = [SELECT   Id, Name, 
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
                if (!listProposalBalance.isEmpty()){
                    objProposalBalance = listProposalBalance[0];
                } else {
                    objProposalBalance = new Balance__c();
                }
                system.debug('[objProposalBalance] :: ' + objProposalBalance);
            }
            return objProposalBalance;
        }
        set;
    }

    /**
     * @description : 오픈시산 레코드
     */
    public Balance__c objOpenBalance {
        get {
            if(objOpenBalance == null) {
                List<Balance__c> listOpenBalance = [SELECT   Id, Name,
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
                if (!listOpenBalance.isEmpty()){
                    objOpenBalance = listOpenBalance[0];
                } else {
                    objOpenBalance = new Balance__c();
                }
                system.debug('[objOpenBalance] :: ' + objOpenBalance);
            }
            return objOpenBalance;
        }
        set;
    }

    /**
     * @description : 시산 레코드
     */
    public Balance__c objBalance {
        get {
            if(objBalance == null) {
                List<Balance__c> listBalance = [SELECT   Id, Name,
                                           SalesRevenueAmt__c, PurchasingCostAmt__c, PurchasingCostPct__c, ManufacturingCostAmt__c, 
                                           ManufacturingCostPct__c, CommonLaborCostAmt__c, ServiceLaborCostAmt__c, LogisticCostAmt__c, 
                                           DepreciationCostAmt__c, RentalCostAmt__c, UtilityCostAmt__c, ConsumableCostAmt__c, EtcCostAmt__c, 
                                           SalesProfitAmt__c, SalesProfitPct__c, FinancialBalanceAmt__c, FinancialProfitAmt__c, FinancialExpenseAmt__c, 
                                           EtcBalanceAmt__c, EtcProfitAmt__c, EtcExpenseAmt__c, MgmtProfitAmt__c, MgmtProfitPct__c
                                  FROM     Balance__c
                                  WHERE    Opportunity__c = :recordId
                                  AND      Classification__c =:balanceType
                                  ORDER BY CreatedDate DESC
                                  LIMIT    1 ];
                if (!listBalance.isEmpty()){
                    objBalance = listBalance[0];
                } else {
                    objBalance = new Balance__c();
                }
                system.debug('[objBalance] :: ' + objBalance);
            }
            return objBalance;
        }
        set;
    }

    /**
     * @description : 시산 상세 (시산요약표) 리스트
     */
    public List<BalanceDetail__c> listBalanceDetail_SUM {
        get {
            if(listBalanceDetail_SUM == null) {
                system.debug('[listBalanceDetail_SUM] :: ' + listBalanceDetail_SUM);
                listBalanceDetail_SUM = [
                    SELECT Id, Name, KeyCode__c,  
                        Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                        Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                    FROM   BalanceDetail__c
                    WHERE  Balance__c =: objBalance.Id
                    AND    Name = 'SUM'
                    ORDER BY Balance__c, Name, KeyCode__c
                ];
                system.debug('[listBalanceDetail_SUM] :: ' + listBalanceDetail_SUM);
            }
            return listBalanceDetail_SUM;
        }
        set;
    }



    /**
     * @description : 시산 상세 (PL) 리스트
     */
    public List<BalanceDetail__c> listBalanceDetail_PL {
        get {
            if(listBalanceDetail_PL == null) {
                listBalanceDetail_PL = [
                    SELECT Id, Name, KeyCode__c,  
                        Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                        Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                    FROM   BalanceDetail__c
                    WHERE  Balance__c =: objBalance.Id
                    AND    Name = 'PL'
                    ORDER BY Balance__c, Name, KeyCode__c
                ];
                system.debug('[listBalanceDetail_PL] :: ' + listBalanceDetail_PL);
            }
            return listBalanceDetail_PL;
        }
        set;
    }


    /**
     * @description : 시산 상세 (IRR) 리스트
     */
    public List<BalanceDetail__c> listBalanceDetail_IRR {
        get {
            if(listBalanceDetail_IRR == null) {
                listBalanceDetail_IRR = [
                    SELECT Id, Name, KeyCode__c,  
                        Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                        Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                    FROM   BalanceDetail__c
                    WHERE  Balance__c =: objBalance.Id
                    AND    Name = 'IRR'
                    ORDER BY Balance__c, Name, KeyCode__c
                ];
                system.debug('[listBalanceDetail_IRR] :: ' + listBalanceDetail_IRR);
            }
            return listBalanceDetail_IRR;
        }
        set;
    }
   

    
    /**
     * 현재 오그의 prefix (URL) 조회 / BalanceTableMgmt.cmp
     * 
     * @return Map<String, Object> mapInitData
     *         - prefix : 현재 오그의 prefix (URL)
     *         
    **/
    @AuraEnabled
    public static Map<String, Object> doGetPrefix() {

        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl =' + baseUrl);

        Map<String, Object> mapInitData = new Map<String, Object>{
            'prefix' => baseUrl
        };
        return mapInitData;
    }

    
    /**
     * 초기화 (기존 업로드 된 시산 데이터가 있으면 초기 셋팅) / BalanceExcelUpload.cmp
     * 
     * @param recordId 영업기회 레코드 ID
     * @param balanceType 제안/오픈 시산 구분
     * @return Map<String, Object> mapInitData
     *         - objBalance : 시산 레코드
     *         - listBalanceDetail_SUM : 시산 상세 레코드 리스트 (시산요약표)
     *         - listBalanceDetail_IRR : 시산 상세 레코드 리스트 (IRR)
     *         - listBalanceDetail_PL  : 시산 상세 레코드 리스트 (PL)
     * 
    **/
    @AuraEnabled
    public static Map<String, Object> doInit(String recordId, String balanceType) {
        System.debug('recordId :: ' + recordId );
        System.debug('balanceType :: ' + balanceType );

        List<Balance__c> listBalance = [SELECT  Id, Name
                                        FROM    Balance__c
                                        WHERE   Opportunity__r.Id = :recordId
                                        AND     Classification__c = :balanceType
                                        LIMIT   1];
        
        
        List<BalanceDetail__c> listBalanceDetail_SUM = new List<BalanceDetail__c>();
        List<BalanceDetail__c> listBalanceDetail_IRR = new List<BalanceDetail__c>();
        List<BalanceDetail__c> listBalanceDetail_PL = new List<BalanceDetail__c>();

        if ( !listBalance.isEmpty()){
            String objBalanceId = listBalance[0].Id;
            listBalanceDetail_SUM = [
                SELECT Id, Name, KeyCode__c,  
                    Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                    Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                FROM   BalanceDetail__c
                WHERE  Balance__c =: objBalanceId
                AND    Name = 'SUM'
                ORDER BY Balance__c, Name, KeyCode__c
            ];

            listBalanceDetail_IRR = [
                SELECT   Id, Name, KeyCode__c,  
                         Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                         Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                FROM     BalanceDetail__c
                WHERE    Balance__c =: objBalanceId
                AND      Name = 'IRR'
                ORDER BY Balance__c, Name, KeyCode__c
            ];

            listBalanceDetail_PL = [
                SELECT Id, Name, KeyCode__c,  
                    Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c, Column9__c,
                    Column10__c, Column11__c, Column12__c, Column13__c, Column14__c, Column15__c, Column16__c, Column17__c
                FROM   BalanceDetail__c
                WHERE  Balance__c =: objBalanceId
                AND    Name = 'PL'
                ORDER BY Balance__c, Name, KeyCode__c
            ];
        }
        Map<String, Object> mapInitData = new Map<String, Object>{
            'objBalance' => listBalance.isEmpty() ? new Balance__c(): listBalance[0],
            'listBalanceDetail_SUM' => listBalanceDetail_SUM,
            'listBalanceDetail_IRR' => listBalanceDetail_IRR,
            'listBalanceDetail_PL' => listBalanceDetail_PL
        };
        return mapInitData;
    }

    
    /**
     * 제안시산 존재 여부확인 / BalanceExcelUpload.cmp
     * 
     * @param recordId 영업기회 레코드 ID
     * @param balanceType 제안/오픈 시산 구분
     * @return Map<String, Object> mapInitData
     *         - isOpenUpload : 시산 업로드 화면 생성 여부
     * 
    **/
    @AuraEnabled
    public static Map<String, Object> doOpenUpload(String recordId, String balanceType) { 
        System.debug('recordId :: ' + recordId );
        System.debug('balanceType :: ' + balanceType );
        List<Balance__c> listBalance;
        Boolean isOpenUpload = true;
        if (balanceType == '오픈시산') {
            listBalance = [
                    SELECT Id, Name
                    FROM Balance__c
                    WHERE Opportunity__r.Id = :recordId
                    AND Classification__c = '제안시산'
                    LIMIT 1
            ];
            // 제안시산이 존재하지 않으면 시산 업로드 화면 못 띄우게 제한
            if (listBalance.isEmpty()) {
                isOpenUpload = false;
            }
        }

        Map<String, Object> mapInitData = new Map<String, Object>{
            'isOpenUpload' => isOpenUpload
        };
        return mapInitData;
    }

    /**
     * 제안시산 존재 여부확인 / BalanceExcelUpload.cmp
     * 
     * @param recordId 영업기회 레코드 ID
     * @param balanceType 제안/오픈 시산 구분
     * @return Map<String, Object> mapInitData
     *         - isOpenUpload : 시산 업로드 화면 생성 여부
     * 
    **/
    @AuraEnabled
    public static void doSave(String recordId, String balanceType, Balance__c objBalance, List<BalanceDetail__c> listBalanceDetail_SUM, List<BalanceDetail__c> listBalanceDetail_IRR, List<BalanceDetail__c> listBalanceDetail_PL) {
        try{
            system.debug(' objBalance ::: ' + objBalance );
            system.debug(' objBalance.Id ::: ' + objBalance.Id );
            system.debug(' recordId ::: ' + recordId );
            
            objBalance.Opportunity__c = recordId;
            objBalance.Classification__c = balanceType;

            objBalance.IRRPct__c = Integer.valueOf(objBalance.IRRPct__c);
            objBalance.SalesRevenueAmt__c = Integer.valueOf(objBalance.SalesRevenue__c.replace(',',''));
            objBalance.SalesRevenue__c = objBalance.SalesRevenue__c;

            objBalance.PurchasingCostAmt__c = Integer.valueOf(objBalance.PurchasingCost__c.replace(',',''));
            objBalance.PurchasingCostPct__c = Integer.valueOf(objBalance.PurchasingCostPct__c);
            objBalance.PurchasingCost__c = objBalance.PurchasingCost__c + ' ('+objBalance.PurchasingCostPct__c+'%)';

            objBalance.ManufacturingCostAmt__c = Integer.valueOf(objBalance.ManufacturingCost__c.replace(',',''));
            objBalance.ManufacturingCostPct__c = Integer.valueOf(objBalance.ManufacturingCostPct__c);
            objBalance.ManufacturingCost__c = objBalance.ManufacturingCost__c + ' ('+objBalance.ManufacturingCostPct__c+'%)';

            objBalance.SalesProfitAmt__c = Integer.valueOf(objBalance.SalesProfit__c.replace(',',''));
            objBalance.SalesProfitPct__c = Integer.valueOf(objBalance.SalesProfitPct__c);
            objBalance.SalesProfit__c = objBalance.SalesProfit__c + ' ('+objBalance.SalesProfitPct__c+'%)';

            objBalance.MgmtProfitAmt__c = Integer.valueOf(objBalance.MgmtProfit__c.replace(',',''));
            objBalance.MgmtProfitPct__c = Integer.valueOf(objBalance.MgmtProfitPct__c);
            objBalance.MgmtProfit__c = objBalance.MgmtProfit__c + ' ('+objBalance.MgmtProfitPct__c+'%)';

            database.upsert(objBalance);

            system.debug('objBalance.Id after upsert :: ' + objBalance.Id);

            List<BalanceDetail__c> listOldBalanceDetail = [
                SELECT Id, Name, KeyCode__c,  
                       Column1__c, Column2__c, Column3__c, Column4__c, Column5__c, Column6__c, Column7__c, Column8__c,
                       Column9__c, Column10__c, Column11__c, Column12__c, Column13__c, Column15__c, Column16__c, Column17__c
                FROM   BalanceDetail__c
                WHERE  Balance__r.Id =: objBalance.Id
            ];

            if ( !listOldBalanceDetail.isEmpty())
                delete listOldBalanceDetail;

            if ( !listBalanceDetail_SUM.isEmpty()){
                for ( BalanceDetail__c objBalanceDetail_SUM : listBalanceDetail_SUM){
                    objBalanceDetail_SUM.Balance__c = objBalance.Id;
                    objBalanceDetail_SUM.Id = null;
                }
                insert listBalanceDetail_SUM; 
            }    
            if ( !listBalanceDetail_IRR.isEmpty()){
                for ( BalanceDetail__c objBalanceDetail_IRR : listBalanceDetail_IRR){
                    objBalanceDetail_IRR.Balance__c = objBalance.Id;
                    objBalanceDetail_IRR.Id = null;
                }
                insert listBalanceDetail_IRR; 
            }    
            if ( !listBalanceDetail_PL.isEmpty()){
                for ( BalanceDetail__c objBalanceDetail_PL : listBalanceDetail_PL){
                    objBalanceDetail_PL.Balance__c = objBalance.Id;
                    objBalanceDetail_PL.Id = null;
                }
                insert listBalanceDetail_PL; 
            }      
        }
        catch(Exception e){
            system.debug('BalanceExcelUploadController doSave error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

}