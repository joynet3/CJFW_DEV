({
	
    /**
     * @description 초기화 ( 검색조건 및 데이터 테이블 기본값 설정)
     */
	doInit : function(component, event, helper) {
		component.set("v.showSpinner", true);

		component.set("v.selectedStatus", 'Request');
		component.set("v.selectedHeadOffice", 'none');
		component.set("v.selectedSU", 'none');
		component.set("v.selectedTeam", 'none');

		component.set("v.inqStartDate", null);
		component.set("v.inqEndDate", null);

		component.set('v.listSearchWrapper', []);
		component.set('v.listSelected', []);
		component.set('v.selectedRows', []);

		component.set('v.totalCount', 0);
 
        component.set("v.listColumn", [
            {'label' : '처리상태', 'fieldName' : 'strStatus', 'type': 'text', sortable: true},
            {'label' : '일자', 'fieldName' : 'eventDate', 'type': 'text', sortable: true},
            {'label' : 'SU', 'fieldName' : 'strHeadOffice', 'type': 'text', sortable: true},
            {'label' : '사업부', 'fieldName' : 'strSU', 'type': 'text', sortable: true},
            {'label' : '팀', 'fieldName' : 'strTeam', 'type': 'text', sortable: true},
            {'label' : '사원', 'fieldName' : 'strUserInfo', 'type': 'text', sortable: true},            
            {'label' : '금액', 'fieldName' : 'totalAmount', 'type': 'currency', cellAttributes: {
                alignment: 'left' }, typeAttributes: { currencyCode: 'KRW' }, sortable: true
            },
            {'label' : '거리', 'fieldName' : 'totalDistance', 'type': 'number', sortable: true, cellAttributes: { alignment: 'right' }},
            {'label' : '', 'fieldName' : 'recordLink', 'type': 'url', typeAttributes: {label: { fieldName: 'viewDetail' }, target: '_blank'}}
        ]);

        var action = component.get("c.doInit");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                var strStatus = returnVal.strStatus;
                var strMessage = returnVal.strMessage;

				console.log('=======================> SUCCESS');

				component.set("v.listSelectStatus", returnVal.listSelectStatus);
				
				let objUser = returnVal.objUser;
				let userType = component.get("v.userType");

				let mapSelectSU = returnVal.mapSelectSU; 
				let mapSelectTeam = returnVal.mapSelectTeam; 
				component.set("v.mapSelectSU", mapSelectSU);
				component.set("v.mapSelectTeam", mapSelectTeam);

				component.set("v.listSelectHeadOffice", returnVal.listSelectHeadOffice);
				component.set("v.listSelectSU", mapSelectSU[objUser.HeadOffice__c]);
				component.set("v.listSelectTeam", mapSelectTeam[objUser.SU__c]);

				let targetYear = returnVal.targetYear;
				let targetMonth = returnVal.targetMonth;
				let listYear = returnVal.listYear;
				let listMonth = returnVal.listMonth;

				console.log('targetYear :: ' + targetYear );
				console.log('targetMonth :: ' + targetMonth );
				console.log('listYear :: ' + JSON.stringify(listYear) );
				console.log('listMonth :: ' + JSON.stringify(listMonth) );
				
				component.set("v.listYear", returnVal.listYear);
				component.set("v.listMonth", returnVal.listMonth);
				component.set("v.selectedYear", returnVal.targetYear);
				component.set("v.selectedMonth", returnVal.targetMonth);

				// 사업부 선택목록 설정
				if(!(helper.isNullCheck(objUser.HeadOffice__c))) {
					let listSelectHeadOffice = component.get("v.listSelectHeadOffice");
					if( userType == 'IT'){
						component.set("v.selectedHeadOffice", listSelectHeadOffice[0].value);
						component.set("v.isDisableTeam", true);	
					}
					else {
						for ( let i in listSelectHeadOffice){
							if(listSelectHeadOffice[i].value == objUser.HeadOffice__c)
								listSelectHeadOffice[i].selected = true;
							else
								listSelectHeadOffice[i].selected = false;
						}
					}
					component.set("v.selectedHeadOffice", objUser.HeadOffice__c);
				
				}

				// SU 선택목록 설정
				if(!(helper.isNullCheck(returnVal.objUser.SU__c))) {
					let listSelectSU = component.get("v.listSelectSU");
					if( userType == 'AS' || userType == 'IT'){
						component.set("v.selectedSU", 'none');
					}
					else {
						for ( let i in listSelectSU){
							if(listSelectSU[i].value == objUser.SU__c)
								listSelectSU[i].selected = true;
							else
								listSelectSU[i].selected = false;
						}
						component.set("v.selectedSU", objUser.SU__c);	
					}
				}

				// 팀 선택목록 설정
				if(!(helper.isNullCheck(returnVal.objUser.Team__c))) {
					let listSelectTeam = component.get("v.listSelectTeam");
					if( userType == 'AS' || userType == 'IT'){
						component.set("v.selectedTeam", 'none');
					}
					else {
						for ( let i in listSelectTeam){
							if(listSelectTeam[i].value == objUser.Team__c)
								listSelectTeam[i].selected = true;
							else
								listSelectTeam[i].selected = false;
						}
						if(  returnVal.objUser.Team__c == null){
							component.set("v.selectedTeam", 'none');
						}
						else{
							component.set("v.selectedTeam", returnVal.objUser.Team__c);
						}
					}
				}
				component.set("v.inqStartDate", returnVal.inqStartDate);
				component.set("v.inqEndDate", returnVal.inqEndDate);
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

			component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
    },

    /**
     * @description 조회조건에 따라 데이터 조회
     */
	getDataTable : function(component, event, helper) {
        component.set("v.showSpinner", true);

        var action = component.get("c.getDataTable");

		var mapParam = {
			'selectedStatus' : component.get("v.selectedStatus"),
			'selectedHeadOffice' : component.get("v.selectedHeadOffice"),
			'selectedSU' : component.get("v.selectedSU"),
			'selectedTeam' : component.get("v.selectedTeam"),
			'userType' : component.get("v.userType"),
			'selectedYear' : component.get("v.selectedYear"),
			'selectedMonth' : component.get("v.selectedMonth"),
			'strSearchMA' : component.get("v.strSearchMA")
		};

		console.log('=============> mapParam : '+JSON.stringify(mapParam));

        action.setParams({
			'mapParam' : mapParam
        });

		action.setCallback(this, function(response) {
            var state = response.getState();

			if(state === "SUCCESS") {
				var returnVal = response.getReturnValue();
				console.log('returnVal :: ' + JSON.stringify(returnVal) );
	
				// 초기화
				component.set('v.listSelected', []);
				component.set('v.selectedRows', []);
	
				if(returnVal.listSearchWrapper.length > 0) {
					component.set('v.listSearchWrapper', returnVal.listSearchWrapper);
				}
				else {
					component.set('v.listSearchWrapper', []);                    
					this.showToast('info', '검색된 결과가 없습니다.');
				}
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
			component.set("v.showSpinner", false);
		});

        $A.enqueueAction(action);
	},

    /**
     * @description 승인 및 반려 처리
     */
	doSave : function(component, event, helper, ApprovalStatus) {
        component.set("v.showSpinner", true);		

        var action = component.get("c.doSave");

		var listSelected = component.get("v.listSelected");		

        action.setParams({
			'strListTarget' : JSON.stringify(listSelected),
			'ApprovalStatus' : ApprovalStatus
        });

		action.setCallback(this, function(response) {
            var state = response.getState();

			if(state === "SUCCESS") {
				var returnVal = response.getReturnValue();
				var strStatus = returnVal.strStatus;
				var strMessage = returnVal.strMessage;
				
				if(strStatus == "SUCCESS") {
					if ( ApprovalStatus == 'Approved' )
						helper.showToast('success', '승인이 정상적으로 처리되었습니다.');
					else if ( ApprovalStatus == 'Rejected' )
						helper.showToast('success', '반려가 정상적으로 처리되었습니다.');
					component.set("v.modalStatus", "Hide");

					setTimeout(function(){
						component.set('v.listSearchWrapper', []);
						component.set('v.listSelected', []);
						component.set('v.selectedRows', []);
					}, 300);
				}else {
					console.log('=======================> Error');
	
					helper.showToast(strStatus, strMessage);
				}
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
			component.set("v.showSpinner", false);
		});

        $A.enqueueAction(action);
	},

    /**
     * @description Null 체크함수
     */
    isNullCheck : function(value){
        if(value == null || value == undefined || value == ""){
            return true;
        }
        else{
            return false;
        }
    },

    /**
     * @description 토스트 알림 창 표시 
     */
	showToast : function(type, message) {
		var evt = $A.get("e.force:showToast");
		evt.setParams({
			key     : "info_alt",
			type    : type,
			message : message
		});
		evt.fire();
	},

    /**
     * @description 테이블 행 정렬 기능
     */
	fnSortData : function(component, fieldName, sortDirection) {
        var listSearchWrapper = component.get("v.listSearchWrapper");
        var reverse = sortDirection !== "asc";
        listSearchWrapper.sort(this.fnSortBy(fieldName, reverse))
        component.set("v.listSearchWrapper", listSearchWrapper);
    },

    /**
     * @description 테이블 행 정렬 기능
     */
    fnSortBy : function(field, reverse, primer) {
        var key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a) == undefined ? "" :  key(a)
            , b = key(b) == undefined ? "" :  key(b)
            , reverse * ((a > b) - (b > a));
        }
    },
})