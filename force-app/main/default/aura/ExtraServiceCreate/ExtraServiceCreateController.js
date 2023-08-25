({
    /**
     * @description 초기화 (부가서비스 내역 레코드 생성 API 호출)
     */
    fnInit : function(component, event, helper) {
     
        let action = component.get("c.doInit");

		action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                var createExtraService = $A.get("e.force:createRecord");
                console.log(returnValue );
                createExtraService.setParams({
                    entityApiName: "ExtraService__c",
                    recordTypeId : returnValue,
                    defaultFieldValues: {
                        ServiceContents__c: component.get("v.recordId"),
                    }
                });
                createExtraService.fire();
                $A.get("e.force:closeQuickAction").fire();
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
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);    
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
});