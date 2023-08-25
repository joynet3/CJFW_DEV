({

	doSearchAttachments : function(component) {
	    console.log('doSearchAttachments ');

	    var filePermissionField = component.get("v.filePermissionField");
	    var fileFieldAPIName = component.get("v.fileFieldAPIName");
        
        var action = component.get("c.doSearchAttachments");

        action.setParams({
            "recordId" : component.get("v.recordId"),
            "fileFieldAPIName" : fileFieldAPIName,
            "filePermissionField" : filePermissionField
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    var returnValue = response.getReturnValue();

                    component.set("v.isFileEditable", returnValue.isFileEditable);
                    component.set("v.objWrapFile", returnValue.objWrapFile);

                    var objWrapFile = component.get("v.objWrapFile");
                    if(objWrapFile.fileId) component.set("v.isUploadFileExist", true);

                    component.set("v.isReady", true);
                }catch(e){
                    component.set("v.isReady", true);
                    console.log('error : ' + e.message);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },


    //child
    doUpdateAttach : function(component, documentId) {

        console.log('doUpdateAttach access');
        var action = component.get("c.doUpdateAttach");

        action.setParams({
            "recordId" : component.get("v.recordId"),
            "documentId"  : documentId,
            "fileFieldAPIName"  : component.get("v.fileFieldAPIName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                // Toast message
                this.showToast("success", "성공적으로 업로드되었습니다.");
                $A.get('e.force:refreshView').fire();
                component.set("v.isReady", true);
            } else if (state === "INCOMPLETE") {
                // Toast message
                this.showToast("warning", response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message;
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    }
                } else {
                    message = "Unknown error";
                }

                // Toast message
                this.showToast("error", message);
            }

            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);    
    },

    doDeleteFile : function(component) {
        var action = component.get("c.doDeleteFile");
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "documentId"  : component.get("v.objWrapFile").fileId,
            "fileFieldAPIName"  : component.get("v.fileFieldAPIName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner", false);

            if(state === "SUCCESS") {
                // Toast message
                this.showToast("success", "성공적으로 삭제되었습니다.");
                component.set("v.isUploadFileExist", false);        
                $A.get('e.force:refreshView').fire();
            } else if (state === "INCOMPLETE") {
                // Toast message
                this.showToast("warning", response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message;
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    }
                } else {
                    message = "Unknown error";
                }

                // Toast message
                this.showToast("error", message);
            }
        });

        $A.enqueueAction(action);
    },

    doCreateConfirmComponent : function(component, param) {
        $A.createComponent(
            "c:DN_Confirm",
            {
                "sHeader"       : param.sHeader,
                "sContent"      : param.sContent,
                "sConfirmBtn"   : param.sConfirmBtn,
                "sCancelBtn"    : param.sCancelBtn,
                "confirmAction" : param.confirmAction
            },
            function(cCommonConfirm, status, errorMessage) {
                if(status === "SUCCESS") {
                    // callback action
                    component.set("v.CommonConfirm", cCommonConfirm);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }   
        );
    },
    /**
     * 토스트 메세지 출력 이벤트 발생
     * @param {string} type 메세지 유형 (success, error, info, warning, other)
     * @param {string} message 토스트에 보여질 메세지
     */
	showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
})