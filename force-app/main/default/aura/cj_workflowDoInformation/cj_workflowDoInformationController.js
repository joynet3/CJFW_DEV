({
    fnInit: function (component, event, helper) {
        console.log('fninit===================>' + component.get('v.recordId'));

        //계정은 Init시 account에 자동입력
        var recordId = component.get('v.recordId');

        var mdmCustomerType = '';

        let elements = component.get('v.InforecordId');

        for(var i = 0; i < elements.length; i++) {
            if(elements[i].isChecked) {
                if(elements[i].LargeCode__c == '본점') {
                    mdmCustomerType = 'MDMParent';
                }else if(elements[i].LargeCode__c == '판매처'){
                    mdmCustomerType = 'MDMChild';
                }
            }
        }

        var action = component.get("c.doInit");
        action.setParams({
            recordId: recordId,
            mdmCustomerType : mdmCustomerType
        });

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {

                var returnVal = response.getReturnValue();

                //console.log('===============> returnVal : '+JSON.stringify(returnVal));

				var strStatus = returnVal.strStatus;
				var strMessage = returnVal.strMessage;

				if(strStatus == "SUCCESS") {
                    console.log('============> returnVal.strObjectType : '+returnVal.strObjectType);
                    component.set("v.strObjectType", returnVal.strObjectType);

                    if(returnVal.strObjectType == 'Opportunity') {

                        var objOpportunity = returnVal.objOpportunity;
                        var objUser = returnVal.objUser;

                        if(objUser) {
                            component.set('v.objCustomer.REQACTORID__c', objUser.EmployeeNumber);
                        }

                        component.set('v.objCustomer.PV_PERNR__c', objOpportunity.Account.Owner.EmployeeNumber);
                        component.set('v.objCustomer.PV_PERNR_lu__c', objOpportunity.Account.OwnerId);                        
                        component.set('v.objCustomer.PV_ORDERMA__c', objOpportunity.Account.Owner.EmployeeNumber);

                        console.log('============> objOpportunity.AccountId : '+objOpportunity.AccountId);
                        /*
                        component.set('v.accountId', objOpportunity.AccountId);
                        component.set('v.pv_pernrempno', objOpportunity.Account.Owner.EmployeeNumber);
                        component.set('v.pv_pernr', objOpportunity.Account.OwnerId);                        
                        */

                        component.set('v.objCustomer.RecordTypeId', returnVal.MDMRecordTypeId);
                        component.set('v.objCustomer.PV_NAME1__c', objOpportunity.Account.Name);

                        // 2023-01-03 Opportunity, Account, ProcessId__c 추가
                        var processId = component.get("v.processId");

                        console.log('============> processId : '+processId);

                        component.set('v.objCustomer.Opportunity__c', objOpportunity.Id);
                        component.set('v.objCustomer.Account__c', objOpportunity.AccountId);
                        component.set('v.objCustomer.PROCID__c', processId);

                        // 고객계정그룹
                        component.set('v.objCustomer.PV_KTOKD__c', 'Z200');                        
                        //국가키
                        component.set('v.objCustomer.PV_LAND1__c', 'KR');
                        //매출형태
                        component.set('v.objCustomer.PV_CESSION_KZ__c', '01');

                        //정렬키
                        component.set('v.objCustomer.PV_ZUAWA__c', '009');
                        component.set('v.inputpv_zuawa', '009');
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

                        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        component.set("v.objCustomer.PVRA_VKGRP__c", today);
                        component.set("v.objCustomer.PVRA_PERNR__c", today);
                        component.set("v.objCustomer.PVRA_CUHR1__c", today);
                        component.set("v.objCustomer.PVRA_KONDA__c", today);
                        component.set("v.objCustomer.PVRA_KVGR1__c", today);
                        component.set("v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c", today);

                        var objCustomer = component.get("v.objCustomer");

                        console.log('====================> objCustomer : '+JSON.stringify(objCustomer));
                        console.log('Id : ' + component.get("v.objCustomer.Id"));

                        // 고객유형
                        component.set("v.objCustomer.PV_CUSTTYPE__c", 'C01');
                    }else {

                        var objMDMRegReqCustomer = returnVal.objMDMRegReqCustomer;

                        component.set("v.objCustomer", objMDMRegReqCustomer);            
                        // 고객유형            
                        //component.set("v.custypes", objMDMRegReqCustomer.PV_CUSTTYPE__c);
                        
                        // ============= 일반정보 =============
                        // 영업그룹
                        component.set("v.inputpv_vkgrp", objMDMRegReqCustomer.PV_VKGRP__c);
                        // 세금계산서발행유형코드
                        component.set("v.inputpv_stcdt", objMDMRegReqCustomer.PV_STCDT__c);
                        // 국가키
                        component.set("v.inputpv_land1", objMDMRegReqCustomer.PV_LAND1__c);
                        // 지역
                        component.set("v.inputpv_regio", objMDMRegReqCustomer.PV_REGIO__c);
                        // ============= 회계정보 =============
                        // 정렬키
                        component.set("v.inputpv_zuawa", objMDMRegReqCustomer.PV_ZUAWA__c);
                        // 조정계정
                        component.set("v.inputpv_akont", objMDMRegReqCustomer.PV_AKONT__c);

                        // ============= 영업정보 =============
                        // 고객분류
                        component.set("v.inputpv_cuhr1", objMDMRegReqCustomer.PV_CUHR1__c);
                        // 가격그룹
                        component.set("v.inputpv_konda", objMDMRegReqCustomer.PV_KONDA__c);
                        // 단가그룹
                        component.set("v.inputpv_kvgr1", objMDMRegReqCustomer.PV_KVGR1__c);
                        // 통화
                        component.set("v.inputpv_waers", objMDMRegReqCustomer.PV_WAERS__c);
                        // 지급조건
                        component.set("v.inputpv_zterm_vv", objMDMRegReqCustomer.PV_ZTERM_VV__c);
                        // 경로사업부
                        component.set("v.inputpv_old_bizplace_new", objMDMRegReqCustomer.PV_OLD_BIZPLACE_NEW__c);
                        // 배송그룹
                        component.set("v.inputpv_deligroup", objMDMRegReqCustomer.PV_DELIGROUP__c);

                    }

                    // 2023-01-04 본점, 판매처는 무조건 3개의 데이터를 입력하도록 수정
                    component.set('v.basicInfo', true);
                    component.set('v.financialInfo', true);
                    component.set('v.salesInfo', true);

                    /*
                    let elements = component.get('v.InforecordId');
                    for (var i = 0; i < elements.length; i++) {

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
                    */
                }else {
                    helper.showToast(strStatus, strMessage);
                }
            }
            component.set("v.isLoading", false);
        });

        $A.enqueueAction(action);

        /*
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
        */
    },
    //AMA 정보 변경시
    pvadmChanged: function (component, event, helper) {
        var value = event.getSource().get("v.value");

        console.log('========> value : '+value);

        if (value && value != "") {
            var action = component.get("c.pvadmChanged");

            action.setParams({
                userId: value
            });
            action.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    //accountId
                    const data = response.getReturnValue();
                    console.log(JSON.stringify(data) + '=====Get 어카운트 ID');

                    component.set('v.objCustomer.PV_ADMINMA__c', data.EmployeeNumber);
                }
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }else {
            component.set('v.objCustomer.PV_ADMINMA__c', '');
        }
    },

    grpChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields <= today) {
                alert('영업그룹의 유효날짜는 오늘보다 커야 합니다.');
                component.set("v.objCustomer.PVRA_VKGRP__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_VKGRP__c", fields);
            }
        }
    },
    cuhrChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields > today) {
                alert('고객분류의 유효날짜는 오늘보다 같거나 작아야 합니다.');
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
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields > today) {
                alert('가격그룹의 유효날짜는 오늘보다 같거나 작아야 합니다.');
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
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields < today) {
                alert('단가그룹의 유효날짜는 오늘보다 같거나 커야 합니다.');
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
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields > today) {
                alert('담당(MA)의 유효날짜는 오늘보다 같거나 작아야 합니다.');
                component.set("v.objCustomer.PVRA_PERNR__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_PERNR__c", fields);
            }
        }
    },
    oldbizplzceChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields > today) {
                alert('경로사업부의 유효날짜는 오늘보다 같거나 작아야 합니다.');
                component.set("v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c", fields);
            }
        }
    },

    //MA 정보 변경시
    pvChanged: function (component, event, helper) {
        var value = event.getSource().get("v.value");

        console.log('==================> value : '+value);
        
        if(value && value != "") {

            var action = component.get("c.changedMA");

            action.setParams({
                userId: value
            });

            action.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    //accountId
                    const data = response.getReturnValue();
                    console.log(JSON.stringify(data) + '=====Get 어카운트 ID');

                    component.set('v.objCustomer.PV_PERNR__c', data.EmployeeNumber);
                }
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }
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
        component.set('v.objCustomer.PV_CHARGECUST_lu__c', component.get('v.objCustomer.Account__c'));
        component.set('v.isReadOnlyPVCharge', false);
    },
    payhandleClick: function (component, event, helper) {
        component.set('v.objCustomer.IsSelf_PV_PAYCUST__c', true);
        component.set('v.objCustomer.PV_PAYCUST__c', '##SELFID##');
        component.set('v.objCustomer.PV_PAYCUST_lu__c', component.get('v.objCustomer.Account__c'));
        component.set('v.isReadOnlyPAYCust', false);
    },
    //기본정보
    fnSave: function (component, event, helper) {
        event.preventDefault();

        helper.doShowSpinner(component);

        var isError = false;
        var errorMsg = '';

        var fields = component.get('v.objCustomer');

        //set field from input
        /*
        fields.PVRA_VKGRP__c = component.get('v.objCustomer.PVRA_VKGRP__c');
        fields.PVRA_PERNR__c = component.get('v.objCustomer.PVRA_PERNR__c');
        fields.PV_SUBSIDIARYYN__c = component.get('v.objCustomer.PV_SUBSIDIARYYN__c');
        fields.PVRA_CUHR1__c = component.get('v.objCustomer.PVRA_CUHR1__c');
        fields.PVRA_KONDA__c = component.get('v.objCustomer.PVRA_KONDA__c');
        fields.PVRA_KVGR1__c = component.get('v.objCustomer.PVRA_KVGR1__c');
        fields.PVRA_OLD_BIZPLACE_NEW__c = component.get('v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c');
        fields.PV_SHAPE__c = component.get('v.objCustomer.PV_SHAPE__c');
        */

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

        // var fields = event.getParam('fields');

        if (!fields.PV_NAME1__c || fields.PV_NAME1__c == '') {
            isError = true;
            errorMsg = '고객명(영문명 포함) 필드를 완료하십시오.';
        }
        else if (!fields.PV_J_1KFREPRE__c || fields.PV_J_1KFREPRE__c == '') {
            isError = true;
            errorMsg = '대표자이름 필드를 완료하십시오.';
        }
        else if (!fields.PV_J_1KFTBUS__c || fields.PV_J_1KFTBUS__c == '') {
            isError = true;
            errorMsg = '업태 필드를 완료하십시오.';
        }
        else if (!fields.PV_TELF1__c || fields.PV_TELF1__c == '') {
            isError = true;
            errorMsg = '전화번호 필드를 완료하십시오.';
        }
        else if (!fields.PV_PAYCUST_lu__c || fields.PV_PAYCUST_lu__c == '') {
            isError = true;
            errorMsg = '지급처 필드를 완료하십시오.';
        }
        else if (!fields.PV_STCD2__c || fields.PV_STCD2__c == '') {
            isError = true;
            errorMsg = '사업자등록번호 필드를 완료하십시오.';
        }
        else if (!fields.PV_GFORM__c || fields.PV_GFORM__c == '') {
            isError = true;
            errorMsg = '법적상태 필드를 완료하십시오.';
        }
        else if (!fields.PV_STCD1__c || fields.PV_STCD1__c == '') {
            isError = true;
            errorMsg = '대표자 생년월일(명칭변경) 필드를 완료하십시오.';
        }
        else if (!fields.PV_J_1KFTIND__c || fields.PV_J_1KFTIND__c == '') {
            isError = true;
            errorMsg = '업종 필드를 완료하십시오.';
        }
        else if (!fields.PV_CHARGECUST_lu__c || fields.PV_CHARGECUST_lu__c == '') {
            isError = true;
            errorMsg = '청구처 필드를 완료하십시오.';
        }
        else if (!fields.PV_FITYP__c || fields.PV_FITYP__c == '') {
            isError = true;
            errorMsg = '과세유형 필드를 완료하십시오.';
        }
        else if (!fields.PV_KNVKTYPE__c || fields.PV_KNVKTYPE__c == '') {
            isError = true;
            errorMsg = '주문유형 필드를 완료하십시오.';
        }
        else if (!component.get('v.objCustomer.PV_REGIO_lu__c') || component.get('v.objCustomer.PV_REGIO_lu__c') == '') {
            isError = true;
            errorMsg = '지역 필드를 완료하십시오.';
        }
        else if (!fields.PV_VKGRP__c || fields.PV_VKGRP__c == '') {
            isError = true;
            errorMsg = '영업그룹 필드를 완료하십시오.';
        }
        else if (!fields.PV_STCDT__c || fields.PV_STCDT__c == '') {
            isError = true;
            errorMsg = '세금계산서 발행 유형 필드를 완료하십시오.';
        }
        //구코드 제어
        else if (component.get('v.objCustomer.PV_OLDCD__c') != "" && component.get('v.objCustomer.PV_OLDCD__c') != undefined && (!regex1.test(component.get('v.objCustomer.PV_OLDCD__c')))) {
            isError = true;
            errorMsg = '구코드(As-Is): 구코드는 10자리 이하의 숫자만 입력이 가능합니다.';
        }
        else if (component.get('v.objCustomer.PV_STCD2__c') != '' && component.get('v.objCustomer.PV_STCD2__c') != undefined && (!regex2.test(component.get('v.objCustomer.PV_STCD2__c')))) {
            isError = true;
            errorMsg = '옳바른 형식의 사업자번호가 아닙니다. 10자리 숫자만 입력이 가능합니다.';
        }
        else if (component.get('v.objCustomer.PV_STCD3__c') != "" && component.get('v.objCustomer.PV_STCD3__c') != undefined && (!regex3.test(component.get('v.objCustomer.PV_STCD3__c')))) {
            isError = true;
            errorMsg = '옳바른 형식의 법인코드가 아닙니다. 13자리 숫자만 입력이 가능합니다.';
        }
        else if (component.get('v.objCustomer.PV_STCD1__c') != "" && component.get('v.objCustomer.PV_STCD1__c') != undefined && (!regex4.test(component.get('v.objCustomer.PV_STCD1__c')))) {
            isError = true;
            errorMsg = '옳바른 형식의 대표자 생년월일이 아닙니다. 6자리만 입력이 가능합니다.';
        }
        else if (component.get('v.objCustomer.PV_TELF1__c') != "" && component.get('v.objCustomer.PV_TELF1__c') != undefined && (!regex5.test(component.get('v.objCustomer.PV_TELF1__c')))) {
            isError = true;
            errorMsg = '옳바른 형식의 전화번호가 아닙니다. "-" 값을 포함하여 입력';
        }
        else if (component.get('v.objCustomer.PV_TELFX__c') != "" && component.get('v.objCustomer.PV_TELFX__c') != undefined && (!regex6.test(component.get('v.objCustomer.PV_TELFX__c')))) {
            isError = true;
            errorMsg = '옳바른 형식의 팩스번호가 아닙니다. "-" 값을 포함하여 입력';
        }
        else if (component.get('v.objCustomer.PV_KULTG__c') != "" && component.get('v.objCustomer.PV_KULTG__c') != undefined && (!regex7.test(component.get('v.objCustomer.PV_KULTG__c')))) {
            isError = true;
            errorMsg = '옳바른 형식의 약정회전일이 아닙니다.';
        }
        else if ((component.get('v.objCustomer.PV_SHAPE__c') != "" && component.get('v.objCustomer.PV_SHAPE__c') != undefined) && (!regex8.test(component.get('v.objCustomer.PV_SHAPE__c')))) {
            isError = true;
            errorMsg = '옳바른 형식의 약정회전일이 아닙니다.';
        }
        else if (component.find("pv_subsi") && component.find("pv_subsi").get('v.checked') == true && component.get('v.objCustomer.PV_VBUND__c') == undefined) {
            isError = true;
            errorMsg = '관사코드를 입력계해주세요';
        }
        else if (component.get('v.objCustomer.PV_OLD_BIZPLACE_NEW__c') == undefined || component.get('v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c') == undefined) {
            isError = true;
            errorMsg = '경로(사업부)는 및 경로사업부(유효기간)은 필수 값 입니다.';
        }
        else if (component.get('v.objCustomer.PV_VKGRP__c') != undefined && component.get('v.objCustomer.PVRA_VKGRP__c') == undefined) {
            isError = true;
            errorMsg = '영업그룹 입력시 영업그룹 유효기간은 필수 값 입니다.';
        }
        else if (component.get('v.objCustomer.PV_CUHR1__c') != undefined && component.get('v.objCustomer.PVRA_CUHR1__c') == undefined) {
            isError = true;
            errorMsg = '고객분류 입력시 고객분류 유효기간은 필수 값 입니다.';
        }
        else if (component.get('v.objCustomer.PV_CUHR1__c') != undefined && component.get('v.v.isRequirePVShape') == true && component.get('v.objCustomer.PV_SHAPE__c') == undefined) {
            isError = true;
            errorMsg = '고객분류에 맞는 외형(정원)을 입력해 주세요';
        }
        else if (component.get('v.objCustomer.PV_KONDA__c') != undefined && component.get('v.objCustomer.PVRA_KONDA__c') == undefined) {
            isError = true;
            errorMsg = '가격그룹 입력시 가격그룹 유효기간은 필수 값 입니다.';
        }
        else if (component.get('v.objCustomer.PV_KVGR1__c') != undefined && component.get('v.objCustomer.PVRA_KVGR1__c') == undefined) {
            isError = true;
            errorMsg = '단가그룹 입력시 단가그룹 유효기간은 필수 값 입니다.';
        }
        else if (component.get('v.pv_pernr') != undefined && component.get('v.objCustomer.PVRA_PERNR__c') == undefined) {
            isError = true;
            errorMsg = '담당MA 입력시 담당MA 유효기간은 필수 값 입니다.';
        }

        if(isError) {
            helper.showToast('error', errorMsg);
            helper.doHideSpinner(component);
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
                    var strObjectType = component.get("v.strObjectType");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "message": "정보가 등록되었습니다."
                    });
                    toastEvent.fire();

                    if(strObjectType == 'Opportunity') {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": result,
                            "slideDevName": "Detail"
                        });
                        navEvt.fire();
                    }else {
                        $A.get('e.force:refreshView').fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    
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
        alert('closedModal');
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
        /*
        // Set isModalOpen attribute to false  
        var compEvents = component.getEvent("componentEventFired");
        console.log(component.get("v.isModalOpen") + ' 모달 창 닫기');

        compEvents.setParams({
            "isOpen": component.get("v.isModalOpen")
        });
        compEvents.fire();
        */
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
    fnAddressSave: function (component, event, helper) {
        console.log('save data');
        helper.fnAddressSaveRecord(component);
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
            component.set('v.objCustomer.PV_SUBSIDIARYYN__c', true);
            component.set('v.isRequireOLDBIZPlace', true);
        } else {
            component.set('v.objCustomer.PV_SUBSIDIARYYN__c', false);
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
        console.log('==============> contacts : '+JSON.stringify(contacts));
        console.log('==============> contacts.length : '+JSON.stringify(contacts.length));
        console.log('==============> contactData : '+JSON.stringify(contactData));
        console.log('==============> contactData.length : '+JSON.stringify(contactData.length));

        if (contacts && contacts != null && contactData && contactData.length > 0) {
            if(contacts.length > 0) {
                contacts.forEach(contact => {
                    if(contact.get('v.checked')) {
                        Array.prototype.push.apply(contactSelected, contactData.filter(item => item.no == contact.get('v.class')));
                    }
                });
            }else {
                if(contacts.get('v.checked')) {
                    Array.prototype.push.apply(contactSelected, contactData.filter(item => item.no == contacts.get('v.class')));
                }
            }
            
        }
        let no = 1;
        contactSelected.forEach(con => {
            con.no = no;
            no = no + 1;
        });
        console.log('contactSelected: ', JSON.stringify(contactSelected));
        component.set('v.contactSelected', contactSelected.slice(0, 5));
        component.set('v.isContactModalOpen', false);
    },

    fnSelectContact: function (component, event) {
        let contacts = component.find('select-contact');
        let isSelectAll = true;
        if(contacts && contacts.length > 0) {
            contacts.forEach(contact => {
                if (contact.get('v.checked') == false) isSelectAll = false;
            });
        }else if(contacts != null) {
            if(contacts.get('v.checked') == false) isSelectAll = false;
        }
        let selectAllContact = component.find('select-all-contact');
        selectAllContact.set('v.checked', isSelectAll);
    },

    fnSelectAllContact: function (component, event) {
        let selectAllContact = component.find('select-all-contact');
        let contacts = component.find('select-contact');
        if(contacts && contacts.length > 0) {
            contacts.forEach(contact => {
                contact.set('v.checked', selectAllContact.get('v.checked'))
            });
        }else if(contacts != null){
            contacts.set('v.checked', selectAllContact.get('v.checked'))
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
    },

    onInputPhone: function (component, event, helper) {
        //var value = component.find("pv_telf1").get("v.value");
        var value = event.getSource().get("v.value");

        console.log('===========> value : '+value);

        event.getSource().set("v.value", helper.onInputPhone(value));
    },
})