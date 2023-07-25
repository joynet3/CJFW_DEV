({

    /**
     * @description 초기화 (Mobile의 경우 Upload 불가처리)
     */
    fnInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);
        component.set("v.selectedTab", 'Summary');
        helper.doInit(component);
    },

    /**
     * @description 시산 업로드 화면 열기
     */
     fnOpenUpload : function(component, event, helper) {
        helper.doOpenUpload(component, event, helper);
    },

    /**
     * @description 시산 업로드 완료 후 초기화 및 데이터 재세팅
     */
     fnHandleExcelpaste : function(component, event, helper) {
        let isComplete = component.get("v.isComplete");
        if( isComplete){
            component.set("v.isComplete", false);
            helper.doInit(component);
        }
    },    

    /**
     * @description 선택된 탭 변경시 데이터 재세팅
     */
    fnActive : function(component, event, helper) {
        let selectedTab = event.getSource().get('v.id');
        component.set("v.selectedTab", selectedTab);
        helper.doInit(component);
    },
})