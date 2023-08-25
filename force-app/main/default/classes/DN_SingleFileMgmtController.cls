/************************************************************************************
 * File Name   : DN_SingleFileMgmtController.cls
 * Author      : Minje.Kim
 * Date        : 2021.11.02
 * Tester      : DN_SingleFileMgmtController_test.cls
 * Description : 파일을 업로드하고, 첨부된 파일 관리
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2021.11.02  Minje.Kim       Create
*************************************************************************************/

public without sharing class DN_SingleFileMgmtController {

    @AuraEnabled
    public static Map<String, Object> doSearchAttachments(Id recordId, String fileFieldAPIName, String filePermissionField) {

        if( filePermissionField == 'TRUE' || filePermissionField == 'FALSE'){
            filePermissionField = filePermissionField.toLowerCase();
        }

        String sObjectType = String.valueOf(recordId.getSobjectType());

        String query = '';
        query += 'SELECT    Id, ' + fileFieldAPIName;

        if(filePermissionField != null && filePermissionField != '' && filePermissionField != 'true' && filePermissionField != 'false') {
            query += '      , ' + filePermissionField;
        }

        query += '  FROM    ' + sObjectType;
        query += ' WHERE    Id = :recordId';

        System.debug('query : ' + query);
        SObject sObj = Database.query(query);
        system.debug('sObj : ' + sObj);

        system.debug('fileFieldAPIName :::: ' + fileFieldAPIName);
        system.debug('fileId(fileFieldAPIName) :::: ' + sObj.get(fileFieldAPIName));

        DataWrapper objWrapFile = new DataWrapper();
        if(sObj.get(fileFieldAPIName) != null) {
            ContentDocument objContentDocument = [SELECT Id, Title, FileExtension, LatestPublishedVersionId
                                                    FROM   ContentDocument
                                                    WHERE  Id =: String.valueOf(sObj.get(fileFieldAPIName))
                                                    LIMIT 1];
            system.debug('objContentDocument : ' + objContentDocument);
            if(objContentDocument != null) {
                objWrapFile.fileId = objContentDocument.Id;
                objWrapFile.versionId = objContentDocument.LatestPublishedVersionId;
                objWrapFile.fileName = objContentDocument.Title + '.' + objContentDocument.FileExtension;
            }
        }
        System.debug('objWrapFile : ' + objWrapFile);


        System.debug('filePermissionField : ' + filePermissionField);
        
        Map<String, Object> mapReturnValue = new Map<String, Object>{
            'objWrapFile' => objWrapFile,
            'isFileEditable' => filePermissionField != null  && filePermissionField != '' && filePermissionField != 'true' && filePermissionField != 'false'  ? sObj.get(filePermissionField) : (filePermissionField != null  && filePermissionField != '' ?  filePermissionField : string.valueof(true)),
            'alternativeTargetId' => recordId
        };
        return mapReturnValue;
    }


    @AuraEnabled
    public static void doUpdateAttach(Id recordId, Id documentId, String fileFieldAPIName) {
        try {
            
            String sObjectType = String.valueOf(recordId.getSobjectType());
            SObject sObj = Schema.getGlobalDescribe().get(sObjectType).newSObject();

            sObj.put('Id', recordId);
            sObj.put(fileFieldAPIName, documentId);

            update sObj;
        } catch(Exception e) {
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@ doUpdateAttach Error : ' + e.getMessage());
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@ doUpdateAttach ErrorLine : ' + e.getLineNumber());
            throw new AuraHandledException('Sorry, contact your Salesforce administrator.');
        }
    }

    @AuraEnabled
    public static void doDeleteFile(Id recordId, Id documentId, String fileFieldAPIName) {
        try {
            String sObjectType = String.valueOf(recordId.getSobjectType());

            SObject sObj = Schema.getGlobalDescribe().get(sObjectType).newSObject();
            sObj.put('Id', recordId);
            sObj.put(fileFieldAPIName, null);

            update sObj;
            delete new ContentDocument(Id = documentId);
        } catch(Exception e) {
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@ doUpdateAttach Error : ' + e.getMessage());
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@ doUpdateAttach ErrorLine : ' + e.getLineNumber());
            throw new AuraHandledException('Sorry, contact your Salesforce administrator.');
        }
    }

    public class DataWrapper {
        @AuraEnabled public String fileId;
        @AuraEnabled public String versionId;
        @AuraEnabled public String fileName;
    }

}