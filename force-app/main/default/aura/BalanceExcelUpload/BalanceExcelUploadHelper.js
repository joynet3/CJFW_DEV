({
    /**
     * @description 초기화 (기업로드 데이터 화면 셋팅)
     */
    doInit : function(component, saveType) {
        component.set("v.showSpinner", true); 

        var action = component.get("c.doInit");
        let recordId = component.get("v.recordId");
        let balanceType = component.get("v.balanceType");
        action.setParams({
            recordId : recordId,
            balanceType : balanceType 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {           
                let returnValue = response.getReturnValue();
                let objBalance = returnValue.objBalance;     

                let listBalanceDetail_SUM = returnValue.listBalanceDetail_SUM;  
                let listBalanceDetail_IRR = returnValue.listBalanceDetail_IRR;  
                let listBalanceDetail_PL = returnValue.listBalanceDetail_PL;  
 
                let regex = new RegExp("[\(\)\ ]","gi");
                if( Array.isArray(listBalanceDetail_SUM) && listBalanceDetail_SUM.length != 0){
                    component.set("v.listPasteTempResultSum", listBalanceDetail_SUM); 
                    component.set("v.isExistSum", true); 
                }
                if( Array.isArray(listBalanceDetail_IRR) && listBalanceDetail_IRR.length != 0){
                    component.set("v.listPasteTempResultIRR", listBalanceDetail_IRR); 
                    console.log('listBalanceDetail_IRR[45] ::' + JSON.stringify(listBalanceDetail_IRR[45]));
                    objBalance.IRRPct__c = listBalanceDetail_IRR[45]['Column2__c'].replace(regex, "");
                    component.set("v.isExistIRR", true); 
                }
                if( Array.isArray(listBalanceDetail_PL) && listBalanceDetail_PL.length != 0){
                    component.set("v.listPasteTempResultPL", listBalanceDetail_PL); 
                    objBalance.SalesRevenue__c = listBalanceDetail_PL[1]['Column2__c'].replace(regex, "");
                    objBalance.PurchasingCost__c = listBalanceDetail_PL[2]['Column2__c'].replace(regex, "");
                    objBalance.PurchasingCostPct__c = listBalanceDetail_PL[3]['Column2__c'].replace(regex, "");
                    objBalance.ManufacturingCost__c = listBalanceDetail_PL[4]['Column2__c'].replace(regex, "");
                    objBalance.ManufacturingCostPct__c = listBalanceDetail_PL[5]['Column2__c'].replace(regex, "");
                    objBalance.SalesProfit__c = listBalanceDetail_PL[14]['Column2__c'].replace(regex, "");
                    objBalance.SalesProfitPct__c = listBalanceDetail_PL[15]['Column2__c'].replace(regex, "");
                    objBalance.MgmtProfit__c = listBalanceDetail_PL[22]['Column2__c'].replace(regex, "");
                    objBalance.MgmtProfitPct__c = listBalanceDetail_PL[23]['Column2__c'].replace(regex, "");
                    component.set("v.isExistPL", true); 
                }
                component.set("v.objBalance", objBalance); 
                // console.log( ' mapBalance ::: ' + JSON.stringify(mapBalance));
                component.set("v.showSpinner", false); 
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

    /**
     * @description 데이터 저장
     */
    doSave : function(component, saveType) {
        component.set("v.showSpinner", true); 

        let recordId = component.get("v.recordId");
        let balanceType = component.get("v.balanceType");
        let objBalance = component.get('v.objBalance');

        console.log (' objBalance :: ' + JSON.stringify(objBalance) );
        var action = component.get("c.doSave");
        action.setParams({
            recordId : recordId,
            balanceType : balanceType,
            "objBalance" : component.get("v.objBalance"),
            "listBalanceDetail_SUM" : component.get("v.listPasteTempResultSum"),
            "listBalanceDetail_IRR" : component.get("v.listPasteTempResultIRR"),
            "listBalanceDetail_PL" : component.get("v.listPasteTempResultPL")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.showSpinner", false);
                component.set("v.isComplete", true);
                component.set("v.isOpen", false);    
                this.showToast("success", "성공적으로 저장되었습니다.");
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
    
    /**
     * @description 시산표 업로드 화면 닫기
     */
    doCloseModal : function(component, helper) {
        component.set("v.isOpen", false);
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