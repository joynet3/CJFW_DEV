({
    // Init
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
                var i=0;
                var sZipNo = "";
                var sRoadAddr = "";
                var sAddrDetail = "";
                
                let objAddress = new Object; 
                objAddress.sZipNo = returnValue.listDesire[component.get("v.zipCodeField")];
                objAddress.sRoadAddr = returnValue.listDesire[component.get("v.addressField")];
                objAddress.sAddrDetail = returnValue.listDesire[component.get("v.addressDetailField")];

                component.set("v.objAddress", objAddress);
                component.set("v.labelPostalCode", returnValue.labelPostalCode);
                component.set("v.labelAddress", returnValue.labelAddress);
                component.set("v.labelAddressDetail", returnValue.labelAddressDetail);
                
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

    // API 호출시 검색어에 특수문자 혹은 OR, INSERT, UNION 등 SQL 예약어가 포함되는 경우
    // 보안장비가 SQL INJECTION 공격으로 간주하여 해당 IP를 차단 시킬 수 있어 필터링 추가
    doCheckSearchKey : function(sSearchKey) {
        if(sSearchKey !== "") {
            // 특수문자 제거
            var expText = /[%=><]/;
            if(expText.test(sSearchKey)) {
                this.showToast("warning", "특수문자를 입력할 수 없습니다.");

                sSearchKey = sSearchKey.split(expText).join("");

                return false;
            }

            // 특정문자열(SQL예약어의 앞뒤공백 포함) 제거
            var listSQL = new Array("OR", "SELECT", "INSERT", "DELETE", "UPDATE", "CREATE", "DROP", "EXEC", "UNION",  "FETCH", "DECLARE", "TRUNCATE");

            var regex;
            var regexPlus;

            for(var i in listSQL) {
                regex = new RegExp("\\s" + listSQL[i] + "\\s", "gi");
                if(regex.test(sSearchKey)) {
                    this.showToast("warning", "\'" + listSQL[i] + "\'와(과) 같은 특정 문자로 검색할 수 없습니다.");

                    sSearchKey = sSearchKey.replace(regex, "");

                    return false;
                }

                regexPlus = new RegExp("\\+" + listSQL[i] + "\\+", "gi");
                if(regexPlus.test(sSearchKey)) {
                    this.showToast("warning", "\'" + listSQL[i] + "\'와(과) 같은 특정 문자로 검색할 수 없습니다.");

                    sSearchKey = sSearchKey(regexPlus, "");

                    return false;
                }                
            }

            return true;
        } else {
            this.showToast("warning", "검색어를 입력해주세요.");

            return false;
        }
    },
    // 주소조회
    doSearchAddress : function(component, intPageNo, intPageIdx) {
        // Show spinner
        this.doShowSpinner(component);

        // Search address
        var action = component.get("c.doSearchAddress");

        action.setParams({
            "sSearchKey"     : component.find("searchKey").get("v.value"),
            "intCntPerPage"  : component.get("v.intCntPerPage"),
            "intCurrentPage" : intPageNo
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var objReturnValue = response.getReturnValue();
                console.log(objReturnValue);

                component.set("v.sErrorCode"    , objReturnValue.sErrorCode);
                component.set("v.bIsSearchAddr" , true);
                component.set("v.AddrInputDiv", false); 

                if(objReturnValue.sErrorCode === "0") {
                    component.set("v.intTotalCount" , objReturnValue.sTotalCount);
                    component.set("v.intTotalPage"  , Math.ceil(objReturnValue.sTotalCount / component.get("v.intCntPerPage")));
                    component.set("v.intCurrentPage", objReturnValue.intCurrentPage);
                    component.set("v.listAddress"   , objReturnValue.listWrapperAddress);
                    component.set("v.intPageIdx"    , intPageIdx);
                    
                } else {
                    // Toast message
                    this.showToast("error", objReturnValue.sErrorMessage);      
                }

                // Hide spinner
                this.doHideSpinner(component);
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

        var objAddress =  component.get('v.objAddress');

		action.setParams({
            "recordId" : component.get("v.recordId"),
            "sZipNo" : objAddress.sZipNo,
            "sRoadAddr"  : objAddress.sRoadAddr,
            "sAddrDetail" : objAddress.sAddrDetail,
            "objName" : component.get("v.objName"),
            "zipCodeField" : component.get("v.zipCodeField"),
            "addressField" : component.get("v.addressField"),
            "addressDetailField" : component.get("v.addressDetailField"),
            "dupConfirmStatus" : component.get("v.dupConfirmStatus")
		});
		action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);

				let result = response.getReturnValue();
                let dupConfirmStatus = result.dupConfirmStatus;
                let dupMessage = result.dupMessage;
                component.set("v.dupConfirmStatus", dupConfirmStatus);
                if ( dupConfirmStatus == 'Y'){
                    // 주의메세지 표시 
                    let alert = {
                        type: "warning",
                        message: "이 레코드는 기존 레코드와 유사합니다. 저장하기 전에 잠재적 중복 레코드를 확인하십시오."
                    };
                    component.set("v.alertType", alert.type);
                    component.set("v.alertMessage", alert.message);
                    component.set("v.isShowWarning", true);
                    
                } else {                
                    // alert('Successfully saved.');
                    component.set("v.AddrInputDiv" , true);
                    this.showToast("success", "주소 변경이 완료되었습니다.");
                    $A.get('e.force:refreshView').fire();
                    component.set("v.screenMode", 'View');
                }
                

			} else if(state === "ERROR") {
                var errors = response.getError();
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
    // 로딩바 활성화
    doShowSpinner : function(component) {
        component.set("v.bIsShowSpinner", true);
    },
    // 로딩바 비활성화
    doHideSpinner : function(component) {
        component.set("v.bIsShowSpinner", false);
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