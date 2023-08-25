({
	
    /**
     * @description 초기화 ( IT 인 경우 선택목록 제한 해제)
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
		helper.getDataTable(component, event, helper);
    },

    /**
     * @description 데이터 행의 상세보기 클릭시 상세보기 창 열기
     */
    fnViewDetail : function(component, event, helper){
        component.set("v.showSpinner", true);
		component.set("v.modalStatus", 'ViewDetail');
		let selectedRow = event.getParam('row');
		component.set("v.strSearchMA", selectedRow.EmployeeNumber);
		helper.doViewDetail(component, event, helper);
    },

    /**
     * @description 전표처리 클릭시 화면 Open
     */
	fnOpenModal : function(component, event, helper) {
		let value = event.getSource().get("v.value");
		let listSearchWrapper = component.get("v.listSearchWrapper");

		let selectedYear = component.get("v.selectedYear");
		let selectedMonth = component.get("v.selectedMonth");

		let targetDate = new Date(selectedYear, selectedMonth, 10);
		targetDate.setMonth(targetDate.getMonth() +1);
		let strTargetDate = targetDate.getFullYear() + '-' +targetDate.getMonth()+ '-10';

		console.log('strTargetDate :: ' + strTargetDate);

		component.set("v.sendDate", strTargetDate);

		if(listSearchWrapper.length > 0) {
			component.set("v.modalStatus", value);
		} else {
			helper.showToast('info', '전표처리할 데이터가 없습니다.');
		}
	},
	
	
    /**
     * @description 지급기준일 확인 및 전표처리
     */
	fnSendCredit : function(component, event, helper) {
		let sendDate = component.get("v.sendDate");	
		console.log (" sendDate :: " + sendDate );

		if ( sendDate == null ){
			helper.showToast('error', '정상적인 지급기준일을 입력하세요.');
			return false;
		}
		helper.doSendCredit(component, event, helper);
	},

    /**
     * @description 전표처리 화면 닫기
     */
	fnCloseModal : function(component, event, helper) {
		component.set("v.modalStatus", 'Hide');
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