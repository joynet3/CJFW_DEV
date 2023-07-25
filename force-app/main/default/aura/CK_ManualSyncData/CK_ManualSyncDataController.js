({

    fnInit : function(component, event, helper) {
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);

        console.log('isMobile ::' +  component.get('v.isMobile'));
        
        let sObjName = component.get("v.sObjName");
        let sObjLabel = component.get("v.sObjLabel");

        var mapCondition = {
            "pIsOrderChecked" : false,
            "pOrderDate" : $A.localizationService.formatDate(new Date(), "yyyyMMdd"),
            "pIsReleaseChecked" : false,
            "pReleaseDate" : $A.localizationService.formatDate(new Date(), "yyyyMMdd"),
            "pIsStockChecked" : false
        };


        if ( sObjName == 'ORDER_H__c'){
            mapCondition.pIsOrderChecked = true;
            sObjLabel = '입고';
        }
        else if ( sObjName == 'RELEASE_H__c'){
            mapCondition.pIsReleaseChecked = true;
            sObjLabel = '출고';
        }
        else if ( sObjName == 'STOCK__c'){
            mapCondition.pIsStockChecked = true;
            sObjLabel = '재고';
        }

        component.set("v.mapCondition", mapCondition);
        component.set("v.sObjLabel", sObjLabel);

        // helper.getInitData(component);
    },

    // 신규/병합 컨펌 Modal
    fnReceiveConfirm : function(component, event, helper) {
        let mapCondition = component.get("v.mapCondition");
        
        if( !mapCondition.pIsOrderChecked && !mapCondition.pIsReleaseChecked && !mapCondition.pIsStockChecked  ){
            helper.showToast("error", "동기화 대상이 선택되지 않았습니다");
            return false;
        }
        else if( mapCondition.pIsOrderChecked &&  mapCondition.pOrderDate.length != 8 ){
            helper.showToast("error", "기준일이 정상적으로 지정되지 않았습니다.");
            return false;
        }
        else if( mapCondition.pIsReleaseChecked && mapCondition.pReleaseDate.length != 8 ){
            helper.showToast("error", "기준일이 정상적으로 지정되지 않았습니다.");
            return false;
        }

        let strSyncType = '';
        if( mapCondition.pIsOrderChecked )
            strSyncType = strSyncType + '입고';
        if ( mapCondition.pIsReleaseChecked )
            strSyncType = strSyncType + ', 출고';
        if ( mapCondition.pIsStockChecked )
            strSyncType = strSyncType + ', 재고';

        var param = {
            "sHeader"       : "확인",
            "sContent"      : "<b> "+ strSyncType+ " 데이터가 동기화 됩니다. 다시한번 확인해주세요 </b>" ,
            "sConfirmBtn"   : "동기화",
            "sCancelBtn"    : "취소",
            "confirmAction" : component.getReference("c.fnSyncData")
        };
        helper.doCreateConfirmComponent(component, param); 
    },

    fnSyncData : function (component, event, helper) {
        let listTarget = [];
        

        console.log( 'listTarget:::' + listTarget.length); 
        let mapCondition = component.get("v.mapCondition");

        if( mapCondition.pIsOrderChecked ){
            listTarget.push('ORDER');
        }
        if ( mapCondition.pIsReleaseChecked ){
            listTarget.push('RELEASE');
        }
        if ( mapCondition.pIsStockChecked )
            listTarget.push('STOCK');

        component.set("v.listTarget", listTarget);

        helper.showToast("info", "데이터 동기화가 진행중입니다. 해당 페이지를 벗어나지 마세요.");
        component.set("v.showSpinner", true);
        helper.doSyncMaster(component);
    },
    
    // 신규/병합 컨펌 Modal
    fnReConfirm : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.doReConfirm(component);
    },
    
    fnClose : function (component, event, helper) {
        helper.doClose(component);
    },


})