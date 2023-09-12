/**
 * @Class : IFN_CMM_ERRUTIL_TEST.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.09.12
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.12 | 조일근  | 최초작성
 * */
@isTest
private class IFN_CMM_ERRUTIL_TEST {
    @TestSetup
    static void setup(){
        IF_ERROR_CODE_MST__c errms = new IF_ERROR_CODE_MST__c();
        errms.SYSTEM_CODE__c = 'COMMON';
        errms.ERROR_KEY__c = '1';
        errms.ERROR_CODE__c = '1';
        errms.ERROR_MSG__c = '1';
        insert errms;
    }


    @isTest
    static void testOne()
    {
        Test.startTest();
        IFN_CMM_ERRUTIL.GET_SYSTEM_ERRMAP('COMMON');
        IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', '1');

        Test.stopTest();
    }

    
}