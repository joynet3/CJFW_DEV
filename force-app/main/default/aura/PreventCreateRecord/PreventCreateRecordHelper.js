({
    /**
     * @description 초기화 (직접 생성 방지 에러메세지 출력)
     */
    doInit : function(component, event, helper) {
		component.set("v.showSpinner", true);
        this.showToast('info', 'MDM 고객 등록 요청은 직접 생성이 불가합니다.');
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