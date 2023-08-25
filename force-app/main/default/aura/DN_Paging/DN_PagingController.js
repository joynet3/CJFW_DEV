({
    // 첫번째 페이지 버튼 이벤트
    firstPage: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
    },
    // 이전 페이지 버튼 이벤트
    prevPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.max(component.get("v.currentPageNumber")-1, 1));
    },
    // 다음 페이지 버튼 이벤트
    nextPage: function(component, event, helper) {
        component.set("v.currentPageNumber", Math.min(component.get("v.currentPageNumber")+1, component.get("v.maxPageNumber")));
    },
    // 마지막 페이지 버튼 이벤트
    lastPage: function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.maxPageNumber"));
    }
})