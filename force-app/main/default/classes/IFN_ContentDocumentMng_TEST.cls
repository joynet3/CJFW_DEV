/**
 * @Class             : 
 * @Author            : SeongHwan.Bang
 * @Last modified on  : 2023-09-02
 * @Last modified by  : SeongHwan.Bang
 * @Description       :  
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   2023-09-02   SeongHwan.Bang   Initial Version
**/
@isTest
public class IFN_ContentDocumentMng_TEST {

    public static testMethod void testMethod1() {


        Map< String,Object> itm = new Map< String,Object>();
        itm.put('fileFullName', 'TEST.xlsx');
        itm.put('base64Data', 'ASDASDJKASJLDJALSDKA');
        UTIL_ContentDocumentMng.insertContentDocumentList(itm,'a3m1s000000A26sAAC','원인분석');

        List<Map<String, String>> files = new List<Map<String, String>>();
        Map<String, String> f = new Map<String, String>();
        f.put('contentVersionId','0681s000000pZRRAA2');
        f.put('documentId','0691s000000pMcsAAE');
        f.put('name','1111.jpg');
        files.add(f);
        f = new Map<String, String>();
        f.put('contentVersionId','0681s000000pZRSAA2');
        f.put('documentId','0691s000000pMctAAE');
        f.put('name','aaa.jpg');
        files.add(f);


        LGC_CnC__c cncMstRecord = new LGC_CnC__c();
        cncMstRecord.Name = '1';
        cncMstRecord.Owner_G_Portal_ID__c = '1';
        cncMstRecord.Details__c = '1';
        cncMstRecord.Initial_Response_Date__c = Date.today();
        cncMstRecord.Initial_Response_Method__c = 'M01';
        cncMstRecord.Initial_Response_Details__c = '1';
        cncMstRecord.CnC_Sample_Required__c = 'Y';
        cncMstRecord.cnc_Sample_Status__c = 'T02';
        cncMstRecord.Expected_Amount_of_Compensation__c = 10;
        cncMstRecord.Register_Exchange_Rate__c = 10;
        cncMstRecord.Final_Customer__c = '1';
        cncMstRecord.Type_lv1__c = 'T01';
        cncMstRecord.Type_lv2__c = 'T0101';
        cncMstRecord.CnC_Sample_Possession__c= 'Y';
        cncMstRecord.Base_Currency__c= 'USD';
        cncMstRecord.Division__c= 'NCC/PO';
        cncMstRecord.Base_Currency__c = 'USD';        
        cncMstRecord.Compensation_Exchange_Rate__c = 20;
        cncMstRecord.Return_Carrying_cost__c = 20;        
        cncMstRecord.Return_Disposal_cost__c = 20;
        cncMstRecord.Reworking_cost__c = 20;
        cncMstRecord.Resale_loss_cost__c = 20;
        cncMstRecord.Amount_of_Cash_Payment__c = 20;
        cncMstRecord.Product_Compensation_Carrying_cost__c = 20;
        cncMstRecord.Product_Qty_X_Price__c  =20;
        cncMstRecord.Sorting__c = 'T01';        
        cncMstRecord.Compensation_Type__c = 'T01;T02;T03'; 
        cncMstRecord.Defect_Occurance_Date__c = Date.today();
        insert cncMstRecord;

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.PathOnClient = 'aaa.jpg';
        cv.Origin = 'C';
        cv.Title = 'aadasd';
        cv.VersionData = EncodingUtil.base64Decode('asdasdasdas');         
        cv.FileLinkExtKey__c = '123456';
        insert cv;  

        

        LGC_CategoryFile__c fcate = new LGC_CategoryFile__c();
        fcate.ContentsVersion__c = cv.Id;
        fcate.Category__c  = 'C&C등록';
        fcate.SObjectAPI__c  = 'LGC_CnC__c';
        fcate.RelatedRecord__c  = cncMstRecord.Id;
        fcate.IsDelete__c = false;
        fcate.FileLinkExtKey__c = '1111';
        insert fcate;  

        UTIL_ContentDocumentMng.saveNewFiles(files, 'a361s000000WgxzAAC', '원인분석');
        UTIL_ContentDocumentMng.exFileRemove('1111');
        

    }
}