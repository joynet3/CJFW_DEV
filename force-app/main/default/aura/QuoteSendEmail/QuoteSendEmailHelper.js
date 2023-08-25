/**
 * Created by 천유정 on 2022-12-26.
 */

({
    /**
     * @description init - 초기화
     * @param {String} recordId 레코드 아이디
     */
    getInitData: function (component, event, helper) {
        console.log('[getInitData] Start =============================>');
        var action = component.get("c.getInitData");
        action.setParams({
            recordId: component.get("v.recordId"),
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[getInitData] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    console.log('[getInitData] strStatus =============================>' + strStatus);
                    var listQuoteLineItems = result['listQuoteLineItems'];
                    var objQuote = result['objQuote'];
                    component.set("v.userEmail", result['userEmail']);
                    component.set("v.userName", result['userName']);
                    component.set("v.listAvailable", result['listField']);
                    component.set("v.listRequiredField", ['fm_ProductCode__c','fm_PriceBookEntryName__c']);
                    component.set("v.listSelected", result['listRequiredField']);
                    component.set("v.listSelectedSave", result['listRequiredField']);

                    component.set("v.listQuoteLineItems", listQuoteLineItems);
                    component.set("v.objQuote", objQuote);
                    console.log('[getInitData] objQuote =============================>' + JSON.stringify(component.get("v.objQuote")));
                    console.log('[getInitData] listQuoteLineItems =============================>' + JSON.stringify(component.get("v.listQuoteLineItems")));
                } else {
                    this.showToast("error", strMessage);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.isShowSpinner", false);
        });
        $A.enqueueAction(action);
        console.log('[getInitData] End ==============================>');
    },

    /**
     * @description Account 검색
     * @param {String} stringKey 사용자가 입력한 키워드값(고객명)
     */
    doSearchAccount: function (component, event, helper, draftValues) {
        this.showSpinner(component);

        console.log('[doSearchAccount] Start =============================>');
        console.log('[doSearchAccount] draftValues =============================>' + draftValues);
        const listSelectedData = component.get("v.listSelectedData");
        var urlInfo = window.location.origin;
        const setSelectedData = new Set();
        for (let i of listSelectedData) {
            setSelectedData.add(i.Id);
        }

        var action = component.get("c.doSearchAccount");
        action.setParams({
            stringKey: draftValues
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[doSearchAccount] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    console.log('[doSearchAccount] strStatus =============================>' + strStatus);
                    var listSearchResult = result['listSearchResult'];
                    var contMap = result['contMap'];
                    if (listSearchResult.length != 0) {
                        for (var data of listSearchResult) {
                            data.Id = data.Id;
                            data.Name = data.Name;
                            data.Phone = data.Phone;
                            data.Address__c = data.Address__c;
                            data.Website = data.Website;
                            data.checked = (setSelectedData.has(data.Id)) ? true : false;
                            if (contMap[data.Id] != null) {
                                data.ContactSize = contMap[data.Id].length;
                                if (data.ContactSize == 1 && contMap[data.Id][0] != null) {
                                    data.ContactId = contMap[data.Id][0].Id;
                                    data.ContactURL = urlInfo + '/lightning/r/Contact/' + contMap[data.Id][0].Id + '/view';
                                    data.ContactName =  contMap[data.Id][0].Name != null? contMap[data.Id][0].Name : null;
                                    data.ContactEmail =  contMap[data.Id][0].Email != null? contMap[data.Id][0].Email : null;
                                }
                            }
                            data.AccountNameURL = urlInfo + '/lightning/r/Account/' + data.Id + '/view';
                        }
                        component.set("v.listSearchResult", listSearchResult);

                        var dataLength = component.get('v.listSearchResult').length;

                        component.set('v.pageNumber', 1);
                        component.set('v.total', dataLength);
                        component.set('v.pages', Math.ceil(dataLength / 10));
                        component.set('v.maxPage', Math.floor((dataLength + 9) / 10));

                        this.doRenderPage(component);
                    }
                } else {
                this.showToast("error", strMessage);
            }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.isShowSpinner", false);
        });
        $A.enqueueAction(action);
        console.log('[doSearchAccount] strStatus =============================>' + JSON.stringify(component.get("v.listSearchResult")));
        console.log('[doSearchAccount] End ==============================>');
    },

    /**
     * @description Save 버튼 클릭 - (Opportunity & Quote 생성 -> Quote Line Item 생성 -> File 생성 & Email 전송)
     */
    doSave: function (component, event, helper) {
        console.log('[doSave] Start =============================>');
        var validMessage = '';
        this.showSpinner(component);

        var batchCount = component.get("v.batchCount");
        var listSelectedData = component.get("v.listSelectedData");
        var listSelectedDataLength = listSelectedData.length;

        console.log('[doSave] listColumn =============================>' + JSON.stringify(component.get("v.listColumn"))); 
        // Batch 처음 시작 : doAccountChunk( component, 총데이터, 시작 인덱스(0), 끝 인덱스(batchCount, 총데이터의 길의 중 큰 값));
        this.doAccountChunk(component, 0);
    },

    /**
     * @description 1. Opportunity & Quote 생성
     * @param {List} listTarget 데이터 (선택한 Account, Contact 목록)
     * @param {Integer} startIdx 시작 인덱스
     * @param {Integer} endIdx 끝 인덱스 (batchCount, 총데이터의 길의 중 큰 값)
     */
    doAccountChunk : function(component, currentAccountIdx) {
        console.log('[doAccountChunk] Start ==============================> [currentAccountIdx] : ' + JSON.stringify(currentAccountIdx));
        component.set("v.currentAccountIdx",  currentAccountIdx);
        let batchCount = component.get("v.batchCount");                                     //1. Opportunity & Quote 생성의 batchCount = 1;
        let LineItemBatchCount = component.get("v.LineItemBatchCount");                     //2. Quote Line Item 생성의 batchCount = 100;
        let SendEmailBatchCount = component.get("v.SendEmailBatchCount");                   //3. File 생성 & Email 전송의 batchCount = 1;

        var listSelectedData = component.get("v.listSelectedData");
        let objCurrentAccount = listSelectedData[currentAccountIdx];                                 //batchCount 에 의해 쪼개진 listTarget 의 데이터 (Batch 실행할 대상)
        let listSelectedDataLength = listSelectedData.length;                                           //listTarget 총 길이

        let listQuoteLineItems = component.get("v.listQuoteLineItems");                     //2. Quote Line Item 생성의 listTarget
        let objQuote = component.get("v.objQuote");                     //2. Quote Line Item 생성의 listTarget

        var sendYN = component.get("v.sendYN");                                             // Email 전송 여부 ( Y, N )
        var fileType = component.get("v.fileType");                                         // File 생성 여부 ( PDF, Excel, N )

        var listCreatedQuote = component.get("v.listCreatedQuote");
        var urlInfo = window.location.origin;

        var action = component.get("c.doCreateQuote");
        action.setParams({
            objQuote: objQuote,
            objCurrentAccount: objCurrentAccount,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[doAccountChunk] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    var listSucceed = result['listSucceed'];
                    this.doCreateLineItem(component, listSucceed[0], listQuoteLineItems, 0, LineItemBatchCount < listQuoteLineItems.length ? LineItemBatchCount : listQuoteLineItems.length);
                    let obj = {
                            'QuoteId'                 : listSucceed[0],
                            'QuoteURL'                : urlInfo + '/lightning/r/Account/' + listSucceed[0] + '/view',
                            'QuoteName'               : '바로가기',
                            'AccountURL'              : urlInfo + '/lightning/r/Account/' + objCurrentAccount.Id + '/view',
                            'AccountName'             : objCurrentAccount.Name,
                    };
                    listCreatedQuote.push(obj);
                    component.set("v.listCreatedQuote", listCreatedQuote);
                } else {
                    this.showToast("error", strMessage);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.isShowSpinner", false);
        });
        $A.enqueueAction(action);
    },

    /**
     * @description 2. Quote Line Item 생성
     * @param {List} listQuote 데이터 (선택한 Account, Contact 목록)
     * @param {List} listTarget 데이터 (Copy 진행할 Quote Line Item)
     * @param {Integer} startIdx 시작 인덱스
     * @param {Integer} endIdx 끝 인덱스 (batchCount, 총데이터의 길의 중 큰 값)
     */
    doCreateLineItem : function(component, quoteId, listTarget, startIdx, endIdx) {
        console.log('[doCreateLineItem] Start ==============================> [startIdx] : ' + JSON.stringify(startIdx) + ' [endIdx] : ' + JSON.stringify(endIdx));

        let LineItemBatchCount = component.get("v.LineItemBatchCount");                 //2. Quote Line Item 생성의 batchCount = 100;
        let SendEmailBatchCount = component.get("v.SendEmailBatchCount");               //3. File 생성 & Email 전송의 batchCount = 1;

        let listTargetLength = listTarget.length;                                       //listTarget 총 길이
        let listChunkLineItem = listTarget.slice(startIdx, endIdx);                     //batchCount 에 의해 쪼개진 listTarget 의 데이터 (Batch 실행할 대상)

        let isFinished = false;

        var sendYN = component.get("v.sendYN");                                             // Email 전송 여부 ( Y, N )
        var fileType = component.get("v.fileType");                                         // File 생성 여부 ( PDF, Excel, N )
        var currentLineItemIdx = component.get("v.currentLineItemIdx");                     // File 생성 여부 ( PDF, Excel, N )

        var progress = component.get('v.progress');

        console.log('[doCreateLineItem] ==============================> [quoteId] : ' + JSON.stringify(quoteId));

        var action = component.get("c.doCreateQuoteLineItem");
        action.setParams({
            listChunkQuote: quoteId,
            listChunkLineItem: listChunkLineItem,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[doCreateLineItem] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    if(listTargetLength > endIdx) {
                        component.set('v.currentLineItemIdx', (endIdx + LineItemBatchCount < listTargetLength ? endIdx + LineItemBatchCount : listTargetLength));
                        this.doCreateLineItem(component, quoteId, listTarget, (startIdx + LineItemBatchCount),
                                       (endIdx + LineItemBatchCount < listTargetLength ? endIdx + LineItemBatchCount : listTargetLength));
                    } else {
                        if (fileType != 'N' ) {
                            this.doCreateFileAndSendEmail(component, quoteId);
                        }
                        else {
                            let listSelectedData = component.get("v.listSelectedData");
                            let currentAccountIdx = component.get("v.currentAccountIdx");
                            // Progress Bar 퍼센트 채우기
                            component.set('v.progress', progress === 100 ? 0 : progress + (100 / listSelectedData.length ));
                            if ( listSelectedData.length > currentAccountIdx+1) {
                                this.doAccountChunk(component, currentAccountIdx + 1);
                                component.set('v.currentLineItemIdx', listTargetLength > LineItemBatchCount? LineItemBatchCount : 0);
                            }
                            else {
                               // 최종완료
                               component.set("v.allComplete", true);
                               this.showToast('success', '성공적으로 작업이 완료되었습니다.');

                            }
                        }
                        isFinished = true;
                    }
                } else {
                    this.showToast("error", strMessage);
                }
                return isFinished;
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.isShowSpinner", false);
        });
        $A.enqueueAction(action);
    },

    /**
     * @description 2. File 생성 & Email 전송
     * @param {List} listTarget 데이터 (Copy 진행할 Quote Line Item)
     * @param {Integer} startIdx 시작 인덱스
     * @param {Integer} endIdx 끝 인덱스 (batchCount, 총데이터의 길의 중 큰 값)
     */
    doCreateFileAndSendEmail : function(component, quoteId) {
        console.log('[doCreateFileAndSendEmail] Start !!!');
        console.log('[doCreateFileAndSendEmail] ==============================> [quoteId] : ' + JSON.stringify(quoteId));

        let listSelectedData = component.get("v.listSelectedData");
        let currentAccountIdx = component.get("v.currentAccountIdx");
        let LineItemBatchCount = component.get("v.LineItemBatchCount");                 //2. Quote Line Item 생성의 batchCount = 100;
        let QuoteLineItemLength = component.get("v.listQuoteLineItems").length;

        console.log('[doCreateFileAndSendEmail] ==============================> [listSelectedData] : ' + JSON.stringify(listSelectedData));
        console.log('[doCreateFileAndSendEmail] ==============================> [currentAccountIdx] : ' + JSON.stringify(currentAccountIdx));

        let objCurrentAccount = listSelectedData[currentAccountIdx];

        console.log('[doCreateFileAndSendEmail] ==============================> [objCurrentAccount] : ' + JSON.stringify(objCurrentAccount));

        let listSelected = component.get("v.listSelected");

        var progress = component.get('v.progress');
        var currentEmailIdx = component.get('v.currentEmailIdx');

        var listCreatedQuote = component.get("v.listCreatedQuote");
        var urlInfo = window.location.origin;

        var action = component.get("c.doCreateFileAndSendEmail");
        action.setParams({
            sendYN : component.get("v.sendYN"),
            fileType : component.get("v.fileType"),
            contentHeader: component.get("v.emailSubject"),
            contentBody: component.get("v.emailContent"),
            objCurrentAccount : objCurrentAccount,
            recordId : quoteId,
            listSelected : listSelected.toString()
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[doCreateFileAndSendEmail] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    var SendFailedAddress = result['SendFailedAddress'];
                    for (var data of listCreatedQuote) {
                        if (data.QuoteId === quoteId) {
                            data.EmailAddress = objCurrentAccount.ContactEmail,
                            data.IsSucceedSendEmail = this.isNullCheck(SendFailedAddress) ? '성공' : '실패'
                        }
                    }
                    component.set("v.listCreatedQuote", listCreatedQuote);
                    // Progress Bar 퍼센트 채우기
                    component.set('v.progress', progress === 100 ? 0 : progress + (100 / listSelectedData.length ));
                    component.set("v.currentEmailIdx", currentEmailIdx+1);
                    if ( listSelectedData.length > currentAccountIdx+1) {
                        this.doAccountChunk(component, currentAccountIdx + 1);
                        component.set('v.currentLineItemIdx', QuoteLineItemLength > LineItemBatchCount? LineItemBatchCount : 0);
                    }
                    else {
                        // 최종완료
                       component.set("v.allComplete", true);
                       this.showToast('success', '성공적으로 작업이 완료되었습니다.');

                    }
                } else {
                    this.showToast("error", strMessage);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.isShowSpinner", false);
            //component.set("v.isShowProgressBar", false);
        });
        $A.enqueueAction(action);
    },

    /**
     * @description Account 검색 목록 - DN_Paging
     */
    doRenderPage: function(component) {
        console.log('[doRenderPage] Start =============================>');
        var listSearchResult = component.get('v.listSearchResult');
        var pageNumber = component.get('v.pageNumber');
        var pageRecords = listSearchResult.slice((pageNumber - 1) * 10, pageNumber * 10);

        component.set('v.pageRecords', pageRecords);
        component.set('v.isShowSpinner', false);
    },

    /**
     * @description Account 선택 목록 - DN_Paging
     */
    doRenderSelectedPage: function(component) {
        console.log('[doRenderSelectedPage] Start =============================>');
        var listSelectedData = component.get('v.listSelectedData');
        console.log('[doRenderSelectedPage] istSelectedData.length =============================>' + listSelectedData.length);
        var SelectedPageNumber = component.get('v.SelectedPageNumber');
        var SelectedPageRecords = listSelectedData.slice((SelectedPageNumber - 1) * 10, SelectedPageNumber * 10);
        component.set('v.SelectedMaxPage', Math.floor((listSelectedData.length + 9) / 10));

        component.set('v.SelectedPageRecords', SelectedPageRecords);
        console.log('[doRenderSelectedPage] SelectedPageRecords.length =============================>' + SelectedPageRecords.length);
        component.set('v.isShowSpinner', false);
    },

    /**
     * @description countPage(현재 페이지 위치) Value 변경 시, 각 Attributes 및 버튼 Disability 설정
     */
    doSetDisability: function (component, event, helper) {
        console.log('[doSetDisability] Start =============================>');
        /*
            isActiveNextBtn : 'Next' 버튼 활성화 여부
            isActiveSaveBtn : 'Save' 버튼 활성화 여부
        */
        var listSelectedData = component.get("v.listSelectedData");             //Account 선택 목록
        var currentPage = component.get("v.countPage");                         //현재 페이지 위치
        var fileType = component.get("v.fileType");                             //파일 생성 여부 선택값
        var sendYN = component.get("v.sendYN");                                 //이메일 전송 여부 선택값

        console.log('[doSetDisability] countPage =============================>' + currentPage);

        if (currentPage === 1) {
            component.set("v.isActiveNextBtn", true);
            component.set("v.isActiveSaveBtn", false);
        } else if (currentPage === 2) {
            if (this.isNullCheck(listSelectedData)) {
                component.set("v.isActiveNextBtn", false);
            } else {
                component.set("v.isActiveNextBtn", true);
            }
            component.set("v.isActiveSaveBtn", false);
        } else if (currentPage === 3) {
            if (this.isNullCheck(listSelectedData)) {
                component.set("v.isActiveNextBtn", false);
            } else {
               if (sendYN === 'Y') {
                   var isAllEmailSet = true;
                   for (var data of listSelectedData) {
                       if (this.isNullCheck(data.ContactEmail)) {
                           isAllEmailSet = false;
                       }
                   }
                   component.set("v.isActiveNextBtn", isAllEmailSet);
                   component.set("v.isActiveSaveBtn", false);
               } else {
                   component.set("v.isActiveSaveBtn", true);
               }
            }
        } else if (currentPage === 4) {
            component.set("v.isActiveNextBtn", true);
            component.set("v.isActiveSaveBtn", true);
        }
        console.log('[doSetDisability] isActiveNextBtn =============================>' + component.get("v.isActiveNextBtn"));
        console.log('[doSetDisability] isActiveSaveBtn =============================>' + component.get("v.isActiveSaveBtn"));

    },

    /**
     * @description Toast 메시지 출력
     */
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },

    /**
     * @description Null , Undefined , '' 체크
     */
    isNullCheck : function(value){
        if(value == null || value == undefined || value == "" || value == '' || value == [] || value == {}){
            return true;
        }
        else{
            return false;
        }
    },

    /**
     * @description this will show the <lightning:spinner />
     */
    showSpinner: function (component) {
        component.set('v.isShowSpinner', true);
    },

    /**
     * @description this will hide the <lightning:spinner />
     */
    hideSpinner: function (component) {
        component.set('v.isShowSpinner', false); 
    },
});