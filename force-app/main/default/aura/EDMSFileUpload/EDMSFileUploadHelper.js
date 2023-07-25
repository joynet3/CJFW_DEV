({
	// 업로드 파일 URL 생성
	doCreatedFileURL : function(component, event, helper, documentId) {
		helper.showSpinner(component);

        var action = component.get("c.doCreatedFileURL");

		action.setParams({
			'documentId': documentId
		});

		helper.showToast('info', '파일 업로드가 진행중입니다 잠시만 기다려주세요');

		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
				var strStatus = returnVal.strStatus;
				var strMessage = returnVal.strMessage;

				if(strStatus == 'SUCCESS') {
					var downloadUrl = returnVal.downloadUrl;

					component.set("v.downloadUrl", downloadUrl);
					helper.doSendEMDS(component, event, helper);
					component.set("v.isActiveBtnSend", true);

					console.log('==============> downloadUrl : '+downloadUrl);				

				}else {
					component.set("v.isActiveBtnSend", false);
					helper.showToast(strStatus, strMessage);
					helper.hideSpinner(component);
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

			//helper.hideSpinner(component);
        });

        $A.enqueueAction(action); 
	},
	
	// 업로드 파일 삭제
	doDeleteFile : function(component, event, helper) {
		helper.showSpinner(component);

        var action = component.get("c.doDeleteFile");

		action.setParams({
			'targetFile': component.get("v.selectedDeleteFile")
		});

		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
				var strStatus = returnVal.strStatus;
				var strMessage = returnVal.strMessage;

				component.set("v.modalStatus", 'Hide');
				if(strStatus == 'SUCCESS') {
					helper.showToast('success', strMessage);	
					helper.doGetEDMSList(component, event, helper);
					helper.doRefreshView(component, event, helper);
				}else {
					helper.showToast('error', strMessage);	
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

	// EDMS 파일리스트 조회
	doGetEDMSList : function(component, event, helper) {
		console.log('===========> helper getEDMSList start');
		helper.showSpinner(component);

		var recordId = component.get("v.recordId");
		var strType = component.get("v.strType");

        var action = component.get("c.doGetEDMSList");

		action.setParams({
			'recordId' : recordId,
			'strType': strType
		});

		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
				var strStatus = returnVal.strStatus;
				var strMessage = returnVal.strMessage;

				if(strStatus == 'SUCCESS') {
					console.log('===============> returnVal.listFileWrapper : '+JSON.stringify(returnVal.listFileWrapper));

					component.set("v.listFileWrapper", returnVal.listFileWrapper);
				}else {
					helper.showToast(strStatus, strMessage);
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
	
	// EDMS 파일 업로드 전송
	doSendEMDS : function(component, event, helper) {
        helper.showSpinner(component);

		var documentId = component.get("v.documentId");
		var downloadUrl = component.get("v.downloadUrl");

        var action = component.get("c.doSendEMDS");

		action.setParams({
			'mapParam' : {
                'recordId' : component.get('v.recordId'),
                'documentId': documentId,
                'strType': component.get('v.strType'),
				'downloadUrl' : downloadUrl
            }
		});
		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
				var strStatus = returnVal.strStatus;
				var strMessage = returnVal.strMessage;

				console.log('================> returnVal : '+JSON.stringify(returnVal));

				helper.showToast(strStatus, strMessage);

				if(strStatus == 'SUCCESS') {
					helper.doGetEDMSList(component, event, helper);
					helper.doRefreshView(component, event, helper);
					//$A.get("e.force:refreshView").fire();
				}else {
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
	// 화면 Refresh
	doRefreshView : function(component, event, helper) {
		var evt = $A.get("e.c:EDMSFileViewRefresh_evt");

		if(evt) {
			console.log('event fire');
			evt.fire();
		}else {
			//alert('not event');
			console.log('event not');
		}
	},
	// Toast 메시지
	showToast : function(type, message) {
		let evt = $A.get("e.force:showToast");
		evt.setParams({
			key     : "info_alt",
			type    : type,
			message : message
		});
		evt.fire();
	},
	// 로딩바 활성화
	showSpinner: function (component) {
		/* this will show the <lightning:spinner /> */
		component.set('v.showSpinner', true);
	},
	// 로딩바 비활성화
	hideSpinner: function (component) {
		/* this will hide the <lightning:spinner /> */
		component.set('v.showSpinner', false);
	},
})