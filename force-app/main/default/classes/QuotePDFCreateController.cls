/*
* ==================================================================================
*   File Name   : QuotePDFCreateController.cls
*   Author      : Minje.Kim
*   Date        : 2022.08.08
*   Tester      : QuotePDFCreateController_test.cls
*   Description : Quote PDF Modal Create
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.08.08    Minje.Kim       Create
* ==================================================================================
*/

public with sharing class QuotePDFCreateController {
    
    @AuraEnabled
    public static Map<String, Object> getInitData(Id recordId) {

        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl =' + baseUrl);
        
		Id networkId = Network.getNetworkId();
        System.debug('networkId =' + networkId);

        Map<String, Object> mapInitData = new Map<String, Object>{
            'prefix' => baseUrl,
            'prefix2' => networkId
        };
        return mapInitData;
    }

    
    @AuraEnabled
    public static void doCreatePDF(Id recordId) {


        PageReference pdf = new pagereference('/apex/QuotePDFCreate');
        pdf.getParameters().put('id', recordId ); 

        Blob body ;
        try {
            body = pdf.getContentAsPDF();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Error');
        }

        QuoteDocument objQuoteDocument = new QuoteDocument();
        objQuoteDocument.QuoteId = recordId;
        objQuoteDocument.Document  = body;
        insert objQuoteDocument;
        
    }

    

    /**
     * Quote Record Id
     */
    public Id recordId {
        get {
            if(recordId == null) {
                recordId = ApexPages.currentPage().getParameters().get('Id');
            }
            return recordId;
        }
        set;
    }

    /**
     * Quote Record
     */
    public Quote objQuote {
        get {
            if(objQuote == null) {
                objQuote = [SELECT  Id
                                    FROM    Quote
                                    WHERE   Id = :recordId];
            }
            return objQuote;
        }
        set;
    }
    

    /**
     * QuoteLineItem List
    */
    public List<List<QuoteLineItem>> listQuoteLineItem {
        get {
            if(listQuoteLineItem == null) {
                system.debug('check0');
                listQuoteLineItem = new List<List<QuoteLineItem>>();
                List<QuoteLineItem> listTempQuoteLineItem = new List<QuoteLineItem>();
                system.debug('check1');
                listTempQuoteLineItem = [SELECT  Id, QuoteId, fm_PriceBookEntryName__c, Product2.Name, Product2Id, PricebookEntryId, ListPrice, UnitPrice
                                    FROM    QuoteLineItem
                                    WHERE   QuoteId = :recordId
                                    LIMIT 90];
                system.debug('listTempQuoteLineItem ::::::' + listTempQuoteLineItem );
                system.debug('recordId ::::::' + recordId );
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                listTempQuoteLineItem.addall(listTempQuoteLineItem); 
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                listTempQuoteLineItem.addall(listTempQuoteLineItem); 
                integer count = 0;
                integer listcount = 0;
                integer totallistsize = listTempQuoteLineItem.size();
                List<QuoteLineItem> listSubQuoteLineItem = new List<QuoteLineItem>();
                for( QuoteLineItem objTempQuoteLineItem : listTempQuoteLineItem){
                    listSubQuoteLineItem.add(objTempQuoteLineItem);
                    count++;
                    if( count == 1000){
                        listcount++;
                        count= 0;
                        listQuoteLineItem.add(listSubQuoteLineItem);
                        listSubQuoteLineItem = new List<QuoteLineItem>();
                    }
                        else if( (count+listcount*1000) == totallistsize-1){
                            system.debug('listSubQuoteLineItem.size() :: ' + listSubQuoteLineItem.size());
                            system.debug('count :: ' + count);
                        listQuoteLineItem.add(listSubQuoteLineItem);
                    }
                }
                system.debug('listTempQuoteLineItem ::::::' + listTempQuoteLineItem.size() );
            }
            return listQuoteLineItem;
        }
        set;
    }
    


    /**
     * 문서 파일명
     */
    // public String fileName {
    //     get {
    //         if(fileName == null) {
    //             fileName = '도시락 일지_' + objLunchBoxSupportList.Account__r.Name + '_' + objLunchBoxSupportList.Year__c + '년_' + objLunchBoxSupportList.Month__c + '월';

    //             if(!attendanceCheck) {
    //                 fileName += '_출석양식';
    //             }
    //         }
    //         return EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+', '\\ ').replaceAll('%28', '(').replaceAll('%29', ')');
    //     }
    //     set;
    // }

    /**
     * 출석상세 맵
     */
    // private Map<Id, Map<Integer, ActivityMgmt__c>> mapActivityMgmts {
    //     get {
    //         if(mapActivityMgmts == null) {
    //             mapActivityMgmts = new Map<Id, Map<Integer, ActivityMgmt__c>>();
    //             Map<Integer, ActivityMgmt__c> mapActivityMgmtTemp = new Map<Integer, ActivityMgmt__c>();

    //             if(!listActivityMgmt.isEmpty()) { 
    //                 for(ActivityMgmt__c objActivityMgmt : listActivityMgmt) {
    //                     mapActivityMgmtTemp = mapActivityMgmts.get(objActivityMgmt.DomesticChild__c);

    //                     if(mapActivityMgmtTemp == null) {
    //                         mapActivityMgmtTemp = new Map<Integer, ActivityMgmt__c>();
    //                         mapActivityMgmtTemp.put(objActivityMgmt.ActivityDate__c.day(), objActivityMgmt);

    //                         mapActivityMgmts.put(objActivityMgmt.DomesticChild__c, mapActivityMgmtTemp);
    //                     }
    //                     else {
    //                         mapActivityMgmtTemp.put(objActivityMgmt.ActivityDate__c.day(), objActivityMgmt);
    //                     }
    //                 }
    //             }
    //         }
    //         return mapActivityMgmts;
    //     }
    //     set;
    // }

    /**
     * 테이블 Caption Span 사이즈
     */
    // public Integer colspanSize {
    //     get {
    //         if(colspanSize == null) {
    //             colspanSize = listDaysOfMonth.size();
    //             colspanSize = colspanSize + 2;
    //         }
    //         return colspanSize;
    //     }
    //     set;
    // }
    
}