({ 
    
    doInit : function(component, event, helper) {
		component.set("v.showSpinner", true);
        var action = component.get("c.doGetParentId");

        action.setParams({
			'recordId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                let returnVal = response.getReturnValue();
                component.set("v.parentId", returnVal.parentId);
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
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },

    doNavigateParentRecord : function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId : component.get("v.parentId"),
            slideDevName : "detail"
        });

        navEvt.fire();
    },
})