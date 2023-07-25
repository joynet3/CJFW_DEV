/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-21-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
global class SapCkProcedureMock_release implements WebServiceMock {
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
     response_x.return_x = '{"detail":[{"RELEASEDKEY":"300000012010","R_PSMNG":"0.000","MAKTX":"CK계란장조림1kg/EA(1Kg/EA)","RETPO":"","WERKS":"2600","RAUBE":"20","MENGE":"90.000","PSMNG":"90.000","PBUDAT":"2022-06-20","EBELP":"10","EINDT":"2022-06-21","XMSGS":"test","LGORT":"1000","MEINS":"EA","MATNR":"700770","CHARG":"0000002550","EBELN":"3000000120"}],"header":[{"XTIMS":"16:39:21","XDATS":"2022-06-20","SND_YN":"S","XMSGS":"test","xstat":"Y","EBELN":"3000000120","IFDATE":"2022-06-20"}]}';
     // end
     response.put('response_x', response_x); 
    }
}