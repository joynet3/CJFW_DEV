/*
* ==================================================================================
*   File Name   : DN_AddrSearchController.cls
*   Author      : Soyoung.Jung
*   Date        : 2019.04.02
*   Tester      : DN_AddrSearchController_Test.cls
*   Description : 행정안전부 도로명주소 검색API 호출
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2019.04.02    Soyoung.Jung    Create
*   1.1                   woojwon         공통 주소 저장 기능 추가
* ==================================================================================
*/

public with sharing class DN_AddrSearchController {
    
    //private static String sConfirmKey = 'TESTJUSOGOKR';
    /*
    private static String sConfirmKey = 'U01TX0FVVEgyMDIyMTEzMDE5NTQzNzExMzI3NTQ='; //신규로받은키
    private static String sReturnType = 'json';
    */
   
    /**
     * 주소정보 API 조회
     * 
     * @param sSearchKey : 조회 키워드
     * @param intCntPerPage : 현재 페이지
     * @param intCurrentPage : 페이지당 출력할 결과 Row 수
     * @return WrapperResponse : 조회된 결과
     *
    **/
    @AuraEnabled
    public static WrapperResponse doSearchAddress(String sSearchKey, Integer intCntPerPage, Integer intCurrentPage) {
        IF_RELAY_INFO__c objRelayInfo = IF_RELAY_INFO__c.getOrgDefaults();

        WrapperResponse objResponse = new WrapperResponse();

        // Interface parameter 생성
        DN_AddrSearch_wb.Input objInput = new DN_AddrSearch_wb.Input();
        objInput.confmKey       = objRelayInfo.AddressConfirmKey__c;
        objInput.keyword        = sSearchKey;
        objInput.resultType     = 'json';
        objInput.currentPage    = intCurrentPage;
        objInput.countPerPage   = intCntPerPage;

        // 생성 된 Interface parameter로 메소드 실행하고 인터페이스 결과 값 저장
        DN_AddrSearch_wb.Output objOutput = new DN_AddrSearch_wb.Output();
        objOutput = DN_AddrSearch_wb.getInstance().execute(objInput);
        System.debug('objOutput : ' + objOutput);

        // Lightning component에서 사용하기 위해 인터페이스 클래스와 AuraEnabled 클래스를 매핑하여 새로운 리스트 생성
        if(objOutput.results != null) {
            DN_AddrSearch_wb.Common objCommon = objOutput.results.common;

            objResponse.sErrorCode         = objCommon.errorCode;
            objResponse.sErrorMessage      = objCommon.errorMessage;
            objResponse.sTotalCount        = objCommon.totalCount;
            objResponse.intCurrentPage     = objCommon.currentPage;

            if(objCommon.errorCode == '0') {
                List<WrapperAddress> listWrapperAddress = new List<WrapperAddress>();
                for(DN_AddrSearch_wb.Address objAddress : objOutput.results.juso) {
                    listWrapperAddress.add(new WrapperAddress(objAddress));
                }

                objResponse.listWrapperAddress = listWrapperAddress; 
            }
        }

        return objResponse;
    }


    public class WrapperResponse {
        @AuraEnabled public String  sErrorCode      {get; set;} // 에러 코드
        @AuraEnabled public String  sErrorMessage   {get; set;} // 에러 메시지
        @AuraEnabled public String  sTotalCount     {get; set;} // 총 검색 데이터수
        @AuraEnabled public Integer intCurrentPage  {get; set;} // 페이지 번호

        @AuraEnabled public List<WrapperAddress> listWrapperAddress {get; set;}
    }

    public class WrapperAddress {
        @AuraEnabled public String sRoadAddr    {get; set;} // 전체 도로명 주소
        @AuraEnabled public String sJibunAddr   {get; set;} // 지번 주소
        @AuraEnabled public String sZipNo       {get; set;} // 우편 번호
        @AuraEnabled public String sSiName      {get; set;} // 시도 명
        @AuraEnabled public String sSggName     {get; set;} // 시군구 명
        @AuraEnabled public String sEmdName     {get; set;} // 읍면동 명
        @AuraEnabled public String sAddrDetail  {get; set;} // 상세주소
        @AuraEnabled public String sAddr        {get; set;} // 주소

        public WrapperAddress(DN_AddrSearch_wb.Address objAddress) {
            sRoadAddr  = objAddress.roadAddr;   
            sJibunAddr = objAddress.jibunAddr;
            sZipNo     = objAddress.zipNo;
            sSiName    = objAddress.siNm;
            sSggName   = objAddress.sggNm;
            sEmdName   = objAddress.emdNm;
          
            
        }
    }
    
    /**
     * 주소정보 저장
     * 
     * @param recordId : Object Record Id
     * @param sZipNo : 우편번호
     * @param sRoadAddr : 주소 정보
     * @param sAddrDetail : 상세주소 정보
     * @param objName : Object API Name
     * @param zipCodeField : 우편번호 Field
     * @param addressField : 주소 Field
     * @param addressDetailField : 상세주소 Field
     * @param dupConfirmStatus : 중복레코드 판단 상태값
     * 
     * @return WrapperResponse : 조회된 결과
     *
    **/
    @AuraEnabled
    public static Map<String, Object> doSave(String recordId, String sZipNo
                                , String sRoadAddr, String sAddrDetail
                                , String objName, String zipCodeField
                                , String addressField, String addressDetailField
                                , String dupConfirmStatus
                             ) {
    String dupMessage = '';
        try {
            System.debug('recordId : ' + recordId);

          
			sObject obj = Schema.getGlobalDescribe().get(objName).newSObject();
            obj.put('Id', recordId);
			obj.put(zipCodeField, sZipNo);
            obj.put(addressField, sRoadAddr);
            obj.put(addressDetailField, sAddrDetail);

            
            Database.update(obj, true);

        } catch (DMLException e) {            
            System.debug('e.getDmlMessage(0) : ' + e.getDmlMessage(0));
            System.debug('e.getDmlMessage(0) : ' + e.getDmlStatusCode(0));
            if ( e.getDmlStatusCode(0) == 'DUPLICATES_DETECTED'){
                if (dupConfirmStatus == 'N') {
                    dupConfirmStatus = 'Y';
                    dupMessage = e.getDmlMessage(0);
                } else {
                    dupConfirmStatus = 'S';
                    Database.DMLOptions dml = new Database.DMLOptions();
                    dml.DuplicateRuleHeader.allowSave = true;
                    sObject obj = Schema.getGlobalDescribe().get(objName).newSObject();
                    obj.put('Id', recordId);
                    obj.put(zipCodeField, sZipNo);
                    obj.put(addressField, sRoadAddr);
                    obj.put(addressDetailField, sAddrDetail);
                    Database.SaveResult sr = Database.update(obj, dml);
                }
            }
            else {
                throw new AuraHandledException(e.getDmlMessage(0));
            }
        } catch(Exception e) {
            System.debug('e.getMessage(0) : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        Map<String, Object> mapReturnValue = new Map<String, Object>{
            'dupConfirmStatus' => dupConfirmStatus,
            'dupMessage' => dupMessage
        };
        return mapReturnValue;
    }
    	
    /**
     * 주소정보 조회
     * 
     * @param recordId : Object Record Id
     * @param objName : Object API Name
     * @param zipCodeField : 우편번호 Field
     * @param addressField : 주소 Field
     * @param addressDetailField : 상세주소 Field
     * @return Map<String, Object>
     *          - listDesire : 조회결과
     *          - labelPostalCode : 우편번호 Label
     *          - labelAddress : 주소 Label
     *          - labelAddressDetail : 상세주소 Label
     *
    **/
    @AuraEnabled
    public static Map<String, Object> getInitData(String recordId
            , String objName
            , String zipCodeField
            , String addressField
            , String addressDetailField) {
        /*
         ACCOUNT listAcc = new ACCOUNT();
      		listAcc =[SELECT zipNo__c , RoadAddr__c, AddrDetail__c FROM ACCOUNT
				where id = :recordId] ;
        System.debug('aaaaa : '+listAcc.zipNo__c );
        */
          //String query = 'select   '+zipCodeField+','+addressField+','+addressDetailField+' from '+objName+' where Id=\'0010k00000ws5gVAAQ\'';
          String query = 'select   '+zipCodeField+','+addressField+','+addressDetailField+' from '+objName+' where Id=:recordId';
             
         sObject obj = Database.query(query);
            
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();

        List<String> listField = new List<String>{zipCodeField, addressField, addressDetailField};
        String labelPostalCode = '';
        String labelAddress = '';
        String labelAddressDetail = '';

        for (String fieldName: fieldMap.keySet()) {
            // system.debug('fieldName :: ' + fieldName );
            if(fieldName == zipCodeField ){
                labelPostalCode = fieldMap.get(fieldName).getDescribe().getLabel();
            }
            else if(fieldName == addressField){
                labelAddress = fieldMap.get(fieldName).getDescribe().getLabel();
            }
            else if(fieldName == addressDetailField){
                labelAddressDetail = fieldMap.get(fieldName).getDescribe().getLabel();
            }
        }

         Map<String, Object> mapReturnValue = new Map<String, Object>{
            'listDesire' => obj,
            'labelPostalCode' => labelPostalCode,
            'labelAddress' => labelAddress,
            'labelAddressDetail' => labelAddressDetail
        };
        return mapReturnValue;
       
    }

}