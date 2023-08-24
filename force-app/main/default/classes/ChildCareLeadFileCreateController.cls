/*
* ==================================================================================
*   File Name   : ChildCareLeadFileCreateController.cls
*   Author      : Minje.Kim
*   Date        : 2022.09.29
*   Tester      : ChildCareLeadFileCreateController_test.cls
*   Description : Quote Excel Modal Create
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.09.29    Minje.Kim       Create
* ==================================================================================
*/

public without sharing class ChildCareLeadFileCreateController {

    /**
     * 미리보기 시 선택가능한 필드 리스트
    */
    public Map<String, String> mapField {
        get {
                List<Map<String, Object>> listFieldMap = CommonUtil.getFieldSet('Lead','LeadItemFileCreate');
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
            return mapField;
        }
        set;
    }
    
    /**
     /**
     * 미리보기 시 필수 필드 리스트
    */
    public List<String> listSelectedField {
        get {
            //listSelectedField  = 'Id, Name, Company,  KindergartenCode__c, AddressDetails__c, Phone, FAx, Website,  AuthorizedCapacity__c, AuthorizationDate__c ';
            //if(listSelectedField == null) {
                String strlistSelectedField = 'Company,KindergartenCode__c,AddressDetails__c,Phone,Fax,Website,AuthorizedCapacity__c,AuthorizationDate__c';
                system.debug('strlistSelectedField :: ' + strlistSelectedField );
                listSelectedField = strlistSelectedField.split(',');
                system.debug('listSelectedField :: ' + listSelectedField );
            //}//
            return listSelectedField;
        }
        set;
    }
    
    /**
     * 엑셀 생성 시 Row Span 용 
    */
    public String ExcelColummLength {
        get {
            //if(ExcelColummLength == null) {
                ExcelColummLength = String.valueOf(listSelectedField.size()+2);
            //}
            return ExcelColummLength;
        }
        set;
    }


    /**
     * 견적서 아이템 리스트
    */
    public List<List<Lead>> listLead {
        get {
            listLead = new List<List<Lead>>();
            List<Lead> listTempLead = new List<Lead>();

            //recordId = ApexPages.currentPage().getParameters().get('Id');

            listTempLead= [SELECT  Company, KindergartenCode__c, AddressDetails__c, Phone, Fax, Website, AuthorizedCapacity__c, AuthorizationDate__c
                                        FROM     Lead
                                        LIMIT    10
                                    ];

            system.debug('listTempLead ::::::' + listTempLead );
            
            integer count = 0;
            integer listcount = 0;
            integer totallistsize = listTempLead.size();

            listLead.add(listTempLead);
            /*if (totallistsize == 10000){

                List<QuoteLineItem> listTempLead2 = new List<QuoteLineItem>();
                listTempLead2 = [SELECT   Id, QuoteId, fm_PriceBookEntryName__c, fm_QuantityUnitOfMeasure__c, ProfitMargin__c,
                                                    CountryOfOriginName__c, TaxTypeName__c, fm_ProductCode__c, Product2Id, UnitPriceWithVAT__c, VAT__c,
                                                    PricebookEntryId, ListPrice, UnitPrice, ToLabel(LogisticsCenter__c), ToLabel(Month__c), BasePurchasePrice__c
                                            FROM     QuoteLineItem
                                            WHERE    QuoteId = :recordId
                                            AND      SortOrder > 10000
                                            ORDER BY SortOrder ASC
                                            LIMIT    10000
                                            ];
                                            
                if ( !listTempLead2.isEmpty()){
                    listLead.add(listTempLead2);
                }

            }*/
            system.debug('listLead.size ::::::' + listLead.size() );
            system.debug('[listLead] :: ' + listLead);
            return listLead;
        }
        set;
    }



}