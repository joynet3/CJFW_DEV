({
    // Component Init
    fnInit : function(component, event, helper) {
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);
            
        helper.getInitData(component);
    },

    fnEditDetail : function(component, event, helper) {
        component.set("v.screenMode", 'EditDetail');
    },
    // 주소 등록 버튼 이벤트
    fnEditFull : function(component, event, helper) {
        component.set("v.screenMode", 'SearchFull');
    },
    // 저장 버튼 이벤트
    fnSaveFull : function(component, event, helper) {
        var bolAddrDetailCheckBox = component.get("v.bolAddrDetailCheckBox");
        var sAddrDetail = component.get("v.objAddress.sAddrDetail");
        if(bolAddrDetailCheckBox && (sAddrDetail === "" || sAddrDetail == undefined || sAddrDetail == null)){
            helper.showToast('error','상세주소를 입력해주세요');
        }else{
            helper.doSave(component);
        }

	},
    // 저장 버튼 이벤트
    fnSaveDetail : function(component, event, helper) {
        var bolAddrDetailCheckBox = component.get("v.bolAddrDetailCheckBox");
        var sAddrDetail = component.get("v.objAddress.sAddrDetail");
        if(bolAddrDetailCheckBox && (sAddrDetail === "" || sAddrDetail == undefined || sAddrDetail == null)){
            helper.showToast('error','상세주소를 입력해주세요');
        }else{
            helper.doSave(component);
        }

    },
    // 검색어 입력 이벤트
    fnHandleKeyup : function(component, event, helper) {
        var isEnterKey = event.keyCode === 13;

        if(isEnterKey) {
            // Search key validation
            var bCheckedSearchKey = helper.doCheckSearchKey(component.find("searchKey").get("v.value"));

            if(bCheckedSearchKey) {
                // Search     
                      
                helper.doSearchAddress(component, 1, 1);
            }
        }
    },
    // 이전페이지 이벤트
    fnPrevPage : function(component, event, helper) {
        var intPageNo  = component.get("v.intCurrentPage") - 1;
        var intPageIdx = component.get("v.intPageIdx") - component.get("v.intCntPerPage");

        helper.doSearchAddress(component, intPageNo, intPageIdx);
    },
    // 다음페이지 이벤트
    fnNextPage : function(component, event, helper) {
        var intPageNo  = component.get("v.intCurrentPage") + 1;
        var intPageIdx = component.get("v.intPageIdx") + component.get("v.intCntPerPage");

        helper.doSearchAddress(component, intPageNo, intPageIdx);
    },
    // 주소 선택 이벤트
    fnClickRoadAddr : function(component, event, helper) {
        var idx         = event.currentTarget.dataset.idx;
        var listAddress = component.get("v.listAddress");
        var objAddress  = listAddress[idx];
        component.set("v.objAddress", objAddress);
        
        component.set("v.sAddrDetail" , "");
        component.set("v.screenMode", 'EditFull');
    },
    // 이전 버튼 이벤트
    fnBack : function(component, event, helper) {
        component.set("v.AddrInputDiv" , true);

        component.set("v.dupConfirmStatus" , "N");
        component.set("v.alertType" , "");
        component.set("v.alertMessage" , "");
        component.set("v.isShowWarning" , false);

        component.set("v.screenMode", 'SearchFull');
    },
    // 취소버튼 이벤트
    fnCancel : function(component, event, helper) {
        helper.getInitData(component);
        component.set("v.screenMode", 'View');
        component.set("v.AddrInputDiv" , true);
    },
    
})