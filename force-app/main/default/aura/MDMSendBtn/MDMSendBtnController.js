({
    // Component Init
	fnInit : function(component, event, helper) {
		var recordId = component.get("v.recordId");
	},
    // 취소 버튼 이벤트 
	fnCancel: function(component, event, helper) {
		$A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    // 전송 버튼 이벤트
	fnSendMDM: function(component, event, helper) {
		helper.showSpinner(component);

		var recordId = component.get("v.recordId");

		var action = component.get("c.doSendMDM");

		action.setParams({
            recordId : recordId
		});
        
        helper.showToast('info', "MDM 전송 진행중입니다 잠시만 기다려주세요");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();

				console.log('====================> returnVal : '+JSON.stringify(returnVal));

				if(returnVal.strStatus == 'SUCCESS') {
					helper.showToast('SUCCESS', '전송되었습니다.');

					$A.get("e.force:refreshView").fire();
        			$A.get("e.force:closeQuickAction").fire();
				}else {
					helper.showToast('ERROR', returnVal.strMessage);
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

			helper.hideSpinner(component);
        });

        $A.enqueueAction(action);
		
    },
})