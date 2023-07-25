/************************************************************************************
 * File Name   		    : DecisionProcess_tr_test.cls
 * Author	  		    : Minje.kim
 * Date				    : 2023.06.28
 * Target	  		    : DecisionProcess_tr.cls
 * Description 		    : DecisionProcess_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.06.28      Minje.kim       Create
 *************************************************************************************/


 @IsTest
 private class DecisionProcess_tr_test {
     @TestSetup
     static void DecisionProcess_tr_testSetUp() {
 
         Set<String> setIFId = new Set<String>{'IF_SFDC_IFRESH_REG_APPROVAL'};
 
         List<IFMaster__c> listIF = new List<IFMaster__c>();
 
         for(String str : setIFId) {
             IFMaster__c obj = new IFMaster__c();
             obj.Name = str;
             obj.ContentType__c = 'application/json';
             obj.Endpoint__c = 'https://test.salesforce.com';
             obj.Method__c = 'POST';
             obj.Type__c = 'Outbound';
             obj.WebServiceType__c = 'REST';
 
             listIF.add(obj);
         }
 
         insert listIF;
 
         IF_RELAY_INFO__c objRelayInfo = new IF_RELAY_INFO__c();
         objRelayInfo.Interface_id__c = 'test';
         objRelayInfo.Interface_auth_key__c = 'test';
 
         insert objRelayInfo;
 
         Account objAccount = TestObjectCreator.objHealthAccount;
         insert objAccount;
 
         PricebookEntry objPriceBookEntry = TestObjectCreator.objPricebookEntry;
         insert objPriceBookEntry;
 
         Opportunity objOpportunity = new Opportunity();
         objOpportunity.AccountId = objAccount.Id;
         objOpportunity.Name = '영업활동';
         objOpportunity.CloseDate = date.valueOf('2022-01-01');
         objOpportunity.StageName = 'Proposal';
         objOpportunity.BidNoticeSource__c = 'NotNull';
         objOpportunity.LeadSource = 'NaraMarket';
         objOpportunity.BidQualifyRegistCloseDateTime__c = date.valueOf('2022-01-01');
         insert objOpportunity;
     }
 
     @IsTest
     static void DecisionProcess_tr_test() {
         test.startTest();
 
         try {
             Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
             DecisionProcess__c objDecisionProcess = new DecisionProcess__c();
             objDecisionProcess.Name = '제안 품의';
             objDecisionProcess.DocStatus__c = '임시저장';
             objDecisionProcess.DocId__c = '046B9F0DC91A';
             objDecisionProcess.totalLineCount__c = 2;
             objDecisionProcess.approvedCount__c = 1;
             objDecisionProcess.approvedUserName__c = '김성진님';
             objDecisionProcess.approvedUserType__c = '기안자';
             objDecisionProcess.approvedUserCode__c = '1000000245';
             objDecisionProcess.approvedDate__c = '"2023-01-20 16:01:54';
             objDecisionProcess.Type__c = 'CRM004';
             objDecisionProcess.Opportunity__c = objOpportunity.Id;

             insert objDecisionProcess;

             Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
             delete objDecisionProcess;

         } catch (Exception e) {
             system.debug('DecisionProcess_tr_test  error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
         }
         test.stopTest();
     }

    // err_cd":"성공"
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = newResponse(200);

            return response;
        }
    }

    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        response.setBody('{"result":"성공","message":"046B9F0DC91A"}');
        return response; 
    }

 
 }