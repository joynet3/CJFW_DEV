({
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

                    console.log('============> isMDMParent : '+isMDMParent);

                    if(isMDMEdit) {                        
                        if(isMDMParent) {
                            component.set('v.isOpenOrgModal', true);
                        }else {
                            component.set('v.isOpenOrgModal2', true);
                        }
                    }else {
                        console.log('===============> Go New');
                        helper.helperGetCategoryLevel1(component, event, helper);
                    }
                    
                }else {
                    helper.showToast(strStatus, strMessage);
                }
            }
            component.set("v.isLoading", false);
        });

        $A.enqueueAction(action);
    },

    handleLevel1Clicked: function (component, event, helper) {
        const target = component.get("v.categoryLevel1Options")[event.currentTarget.dataset.record];
        
        console.log('Click Target'+JSON.stringify(target));

        component.set("v.processId", target.ProcessId__c);
        
        if(target.level__c != '2') {
            
            console.log('Click Targe22222t'+JSON.stringify(target));
            component.set("v.categoryLevel1Selected", target);
        }else {
            console.log('Click Targe333333t'+JSON.stringify(target));
            component.set("v.categoryLevel1Selected", component.get("v.categoryLevel1Options"))
        }
        helper.helperGetCategoryLevel2(component, event, helper, target);
    },

    handleLevel2Clicked: function (component, event, helper) {
        component.set("v.categoryLevel3Selected", null);
        
        
        const target = component.get("v.categoryLevel2Options")[event.currentTarget.dataset.record];
        
        
        console.log('Click 2 번 째 Target'+JSON.stringify(target));
        if (target.level__c != '3') {
            component.set("v.categoryLevel2Selected", target);
        } else {
            
        console.log('Click 2 번 째 Selected Target'+JSON.stringify(target));
            component.set("v.categoryLevel2Selected", component.get("v.categoryLevel2Options"))
        }
        helper.helperGetCategoryLevel3(component, event, helper, target);
    },

    handleLevel3Clicked: function (component, event, helper) {
        helper.helperHandleLevel3Clicked(component, event, helper);
    },
    
    handleClosePopup: function (component, event, helper) {
        helper.handleClosePopup(component, event, helper);
    },
    
    handleEvent : function(component, event, helper) {
        var isCreatedInfo = event.getParam("isOpenOrgModal");
        var isInfos = component.get('v.v.categoryLevel3Selected');
        component.set("v.isOpenOrgModal", isCreatedInfo);
        component.set("v.isOpenOrgModal2", isCreatedInfo);
        component.set('v.categoryLevel3Selected', isInfos);
        
    },
})