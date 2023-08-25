({
    /**
     * @description 초기화 (Mobile 여부 확인)
     */
    fnInit : function(component, event, helper) {
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);
        console.log('isMobile ::' +  component.get('v.isMobile'));
        
        let visualforceUrl = '/apex/CJFW_WageTable';
        component.set("v.vfPageUrl", visualforceUrl);  
    },

    /**
     * @description 파일 생성 화면 닫기
     */
    fnCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },

})