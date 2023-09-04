/*
* ==================================================================================
*   File Name   : QuoteExcelCreateController.cls
*   Author      : Minje.Kim
*   Date        : 2022.09.29
*   Tester      : QuoteExcelCreateController_test.cls
*   Description : Quote Excel Modal Create
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.09.29    Minje.Kim       Create
* ==================================================================================
*/

public with sharing class QuoteExcelCreateController {
    
    @AuraEnabled
    public static Map<String, Object> getInitData(Id recordId) {
        
        // Excel Download 시 보여질 필드 선택
        List<Map<String, Object>> listFieldMap = CommonUtil.getFieldSet('QuoteLineItem','QuoteLineItemExcelDownload');
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

        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl =' + baseUrl);
        

        Map<String, Object> mapInitData = new Map<String, Object>{
            'prefix' => baseUrl,
            'listField' => listField,   
            'listRequiredField' => listRequiredField
        };
        return mapInitData;
    }

    
    @AuraEnabled
    public static void doCreatePDF(Id recordId) {

        system.debug('doCreatePDF --- > ');

        PageReference pdf = new pagereference('/apex/QuoteExcelCreate');
        pdf.getParameters().put('id', recordId ); 

        Blob body ;
        try {
            body = pdf.getContent();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Error');
        }

        ContentVersion objContentVersion = new ContentVersion(
                Title = '22-10-07 견적',
                PathOnClient = 'Test.xls',
                VersionData = body,
                FirstPublishLocationId = recordId
        );
        insert objContentVersion;

        ContentDistribution objContentDistribution = new ContentDistribution(
            ContentVersionId = objContentVersion.Id,
            Name = '22-10-07 견적',
            PreferencesAllowViewInBrowser = true,
            PreferencesLinkLatestVersion = true,
            PreferencesNotifyOnVisit = false,
            PreferencesPasswordRequired = false,
            PreferencesAllowOriginalDownload = true
        );

        insert objContentDistribution;
        system.debug('objContentDistribution1 --- > ' + objContentDistribution);

        ContentDistribution objContentDistribution2 = [SELECT Id, ContentVersionId, ContentDocumentId, ContentDownloadUrl
                                   FROM ContentDistribution
                                   WHERE id =: objContentDistribution.Id
                                  ];

        system.debug('objContentDistribution2 --- > ' + objContentDistribution2);
        
        ContentDocument objContentDocument = [SELECT Id, FileType
                                   FROM ContentDocument
                                   WHERE id =: objContentDistribution2.ContentDocumentId
                                  ];


        Quote objQuote = [SELECT Id, Discount, GrandTotal
                                   FROM Quote
                                   WHERE id =: recordId
                                  ];

        QuoteFile__c objQuoteFile = new QuoteFile__c(
            FileName__c = '22-10-07 견적',
            DownloadUrl__c =  objContentDistribution2.ContentDownloadUrl,
            ContentDocumentId__c =  objContentDistribution2.ContentDocumentId,
            FileType__c =  objContentDocument.FileType,
            Discount__c = objQuote.Discount,
            GrandTotal__c = objQuote.GrandTotal,
            Quote__c = recordId
        );
        // ContentVersionId = objContentDistribution.ContentVersionId,

        insert objQuoteFile;
        // QuoteDocument objQuoteDocument = new QuoteDocument();
        // objQuoteDocument.QuoteId = recordId;
        // objQuoteDocument.Document  = body;
        // insert objQuoteDocument;
        
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

                listTempQuoteLineItem = [SELECT  Id, QuoteId, fm_PriceBookEntryName__c, fm_QuantityUnitOfMeasure__c, 
                                                 fm_CountryOfOrigin__c, fm_IsTaxFreeYN__c, fm_ProductCode__c, Product2Id, 
                                                 PricebookEntryId, ListPrice, UnitPrice
                                         FROM    QuoteLineItem
                                         WHERE   QuoteId = :recordId
                                         LIMIT   90];
                system.debug('listTempQuoteLineItem ::::::' + listTempQuoteLineItem );
                system.debug('recordId ::::::' + recordId );
                listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);
                // listTempQuoteLineItem.addall(listTempQuoteLineItem);     
                
                List<QuoteLineItem> Testthis = new List<QuoteLineItem>();
                Testthis.addall(listTempQuoteLineItem);
                Testthis.addall(Testthis);
                Testthis.addall(Testthis);
                Testthis.addall(Testthis);
                Testthis.addall(Testthis);
                
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
                system.debug('listTempQuoteLineItem ::::::' + JSON.serialize(listTempQuoteLineItem).length() );
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