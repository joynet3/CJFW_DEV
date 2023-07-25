({
    /**
     * @description 초기화 ( 검색조건 및 데이터 테이블 기본값 설정)
     */
	doInit : function(component, event, helper) {
		component.set("v.showSpinner", true);

		component.set("v.selectedStatus", 'Request');
		component.set("v.selectedHeadOffice", 'none');
		component.set("v.selectedSU", 'none');

		component.set('v.listSearchWrapper', []);
		component.set('v.listDetailSearchWrapper', []);

        component.set("v.listColumn", [
            {'label' : '사업부', 'fieldName' : 'SULabel', 'type': 'text', sortable: true},
            {'label' : '팀', 'fieldName' : 'TeamLabel', 'type': 'text', sortable: true},
            {'label' : '사원번호', 'fieldName' : 'EmployeeNumber', 'type': 'text', sortable: true},
            {'label' : '사원명', 'fieldName' : 'Name', 'type': 'text', sortable: true},
            {'label' : '유류유형', 'fieldName' : 'OilType', 'type': 'text', sortable: true},
            {'label' : '코스트센터', 'fieldName' : 'CostCenter', 'type': 'text', sortable: true},
            {'label' : '총 금액', 'fieldName' : 'totalAmount', 'type': 'currency', cellAttributes: {
                alignment: 'left' }, typeAttributes: { currencyCode: 'KRW' }, sortable: true
            },
            {'label' : '총 거리', 'fieldName' : 'totalDistanceWithKm', 'type': 'text', sortable: true, cellAttributes: { alignment: 'left' }},
            {'label' : '은행유형', 'fieldName' : 'BankCode', 'type': 'text', sortable: true},
            {'label' : '지급정보', 'fieldName' : 'PaymentCode', 'type': 'text', sortable: true},
            {'label' : '', 'type': 'button', typeAttributes: { label: '상세보기', variant: 'base'}}
        ]);

        component.set("v.listDetailColumn", [
            {'label' : '처리상태', 'fieldName' : 'strStatus', 'type': 'text', sortable: true},
            {'label' : '일자', 'fieldName' : 'eventDate', 'type': 'text', sortable: true},
            {'label' : 'SU', 'fieldName' : 'strHeadOffice', 'type': 'text', sortable: true},
            {'label' : '사업부', 'fieldName' : 'strSU', 'type': 'text', sortable: true},
            {'label' : '팀', 'fieldName' : 'strTeam', 'type': 'text', sortable: true},
            {'label' : '사원', 'fieldName' : 'strUserInfo', 'type': 'text', sortable: true},            
            {'label' : '금액', 'fieldName' : 'totalAmount', 'type': 'currency', cellAttributes: {
                alignment: 'left' }, typeAttributes: { currencyCode: 'KRW' }, sortable: true
            },
            {'label' : '거리', 'fieldName' : 'totalDistance', 'type': 'number', sortable: true, cellAttributes: { alignment: 'left' }},
            {'label' : '', 'fieldName' : 'recordLink', 'type': 'url', typeAttributes: {label: { fieldName: 'viewDetail' }, target: '_blank'}}
        ]);

        let action = component.get("c.doInit");

        action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                let returnVal = response.getReturnValue();
                let strStatus = returnVal.strStatus;
                let strMessage = returnVal.strMessage;

				console.log('=======================> SUCCESS');

				component.set("v.listSelectStatus", returnVal.listSelectStatus);
				
				let objUser = returnVal.objUser;
				let userType = component.get("v.userType");

				let mapSelectSU = returnVal.mapSelectSU; 
				component.set("v.mapSelectSU", mapSelectSU);
				component.set("v.listSelectHeadOffice", returnVal.listSelectHeadOffice);
				component.set("v.listSelectSU", mapSelectSU[objUser.HeadOffice__c]);
				component.set("v.listYear", returnVal.listYear);
				component.set("v.listMonth", returnVal.listMonth);
				component.set("v.selectedYear", returnVal.targetYear);
				component.set("v.selectedMonth", returnVal.targetMonth);


				if(!(helper.isNullCheck(objUser.HeadOffice__c))) {
					let listSelectHeadOffice = component.get("v.listSelectHeadOffice");
					if( userType == 'IT'){
						component.set("v.selectedHeadOffice", listSelectHeadOffice[0].value);
					}
					else {
						for ( let i in listSelectHeadOffice){
							if(listSelectHeadOffice[i].value == objUser.HeadOffice__c)
								listSelectHeadOffice[i].selected = true;
							else
								listSelectHeadOffice[i].selected = false;
						}
						component.set("v.selectedHeadOffice", objUser.HeadOffice__c);
					}
				}
				helper.showToast(strStatus, strMessage);
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                let errors = response.getError();
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

		let selectedHeadOffice = component.get("v.selectedHeadOffice");
		let selectedSU = component.get("v.selectedSU");
		let userType = component.get("v.userType");
		let selectedYear = component.get("v.selectedYear");
		let selectedMonth = component.get("v.selectedMonth");

        let action = component.get("c.getDataTable");
		
		let mapParam = {
			'selectedHeadOffice' : selectedHeadOffice,
			'selectedSU' : selectedSU,
			'userType' : userType,
			'selectedYear' : selectedYear,
			'selectedMonth' : selectedMonth
		};

		console.log('=============> mapParam : '+JSON.stringify(mapParam));

        action.setParams({
			'mapParam' : mapParam
        });

		action.setCallback(this, function(response) {
            let state = response.getState();

			if(state === "SUCCESS") {
				let returnVal = response.getReturnValue();
				let strStatus = returnVal.strStatus;
				let strMessage = returnVal.strMessage;
				let mapActivityReportId = returnVal.mapActivityReportId;
				// 초기화
				component.set('v.mapActivityReportId', mapActivityReportId);
				if(strStatus == "SUCCESS") {
					if(returnVal.listSearchWrapper.length > 0) {
						component.set('v.listSearchWrapper', returnVal.listSearchWrapper);
					}
					else {
						component.set('v.listSearchWrapper', []);                    
						this.showToast('info', '검색된 결과가 없습니다.');
					}
				}else {
					console.log('=======================> Error');
	
					helper.showToast(strStatus, strMessage);
				}
			}
			else if (state === "INCOMPLETE") {
				alert("From server: " + response.getReturnValue());
			}
			else if (state === "ERROR") {
				let errors = response.getError();
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
     * @description 상세보기 버튼 클릭시 상세 데이터 조회
     */
	doViewDetail : function(component, event, helper) {
        var action = component.get("c.doViewDetail");

		var mapParam = {
			'selectedStatus' : 'Approved',
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
	
				if(returnVal.listSearchWrapper.length > 0) {
					component.set('v.listDetailSearchWrapper', returnVal.listSearchWrapper);
				}
				else {
					component.set('v.listDetailSearchWrapper', []);                    
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
     * @description 전표처리 I/F 진행
     */
	doSendCredit : function(component, event, helper, ApprovalStatus) {
        component.set("v.showSpinner", true);		

        let action = component.get("c.doSendCredit");

		let mapActivityReportId = component.get("v.mapActivityReportId");		
		let sendDate = component.get("v.sendDate");	
		console.log('sendDate asd' + sendDate);
		let listSearchWrapper = component.get("v.listSearchWrapper");
	
        action.setParams({
			'strListTarget' : JSON.stringify(listSearchWrapper),
			'strMapActivityReportId' : JSON.stringify(mapActivityReportId),
			'strSendDate' : sendDate
        });

		action.setCallback(this, function(response) {
            let state = response.getState();

			if(state === "SUCCESS") {
				let returnVal = response.getReturnValue();
				let strStatus = returnVal.strStatus;
				let strMessage = returnVal.strMessage;
				
				if(strStatus == "SUCCESS") {
					helper.showToast('success', '전표처리가 정상적으로 완료되었습니다.');
					component.set('v.modalStatus', 'Hide');
					if (returnVal.DocUrl != ''){
						window.open(returnVal.DocUrl);
					}
				}else { 
					console.log('=======================> Error');
					helper.showToast(strStatus, strMessage);
				}
			}
			else if (state === "INCOMPLETE") {
				alert("From server: " + response.getReturnValue());
			}
			else if (state === "ERROR") {
				let errors = response.getError();
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
		let evt = $A.get("e.force:showToast");
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
        let listSearchWrapper = component.get("v.listSearchWrapper");
        let reverse = sortDirection !== "asc";
        listSearchWrapper.sort(this.fnSortBy(fieldName, reverse))
        component.set("v.listSearchWrapper", listSearchWrapper);
    },

    /**
     * @description 테이블 행 정렬 기능
     */
    fnSortBy : function(field, reverse, primer) {
        let key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a) == undefined ? "" :  key(a)
            , b = key(b) == undefined ? "" :  key(b)
            , reverse * ((a > b) - (b > a));
        }
    },
})