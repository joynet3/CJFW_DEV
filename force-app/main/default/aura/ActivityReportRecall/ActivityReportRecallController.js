({
    /**
     * @description : 초기화 (모바일 여부 확인)
     */
    fnInit : function(component, event, helper) {
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);
        console.log('isMobile ::' +  component.get('v.isMobile'));
        helper.getInitData(component);        
    },

   /**
    * @description : 주유비 승인 회수
    */
    fnRecall: function (component, event, helper) {
        helper.doRecall(component);        
    },

   /**
    * @description : 주유비 승인 회수 화면 닫기
    */
    fnCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },

})