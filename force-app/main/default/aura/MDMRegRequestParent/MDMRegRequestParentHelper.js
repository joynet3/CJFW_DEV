({    
    doSetMDMRequest: function (component, event, helper) {

    },
    //주소 Helper
    // API 호출시 검색어에 특수문자 혹은 OR, INSERT, UNION 등 SQL 예약어가 포함되는 경우
    // 보안장비가 SQL INJECTION 공격으로 간주하여 해당 IP를 차단 시킬 수 있어 필터링 추가
    doCheckSearchKey: function (sSearchKey) {
        if (sSearchKey !== "") {
            // 특수문자 제거
            var expText = /[%=><]/;
            if (expText.test(sSearchKey)) {
                this.showToast("warning", "특수문자를 입력할 수 없습니다.");

                sSearchKey = sSearchKey.split(expText).join("");

                return false;
            }

            // 특정문자열(SQL예약어의 앞뒤공백 포함) 제거
            var listSQL = new Array("OR", "SELECT", "INSERT", "DELETE", "UPDATE", "CREATE", "DROP", "EXEC", "UNION", "FETCH", "DECLARE", "TRUNCATE");

            var regex;
            var regexPlus;

            for (var i in listSQL) {
                regex = new RegExp("\\s" + listSQL[i] + "\\s", "gi");
                if (regex.test(sSearchKey)) {
                    this.showToast("warning", "\'" + listSQL[i] + "\'와(과) 같은 특정 문자로 검색할 수 없습니다.");

                    sSearchKey = sSearchKey.replace(regex, "");

                    return false;
                }

                regexPlus = new RegExp("\\+" + listSQL[i] + "\\+", "gi");
                if (regexPlus.test(sSearchKey)) {
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
    // 주소 API 호출
    doSearchAddress: function (component, intPageNo, intPageIdx) {
        // Show spinner
        this.doShowSpinner(component);

        // Search address
        var action = component.get("c.doSearchAddress");

        action.setParams({
            "sSearchKey": component.find("searchKey").get("v.value"),
            "intCntPerPage": component.get("v.intCntPerPage"),
            "intCurrentPage": intPageNo
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var objReturnValue = response.getReturnValue();
                console.log(objReturnValue);

                component.set("v.sErrorCode", objReturnValue.sErrorCode);
                component.set("v.bIsSearchAddr", true);

                if (objReturnValue.sErrorCode === "0") {
                    component.set("v.intTotalCount", objReturnValue.sTotalCount);
                    component.set("v.intTotalPage", Math.ceil(objReturnValue.sTotalCount / component.get("v.intCntPerPage")));
                    component.set("v.intCurrentPage", objReturnValue.intCurrentPage);
                    component.set("v.listAddress", objReturnValue.listWrapperAddress);
                    component.set("v.intPageIdx", intPageIdx);
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
    // 로딩바 활성화
    doShowSpinner: function (component) {
        component.set("v.showSpinner", true);
    },
    // 로딩바 비활성화
    doHideSpinner: function (component) {
        component.set("v.showSpinner", false);
    },
    // Toast 메시지
    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            key: "info_alt",
            type: type,
            message: message
        });

        evt.fire();
    },
    // 주소 선택 이벤트
    doFireEvent: function (component, fActionType) {
        var evt = component.getEvent("RoadAddrSearchEvt");

        evt.setParams({
            "actionType": fActionType,
            "objAddress": component.get("v.objAddress")
        });

        if (fActionType == 'CLOSE') {
            evt.fire();
        } else {
            component.set("v.AddrInputDiv", true); //주소입력폼
            component.set("v.btnSave", true); //저장버튼
            component.set("v.searchForm", false); //저장버튼

            component.set("v.bIsSearchAddr", true);
            component.set("v.headerName", "주소 저장");
        }
        //@@ evt.fire();
    },

    // 주소 저장
    fnAddressSaveRecord: function (component) {
        //주소 입력 받은 부분 불러오기
        var addressField = component.get('v.objAddress.sRoadAddr');

        //지번 주소 추가 2023-03-02
        var addressBeforeField = component.get('v.objAddress.sJibunAddr');
        //상세주소 입력 받은 부분 불러오기
        var addressDetailField = component.get('v.objAddress.sAddrDetail');

        // 우편번호
        var sZipNo = component.get('v.objAddress.sZipNo');

        console.log('===============> addressBeforeField : '+addressBeforeField);
        
        component.set('v.objCustomer.PV_ADRES_ROADADDR1__c', addressField);
        component.set('v.objCustomer.PV_ADRES_ROADADDR2__c', addressDetailField);
        // 2023-03-03 지번주소 추가 
        component.set('v.objCustomer.PV_ADRES_ADDR1__c', addressBeforeField);
        component.set('v.objCustomer.PV_ADRES_ADDR2__c', addressDetailField);
        component.set('v.objCustomer.PV_ADRES_ZIPCODE__c', sZipNo);

        component.set('v.isAddressModalOpen', false);
    },
    // 주소 이전 버튼
    fnPrepage: function (component) {
        component.set("v.AddrInputDiv", false); //주소입력폼
        component.set("v.btnSave", false); //저장버튼
        component.set("v.searchForm", true); //저장버튼

        component.set("v.bIsSearchAddr", true);
        component.set("v.headerName", "도로명 주소 찾기");
    },

    // 연락처(Contact) 정보 조회
    doGetContactData: function (component) {
        // Show spinner
        this.doShowSpinner(component);

        // Search contact
        var action = component.get("c.getContactsByOpportunity");
        var strObjectType = component.get("v.strObjectType");
        var recordId = '';

        if(strObjectType == 'Opportunity') {
            recordId = component.get("v.recordId");
        }else {
            recordId = component.get("v.objCustomer.Opportunity__c");
        }

        console.log('===============> strObjectType : '+strObjectType);
        console.log('===============> recordId : '+recordId);

        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                var contactData = [];

                if(data && data.length > 0) {
                    data.forEach((item, index) => {
                        contactData.push({
                            isChecked : false,
                            PV_NO__c: String(index + 1),
                            PV_NAME1_VK__c: item.LastName,
                            PV_KNVKGB_lu__c: '',
                            PV_KNVKGB__c: item.PV_KNVKGB__c,
                            PV_TELF1_VK__c: item.MobilePhone,
                            PV_EMAIL_VK__c: item.Email,
                            PV_PAFKT_VK__c: item.PV_PAFKT_VK__c,
                            PV_ABTNR_VK__c: item.Department,
                            PV_TALKT_VK__c: item.PV_TALKT_VK__c,
                            Contact__c : item.Id
                        });
                    });

                    if(contactData.length == 1) {
                        contactData.forEach((item, index) => {
                            item.isChecked = true;
                        });
                    }

                    component.set('v.contactData', contactData);                
                } else {
                    // Toast message
                    this.showToast("error", "고객의 연락처 정보가 존재하지 않습니다. 연락처정보를 입력하여 주시기 바랍니다.");
                }
                component.set('v.isContactModalOpen', true);
                // Hide spinner
                this.doHideSpinner(component);
            } else {
                // Toast message
                this.doHideSpinner(component);
                this.showToast("error", "error get contact data");
            }
        });

        $A.enqueueAction(action);
    },
    
    // 연락처(Contact) 정보 저장
	doSaveContact: function (component, contactTarget) {
        this.doShowSpinner(component);

        console.log(' contactTarget :: ' + JSON.stringify(contactTarget) );
        var action = component.get("c.doSaveContact");

        action.setParams({
            "contactTarget": JSON.stringify(contactTarget)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set('v.isContactModalOpen', false);
            } else {
                this.showToast("error", "연락처 저장에 실패했습니다. 관리자에게 문의하세요.");
            }
            this.doHideSpinner(component);
        });

        $A.enqueueAction(action);
    },
    
    // 전화번호 포맷
    onInputPhone: function (value) {  

        var returnValue = '';
        
        if(!(value == undefined || value == "" || value == null)) {
            returnValue = value
            .replace(/[^0-9]/g, '')
            .replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]{3,4})([0-9]{4})/g, "$1-$2-$3");
        }

        return returnValue;
    },
    // 숫자외 문자 삭제
    onInputNumber : function(value) {
        var returnValue = '';

        if(!(value == undefined || value == "" || value == null)) {
            returnValue = value.replace(/[^0-9]/g, '')
        }

        return returnValue;
    }
})