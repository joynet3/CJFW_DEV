/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 05-27-2022
 * @last modified by  : 안태진
**/
@RestResource(urlMapping= '/sap/info/stock')
global without sharing class IF_SAP_SFDC_INFO_STOCK {
    public IF_SAP_SFDC_INFO_STOCK() {}

    global class Input {
        public List<ZMMT2950> zmmtList;
    }

    global class Output {
        public Result result;
        public ResultData resultData;
    }

    global class Result {
        public String resultCode;
        public String resultMessage;
    }

    global class ResultData {
    }

    global class ZMMT2950{
        public String ztims;
        public String matnr;
        public String mat_typ;
        public String maktx;
        public String werks;
        public String lgort;
        public String batch;
        public String menge;
        public String menge_kg;
        public String p_psmng;
        public String u_psmng;
        public String meins;
    }

    @HttpPost
    global static Output doPost() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Data has been successfully inserted';

        Result objResult = new Result();
        ResultData resultData = new ResultData();

        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        List<Stock__C> stockList = new List<Stock__C>(); 

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
                Input input = (Input)JSON.deserialize(requestBody, Input.class);

                if (input.zmmtList == null || input.zmmtList.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'release_Hlist is null';
                }else {
                    // Map<String, String> mapWerks = CommonUtil.getMapPickListLabel('Stock__C', 'WERKS__c');
                    // Map<String, String> mapLgort = CommonUtil.getMapPickListLabel('Stock__C', 'LGORT__c');
                    // Map<String, String> mapMatTyp = CommonUtil.getMapPickListLabel('Stock__C', 'MAT_TYP__c');
                    Map<String, String> mapMeins = CommonUtil.getMapPickListLabel('Stock__C', 'MEINS__c');
                    Set<String> releaseNoSet = new Set<String>();

                    if (input.zmmtList <> null && input.zmmtList.size() > 0) {
                        for (Integer i = 0; i < input.zmmtList.size(); i++) {
                            Stock__C obj = new Stock__C();
                            // obj.ZTIMS__c = input.zmmtList.ztims;
                            obj.MATNR__c = input.zmmtList[i].matnr;
                            obj.MAT_TYP__c = input.zmmtList[i].mat_typ;
                            obj.MAKTX__c = input.zmmtList[i].maktx;
                            obj.WERKS__c = input.zmmtList[i].werks;
                            obj.LGORT__c = input.zmmtList[i].lgort;
                            obj.BATCH__c = input.zmmtList[i].batch;
                            obj.MENGE__c = Decimal.valueOf(input.zmmtList[i].menge);
                            // obj.MENGE_KG__c = Decimal.valueOf(input.zmmtList[i].menge_kg);
                            obj.P_PSMNG__c = Decimal.valueOf(input.zmmtList[i].p_psmng);
                            obj.U_PSMNG__c = Decimal.valueOf(input.zmmtList[i].u_psmng);
                            obj.MEINS__c = mapMeins.get(input.zmmtList[i].meins);
                            stockList.add(obj);
                        }
                            insert stockList;
                    }    
                }
            }
        } catch (Exception e){
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();
        }

        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        
        objOutput.resultData = resultData;
        objOutput.result = objResult;        

        LogWrapper.status = strStatus;
        LogWrapper.resultCode = strCode;
        LogWrapper.resultMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestBody = requestBody;
        LogWrapper.responseBody = JSON.serialize(objOutput);
        
        IFUtil objIF = new IFUtil('IF_SAP_SFDC_INFO_RELEASE');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}