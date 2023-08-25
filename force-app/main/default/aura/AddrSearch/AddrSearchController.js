({
    // Component Init
    fnInit : function(component, event, helper) {
        helper.getInitData(component);
    },
    // 주소 등록 버튼 이벤트
    fnSearchAddress : function(component, event, helper) {
        component.set("v.openSearchAddr", true);
    },
    // Event Handler
    fnGetEvent : function(component, event, helper) {
        var actionType = event.getParam("actionType");
        console.log("actionType : " + actionType);

        if(actionType === "SELECT") {
            // 이벤트 파라미터와 값 매핑 등등...
            console.log(event.getParam("objAddress"));
        }
        else if(actionType === "CLOSE") {
            // 검색 모달 닫기
            helper.getInitData(component);
        }

        component.set("v.openSearchAddr", false);
    },

    /**
     * 상세 주소를 수정할 수 있는 컴포넌트로 전환
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    // 주소편집 이벤트
    fnEditDetail : function(component, event, helper) {
        component.set("v.openEditing", true);
    },
    // 취소버튼 이벤트
    fnCancel : function(component, event, helper) {
        component.set("v.openEditing", false);
    },

    /**
     * 상세 주소 저장
     * @param {*} component 
     * @param {*} event 
     * @param {*} helper 
     */
    // 저장버튼 이벤트
    fnSave : function(component, event, helper) {
        var bolAddrDetailCheckBox = component.get("v.bolAddrDetailCheckBox");
        var sAddrDetail = component.get("v.sAddrDetail");
        if(bolAddrDetailCheckBox && (sAddrDetail === "" || sAddrDetail == undefined || sAddrDetail == null)){
            helper.showToast('error','상세주소를 입력해주세요');
        }else{
            helper.doSave(component);
        }
    },
})