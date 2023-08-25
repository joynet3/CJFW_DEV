/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class PageMapController_test {
    @testSetup
	static void setData() {
        Set<String> setIFId = new Set<String>{'TMapController', 'IF_TMAP_ROUTE', 'IF_TMAP_GEO', 'IF_TMAP_ROUTE_SEQ_30', 'IF_TMAP_POI'};

        List<IFMaster__c> listIF = new List<IFMaster__c>();

        for(String str : setIFId) {
            IFMaster__c obj = new IFMaster__c();
            obj.Name = str;
            obj.ContentType__c = 'application/json';
            obj.Endpoint__c = 'https://test.salesforce.com';
            obj.Method__c = 'POST';
            obj.Type__c = 'Inbound';
            obj.WebServiceType__c = 'REST';

            listIF.add(obj);
        }

        insert listIF;
	}

    @isTest 
    static void itShould() {
        PageMapController.SearchPoiInfo objSPOI = new PageMapController.SearchPoiInfo();
        objSPOI.totalCount = 1;
        objSPOI.count = 1;
        objSPOI.page = 1;

        PageMapController.Poi objPOI = new PageMapController.Poi();
        objPOI.name = 'test';
        objPOI.noorLat = 'test';
        objPOI.noorLon = 'test';
        objPOI.telNo = 'test';
        objPOI.upperAddrName = 'test';
        objPOI.middleAddrName = 'test';
        objPOI.lowerAddrName = 'test';
        objPOI.detailAddrName = 'test';
        objPOI.firstNo = 'test';
        objPOI.secondNo = 'test';
        objPOI.zipCode = 'test';

        PageMapController.NewResultList objNewR = new PageMapController.NewResultList();
        objNewR.chr = 'test';
        objNewR.type = 'test';
        objNewR.name = 'test';
        objNewR.telNo = 'test';
        objNewR.noorLat = 'test';
        objNewR.noorLon = 'test';
        objNewR.addr = 'test';
        objNewR.zipCode = 'test';
        objNewR.roadAddr = 'test';
        objNewR.index = 'test';

        PageMapController objTarget = new PageMapController();
        ApexPages.currentPage().getParameters().put('count', '5');

        objTarget.increaseDecreaseCount();
    }

    @isTest 
    static void test_searchTmapPlace() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockPOI());

        PageMapController objTarget = new PageMapController();
        Map<String, Object> mapReq = new Map<String, Object>();
        mapReq.put('search', 'test');
        ApexPages.currentPage().getParameters().put('req', JSON.serialize(mapReq));

        objTarget.searchTmapPlace();
        Test.stopTest();
    }

    @isTest 
    static void test_getDistance() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockRoutes());

        PageMapController objTarget = new PageMapController();

        PageMapController.ViaRequestData objWrapper = new PageMapController.ViaRequestData();
        List<PageMapController.ViaPoints> listVia = new List<PageMapController.ViaPoints>();

        objWrapper.startName = 'test';
        objWrapper.startX = 'test';
        objWrapper.startY = 'test';
        objWrapper.endName = 'test';
        objWrapper.endX = 'test';
        objWrapper.endY = 'test';
        objWrapper.viaPoints = listVia;
        objWrapper.searchOption = 'test';

        ApexPages.currentPage().getParameters().put('distanceReq', JSON.serialize(objWrapper));
        ApexPages.currentPage().getParameters().put('dataType', 'test');
        objTarget.getDistance();

        ApexPages.currentPage().getParameters().put('dataType', 'withVia');
        objTarget.getDistance();

        Test.stopTest();
    }
    
    @isTest 
    static void test_getReverseGeocoding() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockGEO());

        PageMapController objTarget = new PageMapController();
        Map<String, Object> mapObj = new Map<String, Object>();
        mapObj.put('lat', 'test');
        mapObj.put('lng', 'test');

        ApexPages.currentPage().getParameters().put('latlng', JSON.serialize(mapObj));
        objTarget.getReverseGeocoding();
        Test.stopTest();
    }

    private class HttpCalloutSuccessMockPOI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseTMapPlace(200);

            return response;
        }
    }

    private static HTTPResponse newResponseTMapPlace(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"searchPoiInfo":{"totalCount": "1394","count": "20","page":"1","pois":{"poi":[{"id":"187757","pkey":"18775700","navSeq":"0","collectionType":"poi","name":"코엑스","telNo":"02-6000-0114","frontLat":"37.51182308","frontLon":"127.05759870","noorLat":"37.51201753","noorLon":"127.05909856","upperAddrName":"서울","middleAddrName":"강남구","lowerAddrName":"삼성동","detailAddrName":"","mlClass":"1","firstNo":"159","secondNo":"","roadName":"영동대로","firstBuildNo":"513","secondBuildNo":"","radius":"0.0","bizName":"","upperBizName":"생활편의","middleBizName":"문화생활시설","lowerBizName":"전시장","detailBizName":"기타","rpFlag":"16","parkFlag":"1","detailInfoFlag":"1","desc":"test","dataKind":"","zipCode":"06164","newAddressList":{"newAddress":[{"centerLat":"37.51201753","centerLon":"127.05909856","frontLat":"37.51182308","frontLon":"127.05759870","roadName":"영동대로","bldNo1":"513","bldNo2":"","roadId":"00668","fullAddressRoad":"서울 강남구 영동대로 513"}]},"evChargers":{"evCharger":[]}}]}}}');

        return response;
    }

    private class HttpCalloutSuccessMockRoutes implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseRoutes(200);

            return response;
        }
    }

    private static HTTPResponse newResponseRoutes(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{ "type": "FeatureCollection", "features": [ {"type": "Feature", "geometry": { "type": "Point", "coordinates": [126.88892596836935,37.582165148940625 ] }, "properties":{ "totalDistance": 22794, "totalTime": 1942, "totalFare": 0, "taxiFare": 20100, "index": 0, "pointIndex": 0, "name": "", "description": "일반도로 을 따라 방면으로 20m 이동", "nextRoadName": "일반도로", "turnType": 200, "pointType": "S" } }]}');

        return response;
    }

    private class HttpCalloutSuccessMockGEO implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponseGEO(200);

            return response;
        }
    }

    private static HTTPResponse newResponseGEO(Integer statusCode) {
        HttpResponse response = new HttpResponse();

        // response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"addressInfo":{"fullAddress":"test"}}');

        return response;
    }

}