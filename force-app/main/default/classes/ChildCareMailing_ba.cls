/*
* ==================================================================================
*   File Name   : ChildCareMailing_ba.cls
*   Author      : JY. Yeo
*   Date        : 2023.07.28
*   Tester      : ChildCareMailing_ba.cls
*   Description : ChildCareMailing_ba Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2023.06.28    JY. Yeo    Create
* ==================================================================================
*/
public without sharing class ChildCareMailing_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    Map<String, Integer> mapData = new Map<String, Integer>();        

    public ChildCareMailing_ba() {
    }

    /***********************************************************************************************************
    *  Bacth   : Start
    *  내용    : 메일 수신인 리스트 
    ************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('ChildCareMailing_ba Start !!');
        String recordtypeId = Schema.SObjectType.MailRecipientMaster__c.getRecordTypeInfosByDeveloperName().get('NewChildCare').getRecordTypeId();
		
        System.debug('ChildCareMailing_ba Start !!' + recordtypeId);
        string strQuery = '';
		strQuery += '  SELECT  Id, Name, MailAddress__c, RegionList__c ';
		strQuery += '  FROM    MailRecipientMaster__c  ';
		strQuery += '  WHERE   recordTypeId =: recordtypeId  ';
		//strQuery += '  LIMIT 1  ';
    
		return Database.getQueryLocator(strQuery);
    }

    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 지역별 어린이집 담당자별 메일 발송
    ************************************************************************************************************/
    public void execute(Database.BatchableContext BC, List<MailRecipientMaster__c> listTarget) {
        if( !listTarget.isEmpty()){
            doCreateFileAndSendEmail(listTarget);
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
    * @author : 
    * @exception : <try-catch>
    * @return :
    */
    @AuraEnabled
    public static Map<String, Object> doCreateFileAndSendEmail(List<MailRecipientMaster__c> targetList) {
        System.debug('doCreateFileAndSendEmail ==== Start!');
        String recordtypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('KindergartenLead').getRecordTypeId();
        System.debug('doCreateFileAndSendEmail ==== Start!' + recordtypeId);
        List<Lead> leadList = [SELECT Id, Region__c, State, City, Company, AddressDetails__c, Phone, AuthorizedCapacity__c, NumberofChildren__c,  AuthorizationDate__c
                      FROM LEAD 
                      WHERE recordTypeId =: recordtypeId
                      AND AuthorizationDate__c >= TODAY 
                      AND NumberofChildren__c = 0 ];

        Map<String, List<Object>> leadMap = new Map<String, List<Object>>();

        for(Lead ld :  leadList){
            List<Object> targetLeadList = new List<Object>();
            if(leadMap.containsKey(ld.Region__c)){
                targetLeadList = leadMap.get(ld.Region__c);
            }
            targetLeadList.add(ld);
            leadMap.put(ld.Region__c, targetLeadList);
        }

        //2. 발송처 그룹핑
        ///Object objChildCareLead = [SELECT Id, Name, Company,  KindergartenCode__c, AddressDetails__c, 
        //Phone, FAx, Website,  AuthorizedCapacity__c, AuthorizationDate__c FROM LEAD LIMIT 10]; // 리드 내용 
        Map<String, List<String>> emailMap = new Map<String, List<String>>();

        for(MailRecipientMaster__c obj :  targetList){
            List<String> targetEmailList = new List<String>();
            if(emailMap.containsKey(obj.RegionList__c)){
                targetEmailList = emailMap.get(obj.RegionList__c);
            }
            targetEmailList.add(obj.MailAddress__c);
            emailMap.put(obj.RegionList__c, targetEmailList);
        }
        
        String strStatus = 'SUCCESS';
        String strMessage = '';
        String listSelected = ' Id, Region__c, State, City, KindergartenType__c, Company, AddressDetails__c, Phone, AuthorizedCapacity__c, NumberofChildren__c,  AuthorizationDate__c ';

        Messaging.SingleEmailMessage message = null;
        Map<String, Object> mapSelectedResult = null;
        String SendFailedReason = '';
        // TEST
        //listContactEmail.add('jiyoung.yeo@cj.net');
        try {
            for(String rName: leadMap.keySet()){
                List<String> listContactEmail = new List<String>();

                listContactEmail = emailMap.get(rName);
                Object objChildCareLead = leadMap.get(rName);
                System.debug('doCreateFileAndSendEmail ==== [listContactEmail] : '+ listContactEmail);
                String fId = doCreateFile(listSelected, rName);
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
                Date targetDate = Date.today();
                message.setSubject(targetDate.year() + '년 ' + targetDate.month() + '월 ' + targetDate.day() + '일 기준 어린이집 신규 인가처');
                String sub = '안녕하세요. CJ프레시웨이 입니다.<br> ' ;
                sub += targetDate.year() + '년 ' + targetDate.month() + '월 ' + targetDate.day() + '일 기준 어린이집 신규 인가처 공유드립니다. .<br/> <br/>';
                sub += '세부 내용은 첨부파일 확인 부탁드립니다.<br/> <br/>   ';
                sub += ' ※ 본 메일은 자동 메일링 서비스입니다. 기타 문의사항은 담당 영업사원을 통해 연락 부탁드립니다. </br>';
                message.setHtmlBody(sub);
    
                System.debug('message >>> ' + message);
                if(!Test.isRunningTest()){
                    Messaging.SendEmailResult [] r =Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        message
                });
    
                if(r[0].isSuccess() == false) {
                    SendFailedReason = r[0].getErrors().toString();
                }
                System.debug('SendEmailResult ====> ' + r);
                }
                
            }

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
                'SendFailedAddress' => ''
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
    public static String doCreateFile(String listSelectedSave, String region) {
        System.debug('listSelectedSave ========> '  + listSelectedSave); 
        

        String strfileVersion ;              
        Decimal decfileVersion ;
        decfileVersion = 1;
        strfileVersion = String.valueOf(decfileVersion);

        // Type에 따라 Blob화 분기
        Blob body ;
        try {
            PageReference excel = new pagereference('/apex/ChildCareLeadExcelCreate');
            //excel.getParameters().put('Id', recordId );  objChildCareLead
            excel.getParameters().put('listSelectedField', listSelectedSave );
            excel.getParameters().put('region', region );
            System.debug('excel link ========> '  + excel.getUrl());
            body = excel.getContent();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Error');
        }
        
        // 확장자 따라 Blob화 분기
        Date targetDate = Date.today();
        String fileName = targetDate.year() + '년 ' + targetDate.month() + '월 ' + targetDate.day() + '일 기준 어린이집 신규 인가처_CJFW.xls';
        String fileType = 'xls';
        //String fileName = 'CJFW_신규어린이집인가.xls';

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