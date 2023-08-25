({
    handleChanged : function(component, message, helper) {
        console.log('LMS Received!!');
        if (message != null) {
            console.log('lightning channel receive success');
            console.log(
                JSON.parse(JSON.stringify(message))
            )
            if(message.getParam('btnType') == 'close' && message.getParam('pageType') == 'cjfwSurveyModal') {

                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }

        }
    }
})