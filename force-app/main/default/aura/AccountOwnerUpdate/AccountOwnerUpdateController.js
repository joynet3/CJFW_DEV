({
    fnInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.doInit(component, event, helper);
    },

    //조회 버튼 클릭 시
    fnSearch : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var userId = component.get("v.selectedUserId");
        var userName = component.get("v.selectedUserName");
        var displayedvalue = component.get("v.displayedvalue");
        if(component.get("v.selectedLocationStateProvince") != 'none' || (component.get("v.selectedUserId") != null && component.get("v.selectedUserId") != '')){            
            if((userId == null || userId == '') && (displayedvalue != null && displayedvalue != '')){ //입력된 값은 있으나 선택된 담당자가 없을 때
                component.set("v.showSpinner", false);
                component.set("v.displayedvalue", '');       
                helper.showToast('info', '담당자 선택이 필요합니다.');                         
            }else{
                helper.getDataTable(component, event, helper);
            }            
        }else{
            component.set("v.showSpinner", false);
            component.set("v.displayedvalue", '');  
            helper.showToast('info', '지역이나 담당자를 선택하세요.');
        }
    },
    selectedUserIdChange : function(component, event, helper) {
        let selectedUserId = component.get("v.selectedUserId");
        if(selectedUserId != undefined && selectedUserId != null && selectedUserId != ''){
            component.set("v.requiredYn", false);
        }else{
            let selectedLocationStateProvince = component.get("v.selectedLocationStateProvince");
            if(selectedLocationStateProvince != 'none'){
                component.set("v.requiredYn", false);
            }else{
                component.set("v.requiredYn", true);
            }            
        }
    },
    //사용자 조회 화면
    fnOpenModal : function(component, event, helper) {
        component.set("v.showSpinner", true);
        let totalCount = component.get("v.totalCount");
        var selectedRows = event.getParam("selectedRows");
        var listSelected = component.get("v.listSelected");
        console.log('totalCount : ' + totalCount);
        if(totalCount > 0) {
            for(var i=0 ; i<listSelected.length - 1; i++){
                if(listSelected[i].ownerId != listSelected[i+1].ownerId){
                    console.log(i + ' - i : ' + listSelected[i].ownerId);
                    console.log(i + ' - i+1 : ' + listSelected[i+1].ownerId);
                    component.set("v.openModal", 'Check');
                    component.set("v.showSpinner", false);
                    break;
                }
            }
            if(component.get("v.openModal") == 'Hide'){
                component.set("v.openModal", 'User');
                helper.getUserDataTable(component, event, helper);
            }
        } else{
            helper.showToast('info', '당담자를 변경할 고객정보를 선택하세요.');
            component.set("v.showSpinner", false);
        }
    },

    //SMA 고객 관리 등급 코드 변경 모달
    fnOpenModalOfChgCd : function(component, event, helper) {
        let totalCount = component.get("v.totalCount");
        if(totalCount > 0) {
            if(component.get("v.openModal") == 'Hide'){
                component.set("v.openModal", 'ChangeCd');
            }
        } else{
            helper.showToast('info', '변경할 고객정보를 선택하세요.');
        }
    },

    //SMA 고객 관리 등급 코드 변경 화면
    fnChangeSmaCustMngGrdCd : function(component, event, helper) {
        var selectedSmaCustMngGrdCd = component.get("v.selectedSmaCustMngGrdCd");
        if(selectedSmaCustMngGrdCd == 'none'){
            helper.showToast('info', '변경할 등급코드를 선택하세요.');
        }else{      
            component.set("v.openModal", 'Hide');  
            component.set("v.showSpinner", true);
            helper.doChangeSmaCustMngGrdCd(component, event, helper);
        }        
    },

    //지역(시,도) 변경 시 세부지역 리스트 변경
    fnChangeSiDo : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var repUser = component.get("v.selectedUserId");
        let selectedLocationStateProvince = component.get("v.selectedLocationStateProvince");
        let mapLocation = component.get("v.mapLocation");
        if(selectedLocationStateProvince != 'none'){
            component.set("v.listLocationState", mapLocation[selectedLocationStateProvince]);
            component.set("v.selectedLocationState", 'none');
            component.set("v.showSpinner", false);
            component.set("v.requiredYn", false);
        }else{
            component.set("v.listLocationState", []);
            component.set("v.selectedLocationState", 'none');
            component.set("v.showSpinner", false);
            console.log('repUser>>'+repUser);
            if(repUser == null|| repUser == ''){
                component.set("v.requiredYn", true);                
            }            
        }
    },

    //전체 리스트 보고서 이동
    fnOpenReport : function(component, event, helper) {
        let reportUrl = component.get("v.reportUrl");
        console.log('reportUrl :: ' + reportUrl);
        if ( reportUrl == '' || reportUrl == null ){
            helper.showToast('ERROR','연결된 보고서가 없습니다. 관리자에게 문의하세요.');
        } else {
            window.open(reportUrl);
        }

    },

    //모든 닫기 버튼
    fnCloseModal : function(component, event, helper) {
        component.set("v.isSelectUser", true);
        component.set("v.openModal", 'Hide');
        component.set("v.selectedSmaCustMngGrdCd", "none");  
        component.set("v.showSpinner", false);
    },

    //담당자 변경 버튼 클릭 시
    fnChangeOwner : function(component, event, helper) {
        component.set("v.openModal", 'Hide');  
        component.set("v.showSpinner", true);        
        helper.doChangeOwner(component, event, helper);
    },

    fnprogress : function(component, event, helper) {
        helper.getUserDataTable(component, event, helper)
        component.set("v.openModal", 'User');
    },

    //사용자 조회 화면 확인 버튼 -> 변경 내역 확인 화면
    fnOpenChangeModal : function(component, event, helper) {
        var listSelectedUser = component.get("v.listSelectedUser");

        console.log('============> listSelectedUser : '+listSelectedUser);

        if(listSelectedUser == undefined || listSelectedUser == null || listSelectedUser == ''){
            helper.showToast('ERROR','사용자를 선택해주세요');
        }else{
            var listSelected = component.get("v.listSelected");
            var userName = component.get("v.listSelectedUser")[0].userName;
            var userEmployeeNumber = component.get("v.listSelectedUser")[0].employeeNumber;
            for(var i=0 ; i<listSelected.length; i++){
                listSelected[i].userName = userName;
                listSelected[i].employeeNumber = userEmployeeNumber;
            }
            component.set("v.listSearchWrapperChange", listSelected);
            component.set("v.openModal", 'Change');
        }

    },

    // DataTable Row Click 시
    fnSelected : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set('v.totalCount', selectedRows.length);
        component.set('v.listSelected', selectedRows);
    },

    // User DataTable Row Click 시
    fnUserSelected : function(component, event, helper){
        var selectedUserRows = event.getParam('selectedRows');
        component.set('v.listSelectedUser', event.getParam("selectedRows"));
        if(selectedUserRows != null){
            component.set("v.isSelectUser", false);
        }
    },

    //데이터 테이블 특정 필드 정렬 선택 시
    fnColumnSorting : function(component, event, helper) {
        helper.fnSortData(component, event, '');
    },
    fnUserColumnSorting : function(component, event, helper) {
        helper.fnSortData(component, event, 'User');
    },
    fnChangeColumnSorting : function(component, event, helper) {
        helper.fnSortData(component, event, 'Change');
    },


})