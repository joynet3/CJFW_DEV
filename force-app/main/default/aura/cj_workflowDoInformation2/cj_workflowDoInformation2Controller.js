({
    fnInit: function (component, event, helper) {
        console.log('fninit===================>' + component.get('v.recordId'));
        let elements = component.get('v.InforecordId');
        var i;
        for (i = 0; i < elements.length; i++) {

            if (elements[i].isChecked) {
                if (elements[i].LargeCode__c == '본점') {
                    component.set('v.custypes', 'C01');
                } else {
                    component.set('v.custypes', 'C02');
                }

                if (elements[i].getCategory__c == '기본정보') {
                    component.set('v.basicInfo', true);
                } else if (elements[i].getCategory__c == '회계정보') {
                    component.set('v.financialInfo', true);
                } else if (elements[i].getCategory__c == '영업정보') {
                    component.set('v.salesInfo', true);
                }
            }
        }
        //계정은 Init시 account에 자동입력

        var action = component.get("c.getAccountInfo");
        action.setParams({
            opportunityId: component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                //accountId
                const data = response.getReturnValue();
                console.log(JSON.stringify(data) + '=====Get 어카운트 ID');
                component.set('v.accountId', data[0].AccountId);
                component.set('v.pv_pernrempno', data[0].Account.fm_empId__c);
                component.set('v.pv_pernr', data[0].Account.OwnerId);
                component.set('v.accountgroup', data[0].Account.AccountGroup__c);

                
                //component.set('v.pv_adminmaempno',data[0].Account.fm_empId__c);
                //component.set('v.pv_adminma',data[0].Account.fm_empId__c);
            }
            
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(action);

        var collector = component.get("c.getDefaultInfo");
        collector.setParams({
            opportunityId: component.get('v.recordId')
        });

        collector.setCallback(this, function (response) {
            const state = response.getState();
            console.log('state : ' + state);
            if (state === "SUCCESS") {
                //accountId
                const data = response.getReturnValue();
                if (data.employeeNumber) {
                    component.set('v.objCustomer.REQACTORID__c', data.employeeNumber);
                }
                if (data.ownerNumber) {
                    component.set('v.objCustomer.PV_PERNR__c', data.ownerNumber.substring(0, 8));
                    component.set('v.objCustomer.PV_ORDERMA__c', data.ownerNumber);
                }
            }
            component.set("v.isLoading", false);
        });

        $A.enqueueAction(collector);

        //정렬키
        component.set('v.objCustomer.PV_ZUAWA__c', '009');
        //국가키
        component.set('v.objCustomer.PV_LAND1__c', 'KR');
        //매출형태
        component.set('v.objCustomer.PV_CESSION_KZ__c', '01');


        //조정계정
        component.set('v.objCustomer.PV_AKONT__c', '11311010');
        component.set('v.inputpv_akont', '11311010');


        //현금관리그룹
        component.set('v.objCustomer.PV_FDGRV__c', 'C1');
        //입금여부(FS만사용)
        component.set('v.objCustomer.PV_VRSDG__c', '100');
        //세금분류
        component.set('v.objCustomer.PV_TAXKDD__c', '1');
        //세금납부방법
        component.set('v.objCustomer.PV_KATR5__c', '5B');
        //국가키
        component.set('v.objCustomer.PV_LAND1__c', 'KR');
        component.set('v.inputpv_land1', 'KR');
        //통화
        component.set('v.objCustomer.PV_WAERS__c', 'KRW');
        component.set('v.inputpv_waers', 'KRW');
        //본점사용유무
        component.set('v.objCustomer.PV_HDOFFICEYN__c', true);

        //배송그룹
        component.set('v.objCustomer.PV_DELIGROUP__c', '00');
        component.set('v.inputpv_deligroup', '00');
    },
    //AMA 정보 변경시
    pvadmChanged: function (component, event, helper) {

        if (event.getSource().get("v.value") && event.getSource().get("v.value") != "") {

            var action = component.get("c.pvadmChanged");

            action.setParams({
                userId: fields
            });
            action.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    //accountId
                    const data = response.getReturnValue();
                    console.log(JSON.stringify(data) + '=====Get 어카운트 ID');

                    component.set('v.pv_adminmaempno', data.EmployeeNumber);
                }
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }
    },

    grpChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            //2022-12-29
            //var dateStr = new Date();
            //var dd    = dateStr.getDate();
            //var mm    = dateStr.getMonth()+1;
            //var yyyy  = dateStr.getFullYear();
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            //var dateComStr = yyyy+'-'+mm+'-'+dd;
            // console.log(fields+'날짜'); 
            // console.log(today+'시스템 날짜');
            if (fields <= today) {
                alert('영업그룹의 유효날짜는 오늘보다 커야 합니다.');
                component.set("v.objCustomer.PVRA_VKGRP__c", '');
                return;
            }
        }
    },
    cuhrChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            //2022-12-29
            //var dateStr = new Date();
            //var dd    = dateStr.getDate();
            //var mm    = dateStr.getMonth()+1;
            //var yyyy  = dateStr.getFullYear();
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            //var dateComStr = yyyy+'-'+mm+'-'+dd;
            // console.log(fields+'날짜'); 
            // console.log(today+'시스템 날짜');
            if (fields <= today) {
                alert('고객분류의 유효날짜는 오늘보다 커야 합니다.');
                component.set("v.objCustomer.PVRA_CUHR1__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_CUHR1__c", fields);
            }
        }
    },

    kondagrpChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            //2022-12-29
            //var dateStr = new Date();
            //var dd    = dateStr.getDate();
            //var mm    = dateStr.getMonth()+1;
            //var yyyy  = dateStr.getFullYear();
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            //var dateComStr = yyyy+'-'+mm+'-'+dd;
            // console.log(fields+'날짜'); 
            // console.log(today+'시스템 날짜');
            if (fields <= today) {
                alert('가격그룹의 유효날짜는 오늘보다 커야 합니다.');
                component.set("v.objCustomer.PVRA_KONDA__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_KONDA__c", fields);
            }
        }
    },

    kvgr1Changed: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            //2022-12-29
            //var dateStr = new Date();
            //var dd    = dateStr.getDate();
            //var mm    = dateStr.getMonth()+1;
            //var yyyy  = dateStr.getFullYear();
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            //var dateComStr = yyyy+'-'+mm+'-'+dd;
            // console.log(fields+'날짜'); 
            // console.log(today+'시스템 날짜');
            if (fields <= today) {
                alert('단가그룹의 유효날짜는 오늘보다 커야 합니다.');
                component.set("v.objCustomer.PVRA_KVGR1__c", '');
                return;
            } else {
                component.set('v.objCustomer.PVRA_KVGR1__c', fields);
            }
        }
    },
    dangrpChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            //2022-12-29
            //var dateStr = new Date();
            //var dd    = dateStr.getDate();
            //var mm    = dateStr.getMonth()+1;
            //var yyyy  = dateStr.getFullYear();
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            //var dateComStr = yyyy+'-'+mm+'-'+dd;
            // console.log(fields+'날짜'); 
            // console.log(today+'시스템 날짜');
            if (fields <= today) {
                alert('담당(MA)의 유효날짜는 오늘보다 커야 합니다.');
                component.set("v.objCustomer.PVRA_PERNR__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_PERNR__c", fields);
            }
        }
    },

    logiscenterChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields <= today) {
                alert('FW 출고센터 유효날짜는 오늘보다 커야 합니다.');
                component.set("v.objCustomer.PVRA_LOGISCENTER__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_LOGISCENTER__c", fields);
            }
        }
    },

    oldbizplzceChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            //2022-12-29
            //var dateStr = new Date();
            //var dd    = dateStr.getDate();
            //var mm    = dateStr.getMonth()+1;
            //var yyyy  = dateStr.getFullYear();
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            //var dateComStr = yyyy+'-'+mm+'-'+dd;
            // console.log(fields+'날짜'); 
            // console.log(today+'시스템 날짜'); 
            if (fields <= today) {
                alert('경로사업부의 유효날짜는 오늘보다 커야 합니다.');
                component.set("v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c", fields);
            }
        }
    },

    //MA 정보 변경시
    pvChanged: function (component, event, helper) {
        var fields = component.get("v.pv_pernr");
        console.log(fields + '=====================================');
        if (fields != event.getSource().get("v.value") && event.getSource().get("v.value") != "") {

            var action = component.get("c.changedMA");

            action.setParams({
                userId: fields
            });
            action.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    //accountId
                    const data = response.getReturnValue();
                    console.log(JSON.stringify(data) + '=====Get 어카운트 ID');

                    component.set('v.pv_pernrempno', data.EmployeeNumber);
                    component.set('v.pv_pernr', data.id);
                }
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }
    },


    //영업정보 등록시
    customerhandleSuccess: function (component, event, helper) {
        var record = event.getParam("response");

        var myRecordId = record.id;
        //create MDMRegRequestContact after success
        helper.doSaveMDMRegRequestContact(component, myRecordId);

        //create MDMRegRequestContact after success
        helper.doSaveMDMRegRequestBank(component, myRecordId);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "message": "정보가 등록되었습니다."
        });
        toastEvent.fire();
        component.set("v.isModalOpen", false);
        var compEvents = component.getEvent("componentEventFired");
        compEvents.setParams({
            "recordId": myRecordId,
            "isOpen": component.get("v.isModalOpen")
        });
        compEvents.fire();
        component.set("v.isLoading", false);
    },

    handleError: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        var errorMessage = event.getParam("message") + "\n" + event.getParam("detail");
        toastEvent.setParams({
            "type": "error",
            "message": errorMessage
        });
        toastEvent.fire();
        component.set("v.isLoading", false);
        component.set("v.isDisabled", false);
    },


    paycustchanged: function (component, event, helper) {
        var fields = String(event.getParam("value"));
        if (fields != '' || fields != undefined) {
            var action = component.get("c.getCustomerId");

            action.setParams({
                accountId: fields
            });
            action.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    //accountId
                    const data = response.getReturnValue();
                    component.set('v.objCustomer.PV_PAYCUST__c', data);
                }
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);

            component.set('v.isReadOnlyPAYCust', false);
        }
    },
    chargechanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != '' || fields != undefined) {
            var action = component.get("c.getCustomerId");

            action.setParams({
                accountId: fields
            });
            action.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    //accountId
                    const data = response.getReturnValue();
                    component.set('v.objCustomer.PV_CHARGECUST__c', data);
                }
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
            
            component.set('v.isReadOnlyPVCharge', false);
        }
    },
    chargehandleClick: function (component, event, helper) {
        component.set('v.objCustomer.IsSelf_PV_CHARGECUST__c', true);
        component.set('v.objCustomer.PV_CHARGECUST__c', '##SELFID##');
        component.set('v.objCustomer.PV_CHARGECUST_lu__c', component.get('v.accountId'));
        component.set('v.isReadOnlyPVCharge', false);
    },
    payhandleClick: function (component, event, helper) {
        component.set('v.objCustomer.IsSelf_PV_PAYCUST__c', true);
        component.set('v.objCustomer.PV_PAYCUST__c', '##SELFID##');
        component.set('v.objCustomer.PV_PAYCUST_lu__c', component.get('v.accountId'));
        component.set('v.isReadOnlyPAYCust', false);
    },
    //기본정보
    customerhandleSubmit: function (component, event, helper) {
        event.preventDefault();

        // var fields = event.getParam('fields');
        var fields = component.get('v.objCustomer')
        if (!fields.PV_NAME1__c || fields.PV_NAME1__c == '') {
            alert('고객명(영문명 포함) 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_STCD2__c || fields.PV_STCD2__c == '') {
            alert('사업자등록번호 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_STCD4__c || fields.PV_STCD4__c == '') {
            alert('종사업자번호 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_GFORM__c || fields.PV_GFORM__c == '') {
            alert('법적상태 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_J_1KFREPRE__c || fields.PV_J_1KFREPRE__c == '') {
            alert('대표자이름 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_STCD1__c || fields.PV_STCD1__c == '') {
            alert('대표자 생년월일(명칭변경) 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_J_1KFTBUS__c || fields.PV_J_1KFTBUS__c == '') {
            alert('업태 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_J_1KFTIND__c || fields.PV_J_1KFTIND__c == '') {
            alert('업종 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_TELF1__c || fields.PV_TELF1__c == '') {
            alert('전화번호 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_FITYP__c || fields.PV_FITYP__c == '') {
            alert('과세유형 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_KNVKTYPE__c || fields.PV_KNVKTYPE__c == '') {
            alert('주문유형 필드를 완료하십시오.');
            return;
        }
        if (!component.get('v.objCustomer.PV_REGIO_lu__c') || component.get('v.objCustomer.PV_REGIO_lu__c') == '') {
            alert('지역 필드를 완료하십시오.');
            return;
        }

        //set field from input
        fields.PVRA_VKGRP__c = component.get('v.objCustomer.PVRA_VKGRP__c');
        fields.PVRA_PERNR__c = component.get('v.objCustomer.PVRA_PERNR__c');
        fields.PV_SUBSIDIARYYN__c = component.get('v.objCustomer.PV_SUBSIDIARYYN__c');
        fields.PVRA_CUHR1__c = component.get('v.objCustomer.PVRA_CUHR1__c');
        fields.PVRA_KONDA__c = component.get('v.objCustomer.PVRA_KONDA__c');
        fields.PVRA_KVGR1__c = component.get('v.objCustomer.PVRA_KVGR1__c');
        fields.PVRA_OLD_BIZPLACE_NEW__c = component.get('v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c');
        fields.PV_SHAPE__c = component.get('v.objCustomer.PV_SHAPE__c');

        console.log('>>>>>>>>>>>>>>' + JSON.stringify(fields));

        //구코드 제어
        var regex1 = /^(\d{0,10}|)$/;
        //사업자등록번호 제어
        var regex2 = /^(\d{10}|)$/;
        //법적상태 제어
        var regex3 = /^(\d{13}|)$/;
        //생년월일
        var regex4 = /^(?:[0-9]{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[1,2][0-9]|3[0,1]))$|^$/;
        //전화번호
        var regex5 = /^\d{2,3}-\d{3,4}-\d{4}$/;;
        //팩스번호 
        var regex6 = /^\d{2,3}-\d{3,4}-\d{4}$/;
        //약정회전일
        var regex7 = /^\d{1,3}$|^$/;
        //외형(정원)
        var regex8 = /^\d{0,11}$/;

        // test save MDMRegRequestContact defaule myRecordId = 'a0o0w000006kl5EAAQ'
        // helper.doSaveMDMRegRequestContact(component, 'a0o0w000006kl5EAAQ');

        // test save MDMRegRequestContact defaule myRecordId = 'a0o0w000006kl5EAAQ'
        // helper.doSaveMDMRegRequestBank(component, 'a0o0w000006kl5EAAQ');

        //구코드 제어

        if (component.get('v.objCustomer.PV_OLDCD__c') != "" && component.get('v.objCustomer.PV_OLDCD__c') != undefined) {
            if (!regex1.test(component.get('v.objCustomer.PV_OLDCD__c'))) {
                alert('구코드(As-Is): 구코드는 10자리 이하의 숫자만 입력이 가능합니다.');
                component.set('v.objCustomer.PV_OLDCD__c', "");
                return;
            }
        }
        //사업자 제어
        console.log(component.get('v.objCustomer.PV_STCD2__c') + '=================');
        if (component.get('v.objCustomer.PV_STCD2__c') != '' && component.get('v.objCustomer.PV_STCD2__c') != undefined) {
            if (!regex2.test(component.get('v.objCustomer.PV_STCD2__c'))) {

                alert('옳바른 형식의 사업자번호가 아닙니다. 10자리 숫자만 입력이 가능합니다.');
                component.set('v.objCustomer.PV_STCD2__c', "");
                return;
            }
        }

        if (component.get('v.objCustomer.PV_STCD3__c') != "" && component.get('v.objCustomer.PV_STCD3__c') != undefined) {
            if (!regex3.test(component.get('v.objCustomer.PV_STCD3__c'))) {
                alert('옳바른 형식의 법인코드가 아닙니다. 13자리 숫자만 입력이 가능합니다.');
                component.set('v.objCustomer.PV_STCD3__c', "");
                return;
            }
        }
        if (component.get('v.objCustomer.PV_STCD1__c') != "" && component.get('v.objCustomer.PV_STCD1__c') != undefined) {
            if (!regex4.test(component.get('v.objCustomer.PV_STCD1__c'))) {
                alert('옳바른 형식의 대표자 생년월일이 아닙니다. 6자리만 입력이 가능합니다.');
                component.set('v.objCustomer.PV_STCD1__c', "");
                return;
            }
        }
        console.log(regex5.test(component.get('v.objCustomer.PV_TELF1__c')));

        if (component.get('v.objCustomer.PV_TELF1__c') != "" && component.get('v.objCustomer.PV_TELF1__c') != undefined) {
            if (!regex5.test(component.get('v.objCustomer.PV_TELF1__c'))) {
                alert('옳바른 형식의 전화번호가 아닙니다. "-" 값을 포함하여 입력');
                component.set('v.objCustomer.PV_TELF1__c', "");
                return;
            }
        }
        if (component.get('v.objCustomer.PV_TELFX__c') != "" && component.get('v.objCustomer.PV_TELFX__c') != undefined) {
            if (!regex6.test(component.get('v.objCustomer.PV_TELFX__c'))) {
                alert('옳바른 형식의 팩스번호가 아닙니다. "-" 값을 포함하여 입력');
                component.set('v.objCustomer.PV_TELFX__c', "");
                return;
            }
        }
        if (component.get('v.objCustomer.PV_KULTG__c') != "" && component.get('v.objCustomer.PV_KULTG__c') != undefined) {
            if (!regex7.test(component.get('v.objCustomer.PV_KULTG__c'))) {
                alert('옳바른 형식의 약정회전일이 아닙니다.');
                component.set('v.objCustomer.PV_KULTG__c', "");
                return;
            }
        }

        if (component.get('v.objCustomer.PV_SHAPE__c') != "" && component.get('v.objCustomer.PV_SHAPE__c') != undefined) {
            if (!regex8.test(component.get('v.objCustomer.PV_SHAPE__c'))) {
                alert('옳바른 형식의 약정회전일이 아닙니다.');
                component.set('v.objCustomer.PV_SHAPE__c', "");
                return;
            }
        }

        //console.log(component.find("pv_subsi").get('v.checked')+'관계사여부');
        //console.log(component.get('v.objCustomer.PV_VBUND__c')+'관계사코드');
        if (component.find("pv_subsi").get('v.checked') == true && component.get('v.objCustomer.PV_VBUND__c') == undefined) {
            alert('관사코드를 입력계해주세요');
            return;
        }

        if (component.get('v.objCustomer.PV_OLD_BIZPLACE_NEW__c') == undefined || component.get('v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c') == undefined) {
            alert('경로(사업부)는 및 경로사업부(유효기간)은 필수 값 입니다.');
            return;
        }

        if (component.get('v.objCustomer.PV_VKGRP__c') != undefined && component.get('v.objCustomer.PVRA_VKGRP__c') == undefined) {
            alert('영업그룹 입력시 영업그룹 유효기간은 필수 값 입니다.');
            return;
        }
        if (component.get('v.objCustomer.PV_CUHR1__c') != undefined && component.get('v.objCustomer.PVRA_CUHR1__c') == undefined) {
            alert('고객분류 입력시 고객분류 유효기간은 필수 값 입니다.');
            return;
        } else if (component.get('v.objCustomer.PV_CUHR1__c') != undefined && component.get('v.v.isRequirePVShape') == true && component.get('v.objCustomer.PV_SHAPE__c') == undefined) {
            alert('고객분류에 맞는 외형(정원)을 입력해 주세요');
            return;
        }
        if (component.get('v.objCustomer.PV_KONDA__c') != undefined && component.get('v.objCustomer.PVRA_KONDA__c') == undefined) {
            alert('가격그룹 입력시 가격그룹 유효기간은 필수 값 입니다.');
            return;
        }

        if (component.get('v.objCustomer.PV_KVGR1__c') != undefined && component.get('v.objCustomer.PVRA_KVGR1__c') == undefined) {
            alert('단가그룹 입력시 단가그룹 유효기간은 필수 값 입니다.');
            return;
        }

        if (component.get('v.pv_pernr') != undefined && component.get('v.objCustomer.PVRA_PERNR__c') == undefined) {
            alert('담당MA 입력시 담당MA 유효기간은 필수 값 입니다.');
            return;
        }
        if (!fields.PV_VKGRP__c || fields.PV_VKGRP__c == '') {
            alert('영업그룹 필드를 완료하십시오.');
            return;
        }
        if (!fields.PV_STCDT__c || fields.PV_STCDT__c == '') {
            alert('세금계산서 발행 유형 필드를 완료하십시오.');
            return;
        }

        console.log(JSON.stringify(component.get('v.objCustomer')) + '전체 입력 값');

        // component.find("generalrecordEditForm").submit(fields);
        // component.find('bankrecordEditForm').submit();
        let contactSelected = component.get('v.contactSelected');
        if (contactSelected && contactSelected.length > 0) {
            contactSelected.forEach(contact => {
                contact.PV_NO__c = contact.no;
                delete contact['no'];
            });
        }

        let bankSelected = component.get('v.bankSelected');
        console.log('bankSelected: ', JSON.stringify(bankSelected));
        if (bankSelected && bankSelected.length > 0) {
            bankSelected.forEach(bank => {
                delete bank['no'];
            });
        }

        var saveRecords = component.get("c.saveRecords");
        saveRecords.setParams({
            customer : fields,
            contacts : contactSelected,
            banks : bankSelected
        });
        saveRecords.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                if (result !== 'error') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": "정보가 등록되었습니다."
                    });
                    toastEvent.fire();
                    component.set("v.isModalOpen", false);

                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                    component.set("v.isLoading", false);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    var errorMessage = '오류가 발생했습니다 관리자에게 문의하여 주시기 바랍니다';
                    toastEvent.setParams({
                        "type": "error",
                        "message": errorMessage
                    });
                    toastEvent.fire();
                    component.set("v.isLoading", false);
                    component.set("v.isDisabled", false);
                }
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(saveRecords);
    },
    openAddressModal: function (component, event, helper) {
        component.set("v.isAddressModalOpen", true);
    },
    closeModel: function (component, event, helper) {
        // Set isModalOpen attribute to false  
        var compEvents = component.getEvent("componentEventFired");
        console.log(component.get("v.isModalOpen") + ' 모달 창 닫기');

        compEvents.setParams({
            "isOpen": component.get("v.isModalOpen")
        });
        compEvents.fire();

    },

    //주소 Ctrl 
    fnHandleKeyup: function (component, event, helper) {
        var isEnterKey = event.keyCode === 13;

        if (isEnterKey) {
            // Search key validation
            var bCheckedSearchKey = helper.doCheckSearchKey(component.find("searchKey").get("v.value"));

            if (bCheckedSearchKey) {
                // Search     
                helper.doSearchAddress(component, 1, 1);
            }
        }
    },
    fnPrevPage: function (component, event, helper) {
        var intPageNo = component.get("v.intCurrentPage") - 1;
        var intPageIdx = component.get("v.intPageIdx") - component.get("v.intCntPerPage");

        helper.doSearchAddress(component, intPageNo, intPageIdx);
    },

    fnNextPage: function (component, event, helper) {
        var intPageNo = component.get("v.intCurrentPage") + 1;
        var intPageIdx = component.get("v.intPageIdx") + component.get("v.intCntPerPage");

        helper.doSearchAddress(component, intPageNo, intPageIdx);
    },
    fnClickRoadAddr: function (component, event, helper) {
        var idx = event.currentTarget.dataset.idx;
        var listAddress = component.get("v.listAddress");
        var objAddress = listAddress[idx];

        console.log(objAddress);
        component.set("v.objAddress", objAddress);

        var hasSaveFunc = component.get("v.hasSaveFunc");
        helper.doFireEvent(component, hasSaveFunc ? "SELECT" : "CLOSE");
    },
    fnKeyUpModal: function (component, event, helper) {
        if (event.keyCode === 27) { // ESC
            helper.doFireEvent(component, "CLOSE");
        }
    },
    //주소 창 닫기
    fnSearchClose: function (component, event, helper) {
        component.set('v.isAddressModalOpen', false);
    },
    fnSave: function (component, event, helper) {
        console.log('save data');
        helper.fnSaveRecord(component);
    },
    fnPrepage: function (component, event, helper) {
        helper.fnPrepage(component);
    },

    handleCmpEvent: function (component, event) {
        var listStr = ['3194-001', '3208-001', '3209-001', '3210-001', '3211-001',
            '3212-001', '3213-001', '3214-001', '3215-001', '3216-001',
            '3217-001', '3218-001', '3219-001', '3220-001', '3221-001',
            '3222-001', '3223-001', '3224-001']
        var code = component.get('v.objCustomer.PV_CUHR1__c');
        component.set('v.isRequirePVShape', listStr.includes(code));
        console.log('code ' + code);

    },
    handleztermEvent: function (component, event) {
        var code = component.get('v.objCustomer.PV_ZTERM_VV__c');
        console.log('code1111' + code);
        switch (code) {
            case 'A103':
                console.log('code2222' + code);
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
    subsidiChange: function (component, event) {
        var compares = component.find("pv_subsi").get('v.checked');
        console.log(compares + '<<<<');
        if (compares === true) {
            component.set('v.isRequireOLDBIZPlace', true);
        } else {
            component.set('v.isRequireOLDBIZPlace', false);
        }
    },

    //contact modal
    setContactModal: function (component, event, helper) {
        helper.doGetContactData(component);
    },

    setCloseContactModal: function (component, event) {
        component.set('v.isContactModalOpen', false);
    },

    fnContactSelected: function (component, event) {
        let contactData = component.get('v.contactData');
        let contacts = component.find('select-contact');
        let contactSelected = [];
        if (contacts && contacts.length > 0 && contactData && contactData.length > 0) {
            contacts.forEach(contact => {
                if (contact.get('v.checked')) {
                    Array.prototype.push.apply(contactSelected, contactData.filter(item => item.no == contact.get('v.class')));
                }
            })
        }
        let no = 1;
        contactSelected.forEach(con => {
            con.no = no;
            no = no + 1;
        });
        console.log('contactSelected: ', contactSelected);
        component.set('v.contactSelected', contactSelected.slice(0, 5));
        component.set('v.isContactModalOpen', false);
    },

    fnSelectContact: function (component, event) {
        let contacts = component.find('select-contact');
        let isSelectAll = true;
        if (contacts && contacts.length > 0) {
            contacts.forEach(contact => {
                if (contact.get('v.checked') == false) isSelectAll = false;
            })
        }
        let selectAllContact = component.find('select-all-contact');
        selectAllContact.set('v.checked', isSelectAll);
    },

    fnSelectAllContact: function (component, event) {
        let selectAllContact = component.find('select-all-contact');
        let contacts = component.find('select-contact');
        if (contacts && contacts.length > 0) {
            contacts.forEach(contact => {
                contact.set('v.checked', selectAllContact.get('v.checked'))
            })
        }
    },

    fnPVKNVKGB: function (component, event) {
        let recordNo = event.getSource().get("v.class");
        let contactData = component.get('v.contactData');
        if (contactData && contactData.length > 0 && recordNo) {
            contactData.forEach(contact => {
                if (contact.no == recordNo) contact.PV_KNVKGB__c = event.getSource().get("v.value")
            })
        }
    },

    fnPVTALKTVK: function (component, event) {
        let recordNo = event.getSource().get("v.class");
        let contactData = component.get('v.contactData');
        if (contactData && contactData.length > 0 && recordNo) {
            contactData.forEach(contact => {
                if (contact.no == recordNo) contact.PV_TALKT_VK__c = event.getSource().get("v.value")
            })
        }
    },

    //bank modal

    setBankModal: function (component, event, helper) {
        component.set('v.isBankModalOpen', true);
        let bankData = component.get('v.bankData');
        bankData = [{
            no: 1,
            PV_ACTCLOSEYN__c: 'false'
        }];
        component.set('v.bankData', bankData)
    },

    setCloseBankModal: function (component, event) {
        component.set('v.isBankModalOpen', false);
    },

    fnChangeBankData: function (component, event) {
        let recordNo = event.getSource().get("v.class");
        let bankData = component.get('v.bankData');
        if (recordNo && bankData) {
            bankData.forEach(bank => {
                if (bank.no == recordNo) {
                    if (event.getSource().get("v.fieldName")) {
                        bank[event.getSource().get("v.fieldName")] = event.getSource().get("v.type") == 'checkbox' ? event.getSource().get("v.checked") : event.getSource().get("v.value")
                    } else {
                        bank[event.getSource().get("v.label")] = event.getSource().get("v.type") == 'checkbox' ? event.getSource().get("v.checked") : event.getSource().get("v.value")
                    }

                }
            })
        }
        console.log('bankData: ', bankData);
    },

    addBankItem: function (component, event) {
        let bankData = component.get('v.bankData');
        let bankItem = { no: bankData.length + 1, PV_ACTCLOSEYN__c: 'false' };
        bankData.push(bankItem);
        component.set('v.bankData', bankData);
    },

    removeBankItem: function (component, event) {
        let recordNo = event.getSource().get("v.class");
        let bankData = component.get('v.bankData');

        let indexBankItem = bankData.findIndex(x => x.no == recordNo);
        if (indexBankItem > -1) {
            bankData.splice(indexBankItem, 1);
        }
        bankData.forEach((item, index) => {
            item.no = index + 1;
        })
        component.set('v.bankData', bankData);
    },

    fnBankSelected: function (component, event) {
        component.set('v.bankSelected', component.get('v.bankData'));
        component.set('v.isBankModalOpen', false);
    },

    setPV_KDGRP: function (component, event) {
        console.log(component.find("PV_KDGRP").get("v.value"));
        component.find("PV_KDGRP").get("v.value");
        component.set('v.objCustomer.PV_KDGRP__c', component.find("PV_KDGRP").get("v.value"));
    }
})