({
    /**
     * @description : 초기화 (회수 가능 여부 체크)
     */
    getInitData : function(component) {
        component.set("v.showSpinner", true);
        var action = component.get("c.getInitData");

		action.setParams({
            recordId : component.get("v.recordId")
		});
		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();

                let objActivityReport = returnValue.objActivityReport;

                if ( objActivityReport.ApprovalStatus__c != 'Request' ){
                    this.showToast("error", "승인요청 상태서만 회수가 가능합니다.");
                    this.doCloseModal(component);
                } 
                
			} else if(state === "ERROR") {
                var errors = response.getError();
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
            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
    },

    /**
     * @description : 주유비 승인 회수 진행
     */
    doRecall : function(component) {
        component.set("v.showSpinner", true);
        var action = component.get("c.doRecall");
		action.setParams({
            recordId : component.get("v.recordId")
		});
		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                this.showToast("success", "성공적으로 회수되었습니다.");
                this.doCloseModal(component);
            }else if(state === "ERROR") {
                var errors = response.getError();
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
                component.set("v.isBTNClicked", false); 
                component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },

   /**
    * @description : 주유비 승인 회수 화면 닫기
    */
    doCloseModal : function(component, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },
    
    /**
     * @description 토스트 메세지 출력 이벤트 발생
     * @param {string} type 메세지 유형 (success, error, info, warning, other)
     * @param {string} message 토스트에 보여질 메세지
     */
	showToast : function(type, message) {
        let evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
})