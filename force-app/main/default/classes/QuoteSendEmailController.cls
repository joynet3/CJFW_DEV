/**
 * Created by 천유정 on 2022-12-26.
 */

public with sharing class QuoteSendEmailController {
    /**
    * @description : fnInit - 초기화
    * @author : 천유정
    * @exception : <try-catch>
    * @param : recordId - 레코드아이디
    * @return :
    */
    @AuraEnabled
    public static Map<String, Object> getInitData(String recordId) {
        System.debug('getInitData ==== Start!');
        System.debug('getInitData ==============> [recordId] ' + recordId);

        String strStatus = 'SUCCESS';
        String strMessage = '';

        Quote objQuote;
        List<QuoteLineItem> listQuoteLineItems;
        User objUser;

        // Excel Download 시 보여질 필드 선택
        List<Map<String, Object>> listFieldMap = CommonUtil.getFieldSet('QuoteLineItem','QuoteLineItemFileCreate');
        List<Map<String, String>> listField = new List<Map<String, String>>();
        List<String> listRequiredField = new List<String>();

        try {
            objQuote = [
                    SELECT Id, Name, OpportunityId, Opportunity.Name, Opportunity.RecordTypeId, Opportunity.StageName
                    FROM Quote
                    WHERE Id =: recordId
            ];
            listQuoteLineItems = [
                    SELECT Id, PricebookEntryId, Month__c, BasePurchasePrice__c, UnitPrice, ProfitMargin__c,
                            UnitPriceWithVAT__c, Quantity, Product2Id
                    FROM QuoteLineItem
                    WHERE QuoteId =: recordId
            ];
            objUser = [
                    SELECT Id, LastName
                    FROM User
                    WHERE Id =: UserInfo.getUserId()
            ];

            for ( Map<String, Object> objMap : listFieldMap ) {
                listField.add(new Map<String, String>{
                        'label' => String.valueOf(objMap.get('label')),
                        'value' => String.valueOf(objMap.get('apiName')),
                        'type' => String.valueOf(objMap.get('type'))
                });
                if ( objMap.get('required') == true )
                    listRequiredField.add(String.valueOf(objMap.get('apiName')));
            }

        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            System.debug('[getInitData] ERROR ===>' + strMessage);
        }
        System.debug('getInitData ==== End!');
        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage,
                'objQuote' => objQuote,
                'listQuoteLineItems' => listQuoteLineItems,
                'userEmail' => UserInfo.getUserEmail(),
                'userName' => objUser.LastName,
                'listField' => listField,
                'listRequiredField' => listRequiredField
        };
        return mapReturn;
    }

    /**
    * @description : doSearchAccount - 견적 이메일 발송(1/3)에서 입력값에 따라 Account 검색
    * @author : 천유정
    * @exception : <try-catch>
    * @param : stringKey - 사용자가 입력한 키워드값(고객명)
    * @return :
    */
    @AuraEnabled
    public static Map<String, Object> doSearchAccount(String stringKey) {
        System.debug('doSearchAccount ==== Start!');

        System.debug('doSearchAccount ==============> [stringKey] ' + stringKey);

        List<Account> listAccount;
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        Map<Id, List<Contact>> contMap = new Map<Id, List<Contact>>();

        String strStatus = 'SUCCESS';
        String strMessage = '';
        try {
            String strQuery = 'SELECT Id';
            strQuery += '   ,Name, Phone,  Address__c, Website, (select Id, Name, Email from Contacts) ';
            strQuery += '   FROM    Account';
            if(stringKey <> null && stringKey != '') {
                strQuery += '   WHERE   Name LIKE \'%' + stringKey + '%\'';
            }
            strQuery += '   ORDER BY    Name';
            strQuery += '   LIMIT    10000';

            listAccount = Database.query(strQuery);
            System.debug('listAccount ==========>' + listAccount);

            if (!listAccount.isEmpty() && listAccount.size() > 0) {
                List<Contact> contList;
                for(Account a : listAccount) {
                    contList = new List<Contact>();
                    for(Contact c : a.Contacts) {
                        contList.add(c);
                    }
                    contMap.put(a.Id, contList);
                }
                System.debug('contMap =========> ' + contMap);
            }

        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            System.debug('[doSearchAccount] ERROR ===>' + strMessage);
        }
        System.debug('doSearchAccount ==== End!');
        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage,
                'listSearchResult' => listAccount,
                'contMap' => contMap
        };
        return mapReturn;
    }

    /**
    * @description : getInitContactList - Contact 목록 불러오기
    * @author : 천유정
    * @exception : <try-catch>
    * @param : objAccountId - '연락처 검색' 버튼을 누른 행의 Account Id
    * @return :
    */
    @AuraEnabled
    public static Map<String, Object> getInitContactList(String objAccountId ) {
        System.debug('getInitContactList ==== Start!');

        System.debug('getInitContactList ==============> [objAccountId] ' + objAccountId);

        String strStatus = 'SUCCESS';
        String strMessage = '';
        List<Contact> listContacts = new List<Contact>();

        try {
            System.debug('objAccountId ====>' + objAccountId);
            listContacts = [
                    SELECT Id, Name, Email, Phone, AccountId, MobilePhone
                    FROM Contact
                    WHERE AccountId =: objAccountId
            ];
        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            System.debug('[getInitContactList] ERROR ===>' + strMessage);

        }
        System.debug('getInitContactList ==== End!');
        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage,
                'listContacts' => listContacts
        };
        return mapReturn;
    }

    /**
    * @description : doCreateQuote - Opportunity & Quote 생성
    * @author : 천유정
    * @exception : <try-catch>
    * @param : objQuote - 기존 Quote Id
    * @param : objCurrentAccount - Opportunity & Quote 생성를 생성할 Account Id (Helper 내 Batch를 통해 생성, Size = 1)
    * @return :
    */
    @AuraEnabled
    public static Map<String, Object> doCreateQuote(Quote objQuote, Object objCurrentAccount) {
        System.debug('doCreateQuote ==== Start!');

        System.debug('doCreateQuote ==============> [objQuote] ' + objQuote);
        System.debug('doCreateQuote ==============> [objCurrentAccount] ' + objCurrentAccount);

        String strStatus = 'SUCCESS';
        String strMessage = '';
        Map<String, Object> mapSelectedResult = null;
        List<String> listAccountId = new List<String>();             // 선택한 Account Id 목록
        List<String> listFailed = new List<String>();         // 생성에 실패한 Account Id 목록
        List<String> listSucceed = new List<String>();        // 생성에 성공한 Account Id 목록

        try {
            mapSelectedResult = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objCurrentAccount));
            listAccountId.add((String) mapSelectedResult.get('Id'));

            if (!listAccountId.isEmpty()) {
                System.debug('listAccountId ==============>' + listAccountId);
                Map<String, Opportunity> mapOpportunity = new Map<String, Opportunity>();
                Opportunity objOpportunity;

                for (String objId : listAccountId) {
                    objOpportunity = new Opportunity();
                    objOpportunity.AccountId = objId;
                    objOpportunity.Name = objQuote.Opportunity.Name;
                    objOpportunity.StageName = 'Needs Analysis';
                    objOpportunity.CloseDate = Date.today();
                    mapOpportunity.put(objId, objOpportunity);
                }

                if (mapOpportunity <> null && mapOpportunity.size() > 0) {
                    List<Quote> listQuote = new List<Quote>();
                    Quote objNewQuote;

                    Database.SaveResult[] srList = Database.insert(mapOpportunity.values(), false);
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted Opportunity. Opportunity ID: ' + sr.getId());
                            objNewQuote = new Quote();
                            objNewQuote.OpportunityId = sr.getId();
                            objNewQuote.OriginalQuote__c = objQuote.Id;
                            objNewQuote.Name = objQuote.Name;
                            listQuote.add(objNewQuote);
                        }
                        else {
                            // Operation failed, so get all errors
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Opportunity fields that affected this error: ' + err.getFields());
                            }
                        }
                    }

                    if (!listQuote.isEmpty()) {
                        System.debug('listQuote ===================> ' + listQuote);
                        Database.SaveResult[] srQuoteList = Database.insert(listQuote, false);
                        for (Database.SaveResult sr : srQuoteList) {
                            if (sr.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted Quote. Quote ID: ' + sr.getId());
                                listSucceed.add(sr.getId());
                            }
                            else {
                                // Operation failed, so get all errors
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Quote fields that affected this error: ' + err.getFields());
                                }
                            }
                        }
                    }
                }
            }
        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            System.debug('[doCreateQuote] ERROR ===>' + strMessage);
        }
        System.debug('doCreateQuote ==== End!');
        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage,
                'listFailed' => listFailed,
                'listSucceed' => listSucceed
        };
        return mapReturn;
    }

    /**
    * @description : doCreateQuoteLineItem - Quote Line Item 생성
    * @author : 천유정
    * @exception : <try-catch>
    * @param : listChunkQuote - Quote Line Item을 복제할 Quote의 Id
    * @param : listChunkLineItem - 복제할 기존 Quote Line Item (Helper 내 Batch를 통해 생성, LineItemBatchCount 수만큼 List에 담겨 전달됨)
    * @return :
    */
    @AuraEnabled
    public static Map<String, Object> doCreateQuoteLineItem(List<String> listChunkQuote, List<QuoteLineItem> listChunkLineItem) {
        System.debug('doCreateQuoteLineItem ==== Start!');
        System.debug('doCreateQuoteLineItem ==== [listChunkQuote] ' + listChunkQuote);
        System.debug('doCreateQuoteLineItem ==== [listChunkLineItem] ' + listChunkLineItem);

        String strStatus = 'SUCCESS';
        String strMessage = '';
        try {
            List<QuoteLineItem> listNewQuoteLineItem = new List<QuoteLineItem>();
            QuoteLineItem objNewQuoteLineItem;
            for (QuoteLineItem obj : listChunkLineItem) {
                for (String quoteId : listChunkQuote) {
                    objNewQuoteLineItem = new QuoteLineItem();
                    objNewQuoteLineItem.Month__c = obj.Month__c;
                    objNewQuoteLineItem.PricebookEntryId = obj.PricebookEntryId;
                    objNewQuoteLineItem.BasePurchasePrice__c = obj.BasePurchasePrice__c;
                    objNewQuoteLineItem.UnitPrice = obj.UnitPrice;
                    objNewQuoteLineItem.ProfitMargin__c = obj.ProfitMargin__c;
                    objNewQuoteLineItem.UnitPriceWithVAT__c = obj.UnitPriceWithVAT__c;
                    objNewQuoteLineItem.Quantity = obj.Quantity;
                    objNewQuoteLineItem.QuoteId = quoteId;
                    listNewQuoteLineItem.add(objNewQuoteLineItem);
                }
            }

            if (!listNewQuoteLineItem.isEmpty()) {
                Database.SaveResult[] srl = Database.insert(listNewQuoteLineItem, false);
                for (Database.SaveResult sr : srl) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        // System.debug('Successfully inserted. ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Those fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
            System.debug('[doCreateQuoteLineItem] ERROR ===>' + strMessage);
        }
        System.debug('doCreateQuoteLineItem ==== End!');
        Map<String, Object> mapReturn = new Map<String, Object>{
                'strStatus' => strStatus,
                'strMessage' => strMessage
        };
        return mapReturn;
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
            String sendYN, String fileType, String contentHeader, String contentBody, Object objCurrentAccount, Id recordId, String listSelected) {
        System.debug('doCreateFileAndSendEmail ==== Start!');

        System.debug('doCreateFileAndSendEmail ==== [sendYN] : '+ sendYN);
        System.debug('doCreateFileAndSendEmail ==== [fileType] : '+ fileType);
        System.debug('doCreateFileAndSendEmail ==== [contentHeader] : '+ contentHeader);
        System.debug('doCreateFileAndSendEmail ==== [contentBody] : '+ contentBody);
        System.debug('doCreateFileAndSendEmail ==== [objCurrentAccount] : '+ objCurrentAccount);
        System.debug('doCreateFileAndSendEmail ==== [recordId] : '+ recordId);

        String strStatus = 'SUCCESS';
        String strMessage = '';

        Messaging.SingleEmailMessage message = null;
        Map<String, Object> mapSelectedResult = null;
        String SendFailedReason = '';
        List<String> listContactEmail = new List<String>();

        try {
            list<String> listContactId = new list<String>();

            mapSelectedResult = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objCurrentAccount));
            listContactEmail.add((String) mapSelectedResult.get('ContactEmail'));
            listContactId.add((String) mapSelectedResult.get('ContactId'));


            System.debug('doCreateFileAndSendEmail ==== [listContactEmail] : '+ listContactEmail);

            if (fileType != 'N' && fileType != null) {
/*                // Excel Download 시 보여질 필드 선택
                List<Map<String, Object>> listFieldMap = CommonUtil.getFieldSet('QuoteLineItem','QuoteLineItemFileCreate');
                List<Map<String, String>> listField = new List<Map<String, String>>();
                List<String> listRequiredField = new List<String>();

                for ( Map<String, Object> objMap : listFieldMap ) {
                    listField.add(new Map<String, String>{
                            'label' => String.valueOf(objMap.get('label')),
                            'value' => String.valueOf(objMap.get('apiName')),
                            'type' => String.valueOf(objMap.get('type'))
                    });
                    if ( objMap.get('required') == true )
                        listRequiredField.add(String.valueOf(objMap.get('apiName')));
                }
                System.debug('listRequiredField =====> ' + listRequiredField.toString());

                String subReturn = listRequiredField.toString();
                String s2 = subReturn.substringBetween('(', ')');
                System.debug('s2 =====> ' + s2.remove(' '));*/

                QuoteFileCreateController.doCreateFile(recordId, fileType, listSelected);
            }

            if (sendYN == 'Y') {
                message = new Messaging.SingleEmailMessage();

                List<ContentVersion> files = new List<ContentVersion>();

                Set<Id> setContentDocumentLink = new Set<Id>();
                for (ContentDocumentLink obj : [
                        SELECT Id, ContentDocumentId, LinkedEntityId
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId = :recordId
                ]) {
                    setContentDocumentLink.add(obj.ContentDocumentId);
                }

                if (!setContentDocumentLink.isEmpty()) {
                    System.debug('setContentDocumentLink :: ' + setContentDocumentLink);
                    Set<Id> setContentVersionId = new Set<Id>();
                    for (ContentVersion obj : [
                            SELECT Id, Title, FileType, VersionData, ContentDocumentId
                            FROM ContentVersion
                            WHERE ContentDocumentId = :setContentDocumentLink
                            LIMIT 1
                    ]) {
                        System.debug('file111 :: ' + obj);
                        setContentVersionId.add(obj.Id);
                        files.add(obj);
                    }
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
                message.setTargetObjectId(listContactId[0]);        //Contact Id (User는 Activity 추적 X)
                message.setWhatId(recordId);                        //관련 Object Id
                message.setSaveAsActivity(true);                    //Activity 추가 지정
                
                //일반사용자 Test
                // String currEmail = UserInfo.getUserEmail();
                // message.setReplyTo(currEmail);
                // message.setSenderDisplayName(currEmail);

                System.debug('message >>> ' + message);

                Messaging.SendEmailResult [] r =Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        message
                });

                if(r[0].isSuccess() == false) {
                    SendFailedReason = r[0].getErrors().toString();
                }
                System.debug('SendEmailResult ====> ' + r);
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
                'SendFailedAddress' => SendFailedReason == '' ?  '' : listContactEmail[0]
        };
        return mapReturn;
    }
}