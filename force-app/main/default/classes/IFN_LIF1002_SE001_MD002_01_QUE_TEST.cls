/**                                     
 * @Class : IFX_PMDS_WEEKPRICE_SearchQueueable_TEST                     
 * @Description : 원료시황 주별 가격정보 호출 Queueable test class                      
 * @Author : 조일근
 * @Date : 2021-07-28
 * @Version : 1.0                               
 * @Modified :                                  
 *  ---------------------------------------------                       
 *  NO | Date       | Modifier      | Description               
 *  ---------------------------------------------                       
 *  1. | 2021-07-28 | 조일근  | 최초작성                           
 */
@isTest
public with sharing class IFN_LIF1002_SE001_MD002_01_QUE_TEST {
    @TestSetup
    static void setup(){
        IFMaster__c ifMaster = new IFMaster__c(
            Name = 'IFN_LIF1002_SE001_MD002_01',
            InterfaceId__c = 'IFN_LIF1002_SE001_MD002_01',
            Type__c = 'Inbound',
            WebserviceType__c = 'REST',
            Method__c = 'POST',
            ContentType__c = 'application/json'
        );

        insert ifMaster;

        IFN_TestDataFactory.createIfPrograms();
        
    } //end of setup()

    @isTest
    static void test01(){
        Test.startTest();

        IFN_LIF1002_SE001_MD001.SearchLst searchitm = new IFN_LIF1002_SE001_MD001.SearchLst();
        searchitm.upd_dt = '';
        searchitm.sale_unit_cd = '';
        searchitm.co_id = '';
        searchitm.brd_nm = '';        
        searchitm.migr_orinat_cd_nm = '';
        searchitm.gd_cls_id3 = '';
        searchitm.migr_orinat_cd = '';
        searchitm.gd_cls_id2 = '';
        searchitm.gd_cls_id4 = '';
        searchitm.gd_cls_nm3 = '';
        searchitm.gd_cls_nm2 = '';
        searchitm.gd_cls_id1 = '';
        searchitm.gd_cls_nm4 = '';
        searchitm.gd_cls_nm1 = '';
        searchitm.taxt_cl_cd = '';
        searchitm.gd_cls_id = '';
        searchitm.gd_no = '';
        searchitm.id = '';
        searchitm.gd_bd = '';
        searchitm.gd_bd_kw = '';
        searchitm.taxt_cl_cd_nm = '';


        Test.setMock(HttpCalloutMock.class, new IFN_LIF1002_SE001_MD001_TEST.IFN_LIF1002_SE001_MD001_TESTMock(JSON.serialize(searchitm),200)); 
        System.enqueueJob(new IFN_LIF1002_SE001_MD002_01_QUE('11'));
        Test.stopTest();
    } //end of testOne()


    @isTest
    static void test02(){
        Test.startTest();

        IFN_LIF1002_SE001_MD001.SearchLst searchitm = new IFN_LIF1002_SE001_MD001.SearchLst();
        searchitm.upd_dt = '';
        searchitm.sale_unit_cd = '';
        searchitm.co_id = '';
        searchitm.brd_nm = '';        
        searchitm.migr_orinat_cd_nm = '';
        searchitm.gd_cls_id3 = '';
        searchitm.migr_orinat_cd = '';
        searchitm.gd_cls_id2 = '';
        searchitm.gd_cls_id4 = '';
        searchitm.gd_cls_nm3 = '';
        searchitm.gd_cls_nm2 = '';
        searchitm.gd_cls_id1 = '';
        searchitm.gd_cls_nm4 = '';
        searchitm.gd_cls_nm1 = '';
        searchitm.taxt_cl_cd = '';
        searchitm.gd_cls_id = '';
        searchitm.gd_no = '';
        searchitm.id = '';
        searchitm.gd_bd = '';
        searchitm.gd_bd_kw = '';
        searchitm.taxt_cl_cd_nm = '';


        Test.setMock(HttpCalloutMock.class, new IFN_LIF1002_SE001_MD001_TEST.IFN_LIF1002_SE001_MD001_TESTMock(JSON.serialize(searchitm),200)); 
        System.enqueueJob(new IFN_LIF1002_SE001_MD002_01_QUE('12'));
        Test.stopTest();
    } //end of testOne()


    @isTest
    static void test03(){
        Test.startTest();

        IFN_LIF1002_SE001_MD001.SearchLst searchitm = new IFN_LIF1002_SE001_MD001.SearchLst();
        searchitm.upd_dt = '';
        searchitm.sale_unit_cd = '';
        searchitm.co_id = '';
        searchitm.brd_nm = '';        
        searchitm.migr_orinat_cd_nm = '';
        searchitm.gd_cls_id3 = '';
        searchitm.migr_orinat_cd = '';
        searchitm.gd_cls_id2 = '';
        searchitm.gd_cls_id4 = '';
        searchitm.gd_cls_nm3 = '';
        searchitm.gd_cls_nm2 = '';
        searchitm.gd_cls_id1 = '';
        searchitm.gd_cls_nm4 = '';
        searchitm.gd_cls_nm1 = '';
        searchitm.taxt_cl_cd = '';
        searchitm.gd_cls_id = '';
        searchitm.gd_no = '';
        searchitm.id = '';
        searchitm.gd_bd = '';
        searchitm.gd_bd_kw = '';
        searchitm.taxt_cl_cd_nm = '';


        Test.setMock(HttpCalloutMock.class, new IFN_LIF1002_SE001_MD001_TEST.IFN_LIF1002_SE001_MD001_TESTMock(JSON.serialize(searchitm),200)); 
        System.enqueueJob(new IFN_LIF1002_SE001_MD002_01_QUE('13'));
        Test.stopTest();
    } //end of testOne()    

    @isTest
    static void test04(){
        Test.startTest();

        IFN_LIF1002_SE001_MD001.SearchLst searchitm = new IFN_LIF1002_SE001_MD001.SearchLst();
        searchitm.upd_dt = '';
        searchitm.sale_unit_cd = '';
        searchitm.co_id = '';
        searchitm.brd_nm = '';        
        searchitm.migr_orinat_cd_nm = '';
        searchitm.gd_cls_id3 = '';
        searchitm.migr_orinat_cd = '';
        searchitm.gd_cls_id2 = '';
        searchitm.gd_cls_id4 = '';
        searchitm.gd_cls_nm3 = '';
        searchitm.gd_cls_nm2 = '';
        searchitm.gd_cls_id1 = '';
        searchitm.gd_cls_nm4 = '';
        searchitm.gd_cls_nm1 = '';
        searchitm.taxt_cl_cd = '';
        searchitm.gd_cls_id = '';
        searchitm.gd_no = '';
        searchitm.id = '';
        searchitm.gd_bd = '';
        searchitm.gd_bd_kw = '';
        searchitm.taxt_cl_cd_nm = '';


        Test.setMock(HttpCalloutMock.class, new IFN_LIF1002_SE001_MD001_TEST.IFN_LIF1002_SE001_MD001_TESTMock(JSON.serialize(searchitm),200)); 
        System.enqueueJob(new IFN_LIF1002_SE001_MD002_01_QUE('14'));
        Test.stopTest();
    } //end of testOne()   

} //end of Class