({    
    doSetMDMRequest: function (component, event, helper) {

    }
    //주소 Helper
    // API 호출시 검색어에 특수문자 혹은 OR, INSERT, UNION 등 SQL 예약어가 포함되는 경우
    // 보안장비가 SQL INJECTION 공격으로 간주하여 해당 IP를 차단 시킬 수 있어 필터링 추가
    ,doCheckSearchKey: function (sSearchKey) {
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

    doShowSpinner: function (component) {
        component.set("v.bIsShowSpinner", true);
    },

    doHideSpinner: function (component) {
        component.set("v.bIsShowSpinner", false);
    },

    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            key: "info_alt",
            type: type,
            message: message
        });

        evt.fire();
    },

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

    fnAddressSaveRecord: function (component) {
        //주소 입력 받은 부분 불러오기
        var addressField = component.get('v.objAddress.sRoadAddr');
        //상세주소 입력 받은 부분 불러오기
        var addressDetailField = component.get('v.objAddress.sAddrDetail');
        var sZipNo = component.get('v.objAddress.sZipNo');


        component.set('v.objCustomer.PV_ADRES_ROADADDR1__c', addressField);
        component.set('v.objCustomer.PV_ADRES_ROADADDR2__c', addressDetailField);
        component.set('v.objCustomer.PV_ADRES_ZIPCODE__c', sZipNo);

        component.set('v.isAddressModalOpen', false);

        /*
        component.set('v.roadNameAddress', addressField);
        component.set('v.detailAddress', addressDetailField);
        component.set('v.zipcodes', sZipNo);
        component.set('v.isAddressModalOpen', false);
        */
    },

    fnPrepage: function (component) {
        component.set("v.AddrInputDiv", false); //주소입력폼
        component.set("v.btnSave", false); //저장버튼
        component.set("v.searchForm", true); //저장버튼

        component.set("v.bIsSearchAddr", true);
        component.set("v.headerName", "도로명 주소 찾기");
    },

    /**
     * @description 토스트 메세지 출력 이벤트 발생
     * @param {string} type 메세지 유형 (success, error, info, warning, other)
     * @param {string} message 토스트에 보여질 메세지
     */
    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key: "info_alt",
            type: type,
            message: message
        });
        evt.fire();
    },

    /**
     * @description get contact data by opportunmity id
     */
    doGetContactData: function (component) {
        // Show spinner
        this.doShowSpinner(component);

        // Search contact
        var action = component.get("c.getContactsByOpportunity");

        action.setParams({
            "recordId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);

                if (data && data.length > 0) {
                    let contactData = [];
                    data.forEach((item, index) => {
                        contactData.push({
                            no: index + 1,
                            PV_NAME1_VK__c: item.LastName,
                            PV_TELF1_VK__c: item.Phone,
                            PV_EMAIL_VK__c: item.Email,
                            PV_PAFKT_VK__c: item.PV_PAFKT_VK__c,
                            PV_ABTNR_VK__c: item.Department,
                            Contact__c : item.Id
                        });
                    })
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
                this.showToast("error", "error get contact data");
            }
        });

        $A.enqueueAction(action);
    },

    onInputPhone: function (value) {        
        var returnValue = value
            .replace(/[^0-9]/g, '')
            .replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]{3,4})([0-9]{4})/g, "$1-$2-$3");
        /*
        var returnValue = value.replace(/[^0-9]/g, '').replace(/^(\d{0,3})(\d{0,4})(\d{0,4})$/g, "$1-$2-$3").replace(/(\-{1,2})$/g, "");
        */

        return returnValue;
    },

    // /**
    //  * @description save MDMRegRequestContact
    //  */
    // doSaveMDMRegRequestContact: function (component, myRecordId) {
    //     // Show spinner
    //     this.doShowSpinner(component);

    //     let contactSelected = component.get('v.contactSelected');
    //     console.log('contactSelected: ', contactSelected);
    //     if (contactSelected && contactSelected.length > 0) {
    //         contactSelected.forEach(contact => {
    //             delete contact['no'];

    //             contact.MDMRegRequestCustomer__c = myRecordId;

    //             var action = component.get("c.saveMDMRegRequestContact");

    //             action.setParams({
    //                 "listMDMRegRequestContact": contactSelected
    //             });
    //             action.setCallback(this, function (response) {
    //                 var state = response.getState();

    //                 if (state === "SUCCESS") {
    //                     var data = response.getReturnValue();
    //                     console.log('listMDMRegRequestContact: ', data);
    //                 } else {
    //                     // Toast message error
    //                     this.showToast("error", "Error Save MDMRegRequestContact");
    //                 }
    //             });

    //             $A.enqueueAction(action);
    //         })
    //     }
    // },

    // /**
    //  * @description save MDMRegRequestBank__c
    //  */
    // doSaveMDMRegRequestBank: function (component, myRecordId) {
    //     // Show spinner
    //     this.doShowSpinner(component);

    //     let bankSelected = component.get('v.bankSelected');
    //     if (bankSelected && bankSelected.length > 0) {
    //         bankSelected.forEach(contact => {
    //             delete contact['no'];

    //             contact.MDMRegRequestCustomer__c = myRecordId;

    //             var action = component.get("c.saveMDMRegRequestBank");

    //             action.setParams({
    //                 "listMDMRegRequestBank": bankSelected
    //             });
    //             action.setCallback(this, function (response) {
    //                 var state = response.getState();

    //                 if (state === "SUCCESS") {
    //                     var data = response.getReturnValue();
    //                     console.log('listMDMRegRequestBank: ', data);
    //                 } else {
    //                     // Toast message error
    //                     this.showToast("error", "Error Save MDMRegRequestBank");
    //                 }
    //             });

    //             $A.enqueueAction(action);
    //         })
    //     }
    // },
})