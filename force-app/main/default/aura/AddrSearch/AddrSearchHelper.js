({
    getInitData : function(component) {
     	var action = component.get("c.getInitData");
        
		action.setParams({
            recordId : component.get("v.recordId")
            , objName : component.get("v.objName")
            , zipCodeField : component.get("v.zipCodeField")
            , addressField : component.get("v.addressField")
            , addressDetailField : component.get("v.addressDetailField")
		});
		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                //console.log(returnValue);
                var i=0;
                var sZipNo = "";
                var sRoadAddr = "";
                var sAddrDetail = "";

                sZipNo = returnValue.listDesire[component.get("v.zipCodeField")];
                sRoadAddr = returnValue.listDesire[component.get("v.addressField")];
                sAddrDetail = returnValue.listDesire[component.get("v.addressDetailField")];


                component.set("v.labelPostalCode", returnValue.labelPostalCode);
                component.set("v.labelAddress", returnValue.labelAddress);
                component.set("v.labelAddressDetail", returnValue.labelAddressDetail);

				// for(var key in returnValue.listDesire) {
                //     //console.log("attr: " + key + ", value: " + returnValue.listDesire[key]);
                //     if(i==0) {
                //         sZipNo = returnValue.listDesire[key];
                //     }
                //     if(i==1) {
                //         sRoadAddr = returnValue.listDesire[key];
                //     }
                //     if(i==2) {
                //         sAddrDetail = returnValue.listDesire[key];
                //     }
                //     i++;
                // }
                component.set("v.sZipNo", sZipNo);
                component.set("v.sRoadAddr", sRoadAddr);
                component.set("v.sAddrDetail", sAddrDetail);
                component.set("v.sAddrDetail", sAddrDetail);
			} else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * 주소 상세 업데이트
     * @param {*} component 
     */
    doSave : function(component) {
        component.set("v.showSpinner", true);
        var action = component.get("c.doSave");
		action.setParams({
            "recordId" : component.get("v.recordId"),
            "sZipNo" : component.get("v.sZipNo"),
            "sRoadAddr" : component.get("v.sRoadAddr"),
            "sAddrDetail" : component.get("v.sAddrDetail"),
            "objName" : component.get("v.objName"),
            "zipCodeField" : component.get("v.zipCodeField"),
            "addressField" : component.get("v.addressField"),
            "addressDetailField" : component.get("v.addressDetailField")
		});
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('statesdfsdf');
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);

                this.showToast("success", "주소 변경이 완료되었습니다.");
                $A.get('e.force:refreshView').fire();

                component.set("v.openEditing", false);
			} else if(state === "ERROR") {
                var errors = response.getError();
                console.log('asdf'+ JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
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