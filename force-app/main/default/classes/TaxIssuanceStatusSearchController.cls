/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 08-03-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-02-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class TaxIssuanceStatusSearchController {

    /**
     * @description 세금계산서 발행 Tab의 From발행일자을 달의 첫날로 Setting
     * 
     * @return      `Date`
     */
    @AuraEnabled
    public static Date getTodayDate(){
        Date result = System.today();
        
        return result;
    }
    /**
     * @description 세금계산서 발행 Tab의 to발행일자 오늘날짜로 Setting
     *
     * @return      `Date`
     */
    @AuraEnabled
    public static Date getFirstDayOfMonthDate() {
        Date today = System.today();
        Integer year = today.year();
        Integer month = today.month();
        Date result = Date.newInstance(year, month, 1);

        return result;
    }
    
    /**
     * @description callout 호출 가정
     *
     * @return      `List<TaxWrapper>`
     */
    @AuraEnabled
    public static List<TaxWrapper> search(){
        List<TaxWrapper> result = new List<TaxWrapper>();
        String strRequestBody = '';
        String responseBody = exampleCallout(strRequestBody); // 인터페이스 콜아웃 호출후 response 받았다고 가정하는 메소드 return은 String옴
        result = (List<TaxWrapper>)JSON.deserialize(responseBody,  List<TaxWrapper>.class); // String -> Wrapper Class 형태로 변경

        return result;
    }
    /**
     * @description  interface로 데이터 보내기
     *
     * @param params 
     * @return       `String`
     */
    @AuraEnabled
    public static String calloutInterface(String params){
        System.debug('Received Params: ' + params);
        
        return null;
    }
    
    public class TaxWrapper{
        @AuraEnabled public String  id {get;set;}
        @AuraEnabled public Integer index {get;set;}
        @AuraEnabled public String  taxStatus {get;set;}
        @AuraEnabled public String  errMessage {get;set;}
        @AuraEnabled public String  taxReportStatus {get;set;}
        @AuraEnabled public String  privousDocNum {get;set;}
        @AuraEnabled public String  electronicDocNum {get;set;}
        @AuraEnabled public String  customerCode {get;set;}
        @AuraEnabled public String  customerName {get;set;}
        @AuraEnabled public String  teamName {get;set;}
        @AuraEnabled public String  managerMA {get;set;}
        @AuraEnabled public Date    publishDate {get;set;}
        @AuraEnabled public Date    createdDate {get;set;}
        @AuraEnabled public String  supplyValue {get;set;}
        @AuraEnabled public String  taxAmount {get;set;}
        @AuraEnabled public String  totalMount {get;set;}
        @AuraEnabled public String  aspVendor {get;set;}
        @AuraEnabled public String  billType {get;set;}
        @AuraEnabled public String  isCancel {get;set;}
    }


    /**
     * @description : 임의로 생성한 데이터를 리턴하는 메소드(안봐도됨)
     * @return  `List<DummyWrapper>`
     */
    public static String exampleCallout(String strRequestBody){
        // Map<String, List<String>> endcomment = new Map<String, List<String>>();
        // endcomment.put('type', typeList);

        List<String> typeList = new List<String>{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 
                                                 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 
                                                 'U', 'V', 'W', 'X', 'Y', 'Z'};


        List<DummyWrapper> DummyWrapperList = new List<DummyWrapper>();
        Integer i = 1;

        for(String t : typeList) {
            String id = String.valueOf(i);

            DummyWrapper dw = new DummyWrapper();
            dw.id                   =       id;
            dw.index                =       i;
            dw.taxStatus            =       t + '세금계산서상태';
            dw.errMessage           =       t + '에러메세지';
            dw.taxReportStatus      =       t + '국세청신고상태';
            dw.privousDocNum        =       t + '이전문서번호';
            dw.electronicDocNum     =       t + '전자문서번호';
            dw.customerCode         =       t + '고객코드';
            dw.customerName         =       t + '고객사명';
            dw.teamName             =       t + '팀명';
            dw.managerMA            =       t + '담당MA';
            dw.publishDate          =       System.today();
            dw.createdDate          =       System.today();
            dw.supplyValue          =       t + '공급가액';
            dw.taxAmount            =       t + '세액';
            dw.totalMount           =       t + '총액';
            dw.aspVendor            =       t + 'ASP업체';
            dw.billType             =       t + '계산서구분';
            dw.isCancel             =       t + '취소여부';
            i++;

            DummyWrapperList.add(dw);
        }

        return JSON.serialize(DummyWrapperList);
    }

    //인터페이스로 가정 (안봐도됨)
    public class DummyWrapper{
        public String  id;
        public Integer index;                // No 
        public String  taxStatus;             // 세금계산서 상태
        public String  errMessage;           // 에러메세지
        public String  taxReportStatus;      // 국세청신고상태
        public String  privousDocNum;        // 이전문서번호
        public String  electronicDocNum;     // 전자문서번호
        public String  customerCode;         // 고객코드 
        public String  customerName;         // 고객사명 
        public String  teamName;             // 팀명 
        public String  managerMA;            // 담당MA 
        public Date    publishDate;          // 발행일 
        public Date    createdDate;          // 작성일 
        public String  supplyValue;          // 공급가액 
        public String  taxAmount;            // 세액 
        public String  totalMount;           // 총액
        public String  aspVendor;            // ASP업체
        public String  billType;             // 계산서구분
        public String  isCancel;             // 취소여부 (이건 받는값은 아닌듯??)
    }
}