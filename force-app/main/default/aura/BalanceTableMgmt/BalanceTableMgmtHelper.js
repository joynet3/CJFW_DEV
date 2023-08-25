/**
 * @description       : 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 07-31-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   07-31-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
({
    /**
     * @description 초기화 (선택된 탭과 시산 유형에 따라 해당하는 표를 셋팅)
     */
    doInit : function(component) {
        let action = component.get("c.doGetPrefix");

        let recordId = component.get("v.recordId");

        action.setCallback(this, function(response) {
            let state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.showSpinner", true);                        
                let returnValue = response.getReturnValue();

                let selectedTab = component.get("v.selectedTab");
                let balanceType = component.get("v.balanceType");
                
                console.log(JSON.stringify(selectedTab));

                // prefix + vfpage + 변수로 URL 조합 및 셋팅
                let visualforceUrl = '';
                if ( balanceType == '비교') {
                    visualforceUrl = returnValue.prefix + '/apex/BalanceCompareView?Id=' + recordId;   
                }
                else {
                    visualforceUrl = returnValue.prefix + '/apex/BalanceExcelUploadView?Id=' + recordId + "&viewType=" + selectedTab + "&balanceType=" + balanceType;   
                }
                console.log('h.1 > visualForcePage URL ', JSON.stringify(visualforceUrl));
                component.set("v.vfPageUrl", '');
                setTimeout(function(){ 
                    component.set("v.vfPageUrl", visualforceUrl);
                }, 1000);
                setTimeout(function(){ 
                    component.set("v.showSpinner", false);
                }, 2000);

            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast('ERROR', errors[0].message);
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description 시산 업로드 화면 열기 (제안시산이 없는 경우 오픈시산 업로드 불가)
     * recordId -> oppty id 
     * balanceType -> 시산타입 ('오픈시산' or '제안시산')
     */
    doOpenUpload : function(component, event, helper) {
        let action = component.get("c.doOpenUpload");
        let recordId = component.get("v.recordId");
        let balanceType = component.get("v.balanceType");
        action.setParams({
            recordId : recordId,
            balanceType : balanceType
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner", true);
                let returnValue = response.getReturnValue();
                let isOpenUploadValue = returnValue.isOpenUpload;
                console.log('1> isOpenUploadValue ' , JSON.stringify(returnValue));

                // 유효성 체크 후 이상 없으면 시산 업로드 Open
                var validMessage = '';
                if (isOpenUploadValue === false) {
                    validMessage = '제안 시산을 먼저 업로드 한 후 오픈 시산을 업로드 하십시오.';
                }
                if(validMessage != '') {
                    helper.showToast('info', validMessage);
                    component.set("v.showSpinner", false);
                    return;
                }
                component.set("v.isOpenUpload", isOpenUploadValue);

            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast('ERROR', errors[0].message);
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
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