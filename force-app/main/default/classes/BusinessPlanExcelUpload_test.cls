/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-23-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class BusinessPlanExcelUpload_test {
    @testSetup
	static void setData() {
        User objUser = new User();
        objUser.Id = UserInfo.getUserId();
        objUser.HeadOffice__c = '3001';
        objUser.SU__c = '4100';

        update objUser;
    }

        
    @isTest 
    static void itShould() {
        BusinessPlanExcelUpload.doInit();

        String strItemDetail = '[{"SLBZ_ORG_NM__c":"급식SU","SLBZ_ORG_ID__c":"3001","DIV_NM__c":"튼튼스쿨사업부","DIV_ID__c":"4709","BRC_NM__c":"튼튼스쿨)튼튼스쿨1팀","BRC_ID__c":"315","EmployeeNumber__c":"009090","MAName__c":"전관우","Year__c":"2023","Month__c":"1","Type__c":"신규","TargetNetAmount__c":"","TargetSalesProfit__c":""}]';
        BusinessPlanExcelUpload.doCheckFile(null, strItemDetail, null, null);

        String strAddItem = '[{"inputEmployeeNumber":"009090","intSEQ":2,"objItem":{"DIV_NM__c":"튼튼스쿨사업부","SLBZ_ORG_ID__c":"3001","EmployeeNumber__c":"009090","Month__c":"1","TargetSalesProfit__c":0,"DIV_ID__c":"4709","Year__c":2023,"Type__c":"신규","TargetNetAmount__c":0,"BRC_NM__c":"튼튼스쿨)튼튼스쿨1팀","BRC_ID__c":"315","SLBZ_ORG_NM__c":"급식SU"},"strStatus":"SUCCESS"}]';
        BusinessPlanExcelUpload.doAddItem(null, strAddItem, null);

        BusinessPlanExcelUpload.doGetExportTarget('3001', '4100');
    }
}