/**
 * @description       : LineItemMgmtHelper.js
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   07-26-2023   eunyoung.choi@dkbmc.com   Initial Version
 * 2.0   08-03-2023   eunyoung.choi@dkbmc.com   product name ->  /,공백,\, _ 제거 => 검색기능 향상 
**/
({
    /**
     * @description 초기 데이터 가져오기
     *              상품검색목록 헤더에 세팅될 데이터 
     */
    getLineItem : function(component) {
        console.log('# LineItemMgmtHelper # getLineItem ');
        let action = component.get("c.getLineItem");

		action.setParams({
            recordId : component.get("v.recordId"),
            sObjectName : component.get("v.sObjectName")
		});
		action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                
                // 0. 데이터 가져오기 
                let returnValue = response.getReturnValue();
                let listMonth = returnValue.listMonth;
                let listCenter = returnValue.listCenter;
                let listOrigin = returnValue.listOrigin;
                
                // 1. 기준월 및 물류센터 default 설정
                let now = new Date();
                let day = now.getDate();
                let month = now.toLocaleString("en-US", { month: "short" });    
                let year = now.getYear()-100; 
                console.log( 'getYear v:: ' + year);       
                let defaultMonth = '';

                day <= 15 ? defaultMonth = 'Early' + month : defaultMonth = 'Late' + month;

                let thisYear = true;
                for ( let i in listMonth){
                    if ( !thisYear){    
                        listMonth[i].label = (listMonth[i].label +'('+ (year-1) +'년)');
                    }
                    
                    if(listMonth[i].value == defaultMonth){
                        listMonth[i].selected = true;
                        thisYear = false;
                    }
                    else{
                        listMonth[i].selected = false;
                    }

                }
                component.set("v.listMonth", listMonth);
                component.set("v.listCenter", listCenter);
                component.set("v.selectedMonth", defaultMonth);
                component.set("v.selectedCenter", listCenter[0].value);
                component.set("v.listOrigin", listOrigin);
                component.set("v.objParent", returnValue.objParent);

                // 2. 상품분류 설정
                let listCategoryL = returnValue.listCategoryL;
                let mapCategoryM = returnValue.mapCategoryM;
                component.set("v.listCategoryL", listCategoryL);
                component.set("v.mapCategoryM", mapCategoryM);
                component.set("v.selectedCategoryL", 'none');
                
                let mapNoSelectCategoryL = [{ value: 'none', label: '전체' }];
                component.set("v.listCategoryM", mapNoSelectCategoryL);
                component.set("v.selectedCategoryM_A", 'none');
                

                // 3. 기준월 및 물류센터 Value to Label 후 렌더링
                let setLineItemCode = new Set();
                if(returnValue.listLineItem.length > 0) {
                    for( let i in returnValue.listLineItem){
                        setLineItemCode.add(returnValue.listLineItem[i].fm_ProductCode__c);
                        let idxMonth = listMonth.findIndex(objMap => objMap.value == returnValue.listLineItem[i].Month__c); 
                        if (idxMonth != -1)
                        returnValue.listLineItem[i].MonthToLabel = listMonth[idxMonth].label;
                        let idxCenter = listCenter.findIndex(objMap => objMap.value == returnValue.listLineItem[i].LogisticsCenter__c); 
                        if (idxCenter != -1)
                        returnValue.listLineItem[i].CenterToLabel = listCenter[idxCenter].label;
                    }
                    let countPerPage = component.get("v.countPerPage");
                    component.set("v.maxPage", Math.floor((returnValue.listLineItem.length + (countPerPage - 1)) / countPerPage));
                    component.set("v.pageNumber", 1);
                    component.set("v.lastIdx", returnValue.listLineItem.length-1);
                }
                component.set("v.listLineItem", returnValue.listLineItem);
                component.set("v.objUser", returnValue.objUser);
                console.log('returnValue.objUser :: ' + JSON.stringify(returnValue.objUser) );
                component.set("v.setLineItemCode", setLineItemCode);

                this.doRenderPage(component);

			} else if(state === "ERROR") {
                let errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else if(errors[0] && errors[0].pageErrors[0].message){
                        this.showToast("error", errors[0].pageErrors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    
    /**
     * @description 상품 검색목록 가져오기 (초기검색)
     * @param {String}  searchKey     검색 키워드
     * @param {Boolean} isAutoMapping 자동 매핑 여부
     * 2023.08.03 : mapParam에 objUser 추가 / eunyoung.choi
     */
     doGetAllEntry : function(component, searchKey, isAutoMapping) {
        console.log('# LineItemMgmtHelper # doGetAllEntry # 초기검색 ');
        component.set("v.showSpinner", true);
        // mapParam
        let objParent = component.get("v.objParent");
        let selectedMonth = component.get("v.selectedMonth");
        let selectedCenter = component.get("v.selectedCenter");
        let selectedCategoryL = component.get("v.selectedCategoryL");
        let sortStatus = component.get("v.sortStatus");
       
        let objUser = component.get("v.objUser");
        console.log('objUser ->' , JSON.stringify(objUser) );
        
        let action = component.get("c.doSearch");
        let mapParam = {
            "Pricebook2Id" : objParent.Pricebook2Id,
            "selectedCategoryL" : selectedCategoryL,
            "selectedMonth" : selectedMonth,
            "selectedCenter" : selectedCenter,
            "sortStatus" : sortStatus,
            "objUser" : objUser
        };

        action.setParams({
            "mapParam" : mapParam
        });

        console.log ('Apex Query Start:: ');
		action.setCallback(this, function(response) {
            console.log ('Apex Query End:: ');
            let state = response.getState();

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                // Page List 셋팅
                let listAllEntry = returnValue.listAllEntry;
                component.set("v.listAllEntry", listAllEntry);       
                component.set("v.isChangeCondition", false);

                // 자동 매핑 프로세스인 경우, 다시 자동 매핑 프로세스로 복귀 
                if ( isAutoMapping) {
                    this.doAutoMappingAI(component);
                // AI 검색인 경우, AI 검색 프로세스 진행
                } else if ( component.get("v.isAISearch") ){ 
                    this.doSearchAI(component, searchKey, isAutoMapping);
                // 일반 검색인 경우, 일반 검색 프로세스 진행 
                } else {
                    this.doSearch(component, searchKey, isAutoMapping);
                }
            }
            else if(state === "ERROR") {
                let errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else if(errors[0] && errors[0].pageErrors[0].message){
                        this.showToast("error", errors[0].pageErrors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    
    /**
     * @description 상품 검색목록 가져오기 (재검색)
     * @param {String}  searchKey     검색 키워드
     * @param {Boolean} isAutoMapping 자동 매핑 여부
     */
     doSearch : function(component, searchKey, isAutoMapping) {
        console.log('# LineItemMgmtHelper # doSearch ');
        component.set("v.showSpinner", true);

        let subCountPerPage = component.get("v.subCountPerPage");
        let listAllEntry = component.get("v.listAllEntry");
        console.log('#doSearch Controller -> 반환된 PriceBookEntry 전체리스트 -> ', (JSON.stringify(listAllEntry)) );
        let listSearchEntry =  [];
        
        if ( searchKey == ''){
            console.log(' #####  1 ');
            listSearchEntry = listAllEntry;
            //console.log(' listSearchEntry -> ');
        }
        else if (searchKey.length == 6 && Number(searchKey)){
            console.log(' #####  2 ');
            listSearchEntry = listAllEntry.filter(function(v) {
                return (v.ProductCode.indexOf(searchKey) > -1);
            });
        }
        else {
            // 필터조건 변경 
            console.log(' #####  3 ');
            listSearchEntry = listAllEntry.filter(function(v) {
                return (v.Name.indexOf(searchKey) > -1);
            });

            /* 조건추가 [Start] 23.08.03 eunyoung.choi 
               : name 값을 받아서 ,  / , 공백 , \ , _ 제거해주기 -> 

            */
/*             const changeData = JSON.parse((JSON.stringify(listAllEntry)));
            const changeName = changeData.map(item => item.Name.replace(/[\(\)_\/\s]/g, ''));
            console.log('name 값 변환 -> ' , changeName); */

/*             listSearchEntry = listAllEntry.map(item => {
                return {
                  ...item,
                  Name: item.Name.replace(/[\(\)_\/\s]/g, '')
                };
              });
               */
            //console.log('변환된 listSearchEntry -> ', listSearchEntry );

            /* 조건추가 [End] */

        }
        console.log('# LineItemMgmtHelper # doSearch # 검색에 맞는 결과값 -> ', listSearchEntry);
        let listSearchEntryCode = listSearchEntry.map(v => v.ProductCode);
        console.log('# LineItemMgmtHelper # doSearch # Product Code ->', listSearchEntryCode);

        component.set("v.subMaxPage", Math.floor((listSearchEntryCode.length + (subCountPerPage - 1)) / subCountPerPage));
        component.set("v.subPageNumber", 1);
                
        component.set("v.listSearchEntryCode", listSearchEntryCode);
            
        this.doSubRenderPage(component, isAutoMapping);
    },

    
    /**
     * @description 상품 검색목록 가져오기 (AI검색)
     * @param {String}  searchKey     검색 키워드
     * @param {Boolean} isAutoMapping 자동 매핑 여부
     */
     doSearchAI : function(component, searchKey, isAutoMapping) {
        console.log('h.4> doSearchAI -------------');
        component.set("v.showSpinner", true);
        let selectedCenter = component.get("v.selectedCenter");

        let action = component.get("c.doSearchAI");
        let mapParam = {
            "searchKey" : searchKey,
            "selectedCenter" : selectedCenter
        };
        
        action.setParams({
            "mapParam" : mapParam
        });

		action.setCallback(this, function(response) {
            let state = response.getState();
            
            if(state === "SUCCESS") {
                console.log('h.4.1> AI Search success => ', mapParam);
                
                let returnValue = response.getReturnValue();
                
                // 1. Page List 셋팅
                let listAIEntryCode = returnValue.listAIEntryCode;             
                let listAllEntry = component.get("v.listAllEntry");
                console.log('h.4.2> listAllEntry => ', JSON.stringify(listAllEntry) );
                console.log('h.4.3> listAllEntry length => ', (JSON.stringify(listAllEntry)).length );
                
                console.log ( 'listAIEntryCode :: ' + JSON.stringify(listAIEntryCode));
                var AISearchSize = JSON.parse(JSON.stringify(listAIEntryCode));
                console.log ( 'h. AI SIZE -> ' + AISearchSize.length );
                
                // 전체 검색 리스트에서 productCode만 추출해서 Map에 담음 
                let listAllEntryCode = listAllEntry.map(v => v.ProductCode);
                
                console.log ( 'h.4.4> listAllEntryCode -> ' + listAllEntryCode );
                
                
                // AI 코드중 vs  전체리스트 비교후 겹치는 것만 return
                let listSearchEntryCode = listAIEntryCode.filter(function(v) {
                    return (listAllEntryCode.includes(v));
                });
                
                console.log ( 'h.4.5> listSearchEntryCode -> ' + listSearchEntryCode );

                let subCountPerPage = component.get("v.subCountPerPage");
                component.set("v.subMaxPage", Math.floor((listSearchEntryCode.length + (subCountPerPage - 1)) / subCountPerPage));
                component.set("v.subPageNumber", 1);
                        
                component.set("v.listSearchEntryCode", listSearchEntryCode);
                    
                this.doSubRenderPage(component, isAutoMapping);
            }
            else if(state === "ERROR") {
                let errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else if(errors[0] && errors[0].pageErrors[0].message){
                        this.showToast("error", errors[0].pageErrors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description 상품 검색 리스트 렌더링
     */
     doSubRenderPage : function(component, isAutoMapping) {   
        console.log('h.5> doSubRenderPage -------------');    
        let subPageNumber = component.get("v.subPageNumber");
        let subCountPerPage = component.get("v.subCountPerPage");
        let listSearchEntryCode = component.get("v.listSearchEntryCode");
        let selectedControl = component.get("v.selectedControl");
        let objParent = component.get("v.objParent");
        let selectedCenter = component.get("v.selectedCenter");
        
        let isAISearch = component.get("v.isAISearch");
        let listTargetEntryCode = listSearchEntryCode.slice((subPageNumber - 1) * subCountPerPage, subPageNumber * subCountPerPage);
        let selectedMonth = component.get("v.selectedMonth");
        let sortStatus = component.get("v.sortStatus");

        // let suCode = component.get('v')

        let action = component.get("c.getCurrentEntry");
         
        action.setParams({
            "listTargetEntryCode" : listTargetEntryCode,
            "selectedCenter" : selectedCenter,
            "selectedMonth" : selectedMonth,
            "sortStatus" : sortStatus,
            "selectedControl" : selectedControl,
            "customerID" : objParent.Account.CustomerID__c,
        });
		action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                let setControlEntry = new Set();
                if (selectedControl == 'Y'){
                    let objControllWrapper = returnValue.objControllWrapper;
                    setControlEntry = new Set(objControllWrapper.listControlEntry);
                    let ERR_CD = objControllWrapper.ERR_CD;
                    let ERR_MSG_CTT = objControllWrapper.ERR_MSG_CTT;
                    
                    if ( ERR_CD != '0000'){
                        this.showToast("Error", "[" + ERR_CD + "] " + ERR_MSG_CTT);
                    }
                }

                let listCurrentEntry = [];

                // AI 검색인 경우 TOP 순서로 정렬, 아니면 리턴 받은 대로 사용
                if ( isAISearch ){
                    for ( let i in listSearchEntryCode ){
                        for ( let j in returnValue.listCurrentEntry){
                            if ( listSearchEntryCode[i] == returnValue.listCurrentEntry[j].ProductCode ){
                                listCurrentEntry.push(returnValue.listCurrentEntry[j]);
                            }
                        }
                    }
                } else {
                    listCurrentEntry = returnValue.listCurrentEntry;
                }

                let setLineItemCode = new Set(component.get("v.setLineItemCode"));

                let objAutoMappingData = null;
                if ( listCurrentEntry.length > 0){
                    for ( let i in listCurrentEntry ){
                        listCurrentEntry[i].isRestrict = (setControlEntry.has(listCurrentEntry[i].Product2.gd_no__c) ? true : false);
                        listCurrentEntry[i].isInActive = (setLineItemCode.has(listCurrentEntry[i].Product2.gd_no__c) ? true : false);
                        listCurrentEntry[i].UnitPrice = listCurrentEntry[i][selectedMonth+'__c'] ;
                        listCurrentEntry[i].OldUnitPrice = listCurrentEntry[i]['Old'+selectedMonth+'__c'] ;

                        // 이미 선택된 데이터 이거나 상품제어가 활성화된 경우 제어상품이 아닌 상품 매핑
                        if ( isAutoMapping ){
                            if ( selectedControl == 'Y'){
                                if (!listCurrentEntry[i].isRestrict && !listCurrentEntry[i].isInActive){
                                    objAutoMappingData = listCurrentEntry[i];
                                    break;
                                }
                            } else {
                                if ( !listCurrentEntry[i].isInActive){
                                    objAutoMappingData = listCurrentEntry[i];
                                    break;
                                } 
                            }
                        }

                    }
                }

                // 자동 매핑 프로세스 인 경우
                if ( isAutoMapping ){

                    let listLineItem = component.get("v.listLineItem");
                    let idxPasteMapping = component.get("v.idxPasteMapping");
                    let listPasteResult = component.get("v.listPasteResult");

                    // 매핑된 데이터가 없는 경우 Excel 데이터만 존재하는 레코드 삽입
                    if ( objAutoMappingData == null ){
                        let objLineItem = { 	
                            ExcelData : listPasteResult[idxPasteMapping],           
                            fm_PriceBookEntryName__c : '',		
                            BasePurchasePrice__c: null,
                            OldBasePurchasePrice__c: null,
                            Month__c: '',
                            MonthToLabel: '',
                            LogisticsCenter__c: '',
                            CenterToLabel: '',
                            UnitPrice: null,	
                            UnitPriceWithVAT__c: null,	
                            VAT__c: null,	
                            Quantity : 1,
                            PricebookEntryId : null
                        };
                        listLineItem.push(objLineItem);
                    // 매핑된 데이터가 있는 경우 데이터 설정 후 레코드 삽입 
                    } else {
                        let listMonth = component.get("v.listMonth");
                        let listCenter = component.get("v.listCenter");

                        let isTaxTarget =  objAutoMappingData.Product2.fm_TaxType__c == '과세' ? 1 : 0;
                        let UnitPrice = objAutoMappingData.UnitPrice == 1 ? 1 : Math.ceil(objAutoMappingData.UnitPrice/10)* 10;
                        let ProfitMargin = 100;
    
                        if ( UnitPrice != 1){
                            ProfitMargin = (UnitPrice - objAutoMappingData.UnitPrice)/UnitPrice * 100;
                            ProfitMargin = Math.round(ProfitMargin * 100) / 100;
                            
                            if ( ProfitMargin > 99 ) {
                                ProfitMargin = 99;
                                UnitPrice =  Math.ceil(objAutoMappingData.UnitPrice / (1 - 99/100)/10)* 10;
                            }
                        }
    
                        let VAT = (UnitPrice == 1) ? 0 : isTaxTarget * UnitPrice * 0.1;
                        let Month = listMonth[listMonth.findIndex(objMap => objMap.value == component.get("v.selectedMonth"))].label;
    
                        let BracketIndex = Month.indexOf('(');
                        if( BracketIndex > -1 )
                        Month = Month.substring(0, BracketIndex);
    
                        let objLineItem = { 	
                            ExcelData : listPasteResult[idxPasteMapping],     
                            fm_PriceBookEntryName__c : objAutoMappingData.Name,	
                            fm_ProductCode__c : objAutoMappingData.Product2.gd_no__c,	
                            BasePurchasePrice__c : objAutoMappingData.UnitPrice,
                            OldBasePurchasePrice__c : objAutoMappingData.OldUnitPrice,
                            UnitPrice : UnitPrice,
                            TaxTypeName__c : objAutoMappingData.Product2.fm_TaxType__c,
                            UnitPriceWithVAT__c : UnitPrice + VAT,	
                            VAT__c : VAT,
                            ProductCategoryLName__c : objAutoMappingData.Product2.fm_LAR_CLS_NM__c,	 
                            ProductCategoryMName__c : objAutoMappingData.Product2.fm_MID_CLS_NM__c,	 
                            ProductCategoryCode__c : objAutoMappingData.Product2.fm_XSM_CLS_CD__c,	
                            Month__c : selectedMonth,
                            MonthToLabel : Month, 
                            LogisticsCenter__c : selectedCenter,
                            CenterToLabel : listCenter[listCenter.findIndex(objMap => objMap.value == selectedCenter)].label, 
                            ProfitMargin__c : ProfitMargin,	
                            Quantity : 1,
                            fm_QuantityUnitOfMeasure__c : objAutoMappingData.Product2.bas_unit_cd__c,
                            CountryOfOriginName__c : objAutoMappingData.Product2.mnfco_orinat_cd__c,
                            StorageConditionName__c : objAutoMappingData.Product2.strg_cond_cd__c,
                            PricebookEntryId : objAutoMappingData.Id
                        };
                        listLineItem.push(objLineItem);
                        setLineItemCode.add(objAutoMappingData.Product2.gd_no__c);
                        component.set("v.setLineItemCode", setLineItemCode);
                    }
                    // 견본 데이터 Index + 1 후 매핑 프로세스로 돌아가기
                    component.set("v.idxPasteMapping", idxPasteMapping+1);
                    this.doAutoMappingAI(component);
                } else {
                // 자동 매핑 프로세스가 아닌 경우, 검색 리스트 표출 
                    component.set("v.listCurrentEntry", listCurrentEntry);
                    component.set("v.showSpinner", false);
                }
            }
            else if(state === "ERROR") {
                let errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else if(errors[0] && errors[0].pageErrors[0].message){
                        this.showToast("error", errors[0].pageErrors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
                component.set("v.showSpinner", false);
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description 견본 Excel Paste 
     */
    doHandleExcelpaste_Sample : function(component) {
        console.log('h.6> doHandleExcelpaste_Sample -------------');  
        component.set("v.showSpinner", true);
        // 1. 신규 업로드의 경우 기존 데이터 삭제
        let isNewUpload =  component.get("v.isNewUpload");
        if (isNewUpload){
            component.set("v.setLineItemCode", new Set());
            component.set("v.listLineItem", []);
        }

        // 2. 상품 검색 목록 초기화
        component.set("v.listCurrentEntry", []);
        component.set("v.subMaxPage", 1);
        component.set("v.subPageNumber", 1);

        // 3. 견본 데이터 상품 매핑 시작 
        this.doAutoMappingAI(component);
    },

    /**
     * @description 견본 데이터 상품 매핑
     */
    doAutoMappingAI : function(component) {
        console.log('h.7> doAutoMappingAI -------------'); 
        let idxPasteMapping = component.get("v.idxPasteMapping");
        let listPasteResult = component.get("v.listPasteResult");
        let listPasteResultLength = listPasteResult.length; 

        // 현재 Index와 견본 데이터 리스트 길이 비교 
        // 매핑할 견본 데이터가 남은 경우 매핑 프로세스 진행
        if ( idxPasteMapping < listPasteResultLength){
            let isChangeCondition = component.get("v.isChangeCondition");
            // 첫 검색이거나 검색 조건이 변경되었을 경우 전체 리스트 수신
            if ( isChangeCondition ){
                this.doGetAllEntry(component, listPasteResult[idxPasteMapping], true);
            } else {
                let isAISearch = component.get("v.isAISearch");
                // AI 검색인 경우
                if (isAISearch){
                    this.doSearchAI(component, listPasteResult[idxPasteMapping], true);
                // 일반 검색인 경우
                } else {
                    this.doSearch(component, listPasteResult[idxPasteMapping], true);
                }
            }
        } else {
            // 견본 데이터가 모두 매핑되면 마무리 셋팅 
            component.set("v.idxPasteMapping", 0);
            component.set("v.isExcelExist", true);

            let listLineItem = component.get("v.listLineItem");
            let listLineItemLength = listLineItem.length;
            let oldLastIdx = component.get("v.lastIdx");
            let isNewUpload =  component.get("v.isNewUpload");

            if (isNewUpload){
                component.set("v.currentIdx", 0);
                component.set("v.pageNumber", 1);
            }
            else {
                component.set("v.currentIdx", oldLastIdx+1);
                component.set("v.pageNumber", Math.ceil( ((oldLastIdx+2) == 0 ? 1 : (oldLastIdx+2)) / component.get("v.countPerPage") ));
            }
            component.set("v.lastIdx", listLineItemLength-1);
            component.set("v.isComplete", false);
            this.doReCalcPage(component, false);
        }
    },

    
    /**
     * @description 학습 데이터 API 전송
     * @param {String}  objCurrentEntry 선택된 상품 정보 
     */
    doSendLearningData : function(component, objCurrentEntry) {
        console.log('h.8> doSendLearningData -------------'); 
        component.set("v.showSpinner", true);
        let strSearchInputForLearning = component.get("v.strSearchInputForLearning");
        let objUser = component.get("v.objUser");
        let selectedCenter = component.get("v.selectedCenter"); //2023-08-09 dkbmc백영주대리[인터페이스 파라미터 추가 건]
        console.log('물류센터선택값-->selectedCenter -------------'+selectedCenter);
        console.log('사업부코드값-->biz_dept_cd -------------'+objUser.SU__c);
        let action = component.get("c.doSendLearningData");
        let mapParam = {
            "search_term" : strSearchInputForLearning,
            "emp_code" : objUser.EmployeeNumber,
            "product_code" : objCurrentEntry.Product2.gd_no__c,
            "product_name" : objCurrentEntry.Name,
            "cateL_name" : objCurrentEntry.Product2.fm_LAR_CLS_NM__c,
            "cateM_name" : objCurrentEntry.Product2.fm_MID_CLS_NM__c,
            "lgs_ctr_cd" : selectedCenter, //2023-08-09 dkbmc백영주대리[인터페이스 파라미터(물류센터코드) 추가 건]
            "biz_dept_cd" : objUser.SU__c//2023-08-10 dkbmc백영주대리[인터페이스 파라미터(사업부코드) 추가 건]
        };
        
        action.setParams({
            "mapParam" : mapParam
        });

		action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                
            }
            else if(state === "ERROR") {
                let errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else if(errors[0] && errors[0].pageErrors[0].message){
                        this.showToast("error", errors[0].pageErrors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description 전체 Excel Paste 
     */
    doHandleExcelpaste_Full : function(component) {
        console.log('h.9> doHandleExcelpaste_Full -------------'); 
        // 1. 신규 업로드의 경우 기존 데이터 삭제
        let isNewUpload =  component.get("v.isNewUpload");
        if (isNewUpload){
            component.set("v.setLineItemCode", new Set());
            component.set("v.listLineItem", []);
        }

        // 2. 데이터 가져오기 
        let listPasteResult = component.get("v.listPasteResult");
        let listLineItem = component.get("v.listLineItem");
        let lastIdx = component.get("v.lastIdx");

        // 3. Excel 견본 데이터 삽입 
        for ( let i in listPasteResult) {
            listLineItem.push(listPasteResult[i]);
        }
        
        // 4. 엑셀 열 Visable, 마지막 인덱스 설정
        let listLineItemLength = listLineItem.length;
        let oldLastIdx = lastIdx;
        if (isNewUpload){
            component.set("v.currentIdx", 0);
            component.set("v.pageNumber", 1);
        }
        else {
            component.set("v.currentIdx", oldLastIdx+1);
            component.set("v.pageNumber", Math.ceil( ((oldLastIdx+2) == 0 ? 1 : (oldLastIdx+2)) / component.get("v.countPerPage") ));
        }
        component.set("v.lastIdx", listLineItemLength-1);

        // 5. Paging 재계산 
        this.doReCalcPage(component, false);
        component.set("v.isComplete", false);
    },

    /**
     * @description 데이터를 분할하여 Paging하는 기능
     */
    doRenderPage : function(component) {
        console.log('h.10> doRenderPage -------------'); 
        let pageNumber = component.get("v.pageNumber");
        let countPerPage = component.get("v.countPerPage");
        let listLineItem = component.get("v.listLineItem");
        let pageRecords = listLineItem.slice((pageNumber - 1) * countPerPage, pageNumber * countPerPage);
        component.set("v.pageRecords", pageRecords);

        setTimeout(function(){ 
            component.set("v.showSpinner", false);
        }, 100);

    },

    
    /**
     * @description 데이터가 추가 되면서 현 페이지의 Record가 CountPerPage를 넘어서는 경우 maxpage 재계산 
     * @param {Boolean} isMove 페이지 재계산시 마지막 페이지로 갈 지 여부
     */
    doReCalcPage : function(component, isMove) {
        console.log('h.11> doReCalcPage -------------'); 
        component.set("v.showSpinner", true);
        let countPerPage = component.get("v.countPerPage");
        let listLineItem = component.get("v.listLineItem");
        let lastIdx = component.get("v.lastIdx");

        component.set("v.maxPage", Math.floor((listLineItem.length + (countPerPage - 1)) / countPerPage));
        if ( isMove )
            component.set("v.pageNumber", Math.ceil( ((lastIdx+1) == 0 ? 1 : (lastIdx+1)) / countPerPage ));

        this.doRenderPage(component);
    },


    /**
     * @description 데이터를 추가하거나 Excel Sample Paste를 진행했을 때 마지막 페이지로 이동하는 기능
     */
     doFindPage : function(component) {     
        console.log('h.12> doFindPage -------------');  
        let pageNumber = component.get("v.pageNumber");
        let countPerPage = component.get("v.countPerPage");
        let listLineItem = component.get("v.listLineItem");
        let lastIdx = component.get("v.lastIdx");
        let pageRecords = listLineItem.slice((pageNumber - 1) * countPerPage, pageNumber * countPerPage);
        component.set("v.pageRecords", pageRecords);
        component.set("v.pageNumber", Math.ceil( (lastIdx+1) / countPerPage ));
    },

    
    /**
     * @description 데이터 저장 (1000개 이상의 경우 Chunk)
     */
    doSave : function(component) {
        console.log('h.13> doSave -------------');  
        console.log('Point :: doSave Start !! ');
        this.showToast("info", "데이터를 저장중입니다. 절대 페이지를 이동하지 마세요. 데이터가 유실됩니다." );

        let chunkSize = component.get("v.chunkSize");
        let action = component.get("c.getLineItem");
        action.setParams({
            recordId : component.get("v.recordId"),
            sObjectName : component.get("v.sObjectName")
        });
    
        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {

                let returnValue = response.getReturnValue();
                let listExistLineItem = returnValue.listLineItem;

                // 기존 데이터 확인 존재하면 Delete Chunk
                if ( returnValue.listLineItem.length > 0 ){
                    this.doChunk(component, 'Delete', listExistLineItem, 0, (chunkSize < listExistLineItem.length ? chunkSize : listExistLineItem.length));
                }
                else {
                    let listLineItem = component.get("v.listLineItem");
                    let listSaveTarget = [];
                    let SortOrder = 1;
                    for ( let i = 0 ;  i <listLineItem.length ; i++){
                        if ( listLineItem[i].fm_PriceBookEntryName__c != ''){
                            delete listLineItem[i].Id;
                            listLineItem[i].SortOrder = SortOrder++;
                            listSaveTarget.push(listLineItem[i]);
                        }
                    }
                    // 기존 데이터 없으면 Insert Chunk
                    if ( listSaveTarget.length > 0 ) { 
                        this.doChunk(component, 'Insert', listSaveTarget, 0, (chunkSize < listSaveTarget.length ? chunkSize : listSaveTarget.length));
                    }
                    else { 
                        this.showToast("Error", "저장할 데이터가 없습니다.");
                        component.set("v.isBTNClicked", false);  
                        component.set("v.showSpinner", false);
                        return false;
                    }
                }
            } else if(state === "ERROR") {
                let errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else if(errors[0] && errors[0].pageErrors[0].message){
                        this.showToast("error", errors[0].pageErrors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
                component.set("v.isBTNClicked", false);  
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    /**
     * @description 대량 데이터 저장의 경우 Delete or Insert Chunk 진행
     * @param {String} chunkType  Insert, Delete 구분
     * @param {List<Object>} listTarget Target Object List
     * @param {String} startIdx Chunk startIdx
     * @param {String} endIdx Chunk endIdx
     */
    doChunk : function(component, chunkType, listTarget, startIdx, endIdx) {
        console.log('h.14> doChunk -------------');  
        console.log('Point :: doChunk Start !! ');
        let sObjectName = component.get("v.sObjectName")
        
        let chunkSize = component.get("v.chunkSize ");
        let listTargetLength = listTarget.length;
        let listChunk = listTarget.slice(startIdx, endIdx);

        let action;

        if( sObjectName == 'Quote'){
            action = component.get("c.doChunkQuote");
        }
        else if( sObjectName == 'Opportunity'){
            action = component.get("c.doChunkOppty");
        }

		action.setParams({
            chunkType : chunkType,
            listChunk : listChunk
		});
		action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                // endIdx 가 총 길이와 같아질 때 까지 Chunk
                if(listTargetLength > endIdx) {
                    this.doChunk(component, chunkType, listTarget, (startIdx + chunkSize), 
                                   (endIdx + chunkSize < listTargetLength ? endIdx + chunkSize : listTargetLength));
                }
                // Delete Type인 경우 Insert Chunk도 진행해야하는 지 확인
                else if ( chunkType == 'Delete') {
                    let listLineItem = component.get("v.listLineItem");
                    let listSaveTarget = [];
                    let SortOrder = 1;
                    for ( let i = 0 ;  i <listLineItem.length ; i++){
                        if ( listLineItem[i].fm_PriceBookEntryName__c != ''){
                            delete listLineItem[i].Id;
                            listLineItem[i].SortOrder = SortOrder++;
                            listSaveTarget.push(listLineItem[i]);
                        }
                    }

                    if ( listSaveTarget.length > 0){
                        this.doChunk(component, 'Insert', listSaveTarget, 0, 
                                       ( chunkSize < listSaveTarget.length ? chunkSize : listSaveTarget.length));
                    }
                    else {
                        // 임시저장/저장에 따라 분기
                        let saveType = component.get("v.saveType");
                        if ( saveType == 'Temp' ){
                            this.showToast("success", "성공적으로 임시저장되었습니다.");
                            component.set("v.isBTNClicked", false);  
                            component.set("v.showSpinner", false);
                        }
                        else if ( saveType == 'Final' ){
                            this.showToast("success", "성공적으로 저장되었습니다.");
                            window.location.href = "/" + component.get("v.recordId");
                        }
                    }
                }
                else {
                    // 임시저장/저장에 따라 분기
                    let saveType = component.get("v.saveType");
                    if ( saveType == 'Temp' ){
                        this.showToast("success", "성공적으로 임시저장되었습니다.");
                        component.set("v.isBTNClicked", false);  
                        component.set("v.showSpinner", false);
                    }
                    else if ( saveType == 'Final' ){
                        this.showToast("success", "성공적으로 저장되었습니다.");
                        window.location.href = "/" + component.get("v.recordId");
                    }
                }
                
			} else if(state === "ERROR") {
                let errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else if(errors[0] && errors[0].pageErrors[0].message){
                        this.showToast("error", errors[0].pageErrors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },


    /**
     * @description 세일즈포스 데이트 유형에 맞게 변경
     * @param {*} date 자바스크립트 date 객체
     */
    doParseYYYYMMDD : function(date) {
        console.log('h.15> doParseYYYYMMDD -------------');  
        let mm = date.getMonth() + 1;
        let dd = date.getDate();

        return [date.getFullYear(), (mm > 9 ? "" : "0") + mm, (dd > 9 ? "" : "0") + dd].join("-");
    },

    /**
     * @description 토스트 메세지 출력 이벤트 발생
     * @param {string} type 메세지 유형 (success, error, info, warning, other)
     * @param {string} message 토스트에 보여질 메세지
     */
	showToast : function(type, message) {
        console.log('h.16> showToast -------------'); 
        let evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
})