/*
* ==================================================================================
*   File Name   : DecisionProcessNewController.cls
*   Author      : Minje.Kim
*   Date        : 2023.01.11
*   Tester      : DecisionProcessNewController_test.cls
*   Description : 품의이력 생성 화면
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2023.01.11    Minje.Kim    Create
* ==================================================================================
*/

public without sharing class DecisionProcessNewController {

    /**
     * 품의이력 생성 화면 Init
     *      
     * @return Map<String, Object>
     *          - listDocType : 품의유형 선택목록 리스트
     *
    **/
    @AuraEnabled
    public static Map<String, Object> getInitData() {
        Map<String, Object> mapInitData = new Map<String, Object>{         
            'listDocType' => CommonUtil.getPicklistValues('DecisionProcess__c', 'Type__c', false)
        };
        return mapInitData;
    }

    /**
     * 품의이력 생성
     * 
     * @param recordId
     * @param objDecisionProcess 품의이력(DecisionProcess__c) Object
     * @return 
     *
    **/
    @AuraEnabled
    public static void doSave(Id recordId, DecisionProcess__c objDecisionProcess) {
        Boolean isIFError = false;
        try {
            String DocType = objDecisionProcess.Type__c; 
            if ( DocType == 'CRM001' || DocType == 'CRM002' || DocType == 'CRM003' || DocType == 'CRM004' || DocType == 'CRM005'){
               
                // I/F 파라미터 셋팅
                Map<String, Object> mapInput = new Map<String, Object>();
                                
                mapInput.put('apptype', DocType);
    
                // 품의유형에 맞는 양식 HTML로 변환
                PageReference file = null;
                // 1) Risk 점검의뢰서 CRM001
                if ( DocType == 'CRM001' ) {
                    file = new pagereference('/apex/ESM_RiskCheck');
                // 2) 법인(사용) 인감 신청서 CRM002
                } else if ( DocType == 'CRM002' ){
                    file = new pagereference('/apex/ESM_SealUse');
                // 3) 사용인감 반출 신청서 CRM003
                } else if ( DocType == 'CRM003' ){
                    file = new pagereference('/apex/ESM_SealCarryOut');
                // 4) 제안 품의서 CRM004
                } else if ( DocType == 'CRM004' ){
                    file = new pagereference('/apex/ESM_ProposalApproval');
                // 5) 오픈품의서 CRM005
                } else if ( DocType == 'CRM005' ){
                    file = new pagereference('/apex/ESM_OpenApproval');
                }
    
                file.getParameters().put('Id', objDecisionProcess.Opportunity__c ); 
    
                Blob body ;
                if (!Test.isRunningTest()) {
                    body = file.getContent();
                }else{
                    body = Blob.valueOf('UNIT.TEST');
                }
    
                String strBlob = body.toString();
                String strResult = CommonUtil.HTMLparse(strBlob, '<div id="getdata"');
    
                // 유저정보
                User objUser = [
                    SELECT  Id, EmployeeNumber, UserId__c
                    FROM    User
                    WHERE   Id =: UserInfo.getUserId()
                ];

                mapInput.put('userid', objUser.EmployeeNumber);
                mapInput.put('body', strResult); 
    
                IFUtil ifutilWrapper = new IFUtil('IF_SFDC_IFRESH_REG_APPROVAL');
    
                // I/F 진행
                System.debug(' check Input ::: ' + mapInput);
                String strJsonRequestBody = JSON.serialize(mapInput);
                HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);
                system.debug( 'check Output ::: ' + response.getBody() );
    
                // I/F 성공시
                if(response.getStatusCode() == 200){
                    Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
                    // I/F 결과 에러코드 발생시
                    if ( resultMap.get('err_cd') == '실패') {
                        system.debug('[I/F Error] ::: ['+resultMap.get('err_cd')+'] '+resultMap.get('err_msg_ctt'));
                        isIFError = true;
                    }
                    // I/F 결과 에러코드 미발생시
                    else {
                        objDecisionProcess.DocId__c = String.valueOf(resultMap.get('doc_id'));
                        objDecisionProcess.DocURL__c = String.valueOf(resultMap.get('url'))+'&modeType=REUSE';
                        // objDecisionProcess.DocURL__c = String.valueOf(resultMap.get('url'));
                        system.debug( 'check doc_id  ::: ' + resultMap.get('doc_id'));
                        system.debug( 'check doc_num ::: ' + resultMap.get('doc_num'));
                        system.debug( 'check url     ::: ' + resultMap.get('url'));
                    }
                // I/F 실패시
                } else {
                    isIFError = true;
                    system.debug( '[I/F Error] ::: [' + response.getStatusCode() + '] 서버접속 실패');
                }
            }  
            System.debug('objDecisionProcess : ' + objDecisionProcess);
            insert objDecisionProcess;

        } catch(Exception e) {
            System.debug('error getMessage : ' + e.getMessage());
            System.debug('error getLineNumber : ' + e.getLineNumber());
            System.debug('error getCause : ' + e.getCause());
            String strErrorMessage = '[오류]  관리자에게 문의해주세요. (' + e.getMessage() + ')';

            if(isIFError) {
                strErrorMessage = '[I/F Error] '+strErrorMessage;
            }

            throw new AuraHandledException(strErrorMessage);
        }
    }

    /**
     * 제안품의 & 오픈품의 생성 조건 확인
     * 
     * @param recordId 영업기회(Opportunity) RecordId
     * @param DocType 문서종류 제안품의서(CRM004), 오픈품의서(CRM005)
     * @return Map<String, Object>
     *          - isAvailable : 생성 가능 여부
     *          - strMessage : 오류 메세지
    **/
    @AuraEnabled
    public static Map<String, Object> doCheckOpenApproval(String recordId, String DocType) { 
        List<Balance__c> listBalance;
        List<DecisionProcess__c > listDecisionProcess;
        Boolean isAvailable = true;
        String strMessage = '';
        try {
            // 제안 품의서 CRM004
            if (DocType == 'CRM004') {
                listBalance = [
                        SELECT Id, Name
                        FROM Balance__c
                        WHERE Opportunity__r.Id = :recordId
                        AND Classification__c = '제안시산'
                        LIMIT 1
                ];

                if (listBalance.isEmpty()) {
                    isAvailable = false;
                    strMessage = '제안 시산을 먼저 등록 후 제안 품의서를 생성해주세요.';
                }
            // 오픈품의서 CRM005
            } else if (DocType == 'CRM005') {
                listBalance = [
                        SELECT Id, Name
                        FROM Balance__c
                        WHERE Opportunity__r.Id = :recordId
                        AND Classification__c = '오픈시산'
                        LIMIT 1
                ];

                listDecisionProcess = [
                        SELECT Id, Type__c
                        FROM DecisionProcess__c
                        WHERE Opportunity__r.Id = :recordId
                        AND Type__c = 'CRM004'
                        LIMIT 1
                ];
                if (listBalance.isEmpty() || listDecisionProcess.isEmpty()) {
                    isAvailable = false;
                    strMessage = '오픈 시산과 제안 품의서를 먼저 등록 후 오픈 품의서를 생성해주세요.';
                }
            }
        } catch(Exception e) {
            System.debug('error getMessage : ' + e.getMessage());
            System.debug('error getLineNumber : ' + e.getLineNumber());
            System.debug('error getCause : ' + e.getCause());
        }

        Map<String, Object> mapInitData = new Map<String, Object>{
            'isAvailable' => isAvailable,
            'strMessage' => strMessage
        };
        return mapInitData;
    }

    
    @Future(Callout=true)
    public static void doDelete(String docId) {

        try {
            User objUser = [
                SELECT  Id, EmployeeNumber
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
            ];

            // I/F 파라미터 셋팅
            Map<String, Object> mapInput = new Map<String, Object>();
                            
            mapInput.put('doc_Id', docId);
            mapInput.put('sabun', objUser.EmployeeNumber);

            IFUtil ifutilWrapper = new IFUtil('IF_SFDC_IFRESH_DEL_APPROVAL');

            // I/F 진행
            System.debug(' check Input ::: ' + mapInput);
            String strJsonRequestBody = JSON.serialize(mapInput);
            HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);
            system.debug( 'check Output ::: ' + response.getBody() );

            // I/F 성공시
            if(response.getStatusCode() == 200){
                Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
                System.debug('성공');
            } else {
                system.debug( '[I/F Error] ::: [' + response.getStatusCode() + '] 서버접속 실패');
            }

        } catch(Exception e) {
            System.debug('error getMessage : ' + e.getMessage());
            System.debug('error getLineNumber : ' + e.getLineNumber());
            System.debug('error getCause : ' + e.getCause());
        }
    }

}