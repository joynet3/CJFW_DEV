({
	fnInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
    },

    fnAfterScriptLoad : function(component, event, helper) {
        console.log('=======================> fnAfterScriptLoad');

        component.set("v.listResultColumn", [                
                {'label' : '행번호', 'fieldName' : 'intSEQ', 'type': 'text', sortable:true},
				/*
				{'label' : 'SU', 'fieldName' : 'input_SLBZ_ORG_NM', 'type': 'text', sortable:true},
				{'label' : '사업부', 'fieldName' : 'input_DIV_NM', 'type': 'text', sortable:true},
				{'label' : '팀', 'fieldName' : 'input_BRC_NM', 'type': 'text', sortable:true},
				{'label' : '사번', 'fieldName' : 'input_EmployeeNumber', 'type': 'text', sortable:true},
				{'label' : 'MA명', 'fieldName' : 'input_MAName', 'type': 'text', sortable:true},				
                {'label' : '년도', 'fieldName' : 'input_Year', 'type': 'text', sortable:true},
				{'label' : '월', 'fieldName' : 'input_Month', 'type': 'text', sortable:true},
				{'label' : '신규/기존', 'fieldName' : 'input_Type', 'type': 'text', sortable:true},
				{'label' : '매출계획(원)', 'fieldName' : 'input_TargetNetAmount', 'type': 'text', sortable:true},
				{'label' : '매출이익계획(원)', 'fieldName' : 'input_TargetSalesProfit', 'type': 'text', sortable:true},
				*/
                {'label' : '상태', 'fieldName' : 'strStatus', 'text': 'text', sortable:true},
                {'label' : '결과메시지', 'fieldName' : 'strMessage', 'type': 'text', sortable:true},
            ]
        );
    },
	// 엑셀 파일 업로드 변경 이벤트
    fnHandleFilesChange : function(component, event, helper) {
        var files = event.getSource().get("v.files");
        var file = files[0];

        //console.log('==================> file : '+JSON.stringify(file));

		var isFS = component.get("v.isFS");

        if(!file || file.length == 0) return;

		var FieldList = [];

		console.log('==============> isFS : '+isFS);

		// 2023-02-23 FS인 경우 수주매출, 발생매출, 발생매출이익 추가
		if(isFS) {
			FieldList = [
				"SLBZ_ORG_NM__c", "SLBZ_ORG_ID__c", "DIV_NM__c", "DIV_ID__c", "BRC_NM__c", "BRC_ID__c",
				"EmployeeNumber__c", "MAName__c", "Year__c", "Month__c", "Type__c", "TargetNetAmount__c", "TargetSalesProfit__c",
				"OrderSalesAmount__c", "ActualSalesAmount__c", "ActualSalesAmountProfit__c"
			];

		}else {
			FieldList = [
				"SLBZ_ORG_NM__c", "SLBZ_ORG_ID__c", "DIV_NM__c", "DIV_ID__c", "BRC_NM__c", "BRC_ID__c",
				"EmployeeNumber__c", "MAName__c", "Year__c", "Month__c", "Type__c", "TargetNetAmount__c", "TargetSalesProfit__c",				
			];
		}
        
        var objExcelImport = {
            StartRow : 0,
            StartColumn : 0,
            FieldList : FieldList
        };
        
        helper.doXlsxRead(component, objExcelImport, file, helper);
    },
	// 업로드 버튼 이벤트
    fnAddItem: function(component, event, helper) {
        helper.showSpinner(component);
		
		var action = component.get("c.doAddItem");

        var listSuccessWrapper = component.get("v.listSuccessWrapper")

		action.setParams({
            recordId : component.get("v.recordId"),
			strAddItem : JSON.stringify(listSuccessWrapper),
            mapCount : {
                "totalCount":component.get("v.totalSize"),
                //"assetCount":component.get("v.totalAssetCount"),
                //"productItemCount":component.get("v.totalProductItemCount")
            }
		});

		action.setCallback(this, function(response) {
			var state = response.getState();
			var toast = $A.get("e.force:showToast");
						
			if(state === "SUCCESS") {
				//var returnVal = response.getReturnValue();

                helper.showToast('SUCCESS', 'Success');

                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
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
			helper.hideSpinner(component); 
		});

		$A.enqueueAction(action);
    },
	// 다운로드 버튼 이벤트
    fnExcelExport : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.doGetExportTarget(component);
	},
	// 양식 다운로드 버튼 이벤트
	fnOpenModal : function(component, event, helper) {
		let value = event.getSource().get("v.value");
		component.set("v.modalStatus", value);
	},
	// 양식 다운로드 팝업창 닫기 이벤트
	fnCloseModal : function(component, event, helper) {
		component.set("v.modalStatus", 'Hide');
	},
	// 본부 변경 이벤트
	fnChangeHeadOffice : function(component, event, helper) {
		let selectedHeadOffice = component.get("v.selectedHeadOffice");
		// component.set("v.selectedTeam", 'none');	
		// component.set("v.isDisableTeam", true);	
		
		let mapSelectSU = component.get("v.mapSelectSU");
		component.set("v.listSelectSU", mapSelectSU[selectedHeadOffice]);
	},
	// SU 변경 이벤트
	fnChangeSU : function(component, event, helper) {
		let selectedSU = component.get("v.selectedSU");
		// if ( selectedSU == 'none' ){
		// 	component.set("v.selectedTeam", 'none');	
		// 	component.set("v.isDisableTeam", true);	
		// } else {
		// 	let mapSelectTeam = component.get("v.mapSelectTeam");
		// 	component.set("v.isDisableTeam", false);	
		// 	component.set("v.listSelectTeam", mapSelectTeam[selectedSU]);
		// } 
	},
	// 취소버튼 이벤트
    fnCancel: function(component, event, helper) {
        console.log('==============> fnCancel');
        $A.get("e.force:closeQuickAction").fire();
    }
})