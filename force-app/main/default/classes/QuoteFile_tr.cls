/************************************************************************************
 * File Name   		: QuoteFile_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.10.20
 * Tester	  		: QuoteFile_tr_test.cls
 * Description 		: QuoteFile_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.08.24      Minje.Kim       Create
*************************************************************************************/

public without sharing class QuoteFile_tr extends TriggerHandler {
    public QuoteFile_tr() {
        listNew = (List<QuoteFile__c>) trigger.new;
        mapOld = (Map<Id, QuoteFile__c>) trigger.oldMap;
        listOld = (List<QuoteFile__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<QuoteFile__c> listNew { get; set; }
    private List<QuoteFile__c> listOld { get; set; }
    private Map<Id, QuoteFile__c> mapOld { get; set; }

    public override void beforeDelete() {
        // QuoteFile에 연결된 Attachment(ContentDocument) 삭제
        doHandleRelatedDelete();
    }

    /***********************************************************************************************************
    *  Trigger  : Before Delete
    *  내용     : 레코드 삭제시 연결된 ContentDocument 삭제
    ************************************************************************************************************/
    private void doHandleRelatedDelete() {

        Set<Id> setIdDocumentId = new Set<Id>();
        for (QuoteFile__c objQuoteFile : listOld) {
            if (objQuoteFile.ContentDocumentId__c != '')
                setIdDocumentId.add(objQuoteFile.ContentDocumentId__c);
        }

        List<ContentDocument> listContentDocument = [
                SELECT Id
                FROM ContentDocument
                WHERE Id IN :setIdDocumentId
        ];

        if (!listContentDocument.isEmpty()) {
            delete listContentDocument;
        }
    }
}