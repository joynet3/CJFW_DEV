({

    /**
     * @description 초기화 (기초 데이터 셋팅)
     */
    fnInit : function(component, event, helper) {
        component.set("v.isNewUpload", false);
        if(component.get("v.sObjectName") != ""){
            helper.doInit(component);
        }
    },

    /**
     * @description Sample 업로드 신규 ↔ 끝행추가 변경 시 경고 메세지 및 초기화
     */
    fnCheckRadioHandle : function(component, event, helper) {
        var radioValue = event.getSource().get("v.value");
        if ( radioValue == 'Y' ){
            component.set("v.isNewUpload", true);
            helper.showToast('Error', "[주의] 신규 업로드 시 입력된 데이터가 모두 삭제됩니다.");
        }
        else if ( radioValue == 'N' )
            component.set("v.isNewUpload", false);

        console.log( 'isNewUpload :: ' + component.get("v.isNewUpload"));
    },
    
    /**
     * @description 메뉴얼 다운로드
     */
    fnManualDownload : function(component, event, helper) {
        window.location.href = 'https://cjfw.file.force.com/sfc/dist/version/download/?oid=00D5i0000051CB8&ids=0685i00000ANLWf&d=%2Fa%2F5i000000kkvr%2FqBTxxuWL63bGqO5r0taLfNGVkCpThBaCS9_oo8_GJiA&asPdf=false';
    }, 

    /**
     * @description 견본 ↔ 전체 업로드 탭 변경시 유효성 체크 및 초기화
     */
    fnHandleActive : function(component, event, helper) {
        component.set("v.isNewUpload", false);
        var openTab = event.getSource().get('v.id');
        component.set("v.openTab", openTab);  

        if ( openTab == 'Full' && component.get("v.listLineItem").length > 10000 ){
            helper.showToast('ERROR', "제품을 10,000개 이상 등록할 수 없습니다.");
            component.set("v.openTab", 'Sample');  
        }
    }, 

    /**
     * @description Paste 완료 및 선택된 상품리스트에 반영
     */
    fnSave : function(component, event, helper) {
        if(component.get("v.isBTNClicked") == true){
            console.log("Duplication prevention!");
            return;
        }
        component.set("v.isBTNClicked", true);  
        helper.doSave(component);
    },
    
    /**
     * @description Excel Paste 화면 닫기
     */
    fnCancel : function(component, event, helper) {
        helper.doCloseModal(component);
    },

    /**
     * @description 전체 업로드 필드 선택값 변경 시 유효성 체크 및 초기화
     */
    fnHandleChangeDuallistBox : function(component, event, helper) {
        let listAvailable = component.get("v.listAvailable");
        let listSelected = component.get("v.listSelected");
        if( listSelected.includes('ProfitMargin__c') && listSelected.includes('UnitPrice')){
            listSelected.pop();
            helper.showToast('ERROR', "매익률과 판매가격 둘 중 하나만 선택가능합니다.");
        }

        let listSelectedLabel = [];
        for(let i in listSelected){
            for(let j in listAvailable){
                if ( listSelected[i] == listAvailable[j].value){
                    listSelectedLabel.push(listAvailable[j].label);
                }
            }
        }
        component.set("v.listViewData_Full", []);
        component.set("v.pageRecords_Full", []);
        component.set("v.listSelectedLabel", listSelectedLabel);
        console.log( " listSelected.lentgh ::: " + listSelected.length);

    },

    /**
     * @description 견본 업로드 렌더링
     */
    fnDataRender_Sample : function(component, event, helper) {
        console.log('start fnDataRender_Sample ::');
        component.set("v.showSpinner", true);

        let data = component.find('exceldata_Sample').get('v.value');
        component.find('exceldata_Sample').set('v.value','');

        let rows = [];
        if ( data == '' || data == null){
            helper.showToast('ERROR', "입력된 데이터가 없습니다." );
            component.set("v.showSpinner", false);
            return false;
        }

        // Excel -> Data 변환
        rows =  data.split("\n");
        let rowsLength = rows.length;
        let inputLength = rows[0].split("\t").length ;
        let listParseData = [];

        // 제한 행 개수 체크
        if ( rowsLength > 10000){
            helper.showToast('ERROR', "10,000행을 초과하여 입력할 수 없습니다. ( "+ rowsLength +" )" );
            component.set("v.showSpinner", false);
            return false;
        }

        for(let y in rows) {
            let cells = rows[y].split("\t");
            if ( inputLength == 1)
                listParseData.push(cells[0]);
            else if ( inputLength > 1)
                listParseData.push(cells[0]+'('+ cells[1]+')');
        }

        if( rows[rows.length-1] == ''){
            listParseData.splice(rows.length-1);
        }

        console.log('listParseData :::' + JSON.stringify(listParseData));

        component.set("v.listPasteTempResult_Sample", listParseData);

        // Paging 처리
        let countPerPage = component.get("v.countPerPage_Sample");
        component.set("v.pageNumber_Sample", 1);
        component.set("v.maxPage_Sample", Math.floor((listParseData.length + (countPerPage - 1)) / countPerPage));
        component.set("v.pageRecords_Sample", listParseData.slice( 0 , countPerPage));

        setTimeout(function(){ 
            component.set("v.showSpinner", false);
        }, 1000);
        console.log('end fnDataRender_Sample ::');
    },

    /**
     * @description 전체 업로드 렌더링
     */
    fnDataRender_Full : function(component, event, helper) {
        console.log('start fnDataRender_Full ::');
        component.set("v.showSpinner", true);
        
        let listSelected = component.get("v.listSelected");

        let data = component.find('exceldata_Full').get('v.value');
        component.find('exceldata_Full').set('v.value','');

        let rows = [];
        
        if ( data == '' || data == null){
            helper.showToast('ERROR', "입력된 데이터가 없습니다." );
            component.set("v.showSpinner", false);
            return false;
        }

        // Excel -> Data 변환
        rows =  data.split("\n");

        let rowsLength = rows.length;
        let listValidTargetData = [];
        let listParseData = [];
    
        // 제한 행 개수 체크
        if ( rowsLength > 10000){
            helper.showToast('ERROR', "10,000행을 초과하여 입력할 수 없습니다. ( "+ rowsLength +" )" );
            component.set("v.showSpinner", false);
            return false;
        }

        // 선택된 필드 갯수와 입력된 데이터 열 갯수 체크
        let fieldLength = listSelected.length
        let inputLength = rows[0].split("\t").length ;

        if ( fieldLength != inputLength){
            helper.showToast('ERROR', "선택된 필드와 입력된 데이터 열 갯수가 맞지 않습니다. ( 입력: " + inputLength +" / 선택: " + fieldLength + " )");
            component.set("v.showSpinner", false);
            return false;
        }

        for(let y in rows) {
            let objData = new Object;
            let cells = rows[y].split("\t");
            
            for( let i in listSelected){
                objData[listSelected[i]] = cells[i];
            }
            listValidTargetData.push(objData);
            listParseData.push(cells);
        }

        if( rows[rows.length-1] == ''){
            listValidTargetData.splice(rows.length-1);
            listParseData.splice(rows.length-1);
        }

        component.set("v.listViewData_Full", listParseData);
        component.set("v.listValidTargetData", listValidTargetData);

        // Paging 처리
        let countPerPage = component.get("v.countPerPage_Full");
        let listViewData_Full = component.get("v.listViewData_Full");

        component.set("v.pageNumber_Full", 1);
        component.set("v.maxPage_Full", Math.floor((listViewData_Full.length + (countPerPage - 1)) / countPerPage));
        component.set("v.pageRecords_Full", listViewData_Full.slice( 0 , countPerPage));

        helper.showToast('info', "데이터를 렌더링 중 입니다. 데이터가 클 수록 소요시간이 길어집니다.");

        helper.doCheckValid(component);

        console.log('end fnDataRender_Full ::');
    },

    
    /**
     * @description 견본 업로드 데이터 (미리보기) 페이지 이동시 리스트 재출력
     */
    fnRenderPage_Sample : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.doRenderPage_Sample(component);
    },

    /**
     * @description 전체 업로드 데이터 (미리보기) 페이지 이동시 리스트 재출력
     */
    fnRenderPage_Full : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.doRenderPage_Full(component);
    },
})