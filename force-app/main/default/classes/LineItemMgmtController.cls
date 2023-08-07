/*
* ==================================================================================
*   File Name   : LineItemMgmtController.cls
*   Author      : Minje.Kim
*   Date        : 2022.07.20
*   Tester      : LineItemMgmtController_test.cls
*   Description : QuotoLineItem New Button Override Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.07.20    Minje.Kim    Create
* ==================================================================================
*/

public without sharing class LineItemMgmtController {
    public class Input {
        public String system_type_cd;
        public String opcode;
        public String lgs_ctr_id;
        public String CUST_ID;
        public String REF_DATE;
        public List<String> GD_NO;
    }
    
    public class Output {
        public OutputSubOne ds_list;
        public OutputSubTwo totalCount;
        public String err_msg_ctt;
        public String err_cd;
    }

    public class OutputSubOne {
        public List<String> data;
    }

    public class OutputSubTwo {
        public String data;
    }
        
    /**
     * 업로드된 데이터 유효성 체크 (전체 업로드)
     *  
     * @param  recordId : 상위 레코드 ID (견적서ID)          
     * @return Map<String, Object>
     *         - listLineItem : 조회된 가격 목록 항목 리스트 
     *         - objParent : 상위 레코드 정보 (견적서 레코드 정보)
     *         - listMonth : 월 선택 목록 리스트
     *         - listCenter : 물류센터 선택 목록 리스트
     *         - listCategoryL : 상품 분류(대) 선택 목록 리스트
     *         - mapCategoryM : 상품 분류(중) 선택 목록 리스트
    **/
    @AuraEnabled
    public static Map<String, Object> getLineItem(id recordId, String sObjectName) {
        System.debug('# LineItemMgmtController # getLineItem ');
        List<QuoteLineItem> listQuoteLineItem = new List<QuoteLineItem>();
        Quote objQuote = new Quote();

        List<OpportunityLineItem> listOpptyLineItem = new List<OpportunityLineItem>();
        Opportunity objOppty = new Opportunity();
        
        if ( sObjectName == 'Quote'){

            listQuoteLineItem = [SELECT    QuoteId, Month__c, LogisticsCenter__c, fm_ProductCode__c, OldBasePurchasePrice__c, BasePurchasePrice__c, Quantity,
                                           fm_QuantityUnitOfMeasure__c, CountryOfOriginName__c, StorageConditionName__c, Product2.bas_unit_cd__c, 
                                           Product2.strg_cond_cd__c, TaxTypeName__c, 
                                           ProfitMargin__c, SortOrder, fm_PriceBookEntryName__c, Product2Id,  
                                           PricebookEntryId, ListPrice, UnitPrice, UnitPriceWithVAT__c, VAT__c,
                                           ProductCategoryCode__c, ProductCategoryLName__c, ProductCategoryMName__c
                                 FROM      QuoteLineItem
                                 WHERE     QuoteId = :recordId
                                 ORDER BY  SortOrder
                                ];

            objQuote = [SELECT  Id, Pricebook2Id, Account.CustomerID__c
                        FROM    Quote
                        WHERE   Id = :recordId
                        ];

        }
        else if ( sObjectName == 'Opportunity' ){

            listOpptyLineItem = [SELECT    OpportunityId, Month__c, LogisticsCenter__c, fm_ProductCode__c, BasePurchasePrice__c, Quantity, 
                                           fm_QuantityUnitOfMeasure__c, CountryOfOriginName__c, Product2.bas_unit_cd__c, Product2.migr_orinat_cd__c, Product2.strg_cond_cd__c,
                                           fm_IsTaxFreeYN__c,
                                           ProfitMargin__c, SortOrder, fm_PriceBookEntryName__c, Product2Id,  
                                           PricebookEntryId, ListPrice, UnitPrice, UnitPriceWithVAT__c, VAT__c
                                 FROM      OpportunityLineItem
                                 WHERE     OpportunityId = :recordId
                                 ORDER BY  SortOrder
                                ];
                                
            objOppty = [SELECT  Id, Pricebook2Id, Account.CustomerID__c
                        FROM    Opportunity
                        WHERE   Id = :recordId
                       ]; 
        }
   

        // 상품군 정보 Query
        List<ProductCategory__c > listCategory = new List<ProductCategory__c >();
        List<Map<String,String>> listCategoryL = new List<Map<String, String>>();
        Map<String,List<Map<String,String>>> mapCategoryM = new Map<String,List<Map<String,String>>>();
        
        listCategory  = [ SELECT   Id, Name, gd_cls_lvl_dpt__c, upp_gd_cls_id__c, IsActive__c, gd_cls_id__c
                           FROM     ProductCategory__c 
                           WHERE    gd_cls_lvl_dpt__c  IN ('1','2')
                           AND      IsActive__c = true
                           ORDER BY gd_cls_lvl_dpt__c, upp_gd_cls_id__c ASC
                        ];       

        listCategoryL.add(new Map<String, String>{
                'label' => '전체',
                'value' => 'none'
        });

        for( productCategory__c objCategory : listCategory) {
            if ( objCategory.gd_cls_lvl_dpt__c == '1'){
                listCategoryL.add(new Map<String, String>{
                        'label' => objCategory.Name,
                        'value' => objCategory.gd_cls_id__c
                });
            }
            else {
                Boolean isExist = mapCategoryM.get(objCategory.upp_gd_cls_id__c) != null ? true : false;
                if (isExist){
                    List<Map<String,String>> listCategoryM = mapCategoryM.get(objCategory.upp_gd_cls_id__c);
                    listCategoryM.add(new Map<String, String>{
                        'label' => objCategory.Name,
                        'value' => objCategory.gd_cls_id__c
                    });
                    mapCategoryM.put(objCategory.upp_gd_cls_id__c, listCategoryM);
                }
                else {          
                    List<Map<String,String>> listCategoryM = new List<Map<String,String>>();
                    listCategoryM.add(new Map<String, String>{
                        'label' => '전체',
                        'value' => 'none'
                    });
                    listCategoryM.add(new Map<String, String>{
                        'label' => objCategory.Name,
                        'value' => objCategory.gd_cls_id__c
                    });
                    mapCategoryM.put(objCategory.upp_gd_cls_id__c, listCategoryM);
                }
            }
        }
        
        User objUser = [
            SELECT  Id, Name, EmployeeNumber, HeadOffice__c, SU__c, Team__c
            FROM    User
            WHERE   Id =: UserInfo.getUserId()
        ];
                                
            
        Map<String, Object> mapInitData = new Map<String, Object>{            
            'listLineItem' => (sObjectName == 'Quote' ? (Object) listQuoteLineItem : (Object) listOpptyLineItem),
            'objParent' => (sObjectName == 'Quote' ? (Object) objQuote : (Object) objOppty),
            'listMonth' => CommonUtil.getPickListValues(sObjectName+'LineItem', 'Month__c', false),
            'listCenter' => CommonUtil.getPickListValues('Product2', 'lgs_ctr__c', false),
            'listCategoryL' => listCategoryL,
            'mapCategoryM' => mapCategoryM,
            'objUser' => objUser
        };

        return mapInitData;
    }    

    /**
     * 상품 리스트 조회
     *  
     * @param  Map<String, Object> mapParam 
     *         - Pricebook2Id : 가격 목록 레코드 ID 
     *         - selectedMonth : 선택된 월
     *         - selectedCenter : 선택된 물류센터
     *         - selectedCategoryL : 선택된 상품분류(대)
     *         - sortStatus  : 조회 정렬 기준
     * @return Map<String, Object> mapInitData
     *         - listAllEntry : 조회된 상품 리스트
    **/
    @AuraEnabled
    public static Map<String, Object> doSearch(Map<String, Object> mapParam) {
        System.debug('# LineItemMgmtController # doSearch ');
        datetime qryStart = datetime.now();
        Id Pricebook2Id  = (Id) String.valueOf(mapParam.get('Pricebook2Id'));
        String selectedMonth  = String.valueOf(mapParam.get('selectedMonth'));
        String selectedCenter  = String.valueOf(mapParam.get('selectedCenter'));
        String selectedCategoryL  = String.valueOf(mapParam.get('selectedCategoryL'));
        String sortStatus  = String.valueOf(mapParam.get('sortStatus'));
        
        datetime qryEnd = datetime.now(); 
        system.debug(logginglevel.WARN, (qryEnd.getTime() - qryStart.getTime()) /1000);

        // PriceBookEntryList 조회
        String query = '';
        query += 'SELECT    Name, ProductCode ';
        query += '  FROM    PriceBookEntry ';
        query += ' WHERE    lgs_ctr__c = \'' + selectedCenter + '\' ' ;
        query += '   AND    Product2.isActive = true ' ; 

        if( selectedCategoryL != 'none')
        query += '   AND    Product2.ProductCategory__r.fm_LAR_CLS_ID__c = \'' + selectedCategoryL + '\' ' ;
        query += '   AND    ' + selectedMonth + '__c != null ' ;
        query += '   AND    ' + selectedMonth + '__c != 0 ' ;
        
        if ( sortStatus != 'none'){
            String sortDirection = sortStatus.substring(0,2) == 'DN' ? 'DESC' : 'ASC';
            String sortTargetType = sortStatus.substring(2);
            String sortTargetField = '';
            
            if( sortTargetType == 'Code')
                sortTargetField = 'ProductCode';
            else if( sortTargetType == 'Name')
                sortTargetField = 'Name';
            else if( sortTargetType == 'Price')
                sortTargetField = selectedMonth + '__c ';
            query += ' ORDER BY ' + sortTargetField + ' ' + sortDirection;
        }
        else {
            query += ' ORDER BY ' + selectedMonth + '__c ' + 'ASC ';
        }
        query += ' LIMIT    50000 ' ; 

        System.debug('# doSearch 최종검색쿼리 -> ' + query);

        List<PriceBookEntry> listPriceBookEntry = new List<PriceBookEntry>();
        List<PriceBookEntry> listCurrentEntry = new List<PriceBookEntry>();

        listPriceBookEntry = Database.query(query);

        Map<String, Object> mapInitData = new Map<String, Object>{           
            'listAllEntry' => listPriceBookEntry
        };

        return mapInitData;
    }    
    
    /**
     * 상품 리스트 조회 (AI 검색)
     *  
     * @param  Map<String, Object> mapParam 
     *         - searchKey : 검색 키워드
     *         - selectedCenter : 선택된 물류센터
     * @return Map<String, Object> mapInitData
     *         - listAIEntryCode : 조회된 상품 리스트 (AI 인터페이스 결과)
    **/
    @AuraEnabled
    public static Map<String, Object> doSearchAI (Map<String, Object> mapParam) {
        System.debug('# LineItemMgmtController # doSearchAI ');
        String searchKey  = String.valueOf(mapParam.get('searchKey'));
        String selectedCenter  = String.valueOf(mapParam.get('selectedCenter'));

        Map<String,Object> objInput = new Map<String,Object>();
        List<String> strlist = new List<String>();
        strlist.add(searchKey);
        objInput.put('total_count',1); 
        objInput.put('option','cate'); 
        objInput.put('input_data', strlist); 
        
        List<String> listAIEntryCode = new List<String>();
    
        IFUtil ifutilWrapper = new IFUtil('IF_AI_SFDC_PRODUCT_INFO');
        
        // I/F 진행
        String strJsonRequestBody = JSON.serialize(objInput);
        System.debug(' check objInput ::: ' + JSON.serialize(objInput));
        HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);
        system.debug( 'check getBody ::: ' + response.getBody() );
        system.debug( 'check getStatusCode ::: ' + response.getStatusCode() );
    
        // I/F 성공 시 TOP 20 데이터 반환
        if(response.getStatusCode() == 200) 
        {   
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
            Map<String, Object> orderTarget = ( Map<String, Object> ) (( Map<String, Object> ) resultMap.get('orders')).get('0');
          
            String TOP1_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP1_Y'));
            String TOP2_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP2_Y'));
            String TOP3_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP3_Y'));
            String TOP4_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP4_Y'));
            String TOP5_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP5_Y'));
            String TOP6_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP6_Y'));
            String TOP7_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP7_Y'));
            String TOP8_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP8_Y'));
            String TOP9_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP9_Y'));
            String TOP10_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP10_Y'));
            String TOP11_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP11_Y'));
            String TOP12_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP12_Y'));
            String TOP13_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP13_Y'));
            String TOP14_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP14_Y'));
            String TOP15_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP15_Y'));
            String TOP16_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP16_Y'));
            String TOP17_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP17_Y'));
            String TOP18_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP18_Y'));
            String TOP19_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP19_Y'));
            String TOP20_Y = selectedCenter + '_' + String.valueOf(orderTarget.get('TOP20_Y'));
    
            if ( TOP1_Y != '' ) listAIEntryCode.add(TOP1_Y);
            if ( TOP2_Y != '' ) listAIEntryCode.add(TOP2_Y);
            if ( TOP3_Y != '' ) listAIEntryCode.add(TOP3_Y);
            if ( TOP4_Y != '' ) listAIEntryCode.add(TOP4_Y);
            if ( TOP5_Y != '' ) listAIEntryCode.add(TOP5_Y);
            if ( TOP6_Y != '' ) listAIEntryCode.add(TOP6_Y);
            if ( TOP7_Y != '' ) listAIEntryCode.add(TOP7_Y);
            if ( TOP8_Y != '' ) listAIEntryCode.add(TOP8_Y);
            if ( TOP9_Y != '' ) listAIEntryCode.add(TOP9_Y);
            if ( TOP10_Y != '' ) listAIEntryCode.add(TOP10_Y);
            if ( TOP11_Y != '' ) listAIEntryCode.add(TOP11_Y);
            if ( TOP12_Y != '' ) listAIEntryCode.add(TOP12_Y);
            if ( TOP13_Y != '' ) listAIEntryCode.add(TOP13_Y);
            if ( TOP14_Y != '' ) listAIEntryCode.add(TOP14_Y);
            if ( TOP15_Y != '' ) listAIEntryCode.add(TOP15_Y);
            if ( TOP16_Y != '' ) listAIEntryCode.add(TOP16_Y);
            if ( TOP17_Y != '' ) listAIEntryCode.add(TOP17_Y);
            if ( TOP18_Y != '' ) listAIEntryCode.add(TOP18_Y);
            if ( TOP19_Y != '' ) listAIEntryCode.add(TOP19_Y);
            if ( TOP20_Y != '' ) listAIEntryCode.add(TOP20_Y);
        }
            system.debug( ':: listAIEntryCode :: ' + listAIEntryCode );

        Map<String, Object> mapInitData = new Map<String, Object>{           
            'listAIEntryCode' => listAIEntryCode
        };

        return mapInitData;
    }    
    
    /**
     * 상품 학습 데이터 전송 (AI 검색)
     *  
     * @param  Map<String, Object> mapParam 
     *         - search_term : 검색 키워드
     *         - emp_code : 현재 사용자 사원번호
     *         - product_code : 선택된 상품코드
     *         - product_name : 선택된 상품명
     *         - cateL_name : 선택된 상품의 대분류명
     *         - cateM_name : 선택된 상품의 중분류명
    **/
    @AuraEnabled
    public static void doSendLearningData (Map<String, Object> mapParam) {
        System.debug('# LineItemMgmtController # doSendLearningData ');
        String search_term  = String.valueOf(mapParam.get('search_term'));
        String emp_code  = String.valueOf(mapParam.get('emp_code'));
        String product_code  = String.valueOf(mapParam.get('product_code'));
        String product_name  = String.valueOf(mapParam.get('product_name'));
        String cateL_name  = String.valueOf(mapParam.get('cateL_name'));
        String cateM_name  = String.valueOf(mapParam.get('cateM_name'));

        Map<String,Object> objInput = new Map<String,Object>();
        objInput.put('search_term', search_term); 
        objInput.put('emp_code', emp_code); 
        objInput.put('product_code', product_code); 
        objInput.put('product_name', product_name); 
        objInput.put('cateL_name', cateL_name); 
        objInput.put('cateM_name', cateM_name); 
        
        List<String> listAIEntryCode = new List<String>();
    
        IFUtil ifutilWrapper = new IFUtil('IF_AI_SFDC_LEARNING_SEND');
        
        // I/F 진행
        String strJsonRequestBody = JSON.serialize(objInput);
        System.debug(' check objInput ::: ' + JSON.serialize(objInput));
        HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);
        system.debug( 'check getBody ::: ' + response.getBody() );
        system.debug( 'check getStatusCode ::: ' + response.getStatusCode() );
    
    }    

    
    /**
     * 대상 상품 코드 리스트로 상품 데이터 리스트 조회
     * 중단제어 적용할 경우 : i-fresh 상에서 해당 고객에 비활성화 된 상품은 선택할 수 없도록 처리 (customerID = Account.CustomerID__c)
     *  
     * @param  listTargetEntryCode : 대상 상품코드 리스트
     * @param  selectedCenter : 선택된 물류센터
     * @param  selectedMonth : 선택된 월
     * @param  sortStatus : 조회 정렬 기준
     * @param  selectedControl : 중단 제어 활성화 여부
     * @param  customerID : 중단 제어 활성화 기준 고객 ID (Account.CustomerID__c)
     * @return Map<String, Object> mapInitData
     *         - ControllWrapper objControllWrapper
     *           - listControlEntry : 중단 제어 결과 사용가능 상품코드 리스트 
     *           - ERR_CD : I/F 결과 코드
     *           - ERR_MSG_CTT : I/F 결과 메세지 
     *         - listCurrentEntry : 현재 페이지에서 조회되는 상품 목록 정보
    **/    
    @AuraEnabled
    public static Map<String, Object> getCurrentEntry(List<String> listTargetEntryCode, String selectedCenter, String selectedMonth, String sortStatus, String selectedControl, String customerID) {
        System.debug('# LineItemMgmtController # getCurrentEntry ');
        System.debug('listTargetEntryCode -> ' + listTargetEntryCode);
        System.debug('selectedCenter -> ' + selectedCenter);
        System.debug('selectedMonth -> ' + selectedMonth);
        System.debug('sortStatus -> ' + sortStatus);
        System.debug('selectedControl -> ' + selectedControl);
        System.debug('customerID -> ' + customerID);

        String ERR_CD = '0000';
        String ERR_MSG_CTT = '';
        // PriceBookEntryList 조회
        String query = '';
        query += 'SELECT    Id, Name, ProductCode, Product2.gd_no__c, UnitPrice, toLabel(Product2.bas_unit_cd__c), toLabel(Product2.migr_orinat_cd__c), toLabel(Product2.strg_cond_cd__c), Product2.taxt_cl_cd__c, Product2.lgs_ctr_id__c, ';
        query += '          Product2.fm_TaxType__c, Product2.fm_LAR_CLS_NM__c,Product2.fm_MID_CLS_NM__c, Product2.fm_XSM_CLS_CD__c';
        query += '          , ' + selectedMonth + '__c, Old' + selectedMonth + '__c ';
        query += '  FROM    PriceBookEntry ';
        query += ' WHERE    ProductCode IN : listTargetEntryCode';
        query += '   AND    ' + selectedMonth + '__c != null ' ;
        query += '   AND    ' + selectedMonth + '__c != 0 ' ;

        if ( sortStatus != 'none'){
            String sortDirection = sortStatus.substring(0,2) == 'DN' ? 'DESC' : 'ASC';
            String sortTargetType = sortStatus.substring(2);
            String sortTargetField = '';
            
            if( sortTargetType == 'Code')
                sortTargetField = 'ProductCode';
            else if( sortTargetType == 'Name')
                sortTargetField = 'Name';
            else if( sortTargetType == 'Price')
                sortTargetField = selectedMonth + '__c ';
            query += ' ORDER BY ' + sortTargetField + ' ' + sortDirection; 
        }
        else {
            query += ' ORDER BY ' + selectedMonth + '__c ' + 'ASC ';
        }

        System.debug('# getCurrentEntry 최종검색쿼리 -> ' + query);

        List<PriceBookEntry> listCurrentEntry = new List<PriceBookEntry>();
        listCurrentEntry = Database.query(query);

        System.debug('# getCurrentEntry 최종검색쿼리 SIZE -> ' + listCurrentEntry.size() );

        List<String> listCurrentEntryCode = new List<String>();
        for ( PriceBookEntry objCurrentEntry : listCurrentEntry){
            listCurrentEntryCode.add( objCurrentEntry.Product2.gd_no__c);
        }
        List<String> listControlEntry = new List<String>();

        if ( selectedControl == 'Y' && !listCurrentEntryCode.isEmpty()){
            
            Input objInput = new Input();
            objInput.system_type_cd = 'IF0004'; 
            objInput.opcode = 'CR006'; 
            objInput.lgs_ctr_id = selectedCenter; 
            objInput.CUST_ID = customerID; 
            objInput.REF_DATE = doGetTargetDate(selectedMonth); 
            objInput.GD_NO = listCurrentEntryCode; 

            System.debug(' objInput ::: ' + JSON.serialize(objInput));

            IFUtil ifutilWrapper = new IFUtil('IF_IFRESH_SFDC_PRICE_CONTROL_INFO');
            
            String strJsonRequestBody = JSON.serialize(objInput);
            HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);

            Output objOutput = new Output();
            
            system.debug( 'check Input ::: ' + strJsonRequestBody );
            if(response.getStatusCode() == 200) {
                system.debug( '성공 ::' );
                system.debug( 'check Output ::: ' + response.getBody() );
                objOutput = (Output)JSON.deserialize(response.getBody(), Output.class);
                listControlEntry = objOutput.ds_list.data;
                ERR_CD = objOutput.err_cd;
                ERR_MSG_CTT = objOutput.err_msg_ctt;
            }else {
                system.debug( '실패 ::' + response.getStatusCode()  );
                String responseBody = response.getBody();    
                system.debug( 'check Output ::: ' + response.getBody() ); 
                ERR_CD = String.valueOf(response.getStatusCode());
                ERR_MSG_CTT = '[I/F Error] ::: 영업 시스템 연결에 실패했습니다.';
            }
        }   
        ControllWrapper objControllWrapper = new ControllWrapper();
        objControllWrapper.ERR_CD = ERR_CD; 
        objControllWrapper.ERR_MSG_CTT = ERR_MSG_CTT;
        objControllWrapper.listControlEntry = listControlEntry;

        
        Map<String, Object> mapInitData = new Map<String, Object>{           
            'listCurrentEntry' => listCurrentEntry,       
            'objControllWrapper' => objControllWrapper
        };

        return mapInitData;
    }


    
    /**
     * 생성 또는 삭제 Chunk(배치) 기능 (견적서 행 아이템)
     *  
     * @param  chunkType : 생성 또는 삭제 여부
     * @param  listChunk : 생성 또는 삭제 대상
    **/    
    @AuraEnabled
    public static void doChunkQuote(String chunkType, List<QuoteLineItem> listChunk) {
        System.debug('# LineItemMgmtController # doChunkQuote ');
        try {
            if ( chunkType == 'Delete'){
                if( !listChunk.isEmpty()){
                    delete listChunk;
                }
            }
            else if (chunkType == 'Insert') {
                if( !listChunk.isEmpty()){
                    for ( QuoteLineItem objInsertTarget : listChunk){
                        objInsertTarget.SortOrder = integer.valueOf(objInsertTarget.SortOrder);
                    }
                    insert listChunk;
                }
            }
        } catch(Exception e){
            system.debug('QuoteLineItemMgmtController doChunk error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }
    
    /**
     * 생성 또는 삭제 Chunk(배치) 기능 (영업기회 행 아이템)
     *  
     * @param  chunkType : 생성 또는 삭제 여부
     * @param  listChunk : 생성 또는 삭제 대상
    **/    
    @AuraEnabled
    public static void doChunkOppty(String chunkType, List<OpportunityLineItem> listChunk) {
        System.debug('# LineItemMgmtController # doChunkOppty ');
        try {
            if ( chunkType == 'Delete'){
                if( !listChunk.isEmpty()){
                    delete listChunk;
                }
            }
            else if (chunkType == 'Insert') {
                if( !listChunk.isEmpty()){
                    for ( OpportunityLineItem objInsertTarget : listChunk){
                        objInsertTarget.SortOrder = integer.valueOf(objInsertTarget.SortOrder);
                    }
                    insert listChunk;
                }
            }
        } catch(Exception e){
            system.debug('QuoteLineItemMgmtController doChunk error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }
    
    /**
     * 선택된 월 데이터로 중단제어 기준일자 계산
     *  
     * @param  selectedMonth : 선택된 월
    **/  
    private static String doGetTargetDate(String selectedMonth) {
        System.debug('# LineItemMgmtController # doGetTargetDate ');
        selectedMonth = selectedMonth.toLowerCase();
        String strtargetDate = '';
        Datetime dateToday = Datetime.now();
        String strThisMonthMMM = dateToday.format('MMM').toLowerCase();
        String strThisMonthOfHalf = '';
        
        if (Integer.valueOf(dateToday.format('dd')) < 16) {
            strThisMonthOfHalf = 'early' + strThisMonthMMM;
        } else {
            strThisMonthOfHalf = 'late' + strThisMonthMMM;
        }

        if ( strThisMonthOfHalf == selectedMonth){
            strtargetDate = dateToday.format('yyyyMMdd');
        }
        else {
            Map<String, String> mapMonth = new Map<String, String>{           
                'jan' => '01', 'feb' => '02', 'mar' => '03', 'apr' => '04',      
                'may' => '05', 'jun' => '06', 'jul' => '07', 'aug' => '08',      
                'sep' => '09', 'oct' => '10', 'nov' => '11', 'dec' => '12'
            };

            integer prefixLength = 4;
            if(selectedMonth.startsWith('early'))
                prefixLength = 5;
            
            Integer intTargetMonth = Integer.valueOf(mapMonth.get(selectedMonth.mid(prefixLength,3).toLowerCase()));

            Integer intThisMonth = Integer.valueOf(mapMonth.get(strThisMonthMMM));
            
            String strYear = intTargetMonth > intThisMonth ? dateToday.addYears(-1).format('yyyy') : dateToday.format('yyyy');
            String strMonth = mapMonth.get(selectedMonth.mid(prefixLength,3).toLowerCase());
            String strDay = String.valueOf(date.daysInMonth(dateToday.year(), intTargetMonth));
            strtargetDate = strYear + strMonth + strDay;
        }
        return strtargetDate;
    }
    
    public class ControllWrapper {
        @AuraEnabled
        public List<String> listControlEntry {get;set;}
        @AuraEnabled
        public String ERR_CD {get;set;}
        @AuraEnabled
        public String ERR_MSG_CTT {get;set;}
    }

}