({

    /**
     * @description 초기화
     */
    fnInit : function(component, event, helper) {
        component.set("v.showSpinner", true);

        // 모바일 여부 확인
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);
        console.log('isMobile ::' +  component.get('v.isMobile'));
        
        // 품의이력 레코드 기본 셋팅
        let objDecisionProcess = { 		            
            Name: '',		
            Type__c: '',		
            DocStatus__c : '임시저장',
            Opportunity__c: component.get("v.recordId")
        };		
        component.set("v.objDecisionProcess", objDecisionProcess);

        helper.getInitData(component);
    },

    /**
     * @description 더블클릭 방지 해제
     */
    fnChange : function(component, event, helper) {
        component.set("v.isBTNClicked", false);
    },

    /**
     * @description 품의이력 레코드 셋팅 후 저장
     */
    fnSave : function(component, event, helper) {
        component.set("v.showSpinner", true);

        if(component.get("v.isBTNClicked") == true){
            console.log("Duplication prevention!");
            return;
        }
        component.set("v.isBTNClicked", true);  

        let listDocType = component.get("v.listDocType");
        
        let objDecisionProcess = component.get("v.objDecisionProcess");
        let docType = objDecisionProcess.Type__c

        // 품의유형을 품의이력 명으로 설정
        for ( let i in listDocType){
            if ( listDocType[i].value == docType) {
                objDecisionProcess.Name = listDocType[i].label;
            }
        }
        helper.doCheckOpenApproval(component, event, helper);
    },
    
    /**
     * @description 화면 닫기
     */
    fnCancel : function(component, event, helper) {
        helper.doCloseModal(component);
    },

})