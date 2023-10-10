/**
 * @description       : 
 * @author            : hyeeun.song@dkbmc.com
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : hyeeun.song@dkbmc.com
**/
@isTest
private class CJFW_MDMBulkUpdateHeadController_test {
    
    static List<CJFW_MDMBulkUpdateHeadController.MDMRequest> customerList = new List<CJFW_MDMBulkUpdateHeadController.MDMRequest>();
    
    @TestSetup
    static void setData() {
        
        List<Account> accList = new List<Account>();
        
        // 본점 C01, 판매처 C02, 관리처 C03, C04, C11
        for(Integer i = 0; i < 100; i++) {
            Account acc = new Account();
            acc.Name = '치킨집';
            // acc.CustomerType__c = 'C01';
            acc.CustomerId__c = '105' + String.valueOf(i);
            acc.LegalStatus__c = 'A';
            acc.RepresentativeName__c = '대표자';
            acc.RepresentativeBirthDate__c = '123456';
            acc.BusinessConditions__c = '주점';
            acc.RecordTypeId = '0120w000001dMzHAAU';
            accList.add(acc);
        }

        System.debug('accList => ' + accList);

        insert accList;

    }

    // 본점 Test
    @isTest
    static void updateTest1() {

        getList();

        System.debug('customerList => ' + customerList);

        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        CJFW_MDMBulkUpdateHeadController.SaveResult result = CJFW_MDMBulkUpdateHeadController.doSave(customerList, '본점');

        System.debug('본점 result => ' + result);
        System.Assert(result.status == 'S', '본점 성공');

        Test.stopTest();

    }

    // 판매처 Test
    @isTest
    static void updateTest2() {

        getList();

        System.debug('customerList => ' + customerList);

        Test.startTest();

        CJFW_MDMBulkUpdateHeadController.SaveResult result = CJFW_MDMBulkUpdateHeadController.doSave(customerList, '판매처');

        System.debug('판매처 result => ' + result);
        System.Assert(result.status == 'S', '판매처 성공');

        Test.stopTest();

    }

    // 관리처 Test
    @isTest
    static void updateTest3() {

        getList();

        System.debug('customerList => ' + customerList);

        Test.startTest();

        CJFW_MDMBulkUpdateHeadController.SaveResult result = CJFW_MDMBulkUpdateHeadController.doSave(customerList, '관리처');

        System.debug('관리처 result => ' + result);
        System.Assert(result.status == 'S', '관리처 성공');

        Test.stopTest();

    }

    // 공통 부분
    @isTest
    static void getList() {

        for(Integer i = 0; i < 100; i++) {
            CJFW_MDMBulkUpdateHeadController.MDMRequest cus = new CJFW_MDMBulkUpdateHeadController.MDMRequest();
            cus.PV_NAME1 = '피자집';
            cus.PV_KUNNR = '105' + String.valueOf(i);
            cus.PV_GFORM = 'B';
            cus.PV_J_1KFREPRE = '대표인';
            cus.PV_STCD1 = '789101';
            cus.PV_J_1KFTBUS = '음식점';
            customerList.add(cus);
        }

    }

    // // Mock1 : SUCCESS
    // private class HttpCalloutSuccessMock implements HttpCalloutMock {
    //     public HTTPResponse respond(HTTPRequest request) {
    //         HttpResponse response = newResponse(200);

    //         return response;
    //     }
    // }

    // private static HTTPResponse newResponse(Integer statusCode) {
    //     HttpResponse response = new HttpResponse();
    //     response.setStatusCode(statusCode);
    //     response.setBody('{"ERR_CD":"S","ERR_MSG_CTT":"","DS_MASTER":{"data":[{"OIL_UNITP":274,"BASE_MON":"202211","COM_CD":"FW00","OIL_TYPE_CD":"1","DPRC_UNITP":101}],"SVC_ERR_MSG_TEXT":"","ErrorCode":0}}');

    //     return response;
    // }

}