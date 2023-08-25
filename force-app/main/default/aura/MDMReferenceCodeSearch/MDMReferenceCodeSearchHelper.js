({
	// Component Init
    doInit : function(component, event, helper) {
		helper.showSpinner(component);

		var action = component.get("c.doInit");
		
		action.setParams({
			"strGroupId":component.get("v.groupId"),
			"inputText":component.get("v.inputText")
		});

		action.setCallback(this, function(response) {
			var state = response.getState();

			if(state === "SUCCESS") {
				var returnVal = response.getReturnValue();

				var strStatus = returnVal.strStatus;
				var strMessage = returnVal.strMessage;

				//console.log('============> returnVal : '+JSON.stringify(returnVal));

				if(strStatus == "SUCCESS") {
					component.set("v.listSearchResult", returnVal.listSearchResult);					
					component.set("v.value", returnVal.code);
					component.set("v.id", returnVal.inputId);
					component.set("v.inputTextLabel", returnVal.inputTextLabel);
				}else {
					helper.showToast(strStatus, strMessage);
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
	// 조회
	doSearch : function(component, event, helper) {
		helper.showSpinner(component);
		
		var action = component.get("c.doSearch");
		
		action.setParams({
			"strGroupId" : component.get("v.groupId"),
			"searchWord" : component.get("v.searchWord"),
		});

		action.setCallback(this, function(response) {
			var state = response.getState();
			var toast = $A.get("e.force:showToast");
						
			if(state === "SUCCESS") {
				var returnVal = response.getReturnValue();

				var strStatus = returnVal.strStatus;
				var strMessage = returnVal.strMessage;

				if(strStatus == "SUCCESS") {
					var viewCount = component.get("v.viewCount");

					component.set("v.totalCount", returnVal.listSearchResult.length);

					if(returnVal.listSearchResult.length <= viewCount){
						component.set("v.curCount", returnVal.listSearchResult.length);	
					}
					else{
						component.set("v.curCount", viewCount);	
					}

					component.set("v.listSearchResult", returnVal.listSearchResult);
				}else {
					helper.showToast(strStatus, strMessage);
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
	// Toast 메시지
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
	// 로딩바 활성화
	showSpinner: function (component) {
		/* this will show the <lightning:spinner /> */
		component.set('v.isShowSpinnerSearchModal', true);
	},
	// 로딩바 비활성화
	hideSpinner: function (component) {
		/* this will hide the <lightning:spinner /> */
		component.set('v.isShowSpinnerSearchModal', false);
	},
})