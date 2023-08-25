({
    // Component Init
	fnInit : function(component, event, helper) {
		helper.showSpinner(component);

		var recordId = component.get("v.recordId");

		var action = component.get("c.doInit");

		action.setParams({
            recordId : recordId
		});

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();

				console.log('====================> returnVal : '+JSON.stringify(returnVal));

				if(returnVal.strStatus == 'SUCCESS') {
                    component.set("v.listSelectType", returnVal.listSelectType);
                    helper.doGetEDMSList(component, event, helper);
				}else {
					helper.showToast('ERROR', returnVal.strMessage);
				}
				
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        helper.showToast('ERROR', errors[0].message);
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }

			helper.hideSpinner(component);
        });

        $A.enqueueAction(action);
	},
    // 파일업로드 Finish 이벤트
    fnHandleUploadFinished : function(component, event, helper) {
        var files = event.getParam("files");
        var documentId = files[0].documentId;
        component.set("v.documentId", documentId);

        helper.doCreatedFileURL(component, event, helper, documentId);
    },


    /**
     * @description : 파일 삭제 컨펌 이벤트 
     */
    fnDeleteConfirm : function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.title");
        
        let listFileWrapper = component.get("v.listFileWrapper");  
        console.log( 'selectedIndex :: ' + selectedIndex);
        let objFile = listFileWrapper[selectedIndex];
        component.set("v.selectedDeleteFile", objFile);
        console.log( 'objFile :: ' + JSON.stringify(objFile));

        component.set("v.modalStatus", 'Delete');
        component.set("v.modalDesc", '[' + objFile.fileName + ']');
    },

    // 파일 삭제 이벤트
    fnDeleteFile : function(component, event, helper) {
        helper.doDeleteFile(component, event, helper);
    },
    
    /**
     * @description 전표처리 화면 닫기
     */
	fnCloseModal : function(component, event, helper) {
		component.set("v.modalStatus", 'Hide');
	},

    // 닫기 버튼 이벤트
    fnClose: function(component, event, helper) {
		$A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    // 구분 토글 이벤트
    handleSectionToggle: function(component, event, helper) {
        var strType = component.get("v.strType");

        var openSections = event.getParam('openSections');

        component.set("v.listFileWrapper", []);

        helper.doGetEDMSList(component, event, helper);

        console.log('=================> strType : '+strType);
        console.log('=================> openSections : '+openSections);
    }
})