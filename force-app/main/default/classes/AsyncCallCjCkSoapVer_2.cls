//Generated by wsdl2apex

public class AsyncCallCjCkSoapVer_2 {
    public class callSapCkProcedureResponseFuture extends System.WebServiceCalloutFuture {
        public String getValue() {
            callCjCkSoapVer_2.callSapCkProcedureResponse response = (callCjCkSoapVer_2.callSapCkProcedureResponse)System.WebServiceCallout.endInvoke(this);
            return response.return_x;
        }
    }
    public class AsyncCalllogisoneSapCkSoapImplPort {
        public String endpoint_x = 'http://scmwsqa.ifresh.co.kr:8900/ws/callSapCkProcedure';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://service.sap.logisoneweb/', 'callCjCkSoapVer_2'};
        public AsyncCallCjCkSoapVer_2.callSapCkProcedureResponseFuture beginCallSapCkProcedure(System.Continuation continuation,callCjCkSoapVer_2.sapCkInParameter arg0) {
            callCjCkSoapVer_2.callSapCkProcedure request_x = new callCjCkSoapVer_2.callSapCkProcedure();
            request_x.arg0 = arg0;
            return (AsyncCallCjCkSoapVer_2.callSapCkProcedureResponseFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncCallCjCkSoapVer_2.callSapCkProcedureResponseFuture.class,
              continuation,
              new String[]{endpoint_x,
              '',
              'http://service.sap.logisoneweb/',
              'callSapCkProcedure',
              'http://service.sap.logisoneweb/',
              'callSapCkProcedureResponse',
              'callCjCkSoapVer_2.callSapCkProcedureResponse'}
            );
        }
    }
}