({
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

    doShowSpinner : function(component) {
        component.set("v.bIsShowSpinner", true);
    },

    doHideSpinner : function(component) {
        component.set("v.bIsShowSpinner", false);
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    },

    doFireEvent : function(component, fActionType) {
        var evt = component.getEvent("RoadAddrSearchEvt");
        evt.setParams({
            "actionType" : fActionType,
            "objAddress" : component.get("v.objAddress")
        });
        
        if(fActionType== 'CLOSE') {
            evt.fire();
        } else {
            component.set("v.AddrInputDiv", true); //주소입력폼
            component.set("v.btnSave", true); //저장버튼
            component.set("v.searchForm", false); //저장버튼
            
            component.set("v.bIsSearchAddr" , true);
            component.set("v.headerName" , "주소 저장");
        }
        //@@ evt.fire();
    },
    
    fnSaveRecord : function(component) {
        this.doShowSpinner(component);

		var recordId = component.get('v.recordId');
        var objAddr =  component.get('v.objAddress');
        var objName =  component.get('v.objName');
        var zipCodeField =  component.get('v.zipCodeField');
        var addressField =  component.get('v.addressField');
        var addressDetailField =  component.get('v.addressDetailField');

		var action = component.get('c.doSave'); 
		action.setParams({
			'recordId' : recordId
			, 'sZipNo' : objAddr.sZipNo
            , 'sRoadAddr'  : objAddr.sRoadAddr  	/*도로명 주소*/
            , 'sAddrDetail': objAddr.sAddrDetail 	/*주소상세*/
            , 'objName' : objName
            , 'zipCodeField' : zipCodeField
            , 'addressField' : addressField
            , 'addressDetailField' : addressDetailField
            , 'dupConfirmStatus' : component.get("v.dupConfirmStatus")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === 'SUCCESS') {
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
                    this.showToast('success', '성공적으로 저장되었습니다.');
                    var evt = component.getEvent("RoadAddrSearchEvt");
                    evt.setParams({
                        actionType: "CLOSE"
                    });
                    evt.fire();
                    $A.get('e.force:refreshView').fire();
                }
        	} else if(state === 'ERROR') { 
        		var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // alert("Error message: " + errors[0].message);
                        this.showToast("error", errors[0].message);
                    }
                } else {
                    // alert("Unknown error");
                    this.showToast("error", "Unknown error");
                }
            }
            
            this.doHideSpinner(component);
		}); 
		
		$A.enqueueAction(action);
	},
    
    fnPrepage : function(component) {
        component.set("v.AddrInputDiv",false); //주소입력폼
        component.set("v.btnSave", false); //저장버튼
        component.set("v.searchForm", true); //저장버튼
        
        component.set("v.bIsSearchAddr" , true);
        component.set("v.headerName" , "도로명 주소 찾기");
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