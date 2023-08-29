({
    fn_promise : function(cmp, helper, methodName, params) 
    {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = cmp.get('c.' + methodName);
            action.setParams(params);
            action.setCallback(helper, function(response) {
                if (response.getState() === 'SUCCESS') {
                    resolve({'c':cmp, 'h':helper, 'r':response.getReturnValue(),'state' : response.getState()});
                } else {
                    let errors = response.getError();
                    console.log(errors);
                    cmp.set('v.isShowSpinner' , false);
                    helper.fn_showToast('error' , 'Error' , '재시도 후 에러 발생시 관리자에게 문의하세요.')
                }
            });          
            $A.enqueueAction(action);
        }));
    },

    fn_showToast : function(type, title, message) 
    {
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title': title,
            'message': message,
            'type' : type
        });
        toastEvent.fire();
    },

})