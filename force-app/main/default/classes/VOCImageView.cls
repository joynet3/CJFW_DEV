/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class VOCImageView {
    /**
     * VOC Image View Init
     * 
     * @params recordId Record Id
     * @return DataWrapper
     *
    **/
    @AuraEnabled
    public static DataWrapper doInit(String recordId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();
        List<String> listImage = new List<String>();

        try {
            VOC__c objVOC = [
                SELECT  Id, img_file_url1__c, img_file_url2__c, img_file_url3__c
                FROM    VOC__c
                WHERE   Id =:recordId
            ];

            if(objVOC.img_file_url1__c <> null) {
                listImage.add(objVOC.img_file_url1__c);
            }

            if(objVOC.img_file_url2__c <> null) {
                listImage.add(objVOC.img_file_url2__c);
            }

            if(objVOC.img_file_url3__c <> null) {
                listImage.add(objVOC.img_file_url3__c);
            }
        }catch (Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }
        
        objWrapper.listImage = listImage;

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    public class DataWrapper {
        @AuraEnabled
        public String strStatus {get;set;}
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public List<String> listImage {get;set;}
    }
}