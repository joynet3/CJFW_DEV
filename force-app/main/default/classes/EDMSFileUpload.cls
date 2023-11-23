/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-22-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public without sharing class EDMSFileUpload {
    /**
     * EDMS File Upload Init
     * 
     * @param recordId record Id     
     * @return DataWrapper
     *          - strStatus : 상태
     *          - strMessage : 메시지
     *          - listSelectType : EDMS File Type__c Picklist value 정보 (계약서원본, 사업자등록증, 인감증명서(개인/법인), 법인등기부 등본, 장려금약정서, 사용인감계, 개인정보활용동의서, 상계처리약정서, 계약이행완료확인서, 계약해지합의서, 관리처등록의뢰서)
     * 
    **/
    @AuraEnabled
	public static DataWrapper doInit(String recordId) {
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();

        try {

            List<Map<String, String>> listSelectType = CommonUtil.getPickListValues('EDMSFile__c', 'Type__c', false); 

            objWrapper.listSelectType = listSelectType;

            system.debug('EDMSFileUpload.doInit()');
            system.debug('listSelectType ' + JSON.serialize(listSelectType));
            /* 대유주석
            List<EDMSFile__c> listEMDSFile = new List<EDMSFile__c>();

            listEMDSFile = [
                SELECT  Id, Status__c, Type__c, DownloadURL__c
                FROM    EDMSFile__c
                WHERE   TargetId__c =:recordId
            ];

            objWrapper.listEMDSFile = listEMDSFile;
            */
        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    /**
     * EDMS File List 조회
     * 
     * @param recordId EDMSFile(EDMSFile__c) Record Id
     * @param strType 파일구분 계약서원본(1), 사업자등록증(2), 인감증명서(개인/법인)(3), 법인등기부 등본(4), 장려금약정서(5), 사용인감계(6)
     *                개인정보활용동의서(7), 상계처리약정서(8), 계약이행완료확인서(9), 계약해지합의서(10), 관리처등록의뢰서(11)
     * @return DataWrapper
     *          - strStatus : 상태
     *          - strMessage : 메시지
     *          - listFileWrapper : EDMS File 리스트
     *
    **/
    @AuraEnabled
    public static DataWrapper doGetEDMSList(String recordId, String strType) {
        String strStatus = 'SUCCESS';
        String strMessage = '';
        //[Page2]
        String strTypeLabel = '';

        system.debug('doGetEDMSList');
        system.debug('recordId ' + recordId);
        system.debug('strType ' + strType);

        DataWrapper objWrapper = new DataWrapper();

        List<FileWrapper> listFileWrapper = new List<FileWrapper>();

        try {
            List<EDMSFile__c> listEDMSFile = new List<EDMSFile__c>();

            /** [P2]
             * Type__c 으로 toLabel(Type__c) 가져오는 Map 추가 (AlertMsg때문에)
             */

            for(EDMSFile__c obj : [                                                              
                SELECT  Id, TargetId__c, Type__c, Name, fileExt__c, DownloadURL__c, FM_Type__c
                FROM    EDMSFile__c
                WHERE   TargetId__c =:recordId
                AND     Type__c =:strType
                ORDER BY CreatedDate desc
            ]) {
                FileWrapper objFileWrapper = new FileWrapper();

                Set<String> setExcelExt = new Set<String>{'xlsx', 'xlsm', 'xls', 'xlt'};
                Set<String> setImageExt = new Set<String>{'bmp', 'jpeg', 'jpg', 'gif', 'png', 'tif', 'tiff'};
                Set<String> setPPTExt = new Set<String>{'ppt', 'pptx'};
                Set<String> setWordExt = new Set<String>{'doc', 'docx'};

                objFileWrapper.fileName = obj.Name;
                objFileWrapper.downloadURL = obj.DownloadURL__c;
                objFileWrapper.SFDCID = obj.Id;
                /**[P2] TypeLabel Name */
                strTypeLabel = obj.FM_Type__c;
                objFileWrapper.typeLabel = strTypeLabel;

                System.debug('============> obj.fileExt__c : '+obj.fileExt__c);
                System.debug('============>[P2] strTypeLabel : '+strTypeLabel);

                String iconName = '';

                if(setExcelExt.contains(obj.fileExt__c)) {
                    iconName ='excel';
                }else if(setImageExt.contains(obj.fileExt__c)) {
                    iconName ='image';
                }else if(setWordExt.contains(obj.fileExt__c)) {
                    iconName ='word';
                }else if(setPPTExt.contains(obj.fileExt__c)) {
                    iconName ='ppt';
                }else if(obj.fileExt__c == 'pdf') {
                    iconName ='pdf';
                }else if(obj.fileExt__c == 'txt') {
                    iconName ='txt';
                }
                else {
                    iconName = 'unknown';
                }

                System.debug('============> iconName : '+iconName);

                objFileWrapper.iconName = 'doctype:'+iconName;

                listFileWrapper.add(objFileWrapper);
                system.debug('[[P2] listFileWrapper' + json.serialize(listFileWrapper));
            }

        }catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        System.debug('===============> strStatus : '+strStatus);
        System.debug('===============> strMessage : '+strMessage);

        objWrapper.listFileWrapper = listFileWrapper;
        system.debug('[[P2] listFileWrapper' + json.serialize(objWrapper.listFileWrapper));
        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }

    /**
     * Salesforce File Download URL 생성
     * 
     * @param documentId ContentDocument Id
     * @return DataWrapper
     *          - strStatus : 상태
     *          - strMessage : 메시지
     *          - downloadUrl : 다운로드 URL
     *
    **/
    @AuraEnabled
    public static DataWrapper doCreatedFileURL(String documentId) {
        system.debug('doCreatedFileURL ' + documentId);
        String strStatus = 'SUCCESS';
        String strMessage = '';

        DataWrapper objWrapper = new DataWrapper();

        try {
            // 증빙파일 파일 레코드
            ContentVersion objContentVersion = [
                    SELECT  Id, PathOnClient, Title, FileExtension, ContentSize, VersionData, CreatedDate
                    FROM    ContentVersion
                    WHERE   ContentDocumentId =:documentId
            ];

            System.debug('========================> objContentVersion : '+ objContentVersion);
            System.debug('========================> objContentVersion.FileExtension : '+objContentVersion.FileExtension);
            System.debug('========================> objContentVersion.ContentSize : '+objContentVersion.ContentSize);

            String strFileExtension = String.valueOf(objContentVersion.FileExtension).toUpperCase();
            Integer intContentSize = objContentVersion.ContentSize;            
            Boolean isValidationError = false;
            String strValidationErrorMessage = '';

            Set<String> setEvidenceExtension = new Set<String>{'WAV', 'MP3', 'WMA', 'JPG', 'JPEG', 'GIF', 'TIF', 'PDF', 'DER'};

            /* 대유주석
            if(setEvidenceExtension.contains(strFileExtension)) {
                if((strFileExtension == 'WAV' || strFileExtension == 'MP3' || strFileExtension == 'WMA') && intContentSize > 300000) {
                    isValidationError = true;
                    strValidationErrorMessage = 'WAV, MP3, WMA 최대크기는 300KB 입니다';
                }else if(strFileExtension == 'DER' && intContentSize > 10000) {
                    isValidationError = true;
                    strValidationErrorMessage = 'DER 최대크기는 10KB 입니다';
                }else if((strFileExtension == 'JPG' || strFileExtension == 'JPEG' || strFileExtension == 'GIF' || strFileExtension == 'TIF' || strFileExtension == 'PDF') && intContentSize > 300000) {
                    isValidationError = true;
                    strValidationErrorMessage = 'JPG, JPEG, GIF, TIF, PDF 최대크기는 300KB 입니다';    
                }
            }else {
                isValidationError = true;
                strValidationErrorMessage = '증빙파일 확장자는 WAV, MP3, WMA, JPG, JPEG, GIF, TIF, PDF, DER만 가능합니다.';
            }
            */

            if(isValidationError) {
                Database.delete(documentId);

                strStatus = 'ERROR';
                strMessage = strValidationErrorMessage;
            }else {
                ContentDistribution objDistribution = new ContentDistribution();
                objDistribution.Name = 'MDM_' + objContentVersion.PathOnClient;
                objDistribution.ContentVersionId = objContentVersion.Id;
                objDistribution.PreferencesAllowViewInBrowser = true;
                objDistribution.PreferencesLinkLatestVersion = true;
                objDistribution.PreferencesNotifyOnVisit = false;
                objDistribution.PreferencesPasswordRequired = false;
                objDistribution.PreferencesAllowOriginalDownload = true;

                insert objDistribution;

                ContentDistribution objDistributionQuery = [
                    SELECT   Id, Name, DistributionPublicUrl, ContentDownloadUrl, ContentDocumentId
                    FROM     ContentDistribution
                    WHERE    Id = :objDistribution.Id
                ];

                objWrapper.downloadUrl = objDistributionQuery.ContentDownloadUrl;
            }
        }catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;


        return objWrapper;
    }

    /**
     * EDMS 파일 업로드
     * 
     * @param mapParam recordId, documentId, strType, downloadUrl
     * @return DataWrapper
     *          - strStatus : 상태
     *          - strMessage : 메시지
     *
    **/
    @AuraEnabled
    public static DataWrapper doSendEMDS(Map<String, String> mapParam) {
        String strStatus = 'SUCCESS';
        String strMessage = '업로드가 완료되었습니다.';
        String recordId = mapParam.get('recordId');
        String documentId = mapParam.get('documentId');
        String strType = mapParam.get('strType');
        String downloadUrl = mapParam.get('downloadUrl');

        DataWrapper objWrapper = new DataWrapper();
        String versionCategory = '';//oppty의 계약 체결 파일 추가 23-11-21 yejoo
        
        try {

            MDMRegRequestCustomer__c objCustomer = [
                SELECT Id, Account__c FROM MDMRegRequestCustomer__c WHERE Id =:recordId
            ];

            // 증빙파일 파일 레코드
            ContentVersion objContentVersion = [
                    SELECT  Id, PathOnClient, Title, FileExtension, ContentSize, VersionData, CreatedDate, Category__c
                    FROM    ContentVersion
                    WHERE   ContentDocumentId =:documentId
            ];
            System.debug('========================> objContentVersion : '+ objContentVersion);
            System.debug('========================> objContentVersion.FileExtension : '+objContentVersion.FileExtension);
            System.debug('========================> objContentVersion.ContentSize : '+objContentVersion.ContentSize);

            versionCategory = objContentVersion.Category__c;
            String strFileExtension = String.valueOf(objContentVersion.FileExtension).toUpperCase();
            Integer intContentSize = objContentVersion.ContentSize;

            String fileName = objContentVersion.Title;
            String fileExt = objContentVersion.FileExtension;

            List<EDMSFile__c> listDupFile = new List<EDMSFile__c>();
            listDupFile = [
                    SELECT  Id, Name, FileExt__c
                    FROM    EDMSFile__c
                    WHERE   TargetId__c =: recordId
            ];

            if (!listDupFile.isEmpty()){

                Boolean isDupCheckDone = false; 
                Integer count = 0;
                // dup 확인
                // 있으면 Count ++ 한뒤 한바퀴 더
                // 없으면 그대로 

                while ( isDupCheckDone == false ){
                    String strFileName = count > 0 ? fileName + ' (' + count + ')' : fileName;
                    Boolean isHaveDup = false;
                    for ( EDMSFile__c objDupFile : listDupFile){
                        if ( objDupFile.Name == strFileName + '.' + objContentVersion.FileExtension){
                            count++;
                            isHaveDup = true;
                            break;
                        }
                    }
                    
                    if ( isHaveDup == false ){
                        fileName = strFileName;
                        isDupCheckDone = true;
                    }
                }
            }

            String fileFullName = fileName+'.'+objContentVersion.FileExtension;


            System.debug('========================> fileName : '+fileName);
            System.debug('========================> fileFullName : '+fileFullName);

            Map<String, Object> mapFile = new Map<String, Object>();
            
            EDMSFile objFile = new EDMSFile();

            objFile.system_type_cd = 'IF0004';
            objFile.opcode = 'CR009';
            objFile.doctypecd = '1000';
            objFile.attrid = '101';
            objFile.orgattrid = '100';
            objFile.category = strType;
            objFile.attrvalue = objCustomer.Account__c;
            objFile.download_url = downloadUrl;
            objFile.file_name = fileName;
            objFile.file_ext = fileExt;

            String strJSON = JSON.serialize(objFile);

            System.debug('============> strJSON : '+strJSON);

            IFUtil ifutilWrapper = new IFUtil('IF_SFDC_EDMS_FILE_UPLOAD');
            
            HttpResponse response = ifutilWrapper.webCallout(strJSON, true);

            String responseBody = response.getBody();

            System.debug('===========> response.getStatusCode() : '+response.getStatusCode());
            System.debug('===========> responseBody : '+responseBody);

            if(response.getStatusCode() == 200) {                     
                Map<String, Object> mapResBody = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

                System.debug('================> mapResBody : '+JSON.serialize(mapResBody));

                String err_cd = (String)mapResBody.get('err_cd');
                String err_msg_ctt = (String)mapResBody.get('err_msg_ctt');

                System.debug('============> err_cd : '+err_cd);
                System.debug('============> err_msg_ctt : '+err_msg_ctt);

                if(err_cd == '0000') {
                    String download_url = (String)mapResBody.get('download_url');

                    EDMSFile__c objEDMSFile = new EDMSFile__c();

                    objEDMSFile.Name = fileFullName;
                    objEDMSFile.FileExt__c = fileExt;
                    objEDMSFile.Type__c = strType;
                    objEDMSFile.TargetId__c = recordId;
                    objEDMSFile.Status__c = 'Success';
                    objEDMSFile.DownloadURL__c = download_url;
                    // TODO :: 키값만 여기에 넣으면 됨 attrvalue = download url 뒤에 있느거 

                    insert objEDMSFile;

                }else {
                    strStatus = 'ERROR';
                    strMessage = err_msg_ctt;
                }
            }else {
                strStatus = 'ERROR';                    
                strMessage = '파일업로드에 실패하였습니다. 관리자에 문의하여 주시기 바랍니다. 에러코드 : '+response.getStatusCode();
            }

            if(versionCategory != System.Label.CJFW_ETC_CategoryName_002){//oppty의 계약 체결 파일 추가 23-11-21 yejoo
                Database.delete(documentId);
            }

        }catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();

            if(versionCategory != System.Label.CJFW_ETC_CategoryName_002){//oppty의 계약 체결 파일 추가 23-11-21 yejoo
                Database.delete(documentId);
            }
        }

        System.debug('===============> strStatus : '+strStatus);
        System.debug('===============> strMessage : '+strMessage);

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
    }
    
    /**
     * EDMS 파일 업로드
     * 
     * @param mapParam recordId, documentId, strType, downloadUrl
     * @return DataWrapper
     *          - strStatus : 상태
     *          - strMessage : 메시지
     *
    **/
    @AuraEnabled
    public static DataWrapper doDeleteFile(FileWrapper targetFile) {
        String strStatus = 'SUCCESS';
        String strMessage = '파일이 정상적으로 삭제되었습니다.';
        DataWrapper objWrapper = new DataWrapper();

        
        try {
            String attrvalue = targetFile.downloadURL;

            Integer index = attrvalue.lastIndexOf('/');
            attrvalue = attrvalue.substring(index + 1);

            system.debug('targetFile.downloadURL :: ' + targetFile.downloadURL);
            system.debug('attrvalue :: ' + attrvalue);

            Map<String,Object> mapRequest = new Map<String,Object>();

            mapRequest.put('system_type_cd','IF0004');
            mapRequest.put('doctypecd','1000');
            mapRequest.put('attrid','101');
            mapRequest.put('attrvalue', attrvalue);

            String strJSON = JSON.serialize(mapRequest);

            IFUtil ifutilWrapper = new IFUtil('IF_SFDC_EDMS_FILE_DELETE');
            
            HttpResponse response = ifutilWrapper.webCallout(strJSON, true);

            String responseBody = response.getBody();

            System.debug('===========> response.getStatusCode() : '+response.getStatusCode());
            System.debug('===========> responseBody : '+responseBody);

            if(response.getStatusCode() == 200) {                    
                Map<String, Object> mapResBody = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

                System.debug('================> mapResBody : '+JSON.serialize(mapResBody));

                String err_cd = (String)mapResBody.get('err_cd');
                String err_msg_ctt = (String)mapResBody.get('err_msg_ctt');

                System.debug('============> err_cd : '+err_cd);
                System.debug('============> err_msg_ctt : '+err_msg_ctt);

                if(err_cd == '0000') {
                    try {
                        EDMSFile__c objEDMSFile = new EDMSFile__c();
                        objEDMSFile.Id = targetFile.SFDCID;
                        delete objEDMSFile; 
                    } catch(Exception e) {
                        strStatus = 'ERROR';
                        strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
                    }
                }else {
                    strStatus = 'ERROR';
                    strMessage = '[I/F Error] 파일업로드에 실패하였습니다. 관리자에 문의하여 주시기 바랍니다. 에러코드 : '+response.getStatusCode();
                }
            }else {
                strStatus = 'ERROR';                    
                strMessage = '[I/F Error]  파일업로드에 실패하였습니다. 관리자에 문의하여 주시기 바랍니다. 에러코드 : '+response.getStatusCode();
            }
            
        }catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        System.debug('===============> strStatus : '+strStatus);
        System.debug('===============> strMessage : '+strMessage);

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
        public String downloadUrl {get;set;}

        @AuraEnabled
        public List<Map<String, String>> listSelectType {get;set;}
        @AuraEnabled
        public List<FileWrapper> listFileWrapper {get;set;}
	}

    public class FileWrapper {
        @AuraEnabled
        public String fileName {get;set;}
        @AuraEnabled
        public String fileExt {get;set;}
        @AuraEnabled
        public String iconName {get;set;}
        @AuraEnabled
        public String downloadURL {get;set;}
        @AuraEnabled
        public String SFDCID {get;set;}
        /** [P2] */
        @AuraEnabled
        public String typeLabel {get;set;}
        
    }

    public class EDMSFile {
        @AuraEnabled
        public String system_type_cd {get;set;}
        @AuraEnabled
        public String opcode {get;set;}
        @AuraEnabled
        public String doctypecd {get;set;}
        @AuraEnabled
        public String attrid {get;set;}
        @AuraEnabled
        public String orgattrid {get;set;}
        @AuraEnabled
        public String attrvalue {get;set;}
        @AuraEnabled
        public String category {get;set;}
        @AuraEnabled
        public String download_url {get;set;}
        @AuraEnabled
        public String file_name {get;set;}
        @AuraEnabled
        public String file_ext {get;set;}
	}
}