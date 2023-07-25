/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class IFUtil {
    /** I/F Master */
    public IFMaster__c objIFMaster;

    /** I/F Test 여부 */
    public Boolean isTest = false;

    public IFUtil(String ifId) {
        IFMaster__c objIFMaster = new IFMaster__c();

        objIFMaster = [
            SELECT Id, Name,
                    InterfaceId__c, Type__c, WebserviceType__c, Endpoint__c, Method__c, ContentType__c
            FROM IFMaster__c
            WHERE Name =: ifId
            FOR UPDATE
        ];

        this.objIFMaster = objIFMaster;
    }

    /**
     * log저장(Async)
     * 
     * @param strIFName IFMaster__c Record Id   
     * @param strJSONLog JSON Log    
     * @return 
     *         
    **/
    @future
    public static void setLogFuture(String strIFName, String strJSONLog) {
        IFMaster__c objIFMaster = new IFMaster__c();

        LogWrapper LogWrapper = (LogWrapper)JSON.deserialize(strJSONLog, LogWrapper.class);

        Datetime requestTime = Datetime.now();
        Datetime responseTime;

        objIFMaster = [
            SELECT Id, Name, Type__c, WebserviceType__c, Endpoint__c, Method__c, ContentType__c
            FROM IFMaster__c
            WHERE Name =:strIFName
            FOR UPDATE
        ];

        IFLog__c objLog = new IFLog__c();

        objLog.IFMaster__c = objIFMaster.Id;
        objLog.Status__c = LogWrapper.status;

        objLog.ResultCode__c = LogWrapper.resultCode;
        objLog.ResultMessage__c = LogWrapper.resultMessage <> null && LogWrapper.resultMessage.length() > 130000 ? LogWrapper.resultMessage.substring(0,130000) : LogWrapper.resultMessage;

        objLog.RequestTime__c = LogWrapper.requestTime;
        objLog.RequestHeader__c = LogWrapper.requestHeader <> null && LogWrapper.requestHeader.length() > 130000 ? LogWrapper.requestHeader.substring(0,130000) : LogWrapper.requestHeader;
        objLog.RequestBody__c = LogWrapper.requestBody <> null && LogWrapper.requestBody.length() > 130000 ? LogWrapper.requestBody.substring(0,130000) : LogWrapper.requestBody;        

        objLog.ResponseTime__c = LogWrapper.responseTime;
        objLog.ResponseHeader__c = LogWrapper.responseHeader <> null && LogWrapper.responseHeader.length() > 130000 ? LogWrapper.responseHeader.substring(0,130000) : LogWrapper.responseHeader;        
        objLog.ResponseBody__c = LogWrapper.responseBody <> null && LogWrapper.responseBody.length() > 130000 ? LogWrapper.responseBody.substring(0,130000) : LogWrapper.responseBody;
        
        insert objLog;
    }

    /**
     * I/F log 생성
     * 
     * @param LogWrapper Log Wrapper 
     * @return
     *         
    **/
    public void setLog(LogWrapper LogWrapper) {
        IFLog__c objLog = new IFLog__c();
        
        objLog.IFMaster__c = this.objIFMaster.Id;
        objLog.Status__c = LogWrapper.status;
        /*
        objLog.TransactionId__c = LogWrapper.transactionId;
        objLog.IsLast__c = LogWrapper.isLast;
        */
                
        objLog.ResultCode__c = LogWrapper.resultCode;
        objLog.ResultMessage__c = LogWrapper.resultMessage <> null && LogWrapper.resultMessage.length() > 130000 ? LogWrapper.resultMessage.substring(0,130000) : LogWrapper.resultMessage;        

        objLog.RequestTime__c = LogWrapper.requestTime;        
        objLog.RequestHeader__c = LogWrapper.requestHeader <> null && LogWrapper.requestHeader.length() > 130000 ? LogWrapper.requestHeader.substring(0,130000) : LogWrapper.requestHeader;        
        objLog.RequestBody__c = LogWrapper.requestBody <> null && LogWrapper.requestBody.length() > 130000 ? LogWrapper.requestBody.substring(0,130000) : LogWrapper.requestBody;        

        objLog.ResponseTime__c = LogWrapper.responseTime;
        objLog.ResponseHeader__c = LogWrapper.responseHeader <> null && LogWrapper.responseHeader.length() > 130000 ? LogWrapper.responseHeader.substring(0,130000) : LogWrapper.responseHeader;        
        objLog.ResponseBody__c = LogWrapper.responseBody <> null && LogWrapper.responseBody.length() > 130000 ? LogWrapper.responseBody.substring(0,130000) : LogWrapper.responseBody;
        
        insert objLog;
    }
    
    /**
     * I/F 웹서비스 호출(Sync)
     * 
     * @param requestBody 요청값
     * @param isLogInsert Log(IFLog__c) 생성여부
     * @return
     *         
    **/
    public HttpResponse webCallout(String requestBody, Boolean isLogInsert) {
        HttpRequest request = new HttpRequest();
		HttpResponse response = new HttpResponse();
		Http http = new Http();
        
        String status = 'SUCCESS';
        String responseBody;
		String resultCode = '0';
        String resultMessage = '';
        LogWrapper objWrapper = new LogWrapper();
        
        try {
            
            objWrapper.requestTime = Datetime.now();

            if(objIFMaster.Name.contains('IFRESH') || objIFMaster.Name.contains('MDM') || objIFMaster.Name.contains('SRM') || objIFMaster.Name.contains('EACCT') ||
                objIFMaster.Name.contains('EDMS')
            ) {
                IF_RELAY_INFO__c objRelayInfo = IF_RELAY_INFO__c.getOrgDefaults();
                request.setHeader('Interface_id', objRelayInfo.Interface_id__c);
                request.setHeader('Interface_auth_key', objRelayInfo.Interface_auth_key__c);
                request.setHeader('Interface_req_dt', String.valueOf(Datetime.now().format('yyyyMMddHHmmss')));
                request.setHeader('Interface_tracekey', '1000000000000000000');
            } else if (objIFMaster.Name == 'IF_AI_SFDC_PRODUCT_INFO'){
                if(!Test.isRunningTest()) {
                    IF_AI_SFDC_PRODUCT_INFO__c objProductInfo = IF_AI_SFDC_PRODUCT_INFO__c.getOrgDefaults();
                    request.setHeader('x-aipex-role-id', objProductInfo.RoleId__c);
                    request.setHeader('x-aipex-secret-id', objProductInfo.SecretId__c);
                    request.setHeader('accept', this.objIFMaster.ContentType__c);
                }
            } else if (objIFMaster.Name == 'IF_AI_SFDC_LEARNING_SEND'){
                if(!Test.isRunningTest()) {
                    IF_AI_SFDC_LEARNING_SEND__c objLearningInfo = IF_AI_SFDC_LEARNING_SEND__c.getOrgDefaults();
                    request.setHeader('x-aipex-role-id', objLearningInfo.RoleId__c);
                    request.setHeader('x-aipex-secret-id', objLearningInfo.SecretId__c);
                    request.setHeader('accept', this.objIFMaster.ContentType__c);
                }
            } 
            
            request.setMethod(this.objIFMaster.Method__c);
            request.setEndpoint(this.objIFMaster.Endpoint__c);
            request.setTimeout(110000);         

            String contentType = this.objIFMaster.ContentType__c;

            request.setHeader('Content-Type', contentType);
            
            if(contentType.contains('multipart')) {                
                //request.setHeader('Content-Length', String.valueOf(requestBody.length()));
                request.setBodyAsBlob(EncodingUtil.base64Decode(requestBody));
                contentType = contentType+' charset=utf-8; boundary='+'vguardiance';
            }
            
            objWrapper.requestBody = requestBody;

            //Map<String, Object> mapParam = (Map<String, Object>)JSON.deserializeUntyped(requestBody);

            /*
            System.debug('kym =================> : requestBody : '+requestBody);           
            System.debug('kym =================> transactionId : '+mapParam.get('transactionId'));

            objWrapper.transactionId = String.valueOf(mapParam.get('transactionId'));
            */
            
            // request.setBody를 할 경우 Method GET으로 설정을 해도 실제로는 POST로 전송되기 때문에 분기처리해준다
            if(objIFMaster.Method__c == 'POST') {
                if(contentType == 'application/x-www-form-urlencoded') {
                    requestBody = EncodingUtil.urlEncode(requestBody, 'UTF-8');
                }
                request.setBody(requestBody);
            }else if(objIFMaster.Method__c == 'PUT') {
                request.setEndpoint(objIFMaster.Endpoint__c+'?_HttpMethod=PATCH');
                request.setMethod('POST');
                //request.setHeader('X-HTTP-Method-Override', 'PATCH');
                request.setBody(requestBody);

            }else if(objIFMaster.Method__c == 'GET' && (requestBody <> null && requestBody != '')) {
                request.setEndpoint(objIFMaster.Endpoint__c+'?'+requestBody);
            }
            System.debug('request :: ' + request);
            response = http.send(request);
            
            responseBody = response.getBody();

            Boolean redirect;

            if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                if(responseBody <> null && responseBody != '') {
                    /*
                    Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

                    System.debug('==================> webCallout mapResponse : '+mapResponse);

                    if(mapResponse.get('resultCode') <> null) {
                        String strCode = String.valueOf(mapResponse.get('resultCode'));

                        if(strCode != '0000') {
                            status = 'ERROR';
                            resultCode = String.valueOf(mapResponse.get('resultCode'));
                            resultMessage = String.valueOf(mapResponse.get('resultMessage'));
                        }
                    }else if(mapResponse.get('data') <> null) {
                        Map<String, Object> mapResultData = (Map<String, Object>)mapResponse.get('data');

                        
                        if(mapResultData.get('ES_RESULT') <> null) {
                            Map<String, Object> sapResultMap = (Map<String, Object>)mapResultData.get('ES_RESULT');

                            String sapResultCode = String.valueOf(sapResultMap.get('CODE'));

                            if(sapResultCode != 'S') {
                                status = 'ERROR';
                                resultCode = sapResultCode;
                                resultMessage = String.valueOf(sapResultMap.get('MESSAGE'));
                            }

                        }
                        // 나머지 SAP                    
                        else if(mapResultData.get('E_RETURN') <> null) {
                            Map<String, Object> sapResultMap = (Map<String, Object>)mapResultData.get('E_RETURN');

                            String sapResultCode = String.valueOf(sapResultMap.get('CODE'));

                            if(sapResultCode != 'S') {
                                status = 'ERROR';
                                resultCode = sapResultCode;
                                resultMessage = String.valueOf(sapResultMap.get('MESSAGE'));
                            }
                        }
                    }
                    */
                }else {
                    responseBody = 'Not ResponseBody';
                }

                objWrapper.responseTime = Datetime.now();
                objWrapper.responseBody = responseBody;
            }          
            else {
                String loc = response.getHeader('Location'); // get location of the redirect

                status = 'ERROR';
                resultCode = String.valueOf(response.getStatusCode());
                resultMessage = responseBody;
            }
            
        }catch(Exception e) {
            status = 'ERROR';
            resultCode = '-1';
            resultMessage = e.getMessage()+'ERROR Line : '+e.getLineNumber();
        }

        /*
        System.debug('================> webCallout resultCode : '+resultCode);
        System.debug('================> webCallout resultMessage : '+resultMessage);
        */
        
        objWrapper.status = status;
        objWrapper.resultCode = resultCode;
        objWrapper.resultMessage = resultMessage;

        if(isLogInsert) {
            setLog(objWrapper);
        }
        return response;
    }
    
    /**
     * I/F 웹서비스 호출(ASync)
     * 
     * @param strJson JSON Data
     * @return
     *         
    **/
    @future(callout=true)
    public static void webCalloutFuture(String strJson) {
        IFMaster__c objIFMaster = new IFMaster__c(); 

        Map<String, Object> mapParam = new Map<String, Object>();

        mapParam = (Map<String, Object>)JSON.deserializeUntyped(strJson);        

        Datetime requestTime = Datetime.now();
        Datetime responseTime;
        
        objIFMaster = [
            SELECT  Id, Name, Type__c, WebserviceType__c, Endpoint__c, Method__c, ContentType__c
            FROM    IFMaster__c
            WHERE   Name =:String.valueOf(mapParam.get('if_id'))
            FOR UPDATE
        ];

        HttpRequest request = new HttpRequest();
		HttpResponse response = new HttpResponse();
		Http http = new Http();
        
        String status = 'SUCCESS';
        String responseBody;
		String resultCode = '0';
        String resultMessage = '';       

        String requestBody = '';
        
        try {
            requestBody = JSON.serialize(mapParam.get('body'));            
            /*
            System.debug('=============> requestBody : '+requestBody);

            if(requestBody.contains('\\\\n')) {
                requestBody = requestBody.replaceAll('\\\\n', '\\n');
            }

            if(requestBody.contains('\\\\\\\\n')) {                    
                requestBody = requestBody.replaceAll('\\\\\\\\n', '\\n');
            } 
            */           


            if(objIFMaster.Name.contains('IFRESH') || objIFMaster.Name.contains('MDM') || objIFMaster.Name.contains('SRM') || objIFMaster.Name.contains('EACCT')) {
                IF_RELAY_INFO__c objRelayInfo = IF_RELAY_INFO__c.getOrgDefaults();

                request.setHeader('Interface_id', objRelayInfo.Interface_id__c);
                request.setHeader('Interface_auth_key', objRelayInfo.Interface_auth_key__c);
                request.setHeader('Interface_req_dt', String.valueOf(Datetime.now().format('yyyyMMddHHmmss')));
                // 2022-11-09 현재 미정 추후 변경 필요 
                request.setHeader('Interface_tracekey', '1000000000000000000');
            }            

            request.setMethod(objIFMaster.Method__c);
            request.setEndpoint(objIFMaster.Endpoint__c);
            request.setTimeout(110000);
            request.setHeader('Content-Type', objIFMaster.ContentType__c);
            request.setHeader('Content-Length', String.valueOf(requestBody.length()));

            // multipartform 형태의 웹서비스이면 따로 세팅
            if(objIFMaster.ContentType__c.contains('multipart')) {                
                //request.setHeader('Content-Length', body.length());
                /*
                request.setBodyAsBlob(EncodingUtil.base64Decode(body));
                contentType = contentType+' charset=utf-8; boundary='+System.label.Code_boundary;
				*/
            }

            // request.setBody를 할 경우 Method GET으로 설정을 해도 실제로는 POST로 전송되기 때문에 분기처리해준다
            if(objIFMaster.Method__c == 'POST') {                
                request.setBody(requestBody);
            }else if(objIFMaster.Method__c == 'GET') {
                request.setEndpoint(objIFMaster.Endpoint__c+'?'+requestBody);
            }
            
            response = http.send(request);

            responseTime = Datetime.now();
            responseBody = response.getBody();

            if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                if(responseBody <> null && responseBody != '') {
                    Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

                    System.debug('==================> webCalloutFuture mapResponse : '+mapResponse);

                    if(mapResponse.get('resultCode') <> null) {

                        String strCode = String.valueOf(mapResponse.get('resultCode'));

                        if(strCode != '0000') {
                            status = 'ERROR';
                            resultCode = String.valueOf(mapResponse.get('resultCode'));
                            resultMessage = String.valueOf(mapResponse.get('resultMessage'));
                        }
                    }else if(mapResponse.get('data') <> null) {
                        Map<String, Object> mapResultData = (Map<String, Object>)mapResponse.get('data');

                        /*
                        if(mapResultData.get('ES_RESULT') <> null) {
                            Map<String, Object> sapResultMap = (Map<String, Object>)mapResultData.get('ES_RESULT');
    
                            String sapResultCode = String.valueOf(sapResultMap.get('CODE'));
    
                            if(sapResultCode != 'S') {
                                status = 'ERROR';
                                resultCode = sapResultCode;
                                resultMessage = String.valueOf(sapResultMap.get('MESSAGE'));
                            }
    
                        }
                        // 나머지 SAP                    
                        else if(mapResultData.get('E_RETURN') <> null) {
                            Map<String, Object> sapResultMap = (Map<String, Object>)mapResultData.get('E_RETURN');
    
                            String sapResultCode = String.valueOf(sapResultMap.get('CODE'));
    
                            if(sapResultCode != 'S') {
                                status = 'ERROR';
                                resultCode = sapResultCode;
                                resultMessage = String.valueOf(sapResultMap.get('MESSAGE'));
                            }
                        }
                        */
                    }
                }else {
                    responseBody = 'Not ResponseBody';
                }
            }else {
                status = 'ERROR';
                resultCode = String.valueOf(response.getStatusCode());
                resultMessage = response.getBody();
            }

        }catch(Exception e) {
            status = 'ERROR';
            resultCode = '-1';
            resultMessage = e.getMessage()+' Line : '+e.getLineNumber();            
        }

        IFLog__c objLog = new IFLog__c();
        
        objLog.IFMaster__c = objIFMaster.Id;
        objLog.Status__c = status;
        objLog.ResultCode__c = resultCode;
        objLog.ResultMessage__c = resultMessage <> null && resultMessage.length() > 130000 ? resultMessage.substring(0,130000) : resultMessage;
        objLog.RequestTime__c = requestTime;
        objLog.RequestBody__c = requestBody <> null && requestBody.length() > 130000 ? requestBody.substring(0,130000) : requestBody;
        objLog.ResponseTime__c = responseTime;
        objLog.ResponseBody__c = responseBody <> null && responseBody.length() > 130000 ? responseBody.substring(0,130000) : responseBody;
        //objLog.transactionId__c = String.valueOf(mapParam.get('transactionId'));
        
        insert objLog;
    }
}