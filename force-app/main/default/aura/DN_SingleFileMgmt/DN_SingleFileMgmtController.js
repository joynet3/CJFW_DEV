({
    fnInit : function(component, event, helper) {
        component.set("v.isReady", false);
        helper.doSearchAttachments(component);
    },

    fnOpenModal : function(component, event, helper) {
        var objWrapFile = component.get("v.objWrapFile");

        // Delete modal
        var param = {
            "sHeader"       : "파일 삭제",
            "sContent"      : "<b>'" + objWrapFile.fileName + "'</b>을(를) 삭제하시겠습니까?",
            "sConfirmBtn"   : "삭제",
            "sCancelBtn"    : "취소",
            "confirmAction" : component.getReference("c.fnDelete")
        };

        helper.doCreateConfirmComponent(component, param);
    },
			
    fnDelete : function(component, event, helper) {		
        component.set("v.showSpinner", true);	
        component.set("v.isReady", false);	
        helper.doDeleteFile(component);		
    },

    fnUploadFinished : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.isReady", false);

        var files = event.getParam("files");
        console.log(files[0]);

        helper.doUpdateAttach(component, files[0].documentId);
    },

    fnFilePreview : function(component, event, helper) {
        var documentId = component.get("v.objWrapFile").fileId;

        var evt = $A.get("e.lightning:openFiles");
        evt.setParams({
            "recordIds" : [documentId]
        });
        evt.fire();
    },


    
})