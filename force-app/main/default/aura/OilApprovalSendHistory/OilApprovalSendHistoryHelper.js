({
	
    /**
     * @description 초기화
     */
	doInit : function(component, event, helper) {
		component.set("v.showSpinner", true);

		component.set("v.selectedStatus", 'Request');
		component.set("v.selectedHeadOffice", 'none');
		component.set("v.selectedSU", 'none');

		component.set('v.listSearchWrapper', []);

        component.set("v.listColumn", [
            { label : '사업부', fieldName : 'SULabel', type: 'text', sortable: true},
            { label : '대상년월', fieldName : 'YearAndMonth', type: 'text', sortable: true},
            { label : '품의서', fieldName: "DocUrl", type: "url",
            typeAttributes: { label:  '품의서 열기' , target: '_blank' }},
            { label : '결재상태', fieldName : 'ApprovalStatusInfo', type: 'text', sortable: true},
            { label : '최근 결재 이력', fieldName : 'RecentApprovalInfo', type: 'text', initialWidth: 300, sortable: true},
            { label : '수금자 총 인원', fieldName : 'totalHeadcount', type: 'text', sortable: true},
            { label : '총 금액', fieldName : 'totalAmount', type: 'currency', cellAttributes: {
                alignment: 'left' }, typeAttributes: { currencyCode: 'KRW' }, sortable: true
            },
            { label : '등록자명', 'fieldName' : 'RegUser', 'type': 'text', sortable: true}
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

				// console.log( ' returnVal ::: ' + JSON.stringify(returnVal));

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
     * @description 초기 검색 ( 검색 전 문서 업데이트 대상 확인)
     */
	doGetTargetData : function(component, event, helper) {
        component.set("v.showSpinner", true);

		let selectedHeadOffice = component.get("v.selectedHeadOffice");
		let selectedSU = component.get("v.selectedSU");
		let selectedYear = component.get("v.selectedYear");
		let selectedMonth = component.get("v.selectedMonth");

        let action = component.get("c.doGetTargetData");
		
		let mapParam = {
			'selectedHeadOffice' : selectedHeadOffice,
			'selectedSU' : selectedSU,
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
	
				if(strStatus == "SUCCESS") {
					if(returnVal.listTargetId.length > 0) {
	                    this.doUpdateDocId(component, helper, returnVal.listTargetId, 0);
					}
					else {             
						this.showToast('info', '검색된 결과가 없습니다.');
						component.set('v.listSearchWrapper', []);     
						component.set("v.showSpinner", false);
					}
				}else {
					console.log('=======================> Error doGetTargetData');
					helper.showToast(strStatus, strMessage);
					component.set("v.showSpinner", false);
				}
			}
			else if (state === "INCOMPLETE") {
				alert("From server: " + response.getReturnValue());
				component.set("v.showSpinner", false);
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
				component.set("v.showSpinner", false);
			}
		});
        $A.enqueueAction(action);
	},

    
    /**
     * @description 검색 대상이 DocId를 가지고 있지 않을 때, 재무시스템을 통해 DocId 업데이트
     */
	doUpdateDocId : function(component, helper, listTargetId, currentIndex) {

        let action = component.get("c.doUpdateDocId");

        action.setParams({
			'targetId' : listTargetId[currentIndex]
        });

		action.setCallback(this, function(response) {
            let state = response.getState();

			if(state === "SUCCESS") {
				let returnVal = response.getReturnValue();
				let strStatus = returnVal.strStatus;
				let strMessage = returnVal.strMessage;
	
				console.log(' listTargetId :: ' + JSON.stringify(listTargetId));
				if(strStatus == "SUCCESS") {
					if(listTargetId.length > currentIndex) {
	                    this.doUpdateDocId(component, helper, listTargetId, currentIndex+1);
					}
					else {
	                    this.doUpdateDocState(component, helper, listTargetId, 0);
					}
				}else {
					console.log('=======================> Error doUpdateDocId');
					helper.showToast(strStatus, strMessage);
					component.set("v.showSpinner", false);
				}
			}
			else if (state === "INCOMPLETE") {
				alert("From server: " + response.getReturnValue());
				component.set("v.showSpinner", false);
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
				component.set("v.showSpinner", false);
			}
		});
        $A.enqueueAction(action);
	},

    /**
     * @description 검색 대상이 DocId를 가지고 있을 때, 전자결재시스템을 통해 결재상태 업데이트
     */
	doUpdateDocState : function(component, helper, listTargetId, currentIndex) {

        let action = component.get("c.doUpdateDocState");

        action.setParams({
			'targetId' : listTargetId[currentIndex]
        });

		action.setCallback(this, function(response) {
            let state = response.getState();

			if(state === "SUCCESS") {
				let returnVal = response.getReturnValue();
				let strStatus = returnVal.strStatus;
				let strMessage = returnVal.strMessage;
	
				if(strStatus == "SUCCESS") {
					if(listTargetId.length > currentIndex) {
	                    this.doUpdateDocState(component, helper, listTargetId, currentIndex+1);
					}
					else {
                        this.getDataTable(component, helper, listTargetId);
					}
				}else {
					console.log('=======================> Error doUpdateDocState');
					helper.showToast(strStatus, strMessage);
					component.set("v.showSpinner", false);
				}
			}
			else if (state === "INCOMPLETE") {
				alert("From server: " + response.getReturnValue());
				component.set("v.showSpinner", false);
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
				component.set("v.showSpinner", false);
			}
		});
        $A.enqueueAction(action);
	},

    /**
     * @description 검색 조건에 따라 데이터 검색
     */
	getDataTable : function(component, helper, listTargetId) {

        let action = component.get("c.getDataTable");

        action.setParams({
			'listTargetId' : listTargetId
        });

		action.setCallback(this, function(response) {
            let state = response.getState();

			if(state === "SUCCESS") {
				let returnVal = response.getReturnValue();
				let strStatus = returnVal.strStatus;
				let strMessage = returnVal.strMessage;
	
				if(strStatus == "SUCCESS") {
					if(returnVal.listSearchLineWrapper.length > 0) {
						component.set('v.listSearchWrapper', returnVal.listSearchLineWrapper);
					}
					else {
						component.set('v.listSearchWrapper', []);                    
						this.showToast('info', '검색된 결과가 없습니다.');
					}
				}else {
					console.log('=======================> Error getDataTable');
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