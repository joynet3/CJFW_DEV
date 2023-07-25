({
    // Confirm 버튼 이벤트
	fnConfirm : function(component, event, helper) {
        $A.util.toggleClass(component.find("modalContainer"), "slds-hide");

        // 추가 Action이 존재할 경우 수행
        var confirmAction = component.get("v.confirmAction");
        if(confirmAction) $A.enqueueAction(confirmAction);
	},
    // Cancel 버튼 이벤트
    fnCancel : function(component, event, helper) {
        $A.util.toggleClass(component.find("modalContainer"), "slds-hide");

        // 추가 Action이 존재할 경우 수행
        var cancelAction = component.get("v.cancelAction");
        if(cancelAction) $A.enqueueAction(cancelAction);
    },
})