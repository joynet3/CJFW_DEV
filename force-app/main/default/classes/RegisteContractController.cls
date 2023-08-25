/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class RegisteContractController {
    /**
     * 영업기회 계약등록화면 Init
     * 
     * @params recordId Opportunity Id
     * @return DataWrapper
     *
    **/
    @AuraEnabled
    public static DataWrapper doInit(String recordId){
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';
        String strMessage = '';

        try{
            Opportunity obj = [SELECT StageName, ContractId FROM Opportunity WHERE Id = :recordId];
            if (!obj.StageName.equals('Closed Won')) {
                strStatus = 'ERROR';
                strMessage = Label.NotClosedWonError;
            }else if (obj.ContractId != null) {
                strStatus = 'ERROR';
                strMessage = Label.ContractAlreadyRegisteredError;
            }
        }catch (Exception e){
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ': ' + e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;
        return objWrapper;
    }

    /**
     * 계약정보 저장
     * 
     * @params recordId Opportunity Id
     * @params contractStartDate 계약시작일
     * @params contractTerm 계약기간(월)
     * @params ownerExpirationNotice 담당MA 만료알림 
     * @params description 설명
     * @return DataWrapper
     *
    **/
    @AuraEnabled
    public static DataWrapper registContract(String recordId, Date contractStartDate, String contractTerm, String ownerExpirationNotice, String description) {
        
        
        System.debug('::registContract::');
        System.debug('recordId : ' +recordId);
        System.debug('contractStartDate : ' +contractStartDate);
        System.debug('contractTerm : ' +contractTerm);
        System.debug('ownerExpirationNotice : ' + ownerExpirationNotice);
        System.debug('description : ' + description);
        DataWrapper objWrapper = new DataWrapper();
        String strStatus = 'SUCCESS';
        String strMessage = '';
        try{
            Opportunity objOppty = new Opportunity();
            objOppty.Id = recordId;
            objOppty.ContractStartDate__c = contractStartDate;
            objOppty.ContractTerm__c = Integer.valueOf(contractTerm);
            objOppty.OwnerExpirationNotice__c = ownerExpirationNotice;
            objOppty.ContractDescription__c = description;
            Database.SaveResult objsr = Database.update(objOppty);
            if (objsr.isSuccess()) {
                System.debug('Success');
                strMessage = Label.SuccessRegisteContract;
            }else {
                Database.Error err = objsr.getErrors()[0];
                System.debug('registContract update Error > sr : ' + objsr + '      // err :  ' + err);
                System.debug('registContract update Error > objOppty: ' + objOppty);
                strStatus = 'ERROR';
                strMessage = err.getMessage();
            }
        }catch (Exception e){
            System.debug('registContract catch :' + e.getMessage() + '\\ \\' + e.getLineNumber());
            strStatus = 'ERROR';
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                strMessage = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ',': []');
            }else{
                strMessage += '계약 등록에 실패했습니다. - ' + e.getMessage();
            }
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;
        return objWrapper;
    }
    public class DataWrapper {
        @AuraEnabled
        public String strStatus { get; set; }
        @AuraEnabled
        public String strMessage { get; set; }
    }
}