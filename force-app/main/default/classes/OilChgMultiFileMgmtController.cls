/************************************************************************************
 * File Name   : OilChgMultiFileMgmtController.cls
 * Author      : sy.lee
 * Date        : 2023.04.28
 * Tester      : OilChgMultiFileMgmtController_test.cls
 * Description : 파일을 업로드하고, 첨부된 파일 OCR API이용하여 데이터 추출
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2023.04.28      sy.lee             Create
   1.1      2023.06.27      sy.lee             update
*************************************************************************************/

public without sharing class OilChgMultiFileMgmtController {

    //관련된 첨부파일 존재시 해당 정보 조회
    @AuraEnabled
    public static Map<String, Object> doSearchAttachments(Id recordId, String fileFieldAPIName,String typeBfileFieldAPIName,String typeCfileFieldAPIName, String filePermissionField) {

        if( filePermissionField == 'TRUE' || filePermissionField == 'FALSE'){
            filePermissionField = filePermissionField.toLowerCase();
        }

        String sObjectType = String.valueOf(recordId.getSobjectType());

        String query = '';
        query += 'SELECT    Id, ' + fileFieldAPIName+', '+ typeBfileFieldAPIName+', '+ typeCfileFieldAPIName;

        if(filePermissionField != null && filePermissionField != '' && filePermissionField != 'true' && filePermissionField != 'false') {
            query += '      , ' + filePermissionField;
        }

        query += '  FROM    ' + sObjectType;
        query += ' WHERE    Id = :recordId';

        SObject sObj = Database.query(query);

        DataWrapper objWrapFile = new DataWrapper();
        if(sObj.get(fileFieldAPIName) != null) {
            ContentDocument objContentDocumentA = [SELECT Id, Title, FileExtension, LatestPublishedVersionId
                                                    FROM   ContentDocument
                                                    WHERE  Id =: String.valueOf(sObj.get(fileFieldAPIName))
                                                    LIMIT 1];
            if(objContentDocumentA != null) {
                objWrapFile.typeAfileId = objContentDocumentA.Id;
                objWrapFile.typeAversionId = objContentDocumentA.LatestPublishedVersionId;
                objWrapFile.typeAfileName = objContentDocumentA.Title + '.' + objContentDocumentA.FileExtension;
                objWrapFile.typeAForm = objContentDocumentA.FileExtension;
            }
        }
        if(sObj.get(typeBfileFieldAPIName) != null) {
            ContentDocument objContentDocumentB = [SELECT Id, Title, FileExtension, LatestPublishedVersionId
                                                    FROM   ContentDocument
                                                    WHERE  Id =: String.valueOf(sObj.get(typeBfileFieldAPIName))
                                                    LIMIT 1];
            if(objContentDocumentB != null) {
                objWrapFile.typeBfileId = objContentDocumentB.Id;
                objWrapFile.typeBversionId = objContentDocumentB.LatestPublishedVersionId;
                objWrapFile.typeBfileName = objContentDocumentB.Title + '.' + objContentDocumentB.FileExtension;
                objWrapFile.typeBForm = objContentDocumentB.FileExtension;
            }
        }
        if(sObj.get(typeCfileFieldAPIName) != null) {
            ContentDocument objContentDocumentC = [SELECT Id, Title, FileExtension, LatestPublishedVersionId
                                                    FROM   ContentDocument
                                                    WHERE  Id =: String.valueOf(sObj.get(typeCfileFieldAPIName))
                                                    LIMIT 1];
            if(objContentDocumentC != null) {
                objWrapFile.typeCfileId = objContentDocumentC.Id;
                objWrapFile.typeCversionId = objContentDocumentC.LatestPublishedVersionId;
                objWrapFile.typeCfileName = objContentDocumentC.Title + '.' + objContentDocumentC.FileExtension;
                objWrapFile.typeCForm = objContentDocumentC.FileExtension;
            }
        }
        
        Map<String, Object> mapReturnValue = new Map<String, Object>{
            'objWrapFile' => objWrapFile,
            'isFileEditable' => filePermissionField != null  && filePermissionField != '' && filePermissionField != 'true' && filePermissionField != 'false'  ? sObj.get(filePermissionField) : (filePermissionField != null  && filePermissionField != '' ?  filePermissionField : string.valueof(true)),
            'alternativeTargetId' => recordId
        };
        return mapReturnValue;
    }

    // naver OCR API 사용
    @AuraEnabled
    public static Map<String, Object> doNaverOcrProcess(Id recordId,Id cdId) {
        List<String> result;
        Boolean passFlag = false;
        Map<String, String> mapOilType = CommonUtil.getMapPickListLabel('User', 'oil_type_cd__c');
        try {
       
            ContentDistribution cdtObj = [
                    SELECT   Id, Name, DistributionPublicUrl, ContentDownloadUrl, ContentDocumentId
                    FROM     ContentDistribution
                    WHERE    Id = :cdId
            ];

            OilTypeChange__c oilInfo = [SELECT Id,CarNo__c,oil_type_cd__c FROM OilTypeChange__c WHERE id =:recordId];
            String carNoInfo = oilInfo.CarNo__c.replace(' ', '').trim(); //차량번호
            String oilTypeStrInfo = mapOilType.get(oilInfo.oil_type_cd__c).replace(' ', '').trim(); //유류유형
            String imageUrl=cdtObj.ContentDownloadUrl;
            if(string.isNotBlank(imageUrl) && !Test.isRunningTest())
            {      
                result = NaverCloudOcrAPI.analyzeImage(imageUrl);                                   
            }else{
                result = new List<String>();
                result.add('OCR 추출 이미지 출저 정보가 확실하지 않습니다.');
                result.add('temp');
            }
            Boolean isCarInfo = result[0].replace(' ', '').trim().contains('자동차등록증');//'자동차등록증이'란 고정 단어가 올린 파일에 있어야함
            if(isCarInfo){
                oilInfo.isExtractOfCarNo__c = result[1].contains(carNoInfo);
                oilInfo.isExtractOfOilType__c = result[2].contains(oilTypeStrInfo);
                //차량번호 및 유류유형이 추출한 것과 기재한 것 일치할 시에만 자동승인 프로세스 진행
                if(result[1].contains(carNoInfo) && result[2].contains(oilTypeStrInfo)){
                    oilInfo.ApprovalStatus__c ='승인';
                    oilInfo.isAutoApproval__c = true;
                    passFlag = true;
                }
            }            
            if(oilInfo != null && isCarInfo && (result[1].contains(carNoInfo) || result[2].contains(oilTypeStrInfo)))
            {
                update oilInfo;
            }            
            
        } catch(Exception e) {
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@ doOcrTest Error : ' + e.getMessage());
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@ doOcrTest ErrorLine : ' + e.getLineNumber());
            throw new AuraHandledException('Sorry, contact your Salesforce administrator.');
        }
        String msg = '승인대기중입니다.';
        if(passFlag){
            msg = '승인이 완료되었습니다.';
        }
        Map<String, String> mapReturnValue = new Map<String, String>{
            'ocrResult' => msg
        };
        return mapReturnValue;
    }

    //파일 첨부시 필요한 후속작업 로직 [1].유류유형 개체의 관련필드에 해당 파일 document id 적제, [2]. naver ocr api에 보낼 imege url 생성을 위해 파일 첨부시 ContentDistribution 데이터 생성과정을 넣음
    @AuraEnabled
    public static Map<String, Object> doUpdateAttach(Id recordId, Id documentId, String fileFieldAPIName) {
        try {
            //[1]
            String sObjectType = String.valueOf(recordId.getSobjectType());
            SObject sObj = Schema.getGlobalDescribe().get(sObjectType).newSObject();          

            sObj.put('Id', recordId);
            sObj.put(fileFieldAPIName, documentId);
            update sObj;

            //[2]     
            ContentDocumentLink linkObj=[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId LIMIT 1];
        
            ContentVersion versionObj=[SELECT Id,VersionData,Title,ContentDocumentId,FileExtension,PathOnClient FROM ContentVersion WHERE ContentDocumentId =:linkObj.ContentDocumentId AND IsLatest = true];

            ContentDistribution objDistribution = new ContentDistribution();
            objDistribution.Name = versionObj.PathOnClient;
            objDistribution.ContentVersionId = versionObj.Id;
            objDistribution.PreferencesAllowViewInBrowser = true;
            objDistribution.PreferencesLinkLatestVersion = true;
            objDistribution.PreferencesNotifyOnVisit = false;
            objDistribution.PreferencesPasswordRequired = false;
            objDistribution.PreferencesAllowOriginalDownload = true;
            insert objDistribution;  

            Map<String, Object> mapReturnValue = new Map<String, Object>{
                'cdId' => objDistribution.Id
            };
            return mapReturnValue;  
            
        } catch(Exception e) {
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@ doUpdateAttach Error : ' + e.getMessage());
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@ doUpdateAttach ErrorLine : ' + e.getLineNumber());
            throw new AuraHandledException('Sorry, contact your Salesforce administrator.');
        }
    }

    //첨부한 파일 삭제 시 삭제한 document ID를 유류유형의 해당 첨부파일 필드에서도 삭제(null) 처리
    @AuraEnabled
    public static void doDeleteFile(Id recordId, Id documentId, String fileFieldAPIName) {
        try {

            delete new ContentDocument(Id = documentId);
            String sObjectType = String.valueOf(recordId.getSobjectType());
            SObject sObj = Schema.getGlobalDescribe().get(sObjectType).newSObject();
            sObj.put('Id', recordId);
            sObj.put(fileFieldAPIName, null);
            update sObj;
            
        } catch(Exception e) {
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@ doDeleteFile Error : ' + e.getMessage());
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@ doDeleteFile ErrorLine : ' + e.getLineNumber());
            throw new AuraHandledException('Sorry, contact your Salesforce administrator.');
        }
    }

    public class DataWrapper {
        @AuraEnabled public String typeAfileId;
        @AuraEnabled public String typeAversionId;
        @AuraEnabled public String typeAfileName;
        @AuraEnabled public String typeAForm;
        @AuraEnabled public String typeBfileId;
        @AuraEnabled public String typeBversionId;
        @AuraEnabled public String typeBfileName;
        @AuraEnabled public String typeBForm;
        @AuraEnabled public String typeCfileId;
        @AuraEnabled public String typeCversionId;
        @AuraEnabled public String typeCfileName;
        @AuraEnabled public String typeCForm;
    }

}