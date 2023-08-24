/*
* ==================================================================================
*   File Name   : ChildCareMailing_ba.cls
*   Author      : Minje.Kim
*   Date        : 2023.01.09
*   Tester      : ChildCareMailing_ba.cls
*   Description : ChildCareMailing_ba Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2023.01.09    JY. Yeo    Create
* ==================================================================================
*/
public without sharing class ChildCareMailing_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    Map<String, Integer> mapData = new Map<String, Integer>();        

    public ChildCareMailing_ba() {
    }

    /***********************************************************************************************************
    *  Bacth   : Start
    *  내용    : 전자결재 상태 업데이트 대상선정(완료, 회수 제외)
    ************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('ApprovalLineAutoUpdate_ba Start !!');

		string strQuery = '';
		strQuery += '  SELECT  Id, Email  ';
		strQuery += '  FROM    User  ';
		//strQuery += '  WHERE   Email = \'jiyoung.yeo@cj.net\'  ';
		strQuery += '  LIMIT 1  ';
    
		return Database.getQueryLocator(strQuery);
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 전자결재 상태 업데이트 진행 ( ApprovalLineUpdateController 컨트롤러의 doUpdateApproval 함수 사용)
    ************************************************************************************************************/
    public void execute(Database.BatchableContext BC, List<User> listTarget) {

        if( !listTarget.isEmpty()){
            User objDecisionProcess = listTarget[0];
            doCreateFileAndSendEmail('test','test');
        }
    }

    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 내용 없음
    ************************************************************************************************************/
    public void finish(Database.BatchableContext BC) {
        System.debug('ChildCareMailing_ba finish !!');
    }

    
    /**
    * @description : doCreateFileAndSendEmail - File 생성 & Email 전송
    * @author : 천유정
    * @exception : <try-catch>
    * @param : sendYN - 이메일 전송 여부 값
    * @param : fileType - 견적 파일 Type 값
    * @param : contentHeader - 이메일 제목
    * @param : contentBody - 이메일 내용
    * @param : objCurrentAccount - 현재 Account의 Id
    * @param : listSelected - 파일 내 표시할 필드 목록
    * @return :
    */
    @AuraEnabled
    public static Map<String, Object> doCreateFileAndSendEmail(
            String contentHeader, String contentBody) {
        System.debug('doCreateFileAndSendEmail ==== Start!');

        Object objChildCareLead = [SELECT Id, Name, Company,  KindergartenCode__c, AddressDetails__c, 
        Phone, FAx, Website,  AuthorizedCapacity__c, AuthorizationDate__c FROM LEAD LIMIT 10]; // 리드 내용 
        String strStatus = 'SUCCESS';
        String strMessage = '';
        String listSelected = ' Id, Name, Company,  KindergartenCode__c, AddressDetails__c, Phone, FAx, Website,  AuthorizedCapacity__c, AuthorizationDate__c ';

        Messaging.SingleEmailMessage message = null;
        Map<String, Object> mapSelectedResult = null;
        String SendFailedReason = '';
        List<String> listContactEmail = new List<String>();
        // TEST
        listContactEmail.add('jiyoung.yeo@cj.net');
        try {

            //mapSelectedResult = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objChildCareLead));
            System.debug('doCreateFileAndSendEmail ==== [listContactEmail] : '+ listContactEmail);
            String fId = doCreateFile(listSelected);
        
            message = new Messaging.SingleEmailMessage();

            List<ContentVersion> files = new List<ContentVersion>();

            Set<Id> setContentVersionId = new Set<Id>();
            for (ContentVersion obj : [
                    SELECT Id, Title, FileType, VersionData, ContentDocumentId
                    FROM ContentVersion
                    WHERE Id = :fId
                    LIMIT 1
            ]) {
                System.debug('file111 :: ' + obj);
                setContentVersionId.add(obj.Id);
                files.add(obj);
            }

            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            for (ContentVersion file : files) {
                System.debug('file :: ' + file);
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(file.Title);
                efa.setBody(file.VersionData);
                //efa.setContentType(file.FileType);
                attachments.add(efa);
            }
            message.setFileAttachments(attachments);


            message.setToAddresses(listContactEmail);
            message.setSubject(contentHeader);
            message.setHtmlBody(contentBody);
            //message.setTargetObjectId(listContactId[0]);        //Contact Id (User는 Activity 추적 X)
            //message.setWhatId(recordId);                        //관련 Object Id
            // message.setSaveAsActivity(true);             //Activity 추가 지정

            System.debug('message >>> ' + message);

            Messaging.SendEmailResult [] r =Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    message
            });

            if(r[0].isSuccess() == false) {
                SendFailedReason = r[0].getErrors().toString();
            }
            System.debug('SendEmailResult ====> ' + r);
            

        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            System.debug('[doCreateFileAndSendEmail] ERROR ===>' + strMessage);
        }
        System.debug('doCreateFileAndSendEmail ==== End!');
        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage,
                'SendFailedReason' => SendFailedReason,
                'SendFailedAddress' => SendFailedReason == '' ?  '' : listContactEmail[0]
        };
        return mapReturn;
    }
        /**
     * Prefix 및 필드셋 정보 조회
     * 
     * @param  recordId : 견적서 Record Id
     * @param  saveType : 파일 타입 (PDF/Excel)
     * @param  listSelectedSave : 파일 내 조회될 필드 리스트
     * 
    **/
    @AuraEnabled
    public static String doCreateFile(String listSelectedSave) {
        System.debug('listSelectedSave ========> '  + listSelectedSave); 
        

        String strfileVersion ;              
        Decimal decfileVersion ;
        decfileVersion = 1;
        strfileVersion = String.valueOf(decfileVersion);

        // Type에 따라 Blob화 분기
        Blob body ;
        try {
            PageReference excel = new pagereference('/apex/ChildCareLeadExcelCreate');
            //excel.getParameters().put('Id', recordId ); 
            excel.getParameters().put('listSelectedField', listSelectedSave );
            System.debug('excel link ========> '  + excel.getUrl());
            body = excel.getContent();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Error');
        }
        
        // 확장자 따라 Blob화 분기
        String fileType = 'xls';
        String fileName = 'testFile.xls';

        ContentVersion objContentVersion = new ContentVersion(
                Title = fileName,
                PathOnClient = fileName,
                VersionData = body
        );
        insert objContentVersion;

        ContentDistribution objContentDistribution = new ContentDistribution(
            ContentVersionId = objContentVersion.Id,
            Name = fileName,
            PreferencesAllowViewInBrowser = true,
            PreferencesLinkLatestVersion = true,
            PreferencesNotifyOnVisit = false,
            PreferencesPasswordRequired = false,
            PreferencesAllowOriginalDownload = true
        );

        insert objContentDistribution;
        String fId = objContentVersion.Id;
        return fId;
    }
}