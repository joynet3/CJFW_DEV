//Generated by wsdl2apex

public class AsyncCallCjCkSoapVer_3 {
    public class callSapCkProcedureResponseFuture extends System.WebServiceCalloutFuture {
        public String getValue() {
            callCjCkSoapVer_3.callSapCkProcedureResponse response = (callCjCkSoapVer_3.callSapCkProcedureResponse)System.WebServiceCallout.endInvoke(this);
            return response.return_x;
        }
    }
    public class AsyncCalllogisoneSapCkSoapImplPort {
        public String endpoint_x = 'http://scmws.ifresh.co.kr:8900/ws/callSapCkProcedure';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://service.sap.logisoneweb/', 'callCjCkSoapVer_3'};
        public AsyncCallCjCkSoapVer_3.callSapCkProcedureResponseFuture beginCallSapCkProcedure(System.Continuation continuation,callCjCkSoapVer_3.sapCkInParameter arg0) {
            callCjCkSoapVer_3.callSapCkProcedure request_x = new callCjCkSoapVer_3.callSapCkProcedure();
            request_x.arg0 = arg0;
            return (AsyncCallCjCkSoapVer_3.callSapCkProcedureResponseFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncCallCjCkSoapVer_3.callSapCkProcedureResponseFuture.class,
              continuation,
              new String[]{endpoint_x,
              '',
              'http://service.sap.logisoneweb/',
              'callSapCkProcedure',
              'http://service.sap.logisoneweb/',
              'callSapCkProcedureResponse',
              'callCjCkSoapVer_3.callSapCkProcedureResponse'}
            );
        }
    }
}