({
    /**
     * @description 초기화 ( 검색조건 및 데이터 테이블 기본값 설정)
     */
	fnInit : function(component, event, helper) {
		let userType = component.get('v.userType');
		if ( userType == 'IT'){
			component.set('v.isDisableHeadOffice', false);
			component.set('v.isDisableSU', false);
		} 
		helper.doInit(component, event, helper);
    },
	
    /**
     * @description 기준년도&기준월 변경시 검색목록 초기화
     */
     fnChangeDate : function(component, event, helper) {  
		component.set('v.listSearchWrapper', []);
		console.log('selectedYear ::: ' + component.get('v.selectedYear'));
    },

    /**
     * @description 사업부 변경시 검색목록 초기화
     */
	fnChangeHeadOffice : function(component, event, helper) {
		let selectedHeadOffice = component.get("v.selectedHeadOffice");		
		let mapSelectSU = component.get("v.mapSelectSU");
		component.set("v.listSelectSU", mapSelectSU[selectedHeadOffice]);
		component.set("v.selectedSU", 'none');
		component.set('v.listSearchWrapper', []);
	},

    /**
     * @description SU 변경시 검색목록 초기화
     */
	fnChangeSU : function(component, event, helper) {
		component.set('v.listSearchWrapper', []);
	},

    /**
     * @description 데이터 조회
     */
	fnSearch : function(component, event, helper) {		
		helper.doGetTargetData(component, event, helper);
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