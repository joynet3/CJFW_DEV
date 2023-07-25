/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
public class IF_SFDC_SAP_REC_STOCK {

    public IF_SFDC_SAP_REC_STOCK() {}

    callCjCkSoapVer_2.sapCkInParameter inputData = new callCjCkSoapVer_2.sapCkInParameter();

    public class Input {
        public List<Stock> header;
    }

    public class Output {
        public Result result;
    }

    public class Result {
        public String resultCode;
        public String resultMessage;
        public String soapCallResult;
    }

    public class Stock{
        public String ZTIMS;
        public String STOCKKEY;
        public String MATNR;
        public String MAT_TYP;
        public String MAKTX;
        public String WERKS;
        public String LGORT;
        public String BATCH;
        public String MENGE;
        public String MENGE_KG;
        public String P_PSMNG;
        public String U_PSMNG;
        public String MEINS;
    }

    public Output callOut() {
            
        List<Stock__C> stockList = new List<Stock__C>(); 

        Result objResult = new Result();
        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '데이터가 성공적으로 수신 되었습니다.';
        String result = '';

        try {

            inputData.requestMsg = '{"IF_ID" : "CK0005"}';
            callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort soap = new callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort();
            result = soap.callSapCkProcedure(inputData);
            System.debug('=======================result:::'+result);

            if(result == '' || result == null) {
                strStatus = 'ERROR';
                strCode = '0003';
                strMessage = '수신받을 데이터가 없습니다.';
            }else {
                Input input = (Input)JSON.deserialize(result, Input.class);

                if (input.header == null || input.header.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = '수신받을 데이터가 없습니다.';
                }else {
                    // Map<String, String> mapWerks = CommonUtil.getMapPickListLabel('Stock__C', 'WERKS__c');
                    // Map<String, String> mapLgort = CommonUtil.getMapPickListLabel('Stock__C', 'LGORT__c');
                    // Map<String, String> mapMatTyp = CommonUtil.getMapPickListLabel('Stock__C', 'MAT_TYP__c');
                    Map<String, String> mapMeins = CommonUtil.getMapPickListLabel('Stock__C', 'MEINS__c');

                    if (input.header <> null && input.header.size() > 0) {
                        for (Integer i = 0; i < input.header.size(); i++) {
                            Stock__C obj = new Stock__C();
                            obj.Name = input.header[i].MAKTX;
                            obj.ZTIMS__c = input.header[i].ZTIMS;
                            obj.STOCKKEY__c = input.header[i].STOCKKEY;
                            obj.MATNR__c = input.header[i].MATNR;
                            obj.MAT_TYP__c = input.header[i].MAT_TYP;
                            obj.MAKTX__c = input.header[i].MAKTX;
                            obj.WERKS__c = input.header[i].WERKS;
                            obj.LGORT__c = input.header[i].LGORT;
                            obj.BATCH__c = input.header[i].BATCH;
                            obj.MENGE__c = Decimal.valueOf(input.header[i].MENGE);
                            obj.MENGE_KG__c = Decimal.valueOf(input.header[i].MENGE_KG);
                            obj.P_PSMNG__c = Decimal.valueOf(input.header[i].P_PSMNG);
                            obj.U_PSMNG__c = Decimal.valueOf(input.header[i].U_PSMNG);
                            obj.MEINS__c = input.header[i].MEINS;
                            obj.isSystemJob__c = true;
                            stockList.add(obj);
                        }
                        System.debug(stockList);
                        upsert stockList STOCKKEY__c;
                    }    
                }
            }
        } catch (Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage(); 
            System.debug(strMessage);
        } finally {
            objResult.resultCode = strCode;
            objResult.resultMessage = strMessage;
            objResult.soapCallResult = result;

            objOutput.result = objResult;

            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'message:::' + strMessage + ':::result:::' + result;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = inputdata.requestMsg;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);

            IFUtil objIF = new IFUtil('IF_SFDC_SAP_REC_STOCK');
            objIF.setLog(LogWrapper);
        }
        return objOutput;
    }
}