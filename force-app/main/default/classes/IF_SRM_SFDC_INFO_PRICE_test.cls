/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 11-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class IF_SRM_SFDC_INFO_PRICE_test {

    @TestSetup
    static void makeData(){
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        List<String> listIF = new List<String>{'IF_SRM_SFDC_INFO_PRICE'};

        for(String str : listIF) {
            IFMaster__c objIFMaster = new IFMaster__c();

            objIFMaster.Name = str;
            objIFMaster.Type__c = 'Outbound';
            objIFMaster.WebserviceType__c = 'REST';
            objIFMaster.Method__c = 'POST';
            objIFMaster.ContentType__c = 'application/json';
            objIFMaster.Endpoint__c = 'test';
            
            listIFMaster.add(objIFMaster);
        }

        insert listIFMaster;

        Product2 objProduct = new Product2(Name = 'testproduct', ProductCode = '2450_100098');
        Product2 objProduct2 = new Product2(Name = 'testproduct2', ProductCode = '2450_100099');

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );

        update standardPricebook;
        insert objProduct;
        insert objProduct2;
        
        PricebookEntry objPricebookentry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            product2Id = objProduct2.Id,
            UnitPrice = 0,
            OldLateDec__c = 0,
            LateDec__c = 12000,
            IsActive = true
        );
        insert objPricebookentry;
    }

    @isTest
    static void testIF_SRM_SFDC_INFO_PRICE() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String strBody = '{"transaction_id":"CR008_20221111095130","is_last":true,"data":[{"aply_stt_ymd":"20221001","lgs_ctr_id":"2450","aply_end_ymd":"99991231","reg_dt":"2022-10-01 09:41:40","upd_dt":"2022-10-02 00:03:33","lgs_ctr_nm":"FO대구센터(물류대행)","crit_buy_prc":"24445.000","gd_no":"100098","gd_nm":"밀가루", "del_yn":"0"},{"aply_stt_ymd":"20221001","lgs_ctr_id":"2450","aply_end_ymd":"99991231","reg_dt":"2022-10-01 09:41:40","upd_dt":"2022-10-02 00:03:33","lgs_ctr_nm":"FO대구센터(물류대행)","crit_buy_prc":"24445.000","gd_no":"100098","gd_nm":"밀가루", "del_yn":"1"}],"total_page":1,"page_no":1}';
        req.requestBody = Blob.valueof(strBody);
        RestContext.request = req;
        RestContext.response = res;
        IF_SRM_SFDC_INFO_PRICE.doPost();
        
        Test.stopTest();
    }
}