/**
 * Created by 천유정 on 2023-01-16.
 */

@IsTest
private class QuoteSendEmailController_test {
    @TestSetup
    static void QuoteSendEmailController_testSetUp() {
        try{
            Account objHealthAccount = TestObjectCreator.objHealthAccount;
            insert objHealthAccount;
            Account objExAccount = TestObjectCreator.objExAccount;
            insert objExAccount;

            PricebookEntry objPricebookEntry = TestObjectCreator.objPricebookEntry;
            insert objPricebookEntry;

            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = '테스트';
            objOpportunity.StageName = 'Needs Analysis';
            objOpportunity.CloseDate = Date.today();
            objOpportunity.AccountId = objHealthAccount.Id;
            insert objOpportunity;

            Quote objQuote = new Quote();
            objQuote.OpportunityId = objOpportunity.Id;
            objQuote.Name = objOpportunity.Name;
            objQuote.Pricebook2Id = objPricebookEntry.Pricebook2Id;
            insert objQuote;

            QuoteLineItem objQuoteLineItem = new QuoteLineItem();
            objQuoteLineItem.Month__c = 'LateOct';
            objQuoteLineItem.PricebookEntryId = objPricebookEntry.Id;
            objQuoteLineItem.BasePurchasePrice__c = objPricebookEntry.LateOct__c;
            objQuoteLineItem.UnitPrice = 1000;
            objQuoteLineItem.ProfitMargin__c = 0;
            objQuoteLineItem.UnitPriceWithVAT__c = 0;
            objQuoteLineItem.Quantity = 1;
            objQuoteLineItem.QuoteId = objQuote.Id;
            insert objQuoteLineItem;

        } catch (Exception e) {
            System.debug('QuoteSendEmailController_test line : ' + e.getLineNumber());
            System.debug('QuoteSendEmailController_test message : ' + e.getMessage());
            System.debug('QuoteSendEmailController_test cause : ' + e.getCause());
        }
    }
    
    @IsTest
    static void QuoteSendEmailController_test() {
        test.startTest();

        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Quote objQuote = [SELECT Id, Opportunity.Name, Name FROM Quote LIMIT 1];
        List<QuoteLineItem> listQuoteLineItem = [
                SELECT Id, Month__c,PricebookEntryId,BasePurchasePrice__c,UnitPrice,ProfitMargin__c,UnitPriceWithVAT__c,Quantity,QuoteId
                FROM QuoteLineItem
                WHERE QuoteId =: objQuote.Id
        ];

        Contact objContact = new Contact(LastName='김테스트', Email='test232@naver.com', AccountId=objAccount.Id);
        Contact objContact2 = new Contact(LastName='김테스트2', Email='test234@naver.com', AccountId=objAccount.Id);
        insert objContact;
        insert objContact2;


        // Excel Download 시 보여질 필드 선택
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

        String quoteIe = objQuote.Id;
        List<String> listChunkQuote = new List<String>();
        listChunkQuote.add(quoteIe);

        QuoteSendEmailController.getInitData(objQuote.Id);

        Map<String, Object> mapObject = new Map<String, Object>();
        mapObject = QuoteSendEmailController.doSearchAccount('HealthAccount');

        QuoteSendEmailController.getInitContactList(objAccount.Id);
        QuoteSendEmailController.doCreateQuoteLineItem(listChunkQuote, listQuoteLineItem);

        Map<String, Object> mapAccount = new Map<String, Object>();
        mapAccount.put('ContactEmail', 'test232@naver.com');
        mapAccount.put('ContactId', objContact.Id);
        mapAccount.put('Id', ObjAccount.Id);
        Object obj = mapAccount;
        mapObject.put('Test', obj);

        QuoteSendEmailController.doCreateQuote(objQuote, mapObject.get('Test'));

        QuoteSendEmailController.doCreateFileAndSendEmail('Y', 'PDF', '제목', '내용', mapObject.get('Test'), objQuote.Id, s2.remove(' '));

        test.stopTest();
    }

}