({
    /**
     * 초기 데이터
     * @param {*} component 
     */

    
    doSyncMaster : function(component, event, helper) {
        let listTarget = component.get("v.listTarget");
        console.log( 'listTarget1 : ' + JSON.stringify(listTarget));

        if ( listTarget.length > 0){
            console.log( 'listTarget[0]:::' + listTarget[0]); 
            if( listTarget[0] =='ORDER'){
                listTarget.shift();
                this.doSyncOrderData(component, event, helper);
            }
            else if( listTarget[0] =='RELEASE'){
                listTarget.shift();
                this.doSyncReleaseData(component, event, helper);
            }
            else if( listTarget[0] =='STOCK'){
                listTarget.shift();
                this.doSyncStockData(component, event, helper);
            }
            console.log( 'listTarget3 : ' + JSON.stringify(listTarget));

            component.set("v.listTarget", listTarget);
        }
        else {

            this.showToast("info", "데이터 동기화가 완료되었습니다. 잠시 후 프로세스가 종료됩니다.");
            setTimeout(
                $A.getCallback(function() {
                    var homeEvent = $A.get("e.force:navigateToObjectHome");
                    homeEvent.setParams({
                        "scope": component.get("v.sObjName")
                    });
                    homeEvent.fire();
                }), 5000
            );
            
    
        }

    },

    doSyncOrderData : function(component, event, helper) {
        console.log( '!!!! doSyncOrderData START !!!!' );
        let mapCondition = component.get("v.mapCondition");
        var action = component.get("c.doSyncOrderData");
		action.setParams({
            paramDate : mapCondition.pOrderDate
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            console.log("state", state);
            console.log("returnValue", JSON.stringify(returnValue));
            if(state === "SUCCESS") {
                if( returnValue.resultCode == '0000')
                this.showToast("success", "입고 데이터 동기화가 정상적으로 진행되었습니다.");
                else 
                this.showToast("error", "입고 동기화 오류 발생 [" +  returnValue.resultCode + "] :: " + returnValue.resultMessage );
            }else{
                this.showToast("error", "입고 동기화 오류 발생 - UnkwonError");
            }
                this.doSyncMaster(component, event, helper);
        });
        $A.enqueueAction(action);
    },

    
    doSyncReleaseData : function(component, event, helper) {
        console.log( '!!!! doSyncReleaseData START !!!!' );
        
        let mapCondition = component.get("v.mapCondition");
        
        var action = component.get("c.doSyncReleaseData");
		action.setParams({
            paramDate : mapCondition.pReleaseDate
		});

        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            console.log("state", state);
            if(state === "SUCCESS") {
                if( returnValue.resultCode == '0000')
                this.showToast("success", "출고 데이터 동기화가 정상적으로 진행되었습니다.");
                else 
                this.showToast("error", "출고 동기화 오류 발생 [" +  returnValue.resultCode + "] :: " + returnValue.resultMessage );
            }else{
                this.showToast("error", "출고 동기화 오류 발생 - UnkwonError");
            }
            this.doSyncMaster(component, event, helper);
        });
        $A.enqueueAction(action);
    },

    doSyncStockData : function(component, event, helper) {
        console.log( '!!!! doSyncStockData START !!!!' );

        var action = component.get("c.doSyncStockData");
		action.setParams({

		});

        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            console.log("state", state);
            if(state === "SUCCESS") {
                if( returnValue.resultCode == '0000')
                this.showToast("success", "재고 데이터 동기화가 정상적으로 진행되었습니다.");
                else 
                this.showToast("error", "재고 동기화 오류 발생 [" +  returnValue.resultCode + "] :: " + returnValue.resultMessage );
            }else{
                this.showToast("error", "재고 동기화 오류 발생 - UnkwonError");
            }
            this.doSyncMaster(component, event, helper);
        });
        $A.enqueueAction(action);
    },

    doReConfirm : function(component, event, helper) {
        console.log( '!!!! doReConfirm START !!!!' );

        let sObjName = component.get("v.sObjName");
        let sObjLabel = component.get("v.sObjLabel");;
        var action = component.get("c.doReConfirm");

		action.setParams({
            sObjName : sObjName
		});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            console.log("state", state);
            if(state === "SUCCESS") {
                if( returnValue.resultCode == '0000')
                this.showToast("success",  sObjLabel + " 재확정이 정상적으로 진행되었습니다.");
                else 
                this.showToast("error",  sObjLabel + " 재확정 오류 발생 [" +  returnValue.resultCode + "] :: " + returnValue.resultMessage );
            }else{
                this.showToast("error",  sObjLabel + " 재확정 오류 발생 - UnkwonError");
            }
            
            this.showToast("info", sObjLabel + " 재확정이 완료되었습니다. 잠시 후 프로세스가 종료됩니다.");
            setTimeout(
                $A.getCallback(function() {
                    var homeEvent = $A.get("e.force:navigateToObjectHome");
                    homeEvent.setParams({
                        "scope": component.get("v.sObjName")
                    });
                    homeEvent.fire();
                }), 5000
            );
            
        });
        $A.enqueueAction(action);
    },


    doClose : function(component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");

        homeEvent.setParams({
            "scope": component.get("v.sObjName")
        });
        homeEvent.fire();
    },

    // 컨펌 모달
    doCreateConfirmComponent : function(component, param) {
        $A.createComponent(
            "c:DN_Confirm",
            {
                "sHeader"       : param.sHeader,
                "sContent"      : param.sContent,
                "sConfirmBtn"   : param.sConfirmBtn,
                "sCancelBtn"    : param.sCancelBtn,
                "confirmAction" : param.confirmAction,
                "cancelAction" : param.cancelAciton,
            },
            function(cCommonConfirm, status, errorMessage) {
                if(status === "SUCCESS") {
                    // callback action
                    component.set("v.CommonConfirm", cCommonConfirm);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }   
        );

        // component.destroy();
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