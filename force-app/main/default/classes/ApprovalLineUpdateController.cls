/*
* ==================================================================================
*   File Name   : ApprovalLineUpdateController.cls
*   Author      : Minje.Kim
*   Date        : 2023.01.09
*   Tester      : ApprovalLineUpdateController_test.cls
*   Description : 전자결재 문서상태 업데이트 Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2023.01.09    Minje.Kim    Create
* ==================================================================================
*/
public without sharing class ApprovalLineUpdateController {

    /**
     * 품의이력 전자결재 상태 업데이트 대상 검색
     * 
     * @return Map<String, Object> mapInitData
     *         - listData : 업데이트 대상 품의 이력 리스트
     *         - listDataLength : 업데이트 대상 품의 이력 리스트 길이
     *
    **/
    @AuraEnabled
    public static Map<String, Object> doGetUpdateTarget(String recordId) {

        List<DecisionProcess__c> listData = [
            SELECT  Id, Name, DocId__c
            FROM    DecisionProcess__c
            WHERE   DocStatus__c != '완료'
            AND     DocStatus__c != '회수(기안취소)'
            AND     DocId__c != ''
            AND     Opportunity__r.Id =: recordId
        ];

        Map<String, Object> mapInitData = new Map<String, Object>{            
            'listData' => listData,
            'listDataLength' => listData.size()
        };

        return mapInitData;
    }

    /**
     * 품의이력 전자결재 대상 쿼리 (단일 행 선택)
     * 
     * @param  String targetId
     *
    **/
    @AuraEnabled
    public static void doUpdateApprovalLine(String targetId) {
        List<DecisionProcess__c> listDecisionProcess = [
            SELECT  Id, Name, DocId__c, DocStatus__c, totalLineCount__c, approvedCount__c, DocURL__c, 
                    approvedUserName__c, approvedUserType__c, approvedDate__c, approvedUserCode__c, Opportunity__c
            FROM    DecisionProcess__c
            WHERE   Id =: targetId
        ];

        List<DecisionProcess__c> listTarget = new List<DecisionProcess__c>();
        if( !listDecisionProcess.isEmpty()){
            DecisionProcess__c objDecisionProcess = listDecisionProcess[0];
            // ※ 공용함수로 사용하기 위해 아래 메소드 분리함 ( ApprovalLineAutoUpdate_ba 에서 사용)
            ApprovalLineUpdateController.doUpdateApproval(objDecisionProcess);
        }
    }
    
    /**
     * 품의이력 전자결재 상태 업데이트
     * 
     * @param objDecisionProcess : 업데이트 대상 품의이력 레코드
     *
    **/
    public static void doUpdateApproval(DecisionProcess__c objDecisionProcess) {
        
        // 파라미터 설정
        Map<String,String> objInput = new Map<String,String>();
        system.debug(' objDecisionProcess ::: ' + objDecisionProcess);
        system.debug(' Input DocId ::: ' + objDecisionProcess.DocId__c);
        objInput.put('doc_id', String.valueOf(objDecisionProcess.DocId__c));
        
        // I/F 실행
        IFUtil ifutilWrapper = new IFUtil('IF_SFDC_IFRESH_INFO_APPROVAL');
        String strJsonRequestBody = JSON.serialize(objInput);
        HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);

        system.debug(' Ouput ::: ' + response.getBody() );

        // I/F 성공 시 
        if ( response.getStatusCode() == 200  ){
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
            // 반환 시 에러코드 발생한 경우 에러메세지 
            if ( resultMap.get('err_cd') == '실패') {
                system.debug( '[I/F Error] ::: ['+resultMap.get('err_cd')+'] '+resultMap.get('err_msg_ctt'));
            }
            // 반환 시 에러코드 발생한 경우 에러메세지 
            else if ( resultMap.get('err_cd') == '9999'){
                system.debug( '[I/F Error] ::: ['+resultMap.get('err_cd')+'] '+resultMap.get('err_msg_ctt'));
            }
            // 반환 시 에러코드 발생한 경우 에러메세지 
            else if ( resultMap.get('err_msg_ctt') == 'DATA가 없습니다'){
                system.debug( '[I/F Error] ::: ['+resultMap.get('err_cd')+'] '+resultMap.get('err_msg_ctt'));
            }
            // 반환 시 정상적인 경우 해당 품의이력에 상태업데이트 결과 저장
            else {
                system.debug( 'check doc_state ::: ' + resultMap.get('doc_state'));
                system.debug( 'check url ::: ' + resultMap.get('url'));
                system.debug( 'check approval_line ::: ' + resultMap.get('approval_line'));
                List<Object> listLine = (List<Object>) resultMap.get('approval_line');

                String DocStatus = String.valueOf(resultMap.get('doc_state'));
                String DocUrl = String.valueOf(resultMap.get('url'));
                Integer approvedCount = 0;
                Integer totalLineCount = listLine.size();
                String approvedUserName = '';
                String approvedUserType = '';
                String approvedDate = '';
                String approvedUserCode = '';         
                
                // 결재 상태 리스트 중 최근 결재 이력 찾기
                for (Integer i = totalLineCount-1 ; i >= 0 ; i--){
                    system.debug( 'i ::: ' + i);
                    system.debug( 'listLine['+i+'] ::: ' + listLine[i]);
                    Map<String, Object> mapObjLine = (Map<String, Object>) listLine[i]; 
                    String status = String.valueOf(mapObjLine.get('status'));
                    if ( status == '결재처리함'){
                        approvedCount    = Integer.valueOf(String.valueOf(mapObjLine.get('no')));
                        approvedUserName = String.valueOf(mapObjLine.get('user_name')); 
                        approvedUserType = String.valueOf(mapObjLine.get('approval_type'));
                        approvedDate     = String.valueOf(mapObjLine.get('approval_date')); 
                        approvedUserCode = String.valueOf(mapObjLine.get('user_id'));
                        break;
                    }             
                }
                
                System.debug('approvedCount ::: ' + approvedCount);
                System.debug('approvedUserName ::: ' + approvedUserName);
                System.debug('approvedUserType ::: ' + approvedUserType);
                System.debug('approvedDate ::: ' + approvedDate);
                System.debug('approvedUserCode ::: ' + approvedUserCode);

                // 값이 바뀌어 있는 경우에만 update
                if ( 
                    objDecisionProcess.DocStatus__c != DocStatus || 
                    objDecisionProcess.approvedCount__c != approvedCount || 
                    objDecisionProcess.approvedUserName__c != approvedUserName || 
                    objDecisionProcess.approvedUserType__c != approvedUserType || 
                    objDecisionProcess.approvedDate__c != approvedDate || 
                    objDecisionProcess.approvedUserCode__c != approvedUserCode ||
                    objDecisionProcess.totalLineCount__c != totalLineCount ||
                    objDecisionProcess.DocURL__c != DocUrl
                )
                {
                    objDecisionProcess.Id = objDecisionProcess.Id;
                    objDecisionProcess.DocStatus__c = DocStatus;
                    objDecisionProcess.approvedCount__c = approvedCount;
                    objDecisionProcess.approvedUserName__c = approvedUserName;
                    objDecisionProcess.approvedUserType__c = approvedUserType;
                    objDecisionProcess.approvedDate__c = approvedDate;
                    objDecisionProcess.approvedUserCode__c = approvedUserCode;
                    objDecisionProcess.totalLineCount__c = totalLineCount;
                    objDecisionProcess.DocURL__c = DocUrl;
                    update objDecisionProcess;

                    // 문서완료 시 확정매출 설정 (오픈시산 정보) 
                    if( objDecisionProcess.DocStatus__c == '완료' && objDecisionProcess.Opportunity__c != null){
                        List<Balance__c> listOpenBalance = [SELECT   Id, Name, IRRPct__c,
                                                                        SalesRevenueAmt__c, PurchasingCostAmt__c, PurchasingCostPct__c, ManufacturingCostAmt__c, 
                                                                        ManufacturingCostPct__c, CommonLaborCostAmt__c, ServiceLaborCostAmt__c, LogisticCostAmt__c, 
                                                                        DepreciationCostAmt__c, RentalCostAmt__c, UtilityCostAmt__c, ConsumableCostAmt__c, EtcCostAmt__c, 
                                                                        SalesProfitAmt__c, SalesProfitPct__c, FinancialBalanceAmt__c, FinancialProfitAmt__c, FinancialExpenseAmt__c, 
                                                                        EtcBalanceAmt__c, EtcProfitAmt__c, EtcExpenseAmt__c, MgmtProfitAmt__c, MgmtProfitPct__c
                                                            FROM     Balance__c
                                                            WHERE    Opportunity__c = :objDecisionProcess.Opportunity__c
                                                            AND      Classification__c = '오픈시산'
                                                            ORDER BY CreatedDate DESC
                                                            LIMIT    1 ];
                        if( !listOpenBalance.isEmpty()){
                            Opportunity objOppty = new Opportunity();
                            objOppty.SalesRevenue__c = listOpenBalance[0].SalesRevenueAmt__c;
                            objOppty.PurchasingCost__c = listOpenBalance[0].PurchasingCostAmt__c;
                            objOppty.ManufacturingCost__c = listOpenBalance[0].ManufacturingCostAmt__c;
                            objOppty.SalesProfit__c = listOpenBalance[0].SalesProfitAmt__c;
                            objOppty.MgmtProfit__c = listOpenBalance[0].MgmtProfitAmt__c;
                            objOppty.IRRPct__c = listOpenBalance[0].IRRPct__c;
                        }
                    }
                }
            }
        }
        else {
            system.debug( '[I/F Error] ::: [' + response.getStatusCode() + '] 서버접속 실패');
        }
    }
}