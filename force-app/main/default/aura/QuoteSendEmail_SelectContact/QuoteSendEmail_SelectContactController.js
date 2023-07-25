/**
 * Created by 천유정 on 2023-01-03.
 */

({
    /**
     * @description 초기화
     */
    fnInit : function(component, event, helper) {
        console.log('===================> fnInit Start');
        helper.showSpinner(component);

        helper.hideSpinner(component);
    },

    /**
     * @description 연락처 검색 화면 열기
     */
    openModel: function(component, event, helper) {
        component.set("v.isShowPopup", true);
        helper.showSpinner(component);
        helper.getInitData(component, event, helper);
        helper.hideSpinner(component);
    },

    /**
     * @description 연락처 검색 화면 닫기
     */
    fnCancel: function(component, event, helper) {
        component.set("v.isShowPopup", false);
    },

    /**
     * @description 조회 리스트 행 선택시 Master Component에 정보 전달
     */
    handlerClickList : function(component, event, helper) {
        var target =  event.currentTarget;
        var index = target.dataset.index;

        var listContacts = component.get('v.listContacts');
        var validMessage = '';

        if (helper.isNullCheck(listContacts[index].Email)) {
            validMessage = '이메일 주소를 가진 연락처를 선택하세요.';
        }

        if(validMessage != '') {
            helper.showToast('info', validMessage); 
            return;
        }

        console.log('===============> popup click target index : '+index);
        console.log('===============> popup click target Object : '+JSON.stringify(listContacts[index]));
        component.set("v.isShowPopup", false);

        var evt = component.getEvent("QuoteSendEmail_SelectContact_evt");

        console.log('==============> get event');
        if (evt) {
            console.log('==============> event setParam');
            console.log('==============> event setParam');
            evt.setParams({
                "index" : index,
                "targetObject" : listContacts[index]
            });
            console.log('==============> event start');
            evt.fire();
            console.log('==============> event fire');
        }else {
            console.log('==============> not event');
        } 
    },
});