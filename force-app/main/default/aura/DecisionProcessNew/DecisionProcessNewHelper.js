({
    /**
     * @description 초기화 (기본 화면 데이터 셋팅)
     */
    getInitData : function(component) {
        var action = component.get("c.getInitData");

		action.setParams({
            
		});
		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);
                // 품의유형 선택목록 리스트 셋팅
                component.set("v.listDocType", returnValue.listDocType);
                
                console.log(JSON.stringify(returnValue.listDocType));

                let objDecisionProcess = component.get("v.objDecisionProcess");
                objDecisionProcess.Type__c = returnValue.listDocType[0].value;

			} else if(state === "ERROR") {
                var errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    } else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.showSpinner", false);
            component.set("v.isBTNClicked", false);  
        });
        $A.enqueueAction(action);
    },

    /**
     * @description 품의이력 생성
     */
    doSave : function(component, event, helper) { 
        var recordId = component.get("v.recordId");
        var action = component.get("c.doSave");

        action.setParams({
            recordId : recordId,
            objDecisionProcess : component.get("v.objDecisionProcess")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                this.showToast("success", "품의가 정상적으로 생성되었습니다.");

                $A.get("e.force:refreshView").fire();
                $A.get("e.force:closeQuickAction").fire();

            } else if(state === "ERROR") {
                var errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
                component.set("v.isBTNClicked", false);
                component.set("v.showSpinner", false);
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description 제안품의 & 오픈품의 생성 조건 확인
     */
    doCheckOpenApproval : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var objDecisionProcess = component.get("v.objDecisionProcess");
        var action = component.get("c.doCheckOpenApproval");
        var validMessage = '';

		action.setParams({
            recordId : recordId,
            DocType : objDecisionProcess.Type__c
		});
		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var isAvailable = returnValue.isAvailable;

                // 정상적인 경우 생성 프로세스 진행 아니면 오류메세지 출력
                if (isAvailable == true) {
                    this.doSave(component, event, helper);
                } else {
                    validMessage = returnValue.strMessage;
                }
                if (validMessage != '') {
                    helper.showToast('info', validMessage);
                    component.set("v.showSpinner", false);
                    return;
                }
			} else if(state === "ERROR") {
                var errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
                component.set("v.isBTNClicked", false); 
                component.set("v.showSpinner", false); 
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description 화면 닫기
     */
    doCloseModal : function(component, helper) {
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },

    /**
     * 세일즈포스 데이트 유형에 맞게 변경
     * @param {*} date 자바스크립트 date 객체
     */
    doParseYYYYMMDD : function(date) {
        var mm = date.getMonth() + 1;
        var dd = date.getDate();

        return [date.getFullYear(), (mm > 9 ? "" : "0") + mm, (dd > 9 ? "" : "0") + dd].join("-");
    },

    /**
     * @description 토스트 메세지 출력 이벤트 발생
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