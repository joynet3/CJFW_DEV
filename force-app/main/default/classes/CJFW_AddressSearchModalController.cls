/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 08-28-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-28-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_AddressSearchModalController {
    /**
    * 주소정보 API 조회
    * 
    * @params sSearchKey : 조회 키워드
    * @params intCntPerPage : 현재 페이지
    * @params intCurrentPage : 페이지당 출력할 결과 Row 수
    * @return WrapperResponse : 조회된 결과
    *
    **/
   @AuraEnabled
   public static WrapperResponse doSearchAddress(String sSearchKey, Integer intCntPerPage, Integer intCurrentPage) {
       WrapperResponse objResponse = new WrapperResponse();

       IF_RELAY_INFO__c objRelayInfo = IF_RELAY_INFO__c.getOrgDefaults();

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
}