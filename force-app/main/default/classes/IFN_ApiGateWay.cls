public with sharing class IFN_ApiGateWay {

    public IFMaster__c objIFMaster;
    public String ifKeyId;

    public List<API_Authenticationkey__mdt> objIFAuthHeadInfoLst;
    public List<API_Authenticationkey__mdt> objIFAuthGetParamInfoLst;

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;


    /** I/F Test 여부 */
    public Boolean isTest = false;
    
    public IFN_ApiGateWay(String ifId) {

        IFMaster__c objIFMaster = new IFMaster__c();
        List<API_Authenticationkey__mdt> objIFAuthHeadInfo = new List<API_Authenticationkey__mdt>();
        List<API_Authenticationkey__mdt> objIFAuthgetParamInfo = new List<API_Authenticationkey__mdt>();

        objIFMaster = [
            SELECT Id, Name,
                    InterfaceId__c, Type__c, WebserviceType__c, Endpoint__c, Method__c, ContentType__c,ifKeyId__c,Header__c,
                    Param1__c,Param2__c,Param3__c,Param4__c
            FROM IFMaster__c
            WHERE Name =: ifId
            limit 1
        ];

        if(String.isNotBlank(objIFMaster.ifKeyId__c)) {
            objIFAuthHeadInfo = [select  MasterLabel,    QualifiedApiName, KeyValue__c, DateRange__c,  
            HeaderKey__c, HeaderLab__c, keyValueSp__c 
            from API_Authenticationkey__mdt 
            where IfHeaderKeyId__c = :objIFMaster.ifKeyId__c
            and keyValueSp__c = 'head'
            ];
            this.objIFAuthHeadInfoLst = objIFAuthHeadInfo;

            objIFAuthgetParamInfo = [select  MasterLabel,    QualifiedApiName, KeyValue__c, DateRange__c,  
            HeaderKey__c, HeaderLab__c, keyValueSp__c 
            from API_Authenticationkey__mdt 
            where IfHeaderKeyId__c = :objIFMaster.ifKeyId__c
            and keyValueSp__c = 'param'
            ];
            this.objIFAuthGetParamInfoLst = objIFAuthgetParamInfo;

            this.ifKeyId = objIFMaster.ifKeyId__c;

        }




        this.objIFMaster = objIFMaster;
        


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


            if(String.isNotBlank(this.ifKeyId) && this.objIFAuthHeadInfoLst.size() >0) {

                for (API_Authenticationkey__mdt hdmap : objIFAuthHeadInfoLst) {
                    request.setHeader(hdmap.HeaderLab__c, hdmap.HeaderKey__c);
                }
                if(this.ifKeyId.equals('IF_RELAY_INFO')) {
                    request.setHeader('Interface_req_dt', String.valueOf(Datetime.now().format('yyyyMMddHHmmss')));
                }
                
                // if 프로그램에 세팅된 헤더값이 있는경우
                Map<String,String> header = String.isNotEmpty(objIFMaster.Header__c) ? null 
                : (Map<String,String>)JSON.deserializeStrict((String)objIFMaster.Header__c, Map<String,String>.class);

                if(header != null && !header.isEmpty())
                {
                  for(String key : header.keySet())
                    {
                        request.setHeader(key, (String) header.get(key));
                    }
                    this.logWrap.RequestHeader = Json.serialize(header);
                }

            }


            
            String endPointUrl = this.objIFMaster.Endpoint__c;
            

            request.setMethod(this.objIFMaster.Method__c);
            request.setTimeout(110000);         

            String contentType = this.objIFMaster.ContentType__c;

            request.setHeader('Content-Type', contentType);
            
            if(contentType.contains('multipart')) {                
                //request.setHeader('Content-Length', String.valueOf(requestBody.length()));
                request.setBodyAsBlob(EncodingUtil.base64Decode(requestBody));
                contentType = contentType+' charset=utf-8; boundary='+'vguardiance';
            }
            
            objWrapper.requestBody = requestBody;

            
            // request.setBody를 할 경우 Method GET으로 설정을 해도 실제로는 POST로 전송되기 때문에 분기처리해준다
            if(objIFMaster.Method__c == 'POST') {
                if(contentType == 'application/x-www-form-urlencoded') {
                    requestBody = EncodingUtil.urlEncode(requestBody, 'UTF-8');
                }
                request.setBody(requestBody);
            }else if(objIFMaster.Method__c == 'PUT') {
                endPointUrl = endPointUrl +'?_HttpMethod=PATCH';
                request.setMethod('POST');
                //request.setHeader('X-HTTP-Method-Override', 'PATCH');
                request.setBody(requestBody);

            }else if(objIFMaster.Method__c == 'GET' && (requestBody <> null && requestBody != '')) {

                endPointUrl = String.isNotBlank(requestBody) ?  endPointUrl+'?'+requestBody : endPointUrl;

                endPointUrl = String.isNotBlank(this.objIFMaster.Param1__c) ?                 
                (endPointUrl.contains('?') ?  endPointUrl + '&' + this.objIFMaster.Param1__c :endPointUrl + '?' + this.objIFMaster.Param1__c)
                : endPointUrl;

                endPointUrl = String.isNotBlank(this.objIFMaster.Param2__c) ?                 
                (endPointUrl.contains('?') ?  endPointUrl + '&' + this.objIFMaster.Param2__c :endPointUrl + '?' + this.objIFMaster.Param2__c)
                : endPointUrl;    
                
                endPointUrl = String.isNotBlank(this.objIFMaster.Param3__c) ?                 
                (endPointUrl.contains('?') ?  endPointUrl + '&' + this.objIFMaster.Param3__c :endPointUrl + '?' + this.objIFMaster.Param3__c)
                : endPointUrl;        
                
                endPointUrl = String.isNotBlank(this.objIFMaster.Param4__c) ?                 
                (endPointUrl.contains('?') ?  endPointUrl + '&' + this.objIFMaster.Param4__c :endPointUrl + '?' + this.objIFMaster.Param4__c)
                : endPointUrl;




               if(String.isNotBlank(this.ifKeyId) && this.objIFAuthGetParamInfoLst.size() >0) {
                    for (API_Authenticationkey__mdt paramdmap : objIFAuthGetParamInfoLst) {
                        endPointUrl = endPointUrl.contains('?') ?  endPointUrl + '&' +paramdmap.HeaderLab__c + '=' + paramdmap.HeaderKey__c
                        :  endPointUrl + '?' +paramdmap.HeaderLab__c + '=' + paramdmap.HeaderKey__c;
                    }
                }
            }

            request.setEndpoint(endPointUrl);


            System.debug('request :: ' + request);
            response = http.send(request);
            
            responseBody = response.getBody();

            Boolean redirect;

            if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                if(responseBody <> null && responseBody != '') {
                   
                    
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
            //setLog(objWrapper);
        }
        return response;
    }
    
    
}