({
    // Component Init
    fnInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.doInit(component, event, helper);
        console.log(component.get('v.recordId'));
    },
    // 정렬 이벤트
    fnColumnSorting : function(component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.fnSortData(component, fieldName, sortDirection);
    },
    // EDMSFileViewRefresh_evt Event Handler
    doRefreshView : function(component, event, helper) {
        //alert('do refresh');
        component.set("v.showSpinner", true);
        helper.doInit(component, event, helper);
    },
})