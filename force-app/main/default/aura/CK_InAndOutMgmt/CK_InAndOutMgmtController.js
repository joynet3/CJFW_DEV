({
    /* 
    ==================================================================================
        모드 진입
    ==================================================================================
    */
    
    // 입고 모드 진입
    fnImportMode : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set('v.screenStatus', "Import");
        helper.doGetData(component, event, helper);
    },

    // 출고 모드 진입
    fnExportMode : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set('v.screenStatus', "Export");
        helper.doGetData(component, event, helper);
    },

    // 라벨스캔 모드 진입
    fnScanMode : function(component, event, helper) {
        component.set('v.taskStatus', 'BarcodeScan');
        let listData = component.get('v.listData');
        let listBackUpData = JSON.parse(JSON.stringify(listData));
        component.set('v.listBackUpData', listBackUpData);
    },

    // 수동변경 모드 진입
    fnEditMode : function(component, event, helper) {
        component.set('v.taskStatus', 'MenualEdit');
        let listData = component.get('v.listData');
        let listBackUpData = JSON.parse(JSON.stringify(listData));
        component.set('v.listBackUpData', listBackUpData);
    }, 

    // 초기화면 진입
    fnHomeMode : function(component, event, helper) {
        component.set('v.screenStatus', "Home");
    },

    /* 
    ==================================================================================
    공통 기능
    ==================================================================================
    */
    
    // 초기화
    fnInit : function(component, event, helper) {
        if ( $A.get("$Browser.formFactor") != 'DESKTOP')
            component.set('v.isMobile', true);

        console.log('isMobile ::' +  component.get('v.isMobile'));
    },

    // 리스트 Paging
    fnRenderPage : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.doRenderPage(component);
    },

    // 상세 내역 Visible Toggle
    fnDetailOpenToggle : function(component, event, helper) {
        let pageRecords = component.get("v.pageRecords");
        let index = event.currentTarget.id;
        console.log('index :::::' + index) ;
        if(pageRecords[index].isOpen)
            pageRecords[index].isOpen = false;
        else
            pageRecords[index].isOpen = true;
        component.set("v.pageRecords", pageRecords);
    },
    
    // 상세 내역 Visiable ALL Toggle
    fnDetailAllOpenToggle : function(component, event, helper) {
        component.set("v.showSpinner", true);

        let pageRecords =component.get('v.pageRecords');
        let isAllOpen = component.get("v.isAllOpen");

        component.set("v.isAllOpen",!isAllOpen);

        for ( var i in pageRecords){
            pageRecords[i].isOpen = !isAllOpen;
        }
        component.set("v.pageRecords", pageRecords);
        
        component.set("v.showSpinner", false);
    },

    // 입출고 확인 CheckBox Toggle
    fnCheckToggle : function(component, event, helper) {
        let pageRecords = component.get("v.pageRecords");
        let index = event.getSource().get("v.id");

        if(pageRecords[index].CHECK__c == 'Y')
            pageRecords[index].CHECK__c = 'N';
        else
            pageRecords[index].CHECK__c = 'Y';

        component.set("v.pageRecords", pageRecords);
    },

    // 취소시 이전 데이터로 백업
    fnTaskCancel : function(component, event, helper) {
        component.set("v.showSpinner", true);
        let listBackUpData = component.get('v.listBackUpData');
        component.set('v.listData', listBackUpData);
        component.set('v.taskStatus', 'View');
        component.set('v.confirmStatus', 'Hide');
        helper.doRenderPage(component);
    },

    // 저장시 변경된 데이터로 Update
    fnTaskSave : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set('v.taskStatus', 'View');
        component.set('v.confirmStatus', 'Hide');
        helper.doSaveData(component);
    },

    // 확정 
    fnTaskConfirm : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set('v.taskStatus', 'View');
        component.set('v.confirmStatus', 'Hide');
        helper.doConfirmData(component);
    },

    /* 
    ==================================================================================
        Mobile Camera Scan
    ==================================================================================
    */

    returnBarcode : function(component, event, helper) { 
        component.set("v.showSpinner", true);
        let screenStatus = component.get('v.screenStatus');

        // 1. 바코드에서 검색키값 분리
        let returnvaluesScanner= event.getParam('value');
        let keyNumber;
        if (screenStatus == 'Import')
            // 1-1 입고의 경우 스캔값에서 주문번호 분리
            keyNumber = returnvaluesScanner.substr(5,10);
        if (screenStatus == 'Export'){
            // 1-2 출고의 경우 스캔값 그대로 사용 (배치번호)
            keyNumber = returnvaluesScanner;
        }
        
        // 2. 내역에서 주문번호를 통해 DataIndex 추출
        let listData = component.get('v.listData');

        let targetDataIndex = '';

        if (screenStatus == 'Import')
        targetDataIndex = listData.findIndex(objHeader => objHeader.EBELN__c === keyNumber);
        if (screenStatus == 'Export'){
            for(let i in listData){
                let result = listData[i].RELEASE_D__r.findIndex(objDetail => objDetail.CHARG__c === keyNumber);
                // helper.showToast('info', 'result : ' + result);
                if (result != -1){
                    targetDataIndex = i;
                    break;
                }
            }
            
            helper.showToast('info', 'input : ' + keyNumber + '/ table index : '+ targetDataIndex);
        }

        if( targetDataIndex == -1){
            helper.showToast('error', '해당하는 내역을 찾을 수 없습니다 : '+ keyNumber);
            component.set("v.showSpinner", false);
            return false;
        }

        // 3. DataIndex에 해당하는 Page 번호와 Line번호 계산 후 이동
        let viewDataIndex = targetDataIndex % 10 ; 
        let viewDataPageNumber = Math.floor(targetDataIndex / 10) +1 ; 
        component.set("v.pageNumber", viewDataPageNumber);

        // 4. 상세내역 펼치기 초기화 및 입고확인 체크
        for ( let i in listData){
            listData[i].isOpen = false;
            if ( i == targetDataIndex){
                listData[i].isOpen = true;
                listData[i].CHECK__c = 'Y';
            }
        }
        component.set('v.listData', listData);

        let pageRecords = component.get('v.pageRecords');
        for ( let i in pageRecords){
            pageRecords[i].isOpen = false;
            if ( i == viewDataIndex){
                pageRecords[i].isOpen = true;
                pageRecords[i].CHECK__c = 'Y';
            }
        }
        component.set('v.pageRecords', pageRecords);
        
        setTimeout(function(){ 
            component.set("v.ScanedItem", pageRecords[viewDataIndex].EBELN__c);
            component.set("v.showSpinner", false);
            setTimeout(function(){ 
                var currentIdxRow = document.getElementById('row-'+ viewDataIndex);
                currentIdxRow.scrollIntoView({behavior: "smooth", block: "start", inline: "start"});
            }, 200);
        }, 200);
    },

    /* 
    ==================================================================================
        CONFIRM
    ==================================================================================
    */

    // 취소 컨펌 
    fnTaskCancelConfirm : function(component, event, helper) {
        component.set('v.confirmStatus', 'Cancel');
    },

    // 저장 컨펌
    fnTaskSaveConfirm : function(component, event, helper) {
        component.set('v.confirmStatus', 'Save');
    },

    // 확정 컨펌
    fnApprovalConfirm : function(component, event, helper) {
        component.set('v.confirmStatus', 'Approval');
        component.set("v.ScanedItem", '');
    },

    // Confirm 창 닫기
    fnConfirmHide : function(component, event, helper) {
        component.set('v.confirmStatus', 'Hide');
        component.set('v.strScanInput', '');
    },




});