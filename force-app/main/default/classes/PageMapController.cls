/**
 * @description       : 
 * @author            : (서원) won.seo@daeunextier.com
 * @group             : 
 * @last modified on  : 02-21-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PageMapController {
    // public class SearchBody{
    //     public Integer total;
    //     public Integer start;
    //     public Integer display;
    //     public List<Items> items;
    // }

    // public class Items{
    //     public String title {get;set;}
    //     public String address {get;set;}
    //     public String roadAddress {get;set;}
    //     public String mapx {get;set;}
    //     public String mapy {get;set;}
    // }

    // public Integer NumberOfRecords {get; set;}
    // public List<Items> itemResults {get; set;}

    // -----------------------TMAP----------------------------------

    public List<NewResultList> tmapItemResults {get; set;}
    public String jsonResultList {get; set;}
    public Integer countValue {get; set;}
    public String apexCurrentAddr {get; set;}

    public class TmapResBody{
        public SearchPoiInfo searchPoiInfo {get; set;}
    }

    public class SearchPoiInfo{
        public Integer totalCount {get; set;}
        public Integer count {get; set;}
        public Integer page {get; set;}
        public Pois pois {get; set;}
    }

    public class Pois{
        public List<Poi> poi {get; set;}
    }

    public class Poi{
        public String name {get; set;}
        public String noorLat {get; set;}
        public String noorLon {get; set;}
        public String telNo {get; set;}
        public String upperAddrName {get; set;}
        public String middleAddrName {get; set;}
        public String lowerAddrName {get; set;}
        public String detailAddrName {get; set;}
        public String firstNo {get; set;}
        public String secondNo {get; set;}
        public String zipCode {get; set;}
        public NewAddressList newAddressList {get; set;}
    }

    public class NewAddressList{
        public List<NewAddress> newAddress {get; set;}
    }

    public class NewAddress{
        public String fullAddressRoad {get; set;}
    }

    public class NewResultList{
        public String chr {get; set;}
        public String type {get; set;}
        public String name {get; set;}
        public String telNo {get; set;}
        public String noorLat {get; set;}
        public String noorLon {get; set;}
        public String addr {get; set;}
        public String zipCode {get; set;}
        public String roadAddr {get; set;}
        public String index {get; set;}
    }

    public class ViaRequestData {
        public String startName;
        public String startX;
        public String startY;
        public String endName;
        public String endX;
        public String endY;
        public List<ViaPoints> viaPoints;
        public String searchOption;
    }

    public class ViaPoints {
        public String viaPointId;
        public String viaPointName;
        public String viaX;
        public String viaY;
    }

    // -----------------------TMAP 거리계산----------------------------------
    public String geomDataJsonString {get; set;}

    public PageMapController() {
        // itemResults = new List<Items>();
        tmapItemResults = new List<NewResultList>();
        jsonResultList = '';
        geomDataJsonString = '';
        countValue = 0;
        apexCurrentAddr = '';
    }

    // public void searchPlace(){
    //     String keyword = apexpages.currentPage().getParameters().get('keyword');

    //     System.debug('keyword::::::::' + keyword);

    //     String utfKeyword = EncodingUtil.urlEncode(keyword, 'UTF-8');
    //     System.debug('keyword::::::::' + utfKeyword);

    //     LogWrapper LogWrapper = new LogWrapper();
    //     LogWrapper.requestTime = Datetime.now();
    //     List<Map<String, Object>> itemsResult = new List<Map<String, Object>>();

    //     String strStatus = 'SUCCESS';
    //     String strCode = '0000';
    //     String strMessage = 'callout success';
    //     String result = '';
        
    //     String curl = 'https://openapi.naver.com/v1/search/local.json?query=' + utfKeyword + '&display=5&start=1&sort=random';
    //     String client_id = 'Y0pkJHn0f4rA0XfQ2UUJ';
    //     String client_secret = 'yG78F6F53K';

    //     try {
    //         HttpRequest request = new HttpRequest();
    //         HttpResponse response = new HttpResponse();
    //         Http http = new Http();

    //         request.setMethod('GET');
    //         request.setEndpoint(curl);
    //         request.setHeader('content-type', 'application/json');
    //         request.setHeader('X-Naver-Client-Id', client_id);
    //         request.setHeader('X-Naver-Client-Secret', client_secret);

    //         response = http.send(request);
    //         System.debug('status: ' + response.getStatusCode());

    //         if (response.getStatusCode() == 200) {
    //             result += String.valueOf(response.getBody());
    //             SearchBody jsonResponse = (SearchBody) JSON.deserialize(response.getBody(), SearchBody.class);
    //             System.debug('jsonResponse::::::: ' + jsonResponse);
    //             itemResults = jsonResponse.items;
                
    //         } else {
    //             strCode = '-1';
    //             strStatus = 'ERROR';
    //             strMessage = 'httpcallout error';
    //         }
    //     } catch (Exception e) {
    //         strCode = '-1';
    //         strStatus = 'ERROR';
    //         strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
    //         System.debug(strMessage);
    //     } finally {
    //         LogWrapper.status = strStatus;
    //         LogWrapper.resultCode = strCode;
    //         LogWrapper.resultMessage = 'strMessage:::' + strMessage;
    //         LogWrapper.responseTime = Datetime.now();
    //         LogWrapper.requestBody = curl;
    //         LogWrapper.responseBody = result;
    //         System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
    //         IFUtil objIF = new IFUtil('PageMapController');
    //         objIF.setLog(LogWrapper);
    //     }
    // }

    public void searchTmapPlace() {
        String req = apexpages.currentPage().getParameters().get('req');

        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(req);

        // System.debug('request-MAP:::::::::::::::::' + data);

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'callout success';
        String result = '';
        String utfKeyword = '';

        utfKeyword = EncodingUtil.urlEncode(data.get('search').toString(), 'UTF-8');
        // System.debug('keyword::::::::' + utfKeyword);

        String client_id = 'l7xx154b924aa23843ada86164026fc751d4';
        String curl = 'https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=' + utfKeyword;

        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();

            request.setMethod('GET');
            request.setEndpoint(curl);
            request.setHeader('Accept', 'application/json');
            request.setHeader('appKey', client_id);

            response = http.send(request);
            // System.debug('status: ' + response.getStatusCode());

            result = String.valueOf(response.getBody());

            if (response.getStatusCode() == 200) {
                // System.debug('BODY::::::: ' + response.getBody());
                TmapResBody jsonResponse = (TmapResBody) JSON.deserialize(response.getBody(), TmapResBody.class);
                // System.debug('======================:::totalCount:::' + jsonResponse.searchPoiInfo.totalCount);
                // System.debug('jsonResponse::::::: ' + jsonResponse);

                // System.debug(JSON.serialize(jsonResponse.searchPoiInfo.pois));
                Pois pois = (Pois) jsonResponse.searchPoiInfo.pois;
                List<Poi> listItems = (List<Poi>) pois.poi;
                // System.debug('listItems::::::: ' + listItems);

                tmapItemResults = new List<NewResultList>();
                jsonResultList = '';

                Integer num = 0;
                for (Poi obj : listItems) {
                    NewResultList item = new NewResultList();
                    // Map<String, Object> jsonItem = new Map<String, Object>();
                    
                    if (data.get('type') == 'start') {
                        item.type = 'start';
                        item.index = '';
                    } else if (data.get('type') == 'end') {
                        item.type = 'end';
                        item.index = '';
                    } else if (data.get('type') == 'via') {
                        item.type = 'via';
                        item.index = data.get('index').toString();
                    } else {
                        if (data.get('type') == 'current-start') {
                            item.type = 'current-start';
                            item.index = '';
                        } else if (data.get('type') == 'current-end') {
                            item.type = 'current-end';
                            item.index = '';
                        } else {
                            item.type = 'current-via';
                            item.index = data.get('index').toString();
                        }
                    }

                    if (item.type.contains('current') && num == 1) {
                        break;
                    }

                    String character = 'a'; // From example
                    Integer[] ASCIINumericRepresentation = character.getChars();
                    String nextCharacter = String.fromCharArray(new List<Integer> {ASCIINumericRepresentation[0] + num});

                    item.chr = nextCharacter;
                    item.name = obj.name;
                    item.telNo = obj.telNo;
                    item.noorLat = obj.noorLat;
                    item.noorLon = obj.noorLon;
                    item.addr = obj.lowerAddrName + ' ' + obj.firstNo + '-' + obj.secondNo + ' ' + obj.detailAddrName;
                    item.zipCode = obj.zipCode;
                    
                    for (NewAddress road: obj.newAddressList.newAddress) {
                        item.roadAddr = road.fullAddressRoad;
                    }

                    tmapItemResults.add((NewResultList) item);
                    num++;
                }

                // System.debug('tmapItemResults::::::: ' + tmapItemResults);
                jsonResultList = JSON.serialize(tmapItemResults);

            } else if(response.getStatusCode() == 204) {
                result += String.valueOf(response.getBody());
                // System.debug('BODY::::::: ' + response.getBody());
                tmapItemResults = new List<NewResultList>();
            } 
            else {
                strCode = '-1';
                strStatus = 'ERROR';
                strMessage = 'httpcallout error';
                tmapItemResults = new List<NewResultList>();
            }
        } catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
            tmapItemResults = new List<NewResultList>();
        } finally {
            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'strMessage:::' + strMessage;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = curl;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
            IFUtil objIF = new IFUtil('IF_TMAP_POI');
            objIF.setLog(LogWrapper);
        }
    }

    // 티맵 거리 계산
    // public void getDistance() {
    //     String distanceReq = apexpages.currentPage().getParameters().get('distanceReq');
    //     String dataType = apexpages.currentPage().getParameters().get('dataType');

    //     // System.debug('dataType===============' + dataType);

    //     LogWrapper LogWrapper = new LogWrapper();
    //     LogWrapper.requestTime = Datetime.now();

    //     String strStatus = 'SUCCESS';
    //     String strCode = '0000';
    //     String strMessage = 'callout success';
    //     String result = '';

    //     String client_id = 'l7xx154b924aa23843ada86164026fc751d4';
    //     String curl = '';
    //     String startY = '';
    //     String startX = '';
    //     String endY = '';
    //     String endX = '';
    //     String searchOption = '0';
    //     String body = '';

    //     List<Map<String, Object>> featuresListMap = new List<Map<String, Object>>();
    //     Map<String, Object> firstProperties = new Map<String, Object>();
    //     List<List<List<String>>> geomData = new List<List<List<String>>>();
    //     Map<String, Object> geomDataWrapper = new Map<String, Object>();

    //     String strIFId = '';

    //     if (dataType == 'withVia') {
    //         strIFId = 'IF_TMAP_ROUTE_SEQ_30';
    //         //2023-02-21 다중 경유지30은 Premium App-key 사용
    //         client_id = 'cIFW0iIsXe8PMgxTLLc042Y4s3Sg7em2aYA66WDr';

    //         ViaRequestData viaRequestData = (ViaRequestData) JSON.deserialize(distanceReq, ViaRequestData.class);

    //         System.debug('request-MAP:::::::::::::::::' + viaRequestData);

    //         curl = 'https://apis.openapi.sk.com/tmap/routes/routeSequential30?version=1';

    //         String startName = EncodingUtil.urlEncode(viaRequestData.startName, 'UTF-8');
    //         startX = viaRequestData.startX;
    //         startY = viaRequestData.startY;
    //         String startTime = System.now().format('yyyyMMddHHmm');
    //         String endName = EncodingUtil.urlEncode(viaRequestData.endName, 'UTF-8');
    //         endX = viaRequestData.endX;
    //         endY = viaRequestData.endY;
    //         searchOption = viaRequestData.searchOption;

    //         Map<String, Object> requestData = new Map<String, Object>();
    //         requestData.put('startName', startName);
    //         requestData.put('startX', startX);
    //         requestData.put('startY', startY);
    //         requestData.put('startTime', startTime);
    //         requestData.put('endName', endName);
    //         requestData.put('endX', endX);
    //         requestData.put('endY', endY);
    //         requestData.put('searchOption', searchOption);
    //         List<ViaPoints> reqDataViaPoints = new List<ViaPoints>();
            
    //         for (Integer i=0; i<viaRequestData.viaPoints.size(); i++) {
    //             reqDataViaPoints.add(viaRequestData.viaPoints[i]);
    //         }
    //         requestData.put('viaPoints', reqDataViaPoints);

    //         body = JSON.serialize(requestData);

    //         // System.debug('body:::::::::::::::::' + body);

            

    //     } else {
    //         strIFId = 'IF_TMAP_ROUTE';

    //         Map<String, Object> startEndData = (Map<String, Object>) JSON.deserializeUntyped(distanceReq);

    //         System.debug('request-MAP:::::::::::::::::' + startEndData);
    
    //         curl = 'https://apis.openapi.sk.com/tmap/routes?version=1';
    
    //         startY = startEndData.get('startY').toString();
    //         startX = startEndData.get('startX').toString();
    //         endY = startEndData.get('endY').toString();
    //         endX = startEndData.get('endX').toString();
    //         searchOption = startEndData.get('searchOption').toString();
    //         body = 'startY=' + startY + '&startX=' + startX + '&endY=' + endY + '&endX=' + endX + '&searchOption=' + searchOption;
    
    //         // System.debug('body:::::::::::::::::' + body);
    //     }

    //     try {
    //         HttpRequest request = new HttpRequest();
    //         HttpResponse response = new HttpResponse();
    //         Http http = new Http();

    //         request.setMethod('POST');
    //         request.setEndpoint(curl);
    //         request.setHeader('accept', 'application/json');
    //         request.setHeader('appKey', client_id);
    //         if (dataType == 'withVia') {
    //             request.setHeader('Accept-Language', 'ko');
    //             request.setHeader('Content-Type', 'application/json');
    //         }
    //         request.setBody(body);

    //         response = http.send(request);
    //         // System.debug('status: ' + response.getStatusCode());
    //         result = String.valueOf(response.getBody());

    //         if (response.getStatusCode() == 200) {
                
    //             // System.debug('BODY::::::: ' + response.getBody());
    //             Map<String, Object> distanceJson = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

    //             if (dataType == 'withVia') {
    //                 Map<String, Object> properties = (Map<String, Object>) distanceJson.get('properties');

    //                 String totalDistanceValue = String.valueOf(((Decimal) Integer.valueOf(properties.get('totalDistance')) /(Decimal)1000.00).setScale(2, System.RoundingMode.HALF_EVEN));
    //                 // System.debug('totalDistanceValue::::::: ' + totalDistanceValue);
    //                 geomDataWrapper.put('totalDistance', totalDistanceValue); 
    //             } else {
    //                 List<Object> features = (List<Object>) distanceJson.get('features');

    //                 for(Object obj : features) {
    //                     featuresListMap.add((Map<String, Object>) obj);
    //                 }
    
    //                 firstProperties = (Map<String, Object>) featuresListMap[0].get('properties');
    //                 String totalDistanceValue = String.valueOf(((Decimal)firstProperties.get('totalDistance')/(Decimal)1000.00).setScale(2, System.RoundingMode.HALF_EVEN));
    //                 // System.debug('totalDistanceValue::::::: ' + totalDistanceValue);
    //                 geomDataWrapper.put('totalDistance', totalDistanceValue); 
    //             }

    //             for( Object featuresObj : (List<Object>) distanceJson.get('features')){ 
    //                 Object geometry = ((Map<String,Object>) featuresObj).get('geometry') ; 
    //                 String type = String.Valueof(((Map<String,Object>) geometry).get('type')) ; 
    //                 if( type == 'LineString'){ 
    //                     Object coordinates = ((Map<String,Object>) geometry).get('coordinates'); 
    //                     List<List<String>> lineString = new List<List<String>>();
    //                     for( Object ls : (List<Object>) coordinates){ 
    //                         List<Object> lsListObj = (List<Object>) ls;
    //                         List<String> xy = new List<String>();

    //                         xy.add(String.valueOf(lsListObj[0]));
    //                         xy.add(String.valueOf(lsListObj[1]));
                            
    //                         lineString.add(xy);
    //                     } 
    //                     geomData.add(lineString);
    //                 }
    //             }
    //             geomDataWrapper.put('lineStringList', geomData); 
    //             geomDataJsonString = JSON.serialize(geomDataWrapper);
    //         } else {
    //             strCode = '-1';
    //             strStatus = 'ERROR';
    //             strMessage = 'httpcallout error';
    //             geomDataWrapper = new Map<String, Object>(); 
    //             geomDataJsonString = '';
    //         }
    //     } catch (Exception e) {
    //         strCode = '-1';
    //         strStatus = 'ERROR';
    //         strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
    //         System.debug(strMessage);
    //     } finally {
    //         LogWrapper.status = strStatus;
    //         LogWrapper.resultCode = strCode;
    //         LogWrapper.resultMessage = 'strMessage:::' + strMessage;
    //         LogWrapper.responseTime = Datetime.now();
    //         LogWrapper.requestBody = body;
    //         LogWrapper.responseBody = result;
    //         System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
    //         IFUtil objIF = new IFUtil(strIFId);
    //         objIF.setLog(LogWrapper);
    //     }
    // }

    
    // 티맵 거리 계산
    public void getDistance() {
        String distanceReq = apexpages.currentPage().getParameters().get('distanceReq');
        String dataType = apexpages.currentPage().getParameters().get('dataType');

        // System.debug('dataType===============' + dataType);

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();
        

        String strIFId = 'IF_TMAP_ROUTE';
        String client_id = 'l7xx154b924aa23843ada86164026fc751d4';
        String curl = 'https://apis.openapi.sk.com/tmap/routes?version=1';

        List<List<List<String>>> geomData = new List<List<List<String>>>();
        Map<String, Object> geomDataWrapper = new Map<String, Object>();
     
        ViaRequestData requestData = (ViaRequestData) JSON.deserialize(distanceReq, ViaRequestData.class);
        
        String searchOption = requestData.searchOption;

        String startX = requestData.startX;
        String startY = requestData.startY;
        String endX = requestData.endX;
        String endY = requestData.endY;
        String body = '';
        
        String startX_sub = '';
        String startY_sub = '';
        String endX_sub = '';
        String endY_sub = '';
        String body_sub = '';
        Boolean bSubExist = false;
        
        
        if ( requestData.viaPoints == null){
            body = 'startY=' + startY + '&startX=' + startX + '&endY=' + endY + '&endX=' + endX + '&searchOption=' + searchOption;
        } else if ( requestData.viaPoints.size() <= 5){
            body = 'startY=' + startY + '&startX=' + startX + '&endY=' + endY + '&endX=' + endX + '&searchOption=' + searchOption + '&passList=';

            for (Integer i=0; i<requestData.viaPoints.size(); i++) {
                body += requestData.viaPoints[i].viaX + ','+ requestData.viaPoints[i].viaY;
                if ( i < requestData.viaPoints.size()-1 ){
                    body += '_';
                }
            }
        } else if ( requestData.viaPoints.size() > 5){
            bSubExist = true;
            // 첫번째 Callout의 도착지 (6번째 경유지) 
            endX = requestData.viaPoints[5].viaX;
            endY = requestData.viaPoints[5].viaY;
            body = 'startY=' + startY + '&startX=' + startX + '&endY=' + endY + '&endX=' + endX + '&searchOption=' + searchOption + '&passList=';

            // 경유지 1~5번 설정 
            for (Integer i=0; i<=4; i++) {
                body += requestData.viaPoints[i].viaX + ','+ requestData.viaPoints[i].viaY;
                if ( i <= 4 ){
                    body += '_';
                }
            }

            // 두번째 Callout의 출발지 (6번째 경유지)
            startX_sub = requestData.viaPoints[5].viaX;
            startY_sub = requestData.viaPoints[5].viaY;

            // 두번째 Callout의 도착지 (기존 도착지)  
            endX_sub = requestData.endX;
            endY_sub = requestData.endY;

            // 경유지 7~9 번설정
            body_sub = 'startY=' + startY_sub + '&startX=' + startX_sub + '&endY=' + endY_sub + '&endX=' + endX_sub + '&searchOption=' + searchOption;
            if (requestData.viaPoints.size() >= 7){
                body_sub = 'startY=' + startY_sub + '&startX=' + startX_sub + '&endY=' + endY_sub + '&endX=' + endX_sub + '&searchOption=' + searchOption + '&passList=';
                for (Integer j=6; j<requestData.viaPoints.size(); j++){
                    body_sub += requestData.viaPoints[j].viaX + ','+ requestData.viaPoints[j].viaY;
                    if ( j < requestData.viaPoints.size()-1 ){
                        body_sub += '_';
                    }
                }
            }
        }
        
        System.debug('body :: ' + body);
        System.debug('body_sub :: ' + body_sub); 

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'callout success';
        String result = '';
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();

            request.setMethod('POST');
            request.setEndpoint(curl);
            request.setHeader('accept', 'application/json');
            request.setHeader('appKey', client_id);
            request.setBody(body);

            response = http.send(request);
            result = String.valueOf(response.getBody());

            if (response.getStatusCode() == 200) {
                Map<String, Object> distanceJson = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                System.debug('BODY::::::: ' + response.getBody());

                List<Object> features = (List<Object>) distanceJson.get('features');
                Map<String, Object> firstProperties = new Map<String, Object>();
                firstProperties = (Map<String, Object>) ((Map<String, Object>) features[0]).get('properties');
                             
                String totalDistanceValue = String.valueOf(((Decimal)firstProperties.get('totalDistance')/(Decimal)1000.00).setScale(2, System.RoundingMode.HALF_EVEN));
                geomDataWrapper.put('totalDistance', totalDistanceValue); 

                System.debug('totalDistanceValue ::: ' +totalDistanceValue);
                
                integer count = 0;
                for( Object featuresObj : (List<Object>) distanceJson.get('features')){ 
                    Object geometry = ((Map<String,Object>) featuresObj).get('geometry') ; 
                    String type = String.Valueof(((Map<String,Object>) geometry).get('type')) ; 
                    Object properties = ((Map<String,Object>) featuresObj).get('properties') ; 
                    String description = String.Valueof(((Map<String,Object>) properties).get('description')) ; 

                    if( type == 'LineString' && description != '경유지와 연결된 가상의 라인입니다' ){ 
                        Object coordinates = ((Map<String,Object>) geometry).get('coordinates'); 
                        List<List<String>> lineString = new List<List<String>>();
                        for( Object ls : (List<Object>) coordinates){ 
                            List<Object> lsListObj = (List<Object>) ls;
                            List<String> xy = new List<String>();

                            xy.add(String.valueOf(lsListObj[0]));
                            xy.add(String.valueOf(lsListObj[1]));
                            
                            lineString.add(xy);
                        }
                        geomData.add(lineString);
                    }
                } 

                if (bSubExist){
                    String strStatussub = 'SUCCESS';
                    String strCodesub = '0000';
                    String strMessagesub = 'callout success';
                    String resultsub = '';
                    try {
                        HttpRequest requestsub = new HttpRequest();
                        HttpResponse responsesub = new HttpResponse();
                        Http httpsub = new Http();

                        requestsub.setMethod('POST');
                        requestsub.setEndpoint(curl);
                        requestsub.setHeader('accept', 'application/json');
                        requestsub.setHeader('appKey', client_id);
                        requestsub.setBody(body_sub);
                        System.debug('BODY::::::: ' + body_sub);

                        responsesub = httpsub.send(requestsub);
                        resultsub = String.valueOf(responsesub.getBody());

                        if (responsesub.getStatusCode() == 200) {
                            
                            // System.debug('BODY::::::: ' + response.getBody());
                            Map<String, Object> distanceJsonSub = (Map<String, Object>) JSON.deserializeUntyped(responsesub.getBody());

                            List<Object> featuresSub = (List<Object>) distanceJsonSub.get('features');

                            Map<String, Object> firstPropertiesSub = new Map<String, Object>();
                            firstPropertiesSub = (Map<String, Object>) ((Map<String, Object>) featuresSub[0]).get('properties');
                            
                            Decimal firstTotalDistanceValue = Decimal.valueOf(String.valueOf(geomDataWrapper.get('totalDistance')));
                            firstTotalDistanceValue += ((Decimal)firstPropertiesSub.get('totalDistance')/(Decimal)1000.00).setScale(2, System.RoundingMode.HALF_EVEN);
                            totalDistanceValue = String.valueOf(firstTotalDistanceValue);
                            geomDataWrapper.put('totalDistance', totalDistanceValue); 

                            for( Object featuresObj : (List<Object>) distanceJsonSub.get('features')){ 
                                Object geometry = ((Map<String,Object>) featuresObj).get('geometry') ; 
                                String type = String.Valueof(((Map<String,Object>) geometry).get('type')) ; 
                                Object properties = ((Map<String,Object>) featuresObj).get('properties') ; 
                                String description = String.Valueof(((Map<String,Object>) properties).get('description')) ; 
                                if( type == 'LineString' && description != '경유지와 연결된 가상의 라인입니다' ){ 
                                    Object coordinates = ((Map<String,Object>) geometry).get('coordinates'); 
                                    List<List<String>> lineString = new List<List<String>>();
                                    for( Object ls : (List<Object>) coordinates){ 
                                        List<Object> lsListObj = (List<Object>) ls;
                                        List<String> xy = new List<String>();

                                        xy.add(String.valueOf(lsListObj[0]));
                                        xy.add(String.valueOf(lsListObj[1]));                    
                                        lineString.add(xy);
                                    } 
                                    geomData.add(lineString);
                                }
                            }
                            System.debug(geomData);
                            
                        } else {
                            strCode = '-1';
                            strStatus = 'ERROR';
                            strMessage = 'httpcallout error';
                            geomDataWrapper = new Map<String, Object>(); 
                            geomDataJsonString = '';
                        }
                    } catch (Exception e) {
                        strCode = '-1';
                        strStatus = 'ERROR';
                        strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
                        System.debug(strMessage);
                    } finally {
                        LogWrapper.status = strStatussub;
                        LogWrapper.resultCode = strCodesub;
                        LogWrapper.resultMessage = 'strMessage:::' + strMessagesub;
                        LogWrapper.responseTime = Datetime.now();
                        LogWrapper.requestBody = body_sub;
                        LogWrapper.responseBody = resultsub;
                        System.debug('===========================finally:::'+strMessagesub+'  status:::'+strStatussub+'  code:::'+strCodesub);
                        
                        IFUtil objIF = new IFUtil(strIFId);
                        objIF.setLog(LogWrapper);
                    }
                }
                geomDataWrapper.put('lineStringList',geomData); 
                geomDataJsonString = JSON.serialize(geomDataWrapper);

            } else {
                strCode = '-1';
                strStatus = 'ERROR';
                strMessage = 'httpcallout error';
                geomDataWrapper = new Map<String, Object>(); 
                geomDataJsonString = '';
            }
        } catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
        } finally {
            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'strMessage:::' + strMessage;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = body;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
            IFUtil objIF = new IFUtil(strIFId);
            objIF.setLog(LogWrapper);
        }
    }

    // 경유지 추가를 위한 카운트
    public void increaseDecreaseCount() {
        Integer varCount = Integer.valueOf(apexpages.currentPage().getParameters().get('count'));
        countValue = varCount;
    }

    // 좌표로 주소 받아오기
    public void getReverseGeocoding() {
        String latlng = apexpages.currentPage().getParameters().get('latlng');

        System.debug('latlng:::::::::::::::::' + latlng);

        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(latlng);

        System.debug('request-MAP:::::::::::::::::' + data);

        String lat = String.valueOf(data.get('lat'));
        String lng = String.valueOf(data.get('lng'));

        // String lat = String.valueOf(37.5494414767581);
        // String lng = String.valueOf(127.05049870491071);

        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'callout success';
        String result = '';

        String client_id = 'l7xx154b924aa23843ada86164026fc751d4';
        String curl = 'https://apis.openapi.sk.com/tmap/geo/reversegeocoding?version=1&lat=' + lat + '&lon=' + lng;

        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();

            request.setMethod('GET');
            request.setEndpoint(curl);
            request.setHeader('Accept', 'application/json');
            request.setHeader('appKey', client_id);

            response = http.send(request);
            System.debug('status: ' + response.getStatusCode());
            result = String.valueOf(response.getBody());

            if (response.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                System.debug('responseBody:::::::::::::::' + responseBody);

                Map<String, Object> addressInfo = (Map<String, Object>) responseBody.get('addressInfo');
                System.debug('addressInfo:::::::::::::::' + addressInfo);

                String addr = String.valueOf(addressInfo.get('fullAddress'));
                System.debug('addr:::::::::::::::' + addr);

                apexCurrentAddr = addr;
            }
        } catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
        } finally {
            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'strMessage:::' + strMessage;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = curl;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
            IFUtil objIF = new IFUtil('IF_TMAP_GEO');
            objIF.setLog(LogWrapper);
        }


    }

    // 경유지 삭제를 위한 카운트
    // public void decreaseCount() {
    //     Integer delData = Integer.valueOf(apexpages.currentPage().getParameters().get('delData'));

    //     Map<String, String> jsonDelData = (Map<String, Object>) JSON.deserializeUntyped(delData);
    //     System.debug('jsonDelData===================' + jsonDelData);

    //     countValue = Integer.valueOf(jsonDelData.get('keyCount'));
    //     System.debug('countValue===================' + countValue);
    // }
}