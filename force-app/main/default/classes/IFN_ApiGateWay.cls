/**
* @Class : IFN_ApiGateWay
* @group Framework : Common
* @Author : 조일근 
* @Date : 2023. 07. 18
* @Version : 1.0
* @Description : 
* @Modified : 인터페이스 호출용 공통 프로그램
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2023. 07. 18 | 조일근    | 최초작성
* */
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

        IFMaster__c objIFMasterINF = new IFMaster__c();
        List<API_Authenticationkey__mdt> objIFAuthHeadInfo = new List<API_Authenticationkey__mdt>();
        List<API_Authenticationkey__mdt> objIFAuthgetParamInfo = new List<API_Authenticationkey__mdt>();

        this.ifKeyId = ifId;        

        objIFMasterINF = [
            SELECT Id, Name,
                    InterfaceId__c, Type__c, WebserviceType__c, Endpoint__c, Method__c, ContentType__c,ifKeyId__c,Header__c,
                    Param1__c,Param2__c,Param3__c,Param4__c
            FROM IFMaster__c
            WHERE Name =:ifId
            Limit 1
        ];

        objIFAuthHeadInfo = [select  MasterLabel,    QualifiedApiName, KeyValue__c, DateRange__c,  
        HeaderKey__c, HeaderLab__c, keyValueSp__c 
        from API_Authenticationkey__mdt 
        where IfHeaderKeyId__c = :ifId
        and keyValueSp__c = 'head'
        ];

        this.objIFAuthHeadInfoLst = objIFAuthHeadInfo;

        objIFAuthgetParamInfo = [select  MasterLabel,    QualifiedApiName, KeyValue__c, DateRange__c,  
        HeaderKey__c, HeaderLab__c, keyValueSp__c 
        from API_Authenticationkey__mdt 
        where IfHeaderKeyId__c = :ifId
        and keyValueSp__c = 'param'
        ];
        this.objIFAuthGetParamInfoLst = objIFAuthgetParamInfo;            

        this.objIFMaster = objIFMasterINF;


    }



 /**
     * I/F 웹서비스 호출(Sync)
     * 
     * @param requestBody 요청값
     * @param isLogInsert Log(IFLog__c) 생성여부
     * @param dynamicHd   헤더 값이 프로그램에서 만들어지는 헤더값
     * @return
     *         
    **/
    public HttpResponse webCallout(String requestBody,Map<String,String> dynamicHd, Boolean isLogInsert) {
        HttpRequest request = new HttpRequest();
		HttpResponse response = new HttpResponse();
		Http http = new Http();
        this.commlog         = new IFN_CommonLog();
                

        String status = 'SUCCESS';
        String responseBody;
		String resultCode = '0';
        String resultMessage = '';
        this.logwrap = new IFN_CommonLog.logWrap(this.ifKeyId,'Real');
        try {
            
            this.logWrap.requestTime = Datetime.now();


            IF_RELAY_INFO__c objRelayInfo = IF_RELAY_INFO__c.getOrgDefaults();
            String contentType = this.objIFMaster.ContentType__c;

            if(String.isNotBlank(this.ifKeyId)) request.setHeader('Interface_id', this.ifKeyId);
            if(String.isNotBlank(objRelayInfo.Interface_auth_key__c)) request.setHeader('Interface_auth_key', objRelayInfo.Interface_auth_key__c);
            if(String.isNotBlank(contentType)) request.setHeader('Content-Type', contentType);


            // if 정보 메타 데이터 정보상의 헤더값 리스트가 있는 경우 헤더 세팅
            if(String.isNotBlank(this.ifKeyId) && this.objIFAuthHeadInfoLst !=null && this.objIFAuthHeadInfoLst.size() >0) {

                for (API_Authenticationkey__mdt hdmap : objIFAuthHeadInfoLst) {
                    request.setHeader(hdmap.HeaderLab__c, hdmap.HeaderKey__c);
                }

            }

            

            // if 프로그램에 세팅된 헤더값이 있는경우
            Map<String,String> header = new Map<String,String>();
            if(String.isNotEmpty(objIFMaster.Header__c)) {
                header =  (Map<String,String>)JSON.deserializeStrict((String)objIFMaster.Header__c, Map<String,String>.class);
            }

            if(header != null && !header.isEmpty())
            {
                for(String key : header.keySet())
                {
                    request.setHeader(key, (String) header.get(key));
                }
                this.logWrap.RequestHeader = Json.serialize(header);
            }


            // 프로그램 로직으로 헤더 정보를 전달해야 하는 헤더 값이 있는 경우
            if(dynamicHd !=null && !dynamicHd.isEmpty()) {
                for(String key : dynamicHd.keySet())
                {
                    request.setHeader(key, (String) dynamicHd.get(key));
                }
            }

            
            String endPointUrl = this.objIFMaster.Endpoint__c;
            String strMethod = this.objIFMaster.Method__c.contains('_') ? this.objIFMaster.Method__c.split('_')[0] : this.objIFMaster.Method__c;
            request.setMethod(strMethod);
            request.setTimeout(110000);         

            
            if(contentType.contains('multipart')) {                
                request.setBodyAsBlob(EncodingUtil.base64Decode(requestBody));
                contentType = contentType+' charset=utf-8; boundary='+'vguardiance';
            }
            
            this.logWrap.requestBody = requestBody;

            
            // request.setBody를 할 경우 Method GET으로 설정을 해도 실제로는 POST로 전송되기 때문에 분기처리해준다
            if(objIFMaster.Method__c == 'POST') {
                if(contentType == 'application/x-www-form-urlencoded') {
                    requestBody = EncodingUtil.urlEncode(requestBody, 'UTF-8');
                }
                request.setBody(requestBody);
            }else if(objIFMaster.Method__c == 'PUT') {
                endPointUrl = endPointUrl +'?_HttpMethod=PATCH';
                request.setMethod('POST');
                request.setBody(requestBody);

            }else if(objIFMaster.Method__c == 'GET' ) {

                if(endPointUrl.contains('?') || requestBody.contains('?')){
                    endPointUrl = String.isNotBlank(requestBody) ?  endPointUrl+requestBody : endPointUrl;      // 로직내에서 ? 까지 포함해 조립한 경우
                }else{
                    endPointUrl = String.isNotBlank(requestBody) ?  endPointUrl+'?'+requestBody : endPointUrl;
                }
                

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



            }else if(objIFMaster.Method__c == 'GET_REST' ) {

                endPointUrl = String.isNotBlank(this.objIFMaster.Param1__c) ? endPointUrl + '/' + this.objIFMaster.Param1__c : endPointUrl;
                endPointUrl = String.isNotBlank(this.objIFMaster.Param2__c) ? endPointUrl + '/' + this.objIFMaster.Param2__c : endPointUrl;
                endPointUrl = String.isNotBlank(this.objIFMaster.Param3__c) ? endPointUrl + '/' + this.objIFMaster.Param3__c : endPointUrl;
                endPointUrl = String.isNotBlank(this.objIFMaster.Param4__c) ? endPointUrl + '/' + this.objIFMaster.Param4__c : endPointUrl;


                endPointUrl = String.isNotBlank(requestBody) ?  endPointUrl+'/'+requestBody : endPointUrl;
            }


            System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>> Interface_id' + request.getHeader('Interface_id'));
            System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>> Interface_auth_key' + request.getHeader('Interface_auth_key'));
            System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>> Content-Type' + request.getHeader('Content-Type'));


            request.setEndpoint(endPointUrl);
            
            response = http.send(request);

            

            Boolean redirect;
            //2023.11.16 sancho
            // if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            //     responseBody = response.getBody();

            //     if(responseBody <> null && responseBody != '') {
            //         resultCode   = String.valueOf(response.getStatusCode());
            //         resultMessage = response.getStatus();
            //     }else {
            //         responseBody = 'Not ResponseBody';
            //     }

            //     this.logWrap.responseTime = Datetime.now();
            //     this.logWrap.responseBody = responseBody;
            // }          
            // else {

            //     status = 'ERROR';
            //     resultCode = String.valueOf(response.getStatusCode());
            //     resultMessage = response.getStatus();
            // }
            
            //2023.11.16 : error body 등 확인을 위해 200 외의 것들도 포함.
            status          = (response.getStatusCode() == 200 || response.getStatusCode() == 201) ? String.valueOf(response.getStatusCode()) : 'ERROR';
            resultCode      = String.valueOf(response.getStatusCode());
            resultMessage   = response.getStatus();

            responseBody    = response.getBody();
            responseBody    = (responseBody <> null && responseBody != '') ? responseBody : 'Not ResponseBody';
            this.logWrap.responseTime = Datetime.now();
            this.logWrap.responseBody = responseBody;


            
        }catch(Exception e) {
            status = 'ERROR';
            resultCode = '-1';
            resultMessage = e.getMessage()+'ERROR Line : '+e.getLineNumber();
        }

        this.logWrap.status = status;
        this.logWrap.resultCode = resultCode;
        this.logWrap.resultMessage = resultMessage;

        if(isLogInsert) {
            commlog.insertLog(this.logWrap);
        }
        return response;
    }
    
    
}