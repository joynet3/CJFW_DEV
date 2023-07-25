({
    /**
     * @description 초기화 
     */
	fnInit : function(component, event, helper) {
		let userType = component.get('v.userType');
		// 사용자 유형이 IT 인 경우 선택목록 제한 해제 (사업부, SU, 팀)
		if ( userType == 'IT'){
			component.set('v.isDisableHeadOffice', false);
			component.set('v.isDisableSU', false);
			component.set('v.isDisableTeam', false);
		// 사용자 유형이 사업부장(BM) 인 경우 선택목록 제한 해제 ( 팀)
		} else if ( userType == 'BM'){
			component.set('v.isDisableTeam', false);
		} 
		helper.doInit(component, event, helper);

    },
	
    /**
     * @description 처리상태 변경시 검색목록 초기화
     */
	fnChangeSearchType : function(component, event, helper) {	
		component.set('v.listSearchWrapper', []);
		component.set('v.listSelected', []);
		component.set('v.selectedRows', []);
    },
	
    /**
     * @description 기준년도 변경시 검색목록 초기화
     */
     fnChangeYear : function(component, event, helper) {  
		component.set('v.listSearchWrapper', []);
		component.set('v.listSelected', []);
		component.set('v.selectedRows', []);
		console.log('selectedYear ::: ' + component.get('v.selectedYear'));
    },

    /**
     * @description 기준월 변경시 검색목록 초기화
     */
     fnChangeMonth : function(component, event, helper) {  
		component.set('v.listSearchWrapper', []);
		component.set('v.listSelected', []);
		component.set('v.selectedRows', []);
		console.log('selectedMonth ::: ' + component.get('v.selectedMonth'));
    },

    /**
     * @description 데이터 조회
     */
	fnSearch : function(component, event, helper) {		
		helper.getDataTable(component, event, helper);
    },

	
    /**
     * @description 데이터 선택 시 선택 데이터 및 총 개수 셋팅
     */
    fnSelected : function(component, event, helper){
		var selectedRows = event.getParam("selectedRows");
		component.set('v.totalCount', selectedRows.length);
		component.set('v.listSelected', event.getParam("selectedRows"));

		console.log('v.listSelected :' + component.get('v.listSelected'))
		console.log('v.totalCount :' + component.get('v.totalCount'))
    },

    /**
     * @description 승인 또는 반려 버튼 클릭시 화면 Open
     */
	fnOpenModal : function(component, event, helper) {
		let value = event.getSource().get("v.value");
		let totalCount = component.get("v.totalCount");

		if(totalCount > 0) {
			component.set("v.modalStatus", value);
		} else if ( value == 'Approve') {
			helper.showToast('info', '승인할 활동보고를 선택하세요.');
		} else if ( value == 'Reject') {
			helper.showToast('info', '반려할 활동보고를 선택하세요.');
		}
	},

    /**
     * @description 사업부 변경시 검색목록 초기화
     */
	fnChangeHeadOffice : function(component, event, helper) {
		let selectedHeadOffice = component.get("v.selectedHeadOffice");
		component.set("v.selectedTeam", 'none');	
		component.set("v.isDisableTeam", true);	
		
		let mapSelectSU = component.get("v.mapSelectSU");
		component.set("v.listSelectSU", mapSelectSU[selectedHeadOffice]);
	},
	
    /**
     * @description SU 변경시 검색목록 초기화
     */
	fnChangeSU : function(component, event, helper) {
		let selectedSU = component.get("v.selectedSU");
		if ( selectedSU == 'none' ){
			component.set("v.selectedTeam", 'none');	
			component.set("v.isDisableTeam", true);	
		} else {
			let mapSelectTeam = component.get("v.mapSelectTeam");
			component.set("v.isDisableTeam", false);	
			component.set("v.listSelectTeam", mapSelectTeam[selectedSU]);
		} 
	},
	
    /**
     * @description 승인 또는 반려 화면 닫기
     */
	fnCloseModal : function(component, event, helper) {
		component.set("v.modalStatus", 'Hide');
	},

    /**
     * @description 승인 진행
     */
	fnApprove : function(component, event, helper) {
		helper.doSave(component, event, helper, 'Approved');
	},
	
    /**
     * @description 반려 진행
     */
	fnReject : function(component, event, helper) {
		helper.doSave(component, event, helper, 'Rejected');
	},

    /**
     * @description 테이블 행 정렬 기능
     */
    fnColumnSorting : function(component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.fnSortData(component, fieldName, sortDirection);
    },

})