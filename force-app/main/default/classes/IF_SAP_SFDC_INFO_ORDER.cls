/**
 * @description       : 
 * @author            : 안태진
 * @group             : 
 * @last modified on  : 06-15-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
@RestResource(urlMapping='/sap/info/order')
global without sharing class IF_SAP_SFDC_INFO_ORDER {
    public IF_SAP_SFDC_INFO_ORDER() {}

    global class Input {
        public List<OrderH> order_Hlist;
        public List<OrderD> order_Dlist;
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

    global class OrderH{
        public String ZTIMS;
        public String IFDATE;
        public String EBELN;
        public String RESWK;
        public String SND_YN;
        public String SHIP_TYP;
        public String XDATS;
        public String XTIMS;
    }

    global class OrderD{
        public String ZTIMS;
        public String EBELN;
        public String EBELP;
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

            List<Order_H__C> orderHList = new List<ORDER_H__C>(); 
            List<Order_D__C> orderDList = new List<ORDER_D__C>(); 

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

                    if (input.order_Hlist == null || input.order_Hlist.size() < 1) {
                        strStatus = 'ERROR';
                        strCode = '0001';
                        strMessage = 'ordero_h_lsit is null';
                    }else if (input.order_Dlist == null || input.order_Dlist.size() < 1) {
                        strStatus = 'ERROR';
                        strCode = '0002';
                        strMessage = 'ordero_d_lsit is null';
                    }else {
                        Map<String, Id> id_ebelnMap = new Map<String, Id>();
                        Map<String, String> mapSND_YN = CommonUtil.getMapPickListLabel('Order_H__c', 'Snd_Yn__c');

                        Set<String> orderNoSet = new Set<String>();

                        if (input.order_Hlist <> null && input.order_Hlist.size() > 0) {
                            for (Integer i = 0; i < input.order_Hlist.size(); i++) {
                                Order_H__c obj = new Order_H__c();
                                obj.IFDATE__c = Date.valueOf(input.order_Hlist[i].IFDATE);
                                obj.EBELN__c = input.order_Hlist[i].EBELN;
                                obj.Reswk__c = input.order_Hlist[i].RESWK;
                                obj.Snd_Yn__c = mapSND_YN.get(input.order_Hlist[i].SND_YN);
                                obj.SHIP_TYP__c = input.order_Hlist[i].SHIP_TYP;
                                obj.Xdats__c = input.order_Hlist[i].XDATS;
                                obj.Xtims__c = input.order_Hlist[i].XTIMS;
                                orderNoSet.add(input.order_Hlist[i].EBELN);
                                orderHList.add(obj);
                            }
                                upsert orderHList EBELN__c;
                                orderHList = [SELECT Id,EBELN__C FROM Order_H__c WHERE EBELN__c in:orderNoSet];
                                System.debug('===========orderHList=='+orderHList);
                            for (Order_H__c obj : orderHList) {
                                id_ebelnMap.put(obj.EBELN__c, obj.Id);
                            }
                            System.debug('==================id_ebelnMap++++'+id_ebelnMap);
                            

                        }    
                        if (input.order_Dlist <> null && input.order_Dlist.size() > 0) {
                            Map<String, String> mapWERKS = CommonUtil.getMapPickList('Order_D__c', 'WERKS__c');
                            for (Integer i = 0; i < input.order_Hlist.size(); i++) {
                                Order_D__c obj = new Order_D__c();
                                obj.EBELN__c = input.order_Dlist[i].EBELN;
                                obj.EBELP__c = input.order_Dlist[i].EBELP;
                                obj.LOEKZ__c = input.order_Dlist[i].LOEKZ;
                                obj.WERKS__c = mapWERKS.get(input.order_Dlist[i].WERKS);
                                obj.LGORT__c = input.order_Dlist[i].LGORT;
                                obj.MATNR__c = input.order_Dlist[i].MATNR;
                                obj.MAKTX__c = input.order_Dlist[i].MAKTX;
                                obj.MENGE__c = Decimal.valueOf(input.order_Dlist[i].MENGE);
                                obj.MEINS__c = input.order_Dlist[i].MEINS;
                                obj.RAUBE__c = input.order_Dlist[i].RAUBE;
                                obj.EINDT__c = Date.valueOf(input.order_Dlist[i].EINDT);
                                obj.RETPO__c = input.order_Dlist[i].RETPO;
                                obj.BUDAT__c = Date.valueOf(input.order_Dlist[i].BUDAT);
                                obj.Order_H__C = id_ebelnMap.get(input.order_Dlist[i].EBELN);
                                orderDList.add(obj);
                            }
                            System.debug('===========orderHList==' + orderDList);
                            insert orderDList;

                        }
                    }
                }
            } catch (Exception e) {
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
        
        IFUtil objIF = new IFUtil('IF_SAP_SFDC_INFO_ORDER');
        objIF.setLog(LogWrapper);

        return objOutput;
    }
}