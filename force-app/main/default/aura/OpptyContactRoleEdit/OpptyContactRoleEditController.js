({
    handlePageChange : function(component, event, helper) {
        component.set("v.showSpinner", true);
        // console.log('ActivityMgmtNew access again- ' + component.get("v.recordId"));
        // var recordId;
        // var pageReference = component.get("v.pageReference");

        // var state = pageReference.state;
        // var context = state.inContextOfRef;
        // if(context.startsWith("1\.")) {
        //     context = context.substring(2);

        //     var addressableContext = JSON.parse(window.atob(context));
        //     console.log("addressableContext : " + JSON.stringify(addressableContext)); 
        //     console.log("record id : " + addressableContext.attributes.recordId);

        //     recordId = addressableContext.attributes.recordId;
        // }
        // component.set("v.parentId", recordId);
        // component.set("v.showSpinner", false);

        component.set("v.showSpinner", true);
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);
        console.log('isMobile ::' +  component.get('v.isMobile'));

		helper.doInit(component, event, helper);
    },

    fnInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        // console.log('ActivityMgmtNew access again- ' + component.get("v.recordId"));
        // var recordId;
        // var pageReference = component.get("v.pageReference");

        // var state = pageReference.state;
        // var context = state.inContextOfRef;
        // if(context.startsWith("1\.")) {
        //     context = context.substring(2);

        //     var addressableContext = JSON.parse(window.atob(context));
        //     console.log("addressableContext : " + JSON.stringify(addressableContext)); 
        //     console.log("record id : " + addressableContext.attributes.recordId);

        //     recordId = addressableContext.attributes.recordId;
        // }
        // component.set("v.parentId", recordId);
        // component.set("v.showSpinner", false);
        
        component.set("v.showSpinner", true);
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);
        console.log('isMobile ::' +  component.get('v.isMobile'));
        
		helper.doInit(component, event, helper);
    },

    
    fnSubmit : function(component, event, helper) {
        component.set("v.showSpinner", true);
    },

    fnSuccess : function(component, event, helper) {
        helper.showToast("success", "영업활동 키맨 역할 이(가) 저장되었습니다.");
        helper.doNavigateParentRecord(component);
    },
    
    fnError : function(component, event, helper) {
        component.set("v.showSpinner", false);
    },

    fnCancel : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.doNavigateParentRecord(component);
    },

})