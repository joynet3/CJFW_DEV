/**
 * @description       : 
 * @author            : 안태진
 * @group             : 
 * @last modified on  : 06-24-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
public class IF_SFDC_SAP_SAND_ORDER {

    callCjCkSoapVer_2.sapCkInParameter inputData = new callCjCkSoapVer_2.sapCkInParameter();
    
    public class Input {
        public List<OrderH> header;
        public List<OrderD> detail;
    }

    public class Output {
        public Result result;
    }

    public class Result {
        public String resultCode;
        public String resultMessage;
        public String soapCallResult;
    }

    public class OrderH{
        public String ZTIMS;
        public String IFDATE;
        public String EBELN;
        public String EBELN_R;
        public String RESWK;
        public String SND_YN;
        public String SHIP_TYP;
        public String XDATS;
        public String XTIMS;
        public String XMSGS;
    }

    public class OrderD{
        public String ZTIMS;
        public String EBELN;
        public String EBELP;
        public String EBELN_R;
        public String EBELP_R;
        public String LIFNR;
        public String LOEKZ;
        public String WERKS;
        public String LGORT;
        public String MATNR;
        public String MAKTX;
        public String MENGE;
        public String MEINS;
        public String RAUBE;
        public String EINDT;
        public String RETPO;
        public String BUDAT;
        public String XMSGS;
        public String ORDERDKEY;
    }

    public Output callOut() {
        List<Order_H__C> inputHeader = new List<ORDER_H__C>(); 
        List<Order_D__C> inputDetail = new List<ORDER_D__C>(); 
        List<Order_H__C> updateHList = new List<ORDER_H__C>(); 
        List<Order_D__C> updateDList = new List<ORDER_D__C>(); 
        Map<String,Object> inputMap = new Map<String,Object>();

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
            inputHeader = [
                SELECT IFDATE__c, EBELN__c, EBELN_R__c, RESWK__c, CHECK__c, SHIP_TYP__c, CONFIRM__c, SND_YN__c, XDATS__c, XTIMS__c
                FROM Order_H__C
                WHERE CHECK__c = 'Y' AND EBELN_R__c = ''
                ];
            inputDetail = [
                SELECT EBELN__c, EBELP__c, LOEKZ__c, WERKS__c, LIFNR__c, LGORT__c, MATNR__c, MAKTX__c, MENGE__c, MEINS__c, RAUBE__c, EINDT__c, RETPO__c, BUDAT__c, ORDER_H__c, ORDERDKEY__c
                FROM Order_D__C
                WHERE ORDER_H__r.CHECK__c = 'Y' AND ORDER_H__r.EBELN_R__c = ''
            ];

            inputMap.put('header', inputHeader);
            inputMap.put('detail', inputDetail);
            inputMap.put('IF_ID', 'CK0002');

            inputString = JSON.serialize(inputMap);
            inputData.requestMsg = inputString;

            System.debug('========================requestMsg :::'+inputData.requestMsg);

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
                    Map<String, Order_H__c> mapUpOrder = new Map<String, Order_H__c>();
                    Map<String, Order_D__c> mapUpDOrder = new Map<String, Order_D__c>();
    
                    if (input.header <> null && input.header.size() > 0) {
                        for (Order_H__c obj : inputHeader) {
                            mapUpOrder.put(obj.EBELN__C, obj);
                        }
                        if (!inputHeader.isEmpty()) {
                            for (OrderH obj : input.header) {
                                Order_H__c orderHObj = new Order_H__c();
                                orderHObj = mapUpOrder.get(obj.EBELN);
                                if (obj.XMSGS == '') {
                                    orderHObj.CONFIRM__c = 'Y';
                                    // orderHObj.EBELN_R__C = obj.EBELN_R;
                                }
                                orderHObj.EBELN_R__C = obj.EBELN_R;
                                orderHObj.xmsgs__c = obj.XMSGS;
                                updateHList.add(orderHObj);
                            }
                            System.debug(('====================mapUpOrder:::' + mapUpOrder));
                            System.debug(('====================updateHList:::' + updateHList));
                            update updateHList;
                        }
                        for (Order_D__c obj : inputDetail) {
                            mapUpDOrder.put(obj.EBELN__C, obj);
                        }
                        if(!inputDetail.isEmpty()){
                            for (OrderD obj : input.detail) {
                                Order_D__c orderDObj = new Order_D__c();
                                orderDObj = mapUpDOrder.get(obj.EBELN);
                                // if(obj.XMSGS == ''){
                                //     orderDObj.EBELN_R__C = obj.EBELN_R;
                                //     orderDObj.EBELP_R__c = obj.EBELP_R;
                                // }
                                orderDObj.EBELN_R__C = obj.EBELN_R;
                                orderDObj.EBELP_R__c = obj.EBELP_R;
                                orderDObj.xmsgs__c = obj.XMSGS;
                            }
                            System.debug(('====================mapUpDOrder:::' + mapUpDOrder));
                            System.debug(('====================updateDList:::' + updateDList));
                            update updateDList;
                        }
                    }
                }    
            }
        }catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage(); 
            System.debug(strMessage);
        }finally{

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
            
            IFUtil objIF = new IFUtil('IF_SFDC_SAP_SAND_ORDER');
            objIF.setLog(LogWrapper);
        }
        return objOutput;
    }
}