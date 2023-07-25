/**
 * Created by 천유정 on 2023-01-03.
 */

({
    /**
     * @description 초기화 (연락처 리스트 조회)
     */
    getInitData : function(component, event, helper) {
        console.log('[getInitData] Start =============================>');
        var action = component.get("c.getInitContactList");
        action.setParams({
            objAccountId: component.get("v.objAccountId"), 
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('[getInitData] result', result);
                var strStatus = result['strStatus'];
                var strMessage = result['strMessage'];
                if (strStatus === 'SUCCESS') {
                    console.log('[getInitData] strStatus =============================>' + strStatus);
                    var listContacts = result['listContacts'];
                    if (listContacts.length != 0) {
                        for (var data of listContacts) {
                            data.Name = data.Name;
                            data.MobilePhone = data.MobilePhone;
                            data.Email = data.Email;
                            data.AccountId = data.AccountId;
                            data.Id = data.Id;
                        }
                        component.set("v.listContacts", listContacts);
                    }
                } else {
                    this.showToast("error", strMessage);
                }

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.isShowSpinner", false);
        });
        $A.enqueueAction(action);
        console.log('[getInitData] End ==============================>');
    },

    /**
     * @description Spinner ON
     */
    showSpinner: function (component) {
        /* this will show the <lightning:spinner /> */
        component.set('v.isShowSpinner', true);
    },

    /**
     * @description Spinner OFF
     */
    hideSpinner: function (component) {
        /* this will hide the <lightning:spinner /> */
        component.set('v.isShowSpinner', false);
    },

    /**
     * @description Null , Undefined , '' 체크
     */
    isNullCheck : function(value){
        if(value == null || value == undefined || value == ""){
            return true;
        }
        else{
            return false;
        }
    },
    
    /**
     * @description 토스트 메세지
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
});