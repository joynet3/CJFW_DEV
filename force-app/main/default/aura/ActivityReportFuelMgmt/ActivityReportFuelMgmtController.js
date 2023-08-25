({

    /**
     * @description : 초기화 (모바일 여부 확인)
     */
    fnInit : function(component, event, helper) {        
        component.set("v.showSpinner", true);
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);
        console.log('isMobile ::' +  component.get('v.isMobile'));
        helper.doInit(component);
    },
    
    /**
     * @description : 상세 내역 Visible Toggle
     */
    fnDetailOpenToggle : function(component, event, helper) {
        let listData = component.get("v.listData");
        let index = event.currentTarget.id;
        if(listData[index].isDetailOpen)
            listData[index].isDetailOpen = false;
        else
            listData[index].isDetailOpen = true;
        component.set("v.listData", listData);
    },
    
    /**
     * @description : 상세 내역 Visible ALL Toggle
     */
    fnDetailAllOpenToggle : function(component, event, helper) {
        component.set("v.showSpinner", true);

        let listData =component.get('v.listData');
        let isAllOpen = component.get("v.isAllOpen");

        component.set("v.isAllOpen",!isAllOpen);

        for ( var i in listData){
            listData[i].isDetailOpen = !isAllOpen;
        }
        component.set("v.listData", listData);
        component.set("v.showSpinner", false);
    },

    /**
     * @description : 경유지 내역 Visible Toggle
     */
    fnWayPointOpenToggle : function(component, event, helper) {
        let listData = component.get("v.listData");
        let index = event.currentTarget.id;
        if(listData[index].isWayPointOpen)
            listData[index].isWayPointOpen = false;
        else
            listData[index].isWayPointOpen = true;
        component.set("v.listData", listData);
    },
    
    /**
     * @description : 주유비 설정 내역 저장
     */
    fnSave : function(component, event, helper) {
        
        component.set("v.showSpinner", true);
        let listDatalength =component.get('v.listDatalength');
        let listData =component.get('v.listData');

        console.log('listDatalength ::' + listDatalength);
        if(listDatalength == 0) {
            helper.showToast("error", "저장할 데이터가 없습니다.");
            component.set("v.showSpinner", false);
            return;
        }
        
        var saveType =event.getSource().getLocalId();
        console.log('fnSave saveType : ' + saveType );

        let isNoValue = true;
        for (let i in listData){
            if ( listData[i].Distancekm__c != null)
                isNoValue = false;
        }
        
        if(isNoValue && saveType == 'Final') {
            helper.showToast("error", "제출할 주유비 정보가 없습니다.");
            component.set("v.showSpinner", false);
            return;
        }

        if(component.get("v.isBTNClicked") == true){
            console.log("Duplication prevention!");
            return;
        }

        let totalCost = 0;
        
        for ( let i in listData ){
            totalCost = totalCost + listData[i].VehicleRefuelingCosts__c;
        }
        component.set("v.totalCost", totalCost);

        component.set("v.isBTNClicked", true); 
        helper.doSave(component, saveType);
    },

    /**
     * @description : 주유비 관리 화면 닫기
     */
    fnCancel : function(component, event, helper) {
        helper.doCloseModal(component);
    },

    /**
     * @description : 주유비 제출 (저장포함)
     */
    fnSubmit : function(component, event) {
        
        if( !component.get("v.isComplete") )
        return;

        let selectedIndex = component.get("v.selectedIndex");  
        let listData = component.get("v.listData");
        let objData = listData[selectedIndex];
        console.log('listData :: ' + listData);

        let tmapStartAddr = component.get("v.tmapStartAddr");
        console.log('tmapStartAddr :: ' + tmapStartAddr);
        let tmapStartDesc = component.get("v.tmapStartDesc");
        console.log('tmapStartDesc :: ' + tmapStartDesc);
        let tmapEndAddr = component.get("v.tmapEndAddr");
        console.log('tmapEndAddr :: ' + tmapEndAddr);
        let tmapEndDesc = component.get("v.tmapEndDesc");
        console.log('tmapEndDesc :: ' + tmapEndDesc);
        let tmapOriginDistance = component.get("v.tmapOriginDistance");
        console.log('tmapOriginDistance :: ' + tmapOriginDistance);
        let tmapDistance = component.get("v.tmapDistance");
        console.log('tmapDistance :: ' + tmapDistance);
        let tmapViaPoints = component.get("v.tmapViaPoints");
        console.log('tmapViaPoints :: ' + tmapViaPoints);
        let tmapViaPointsDesc = component.get("v.tmapViaPointsDesc");
        console.log('tmapViaPointsDesc :: ' + tmapViaPointsDesc);

        let objOilInfo = component.get("v.objOilInfo");  

        objData.Departure__c = tmapStartAddr;
        objData.DepartureDesc__c = tmapStartDesc;
        console.log( 'objData.DepartureDesc__c :: ' + objData.DepartureDesc__c);
        objData.Arrival__c = tmapEndAddr;
        objData.ArrivalDesc__c = tmapEndDesc;
        objData.Distancekm__c = tmapDistance;
        objData.DistancekmTmap__c = tmapOriginDistance;

        objData.VehicleRefuelingCosts__c = Math.round(tmapDistance*objOilInfo.Price);
        objData.ActualOilUnitPrice__c = Math.round(objData.VehicleRefuelingCosts__c / objData.Distancekm__c * 100) / 100 ;
        objData.NominalOilUnitPrice__c = objOilInfo.Price;
        objData.oil_type_cd__c = objOilInfo.TypeCode;
        objData.oil_type_nm__c = objOilInfo.TypeName;

        for (let i = 15; i > 0 ; i--){
            objData['WayPoint'+i+'__c'] = null;
            objData['WayPointDesc'+i+'__c'] = null;
        }

        let lastIndex = 0;
        for ( let i in tmapViaPoints ){
            let idx = Number(i)+1;
            console.log( 'idx ::'+ idx);
            objData['WayPoint'+ idx + '__c'] = tmapViaPoints[i];
            lastIndex = idx;
        }
        objData.WayPointCount = lastIndex;

        for ( let i in tmapViaPointsDesc ){
            let idx = Number(i)+1;
            console.log( 'idx ::'+ idx);
            objData['WayPointDesc'+ idx + '__c'] = tmapViaPointsDesc[i];
        }
        component.set("v.listData", listData);

        let totalDistance = 0;
        for ( let i in listData ){
            totalDistance = totalDistance + Number(listData[i].Distancekm__c);
        }
        component.set("v.totalDistance", totalDistance);
        
        let totalCost = 0;
        for ( let i in listData ){
            totalCost = totalCost + listData[i].VehicleRefuelingCosts__c;
        }
        component.set("v.totalCost", totalCost);
        component.set("v.isComplete", false);
    },
    
    /**
     * @description : Tmap 주소검색 호출
     */
    fnSearchAddress : function(component, event, helper) {
        var index = event.getSource().get("v.title");
        console.log('선택 ID : '+ index);
        component.set("v.selectedIndex", index);  
        component.set("v.isOpenTmap", true);  
    },
    
    /**
     * @description : 설정된 주유비 제거
     */
    fnDeleteAddress : function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.title");
        let lastSelectedIndex = component.get("v.selectedDeleteIndex");  

        // 선택한 값과 이전에 선택한 값이 같지 않으면 
        if ( lastSelectedIndex != selectedIndex){
            // 컨펌창 여부가 false 
            component.set("v.isDeleteConfirm", false);
            // 현재값을 이전 선택값에 넣기 
            component.set("v.selectedDeleteIndex", selectedIndex);
        }

        let isDeleteConfirm = component.get("v.isDeleteConfirm");  

        // 컨펌창 여부가 false면 경고 메세지 처리 
        if ( !isDeleteConfirm ){
            component.set("v.isDeleteConfirm", true);
            helper.showToast("info", "해당 주유비 정보가 삭제됩니다. 삭제를 위해 한번 더 클릭해주세요.");
            return;
        }
        
        let listData = component.get("v.listData");
        let objData = listData[selectedIndex];
        console.log( 'index ::: ' + selectedIndex);
        console.log( 'listData ::: ' + JSON.stringify(listData));
        console.log( 'objData ::: ' + JSON.stringify(objData));
        objData.Departure__c = '';
        objData.Arrival__c = '';
        objData.DepartureDesc__c = null;
        objData.ArrivalDesc__c = null;
        
        for (let i = 15; i > 0 ; i--){
            objData['WayPoint'+i+'__c'] = null;
            objData['WayPointDesc'+i+'__c'] = null;
        }

        objData.VehicleRefuelingCosts__c = null;
        objData.Distancekm__c = null;
        objData.DistancekmTmap__c = null;
        objData.WayPointCount = 0;
        objData.isWayPointOpen = false;

        component.set("v.listData", listData);
    },
    
    /**
     * @description 비고조회 화면 열기
     */
	fnOpenModal : function(component, event, helper) {
        let value = event.getSource().getLocalId();
        let selectedIndex = event.getSource().get("v.name");
        
        let listData = component.get("v.listData");
        let objData = listData[selectedIndex];

        if (value.startsWith('Start')){
            component.set("v.modalStatus", 'Description');
            component.set("v.modalTitle", '[출발지] 비고');
            component.set("v.modalDesc", objData.DepartureDesc__c);

        } else if (value.startsWith('End')){
            component.set("v.modalStatus", 'Description');
            component.set("v.modalTitle", '[도착지] 비고');
            component.set("v.modalDesc", objData.ArrivalDesc__c);

        } else if (value.startsWith('Via')){
            component.set("v.modalStatus", 'Description');
            let viaNum = value.slice(7);
            component.set("v.modalTitle", '[경유지 ' + viaNum + '] 비고');
            component.set("v.modalDesc", objData['WayPointDesc'+ viaNum + '__c']);
        }
        console.log( 'value ::: ' + value);
        console.log( 'selectedIndex ::: ' + selectedIndex);
	},
    
    /**
     * @description 비고조회 화면 닫기
     */
	fnCloseModal : function(component, event, helper) {
		component.set("v.modalStatus", 'Hide');
	},
})