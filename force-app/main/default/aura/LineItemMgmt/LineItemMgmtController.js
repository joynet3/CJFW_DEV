({
    
    /**
     * @description 초기화
     */
     fnInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.setLineItemCode", new Set());
        component.set("v.listCurrentEntry", []);
        component.set("v.listLineItem", []);
        component.set("v.pageRecords", []);
        helper.getLineItem(component);
    },
 
    /**
     * @description Page Session 변경 감지시 초기화
     */
    fnhandlePageChange : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.setLineItemCode", new Set());
        component.set("v.listCurrentEntry", []);
        component.set("v.listLineItem", []);
        component.set("v.pageRecords", []);
        component.find("Search").set("v.value",'');
        helper.getLineItem(component);
    },

    /**
     * @description Excel 수정 기능, 수정 완료시 선택된 행이 자동 검색 
     */
    fnToggleExcelEdit : function(component, event, helper) {  
        let isExcelEdit = component.get("v.isExcelEdit");
        component.set("v.isExcelEdit",!isExcelEdit);
        if (isExcelEdit ){
            let currentIdx = component.get("v.currentIdx");
            let listLineItem = component.get("v.listLineItem");
            let searchKey = listLineItem[currentIdx].ExcelData;

            let BracketIndex = searchKey.indexOf('(');
            if( BracketIndex > -1 )
            searchKey = searchKey.substring(0, BracketIndex);

            // 검색 분기 
            let regex = new RegExp("\\\\|\'","gi");
            
            if ( searchKey == null) searchKey = '';
            if ( searchKey != '' ) searchKey = searchKey.replace(regex, "");

            component.set("v.strSearchInput", searchKey);
            component.set("v.strSearchInputForLearning", searchKey);

            if ( component.get("v.isChangeCondition") )
                helper.doGetAllEntry(component, searchKey);
            else{
                component.set("v.isChangeCondition", false);        
                if ( component.get("v.isAISearch") ){ 
                    if( searchKey == '') return false;
                    component.set("v.listCurrentEntry", []);
                    helper.doSearchAI(component, searchKey, false);
                }
                else {
                    helper.doSearch(component, searchKey, false);
                }
            }

        }
    },

    /**
     * @description 견적 상품 행 선택 
     */
     fnCheckIndex : function(component, event, helper) {  
        let idx = event.currentTarget.id;
        let intIdx = Number(idx.substring(4));
        component.set("v.currentIdx", intIdx );        
     },

    /**
     * @description 추가 <-> 변경 모드 수정
     */
     fnToggleAddMode : function(component, event, helper) {  
        let isReplace = component.get("v.isReplace");
        component.set("v.isReplace",!isReplace);
    },
    
    /**
     * @description 검색화면 Enter 입력시 검색
     */
    fnSearch : function(component, event, helper) {  
        if(event.keyCode == 13){
            // 키워드 가져오기
            let searchKey = component.find("Search").get("v.value");
        
            console.log('searchKey ::: ' + searchKey);

            // 검색 분기 (초기검색, 재검색, AI검색)
            let regex = new RegExp("\\\\|\'","gi");
            
            if ( searchKey == null) searchKey = '';
            if ( searchKey != '' ) searchKey = searchKey.replace(regex, "");

            component.set("v.strSearchInput", searchKey);
            component.set("v.strSearchInputForLearning", searchKey);

            if ( component.get("v.isChangeCondition") )
                helper.doGetAllEntry(component, searchKey);
            else{
                component.set("v.isChangeCondition", false);        
                if ( component.get("v.isAISearch") ){ 
                    if( searchKey == '') return false;
                    component.set("v.listCurrentEntry", []);
                    helper.doSearchAI(component, searchKey, false);
                }
                else {
                    helper.doSearch(component, searchKey, false);
                }
            }
        }
    },
    
    /**
     * @description Excel 견본 글자 클릭시 검색
     */
     fnExcelSearch : function(component, event, helper) {  
        if(event.keyCode == 13){
            // 키워드 가져오기
            let isExcelEdit = component.get("v.isExcelEdit");
            component.set("v.isExcelEdit",!isExcelEdit);
            let currentIdx = component.get("v.currentIdx");
            let listLineItem = component.get("v.listLineItem");
            let searchKey = listLineItem[currentIdx].ExcelData;
            console.log( 'searchKey :: ' + searchKey);
            
            let BracketIndex = searchKey.indexOf('(');
            if( BracketIndex > -1 )
            searchKey = searchKey.substring(0, BracketIndex);
            
            // 검색 분기 (초기검색, 재검색, AI검색) 
            let regex = new RegExp("\\\\|\'","gi");
            
            if ( searchKey == null) searchKey = '';
            if ( searchKey != '' ) searchKey = searchKey.replace(regex, "");

            component.set("v.strSearchInput", searchKey);
            component.set("v.strSearchInputForLearning", searchKey);

            if ( component.get("v.isChangeCondition") )
                helper.doGetAllEntry(component, searchKey);
            else{
                component.set("v.isChangeCondition", false);        
                if ( component.get("v.isAISearch") ){ 
                    if( searchKey == '') return false;
                    component.set("v.listCurrentEntry", []);
                    helper.doSearchAI(component, searchKey, false);
                }
                else {
                    helper.doSearch(component, searchKey, false);
                }
            }
        }
    },

    /**
     * @description 상품 검색 리스트 정렬 
     */
    fnEntrySort : function(component, event, helper) {  
              
        // AI 검색인 경우 제외
        if ( component.get("v.isAISearch") ) return false; 

        let targetName = event.currentTarget.id;
        let oldSortStatus = component.get("v.sortStatus");
        let newSortStatus = '';

        if( oldSortStatus == 'none' && targetName == 'Price'){
            newSortStatus = 'DN'+targetName;
        }
        else if(oldSortStatus == 'none'){
            newSortStatus = 'UP'+targetName;
        }
        else if (oldSortStatus.substring(2) == targetName){
            if(oldSortStatus.substring(0,2) == 'UP' )
                newSortStatus = 'DN'+targetName;
            else 
                newSortStatus = 'UP'+targetName;
        }
        else {
            newSortStatus = 'UP'+targetName;
        }
        component.set("v.sortStatus", newSortStatus);
        let strSearchInput = component.get("v.strSearchInput");
        if(strSearchInput == null) strSearchInput = '';
            
        helper.doGetAllEntry(component, strSearchInput);
    },

    /**
     * @description 데이터 행 변경
     * @param {*} component 
     */
    fnReplaceData : function(component, event, helper) {
        console.log('Point :: fnReplaceData Start !! ');
        component.set("v.showSpinner", true);
        
        // 0. 데이터 가져오기
        let sObjectName = component.get("v.sObjectName");
        let index = event.currentTarget.id;
        let listCurrentEntry = component.get("v.listCurrentEntry");
        let listLineItem = component.get("v.listLineItem");
        let currentIdx = Number(component.get("v.currentIdx"));
        let listMonth = component.get("v.listMonth");
        let listCenter = component.get("v.listCenter");
        
        // 1. 비활성화 및 활성화 (중복방지)
        listCurrentEntry[index].isInActive = true;
        let targetProductNo = listLineItem[currentIdx].fm_ProductCode__c;
        for (let i in listCurrentEntry ){
            if (listCurrentEntry[i].Product2.gd_no__c ==  targetProductNo)
            listCurrentEntry[i].isInActive = false;
        }

        component.set("v.listCurrentEntry", listCurrentEntry);

        let setLineItemCode = new Set(component.get("v.setLineItemCode"));
        setLineItemCode.add(listCurrentEntry[index].Product2.gd_no__c);
        setLineItemCode.delete(listLineItem[currentIdx].fm_ProductCode__c);
        component.set("v.setLineItemCode", setLineItemCode);


        // 2. 데이터 체크
        let isTaxTarget =  listCurrentEntry[index].Product2.fm_TaxType__c == '과세' ? 1 : 0;
        let UnitPrice = listCurrentEntry[index].UnitPrice == 1 ? 1 : Math.ceil(listCurrentEntry[index].UnitPrice/10)* 10;
        let ProfitMargin = 100;

        if ( UnitPrice != 1){
            ProfitMargin = (UnitPrice - listCurrentEntry[index].UnitPrice)/UnitPrice * 100;
            ProfitMargin = Math.round(ProfitMargin * 100) / 100;

            if ( ProfitMargin > 99 ) {
                ProfitMargin = 99;
                UnitPrice =  Math.ceil(listCurrentEntry[index].UnitPrice / (1 - 99/100)/10)* 10;
            }
        }

        let VAT = UnitPrice == 1 ? 0 : isTaxTarget * UnitPrice * 0.1;

        let Month = listMonth[listMonth.findIndex(objMap => objMap.value == component.get("v.selectedMonth"))].label;
        
        let BracketIndex = Month.indexOf('(');
        if( BracketIndex > -1 )
        Month = Month.substring(0, BracketIndex);

        // 3. 데이터 행 변경
        listLineItem[currentIdx].fm_PriceBookEntryName__c = listCurrentEntry[index].Name,		
        listLineItem[currentIdx].fm_ProductCode__c = listCurrentEntry[index].Product2.gd_no__c,
        listLineItem[currentIdx].BasePurchasePrice__c = listCurrentEntry[index].UnitPrice, 
        listLineItem[currentIdx].OldBasePurchasePrice__c = listCurrentEntry[index].OldUnitPrice, 
        listLineItem[currentIdx].TaxTypeName__c = listCurrentEntry[index].Product2.fm_TaxType__c,
        listLineItem[currentIdx].UnitPrice = UnitPrice,
        listLineItem[currentIdx].VAT__c = VAT,	 
        listLineItem[currentIdx].UnitPriceWithVAT__c = UnitPrice + VAT,	
        listLineItem[currentIdx].Month__c = component.get("v.selectedMonth"),
        listLineItem[currentIdx].MonthToLabel = Month,	
        listLineItem[currentIdx].ProductCategoryLName__c = listCurrentEntry[index].Product2.fm_LAR_CLS_NM__c,	 
        listLineItem[currentIdx].ProductCategoryMName__c = listCurrentEntry[index].Product2.fm_MID_CLS_NM__c,	 
        listLineItem[currentIdx].ProductCategoryCode__c = listCurrentEntry[index].Product2.fm_XSM_CLS_CD__c,	 
        listLineItem[currentIdx].LogisticsCenter__c = component.get("v.selectedCenter"),	 
        listLineItem[currentIdx].CenterToLabel = listCenter[listCenter.findIndex(objMap => objMap.value == component.get("v.selectedCenter"))].label,	
        listLineItem[currentIdx].ProfitMargin__c = ProfitMargin,	
        listLineItem[currentIdx].Quantity = 1,
        listLineItem[currentIdx].fm_QuantityUnitOfMeasure__c = listCurrentEntry[index].Product2.bas_unit_cd__c,
        listLineItem[currentIdx].CountryOfOriginName__c = listCurrentEntry[index].Product2.migr_orinat_cd__c,
        listLineItem[currentIdx].StorageConditionName__c = listCurrentEntry[index].Product2.strg_cond_cd__c,
        listLineItem[currentIdx].PricebookEntryId = listCurrentEntry[index].Id

        if ( sObjectName == 'Quote' )
            listLineItem[currentIdx].QuoteId = component.get("v.recordId");
        else if ( sObjectName == 'Opportunity' )
            listLineItem[currentIdx].OpportunityId = component.get("v.recordId");

        // 4. 학습데이터 전송 및 Paging 재처리 
        if ( component.get("v.strSearchInputForLearning") != ''){
            helper.doSendLearningData(component, listCurrentEntry[index]);
        }
        helper.doRenderPage(component);

    },

    /**
     * @description 데이터 행 추가
     * @param {*} component 
     */
     fnAddData : function(component, event, helper) {
        console.log('Point :: fnAddData Start !! ');
        component.set("v.showSpinner", true);
        
        // 0. 데이터 가져오기
        let sObjectName = component.get("v.sObjectName");
        let index = event.currentTarget.id;
        let listCurrentEntry = component.get("v.listCurrentEntry");
        let listLineItem = component.get("v.listLineItem");
        let countPerPage = component.get("v.countPerPage");
        let pageNumber = component.get("v.pageNumber");
        let listMonth = component.get("v.listMonth");
        let listCenter = component.get("v.listCenter");
        
        // 1. 선택행 비활성화 (중복방지)
        listCurrentEntry[index].isInActive = true;
        component.set("v.listCurrentEntry", listCurrentEntry);

        let setLineItemCode = new Set(component.get("v.setLineItemCode"));
        setLineItemCode.add(listCurrentEntry[index].Product2.gd_no__c);
        component.set("v.setLineItemCode", setLineItemCode);

        // 2. 데이터 체크
        let isTaxTarget =  listCurrentEntry[index].Product2.fm_TaxType__c == '과세' ? 1 : 0;
        let UnitPrice = listCurrentEntry[index].UnitPrice == 1 ? 1 : Math.ceil(listCurrentEntry[index].UnitPrice/10)* 10;
        let ProfitMargin = 100;

        if ( UnitPrice != 1){
            ProfitMargin = (UnitPrice - listCurrentEntry[index].UnitPrice)/UnitPrice * 100;
            ProfitMargin = Math.round(ProfitMargin * 100) / 100;
            
            if ( ProfitMargin > 99 ) {
                ProfitMargin = 99;
                UnitPrice =  Math.ceil(listCurrentEntry[index].UnitPrice / (1 - 99/100)/10)* 10;
            }
        }

        let VAT = (UnitPrice == 1) ? 0 : isTaxTarget * UnitPrice * 0.1;
        let Month = listMonth[listMonth.findIndex(objMap => objMap.value == component.get("v.selectedMonth"))].label;
        
        let BracketIndex = Month.indexOf('(');
        if( BracketIndex > -1 )
        Month = Month.substring(0, BracketIndex);

        // 3. 데이터 행 추가
         // 3-1. 견본 데이터가 없거나 LineItem 보다 작은 경우 행 생성
        let objLineItem = { 		            
            fm_PriceBookEntryName__c : listCurrentEntry[index].Name,	
            fm_ProductCode__c : listCurrentEntry[index].Product2.gd_no__c,	
            BasePurchasePrice__c : listCurrentEntry[index].UnitPrice,
            OldBasePurchasePrice__c : listCurrentEntry[index].OldUnitPrice,
            UnitPrice : UnitPrice,
            TaxTypeName__c : listCurrentEntry[index].Product2.fm_TaxType__c,
            UnitPriceWithVAT__c : UnitPrice + VAT,	
            VAT__c : VAT,
            ProductCategoryLName__c : listCurrentEntry[index].Product2.fm_LAR_CLS_NM__c,	 
            ProductCategoryMName__c : listCurrentEntry[index].Product2.fm_MID_CLS_NM__c,	 
            ProductCategoryCode__c : listCurrentEntry[index].Product2.fm_XSM_CLS_CD__c,	
            Month__c : component.get("v.selectedMonth"),
            MonthToLabel : Month, 
            LogisticsCenter__c : component.get("v.selectedCenter"),
            CenterToLabel : listCenter[listCenter.findIndex(objMap => objMap.value == component.get("v.selectedCenter"))].label, 
            ProfitMargin__c : ProfitMargin,	
            Quantity : 1,
            fm_QuantityUnitOfMeasure__c : listCurrentEntry[index].Product2.bas_unit_cd__c,
            CountryOfOriginName__c : listCurrentEntry[index].Product2.migr_orinat_cd__c,
            StorageConditionName__c : listCurrentEntry[index].Product2.strg_cond_cd__c,
            PricebookEntryId : listCurrentEntry[index].Id
        };	
        if ( sObjectName == 'Quote' )
            objLineItem.QuoteId = component.get("v.recordId");
        else if ( sObjectName == 'Opportunity' )
            objLineItem.OpportunityId = component.get("v.recordId");
            
        listLineItem.push(objLineItem);
        
        let listLineItemLength = listLineItem.length;
        let lastIdx = listLineItemLength - 1;

        component.set("v.currentIdx", lastIdx);
        component.set("v.lastIdx", lastIdx);
        

        // 4. 학습데이터 전송 및 Paging 재처리, Index 기준 현재 페이지 설정
        
        if ( component.get("v.strSearchInputForLearning") != ''){
            helper.doSendLearningData(component, listCurrentEntry[index]);
        }

        if( lastIdx % countPerPage == 0 && lastIdx != 0){
            helper.doReCalcPage(component, true);
        }
        else if ( lastIdx > 0 && ( lastIdx <= (countPerPage*(pageNumber-1)-1) || lastIdx >= countPerPage*pageNumber )) {
            helper.doFindPage(component);
        }
        else {
            helper.doRenderPage(component);
        }
    },

    /**
     * @description 데이터 행 삭제
     */
     fnRemoveData : function(component, event, helper) {
        console.log('Point :: fnRemoveData Start !! ');

        component.set("v.showSpinner", true);

        // 0. 데이터 가져오기
        let index = Number(event.currentTarget.id);
        let listLineItem = component.get("v.listLineItem");
        let countPerPage = component.get("v.countPerPage");
        let listCurrentEntry = component.get("v.listCurrentEntry");

        let  mapCurrentEntry = new Map();
        for ( let key in listCurrentEntry )
            mapCurrentEntry.set(listCurrentEntry[key].Product2.gd_no__c, listCurrentEntry[key]);

        setTimeout(function(){ 
            // 1. 해당 상품코드 비활성화(중복방지) 목록에서 제거 
            if ( mapCurrentEntry.get(listLineItem[index].fm_ProductCode__c) ){
                mapCurrentEntry.get(listLineItem[index].fm_ProductCode__c).isInActive = false;
                component.set("v.listCurrentEntry", listCurrentEntry);
            };
            
            let setLineItemCode = new Set(component.get("v.setLineItemCode"));
            setLineItemCode.delete(listLineItem[index].fm_ProductCode__c);
            component.set("v.setLineItemCode", setLineItemCode);

            let listLineItemLength = listLineItem.length;
            let lastIdx = listLineItemLength - 1;

            if ( listLineItem[index].ExcelData != null &&  listLineItem[index].ExcelData != ''){
                    listLineItem[index].PricebookEntryId = null;
                    listLineItem[index].fm_PriceBookEntryName__c = '';
                    listLineItem[index].TaxTypeName__c = '';
                    listLineItem[index].BasePurchasePrice__c = null;
                    listLineItem[index].OldBasePurchasePrice__c = null;
                    listLineItem[index].UnitPrice = null;
                    listLineItem[index].UnitPriceWithVAT__c = null;
                    listLineItem[index].VAT__c = null;
                    listLineItem[index].ProfitMargin__c = null;
                    listLineItem[index].Month__c = '';
                    listLineItem[index].MonthToLabel = '';
                    listLineItem[index].LogisticsCenter = '';
                    listLineItem[index].CenterToLabel = '';
                    listLineItem[index].fm_QuantityUnitOfMeasure__c = '',
                    listLineItem[index].CountryOfOriginName__c = '',
                    listLineItem[index].StorageConditionName__c = '',
                    listLineItem[index].ProductCategoryLName__c = '',
                    listLineItem[index].ProductCategoryMName__c = '',
                    listLineItem[index].fm_ProductCode__c = '',
                    listLineItem[index].Id = null;
                    listLineItem[index].Product2Id = null;
                    listLineItem[index].Quantity = 1;
                    listLineItem[index].QuotPricebookEntryId = null;
                    component.set("v.currentIdx", index);
            } else {
                listLineItem.splice(index,1);
                listLineItemLength = listLineItemLength -1;
                
                if( index == lastIdx)
                    component.set("v.currentIdx", index-1);

                component.set("v.lastIdx", lastIdx-1);
            }            

            let pageNumber = component.get("v.pageNumber");

            // 4. Paging 재처리, Index 기준 현재 페이지 설정
            if( listLineItemLength % countPerPage == 0 && listLineItemLength > 0){
                if ( pageNumber == (listLineItemLength/countPerPage +1) ){
                    helper.doReCalcPage(component, true);
                }
                else { 
                    helper.doReCalcPage(component, false);
                }
            }
            else {
                helper.doRenderPage(component);
            }
            component.set("v.showSpinner", false);
        }, 100);
    },

    /**
     * @description 매익률 ↔ 견적가 계산
     */
    fnCalc : function(component, event, helper) {

        // 0. 데이터 가져오기 
        let name = event.getSource().get("v.name");
        let id = event.getSource().get("v.id");
        let idx = id.slice(name.length+1);;
        let calcId ; 
        let record = component.get("v.pageRecords")[idx];

        let isTaxTarget = (record.TaxTypeName__c == '과세' ? 1 : 0);
        // 1. 견적가를 수정한 경우 
        if ( name == 'QuotedPrice'){
            calcId = 'ProfitMargin-'+idx;

            // 1-1. 입력값이 옳바르지 않은 경우
            if ( record.UnitPrice == '' || record.UnitPrice < 10) record.UnitPrice = 10;
            else if ( record.UnitPrice > 1000000000) record.UnitPrice = 1000000000;
            // 1-2. 입력값 보정 (1 Ceiling)
            record.UnitPrice =  Math.ceil(record.UnitPrice/10)* 10;

            let ProfitMargin = (record.UnitPrice - record.BasePurchasePrice__c)/record.UnitPrice * 100;
            if ( ProfitMargin > 99 ) {
                record.ProfitMargin__c = 99;
                record.UnitPrice =  Math.ceil(record.BasePurchasePrice__c / (1 - record.ProfitMargin__c/100)/10)* 10;
            }

            record.VAT__c = isTaxTarget * record.UnitPrice*0.1;
            record.UnitPriceWithVAT__c = Number(record.UnitPrice) + Number(record.VAT__c);
            // 1-3. 입력값 + 기준매입가 기준 매익률 계산 (-2 Round)
            let result = (record.UnitPrice - record.BasePurchasePrice__c)/record.UnitPrice * 100;
            record.ProfitMargin__c = Math.round(result * 100) / 100;
             
        }
        // 2. 매익률을 수정한 경우 
        else if ( name == 'ProfitMargin'){
            
            // 2-3. 입력값이 옳바르지 않은 경우 
            if ( record.ProfitMargin__c == ''){
                record.ProfitMargin__c = 0;
            } else if ( record.ProfitMargin__c > 99 ){
                record.ProfitMargin__c = 99;
            }
 
            calcId = 'QuotedPrice-'+idx;
            // 2-1. 입력값 보정 (1 Ceiling)
            record.UnitPrice =  Math.ceil(record.BasePurchasePrice__c / (1 - record.ProfitMargin__c/100)/10)* 10;
            record.VAT__c = isTaxTarget*record.UnitPrice*0.1;
            record.UnitPriceWithVAT__c = record.UnitPrice + record.VAT__c;
            let ProfitMargin = (record.UnitPrice - record.BasePurchasePrice__c)/record.UnitPrice * 100;
            record.ProfitMargin__c = Math.round(ProfitMargin * 100) / 100;
        }
        // 3. 데이터 Validate 
        setTimeout(function(){ 
        let validationTarget = component.find('validTarget');
            for(let i in validationTarget) {
                if( calcId == validationTarget[i].get("v.id")){
                    if(!validationTarget[i].checkValidity()) {
                        validationTarget[i].set("v.validity", false);
                        validationTarget[i].showHelpMessageIfInvalid();
                    }
                    else{
                        validationTarget[i].reportValidity();
                    }
                }
            }
        }, 100);
        helper.doRenderPage(component);
    },

    /**
     * @description 매익율 일괄적용
     */
     fnEditAllMargin : function(component, event, helper) {  
        component.set("v.showSpinner", true);

            // 0. 대상 데이터 가져오기 및 Validate
            let validationTarget = component.find('intAllMargin');
            if(!validationTarget.checkValidity()) {
                validationTarget.set("v.validity", false);
                validationTarget.showHelpMessageIfInvalid();
                component.set("v.showSpinner", false);
                return ;
            }

            let intAllMargin = component.get("v.intAllMargin");
            let selectedCategoryL_A = component.get("v.selectedCategoryL_A");
            let selectedCategoryM_A = component.get("v.selectedCategoryM_A");
            
            if ( intAllMargin == ''){
                intAllMargin = 0;
            } else if ( intAllMargin > 99 ){
                intAllMargin = 99;
            }

            let listLineItem = component.get("v.listLineItem");
            let lastIdx = component.get("v.lastIdx");
            
            // 1. 매익률 기반 견적가 및 매익률 재계산
            // 1-1. 중분류가 설정된 경우
            if ( selectedCategoryM_A != 'none'){
                for(let i = 0 ; i <= lastIdx; i++ ){
                    let objLineItem = listLineItem[i];
                    if (objLineItem.UnitPrice == 1 || objLineItem.fm_PriceBookEntryName__c == '') continue;
                    if ( (objLineItem.ProductCategoryCode__c).substring(0,4) != selectedCategoryM_A ) continue;
                    let isTaxTarget = objLineItem.TaxTypeName__c == '과세' ? 1 : 0;
                    objLineItem.UnitPrice =  Math.ceil(objLineItem.BasePurchasePrice__c / (1 - intAllMargin/100)/10)* 10;
                    objLineItem.VAT__c = isTaxTarget*objLineItem.UnitPrice*0.1;
                    objLineItem.UnitPriceWithVAT__c = objLineItem.UnitPrice + objLineItem.VAT__c;
                    let ProfitMargin = (objLineItem.UnitPrice - objLineItem.BasePurchasePrice__c)/objLineItem.UnitPrice * 100;
                    objLineItem.ProfitMargin__c = Math.round(ProfitMargin * 100) / 100;
                }

            }
            // 1-2. 대분류가 설정된 경우
            else if ( selectedCategoryL_A != 'none'){
                for(let i = 0 ; i <= lastIdx; i++ ){
                    let objLineItem = listLineItem[i];
                    if (objLineItem.UnitPrice == 1 || objLineItem.fm_PriceBookEntryName__c == '' ) continue;
                    if ( (objLineItem.ProductCategoryCode__c).substring(0,2) != selectedCategoryL_A ) continue;
                    let isTaxTarget = objLineItem.TaxTypeName__c == '과세' ? 1 : 0;
                    objLineItem.UnitPrice =  Math.ceil(objLineItem.BasePurchasePrice__c / (1 - intAllMargin/100)/10)* 10;
                    objLineItem.VAT__c = isTaxTarget*objLineItem.UnitPrice*0.1;
                    objLineItem.UnitPriceWithVAT__c = objLineItem.UnitPrice + objLineItem.VAT__c;
                    let ProfitMargin = (objLineItem.UnitPrice - objLineItem.BasePurchasePrice__c)/objLineItem.UnitPrice * 100;
                    objLineItem.ProfitMargin__c = Math.round(ProfitMargin * 100) / 100;
                }

            }
            // 1-3. 분류가 설정되지 않은 경우
            else {
                for(let i = 0 ; i <= lastIdx; i++ ){
                    let objLineItem = listLineItem[i];
                    if (objLineItem.UnitPrice == 1 || objLineItem.fm_PriceBookEntryName__c == '') continue;
                    let isTaxTarget = objLineItem.TaxTypeName__c == '과세' ? 1 : 0;
                    objLineItem.UnitPrice =  Math.ceil(objLineItem.BasePurchasePrice__c / (1 - intAllMargin/100)/10)* 10;
                    objLineItem.VAT__c = isTaxTarget*objLineItem.UnitPrice*0.1;
                    objLineItem.UnitPriceWithVAT__c = objLineItem.UnitPrice + objLineItem.VAT__c;
                    let ProfitMargin = (objLineItem.UnitPrice - objLineItem.BasePurchasePrice__c)/objLineItem.UnitPrice * 100;
                    objLineItem.ProfitMargin__c = Math.round(ProfitMargin * 100) / 100;
                }
            }
            component.set("v.isOpenMarginBox",false);
            helper.doRenderPage(component);
       
    },

    /**
     * @description 기준월 변경시 검색목록 초기화
     */
     fnChangeMonth : function(component, event, helper) {  
        component.set("v.listCurrentEntry", []);
        component.set("v.isChangeCondition", true);
    },
    
    /**
     * @description 물류센터 변경시 검색목록 초기화
     */
    fnChangeCenter : function(component, event, helper) {  
        component.set("v.listCurrentEntry", []);
        component.set("v.isChangeCondition", true);
    },

    /**
     * @description 물류센터 변경시 검색목록 초기화
     */
     fnChangeCategoryL : function(component, event, helper) {  
        component.set("v.listCurrentEntry", []);
        component.set("v.isChangeCondition", true);
    },

    /**
     * @description 검색유형 변경시 검색목록 초기화
     */
     fnChangeSearchType : function(component, event, helper) {  
        component.set("v.listCurrentEntry", []);
        component.set("v.isChangeCondition", true);
    },


    /**
     * @description 물류센터 변경시 검색목록 초기화
     */
     fnChangeControl : function(component, event, helper) {  
        component.set("v.listCurrentEntry", []);
    },

    
    /**
     * @description 매익율 일괄적용 화면 Open
     */
     fnToggleMarginBox : function(component, event, helper) {  
        let isOpenMarginBox = component.get("v.isOpenMarginBox");
        component.set("v.isOpenMarginBox",!isOpenMarginBox);
    },
    
    /**
     * @description 일괄매익률 대분류 변경시 중분류 초기화
     */
    fnChangeCategoryL_A : function(component, event, helper) {  
        let mapCategoryM = component.get("v.mapCategoryM");
        let selectedCategoryL_A = component.get("v.selectedCategoryL_A");
        if ( selectedCategoryL_A == 'none') {
            let mapNoSelectCategoryL = [{ value: 'none', label: '전체' }];
            component.set("v.listCategoryM", mapNoSelectCategoryL);
        }
        else {
            component.set("v.listCategoryM", mapCategoryM[selectedCategoryL_A]);
        }
        component.set("v.selectedCategoryM_A", 'none');
    },

    /**
     * @description 데이터 저장
     */
     fnSave : function(component, event, helper) {

        // 0. 데이터 가져오기
        component.set("v.showSpinner", true);
        component.set("v.saveType", event.getSource().get("v.value"));
        let listLineItem = component.get("v.listLineItem");
        
        // * 대량 데이터 저장시 Spinner 미발생으로 인한 SetTimeout 설정
        setTimeout(function(){ 
            
            // 1. 더블클릭 방지
            if(component.get("v.isBTNClicked") == true){
                console.log("Duplication prevention!");
                return;
            }
            component.set("v.isBTNClicked", true);  

            // 2. 데이터 목록 Validate
            let indexFirstError = null;
            let countError = 0;
            for(var i in listLineItem) {
                if( listLineItem[i].fm_PriceBookEntryName__c !='' && (listLineItem[i].UnitPrice == '' || listLineItem[i].UnitPrice == null)  ){
                    if ( indexFirstError == null)
                        indexFirstError = i;
                    countError++;
                }
                setTimeout(function(){ 
                    let validationTarget = component.find('validTarget');
                    for(let i in validationTarget) {
                        if(!validationTarget[i].checkValidity()) {
                            validationTarget[i].set("v.validity", false);
                            validationTarget[i].showHelpMessageIfInvalid();
                        }
                    }
                }, 100);
            }

            if ( indexFirstError != null){
                component.set("v.isBTNClicked", false);  
                helper.showToast("error", "정상적인 값을 입력하세요 ("+countError+"건)" );
                component.set("v.showSpinner", false);
                return;
            }
            helper.doSave(component, false, false);

        }, 2000);
    },

    /**
     * @description ExcelPaste 화면 Open
     */
    fnOpenExcelPaste : function(component, event, helper) {
        component.set("v.isOpenExcelPaste", true);
        component.set("v.isAISearch", true);
    },

    /**
     * @description ExcelPaste 완료시 데이터 Set
     */
    fnHandleExcelpaste : function(component, event, helper) {
        // 1. isComplete가 True 즉, PasteData 제출 시 에만 동작  
        if( !component.get("v.isComplete") )
        return false;
        component.set("v.showSpinner", true);

        // 2. 견본/전체업로드 구분따라 분기 
        let openTab = component.get("v.openTab");

        if( openTab == 'Sample'){
            helper.doHandleExcelpaste_Sample(component);
        }
        else if ( openTab == 'Full'){
            helper.doHandleExcelpaste_Full(component);
        }
    },
    
    /**
     * @description Excel 견본 수정 기능 
     */
     fnToggleAddMode : function(component, event, helper) {  
        let isReplace = component.get("v.isReplace");
        component.set("v.isReplace",!isReplace);
    },
    

    /**
     * @description 견본데이터 클릭시 해당 키워드 검색
     */
     fnAutoSearch : function(component, event, helper) {
        
        let isReplace = component.get("v.isReplace");
        if ( isReplace == false )
        component.set("v.isReplace",true);

        // 1. 키워드 불러오기
        let index = event.currentTarget.id;
        let pageRecords = component.get("v.pageRecords");
        let searchKey = pageRecords[index].ExcelData;

        if ( searchKey == '' || searchKey == null)
        return;

        // 2. 규격 열 삭제 후 검색
        let BracketIndex = searchKey.indexOf('(');
        if( BracketIndex > -1 )
        searchKey = searchKey.substring(0, BracketIndex);

        // 검색 분기 
        let regex = new RegExp("\\\\|\'","gi");
        
        if ( searchKey == null) searchKey = '';
        if ( searchKey != '' ) searchKey = searchKey.replace(regex, "");

        component.set("v.strSearchInput", searchKey);
        component.set("v.strSearchInputForLearning", searchKey);

        if ( component.get("v.isChangeCondition") )
            helper.doGetAllEntry(component, searchKey);
        else{
            component.set("v.isChangeCondition", false);        
            if ( component.get("v.isAISearch") ){ 
                if( searchKey == '') {
                    component.set("v.listCurrentEntry", []);
                    return false;
                }
                helper.doSearchAI(component, searchKey, false);
            }
            else {
                helper.doSearch(component, searchKey, false);
            }
        }
    },

    /**
     * @description 데이터 목록 Rendering
     */
    fnRenderPage : function(component, event, helper) {
        component.set("v.showSpinner", true);
        setTimeout(function(){ 
            let validationTarget = component.find('validTarget');
            console.log('validationTarget' + validationTarget );

            for(let i in validationTarget) {
                console.log('validationTarget' + validationTarget[i] );
                if(!validationTarget[i].checkValidity()) {
                    validationTarget[i].set("v.validity", false);
                    validationTarget[i].showHelpMessageIfInvalid();
                }
            }
        }, 100);
        helper.doRenderPage(component);
    },
    
    /**
     * @description 검색 목록 Rendering
     */
    fnSubRenderPage : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.doSubRenderPage(component);
    },


    /**
     * @description 메인 화면 닫기
     */
    fnCancel : function(component, event, helper) {
        window.location.href = "/" + component.get("v.recordId");
    },
})