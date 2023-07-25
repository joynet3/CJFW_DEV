/**
 * Created by kw on 2022-12-29.
 */

({
    // Component Init
    fnInit : function(component, event, helper){
        var action = component.get("c.doInit");
        var recordId = component.get("v.recordId");
        var device = $A.get("$Browser.formFactor")
        console.log("::device:: " + device);
        if(device != "DESKTOP"){
            component.set("v.isMobile", true);
            component.set("v.inputSize", "12");
            component.set("v.dateInput", "dateInput");
        }
        console.log("::isMobile:: " + component.get("v.isMobile"));
        console.log("::inputSize:: " + component.get("v.inputSize"));

        action.setParams({
            'recordId' : recordId
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                var strMessage = returnVal.strMessage;
                console.log(returnVal.strStatus);
                if(returnVal.strStatus == 'SUCCESS'){
                    component.set("v.isVisible", true);
                }else{
                    helper.showToast('ERROR', strMessage);
                    $A.get("e.force:closeQuickAction").fire();
                }
                if(returnVal == 'ERROR') {
                    helper.showToast('ERROR', strMessage);
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    // 저장
    registContract : function(component, helper){
        var recordId = component.get("v.recordId");
        console.log('recordId :: '+recordId);
        var contractStartDate = component.get("v.startDate");
        var contractTerm = component.get("v.contractPeriod");
        var ownerExpirationNotice = component.get("v.expirationNoti");
        var description = component.get("v.description");
        var action = component.get("c.registContract");
        action.setParams({
            recordId : recordId,
            contractStartDate : contractStartDate,
            contractTerm : contractTerm,
            ownerExpirationNotice : ownerExpirationNotice,
            description : description,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            console.log('state :   '+state);
            console.log('returnVal :   '+ JSON.stringify(returnVal));
            if(state === "SUCCESS") {
                var strStatus = returnVal.strStatus;
                var strMessage = returnVal.strMessage
                if(strStatus == 'SUCCESS'){
                    helper.showToast('SUCCESS', strMessage);
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                }else if(strStatus == 'ERROR'){
                    helper.showToast('ERROR', strMessage);
                    console.log("Error message: " + strMessage);
                }
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }else if (state === "ERROR") {
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
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },
    // 로딩바 활성화
    showSpinner: function (component) {
        component.set('v.showSpinner', true);
    },
    // 로딩바 비활성화
    hideSpinner: function (component) {
        component.set('v.showSpinner', false);
    },
    // Toast 메시지
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    },
});