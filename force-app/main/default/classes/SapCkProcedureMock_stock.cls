/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-21-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
global class SapCkProcedureMock_stock implements WebServiceMock {
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
     response_x.return_x = '{"header":[{"MAT_TYP":"2","STOCKKEY":"1000012","MAKTX":"오뚜기 쇠고기라면(덕용 120g/EA)","WERKS":"5000","MENGE_KG":"112.000","U_PSMNG":"933.334","MENGE":"933.334","P_PSMNG":"0.000","LGORT":"1100","MEINS":"EA","MATNR":"103565","ZTIMS":"     20220621013542","BATCH":""},{"MAT_TYP":"2","STOCKKEY":"104374500013000000000000","MAKTX":"마이티 쇼트닝(15Kg/EA)","WERKS":"5000","MENGE_KG":"1987080.000","U_PSMNG":"132472.000","MENGE":"132472.000","P_PSMNG":"0.000","LGORT":"1300","MEINS":"EA","MATNR":"104374","ZTIMS":"     20220621013542","BATCH":""},{"MAT_TYP":"2","STOCKKEY":"104375500013000000000000","MAKTX":"오뚜기 쇼트닝(14Kg/EA)","WERKS":"5000","MENGE_KG":"46032.000","U_PSMNG":"3288.000","MENGE":"3288.000","P_PSMNG":"0.000","LGORT":"1300","MEINS":"EA","MATNR":"104375","ZTIMS":"     20220621013542","BATCH":""}]}';
     // end
     response.put('response_x', response_x); 
    }
}