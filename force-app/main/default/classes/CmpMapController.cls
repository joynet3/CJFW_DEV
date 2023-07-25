/**
 * @description       : 
 * @author            : (서원) won.seo@daeunextier.com
 * @group             : 
 * @last modified on  : 08-26-2022
 * @last modified by  : (서원) won.seo@daeunextier.com
**/
public with sharing class CmpMapController {
    public class Body{
        public Integer code;
        public String message;
        public String currentDateTime;
        public Route route;
    }

    public class Route{
        public List<Traoptimal> traoptimal;
    }

    public class Traoptimal{
        public Summary summary;
        // public List<List<Latlng>> path;
        // public List<Section> section;
        // public List<Guide> guide;
    }

    public class Summary{
        public Integer distance;
        public Integer tollFare;
        public Integer taxiFare;
        public Integer fuelPrice;
    }

    public class SearchBody{
        public Integer total;
        public Integer start;
        public Integer display;
        public List<Items> items;
    }

    public class Items{
        public String title {get;set;}
        public String address {get;set;}
        public String roadAddress {get;set;}
        public String mapx {get;set;}
        public String mapy {get;set;}
    }

    // public class Latlng{
    //     public Long lat;
    //     public Long lng;
    // }

    // public class Section{
    //     public Integer pointIndex;
    //     public Integer pointCount;
    //     public Integer distance;
    //     public String name;
    //     public Integer congestion;
    //     public Integer speed;
    // }

    // public class Guide{
    //     public Integer pointIndex;
    //     public Integer type;
    //     public String instructions;
    //     public Integer distance;
    //     public Integer duration;
    // }

    // -----------------------TMAP----------------------------------
    public class TmapResBody{
        public SearchPoiInfo searchPoiInfo;
    }

    public class SearchPoiInfo{
        public Integer totalCount;
        public Integer count;
        public Integer page;
        public Pois pois;
    }

    public class Pois{
        public List<Poi> poi;
    }

    public class Poi{
        public String name;
        public String noorLat;
        public String noorLon;
        public String telNo;
        public String upperAddrName;
        public String middleAddrName;
        public String lowerAddrName;
        public String detailAddrName;
        public String firstNo;
        public String secondNo;
        public String zipCode;
        public NewAddressList newAddressList;
    }

    public class NewAddressList{
        public List<NewAddress> newAddress;
    }

    public class NewAddress{
        public String fullAddressRoad;
    }



    @AuraEnabled
    public static String getPrefix(){
        String prefix = URL.getSalesforceBaseUrl().toExternalForm();

        // System.debug('Base URL: ' + prefix);

        return prefix;
    }

    // @AuraEnabled
    // public static Map<String, Object> getDistanceApex(Map<String, String> mapParam){

    //     LogWrapper LogWrapper = new LogWrapper();
    //     LogWrapper.requestTime = Datetime.now();

    //     String strStatus = 'SUCCESS';
    //     String strCode = '0000';
    //     String strMessage = 'callout success';
    //     String result = '';
    //     Map<String, Object> summaryMap = new Map<String, Object>();

    //     String curl = 'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving?start=' + mapParam.get('startCoord') + '&goal=' + mapParam.get('goalCoord');
    //     String client_id = 'dlkz6dt5jj';
    //     String client_secret = 'dNLOTJvl3IfBdW5sslLqWKsxQ4hN4uA5237sBomD';

    //     try {
    //         HttpRequest request = new HttpRequest();
    //         HttpResponse response = new HttpResponse();
    //         Http http = new Http();
    
    //         request.setMethod('GET');
    //         request.setEndpoint(curl);
    //         request.setHeader('content-type', 'application/json');
    //         request.setHeader('X-NCP-APIGW-API-KEY-ID', client_id);
    //         request.setHeader('X-NCP-APIGW-API-KEY', client_secret);
    
    //         response = http.send(request);
    //         System.debug('status: ' + response.getStatusCode());

    //         if (response.getStatusCode() == 200) {
    //             result += String.valueOf(response.getBody());
    //             Body jsonBody = (Body) JSON.deserialize(response.getBody(), Body.class);
    //             Summary jsonSummary = jsonBody.route.traoptimal[0].summary;
    //             summaryMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(jsonSummary));

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
            
    //         IFUtil objIF = new IFUtil('CmpMapController');
    //         objIF.setLog(LogWrapper);
    //     }

    //     return summaryMap;
    // }

    // @AuraEnabled
    // public static List<Map<String, Object>> searchPlace(String keyword){

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
        
    //     String curl = 'https://openapi.naver.com/v1/search/local.json?query=' + utfKeyword + '&display=10&start=1&sort=random';
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
    //             // SearchBody jsonResponse = (SearchBody) JSON.deserialize(response.getBody(), SearchBody.class);
    //             Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    //             System.debug('======================:::totalCount:::' + jsonResponse.get('total'));
    //             System.debug('jsonResponse::::::: ' + jsonResponse);

    //             System.debug(JSON.serialize(jsonResponse.get('items')));
    //             List<Object> listItems = (List<Object>) jsonResponse.get('items');
    //             System.debug('listItems::::::: ' + listItems);
    //             // List<Items> listItems = jsonResponse.items;
    //             for (Object obj : listItems) {
    //                 itemsResult.add((Map<String, Object>)obj);
    //             }

    //             System.debug('itemsResult::::::: ' + itemsResult);
                
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

    //     return itemsResult;
    // }

}