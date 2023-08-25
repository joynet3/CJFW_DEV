({
    /**
     * @description : 초기화 (모바일 여부 확인)
     */
    fnInit : function(component, event, helper) {        
        // component.set("v.showSpinner", true);
        // if ( $A.get("$Browser.formFactor") != 'DESKTOP')
        //     component.set('v.isMobile', true);
        // console.log('isMobile ::' +  component.get('v.isMobile'));
        helper.doInit(component);
    },
    
})