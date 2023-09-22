/*
* ==================================================================================
*   File Name   : LineItemMgmtController_test.cls
*   Author      : Minje.Kim
*   Date        : 2022.11.19
*   Target      : LineItemMgmtController.cls
*   Description : QuotoLineItem New Button Override Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.11.19    Minje.Kim    Create
* ==================================================================================
*/
@isTest
private class LineItemMgmtController_test {
    @testSetup
	static void setData() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.EmployeeNumber = '123456';
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = '4700';
        objUser.Team__c = '325';

        update objUser;
       
        Set<String> setIFId = new Set<String>{'IF_IFRESH_SFDC_PRICE_CONTROL_INFO','IF_AI_SFDC_PRODUCT_INFO'};

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
        
        List<Product2> productList = new List<Product2>();
        // product 1개 생성 , 필수값 넣어줘야 생성 됨.
       
        
       
        
	}

    @isTest 
    static void itShould() {

        //product
        Product2 pro = new Product2(
            Name = 'AProduct'
        );
        insert pro;

        LineItemMgmtController.getProduct(pro.id);

        Account objAccount = TestObjectCreator.objHealthAccount;
        insert objAccount;

        PricebookEntry objPriceBookEntry = TestObjectCreator.objPricebookEntry;
        insert objPriceBookEntry;

        Opportunity objOpportunity = new Opportunity();
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Name = '영업활동';
        objOpportunity.CloseDate = date.valueOf('2022-01-01');
        objOpportunity.Pricebook2Id = objPriceBookEntry.Pricebook2Id;
        objOpportunity.StageName = 'Proposal';
        insert objOpportunity;

        Quote objQuote = new Quote();
        objQuote.OpportunityId = objOpportunity.Id;
        objQuote.Pricebook2Id = objPriceBookEntry.Pricebook2Id;
        objQuote.Name = '견적서';
        insert objQuote;

        QuoteLineItem objQuoteLineItem = new QuoteLineItem();
        objQuoteLineItem.QuoteId = objQuote.Id;
        objQuoteLineItem.PricebookEntryId = objPriceBookEntry.Id;
        objQuoteLineItem.UnitPrice = 2000;
        objQuoteLineItem.Quantity = 1;
        insert objQuoteLineItem;

        OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
        objOpportunityLineItem.OpportunityId = objOpportunity.Id;
        objOpportunityLineItem.PricebookEntryId = objPriceBookEntry.Id;
        objOpportunityLineItem.UnitPrice = 2000;
        objOpportunityLineItem.Quantity = 1;
        insert objOpportunityLineItem;

        List<ProductCategory__c> listCategory = new List<ProductCategory__c>();
        ProductCategory__c objCategory = new ProductCategory__c();
        objCategory.Name = 'test category';
        objCategory.gd_cls_lvl_dpt__c = '1';
        objCategory.IsActive__c = true;
        objCategory.gd_cls_id__c = '4010';
        listCategory.add(objCategory);

        ProductCategory__c objCategory2 = new ProductCategory__c();
        objCategory2.Name = 'test category2';
        objCategory2.gd_cls_lvl_dpt__c = '2';
        objCategory2.IsActive__c = true;
        objCategory2.gd_cls_id__c = '4012';
        objCategory2.upp_gd_cls_id__c = '40';
        listCategory.add(objCategory2);

        ProductCategory__c objCategory3 = new ProductCategory__c();
        objCategory3.Name = 'test category3';
        objCategory3.gd_cls_lvl_dpt__c = '2';
        objCategory3.IsActive__c = true;
        objCategory3.gd_cls_id__c = '4013';
        objCategory3.upp_gd_cls_id__c = '40';
        listCategory.add(objCategory3);
        insert listCategory;


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        
        LineItemMgmtController.getLineItem(objQuote.Id, 'Quote');
        LineItemMgmtController.getLineItem(objOpportunity.Id, 'Opportunity');

        
        Map<String, Object> mapParam = new Map<String, Object>();
        mapParam.put('Pricebook2Id', objPriceBookEntry.Pricebook2Id);
        mapParam.put('searchKey', 'product');
        mapParam.put('selectedMonth', 'EarlyJan');
        mapParam.put('selectedCenter', '1000');
        mapParam.put('selectedCategoryL', 'none');
        mapParam.put('sortStatus', 'UPPrice');
        LineItemMgmtController.doSearch(mapParam);


        Map<String, Object> mapParam2 = new Map<String, Object>();
        mapParam2.put('searchKey', 'product');
        mapParam2.put('selectedCenter', '1000');
        LineItemMgmtController.doSearchAI(mapParam2);


        List<String> listTargetEntryCode = new List<String>();
        listTargetEntryCode.add('1000_165272');
        LineItemMgmtController.getCurrentEntry(listTargetEntryCode, '1000','EarlyJan', 'UPCODE', 'Y', '100000000');

        List<QuoteLineItem> listChunkQuoteInsert = new List<QuoteLineItem>();
        objQuoteLineItem.Id =null;
        listChunkQuoteInsert.add(objQuoteLineItem);

        List<OpportunityLineItem> listChunkOpptyInsert = new List<OpportunityLineItem>();
        objOpportunityLineItem.Id = null;
        listChunkOpptyInsert.add(objOpportunityLineItem);

        LineItemMgmtController.doChunkQuote('Insert', listChunkQuoteInsert);
        LineItemMgmtController.doChunkOppty('Insert', listChunkOpptyInsert);
        
        List<QuoteLineItem> listChunkQuoteDelete = new List<QuoteLineItem>();
        listChunkQuoteDelete.add(objQuoteLineItem);

        List<OpportunityLineItem> listChunkOpptyDelete = new List<OpportunityLineItem>();
        listChunkOpptyDelete.add(objOpportunityLineItem);

        LineItemMgmtController.doChunkQuote('Delete', listChunkQuoteDelete);
        LineItemMgmtController.doChunkOppty('Delete', listChunkOpptyDelete);
        
        Test.stopTest();
    }

    // SUCCESS
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(200);
            return response;
        }
    }

    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"total_count":1,"orders":{"0":{"order_nm":"돈까스","TOP1_Y":124165,"TOP1_Y_NM":"소디프 돈까스(135g*10입 1.35Kg/EA)","TOP1_Y_CATE1":"가공식품","TOP1_Y_CATE2":"냉동가공식품","TOP2_Y":127568,"TOP2_Y_NM":"상신 돈까스(HR_200g*10입 2Kg/EA)","TOP2_Y_CATE1":"가공식품","TOP2_Y_CATE2":"냉동가공식품","TOP3_Y":132357,"TOP3_Y_NM":"한미식품 돈까스(유럽풍_130g*10입 1.3Kg/EA)","TOP3_Y_CATE1":"가공식품","TOP3_Y_CATE2":"냉동가공식품","TOP4_Y":148199,"TOP4_Y_NM":"늘찬애 돈까스(70g/개 김밥용 1.4Kg/EA)","TOP4_Y_CATE1":"가공식품","TOP4_Y_CATE2":"냉동가공식품","TOP5_Y":170335,"TOP5_Y_NM":"하늘푸드 돈까스(실속 100g*10입 1Kg/EA)","TOP5_Y_CATE1":"가공식품","TOP5_Y_CATE2":"냉동가공식품","TOP6_Y":140875,"TOP6_Y_NM":"성원 돈까스(135g*10입 1.35Kg/EA)","TOP6_Y_CATE1":"가공식품","TOP6_Y_CATE2":"냉동가공식품","TOP7_Y":148193,"TOP7_Y_NM":"송림 돈까스(고구마치즈_200g*10입 2Kg/EA)","TOP7_Y_CATE1":"가공식품","TOP7_Y_CATE2":"냉동가공식품","TOP8_Y":148252,"TOP8_Y_NM":"송림 돈까스(프리미엄 1.5Kg/EA)","TOP8_Y_CATE1":"가공식품","TOP8_Y_CATE2":"냉동가공식품","TOP9_Y":172184,"TOP9_Y_NM":"이츠웰 돈까스(실속 130g*10입 1.3Kg/EA)","TOP9_Y_CATE1":"가공식품","TOP9_Y_CATE2":"냉동가공식품","TOP10_Y":175765,"TOP10_Y_NM":"한맥 돈까스(35±2g*28±2개입 김밥용 1Kg/EA)","TOP10_Y_CATE1":"가공식품","TOP10_Y_CATE2":"냉동가공식품","TOP11_Y":212421,"TOP11_Y_NM":"늘찬애 돈까스(숙성순살 1.5Kg/EA)","TOP11_Y_CATE1":"가공식품","TOP11_Y_CATE2":"냉동가공식품","TOP12_Y":272222,"TOP12_Y_NM":"하늘푸드 돈까스(300g*5입 1.5Kg/EA)","TOP12_Y_CATE1":"가공식품","TOP12_Y_CATE2":"냉동가공식품","TOP13_Y":273597,"TOP13_Y_NM":"동원 돈까스(프리미엄 1.2Kg/EA)","TOP13_Y_CATE1":"가공식품","TOP13_Y_CATE2":"냉동가공식품","TOP14_Y":342358,"TOP14_Y_NM":"돈까스(밥밥디라라용 소_120g*4입 480g/EA)","TOP14_Y_CATE1":"가공식품","TOP14_Y_CATE2":"냉동가공식품","TOP15_Y":349532,"TOP15_Y_NM":"뻥이요 돈까스(100g*10입 1Kg/EA)","TOP15_Y_CATE1":"가공식품","TOP15_Y_CATE2":"냉동가공식품","TOP16_Y":359170,"TOP16_Y_NM":"돈까스(P용 9147 1.5Kg/EA)","TOP16_Y_CATE1":"가공식품","TOP16_Y_CATE2":"냉동가공식품","TOP17_Y":359903,"TOP17_Y_NM":"돈까스(P용 NEW 1.5Kg/EA)","TOP17_Y_CATE1":"가공식품","TOP17_Y_CATE2":"냉동가공식품","TOP18_Y":360180,"TOP18_Y_NM":"돈까스(P용 9147 750g/EA)","TOP18_Y_CATE1":"가공식품","TOP18_Y_CATE2":"냉동가공식품","TOP19_Y":295569,"TOP19_Y_NM":"치즈돈까스(올빼미돈까스용 12Kg/BOX)","TOP19_Y_CATE1":"가공식품","TOP19_Y_CATE2":"냉동가공식품","TOP20_Y":295568,"TOP20_Y_NM":"왕돈까스(올빼미돈까스용 9.2Kg/BOX)","TOP20_Y_CATE1":"가공식품","TOP20_Y_CATE2":"냉동가공식품"}}}');
        
        return response;
    }
}