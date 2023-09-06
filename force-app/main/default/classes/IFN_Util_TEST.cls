/**
 * @Class : IFN_Util_TEST.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.09.06
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.06 | 조일근  | 최초작성
 * */
@isTest
public without sharing class IFN_Util_TEST {

    @TestSetup
    static void makeData(){
        Account objAcc = TestObjectCreator.objSchoolAccount;
        objAcc.Phone = '01012341234';
        objAcc.Address__c = 'Test Address';
        objAcc.AddressDetails__c = 'test';            
        objAcc.PostalCode__c = '12345';
        objAcc.sma_cust_bid_mtd_cd__c = 'A';
        objAcc.sma_cust_bid_cycl_cd__c = '1';
        objAcc.sma_cust_mng_frm_cd__c = '1';
        objAcc.dstfd_mtd_cd__c = '11';
        objAcc.LocationStateProvince__c = '11';
        objAcc.LocationState__c = '11560';
        objAcc.schl_cust_div_cd__c = 'E';
        objAcc.jrsdt_cido_eduofic_cd__c = '100';
        objAcc.jrsdt_gugun_eduofic_cd__c = '1007';
        objAcc.sma_cust_mng_grd_cd__c = 'C';
        objAcc.odd_txt__c = 'TEST';
        objAcc.sma_cust_mng_grd_cd__c = 'A';

        insert objAcc;
    }

    public static testMethod void testMethod1() {
        Test.startTest();

        Datetime dt = System.now();
        Double db1 = 100.1;
        Double db2 = 100.1;
        Double db3 = 100.1;

        IFN_Util.getRecordTypeId('Account', 'SchoolAgency');
        IFN_Util.getSObjectQuery('Account', 'AccountTracking');
        IFN_Util.replaceText('test1');
        IFN_Util.convertCIELabtoRGB255(db1, db2, db3);
        IFN_Util.trimDatetimeNum(dt);
        IFN_Util.trimString('test', 2);
        IFN_Util.trimString('test', 5);
        IFN_Util.convertMinus('0000-');
        IFN_Util.convertMinus('');
        IFN_Util.convertDate('20200202');
        IFN_Util.convertDateTime('20200202000000');
        IFN_Util.datetimeCheck('20200202000000');
        IFN_Util.dateSumTime('20200202', '000000');
        IFN_Util.getListDividedByByteSize('TEST', 1);
        IFN_Util.converDateTimeToStrFormat(Datetime.now());
        IFN_Util.converDateTimeToStrFormat(Datetime.now(),'yyyy-MM-dd');
        IFN_Util.converDateToStrFormat(Datetime.now());
        IFN_Util.converDateToStrFormat(Datetime.now(),'yyyy-MM-dd');        
        IFN_Util.converStringToNumber('0010907597');
        IFN_Util.converStringToNumber(null);
        IFN_Util.searchText('All',new Set<String>{'123'});
        IFN_Util.minusCheck(null);
        IFN_Util.minusCheck('032131-');
        IFN_Util.convertDateAddTime(Date.today(), Time.newInstance(0, 0, 0, 0));
        IFN_Util.convertDateTimeGMT('','');
        IFN_Util.convertDateTimeGMT('20211011','');
        IFN_Util.convertDateTimeGMT('20211011','12');
        IFN_Util.convertDateTimeGMT('20211011','1200');
        IFN_Util.convertDateTimeGMT('20211011','120000');
        IFN_Util.convertTime('120000');
        IFN_Util.convertTime('120000',6);
        IFN_Util.NextBatchCheck('IF_LCHC_EmployeeConvertBatch');
        IFN_Util.NextScheduleCheck('IF_ERP_ProductHierarchySearchQueueable');
        


        Test.stopTest();
    }
}