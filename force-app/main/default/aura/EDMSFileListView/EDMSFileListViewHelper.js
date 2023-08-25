({
    // init
	doInit : function(component, event, helper) {
	    component.set('v.listSearchWrapper', []);
        component.set("v.listColumn", [
            {'label' : '유형', 'fieldName' : 'type', 'type': 'text', sortable: true},
            {'label' : '이름', 'fieldName' : 'name', 'type': 'text', sortable: true},
            /*
            {'label' : '상태', 'fieldName' : 'status', 'type': 'text', sortable: true, initialWidth: 100},
            */
            {'label' : '최종수정자', 'fieldName' : 'LastModifiedUser', 'type': 'text', sortable: true},
            {'label' : '최종수정일자', 'fieldName' : 'LastModifiedDate', 'type': 'text', sortable: true},
            {'label' : '', 'fieldName' : 'downloadURL', 'type': 'url', typeAttributes: {label: { fieldName: 'donwload' }, target: '_blank'}},
        ]);
        this.getDataTable(component,event,helper);
	},
    // 조회
	getDataTable : function(component, event, helper) {
        var action = component.get("c.getDataTable");
        action.setParams({
            'recordId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                var strStatus = returnVal.strStatus;
                var strMessage = returnVal.strMessage;
                if(strStatus == 'SUCCESS'){
                    component.set('v.listSearchWrapper', returnVal.listSearchWrapper);
                }else{
//                    helper.showToast("ERROR",strMessage);
                    console.log("ERROR30: " + strMessage);
                }
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) {
//                        helper.showToast('ERROR', errors[0].message);
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
    // toast 메시지
	showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
    // 정렬
    fnSortData : function(component, fieldName, sortDirection) {
        var listSearchWrapper = component.get("v.listSearchWrapper");
        var reverse = sortDirection !== "asc";
        listSearchWrapper.sort(this.fnSortBy(fieldName, reverse))
        component.set("v.listSearchWrapper", listSearchWrapper);
    },
    // 정렬
    fnSortBy : function(field, reverse, primer) {
        var key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a) == undefined ? "" :  key(a)
            , b = key(b) == undefined ? "" :  key(b)
            , reverse * ((a > b) - (b > a));
        }
    },
})