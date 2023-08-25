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
    //레코드 변경 버튼
    fnChange: function(component, event, helper){
        var recordId = component.get("v.recordId");
        console.log("recordId================>"+recordId);
    },
})