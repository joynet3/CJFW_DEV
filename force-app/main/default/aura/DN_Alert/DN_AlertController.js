({
	// 닫기버튼 이벤트 
	fnCancel : function(component, event, helper) {
		var showAlert = component.get("v.showAlert");

		if(showAlert) {
			component.set("v.showAlert", !showAlert);
		}
		else {
			component.destroy();
		}
	},
})