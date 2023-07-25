({
    // SFDC Public Link
    fnFileDownload_Link : function(component, event, helper) {
        window.location.href = component.get("v.FileId");
    },
    // SFDC File Object
    fnFileDownload_File : function(component, event, helper) {
        // window.location.href = "/sfc/servlet.shepherd/document/download/" + component.get("v.FileId");
    },
    // Static Resource (한글명 안됨)
    fnFileDownload_Static : function(component, event, helper) {
        // window.location.href = $A.get('$Resource.정적자원명');
    }, 
})