({
    doSearch: function (component, event) {
        console.log("!!! doSearch START !!!");
        let inputStr = component.get("v.bidNtceNo");
        var sourceSiteChk;
        var regex = /[0-9]{4}[A-z]{3}[0-9]{9}/;
        if (regex.test(inputStr)) {
            sourceSiteChk = "1";
        } else {
            sourceSiteChk = "2";
        }

        component.set("v.sourceSiteChk", sourceSiteChk);

        // var sourceSiteChk = component.get("v.sourceSiteChk");
        var workDivision = component.get("v.workDivision");
        console.log(inputStr);
        console.log(sourceSiteChk);
        console.log(workDivision);
        var action = component.get("c.doSearch");
        action.setParams({
            inputStr: inputStr,
            sourceSiteChk: sourceSiteChk,
            workDivision: workDivision
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            console.log("state", state);
            console.log("returnValue", JSON.stringify(returnValue));
            if (state === "SUCCESS") {
                if (returnValue.resultCode == "0000") {
                    this.showToast("success", "입찰공고가 정상적으로 조회되었습니다.");
                    console.log("return lead ::: " + JSON.stringify(returnValue.resultLead));
                    component.set("v.apiData", returnValue.resultLead);
                } else if (returnValue.resultCode == "0001") {
                    this.showToast("error", "시스템 통신 오류 " + returnValue.resultMessage);
                } else {
                    this.showToast("error", "입찰공고 검색 오류 공고종류, 업무구분, 공고번호 확인후 다시시도 하거나 관리자에게 문의 해주십시오.");
                }
            } else {
                this.showToast("error", "입찰공고 검색 오류 공고종류, 업무구분, 공고번호 확인후 다시시도 하거나 관리자에게 문의 해주십시오.");
                console.error();
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    doSave: function (component, event, helper) {
        console.log("!!!! doSave START !!!!");
        var insertLead = component.get("v.apiData");
        var sourceSiteChk = component.get("v.sourceSiteChk");
        var workDivision = component.get("v.workDivision");
        console.log("insert lead" + JSON.stringify(insertLead));
        var action = component.get("c.doSave");
        action.setParams({
            insertLead: insertLead,
            sourceSiteChk: sourceSiteChk,
            workDivision: workDivision
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            console.log("state", state);
            console.log("returnValue", JSON.stringify(returnValue));
            if (state === "SUCCESS") {
                if (returnValue.resultCode == "0000") {
                    this.showToast("success", "입찰공고가 정상적으로 등록되었습니다.");
                    var homeEvent = $A.get("e.force:navigateToSObject");

                    homeEvent.setParams({
                        recordId: "" + returnValue.resultId
                    });
                    homeEvent.fire();
                } else {
                    this.showToast("error", "입찰공고 등록 오류 관리자에게 문의 부탁드립니다.");
                    component.set("v.showSpinner", false);
                }
                component.set("v.showSpinner", false);
            }
            // this.doSave(component, event, helper);
        });
        $A.enqueueAction(action);
    },

    doChange: function (component, event) {
        component.set("v.apiData", null);
        component.set("v.bidNtceNo", null);
        component.set("v.sourceSiteChk", null);
    },

    doClose: function (component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");

        homeEvent.setParams({
            scope: component.get("v.sObjName")
        });
        homeEvent.fire();
    },

    /**
     * @description 토스트 메세지 출력 이벤트 발생
     * @param {string} type 메세지 유형 (success, error, info, warning, other)
     * @param {string} message 토스트에 보여질 메세지
     */

    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key: "info_alt",
            type: type,
            message: message
        });
        evt.fire();
    }
});