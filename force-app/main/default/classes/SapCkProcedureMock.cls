/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-21-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
global class SapCkProcedureMock implements WebServiceMock {
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
     // start - specify the response you want to send
     callCjCkSoapVer_2.callSapCkProcedureResponse response_x = 
         new callCjCkSoapVer_2.callSapCkProcedureResponse();
     response_x.return_x = '{"detail":[{"BUDAT":"2022-04-12","EBELP_R":"00000","MAKTX":"동해 닭정육(2*5cm_절단 2Kg/EA)","RETPO":"","EBELN_R":"","WERKS":"3000","RAUBE":"30","MENGE":"1755.000","ORDERDKEY":"2165209086160","LOEKZ":"","EINDT":"2022-04-12","EBELP":"160","XSTAT":null,"XMSGS":"","LGORT":"L091","MEINS":"EA","MATNR":"203560","EBELN":"2165209086","LIFRN":""},{"BUDAT":"2022-04-12","EBELP_R":"00000","MAKTX":"동해 닭정육(2*5cm_절단 2Kg/EA)","RETPO":"","EBELN_R":"","WERKS":"3000","RAUBE":"30","MENGE":"1755.000","ORDERDKEY":"2165209086160","LOEKZ":"","EINDT":"2022-04-12","EBELP":"160","XSTAT":null,"XMSGS":"","LGORT":"L091","MEINS":"EA","MATNR":"203560","EBELN":"2165209085","LIFRN":""}],"header":[{"SHIP_TYP":"1","RESWK":"2600","XSTAT":null,"XMSGS":"","SND_YN":"","EBELN_R":"","EBELN":"2165209086","IFDATE":"2022-06-17"},{"SHIP_TYP":"1","RESWK":"2600","XSTAT":null,"XMSGS":"","SND_YN":"","EBELN_R":"","EBELN":"2165209085","IFDATE":"2022-06-17"}]}';
     // end
     response.put('response_x', response_x); 
    }
}