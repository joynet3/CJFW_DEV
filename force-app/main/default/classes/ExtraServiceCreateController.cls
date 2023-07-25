/*
* ==================================================================================
*   File Name   : ExtraServiceCreateController.cls
*   Author      : Minje.Kim
*   Date        : 2022.11.14
*   Tester      : ExtraServiceCreateController_test.cls
*   Description : Create ExtraService In ServiceContents QuickAction
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.11.14    Minje.Kim    Create
* ==================================================================================
*/

public without sharing class ExtraServiceCreateController {
    /**
     * 부가서비스 생성 Init
     *      
     * @return String RecordTypeId
     *
    **/
    @AuraEnabled
    public static String doInit() {

        //find all Opportunity record types
        List<Schema.RecordTypeInfo> infos = Schema.SObjectType.ExtraService__c.RecordTypeInfos;
        Id defaultRecordTypeId;

        //check each one
        for (Schema.RecordTypeInfo info : infos) {
            if (info.DefaultRecordTypeMapping) {
                defaultRecordTypeId = info.RecordTypeId;
            }
        }

        //here is the default Opportunity RecordType Id for the current user
        System.debug(defaultRecordTypeId);

        return defaultRecordTypeId;
    }
}