/**
 * @description       : 
 * @author            : 안태진
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
public class IF_SFDC_SAP_REC_ORDER {

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
        public String ORDERDKEY;
    }
    public Output callOut(String sysdate) {
        Set<String> orderebelnDelSet = new Set<String>();
        List<Order_H__c> orderHList = new List<Order_H__c>(); 
        List<Order_D__C> orderDList = new List<Order_D__C>(); 

        Result objResult = new Result();
        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '데이터가 성공적으로 수신 되었습니다.';
        String result = '';

        String inputDate = sysdate;
        system.debug('====================== inputDate :::'+inputDate);

        try {

            inputData.requestMsg = '{"sysdate" : "'+sysdate+'", "IF_ID" : "CK0001"}';
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
                }else if (input.detail == null || input.detail.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0002';
                    strMessage = '수신받을 데이터가 없습니다.';
                }else {
                    Map<String, Id> id_ebelnMap = new Map<String, Id>();
                    Map<String, String> mapSND_YN = CommonUtil.getMapPickListLabel('Order_H__c', 'Snd_Yn__c');
                    Map<String, String> mapWERKS = CommonUtil.getMapPickList('Order_D__c', 'WERKS__c');
                    Set<String> orderNoSet = new Set<String>();
                    List<Order_H__C> delOrderList = new List<Order_H__C>();

                    for (OrderH obj : input.header) {
                        orderNoSet.add(obj.EBELN);
                    }

                    delOrderList = [
                        SELECT Id, IFDATE__c, EBELN__c,EBELN_R__c,Reswk__c,Snd_Yn__c,SHIP_TYP__c,Xdats__c,Xtims__c
                        FROM Order_H__c
                        WHERE (NOT(CONFIRM__c = 'N' AND EBELN_R__c = '')) AND Ebeln__c in: orderNoSet
                    ];

                    for (Order_H__c obj : delOrderList) {
                        orderebelnDelSet.add(obj.Ebeln__c);
                    }
                    
                    if (input.header <> null && input.header.size() > 0) {
                        for (OrderH obj : input.header) {
                            Order_H__c orderObj = new Order_H__c();
                            if(orderebelnDelSet.contains(obj.EBELN)){
                                continue;
                            }else {
                                if(obj.IFDATE <> null) {
                                    Date dt = Date.newInstance(
                                        Integer.valueOf(obj.IFDATE.substring(0,4))
                                        ,Integer.valueOf(obj.IFDATE.substring(5,7))
                                        ,Integer.valueOf(obj.IFDATE.substring(8,10))
                                        );
                                        orderObj.IFDATE__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                                }
                                orderObj.EBELN__c = obj.EBELN;
                                orderObj.EBELN_R__c = obj.EBELN_R;
                                orderObj.Reswk__c = obj.RESWK;
                                orderObj.Snd_Yn__c = mapSND_YN.get(obj.SND_YN);
                                orderObj.SHIP_TYP__c = obj.SHIP_TYP;
                                orderObj.Xdats__c = obj.XDATS;
                                orderObj.Xtims__c = obj.XTIMS;
                                orderHList.add(orderObj);
                            }
                        }
                        System.debug('============= orderHList :::' + orderHList);
                    }

                    upsert orderHList EBELN__c;

                    for (Order_H__c obj : orderHList) {
                        id_ebelnMap.put(obj.Ebeln__c, obj.id);
                    }

                    if (input.detail <> null && input.detail.size() > 0) {
                        
                        for (Integer i = 0; i < input.detail.size(); i++) {
                            if (orderebelnDelSet.contains(input.detail[i].EBELN)) {
                                continue;
                            }else {
                                Order_D__c obj = new Order_D__c(); 
                                obj.Name = input.detail[i].MAKTX;
                                obj.EBELN__c = input.detail[i].EBELN;
                                obj.EBELP__c = input.detail[i].EBELP;
                                obj.EBELN_R__c = input.detail[i].EBELN_R;
                                obj.EBELP_R__c = input.detail[i].EBELP_R;
                                obj.LIFNR__c = input.detail[i].LIFNR;
                                obj.LOEKZ__c = input.detail[i].LOEKZ;
                                obj.WERKS__c = mapWERKS.get(input.detail[i].WERKS);
                                obj.LGORT__c = input.detail[i].LGORT;
                                obj.MATNR__c = input.detail[i].MATNR;
                                obj.MAKTX__c = input.detail[i].MAKTX;
                                obj.MENGE__c = Decimal.valueOf(input.detail[i].MENGE);
                                obj.MEINS__c = input.detail[i].MEINS;
                                obj.RAUBE__c = input.detail[i].RAUBE; 
                                if(input.detail[i].EINDT <> null) {
                                    Date dt = Date.newInstance(
                                        Integer.valueOf(input.detail[i].EINDT.substring(0,4))
                                        ,Integer.valueOf(input.detail[i].EINDT.substring(5,7))
                                        ,Integer.valueOf(input.detail[i].EINDT.substring(8,10))
                                        );
                                        obj.EINDT__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                                }
                                obj.RETPO__c = input.detail[i].RETPO;
                                if(input.detail[i].BUDAT <> null) {
                                    Date dt = Date.newInstance(
                                        Integer.valueOf(input.detail[i].BUDAT.substring(0,4))
                                        ,Integer.valueOf(input.detail[i].BUDAT.substring(5,7))
                                        ,Integer.valueOf(input.detail[i].BUDAT.substring(8,10))
                                        );
                                        obj.BUDAT__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                                }
                                obj.Order_H__C = id_ebelnMap.get(input.detail[i].EBELN);
                                if (input.detail[i].ORDERDKEY == null || input.detail[i].ORDERDKEY == '') {
                                    strStatus = 'ERROR';
                                    strCode = '0004';
                                    strMessage = '수신받을 데이터가 없습니다.';
                                }else {
                                    obj.ORDERDKEY__c = input.detail[i].ORDERDKEY;
                                }
                                orderDList.add(obj);
                            }
                        }

                        System.debug('============= orderDList :::' + orderDList);
                        upsert orderDList ORDERDKEY__c;
                    }

                    // 주문내역 삭제로직 제거 (220624 Cj 요청)
                    // List<ORDER_H__c> listEmptyOrder = new List<ORDER_H__c>();
                    // List<ORDER_H__c> listCheckOrderEmpty = [
                    //     SELECT  
                    //         Id, 
                    //         Name, 
                    //         (SELECT Id 
                    //         FROM ORDER_D__r 
                    //         WHERE LOEKZ__c != 'X') 
                    //     FROM   ORDER_H__c  
                    // ];
                    // for (ORDER_H__c objCheckOrderEmpty : listCheckOrderEmpty ){
                    //     if ( objCheckOrderEmpty.ORDER_D__r.size() == 0)
                    //         listEmptyOrder.add(objCheckOrderEmpty);
                    // }
                    // if( !listEmptyOrder.isEmpty())
                    //     delete listEmptyOrder;
                }
            }
        } catch (Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage(); 
            System.debug(strMessage);
        }
        finally{
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
        
            IFUtil objIF = new IFUtil('IF_SFDC_SAP_REC_ORDER');
            objIF.setLog(LogWrapper);
        }
        return objOutput;
    }
}