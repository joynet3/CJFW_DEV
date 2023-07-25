({
    
    /**
     * @description 초기화
     */
    doInit : function(component, event, helper) {
		component.set("v.showSpinner", true);
        var action = component.get("c.doInit");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                let returnVal = response.getReturnValue();
				component.set("v.isIT", returnVal.isIT);
                component.set("v.isSMA", returnVal.isSMA);
                component.set("v.isFS", returnVal.isFS);
                var isIT = returnVal.isIT;
                var isSMA = returnVal.isSMA;
                var isFS = returnVal.isFS;
                
                if(isIT  == false && isSMA  == false && isFS  == false) {
                    helper.showToast('ERROR', '권한이 없는 사용자 입니다. 관리자에게 문의하세요.');
                }
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
        let evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
})