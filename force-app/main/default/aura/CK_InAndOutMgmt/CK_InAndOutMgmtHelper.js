({

    doGetData : function (component, event, helper) {
        var mapParam = {
            "screenStatus" : component.get("v.screenStatus")
        };
        var action = component.get("c.doGetData");
        action.setParams({
            "mapParam" : mapParam
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set('v.listDatalength', returnValue.length);
                for(let i in returnValue){
                    returnValue[i].isOpen = false;
                }
                component.set('v.listData', returnValue);
                component.set("v.mapPicklist", returnValue.mapPicklist);
                component.set("v.ScanedItem", null);

                console.log( ' returnValue :::: ' + JSON.stringify(returnValue) );
                if(returnValue.length > 0) {
                    var countPerPage = component.get("v.countPerPage");
                    component.set("v.maxPage", Math.floor((returnValue.length + (countPerPage - 1)) / countPerPage));
                    console.log("returnValue.length -->" + returnValue.length);
                    console.log("v.maxPage -->" + component.get("v.maxPage"));
                    console.log("countPerPage -->" + countPerPage);
                    component.set("v.pageNumber", 1);
                }
                this.doRenderPage(component);
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        helper.showToast('ERROR', errors[0].message);
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

    doSaveData : function (component, event, helper) {
        let screenStatus = component.get("v.screenStatus");
        let listData = component.get("v.listData");
        let listSubData = [];
       
        this.showToast('info', '데이터를 저장하는 중 입니다. 다른 페이지로 이동하지 마세요.');
        for ( var i in listData){
            if (screenStatus == 'Import'){
                console.log('listData[i] :: ' + JSON.stringify(listData[i]) );
                if (listData[i].ORDER_D__r != null)
                listSubData.push(...listData[i].ORDER_D__r);
                delete listData[i].SHIP_TYP__c;
            }
            else if (screenStatus == 'Export'){
                if (listData[i].RELEASE_D__r != null)
                listSubData.push(...listData[i].RELEASE_D__r);
            }
        } 
        var action = component.get("c.doSaveData");
        
        action.setParams({ 
            "listData" : listData,
            "listSubData" : listSubData
        });
        console.log('222');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                this.showToast('success', '성공적으로 저장되었습니다.');
                this.doGetData(component, event, helper);
                console.log('333');
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
                console.log('444');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast('ERROR', errors[0].message);
                        console.log("Error message: " + errors[0].message);
                    }
                    
                console.log('555');
                }
                else {
                    console.log("Unknown error");
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action); 
    },

    doConfirmData : function(component, event, helper) {
        console.log( '!!!! doConfirmData START !!!!' );

        var action = component.get("c.doConfirmData");

        action.setParams({ 
            "screenStatus" : component.get("v.screenStatus")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            console.log("state", state);
            if(state === "SUCCESS") {
                if( returnValue.resultCode == '0000')
                this.showToast("success", "확정이 정상적으로 진행되었습니다.");
                else 
                this.showToast("error", "확정 오류 발생 [" +  returnValue.resultCode + "] :: " + returnValue.resultMessage );
            }else{
                this.showToast("error", "확정 오류 발생 - UnkwonError");
            }
            component.set("v.showSpinner", false);
            this.doGetData(component, event, helper);
        });
        $A.enqueueAction(action);
    },

    doRenderPage : function(component) {
        let pageNumber = component.get("v.pageNumber");
        let countPerPage = component.get("v.countPerPage");
        let listData = component.get("v.listData");
        let pageRecords = listData.slice((pageNumber - 1) * countPerPage, pageNumber * countPerPage);
        component.set("v.pageRecords", pageRecords);
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

});