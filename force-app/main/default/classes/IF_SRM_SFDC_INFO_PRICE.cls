/************************************************************************************
 * File Name   		: IF_SRM_SFDC_INFO_PRICE.cls
 * Author	  		: TaeJin.Ahn
 * Date				: 2022.11.21
 * Tester	  		: IF_SRM_SFDC_INFO_PRICE_test.cls
 * Description 		: 기준매입가정보 API
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.11.21      TaeJin.Ahn      Create
 * 1.0      2022.12.23      Minje.Kim       Price Intialize added (IF_SRM_SFDC_INFO_PRICE_INIT_ba)  
*************************************************************************************/

@RestResource(urlMapping='/ifresh/product/price/info')
global without sharing class IF_SRM_SFDC_INFO_PRICE {
    global IF_SRM_SFDC_INFO_PRICE() {}

    global class Input {
        public List<Item> data;
        public String transaction_Id;
        public String total_page;
        public String page_no;
        public String is_last;
    }

    global class Item {
        public String gd_nm;
        public String gd_no;
        public String lgs_ctr_nm;
        public String lgs_ctr_id;        
        public String aply_stt_ymd;
        public String aply_end_ymd;
        public String crit_buy_prc;
        public String reg_dt;
        public String upd_dt;
        public String del_yn;
        public String us_yn;
        public String aply_yn;
    }

    global class Output {
        public String err_cd;
        public String err_msg_ctt;

        /*
        public Result result;
        public ResultData resultData;
        */
    }

    global class Result {
        public String resultCode;
        public String resultMessage;
    }

    global class ResultData {
    }

    @HttpPost
    global static Output doPost() {

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Data has successfully upserted.';

        /*
        Result objResult = new Result();
        ResultData resultData = new ResultData();
        */

        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String requestBody = '';

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            LogWrapper.requestBody = requestBody;   
            if(requestBody == '' || requestBody == null) {
                strStatus = 'ERROR';
                strCode = '-1';
                strMessage = 'request body value does not exist';
            }else {
                Input input = (Input)JSON.deserialize(requestBody,  Input.class);
                List<IF_SRM_SFDC_INFO_PRICE__c> insertDummyList = new List<IF_SRM_SFDC_INFO_PRICE__c>();
                /*
                List<PricebookEntry> upsertObjList = new List<PricebookEntry>();
                Set<String> productCodeSet = new Set<String>();
                */
                if (input.data == null || input.data.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'item list is empty';
                }else{
                    /*
                    Datetime dt = Datetime.now();
                    String month = '';
                    system.debug(dt.format('MMM'));
                    
                    for (Item item : itemList) {
                        productCodeSet.add(item.lgs_ctr_id + '_' + item.gd_no);
                    }

                    if (Integer.valueOf(dt.format('dd')) < 16) {
                        month = 'Early' + dt.format('MMM') + '__c';
                    }else {
                        month = 'Late' + dt.format('MMM') + '__c';
                    }

                    System.debug('month: ' + month);
                    Map<String, PricebookEntry> productCodeMap = new Map<String, PricebookEntry>();
                    Map<String, Id> product2IdMap = new Map<String,Id>();
                    
                    List<PricebookEntry> productCodeList = [
                        SELECT Id, ProductCode, EarlyJan__c,LateJan__c,EarlyFeb__c,LateFeb__c,EarlyMar__c,LateMar__c,EarlyApr__c,LateApr__c,EarlyMay__c,LateMay__c,EarlyJun__c,LateJun__c,EarlyJul__c,LateJul__c,EarlyAug__c,LateAug__c,EarlySep__c,LateSep__c,EarlyOct__c,LateOct__c,EarlyNov__c,LateNov__c,EarlyDec__c,LateDec__c
                        FROM PricebookEntry
                        WHERE ProductCode IN:productCodeSet
                    ];

                    List<Product2> product2Obj = [
                        SELECT Id, ProductCode
                        FROM Product2
                        WHERE ProductCode IN:productCodeSet
                    ];

                    Pricebook2 pricebookId = [
                        SELECT Id
                        FROM Pricebook2
                        WHERE IsStandard = true LIMIT 1
                    ];
                    for (PricebookEntry obj : productCodeList) {
                        productCodeMap.put(obj.ProductCode, obj);
                    }

                    for (Product2 obj : product2Obj) {
                        product2IdMap.put(obj.ProductCode, obj.Id);
                    }
                    */
                    for (Item item : input.data) {
                        IF_SRM_SFDC_INFO_PRICE__c objDummy = new IF_SRM_SFDC_INFO_PRICE__c();
                        objDummy.transactionId__c = input.transaction_Id;
                        objDummy.gd_nm__c = item.gd_nm;
                        objDummy.gd_no__c = item.gd_no;
                        objDummy.lgs_ctr_nm__c = item.lgs_ctr_nm;
                        objDummy.lgs_ctr_id__c = item.lgs_ctr_id;                        
                        objDummy.aply_stt_ymd__c = item.aply_stt_ymd;
                        objDummy.aply_end_ymd__c = item.aply_end_ymd;
                        objDummy.crit_buy_prc__c = item.crit_buy_prc;
                        objDummy.reg_dt__c = item.reg_dt;
                        objDummy.upd_dt__c = item.upd_dt;
                        objDummy.del_yn__c = item.del_yn;
                        objDummy.us_yn__c = item.us_yn;
                        objDummy.aply_yn__c = item.aply_yn;

                        insertDummyList.add(objDummy);
                    }
                }
                if (insertDummyList <> null && insertDummyList.size() > 0) {
                    insert insertDummyList;

                    if(Boolean.valueOf(input.is_last)) {
                        Integer count = 50;
                        Datetime now = Date.today();

                        if(Test.isRunningTest()) {
                            count = 200;
                            now = Date.valueOf('2022-12-16');
                        }
                        String dateNow = now.format('dd');
                        String MonthNow = now.format('MMM');
                
                        if ( datenow == '1' || datenow =='16' ){
                            MonthNow = Integer.valueOf(datenow) < 16 ? 'Early' + MonthNow + '__c' : 'Late' + MonthNow + '__c'; 
                            IF_SRM_SFDC_INFO_PRICE_INIT_ba ba = new IF_SRM_SFDC_INFO_PRICE_INIT_ba(input.transaction_Id, MonthNow);
                            Database.executeBatch(ba, count);
                        }
                        else {
                            IF_SRM_SFDC_INFO_PRICE_ba ba = new IF_SRM_SFDC_INFO_PRICE_ba(input.transaction_Id);
                            Database.executeBatch(ba, count);
                        }
                    }
                }
                // insert insertDummyList;
            }
        } catch (Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       

            System.debug('========================> strMessage : '+strMessage);
        }
        /*
        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        
        objOutput.resultData = resultData;
        objOutput.result = objResult;
        */

        // 2022-11-11 Response 변경
        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strMessage;        
        

        LogWrapper.status = strStatus;
        LogWrapper.resultCode = strCode;
        LogWrapper.resultMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestBody = requestBody;
        LogWrapper.responseBody = JSON.serialize(objOutput);
        
        IFUtil objIF = new IFUtil('IF_SRM_SFDC_INFO_PRICE');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}