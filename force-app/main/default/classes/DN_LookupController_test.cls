/*
* ==================================================================================
*   File Name   : DN_LookupController_test.cls
*   Author      : Soyoung.Jung
*   Date        : 2019.03.27
*   Target      : DN_LookupController.cls
*   Description : Daeunextier common lookup component
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2019.03.27    Soyoung.Jung    Create
* ==================================================================================
*/

@isTest
private class DN_LookupController_test {
    
    static {
	}

	@TestSetup
	static void setup() {
        insert TestObjectCreator.getObjAccount();
	}

	@isTest 
    static void unitTest() {
        String queryString = 'SELECT Id, Name FROM Account WHERE ParentId = null';
        DN_LookupController.querySalesforceRecord(queryString);
        DN_LookupController.getLookupDatas(queryString, 'Account', new List<String>{'Name'});
	}

}