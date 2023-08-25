({
    /**
     * @description 품의이력 전자결재 상태 업데이트 대상 검색
     */
    doGetUpdateTarget : function(component) {

        let action = component.get("c.doGetUpdateTarget");

        action.setParams({
            recordId : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                let listData = returnValue.listData;

                let listDataLength = returnValue.listDataLength;
                let index = 0; 
                if ( listDataLength > 0 ){
                    this.doUpdateApprovalLine(component, listData, listDataLength, index);
                }

            } else if(state === "ERROR") {
                let errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.hasSpinner", false);
        });

        $A.enqueueAction(action);

    },

    /**
     * @description 품의이력 전자결재 대상 업데이트 (하나씩)
     */
    doUpdateApprovalLine : function(component, listData, listDataLength, index) {
        let action = component.get("c.doUpdateApprovalLine");
        let targetId = listData[index].Id;
        console.log ( 'doUpdateApprovalLine target ' + index+1 + ' ::: ' + JSON.stringify(listData[index]));

        action.setParams({
            targetId : targetId
        });

        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                index = index + 1;

                if ( listDataLength > index){
                    this.doUpdateApprovalLine(component, listData, listDataLength, index);
                } else {
                    $A.get("e.force:refreshView").fire();
                }
                
            } else if(state === "ERROR") {
                let errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.hasSpinner", false);
        });

        $A.enqueueAction(action);

    },
    
    showToast : function(type, message) {
        let evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    }
})