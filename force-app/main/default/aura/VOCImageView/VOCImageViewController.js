({
    // Component Init
	fnInit : function(component, event, helper) {

		component.set("v.showSpinner", true);
        
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
        component.set('v.isMobile', true);
        
        var action = component.get("c.doInit");

		action.setParams({
			'recordId' : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                var strStatus = returnVal.strStatus;
                var strMessage = returnVal.strMessage;

				console.log('=======================> SUCCESS');
				if(strStatus == 'SUCCESS') {
					component.set('v.listImage', returnVal.listImage);

				}else {
					helper.showToast(strStatus, strMessage);
				}
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                let errors = response.getError();

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
    // 이미지 클릭 이벤트
	clickDetail : function(component, event, helper) {
		var detailURL = event.target.src;

		console.log('==============> event.target : '+JSON.stringify(event.target));
		console.log('================> detailURL : '+detailURL);
		component.set("v.detailURL",detailURL);
		component.set("v.isOpenPopup", true);
	},
    // 닫기 버튼 이벤트
	fnCloseModal : function(component, event, helper) {
		component.set("v.isOpenPopup", false);
	},

})