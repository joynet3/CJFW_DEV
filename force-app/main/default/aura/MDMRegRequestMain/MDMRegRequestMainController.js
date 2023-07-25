({
    // Component Init function
    fnInit: function (component, event, helper) {
        var recordId = component.get('v.recordId');

        var action = component.get("c.doInit");
        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();

				var strStatus = returnVal.strStatus;
				var strMessage = returnVal.strMessage;

				if(strStatus == "SUCCESS") {
                    var isMDMEdit = returnVal.isMDMEdit;
                    var isMDMParent = returnVal.isMDMParent;
                    var isContact = returnVal.isContact;

                    console.log('============> isMDMParent : '+isMDMParent);

                    // MDM 고객등록 수정일 경우
                    if(isMDMEdit) {                        
                        if(isMDMParent) {
                            component.set('v.isOpenOrgModal', true);
                        }else {
                            component.set('v.isOpenOrgModal2', true);
                        }
                    }
                    // 영업기회(Opportunity)에서 고객등록일 경우
                    else {
                        console.log('================> isContact : '+isContact);
                        // 연락처정보가 존재할 경우 다음으로 진행
                        if(isContact) {
                            helper.helperGetCategoryLevel1(component, event, helper);
                        }else {
                            helper.showToast('ERROR', '연락처 정보가 없을 경우 MDM 고객 등록 요청을 할 수 없습니다. 고객정보의 연락처 정보를 입력하여 주시기 바랍니다.');
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    }
                }else {
                    helper.showToast(strStatus, strMessage);
                }
            }
            component.set("v.isLoading", false);
        });

        $A.enqueueAction(action);
    },
    // 본점, 판매처(Lv1) 클릭 이벤트
    handleLevel1Clicked: function (component, event, helper) {
        const target = component.get("v.categoryLevel1Options")[event.currentTarget.dataset.record];

        component.set("v.processId", target.ProcessId__c);
        
        if(target.level__c != '2') {
            component.set("v.categoryLevel1Selected", target);
        }else {            
            component.set("v.categoryLevel1Selected", component.get("v.categoryLevel1Options"));
        }
        component.set("v.isActiveNextBtn", false);
        helper.helperGetCategoryLevel2(component, event, helper, target);
    },
    // 워크플로우(Lv2) 클릭 이벤트
    handleLevel2Clicked: function (component, event, helper) {
        component.set("v.categoryLevel3Selected", null);

        const target = component.get("v.categoryLevel2Options")[event.currentTarget.dataset.record];
        
        if (target.level__c != '3') {
            component.set("v.categoryLevel2Selected", target);
        } else {
            component.set("v.categoryLevel2Selected", component.get("v.categoryLevel2Options"));
        }

        component.set("v.isActiveNextBtn", true);
        helper.helperGetCategoryLevel3(component, event, helper, target);
    },

    // 다음 버튼 클릭 이벤트
    handleLevel3Clicked: function (component, event, helper) {
        helper.helperHandleLevel3Clicked(component, event, helper);
    },    
    // 닫기 버튼 클릭 이벤트
    handleClosePopup: function (component, event, helper) {
        helper.handleClosePopup(component, event, helper);
    },
    // cj_CustomEvent Event Handler 이벤트
    handleEvent : function(component, event, helper) {
        var isCreatedInfo = event.getParam("isOpenOrgModal");
        var isInfos = component.get('v.v.categoryLevel3Selected');
        component.set("v.isOpenOrgModal", isCreatedInfo);
        component.set("v.isOpenOrgModal2", isCreatedInfo);
        component.set('v.categoryLevel3Selected', isInfos);
    },
})