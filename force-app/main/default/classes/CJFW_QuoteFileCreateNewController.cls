/**
* Custom Object QuoteLineItem 용 견적서 파일 생성
*
*@group  
*@author 진현욱
*@since 2023-10-17  내용 작성
*/
public without sharing class CJFW_QuoteFileCreateNewController {
        
    /**
     * 견적서 Record Id
     */
    public Id recordId {
        get {
            if(recordId == null) {
                recordId = ApexPages.currentPage().getParameters().get('Id');
                system.debug('[recordId] :: ' + recordId);
            }
            return recordId;
        }
        set;
    }

    /**
     * 견적서 Record
     */
    public Quote objQuote {
        get {
            if(objQuote == null) {
                objQuote = [SELECT  Id, Name, OwnerId, EffectiveStartDate__c, ExpirationDate
                                    FROM    Quote
                                    WHERE   Id = :recordId];
                system.debug('[objQuote] :: ' + objQuote);
            }
            return objQuote;
        }
        set;
    }

    /**
     * 견적서 소유자 정보
     */
    public User objOwner {
        get {
            if(objOwner == null) {
                objOwner = [SELECT  Id, Name, MobilePhone, CurrencyIsoCode
                                    FROM    User
                                    WHERE   Id = :objQuote.OwnerId];
                system.debug('[objOwner] :: ' + objOwner);
            }
            return objOwner;
        }
        set;
    }

    /**
     * 미리보기 시 선택가능한 필드 리스트
    */
    public Map<String, String> mapField {
        get {
            if(mapField == null) {
                List<Map<String, Object>> listFieldMap = CommonUtil.getFieldSet('CJFW_QuoteLineItem__c','QuoteLineItemFileCreate');
                system.debug(' listFieldMap :: ' + listFieldMap);
                Map<String, String> mapTemp= new Map<String, String> ();
                for ( Map<String, Object> objMap : listFieldMap ) {
                    String apiName = String.valueOf(objMap.get('apiName'));
                    String label = String.valueOf(objMap.get('label'));
                    system.debug(' String.valueOf(objMap.get(apiName)) :: ' + String.valueOf(objMap.get('apiName')));
                    system.debug(' String.valueOf(objMap.get(label)) :: ' + String.valueOf(objMap.get('label')));
                    mapTemp.put(apiName , label);
                }
                mapField = mapTemp;
                System.debug(
                    JSON.serializePretty(mapField)
                );
            }
            return mapField;
        }
        set;
    }
    
    /**
     * 미리보기 시 필수 필드 리스트
    */
    public List<String> listSelectedField {
        get {
            if(listSelectedField == null) {
                String strlistSelectedField = ApexPages.currentPage().getParameters().get('listSelectedField');
                system.debug('strlistSelectedField :: ' + strlistSelectedField );
                listSelectedField = strlistSelectedField.split(',');
                system.debug('listSelectedField :: ' + listSelectedField );
            }
            return listSelectedField;
        }
        set;
    }
    
    /**
     * 엑셀 생성 시 Row Span 용 
    */
    public String ExcelColummLength {
        get {
            if(ExcelColummLength == null) {
                ExcelColummLength = String.valueOf(listSelectedField.size()+2);
            }
            return ExcelColummLength;
        }
        set;
    }


    /**
     * 견적서 아이템 리스트
    */
    public List<List<CJFW_QuoteLineItem__c>> listQuoteLineItem {
        get {
            if(listQuoteLineItem == null) {
                listQuoteLineItem = new List<List<CJFW_QuoteLineItem__c>>();
                List<CJFW_QuoteLineItem__c> listTempQuoteLineItem = new List<CJFW_QuoteLineItem__c>();

                recordId = ApexPages.currentPage().getParameters().get('Id');

                listTempQuoteLineItem = [SELECT   Id, QuoteId__c, ProductName__c, QuantityUnitOfMeasure__c, ProfitMargin__c,
                                                  CountryOfOriginName__c, TaxTypeName__c, ProductCode__c, Product2Id__c, UnitPriceWithVAT__c, VAT__c,
                                                  UnitPrice__c, ToLabel(LogisticsCenter__c), ToLabel(Month__c), BasePurchasePrice__c, OldBasePurchasePrice__c, StorageConditionName__c,
                                                  ProductWeight__c, BoxQuantity__c, UnitConversion__c, Barcode__c, 
                                                  ProductCategoryLName__c, ProductCategoryMName__c
                                                  ,BiddingProductName__c ,BiddingProductWeight__c, BiddingSpec__c, BiddingUnit__c
                                         FROM     CJFW_QuoteLineItem__c
                                         WHERE    QuoteId__c = :recordId
                                         ORDER BY SortOrder__c ASC
                                         LIMIT    10000
                                        ];

                system.debug('listTempQuoteLineItem ::::::' + listTempQuoteLineItem );
                system.debug('recordId ::::::' + recordId );
                
                integer count = 0;
                integer listcount = 0;
                integer totallistsize = listTempQuoteLineItem.size();

                if ( !listTempQuoteLineItem.isEmpty()){
                    listQuoteLineItem.add(listTempQuoteLineItem);
                    if (totallistsize == 10000){

                        List<CJFW_QuoteLineItem__c> listTempQuoteLineItem2 = new List<CJFW_QuoteLineItem__c>();
                        listTempQuoteLineItem2 = [SELECT   Id, QuoteId__c, ProductName__c, QuantityUnitOfMeasure__c, ProfitMargin__c,
                                                           CountryOfOriginName__c, TaxTypeName__c, ProductCode__c, Product2Id__c, UnitPriceWithVAT__c, VAT__c,
                                                           UnitPrice__c, ToLabel(LogisticsCenter__c), ToLabel(Month__c), BasePurchasePrice__c, OldBasePurchasePrice__c, StorageConditionName__c,
                                                           ProductWeight__c, BoxQuantity__c, UnitConversion__c, Barcode__c, 
                                                           ProductCategoryLName__c, ProductCategoryMName__c
                                                           ,BiddingProductName__c ,BiddingProductWeight__c, BiddingSpec__c, BiddingUnit__c
                                                  FROM     CJFW_QuoteLineItem__c
                                                  WHERE    QuoteId__c = :recordId
                                                  AND      SortOrder__c > 10000
                                                  ORDER BY SortOrder__c ASC
                                                  LIMIT    10000
                                                 ];
                                                 
                        if ( !listTempQuoteLineItem2.isEmpty()){
                            listQuoteLineItem.add(listTempQuoteLineItem2);
                        }

                    }
                    
                }
            }
            system.debug('listQuoteLineItem.size ::::::' + listQuoteLineItem.size() );
            system.debug('[listQuoteLineItem] :: ' + listQuoteLineItem);
            return listQuoteLineItem;
        }
        set;
    }

    /**
     * Prefix 및 필드셋 정보 조회
     *      
     * @return Map<String, Object>
     *         - prefix : 현 Org의 Base Url
     *         - listField : 파일 생성시 선택 가능한 필드 목록
     *         - listRequiredField : 파일 생성시 보여질 필수 필드 목록
    **/
    @AuraEnabled
    public static Map<String, Object> getInitData() {
        
        // Excel Download 시 보여질 필드 선택
        List<Map<String, Object>> listFieldMap = CommonUtil.getFieldSet('CJFW_QuoteLineItem__c','QuoteLineItemFileCreate');
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


    /**
     * Prefix 및 필드셋 정보 조회
     * 
     * @param  recordId : 견적서 Record Id
     * @param  saveType : 파일 타입 (PDF/Excel)
     * @param  listSelectedSave : 파일 내 조회될 필드 리스트
     * 
    **/
    @AuraEnabled
    public static void doCreateFile(Id recordId, String saveType, String listSelectedSave) {
        System.debug('listSelectedSave ========> '  + listSelectedSave); 
        
        // Standard Quote PDF 에서 Discount, GrandTotal을 제공함에 따라 Custom에서도 동일 기능 구현 
        Quote objQuote = [SELECT Id, Name, Discount, GrandTotal
                                   FROM Quote
                                   WHERE id =: recordId
                                  ];


        // File Version Check
        List<QuoteFile__c> listQuoteFile = [SELECT   Id, FileVersion__c
                                            FROM     QuoteFile__c
                                            WHERE    Quote__c = :recordId
                                            ORDER BY FileVersion__c DESC
                                            LIMIT    1
                                           ];
                                                
        String strfileVersion ;              
        Decimal decfileVersion ;
        if ( listQuoteFile.isEmpty() ){
            decfileVersion = 1;
        } else {
            decfileVersion = listQuoteFile[0].FileVersion__c+1;
        }
        strfileVersion = String.valueOf(decfileVersion);

        // Type에 따라 Blob화 분기
        Blob body ;
        try {
            if ( saveType == 'PDF'){
                PageReference pdf = new pagereference('/apex/CJFW_QuotePDFCreateNew');
                pdf.getParameters().put('Id', recordId ); 
                pdf.getParameters().put('listSelectedField', listSelectedSave );
                System.debug('pdf link ========> '  + pdf.getUrl());
                body = pdf.getContentAsPDF();
            }
            else if ( saveType == 'Excel'){
                PageReference excel = new pagereference('/apex/CJFW_QuoteExcelCreateNew');
                excel.getParameters().put('Id', recordId ); 
                excel.getParameters().put('listSelectedField', listSelectedSave );
                System.debug('excel link ========> '  + excel.getUrl());
                body = excel.getContent();
            }
        } catch (VisualforceException e) {
            body = Blob.valueOf('Error');
        }

        
        // 확장자 따라 Blob화 분기
        String fileType = 'None';
        if ( saveType == 'PDF')
            fileType = 'pdf';
        else if ( saveType == 'Excel')
            fileType = 'xls';

        String fileName = objQuote.Name+'_V'+strfileVersion+'.'+fileType;


        ContentVersion objContentVersion = new ContentVersion(
                Title = fileName,
                PathOnClient = fileName,
                VersionData = body,
                FirstPublishLocationId = recordId
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

        ContentDistribution objContentDistribution2 = [SELECT Id, ContentVersionId, ContentDocumentId, ContentDownloadUrl
                                   FROM ContentDistribution
                                   WHERE id =: objContentDistribution.Id
                                  ];
        
        ContentDocument objContentDocument = [SELECT Id, FileType
                                   FROM ContentDocument
                                   WHERE id =: objContentDistribution2.ContentDocumentId
                                  ];

        QuoteFile__c objQuoteFile = new QuoteFile__c(
            FileName__c = fileName,
            DownloadUrl__c =  objContentDistribution2.ContentDownloadUrl,
            ContentDocumentId__c =  objContentDistribution2.ContentDocumentId,
            FileType__c =  saveType,
            FileVersion__c = decfileVersion,
            Discount__c = objQuote.Discount,
            GrandTotal__c = objQuote.GrandTotal,
            Quote__c = recordId
        );

        insert objQuoteFile;
        system.debug(objQuoteFile);
    }

}