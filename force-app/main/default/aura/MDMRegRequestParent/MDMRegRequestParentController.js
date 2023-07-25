({
    // Component Init
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

                    // 영업기회(Opportunity)에서 MDM 고객등록시
                    if(returnVal.strObjectType == 'Opportunity') {

                        var objOpportunity = returnVal.objOpportunity;
                        var objUser = returnVal.objUser;

                        if(objUser) {
                            // 요청자 사원번호 세팅
                            component.set('v.objCustomer.REQACTORID__c', objUser.EmployeeNumber);
                        }

                        // Account 정보 자동 세팅
                        component.set('v.objCustomer.PV_STCD2__c', objOpportunity.Account.CompanyRegisterNumber__c); 
                        component.set('v.objCustomer.PV_J_1KFREPRE__c', objOpportunity.Account.RepresentativeName__c);
                        component.set('v.objCustomer.PV_TELF1__c', helper.onInputPhone(objOpportunity.Account.Phone));   

                        // 테스트를 위한 하드코딩 Start
                        /*
                        component.set('v.objCustomer.PV_STCD2__c', '1234567890');                        
                        component.set('v.objCustomer.PV_J_1KFREPRE__c', '대표자이름');
                        component.set('v.objCustomer.PV_STCD1__c', '850907');
                        component.set('v.objCustomer.PV_J_1KFTBUS__c', '업테테스트');
                        component.set('v.objCustomer.PV_J_1KFTIND__c', '업종테스트');
                        component.set('v.objCustomer.PV_TELF1__c', '010-1234-1234');
                        */

                        // 테스트를 위한 하드코딩 End

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
                        // 국가키
                        component.set('v.objCustomer.PV_LAND1__c', 'KR');
                        component.set('v.inputpv_land1', 'KR');

                        // 매출형태
                        component.set('v.objCustomer.PV_BUSAB__c', '01');
                        // 고객상태
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
                    }
                    // MDM 고객등록 수정시
                    else {

                        var objMDMRegReqCustomer = returnVal.objMDMRegReqCustomer;

                        component.set("v.objCustomer", objMDMRegReqCustomer);
                        var listMDMReqContact = returnVal.listMDMReqContact;

                        console.log('================> listMDMReqContact : '+JSON.stringify(listMDMReqContact));

                        component.set("v.contactSelected", listMDMReqContact);
                        // 고객유형            
                        //component.set("v.custypes", objMDMRegReqCustomer.PV_CUSTTYPE__c);
                        
                        // ============= 일반정보 =============
                        // 영업그룹
                        component.set("v.inputpv_vkgrp", objMDMRegReqCustomer.PV_VKGRP__c);
                        // 세금계산서발행유형코드
                        component.set("v.inputpv_stcdt", objMDMRegReqCustomer.PV_STCDT__c);
                        // 관계사코드
                        component.set("v.inputpv_vbund", objMDMRegReqCustomer.PV_VBUND__c);
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
    //AMA 정보 변경 이벤트
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
                    // 변경된 사용자의 사원번호 세팅
                    component.set('v.objCustomer.PV_ADMINMA__c', data.EmployeeNumber);
                }
            });
            $A.enqueueAction(action);
        }else {
            component.set('v.objCustomer.PV_ADMINMA__c', '');
        }
    },

    // 영업그룹(유효기간 관리) Validation    
    grpChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields <= today) {
                alert('영업그룹의 유효날짜는 오늘보다 커야 합니다.');
                //component.set("v.objCustomer.PVRA_VKGRP__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_VKGRP__c", fields);
            }
        }
    },

    // 고객그룹(유효기간 관리) Validation
    cuhrChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields > today) {
                alert('고객분류의 유효날짜는 오늘보다 같거나 작아야 합니다.');
                //component.set("v.objCustomer.PVRA_CUHR1__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_CUHR1__c", fields);
            }
        }
    },

    // 가격그룹(유효기간 관리) Validation
    kondagrpChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields > today) {
                alert('가격그룹의 유효날짜는 오늘보다 같거나 작아야 합니다.');
                //component.set("v.objCustomer.PVRA_KONDA__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_KONDA__c", fields);
            }
        }
    },

    // 단가그룹(유효기간 관리) Validation
    kvgr1Changed: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields < today) {
                alert('단가그룹의 유효날짜는 오늘보다 같거나 커야 합니다.');
                //component.set("v.objCustomer.PVRA_KVGR1__c", '');
                return;
            } else {
                component.set('v.objCustomer.PVRA_KVGR1__c', fields);
            }
        }
    },
    // 담당MA(유효기간 관리) Validation
    dangrpChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields > today) {
                alert('담당(MA)의 유효날짜는 오늘보다 같거나 작아야 합니다.');
                //component.set("v.objCustomer.PVRA_PERNR__c", '');
                return;
            } else {
                component.set("v.objCustomer.PVRA_PERNR__c", fields);
            }
        }
    },
    // 경로사업부-(유효기간 관리) Validation
    oldbizplzceChanged: function (component, event, helper) {
        var fields = event.getParam("value");
        if (fields != "") {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (fields > today) {
                alert('경로사업부의 유효날짜는 오늘보다 같거나 작아야 합니다.');
                //component.set("v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c", '');
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
            console.log('=============> go changedMA ');

            var action = component.get("c.changedMA");

            action.setParams({
                "userId" : String(value)
            });

            action.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    var returnVal = response.getReturnValue();                    
                    
                    console.log('=========> returnVal : '+returnVal)
                    // MA 사원번호 세팅
                    component.set('v.objCustomer.PV_PERNR__c', returnVal);
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
            });
            $A.enqueueAction(action);
        }
    },

    // 지급처 변경 이벤트 
    paycustchanged: function (component, event, helper) {
        component.set("v.objCustomer.IsSelf_PV_PAYCUST__c", false);
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
    // 청구처 변경 이벤트 
    chargechanged: function (component, event, helper) {
        component.set("v.objCustomer.IsSelf_PV_CHARGECUST__c", false);
        var fields = event.getParam("value");
        if (fields != '' || fields != undefined) {
            var action = component.get("c.getCustomerId");

            action.setParams({
                accountId: fields
            });
            action.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    // 고객번호(CustomerId__c)
                    const data = response.getReturnValue();
                    component.set('v.objCustomer.PV_CHARGECUST__c', data);
                }
            });
            $A.enqueueAction(action);
            
            component.set('v.isReadOnlyPVCharge', false);
        }
    },
    // 청구처 Self 이벤트 
    chargehandleClick: function (component, event, helper) {
        component.set('v.objCustomer.IsSelf_PV_CHARGECUST__c', true);
        component.set('v.objCustomer.PV_CHARGECUST__c', '##SELFID##');
        component.set('v.objCustomer.PV_CHARGECUST_lu__c', component.get('v.objCustomer.Account__c'));
        component.set('v.isReadOnlyPVCharge', false);
    },
    // 지급처 Self 이벤트
    payhandleClick: function (component, event, helper) {
        component.set('v.objCustomer.IsSelf_PV_PAYCUST__c', true);
        component.set('v.objCustomer.PV_PAYCUST__c', '##SELFID##');
        component.set('v.objCustomer.PV_PAYCUST_lu__c', component.get('v.objCustomer.Account__c'));
        component.set('v.isReadOnlyPAYCust', false);
    },    

    // 저장 버튼 이벤트
    fnSave: function (component, event, helper) {
        event.preventDefault();

        // 로딩바 실행
        helper.doShowSpinner(component);

        var isError = false;        
        var errorMsg = '';

        var fields = component.get('v.objCustomer');

        var errorKey = component.get("v.errorKey");

        // 필수값 관련 디자인 표시 초기화
        if(!(errorKey == undefined || errorKey == '' || errorKey == null)) {
            var targetComp = component.find(errorKey);

            if(targetComp) {                
                var targetClass = targetComp.get("v.class");

                console.log('==============> targetClass : '+targetClass);

                if((!(targetClass == null || targetClass == undefined)) && (targetClass.indexOf('isError slds-has-error') > -1)) {
                    targetClass = targetClass.replaceAll('isError slds-has-error', '');
                    targetComp.set("v.class", targetClass);
                }
            }
        }

        errorKey = '';

        var listRequriedErrorKey = component.get("v.listRequriedErrorKey");

        console.log('=============> listRequriedErrorKey : '+JSON.stringify(listRequriedErrorKey));

        if(!(listRequriedErrorKey == undefined || listRequriedErrorKey == '' || listRequriedErrorKey == null)) {
            for(var i=0; i<listRequriedErrorKey.length ; i++) {
                var targetComp = component.find(listRequriedErrorKey[i]);

                if(targetComp) {
                    var targetClass = targetComp.get("v.class");

                    console.log('==============> targetClass : '+targetClass);

                    if((!(targetClass == null || targetClass == undefined)) && (targetClass.indexOf('isError slds-has-error') > -1)) {
                        targetClass = targetClass.replaceAll('isError slds-has-error', '');
                        targetComp.set("v.class", targetClass);
                    }
                }else {
                    console.log('==========> '+listRequriedErrorKey[i]+' not find component');
                }
            }
        }

        listRequriedErrorKey = [];


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

        var isErrorTab = '';

        var basicErrorCount = 0;
        var finErrorCount = 0;
        var salesErrorCount = 0;

        // 기본정보 Validation
        if (!fields.PV_NAME1__c || fields.PV_NAME1__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            
            /*
            errorMsg = '기본정보의 고객명(영문명 포함) 필드를 입력해 주세요.';            
            errorKey = 'PV_NAME1__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_NAME1__c');
        }
        if (!fields.PV_STCD2__c || fields.PV_STCD2__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 사업자등록번호 필드를 입력해 주세요.';            
            errorKey = 'PV_STCD2__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_STCD2__c');
        }
        if (!fields.PV_GFORM__c || fields.PV_GFORM__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 법적상태 필드를 입력해 주세요.';            
            errorKey = 'PV_GFORM__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_GFORM__c');
        }
        if (!fields.PV_J_1KFREPRE__c || fields.PV_J_1KFREPRE__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 대표자이름 필드를 입력해 주세요.';            
            errorKey = 'PV_J_1KFREPRE__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_J_1KFREPRE__c');
        }
        if (!fields.PV_STCD1__c || fields.PV_STCD1__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '대표자 생년월일(명칭변경) 필드를 입력해 주세요. 예시) 750101';            
            errorKey = 'PV_STCD1__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_STCD1__c');
        }
        if (!fields.PV_J_1KFTBUS__c || fields.PV_J_1KFTBUS__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 업태 필드를 입력해 주세요.';            
            errorKey = 'PV_J_1KFTBUS__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_J_1KFTBUS__c');
        }
        if (!fields.PV_J_1KFTIND__c || fields.PV_J_1KFTIND__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 업종 필드를 입력해 주세요.';            
            errorKey = 'PV_J_1KFTIND__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_J_1KFTIND__c');
        }        
        if (!fields.PV_TELF1__c || fields.PV_TELF1__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 전화번호 필드를 입력해 주세요.';            
            errorKey = 'PV_TELF1__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_TELF1__c');
        }
        if (!fields.PV_PAYCUST_lu__c || fields.PV_PAYCUST_lu__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 지급처 필드를 입력해 주세요.';            
            errorKey = 'PV_PAYCUST_lu__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_PAYCUST_lu__c');
        }
        if (!fields.PV_CHARGECUST_lu__c || fields.PV_CHARGECUST_lu__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 청구처 필드를 입력해 주세요.';            
            errorKey = 'PV_CHARGECUST_lu__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_CHARGECUST_lu__c');
        }
        if (!fields.PV_VKGRP__c || fields.PV_VKGRP__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 영업그룹 필드를 입력해 주세요.';            
            errorKey = 'PV_VKGRP__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_VKGRP__c');
        }
        if (!fields.PV_PERNR_lu__c || fields.PV_PERNR_lu__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 담당MA 필드를 입력해 주세요.';            
            errorKey = 'PV_PERNR_lu__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_PERNR_lu__c');
        }
        if (!fields.PV_STCDT__c || fields.PV_STCDT__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 세금계산서 발행 유형 필드를 입력해 주세요.';            
            errorKey = 'PV_STCDT__c';
            */
            ++basicErrorCount;
            //listRequriedErrorKey.push('PV_STCDT__c');
        }
        if (!fields.PV_FITYP__c || fields.PV_FITYP__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 과세유형 필드를 입력해 주세요.';            
            errorKey = 'PV_FITYP__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_FITYP__c');
        }
        if (!fields.PV_LAND1__c || fields.PV_LAND1__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 국가키 필드를 입력해 주세요.';            
            errorKey = 'PV_LAND1__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_LAND1__c');
        }        
        if (component.find("PV_SUBSIDIARYYN__c") && component.find("PV_SUBSIDIARYYN__c").get('v.checked') == true && component.get('v.objCustomer.PV_VBUND__c') == undefined) {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '관계사 코드 필드를 입력해 주세요.';            
            errorKey = 'PV_VBUND__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_VBUND__c');
        }
        if (!fields.PV_KNVKTYPE__c || fields.PV_KNVKTYPE__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 주문유형 필드를 입력해 주세요.';            
            errorKey = 'PV_KNVKTYPE__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_KNVKTYPE__c');
        }
        if (!fields.PV_REGIO__c || fields.PV_REGIO__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'basic';
            }
            /*
            errorMsg = '기본정보의 지역 필드를 입력해 주세요.';            
            errorKey = 'PV_REGIO__c';
            */
            ++basicErrorCount;
            listRequriedErrorKey.push('PV_REGIO__c');
        }
        /*
        // 담당자 정보 체크 추가
        if(fields.PV_ADRES_ROADADDR1__c || fields.PV_ADRES_ROADADDR1__c == '') {
            isError = true;
            errorMsg = '기본정보의 주소를 입력해 주세요.';
        }
        */

        // 회계정보 Validation
        if(!fields.PV_BUSAB__c || fields.PV_BUSAB__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'financial';
            }
            /*
            errorMsg = '회계정보의 매출형태 필드를 입력해 주세요.';            
            errorKey = 'PV_BUSAB__c';
            */
            ++finErrorCount;
            listRequriedErrorKey.push('PV_BUSAB__c');
        }
        if(!fields.PV_CESSION_KZ__c || fields.PV_CESSION_KZ__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'financial';
            }
            /*
            errorMsg = '회계정보의 고객상태 필드를 입력해 주세요.';            
            errorKey = 'PV_CESSION_KZ__c';
            */
            ++finErrorCount;
            listRequriedErrorKey.push('PV_CESSION_KZ__c');
        }
        if(!fields.PV_ZUAWA__c || fields.PV_ZUAWA__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'financial';
            }
            /*
            errorMsg = '회계정보의 정렬키 필드를 입력해 주세요.';            
            errorKey = 'PV_ZUAWA__c';
            */
            ++finErrorCount;
            listRequriedErrorKey.push('PV_ZUAWA__c');
        }
        if(!fields.PV_AKONT__c || fields.PV_AKONT__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'financial';
            }
            /*
            errorMsg = '회계정보의 조정계정 필드를 입력해 주세요.';            
            errorKey = 'PV_AKONT__c';
            */
            ++finErrorCount;
            listRequriedErrorKey.push('PV_AKONT__c');
        }
        if(!fields.PV_FDGRV__c || fields.PV_FDGRV__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'financial';
            }
            /*
            errorMsg = '회계정보의 현금관리그룹 필드를 입력해 주세요.';
            errorKey = 'PV_FDGRV__c';
            */
            ++finErrorCount;
            listRequriedErrorKey.push('PV_FDGRV__c');
        }
        if(!fields.PV_TAXKDD__c || fields.PV_TAXKDD__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'financial';
            }
            /*
            errorMsg = '회계정보의 세금분류 필드를 입력해 주세요.';            
            errorKey = 'PV_TAXKDD__c';
            */
            ++finErrorCount;
            listRequriedErrorKey.push('PV_TAXKDD__c');
        }
        if(!fields.PV_KATR5__c || fields.PV_KATR5__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'financial';
            }
            /*
            errorMsg = '회계정보의 세금납부방법 필드를 입력해 주세요.';            
            errorKey = 'PV_KATR5__c';
            */
            ++finErrorCount;
            listRequriedErrorKey.push('PV_KATR5__c');
        }

        // 영업정보
        if(!fields.PV_CUHR1__c || fields.PV_CUHR1__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'sales';
            }
            /*
            errorMsg = '영업정보의 고객분류 필드를 입력해 주세요.';            
            errorKey = 'PV_CUHR1__c';
            */
            ++salesErrorCount;
            listRequriedErrorKey.push('PV_CUHR1__c');
        }
        if((component.get("v.isRequirePVShape")) && (!fields.PV_SHAPE__c || fields.PV_SHAPE__c == '')) {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'sales';
            }
            /*
            errorMsg = '영업정보의 외형(정원) 필드를 입력해 주세요.';            
            errorKey = 'PV_SHAPE__c';
            */
            ++salesErrorCount;
            listRequriedErrorKey.push('PV_SHAPE__c');
        }
        if(!fields.PV_KONDA__c || fields.PV_KONDA__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'sales';
            }
            /*
            errorMsg = '영업정보의 가격그룹 필드를 입력해 주세요.';            
            errorKey = 'PV_KONDA__c';
            */
            ++salesErrorCount;
            listRequriedErrorKey.push('PV_KONDA__c');
        }
        if(!fields.PV_KVGR1__c || fields.PV_KVGR1__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'sales';
            }
            /*
            errorMsg = '영업정보의 단가그룹 필드를 입력해 주세요.';            
            errorKey = 'PV_KVGR1__c';
            */
            ++salesErrorCount;
            listRequriedErrorKey.push('PV_KVGR1__c');
        }
        if(!fields.PV_WAERS__c || fields.PV_WAERS__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'sales';
            }
            /*
            errorMsg = '영업정보의 통화 필드를 입력해 주세요.';            
            errorKey = 'PV_WAERS__c';
            */
            ++salesErrorCount;
            listRequriedErrorKey.push('PV_WAERS__c');
        }
        if(!fields.PV_KDGRP__c || fields.PV_KDGRP__c == '') {
            isError = true;            
            if(isErrorTab == '') {
                isErrorTab = 'sales';
            }
            /*
            errorMsg = '영업정보의 여신관리(고객향) 필드를 입력해 주세요.';
            errorKey = 'PV_KDGRP__c';
            */
            ++salesErrorCount;
            listRequriedErrorKey.push('PV_KDGRP__c');
        }
        if(!fields.PV_ZTERM_VV__c || fields.PV_ZTERM_VV__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'sales';
            }
            /*
            errorMsg = '영업정보의 지급조건 필드를 입력해 주세요.';            
            errorKey = 'PV_ZTERM_VV__c';
            */
            ++salesErrorCount;
            listRequriedErrorKey.push('PV_ZTERM_VV__c');
        }
        if(!fields.PV_DSTRHISTREGYN__c || fields.PV_DSTRHISTREGYN__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'sales';
            }
            /*
            errorMsg = '영업정보의 유통이력 신고대상 유형 필드를 입력해 주세요.';            
            errorKey = 'PV_DSTRHISTREGYN__c';
            */
            ++salesErrorCount;
            listRequriedErrorKey.push('PV_DSTRHISTREGYN__c');
        }
        if(!fields.PV_OLD_BIZPLACE_NEW__c || fields.PV_OLD_BIZPLACE_NEW__c == '') {
            isError = true;
            if(isErrorTab == '') {
                isErrorTab = 'sales';
            }
            /*
            errorMsg = '영업정보의 경로(사업부) 필드를 입력해 주세요.';            
            errorKey = 'PV_OLD_BIZPLACE_NEW__c';
            */
            ++salesErrorCount;
            listRequriedErrorKey.push('PV_OLD_BIZPLACE_NEW__c');
        }

        // 필수 입력값 관련 표시
        if(isError) {
            console.log('==============> isErrorTab : '+isErrorTab);
            console.log('==============> errorKey : '+errorKey);
            console.log('==============> isError : '+isError);
            console.log('==============> errorMsg : '+errorMsg);

            helper.showToast('error', '입력 필수 필드를 확인하여 주세요.\t\n[기본정보] : '+basicErrorCount+'건\t\n[회계정보] : '+finErrorCount+'건\t\n[영업정보] : '+salesErrorCount+'건');
            component.set("v.selectedTabId", isErrorTab);
            //component.set("v.errorKey", errorKey);
            
            component.set("v.isShowError", isError);

            for(var i=0; i<listRequriedErrorKey.length ; i++) {
                var targetComp = component.find(listRequriedErrorKey[i]);

                if(targetComp) {
                    var targetClass = targetComp.get("v.class");

                    if(targetClass) {
                        targetClass += ' isError slds-has-error';
                    }else {
                        targetClass = 'isError slds-has-error';
                    }
                    
                    targetComp.set("v.class", targetClass);
                }
            }

            component.set("v.listRequriedErrorKey", listRequriedErrorKey);

            helper.doHideSpinner(component);

            return;
        }
        
        // 입력한값에 대한 Validation
        // 기본정보
        if (component.get('v.objCustomer.PV_OLDCD__c') != "" && component.get('v.objCustomer.PV_OLDCD__c') != undefined && (!regex1.test(component.get('v.objCustomer.PV_OLDCD__c')))) {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '구코드(As-Is): 구코드는 10자리 이하의 숫자만 입력이 가능합니다.';            
            errorKey = 'PV_OLDCD__c';
        }
        else if (component.get('v.objCustomer.PV_STCD2__c') != '' && component.get('v.objCustomer.PV_STCD2__c') != undefined && (!regex2.test(component.get('v.objCustomer.PV_STCD2__c')))) {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '옳바른 형식의 사업자등록번호가 아닙니다. 10자리 숫자만 입력이 가능합니다.';            
            errorKey = 'PV_STCD2__c';
        }
        else if (component.get('v.objCustomer.PV_STCD3__c') != "" && component.get('v.objCustomer.PV_STCD3__c') != undefined && (!regex3.test(component.get('v.objCustomer.PV_STCD3__c')))) {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '옳바른 형식의 법인코드가 아닙니다. 13자리 숫자만 입력이 가능합니다.';
            errorKey = 'PV_STCD3__c';
        }
        else if (component.get('v.objCustomer.PV_STCD1__c') != "" && component.get('v.objCustomer.PV_STCD1__c') != undefined && (!regex4.test(component.get('v.objCustomer.PV_STCD1__c')))) {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '옳바른 형식의 대표자 생년월일이 아닙니다. 6자리만 입력이 가능합니다. 예시) 750101';            
            errorKey = 'PV_STCD1__c';
        }
        else if (component.get('v.objCustomer.PV_TELF1__c') != "" && component.get('v.objCustomer.PV_TELF1__c') != undefined && (!regex5.test(component.get('v.objCustomer.PV_TELF1__c')))) {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '옳바른 형식의 전화번호가 아닙니다.';            
            errorKey = 'PV_TELF1__c';
        }
        else if (component.get('v.objCustomer.PV_TELFX__c') != "" && component.get('v.objCustomer.PV_TELFX__c') != undefined && (!regex6.test(component.get('v.objCustomer.PV_TELFX__c')))) {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '옳바른 형식의 팩스번호가 아닙니다.';            
            errorKey = 'PV_TELFX__c';
        }
        else if (!fields.PV_PERNR__c || fields.PV_PERNR__c == '') {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '기본정보의 담당MA 사원번호가 존재하지 않습니다. 사용자 정보를 확인하여 주시기 바랍니다.';            
            errorKey = 'PV_PERNR_lu__c';
        }        
        else if (component.get('v.objCustomer.PV_PERNR_lu__c') != undefined && component.get('v.objCustomer.PVRA_PERNR__c') == undefined) {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '기본정보의 담당MA 입력시 담당MA 유효기간은 필수 값 입니다.';
            errorKey = 'PVRA_PERNR__c';
        }
        else if (component.get('v.objCustomer.PV_VKGRP__c') != undefined && component.get('v.objCustomer.PVRA_VKGRP__c') == undefined) {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '영업그룹 입력시 영업그룹 유효기간은 필수 값 입니다.';
            errorKey = 'PVRA_VKGRP__c';
        }
        else if(!fields.PV_ADRES_ROADADDR1__c || fields.PV_ADRES_ROADADDR1__c == '') {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '기본정보의 주소를 입력해주시기 바랍니다.';
            errorKey = 'PV_ADRES_ROADADDR1__c';
        }
        else if(component.get('v.contactSelected') && component.get('v.contactSelected').length < 1) {
            isError = true;
            isErrorTab = 'basic';
            errorMsg = '기본정보의 담당자 정보는 필수 값 입니다.';
            errorKey = 'PV_NAME1_VK__c';
        }
        // 영업정보
        else if (component.get('v.objCustomer.PV_CUHR1__c') != undefined && component.get('v.objCustomer.PVRA_CUHR1__c') == undefined) {
            isError = true;
            isErrorTab = 'sales';
            errorMsg = '고객분류 입력시 고객분류 유효기간은 필수 값 입니다.';            
            errorKey = 'PV_CUHR1__c';
        }        
        else if (component.get('v.objCustomer.PV_KONDA__c') != undefined && component.get('v.objCustomer.PVRA_KONDA__c') == undefined) {
            isError = true;
            isErrorTab = 'sales';
            errorMsg = '가격그룹 입력시 가격그룹 유효기간은 필수 값 입니다.';            
            errorKey = 'PV_KONDA__c';
        }
        else if (component.get('v.objCustomer.PV_KVGR1__c') != undefined && component.get('v.objCustomer.PVRA_KVGR1__c') == undefined) {
            isError = true;
            isErrorTab = 'sales';
            errorMsg = '단가그룹 입력시 단가그룹 유효기간은 필수 값 입니다.';            
            errorKey = 'PV_KVGR1__c';
        }
        else if (component.get('v.objCustomer.PV_KULTG__c') != "" && component.get('v.objCustomer.PV_KULTG__c') != undefined && (!regex7.test(component.get('v.objCustomer.PV_KULTG__c')))) {
            isError = true;
            isErrorTab = 'sales';
            errorMsg = '옳바른 형식의 약정회전일이 아닙니다.';            
            errorKey = 'PV_KULTG__c';
        }
        else if (component.get('v.objCustomer.PV_OLD_BIZPLACE_NEW__c') == undefined || component.get('v.objCustomer.PVRA_OLD_BIZPLACE_NEW__c') == undefined) {
            isError = true;
            isErrorTab = 'sales';
            errorMsg = '경로(사업부)는 및 경로사업부(유효기간)은 필수 값 입니다.';            
            errorKey = 'PV_OLD_BIZPLACE_NEW__c';
        }
        else if ((component.get('v.objCustomer.PV_SHAPE__c') != "" && component.get('v.objCustomer.PV_SHAPE__c') != undefined) && (!regex8.test(component.get('v.objCustomer.PV_SHAPE__c')))) {
            isError = true;
            isErrorTab = 'sales';
            errorMsg = '옳바른 형식의 외형이 아닙니다.';            
            errorKey = 'PV_SHAPE__c';
        }

        // 오류 관련 표시
        if(isError) {
            console.log('==============> isErrorTab : '+isErrorTab);
            console.log('==============> errorKey : '+errorKey);
            console.log('==============> isError : '+isError);
            console.log('==============> errorMsg : '+errorMsg);

            helper.showToast('error', errorMsg);
            component.set("v.selectedTabId", isErrorTab);
            component.set("v.errorKey", errorKey);
            component.set("v.isShowError", isError);

            var targetComp = component.find(errorKey);

            if(targetComp) {
                var targetClass = targetComp.get("v.class");

                if(targetClass) {
                    targetClass += ' isError slds-has-error';
                }else {
                    targetClass = 'isError slds-has-error';
                }
                
                targetComp.set("v.class", targetClass);
            }else {
                console.log('==============> none target');
            }

            helper.doHideSpinner(component);

            return;
        }
        
        let contactSelected = component.get('v.contactSelected');

        console.log('==============> contactSelected : '+JSON.stringify(contactSelected));
        console.log('==============> contactSelected len : '+JSON.stringify(contactSelected.length));

        if (contactSelected && contactSelected.length > 0) {
            contactSelected.forEach(contact => {
                // 2023-01-07 Number -> Text 형식으로 변경
                //contact.PV_NO__c = String(contact.no);
                delete contact['isChecked'];
            });
        }

        /*
        let bankSelected = component.get('v.bankSelected');
        if (bankSelected && bankSelected.length > 0) {
            bankSelected.forEach(bank => {
                delete bank['no'];
            });
        }
        */

        var saveRecords = component.get("c.saveRecords");
        saveRecords.setParams({
            customer : fields,
            contacts : contactSelected,
            //banks : bankSelected
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
                    component.set("v.isDisabled", false);
                }
            }

            helper.doHideSpinner(component);
        });
        $A.enqueueAction(saveRecords);
    },

    // 주소검색 팝업창 표시
    openAddressModal: function (component, event, helper) {
        component.set("v.isAddressModalOpen", true);
    },

    // 취소 버튼 이벤트
    fnCancel: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },

    // 검색어 입력 이벤트 
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

    // 검색된 주소리스트 이전 버튼 이벤트
    fnPrevPage: function (component, event, helper) {
        var intPageNo = component.get("v.intCurrentPage") - 1;
        var intPageIdx = component.get("v.intPageIdx") - component.get("v.intCntPerPage");

        helper.doSearchAddress(component, intPageNo, intPageIdx);
    },

    // 검색된 주소리스트 다음 버튼 이벤트
    fnNextPage: function (component, event, helper) {
        var intPageNo = component.get("v.intCurrentPage") + 1;
        var intPageIdx = component.get("v.intPageIdx") + component.get("v.intCntPerPage");

        helper.doSearchAddress(component, intPageNo, intPageIdx);
    },

    // 주소리스트 선택 이벤트
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
    //주소 창 취소 버튼 이벤트
    fnSearchClose: function (component, event, helper) {
        component.set('v.isAddressModalOpen', false);
    },

    //주소 창 저장 버튼 이벤트
    fnAddressSave: function (component, event, helper) {
        console.log('save data');
        helper.fnAddressSaveRecord(component);
    },

    //주소 창 이전 버튼 이벤트
    fnPrepage: function (component, event, helper) {
        helper.fnPrepage(component);
    },

    // 고객분류 변경 이벤트
    handlerChangePVCUHR1: function (component, event) {
        var listStr = ['3194-001', '3208-001', '3209-001', '3210-001', '3211-001',
            '3212-001', '3213-001', '3214-001', '3215-001', '3216-001',
            '3217-001', '3218-001', '3219-001', '3220-001', '3221-001',
            '3222-001', '3223-001', '3224-001']
        var code = component.get('v.objCustomer.PV_CUHR1__c');
        component.set('v.isRequirePVShape', listStr.includes(code));
        console.log('code ' + code);

    },

    // 지급조건 변경 이벤트
    handlerChangePVZTERMVV: function (component, event) {
        var code = component.get('v.objCustomer.PV_ZTERM_VV__c');
        console.log('code1111 : '+ code);
        // 지급조건에 따라 약정회전일(PV_KULTG__c) 자동세팅
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

    // 관계사여부 변경 이벤트
    subsidiChange: function (component, event) {
        var compares = component.find("PV_SUBSIDIARYYN__c").get('v.checked');
        console.log(compares + '<<<<');
        // 관계사여부가 체크 되어져 있는 경우 관계사코드(PV_VBUND__c) 필수
        if (compares === true) {
            component.set('v.objCustomer.PV_SUBSIDIARYYN__c', true);
            component.set('v.isRequireOLDBIZPlace', true);
        } else {
            component.set('v.objCustomer.PV_SUBSIDIARYYN__c', false);
            component.set('v.isRequireOLDBIZPlace', false);
        }
    },

    // 담당자 모달창 활성화 이벤트
    setContactModal: function (component, event, helper) {
        helper.doGetContactData(component);
    },
    // 담당자 모달창 비활성화 이벤트
    setCloseContactModal: function (component, event) {
        component.set('v.isContactModalOpen', false);
    },
    // 담당자 연락처 체크 이벤트
	fnContactPhoneCheck: function (component, event, helper) {
        let id = event.getSource().get("v.id");
        let name = event.getSource().get("v.name");
        let idx = id.slice(name.length+1);
        let records = component.get("v.contactData");
        let record = records[idx];
        // 숫자가 아닌 데이터 제거
        record.PV_TELF1_VK__c = record.PV_TELF1_VK__c.replace(/[^0-9]/g, '');
        // 11자리가 넘으면 초과 글자 삭제
        record.PV_TELF1_VK__c = record.PV_TELF1_VK__c.length > 11 ? record.PV_TELF1_VK__c.slice(0,11) : record.PV_TELF1_VK__c;
        // 전화번호 Format 으로 변환 
        record.PV_TELF1_VK__c = record.PV_TELF1_VK__c.replace(/^(\d{2,3})(\d{3,4})(\d{4})$/, '$1-$2-$3');
        component.set("v.contactData", records);
    },
    
    // 담당자 이메일 체크 이벤트
	fnContactEmailCheck: function (component, event, helper) {
        let id = event.getSource().get("v.id");
        let name = event.getSource().get("v.name");
        let idx = id.slice(name.length+1);
        let records = component.get("v.contactData");
        let record = records[idx];
        // 숫자가 아닌 데이터 제거

        record.PV_EMAIL_VK__c = record.PV_EMAIL_VK__c.replace(/[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/g, '');
        console.log('record.PV_EMAIL_VK__c 1 :::' + record.PV_EMAIL_VK__c);
        component.set("v.contactData", records);
    },
    // 담당자 저장 이벤트
    fnContactSelected: function (component, event, helper) {
        let contactData = component.get('v.contactData');
        let contacts = component.find('select-contact');        
        let contactSelected = [];

        /*
        console.log('==============> contacts : '+JSON.stringify(contacts));
        console.log('==============> contacts.length : '+JSON.stringify(contacts.length));
        console.log('==============> contactData : '+JSON.stringify(contactData));
        console.log('==============> contactData.length : '+JSON.stringify(contactData.length));
        */
        let emailRegex = new RegExp("^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$");

        let isError = false;
        let errorMsg = '';

        for(let i=0 ; i<contactData.length ; i++) {
            if(contactData[i].isChecked) {
                contactSelected.push(contactData[i]);
            }
            if(contactData[i].PV_EMAIL_VK__c != '' && contactData[i].PV_EMAIL_VK__c != undefined && contactData[i].PV_EMAIL_VK__c != null){
                if(!emailRegex.test(contactData[i].PV_EMAIL_VK__c)) {
                    isError = true;
                    errorMsg = '담당자 이메일이 잘못된 형식입니다.';
                }
            }
        }

        let no = 1;
        let strObjectType = component.get("v.strObjectType");
        
        contactSelected.forEach(con => {
            con.PV_NO__c = String(no++);
        });


        //console.log('=================> contactSelected : '+JSON.stringify(contactSelected));

        for(let i=0 ; i<contactSelected.length ; i++) { 
            if(contactSelected[i].PV_KNVKGB__c == '' || contactSelected[i].PV_KNVKGB__c == undefined || contactSelected[i].PV_KNVKGB__c == null) {
                isError = true;
                errorMsg = '담당자 유형은 필수 값 입니다.';
            } else if(contactSelected[i].PV_TELF1_VK__c == '' || contactSelected[i].PV_TELF1_VK__c == undefined || contactSelected[i].PV_TELF1_VK__c == null) {
                isError = true;
                errorMsg = '담당자 연락처는 필수 값 입니다.';
            } 
        }

        if(!isError) {
            
            let contactTarget = [];
            contactData.forEach((item, index) => {
                contactTarget.push({
                    LastName : item.PV_NAME1_VK__c,
                    PV_KNVKGB__c : item.PV_KNVKGB__c,
                    MobilePhone : item.PV_TELF1_VK__c,
                    Email : item.PV_EMAIL_VK__c,
                    PV_PAFKT_VK__c : item.PV_PAFKT_VK__c,
                    Department : item.PV_ABTNR_VK__c,
                    PV_TALKT_VK__c: item.PV_TALKT_VK__c,
                    Id : item.Contact__c
                });
            });

            // console.log('contactSelected: ', JSON.stringify(contactSelected));
            component.set('v.contactSelected', contactSelected.slice(0, 5));
            // component.set('v.isContactModalOpen', false);
            // console.log('contactTarget :: ' + JSON.stringify(contactTarget));
            helper.doSaveContact(component, contactTarget);
        } else {
            helper.showToast('error', errorMsg);
        }

    },
    // 담당자 선택 이벤트
    fnSelectContact: function (component, event) {
        let contacts = component.find('select-contact');
        let isSelectAll = true;

        let contactData = component.get('v.contactData');

        for(var i=0 ; i<contactData.length ; i++) {
            if(!contactData[i].isChecked) {
                isSelectAll = false;
            }
        }

        let selectAllContact = component.find('select-all-contact');
        selectAllContact.set('v.checked', isSelectAll);
    },
    // 담당자 전체 선택 이벤트
    fnSelectAllContact: function (component, event) {
        let selectAllContact = component.find('select-all-contact');
        let contacts = component.find('select-contact');

        let contactData = component.get('v.contactData');

        for(var i=0 ; i<contactData.length ; i++) {
            contactData[i].isChecked = selectAllContact.get('v.checked');
        }

        console.log('=========> contactData : '+JSON.stringify(contactData));

        component.set('v.contactData', contactData);
    },

    /*
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
    */

    // 은행정보 팝업창 활성화 이벤트
    setBankModal: function (component, event, helper) {
        component.set('v.isBankModalOpen', true);
        let bankData = component.get('v.bankData');
        bankData = [{
            no: 1,
            PV_ACTCLOSEYN__c: 'false'
        }];
        component.set('v.bankData', bankData)
    },
    // 은행정보 팝업창 비활성화 이벤트
    setCloseBankModal: function (component, event) {
        component.set('v.isBankModalOpen', false);
    },

    // 은행정보 담당자 변경 이벤트
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

    // 은행정보 추가 버튼 이벤트
    addBankItem: function (component, event) {
        let bankData = component.get('v.bankData');
        let bankItem = { no: bankData.length + 1, PV_ACTCLOSEYN__c: 'false' };
        bankData.push(bankItem);
        component.set('v.bankData', bankData);
    },

    // 은행정보 삭제 버튼 이벤트
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
    // 은행정보 선택 버튼 이벤트
    fnBankSelected: function (component, event) {
        component.set('v.bankSelected', component.get('v.bankData'));
        component.set('v.isBankModalOpen', false);
    },
    // 여신관리(고객향) 변경 이벤트
    setPV_KDGRP: function (component, event) {
        console.log(component.find("PV_KDGRP__c").get("v.value"));
        component.find("PV_KDGRP__c").get("v.value");
        component.set('v.objCustomer.PV_KDGRP__c', component.find("PV_KDGRP__c").get("v.value"));
    },

    // 본점사용여부 변경 이벤트
    fnChangeCheckbox: function (component, event, helper) {
        console.log('=================> fnChangeCheckbox Start');

        var value = event.getSource().get("v.value");
        var fieldName = event.getSource().get("v.fieldName");
        console.log('========> value : '+value);
        console.log('========> fieldName : '+fieldName);

        var PV_HDOFFICEYN = component.get("v.objCustomer.PV_HDOFFICEYN__c");
        console.log('========> PV_HDOFFICEYN : '+PV_HDOFFICEYN);
    },

    // 전화번호, 팩스 입력 이벤트
    onInputPhone: function (component, event, helper) {
        //var value = component.find("pv_telf1").get("v.value");
        var value = event.getSource().get("v.value");

        console.log('===========> value : '+value);
        // 전화번호 포맷 자동 세팅
        event.getSource().set("v.value", helper.onInputPhone(value));
    },
    // 숫자 Validation Check
    handlerNumCheck: function (component, event, helper) {
        var whichOne = event.getSource().getLocalId();         
        var mycmp = component.find(whichOne);

        var value = mycmp.get("v.value");

        console.log('===========> value : '+value);

        event.getSource().set("v.value", helper.onInputNumber(value));

        /*
        var returnValue = helper.onInputNumber(value);
        console.log('===========> returnValue : '+returnValue);
        event.getSource().set("v.value", returnValue);
        */
    }
})