/**
 * @description       : 
 * @author            : 백영주
 * @group             : 
 * @last modified on  : 08-16-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class changeToExtraServiceBtn {
    public changeToExtraServiceBtn() {

    }
    @AuraEnabled
    public static DataWrapper doInit(String recordId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();

        try {

        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    @AuraEnabled
	public static DataWrapper doChangeRecord(String recordId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();
        try{
            List<ClassService__c> updateList = new List<ClassService__c>();
            updateList = [
                SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, ServiceContent__c, MDMCode__c, Status__c, Customer__c, Manager__c, CustomerPhone__c, TargetGroup__c, ApplicantsNumber__c, CustomerAgeGroup__c, Address__c, Description__c 
                FROM ClassService__c 
                WHERE Id =:recordId
            ];
            List<ExtraService__c> insertList = new List<ExtraService__c>();
            for(ClassService__c cs : updateList){
                cs.Status__c = 'C';
                ExtraService__c extra = new ExtraService__c();

            }   
            update updateList;

        }catch(Exception e){
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }
        return objWrapper;

    }
    public class DataWrapper {
        @AuraEnabled
        public String strStatus {get;set;}
        @AuraEnabled
        public String strMessage {get;set;}
	}
}