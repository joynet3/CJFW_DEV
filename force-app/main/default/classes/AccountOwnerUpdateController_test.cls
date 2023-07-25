/**
 * Created by kw on 2023-01-05.
 */

@IsTest
private class AccountOwnerUpdateController_test {
    @IsTest
    static void AccountOwnerUpdateController_test() {
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
        Test.startTest();
        System.debug(AccountOwnerUpdateController.doInit());
        Map<String, String> mapParam = new Map<String, String>();
        mapParam.put('selectedLocationStateProvince','11');
        mapParam.put('selectedLocationState','11200');
        System.debug(AccountOwnerUpdateController.getDataTable(mapParam));
        System.debug(AccountOwnerUpdateController.getUserDataTable());
        String strObj ='[{"id": "' + objAcc.Id + '"}]';
        System.debug(strObj);
        System.debug(AccountOwnerUpdateController.doChangeOwner(UserInfo.getUserId(), ''));
        System.debug(AccountOwnerUpdateController.doChangeOwner(UserInfo.getUserId(), strObj));
        System.debug(AccountOwnerUpdateController.doChangeSmaCustMngGrdCd('S', strObj));
        AccountOwnerUpdateController.SearchWrapper sw = new AccountOwnerUpdateController.SearchWrapper(objAcc);
        Test.stopTest();
    }
}