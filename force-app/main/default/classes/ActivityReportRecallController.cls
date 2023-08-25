/*
* ==================================================================================
*   File Name   : ActivityReportRecallController.cls
*   Author      : Minje.kim
*   Date        : 2022.11.06
*   Tester      : AActivityReportRecallController_test.cls
*   Description : 주유비 승인 회수
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.11.06    Minje.kim       Create
* ==================================================================================
*/
public without sharing class ActivityReportRecallController {

    /**
     * 주유비 승인 회수 Init(활동보고 조회)
     * 
     * @param recordId 활동보고(ActivityReport__c) Record Id
     * @return Map<String, object>
     *           - objActivityReport : 활동보고 정보
     *
    **/
    @AuraEnabled
    public static  Map<String, object> getInitData(Id recordId) {
        try{
            ActivityReport__c objActivityReport = [
                SELECT   Id, ApprovalStatus__c
                FROM     ActivityReport__c
                WHERE    Id =: recordId
            ]; 
            
            Map<String, object> mapResult = new Map<String, object>{
                'objActivityReport' => objActivityReport
            };
            return mapResult;
        }
        catch(Exception e){
            system.debug('ActivityReportRecallApprovalController getInitData error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

    /**
     * 주유비 승인 회수
     * 
     * @param recordId 활동보고(ActivityReport__c) Record Id
     * @return 
     *
    **/
    @AuraEnabled
    public static void doRecall(Id recordId) {
        try{
            ActivityReport__c objActivityReport = [
                SELECT   Id, OilTotalAmount__c
                FROM     ActivityReport__c
                WHERE    Id =: recordId
            ]; 
            objActivityReport.ApprovalStatus__c ='Writing';
            update objActivityReport;
        }
        catch(Exception e){
            system.debug('ActivityReportRecallApprovalController doRecall error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }
}