/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
public with sharing class IF_SFDC_SAP_SAND_STOCK {
    public IF_SFDC_SAP_SAND_STOCK() {}

    public class Output {
        public Result result;
    }

    public class Input{
        public List<headerList> header;
    }

    public class headerList{
        public String xmsgs;
        public String MAT_TYP;
        public String Action;
        public String MAKTX;
        public String LGORT;
        public String StockQuantity;
        public String zreturn;
        public String MEINS;
        public String MATNR;
        public String BATCH;
        public String Stockkey;
        public String stocktakingDate;
        public String ChangeQuantity;
    } 

    public class Result {
        public String resultCode;
        public String resultMessage;
        public String soapCallResult;
    }

    @InvocableMethod(label='Send STOCK to SAP')
    public static void doSendStock(List<Id> listTargetId) {

        Set<Id> setTargetId = new Set<Id>(listTargetId);

        system.debug( 'setTargetId :: ' + setTargetId);
        String resultCode = '';
        String resultMessage = '';
        try{
            IF_SFDC_SAP_SAND_STOCK.Output outputObj = new IF_SFDC_SAP_SAND_STOCK.Output();
            IF_SFDC_SAP_SAND_STOCK ifSTOCK = new IF_SFDC_SAP_SAND_STOCK();
            
            callOut(setTargetId);
            // system.debug('Stock outputObj ::' + outputObj);

            // resultCode = outputObj.result.resultCode;
            // resultMessage = outputObj.result.resultMessage;
        } 
        catch(Exception e){
            resultCode = '-1';
            resultMessage ='CK_InAndOutMgmtController doConfirmData error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')';
            system.debug('CODE :: ' + resultCode + ' : ' + resultMessage);    
        }
    }
    
    @Future(callout=true)
    public static void callOut(Set<Id> idSet) {
        callCjCkSoapVer_2.sapCkInParameter inputData = new callCjCkSoapVer_2.sapCkInParameter();
        List<StockChangeLog__c> headerList = new List<StockChangeLog__c>();
        List<STOCK__c> targetList = new List<Stock__c>();
        List<STOCK__c> stockUpList = new List<Stock__c>();
        Map<String,Object> inputMap = new Map<String,Object>();
        Set<String> stockKeySet = new Set<String>();

        Result objResult = new Result();
        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '확정 데이터 전송 성공';
        String result = '';
        String inputString = '';

        try {
            headerList = [
                SELECT StockQuantity__c,
                ChangeQuantity__c,
                Action__c,
                stocktakingDate__c,
                MATNR__c,
                MAT_TYP__c,
                MAKTX__c,
                LGORT__c,
                STOCK__c,
                MEINS__c,
                Batch__c,
                xmsgs__c,
                zreturn__c,
                stockkey__c
                FROM StockChangeLog__c
                WHERE id in:idSet
            ];
            for (StockChangeLog__c obj : headerList) {
                stockKeySet.add(obj.stockkey__c);
                System.debug('=======================obj.stockkey__c:::'+obj.stockkey__c);
            }
            System.debug('===========stockKeySet :::'+stockKeySet);
            inputMap.put('header', headerList);
            inputMap.put('IF_ID', 'CK0006');
            inputString = JSON.serialize(inputMap);
            inputData.requestMsg = inputString;
            System.debug('=============================requestMsg:::'+ inputData.requestMsg);

            callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort soap = new callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort();
            result = soap.callSapCkProcedure(inputData);
            System.debug('result======================= :::'+result);

            if(result == '' || result == null) {
                strStatus = 'ERROR';
                strCode = '0003';
                strMessage = '확정 데이터 전송 실패';
            }else {
                Input input = (Input)JSON.deserialize(result, Input.class);

                if (input.header == null || input.header.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = '확정 데이터 전송 실패';
                }else {
                    Map<String, String> mapMeins = CommonUtil.getMapPickListLabel('Stock__C', 'MEINS__c');
                    Map<String,Stock__c> targetMap = new Map<String,Stock__c>();

                    targetList=[
                        SELECT Id, xmsgs__c, stockkey__c
                        FROM Stock__c
                        WHERE Stockkey__c in:stockKeySet
                    ];

                    System.debug('===========targetList :::'+targetList);
                    if(!targetList.isEmpty()){
                        for (Stock__c obj : targetList) {
                            targetMap.put(obj.stockkey__c, obj);
                        }
                        System.debug('===========targetMap :::'+targetMap);
                        for (headerList obj : input.header) {
                            Stock__c stockObj = new Stock__c();
                            stockObj = targetMap.get(obj.Stockkey);
                            System.debug('===========stockObj :::'+stockObj);
                            System.debug('===========obj.Stockkey :::'+obj.Stockkey);
                            stockObj.xmsgs__c = obj.xmsgs;
                            stockObj.zreturn__c = obj.zreturn;
                            stockUpList.add(stockObj);
                        }
                        System.debug(stockUpList);
    
                        update stockUpList;
                    }else {
                        strCode = '0004';
                        strMessage = '확정 데이터 전송 실패';
                        strStatus = 'ERROR';
                    }
                }
            }
        } catch (Exception e) {
            strCode = '-1';
            strMessage = e.getLineNumber()+e.getMessage() + e.getStackTraceString(); 
            strStatus = 'ERROR';
            System.debug(strMessage);
        } finally {

            objResult.resultCode = strCode;
            objResult.resultMessage = strMessage;
            objResult.soapCallResult = result;

            objOutput.result = objResult;

            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'strMessage:::' + strMessage + ':::soapCallResult:::' + result;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = inputString;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
        
            IFUtil objIF = new IFUtil('IF_SFDC_SAP_SAND_STOCK');
            objIF.setLog(LogWrapper);
        }
    }
}