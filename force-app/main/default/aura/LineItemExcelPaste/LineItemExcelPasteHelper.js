({
    
    doInit : function (component, event, helper) {
        var action = component.get("c.doInit");
        action.setParams({
            "sObjectName" : component.get("v.sObjectName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log('returnValue ::: '+ JSON.stringify(returnValue) );

                component.set("v.listAvailable", returnValue.listField);
                component.set("v.listRequiredField", returnValue.listRequiredField);
                component.set("v.listSelected", returnValue.listRequiredField);
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast('ERROR', errors[0].message);
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
    },

    
    doCheckValid : function (component, event, helper) {
        console.log(' pricebookId :: ' +  component.get("v.pricebookId"));
        let listValidTargetData = component.get("v.listValidTargetData");
        let isNewUpload = component.get("v.isNewUpload");
        let listLineItem = component.get("v.listLineItem");
        let listExistProductCode = [];
        for ( let i in listLineItem){
            listExistProductCode.push(listLineItem[i].fm_ProductCode__c);
        }
        console.log( 'listExistProductCode ::: ' + listExistProductCode);

        var action = component.get("c.doCheckValid");
        action.setParams({
            "pricebookId" : component.get("v.pricebookId"),
            "recordId" : component.get("v.recordId"),
            "sObjectName" : component.get("v.sObjectName"),
            "listValidTargetData" : listValidTargetData,
            "listExistProductCode" : isNewUpload ? [] : listExistProductCode
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {;
                let returnValue = response.getReturnValue();

                let isValid = returnValue.isValid;
                let listResultData = returnValue.listResultData;
                console.log ( 'return.size :: '+ listResultData.length);
                console.log(' isValid ::: ' + isValid ); 

                component.set("v.isValid", isValid);
                
              
                if ( isValid ){
                    component.set("v.listPasteTempResult_Full",  listResultData);
                    console.log( ' listPasteTempResult_Full ::: ' + JSON.stringify(listResultData)); 
                }
                else {
                    for( let i in listResultData){
                        listResultData[i] = Object.values(listResultData[i]);
                    }
                    component.set("v.listViewData_Full",  listResultData);
                    this.showToast('ERROR', listResultData.length + '건의 오류가 발생하였습니다.');
                }

                console.log( ' listViewData_Full ::: ' +  component.get("v.listViewData_Full") );

                this.doReCalcPage_Full(component);
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast('ERROR', errors[0].message);
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action); 
    },

    /**
     * @description Paste 완료 및 선택된 상품리스트에 반영
     */
    doSave : function(component, saveType) {
        component.set("v.showSpinner", true); 
        let openTab = component.get("v.openTab");
        if ( openTab == 'Sample'){
            let listPasteTempResult_Sample = component.get("v.listPasteTempResult_Sample");
            component.set("v.listPasteResult", listPasteTempResult_Sample);
            component.set("v.listPasteTempResult_Sample", []);
        }
        else { 
            // 유효성 체크가 정상적이지 않을 경우 에러메세지
            if(!component.get("v.isValid") ){
                this.showToast('ERROR', '데이터가 정상적으로 렌더링되어 있지 않습니다.');
                component.set("v.showSpinner", false);
                return false;
            }
            let listPasteTempResult_Full = component.get("v.listPasteTempResult_Full");
            component.set("v.listPasteResult", listPasteTempResult_Full);
            component.set("v.listPasteTempResult_Full", []);
            console.log ( 'listPasteTempResult_Full :: ' + JSON.stringify(listPasteTempResult_Full));
        }
        component.set("v.showSpinner", false);
        component.set("v.isComplete", true);
        component.set("v.isOpen", false);    
    },

    doCloseModal : function(component, helper) {
        component.set("v.isOpen", false);
    },


    /**
     * 데이터를 분할하여 Paging하는 기능
     * @param {*} component 
     */
    doReCalcPage_Sample : function(component) {
        let countPerPage_Sample = component.get("v.countPerPage_Sample");
        let listPasteTempResult_Sample = component.get("v.listPasteTempResult_Sample");

        component.set("v.maxPage_Sample", Math.floor((listPasteTempResult_Sample.length + (countPerPage_Sample - 1)) / countPerPage_Sample));
        let maxPage_Sample = component.get("v.maxPage_Sample");
        component.set("v.pageNumber_Sample", maxPage_Sample);
        this.doRenderPage_Sample(component);
    },

    doRenderPage_Sample : function(component) {
        let pageNumber_Sample = component.get("v.pageNumber_Sample");
        let countPerPage_Sample = component.get("v.countPerPage_Sample");
        let listPasteTempResult_Sample = component.get("v.listPasteTempResult_Sample");
        let pageRecords_Sample = listPasteTempResult_Sample.slice((pageNumber_Sample - 1) * countPerPage_Sample, pageNumber_Sample * countPerPage_Sample);
        component.set("v.pageRecords_Sample", pageRecords_Sample);
        component.set("v.showSpinner", false);
    },

    /**
     * 데이터를 분할하여 Paging하는 기능
     * @param {*} component 
     */
    doReCalcPage_Full : function(component) {
        let countPerPage_Full = component.get("v.countPerPage_Full");
        let listViewData_Full = component.get("v.listViewData_Full");

        component.set("v.maxPage_Full", Math.floor((listViewData_Full.length + (countPerPage_Full - 1)) / countPerPage_Full));
        component.set("v.pageNumber_Full", 1);
        this.doRenderPage_Full(component);
    },

    doRenderPage_Full : function(component) {
        let pageNumber_Full = component.get("v.pageNumber_Full");
        let countPerPage_Full = component.get("v.countPerPage_Full");
        let listViewData_Full = component.get("v.listViewData_Full");
        let pageRecords_Full = listViewData_Full.slice((pageNumber_Full - 1) * countPerPage_Full, pageNumber_Full * countPerPage_Full);
        component.set("v.pageRecords_Full", pageRecords_Full);
        component.set("v.showSpinner", false);
    },

    /**
     * @description 토스트 메세지 출력 이벤트 발생
     * @param {string} type 메세지 유형 (success, error, info, warning, other)
     * @param {string} message 토스트에 보여질 메세지
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
})