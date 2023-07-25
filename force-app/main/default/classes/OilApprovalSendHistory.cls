/************************************************************************************
 * File Name   		: OilApprovalSendHistory.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.01.10
 * Tester	  		: OilApprovalSendHistory_test.cls
 * Description 		: 주유비 전표처리 전송 이력 관리 Controller
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.01.10      Minje.Kim       Create
*************************************************************************************/

public with sharing class OilApprovalSendHistory {
    
    /**
     * 주유비 정산 전송이력 탭 Init (데이터 조회를 위한 정보 셋팅)
     * 
     * @params 없음
     * @return DataWrapper 
     *         - objUser : 유저 정보
     *         - listSelectStatus : 제출상태 리스트
     *         - listSelectHeadOffice : 사업부 리스트
     *         - mapSelectSU : SU 리스트
     *         - listYear : 년도 리스트
     *         - listMonth : 월 리스트
     *         - targetYear : 초기 년도 설정값
     *         - targetMonth : 초기 월 설정값
     *
    **/
    @AuraEnabled
    public static DataWrapper doInit() {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();

        try {
            User objUser = [
                SELECT  Id, EmployeeNumber, HeadOffice__c, SU__c, Team__c
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
            ];
            objWrapper.objUser = objUser;

            objWrapper.listSelectStatus = CommonUtil.getPickListValues('ActivityReport__c', 'ApprovalStatus__c', false);
            objWrapper.listSelectHeadOffice = CommonUtil.getPickListValues('User', 'HeadOffice__c', false);
            objWrapper.mapSelectSU = CommonUtil.getDependentPicklistValues(User.SU__c); 

            // Dafault 선택 년도 및 월 계산
            Date targetDate = Date.today().day() > 10 ? Date.today() : Date.today().addMonths(-1);  
            String targetYear = String.valueOf(targetDate.year());
            
            // Dafault 선택 년도 및 선택목록에 표시될 년도 셋팅
            List<Map<String,String>> listYear = new List<Map<String,String>>();
            Integer seqYear = Date.today().year() - 4;
            System.debug( 'targetYear :: ' + targetYear);
            System.debug( 'seqYear :: ' + seqYear);
            while ( seqYear <=  Date.today().year()) {
                listYear.add(new Map<String, String>{
                    'label' => String.valueOf(seqYear) + '년',
                    'value' => String.valueOf(seqYear),
                    'selected' => targetDate.year() == seqYear ? 'true' : 'false'
                });
                seqYear++;
            }
            objWrapper.listYear = listYear;
            objWrapper.targetYear = targetYear;
            
            // 선택목록 표시될 월 셋팅 (Default 선택 월은 전체)
            List<Map<String,String>> listMonth = new List<Map<String,String>>();
            Integer seqMonth = 1; 
            
            listMonth.add(new Map<String, String>{
                'label' => '전체',
                'value' => 'none',
                'selected' => 'true'
            });

            while ( seqMonth < 13 ) {
                listMonth.add(new Map<String, String>{
                    'label' => String.valueOf(seqMonth) + '월',
                    'value' => String.valueOf(seqMonth),
                    'selected' => 'false'
                });
                seqMonth++;
            }
            objWrapper.listMonth = listMonth;
            objWrapper.targetMonth = 'none';

        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    
    /**
     * 주유비 정산 전송이력 데이터 조회
     * 
     * @params Map<String, String> mapParam
     *         - selectedYear : 선택된 년도 정보
     *         - selectedMonth : 선택된 월 정보
     *         - selectedStatus : 선택된 제출상태 코드
     *         - selectedHeadOffice : 선택된 사업부 코드
     *         - selectedSU : 선택된 SU 코드
     * @return DataWrapper objWrapper
     *         - listTargetId : 품의이력 SFDC ID 리스트
     *         - strStatus : 조회 성공/실패 여부
     *         - strMessage : 조회 실패시 에러메세지
     *
    **/
    @AuraEnabled
    public static SearchWrapper doGetTargetData(Map<String, String> mapParam) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        SearchWrapper objWrapper = new SearchWrapper();
    
        String strTargetYear = String.valueOf(mapParam.get('selectedYear'));
        String strTargetMonth = String.valueOf(mapParam.get('selectedMonth'));

        try {
            System.debug('selectedHeadOffice :: ' + String.valueOf(mapParam.get('selectedHeadOffice')));
            System.debug('selectedSU :: ' + String.valueOf(mapParam.get('selectedSU')));

            // 선택된 파라미터를 바탕으로 대상 데이터 쿼리
            String strQuery = '';
            strQuery += '    SELECT  Id, RegUserName__c, RegUserNumber__c, Year__c, Month__c, DocURL__c,  ';
            strQuery += '            RegUserTeamCode__c, RegUserSUCode__c, totalAmount__c, totalHeadcount__c,  ';
            strQuery += '            fm_ApprovalStatusInfo__c, fm_RecentApprovalInfo__c ';
            strQuery += '    FROM    DecisionProcess__c   ';
            strQuery += '    WHERE   year__c = \''+ strTargetYear+'\'';
            
            if(strTargetMonth <> null && strTargetMonth <> 'none') {
                strQuery += '    AND     month__c = \''+ strTargetMonth+'\'';
            }

            if(mapParam.get('selectedHeadOffice') <> null && mapParam.get('selectedHeadOffice') <> 'none') {
                strQuery += '    AND     RegUserHeadOfficeCode__c = \''+mapParam.get('selectedHeadOffice')+'\'';
            }

            if(mapParam.get('selectedSU') <> null && mapParam.get('selectedSU') <> 'none') {
                strQuery += '    AND     RegUserSUCode__c = \''+mapParam.get('selectedSU')+'\'';
            }

            System.debug('strQuery :: ' + strQuery);

            Map<Id, DecisionProcess__c> mapDecisionProcess = new Map<Id, DecisionProcess__c>( (List<DecisionProcess__c>) Database.query(strQuery));
            objWrapper.listTargetId = mapDecisionProcess.keyset();

        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    
    /**
     * 주유비 정산 탭 전송이력 전자결재 번호 변환 (재무시스템 문서번호 -> 전자결재 문서번호 변환 I/F 후 저장 )
     * 
     * @params String targetId : 전자결재 문서 조회 대상 ID
     * @return DataWrapper objWrapper
     *         - strStatus : 성공/실패 여부
     *         - strMessage : 실패시 에러메세지
     *
    **/
    @AuraEnabled
    public static SearchWrapper doUpdateDocId(String targetId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        SearchWrapper objWrapper = new SearchWrapper();

        try {
            // 품의이력 대상 조회
            List<DecisionProcess__c> listDecisionProcess = [
                SELECT  Id, APPV_NO__c
                FROM    DecisionProcess__c
                WHERE   Id =: targetId
                AND     APPV_NO__c != ''
                AND     DocId__c =''
            ];

            // I/F 진행
            if( !listDecisionProcess.isEmpty()){
                DecisionProcess__c objDecisionProcess = listDecisionProcess[0];
                // 파라미터 설정
                Map<String,String> objInput = new Map<String,String>();
                objInput.put('opcode', 'EC003');    
                objInput.put('COM_CD', 'FW00');    
                objInput.put('APPV_NO', objDecisionProcess.APPV_NO__c);    

                // I/F 실행
                IFUtil ifutilWrapper = new IFUtil('IF_SFDC_EACCT_INFO_VRC');
                
                String strJsonRequestBody = JSON.serialize(objInput);
                HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);

                system.debug(' doUpdateDocId response.getStatusCode() ::: ' + response.getStatusCode() );

                // I/F 성공 시 
                if ( response.getStatusCode() == 200  ){
                    system.debug(' doUpdateDocId response.getBody() ::: ' + response.getBody() );
                    Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
                    // 반환 시 에러코드 발생한 경우 에러메세지 
                    if ( resultMap.get('ERR_CD') == 'E') {
                        strStatus = 'ERROR';
                        strMessage = '[I/F Error] ::: ['+resultMap.get('err_cd')+'] '+resultMap.get('err_msg_ctt');
                        system.debug( 'ERROR ::: ['+resultMap.get('err_cd')+'] '+resultMap.get('err_msg_ctt'));
                    }
                    // 반환 시 정상적인 경우 해당 품의이력에 전자결재 문서번호 저장 
                    else {
                        DecisionProcess__c objTarget = new DecisionProcess__c();
                        objTarget.Id = objDecisionProcess.Id;
                        objTarget.DocId__c =  String.valueOf(resultMap.get('DOC_ID'));
                        update objTarget;
                    }
                }
                // I/F 실패 시 에러메세지
                else {
                    strStatus = 'ERROR';
                    strMessage = '[I/F Error] ::: [' + response.getStatusCode() + '] 서버접속 실패';
                    system.debug( 'ERROR ::: [' + response.getStatusCode() + '] 서버접속 실패');
                }
            }
        // 기타 실패 시 에러메세지
        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    
    /**
     * 주유비 정산 탭 전송이력 전자결재 문서 상태 업데이트 
     * 
     * @params String targetId : 전자결재 문서 조회 대상 ID
     * @return DataWrapper objWrapper
     *         - strStatus : 성공/실패 여부
     *         - strMessage : 실패시 에러메세지
     *
    **/
    @AuraEnabled
    public static SearchWrapper doUpdateDocState(String targetId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        SearchWrapper objWrapper = new SearchWrapper();

        // 품의이력 대상 조회
        List<DecisionProcess__c> listDecisionProcess = [
            SELECT  Id, Name, DocId__c, DocStatus__c, totalLineCount__c, approvedCount__c, 
                    approvedUserName__c, approvedUserType__c, approvedDate__c, approvedUserCode__c
            FROM    DecisionProcess__c
            WHERE   Id =: targetId
        ];

        // I/F 진행
        List<DecisionProcess__c> listTarget = new List<DecisionProcess__c>();
        if( !listDecisionProcess.isEmpty()){
            // 파라미터 설정
            DecisionProcess__c objDecisionProcess = listDecisionProcess[0];
            Map<String,String> objInput = new Map<String,String>();
            objInput.put('doc_id', objDecisionProcess.DocId__c);    

            // I/F 실행
            IFUtil ifutilWrapper = new IFUtil('IF_SFDC_IFRESH_INFO_APPROVAL');
            String strJsonRequestBody = JSON.serialize(objInput);
            HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);

            // I/F 성공 시 
            if ( response.getStatusCode() == 200  ){

                system.debug(' response.getStatusCode() ::: ' + response.getStatusCode() );
                system.debug(' response.getBody() ::: ' + response.getBody() );
                Map<String, Object> resultMap = new Map<String, Object>();
                
                // 반환 데이터가 SFDC 형태로 변환, 정상적이지 않은 경우 에러 메세지
                try{
                    resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
                } catch (Exception e) {
                    objWrapper.strStatus = 'ERROR';
                    objWrapper.strMessage = '[I/F Error] ::: 전자결재 서버접속 실패';
                    system.debug( '[I/F Error] :::  전자결재 서버접속 실패');
                    return objWrapper;
                }
                // 반환 시 에러코드 발생한 경우 에러메세지 
                if ( resultMap.get('err_cd') == '실패') {
                    // 프로세스 종료 
                    strStatus = 'ERROR';
                    strMessage = '[I/F Error] ::: ['+resultMap.get('err_cd')+'] '+resultMap.get('err_msg_ctt');
                    system.debug( '[I/F Error] ::: ['+resultMap.get('err_cd')+'] '+resultMap.get('err_msg_ctt'));
                }
                // 반환 시 정상적인 경우 변경된 상태값으로 저장
                else {
                    system.debug( 'check doc_state ::: ' + resultMap.get('doc_state'));
                    system.debug( 'check url ::: ' + resultMap.get('url'));
                    system.debug( 'check approval_line ::: ' + resultMap.get('approval_line'));
                    List<Object> listLine = (List<Object>) resultMap.get('approval_line');

                    String DocStatus = String.valueOf(resultMap.get('doc_state'));
                    if (DocStatus == '' ) DocStatus = '임시저장';
                    Integer approvedCount = 0;
                    Integer totalLineCount = listLine != null ? listLine.size() : 0;
                    String approvedUserName = '';
                    String approvedUserType = '';
                    String approvedDate = '';
                    String approvedUserCode = '';         
                    
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

                    // 값이 바뀌어 있는 경우에만 update 하도록 처리
                    if ( 
                        objDecisionProcess.DocStatus__c != DocStatus || 
                        objDecisionProcess.approvedCount__c != approvedCount || 
                        objDecisionProcess.approvedUserName__c != approvedUserName || 
                        objDecisionProcess.approvedUserType__c != approvedUserType || 
                        objDecisionProcess.approvedDate__c != approvedDate || 
                        objDecisionProcess.approvedUserCode__c != approvedUserCode ||
                        objDecisionProcess.totalLineCount__c != totalLineCount
                    )
                    {
                        DecisionProcess__c objTarget = new DecisionProcess__c();
                        objTarget.Id = objDecisionProcess.Id;
                        objTarget.DocStatus__c = DocStatus;
                        objTarget.approvedCount__c = approvedCount;
                        objTarget.approvedUserName__c = approvedUserName;
                        objTarget.approvedUserType__c = approvedUserType;
                        objTarget.approvedDate__c = approvedDate;
                        objTarget.approvedUserCode__c = approvedUserCode;
                        objTarget.totalLineCount__c = totalLineCount;
                        listTarget.add(objTarget);
                    }
                }

                if ( !listTarget.isEmpty() ) {
                    System.debug(' ::: listTargetDecisionProcess  ::: ');
                    System.debug( listTarget);
                    System.debug(' :::::::::::::::::::::::::::::::::: ');
                    update listTarget;
                }
            }
            // I/F 실패 시 에러메세지
            else {
                strStatus = 'ERROR';
                strMessage = '[I/F Error] ::: [' + response.getStatusCode() + '] 서버접속 실패';
                system.debug( '[I/F Error] ::: [' + response.getStatusCode() + '] 서버접속 실패');
            }
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    
    /**
     * 주유비 정산 탭 전송이력 데이터 조회
     * 
     * @params String listTargetId : 품의이력 조회 대상 ID 리스트
     * @return DataWrapper objWrapper
     *         - listSearchLineWrapper : 조회 결과 리스트
     *         - strStatus : 성공/실패 여부
     *         - strMessage : 실패시 에러메세지
     *
    **/
    @AuraEnabled
    public static SearchWrapper getDataTable(List<String> listTargetId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        SearchWrapper objWrapper = new SearchWrapper();
        List<SearchLineWrapper> listSearchLineWrapper = new List<SearchLineWrapper>();

        Map<String, String> mapSUToLabel = CommonUtil.getMapPickListValuetoLabel('User', 'SU__c');
        Map<String, String> mapTeamToLabel = CommonUtil.getMapPickListValuetoLabel('User', 'Team__c');

        try {
            // 대상 리스트 조회
            List<DecisionProcess__c> listDecisionProcess = [
                SELECT  Id, RegUserName__c, RegUserNumber__c, Year__c, Month__c, DocURL__c, 
                        RegUserTeamCode__c, RegUserSUCode__c, totalAmount__c, totalHeadcount__c,
                        fm_ApprovalStatusInfo__c, fm_RecentApprovalInfo__c
                FROM    DecisionProcess__c
                WHERE   Id =: listTargetId
            ];

            // 화면 출력을 위해 Wrapper 형태로 변환
            for ( DecisionProcess__c objDecisionProcess : listDecisionProcess ){      
                SearchLineWrapper objSearchWrapper = new SearchLineWrapper();
                objSearchWrapper.RegUser = objDecisionProcess.RegUserName__c +' ('+objDecisionProcess.RegUserNumber__c+')';
                objSearchWrapper.YearAndMonth = objDecisionProcess.Year__c + '년 ' + objDecisionProcess.Month__c +'월';
                objSearchWrapper.TeamLabel = mapTeamToLabel.get(objDecisionProcess.RegUserTeamCode__c);
                objSearchWrapper.SULabel = mapSUToLabel.get(objDecisionProcess.RegUserSUCode__c); 
                objSearchWrapper.totalAmount = String.valueOf(objDecisionProcess.totalAmount__c);
                objSearchWrapper.totalHeadcount = String.valueOf(objDecisionProcess.totalHeadcount__c)+'명' ;
                objSearchWrapper.ApprovalStatusInfo = objDecisionProcess.fm_ApprovalStatusInfo__c;
                objSearchWrapper.RecentApprovalInfo = objDecisionProcess.fm_RecentApprovalInfo__c;
                objSearchWrapper.DocURL = objDecisionProcess.DocURL__c;
                listSearchLineWrapper.add(objSearchWrapper);
            }
        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.listSearchLineWrapper = listSearchLineWrapper;
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    
    public class DataWrapper {
        @AuraEnabled
        public String strStatus {get;set;}
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public List<SearchWrapper> listSearchWrapper {get;set;}
        @AuraEnabled
        public Map<String,Set<String>> mapActivityReportId {get;set;}
        @AuraEnabled
        public User objUser {get;set;}
        @AuraEnabled
        public String strHeadOffice {get;set;}
        @AuraEnabled
        public String strSU {get;set;}
        @AuraEnabled
        public String strTeam {get;set;}
        // SearchData
        @AuraEnabled
        public String targetYear {get;set;}
        @AuraEnabled
        public String targetMonth {get;set;}
        @AuraEnabled
        public List<Map<String,String>> listYear {get;set;}
        @AuraEnabled
        public List<Map<String,String>> listMonth {get;set;}
        @AuraEnabled
        public List<Map<String, String>> listSelectStatus {get;set;}
        @AuraEnabled
        public List<Map<String, String>> listSelectHeadOffice {get;set;}
        @AuraEnabled
        public Map<String, List<Map<String, String>>> mapSelectSU {get;set;}        

    }

    public class SearchWrapper {
        @AuraEnabled
        public String strStatus {get;set;}
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public List<SearchLineWrapper> listSearchLineWrapper {get;set;}
        @AuraEnabled
        public Set<Id> listTargetId {get;set;}
    }

    public class SearchLineWrapper {
        @AuraEnabled
        public String SULabel {get;set;}
        @AuraEnabled
        public String TeamLabel {get;set;}
        @AuraEnabled
        public String RegUser {get;set;}
        @AuraEnabled
        public String YearAndMonth {get;set;}
        @AuraEnabled
        public String totalAmount {get;set;}
        @AuraEnabled
        public String totalHeadcount {get;set;}
        @AuraEnabled
        public String ApprovalStatusInfo {get;set;}
        @AuraEnabled
        public String RecentApprovalInfo {get;set;}
        @AuraEnabled
        public String DocUrl {get;set;}
    }
}