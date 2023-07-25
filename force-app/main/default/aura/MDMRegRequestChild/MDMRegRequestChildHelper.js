({
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
        
        /*
        var returnValue = value.replace(/[^0-9]/g, '').replace(/^(\d{0,3})(\d{0,4})(\d{0,4})$/g, "$1-$2-$3").replace(/(\-{1,2})$/g, "");
        */

        return returnValue;
    },
    // 지급조건 변경 이벤트
    onChangePVZTERMVV: function (component, event) {
        var code = component.get('v.objCustomer.PV_ZTERM_VV__c');
        // 지급조건에 따라 약정회전일(PV_KULTG__c) 자동세팅
        switch (code) {
            case 'A103':
                component.set('v.objCustomer.PV_KULTG__c', "0");
                component.set('v.isReadOnlyPVKULTG', true);

                break;
            case 'A104':
                // code block
                component.set('v.objCustomer.PV_KULTG__c', "0");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'A105':
                component.set('v.objCustomer.PV_KULTG__c', "0");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'A106':
                component.set('v.objCustomer.PV_KULTG__c', "0");
                component.set('v.isReadOnlyPVKULTG', true);
                break;

            case 'A107':
                component.set('v.objCustomer.PV_KULTG__c', "0");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'A108':
                component.set('v.objCustomer.PV_KULTG__c', "0");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'C001':
                component.set('v.objCustomer.PV_KULTG__c', "30");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D000':
                component.set('v.objCustomer.PV_KULTG__c', "0");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D100':
                component.set('v.objCustomer.PV_KULTG__c', "0");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D201':
                component.set('v.objCustomer.PV_KULTG__c', "1");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D301':
                component.set('v.objCustomer.PV_KULTG__c', "11");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D305':
                component.set('v.objCustomer.PV_KULTG__c', "15");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D310':
                component.set('v.objCustomer.PV_KULTG__c', "20");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D325':
                component.set('v.objCustomer.PV_KULTG__c', "35");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D360':
                component.set('v.objCustomer.PV_KULTG__c', "70");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D401':
                component.set('v.objCustomer.PV_KULTG__c', "16");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D405':
                component.set('v.objCustomer.PV_KULTG__c', "20");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D410':
                component.set('v.objCustomer.PV_KULTG__c', "25");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D415':
                component.set('v.objCustomer.PV_KULTG__c', "30");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D425':
                component.set('v.objCustomer.PV_KULTG__c', "40");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D430':
                component.set('v.objCustomer.PV_KULTG__c', "45");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D540':
                component.set('v.objCustomer.PV_KULTG__c', "60");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D640':
                component.set('v.objCustomer.PV_KULTG__c', "65");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D665':
                component.set('v.objCustomer.PV_KULTG__c', "90");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D701':
                component.set('v.objCustomer.PV_KULTG__c', "30");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D705':
                component.set('v.objCustomer.PV_KULTG__c', "35");
                component.set('v.isReadOnlyPVKULTG', true);
                break;

            case 'D707':
                component.set('v.objCustomer.PV_KULTG__c', "37");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D710':
                component.set('v.objCustomer.PV_KULTG__c', "40");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D711':
                component.set('v.objCustomer.PV_KULTG__c', "41");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D714':
                component.set('v.objCustomer.PV_KULTG__c', "44");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D715':
                component.set('v.objCustomer.PV_KULTG__c', "45");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D716':
                component.set('v.objCustomer.PV_KULTG__c', "46");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D720':
                component.set('v.objCustomer.PV_KULTG__c', "50");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D725':
                component.set('v.objCustomer.PV_KULTG__c', "55");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D730':
                component.set('v.objCustomer.PV_KULTG__c', "60");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D735':
                component.set('v.objCustomer.PV_KULTG__c', "65");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D740':
                component.set('v.objCustomer.PV_KULTG__c', "70");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D745':
                component.set('v.objCustomer.PV_KULTG__c', "75");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D750':
                component.set('v.objCustomer.PV_KULTG__c', "80");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D755':
                component.set('v.objCustomer.PV_KULTG__c', "85");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D760':
                component.set('v.objCustomer.PV_KULTG__c', "90");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D765':
                component.set('v.objCustomer.PV_KULTG__c', "95");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D770':
                component.set('v.objCustomer.PV_KULTG__c', "100");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D780':
                component.set('v.objCustomer.PV_KULTG__c', "110");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D785':
                component.set('v.objCustomer.PV_KULTG__c', "115");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D790':
                component.set('v.objCustomer.PV_KULTG__c', "120");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D795':
                component.set('v.objCustomer.PV_KULTG__c', "125");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case 'D7C0':
                component.set('v.objCustomer.PV_KULTG__c', "150");
                component.set('v.isReadOnlyPVKULTG', true);
                break;
            case '':
                component.set('v.objCustomer.PV_KULTG__c', "");
                component.set('v.isReadOnlyPVKULTG', false);
                break;
        }
    },
    // FW출고센터, 고객분류 변경시 주문마감유형 리스트 변경
    doChangeOrderType: function (component, event, helper, strType) {
        var PV_LOGISCENTER = component.get('v.objCustomer.PV_LOGISCENTER__c');
        var PV_CUHR1 = component.get('v.objCustomer.PV_CUHR1__c');
        helper.doShowSpinner(component);

        var action = component.get("c.doCheckOrderType");
        
        action.setParams({
            "strType" : strType,
            "PV_LOGISCENTER" : PV_LOGISCENTER,
            "PV_CUHR1" : PV_CUHR1
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();

                var strStatus = returnVal.strStatus;
                var strMessage = returnVal.strMessage;

                if(strStatus == "SUCCESS") {
                    console.log('==============> returnVal.listCustomerOrderType : '+JSON.stringify(returnVal.listCustomerOrderType));

                    var pvODCloseGB = component.get("v.objCustomer.PV_ODCLOSEGB__c");

                    console.log('===========> pvODCloseGB : '+pvODCloseGB);

                    component.set("v.listCustomerOrderType", returnVal.listCustomerOrderType);

                    if(!(pvODCloseGB == undefined || pvODCloseGB == null || pvODCloseGB == '' || pvODCloseGB == 'none')) {

                        var returnMessage = '';

                        if(strType == 'LOGIC') {
                            returnMessage = 'FW 출고센터 변경시 고객 주문마감 유형코드를 재입력하셔야 합니다.';
                        }else {
                            returnMessage = '고객분류값 변경시 고객 주문마감 유형코드를 재입력하셔야 합니다.';
                        }

                        helper.showToast('warning', returnMessage);
                    }
                    component.set("v.objCustomer.PV_ODCLOSEGB__c", "none");
                }else {
                    helper.showToast(strStatus, strMessage);
                }
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();

                if(errors) {
                    if(errors[0] && errors[0].message) {

                        helper.showToast('ERROR', errors[0].message);
                        
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
            helper.doHideSpinner(component);
        });

        $A.enqueueAction(action);
    },
})