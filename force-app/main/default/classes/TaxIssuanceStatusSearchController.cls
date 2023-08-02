public with sharing class TaxIssuanceStatusSearchController {

    @AuraEnabled
    public static void init(String recordId){
    
    }

    // getColumns 메소드 만들어서
 
    @AuraEnabled
    public static List<TaxWrapper> search(){
        List<TaxWrapper> result = new List<TaxWrapper>();
        String strRequestBody = '';
        String responseBody = exampleCallout(strRequestBody); // 인터페이스 콜아웃 호출후 response 받았다고 가정하는 메소드 return은 String옴
        result = (List<TaxWrapper>)JSON.deserialize(responseBody,  List<TaxWrapper>.class); // String -> Wrapper Class 형태로 변경

        return result;
    }

    
    public class TaxWrapper{
        @AuraEnabled public String id{get;set;}
        @AuraEnabled public Date   wDate{get;set;}
        @AuraEnabled public String typeCode{get;set;}
        @AuraEnabled public String type{get;set;}
        @AuraEnabled public String orderNo{get;set;}
        @AuraEnabled public String documentNo{get;set;}
        @AuraEnabled public String sellerCode{get;set;}
        @AuraEnabled public String sellerName{get;set;}
        @AuraEnabled public String managerCode{get;set;}
        @AuraEnabled public String managerName{get;set;}
        @AuraEnabled public String suCode{get;set;}
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

        for(String t : typeList)
        {
            i++;
            String id = String.valueOf(i);

            DummyWrapper dw = new DummyWrapper();
            dw.id          = id; 
            dw.wDate        = system.today(); 
            dw.typeCode    = '유형 ' + t; 
            dw.type        = 'Type ' + t; 
            dw.orderNo     = 'ORDER-' + t; 
            dw.documentNo  = 'DOC-' + t; 
            dw.sellerCode  = 'SELLER-' + t; 
            dw.sellerName  = '판매처-' +t; 
            dw.managerCode = 'MANAGER-'+t; 
            dw.managerName = '관리처-'+t; 
            dw.suCode      = 'SU-'+t; 

            DummyWrapperList.add(dw);
        }

        return JSON.serialize(DummyWrapperList);
    }

    //인터페이스로 가정 (안봐도됨)
    public class DummyWrapper{
        public String id;
        public Date   wDate;
        public String typeCode;
        public String type;
        public String orderNo;
        public String documentNo;
        public String sellerCode;
        public String sellerName;
        public String managerCode;
        public String managerName;
        public String suCode;
    }
}