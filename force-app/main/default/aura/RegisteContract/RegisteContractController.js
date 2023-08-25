/**
 * Created by kw on 2022-12-28.
 */

({
    // Component Init
    fnInit : function(component, event, helper){
        helper.showSpinner(component)
        console.log('fnInit');
        helper.fnInit(component,event, helper);
    },
    // 
    fnRegistContract :function(component, event, helper) {
        helper.showSpinner(component);
        component.set("v.isVisible", true);
    },
    // 취소 버튼 이벤트
    fnCancel :function(component, event, helper) {
        console.log('fnCancel');
        $A.get("e.force:closeQuickAction").fire();
    },
    // 저장 버튼 이벤트
    fnSave :function(component, event, helper) {
        helper.showSpinner(component);
        var startDate = component.get("v.startDate");
        var contractPeriod = component.get("v.contractPeriod");
        var expirationNoti = component.get("v.expirationNoti");

        console.log('fnSave');
        console.log('startDate  ' + startDate);
        console.log('contractPeriod  ' + contractPeriod)
        console.log('expirationNoti  ' + expirationNoti);
        console.log('description  ' + component.get("v.description"));

        if(startDate == null || contractPeriod == null){
            console.log('startDate/contractPeriod is null');
            helper.showToast('ERROR', '필수 항목들을 모두 입력해주세요.');
        }else if(isNaN(contractPeriod)){
            helper.showToast('ERROR', '계약기간에는 숫자만 입력해 주세요.');
        }else{
            helper.registContract(component, helper);
        }
    },
});