({
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
    // 이전 페이지 버튼 이벤트
    fnPrevPage : function(component, event, helper) {
        var intPageNo  = component.get("v.intCurrentPage") - 1;
        var intPageIdx = component.get("v.intPageIdx") - component.get("v.intCntPerPage");

        helper.doSearchAddress(component, intPageNo, intPageIdx);
    },
    // 다음 페이지 버튼 이벤트
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

        console.log(objAddress);
        component.set("v.objAddress", objAddress);

        var hasSaveFunc = component.get("v.hasSaveFunc");
        helper.doFireEvent(component, hasSaveFunc ? "SELECT" : "CLOSE");
    },

    fnKeyUpModal : function(component, event, helper) {
        if(event.keyCode === 27) { // ESC
            helper.doFireEvent(component, "CLOSE");
        }
    },
    // 닫기 버튼 이벤트 
    fnSearchClose : function(component, event, helper) {
        helper.doFireEvent(component, "CLOSE");
    },
    // 저장 버튼 이벤트
    fnSave : function(component, event, helper) {
        var bolAddrDetailCheckBox = component.get("v.bolAddrDetailCheckBox");
        var sAddrDetail = component.get("v.objAddress.sAddrDetail");
        if(bolAddrDetailCheckBox && (sAddrDetail === "" || sAddrDetail == undefined || sAddrDetail == null)){
            helper.showToast('error','상세주소를 입력해주세요');
        }else{
            helper.fnSaveRecord(component);
        }


	},
    // 이전 버튼 이벤트
    fnPrepage : function(component, event, helper) {
		helper.fnPrepage(component);
	},
    
})