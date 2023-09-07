@isTest
public with sharing class IFN_EIF1001_EC003_MD005_TEST {
    @TestSetup
    static void makeData(){
        IFMaster__c ifMaster = new IFMaster__c(
            Name = 'IFN_EIF1001_EC003_MD005',
            Type__c = 'Outbound',
            WebserviceType__c = 'Callout',
            Method__c = 'POST',
            ContentType__c = 'application/json',
            Endpoint__c = 'http://localhost:8060/gwms/crm/rest/EIF1001/EC002/MD003'
        );

        insert ifMaster;

    }

    @isTest
    static void IFN_EIF1001_EC003_MD005_TEST(){
        Test.startTest();


        List<IFN_EIF1001_EC003_MD005.EC003RequstQuickReply> ec003RequstQuickReplyLst = new List<IFN_EIF1001_EC003_MD005.EC003RequstQuickReply>();
        IFN_EIF1001_EC003_MD005.EC003RequstQuickReply ec003RequstQuickReply = new IFN_EIF1001_EC003_MD005.EC003RequstQuickReply();
        ec003RequstQuickReply.name = '1';
        ec003RequstQuickReply.type = '1';
        ec003RequstQuickReply.scheme_android = '1';
        ec003RequstQuickReply.scheme_ios = '1';
        ec003RequstQuickReply.url_mobile = '1';
        ec003RequstQuickReply.url_pc = '1';
        ec003RequstQuickReply.chat_extra = '1';
        ec003RequstQuickReply.chat_event = '1';
        ec003RequstQuickReplyLst.add(ec003RequstQuickReply);
        IFN_EIF1001_EC003_MD005.EC003RequstSupplement ec003RequstSupplement = new IFN_EIF1001_EC003_MD005.EC003RequstSupplement();
        ec003RequstSupplement.quick_reply = ec003RequstQuickReplyLst;

        
        List<IFN_EIF1001_EC003_MD005.EC003RequestList> ec003RequestListlst = new List<IFN_EIF1001_EC003_MD005.EC003RequestList>();
        IFN_EIF1001_EC003_MD005.EC003RequestList ec003RequestList = new IFN_EIF1001_EC003_MD005.EC003RequestList();
        ec003RequestList.description = '1';
        ec003RequestList.title = '1';
        ec003RequestListlst.add(ec003RequestList);

        IFN_EIF1001_EC003_MD005.EC003RequstItem ex003RequstItem = new IFN_EIF1001_EC003_MD005.EC003RequstItem();
        List<IFN_EIF1001_EC003_MD005.EC003RequestSummary> ec003RequestSummarylst = new List<IFN_EIF1001_EC003_MD005.EC003RequestSummary>();
        IFN_EIF1001_EC003_MD005.EC003RequestSummary ec003RequestSummary = new IFN_EIF1001_EC003_MD005.EC003RequestSummary();
        ec003RequestSummary.description = '1';
        ec003RequestSummary.title = '1';
        ec003RequestSummarylst.add(ec003RequestSummary);
        ex003RequstItem.summary = ec003RequestSummarylst;
        ex003RequstItem.itemlist = ec003RequestListlst;




        List<IFN_EIF1001_EC003_MD005.EC003RequstButton> ec003RequstButtonLst = new List<IFN_EIF1001_EC003_MD005.EC003RequstButton>();
        IFN_EIF1001_EC003_MD005.EC003RequstButton ec003RequstButton = new IFN_EIF1001_EC003_MD005.EC003RequstButton();
        ec003RequstButton.name = '1';
        ec003RequstButton.type = '1';
        ec003RequstButton.url_pc = '1';
        ec003RequstButton.url_mobile = '1';
        ec003RequstButton.scheme_android = '1';
        ec003RequstButton.scheme_ios = '1';
        ec003RequstButton.chat_extra = '1';
        ec003RequstButton.chat_event = '1';   
        ec003RequstButtonLst.add(ec003RequstButton);


        IFN_EIF1001_EC003_MD005.EC003RequstImage ec003RequstImage = new IFN_EIF1001_EC003_MD005.EC003RequstImage();
        ec003RequstImage.img_link = '1';
        ec003RequstImage.img_url = '1';

        IFN_EIF1001_EC003_MD005.EC003RequstItemHighlight  ec003RequstItemHighlight = new IFN_EIF1001_EC003_MD005.EC003RequstItemHighlight();
        ec003RequstItemHighlight.description ='1';
        ec003RequstItemHighlight.title ='1';

        

        IFN_EIF1001_EC003_MD005.EC003RequstAttachment ec003RequstAttachment = new IFN_EIF1001_EC003_MD005.EC003RequstAttachment();
        ec003RequstAttachment.button = ec003RequstButtonLst;
        ec003RequstAttachment.item_highlight = ec003RequstItemHighlight;
        ec003RequstAttachment.item = ex003RequstItem;
        ec003RequstAttachment.image = ec003RequstImage;


        IFN_EIF1001_EC003_MD005.EC003RequstFailback ec003RequstFailback = new IFN_EIF1001_EC003_MD005.EC003RequstFailback();
        ec003RequstFailback.failback_type = '1';
        ec003RequstFailback.failback_title = '1';
        ec003RequstFailback.failback_msg = '1';
        ec003RequstFailback.failback_id = '1';

        List<IFN_EIF1001_EC003_MD005.EC003RequstData> callresDatalst = new List<IFN_EIF1001_EC003_MD005.EC003RequstData>();
        IFN_EIF1001_EC003_MD005.EC003RequstData callresData = new IFN_EIF1001_EC003_MD005.EC003RequstData();
        callresData.ad_flag = '1';
        callresData.msg_key = '1';
        callresData.sub_id = '1';
        callresData.sender_number = '1';
        callresData.receiver_number = '1';
        callresData.msg = '1';
        callresData.sender_key = '1';
        callresData.template_code = '1';
        callresData.tile = '1';
        callresData.header = '1';
        callresData.price = 1;
        callresData.currency_type = '1';
        callresData.ad_flag = '1';
        callresData.attachment = ec003RequstAttachment;
        callresData.supplement = ec003RequstSupplement;
        callresData.failback_data = ec003RequstFailback;
        callresDatalst.add(callresData);

        IFN_EIF1001_EC003_MD005.EC003RequstWrapper callres = new IFN_EIF1001_EC003_MD005.EC003RequstWrapper();
        callres.msg_data = callresDatalst;
        callres.msg_type ='1';           

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(JSON.serialize(callres),200)); 
        IFN_EIF1001_EC003_MD005 upload = new IFN_EIF1001_EC003_MD005();
        // Callout Interface
        IFN_CalloutResult calloutResult = upload.callout();

        
        Test.stopTest();
    }


    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method

        public String body{get;set;}
        public Integer statusCode{get;set;}

        public MockHttpResponseGenerator(String body, Integer statusCode)
        {
            this.body = body;
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/text');
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }

}