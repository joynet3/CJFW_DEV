({
    // Init
    doInit : function(component, event, helper) {
        document.title = "담당자 변경";
        component.set("v.showSpinner", true);
        component.set("v.selectedLocationStateProvince", 'none');
        component.set("v.selectedLocationState", 'none');
        component.set('v.listSearchWrapper', []);
        component.set('v.listLocationStateProvince', []);
        component.set('v.listLocationState', []);
        component.set('v.listSelected', []);
        component.set('v.selectedRows', []);
        component.set('v.listSearchWrapperUser', []);
        component.set('v.listSelectedUser', []);
        component.set('v.selectedRowsUser', []);
        component.set('v.listSearchWrapperChange', []);

        component.set("v.listColumn", [
            {'label' : '학교명', 'fieldName' : 'name', 'type': 'text', sortable: true},
            {'label' : '담당자명', 'fieldName' : 'ownerName', 'type': 'text', sortable: true},
            {'label' : '사원번호', 'fieldName' : 'ownerEmployeeNumber', 'type': 'text', sortable: true},
            {'label' : 'SMA 고객 관리 등급 코드', 'fieldName' : 'smaCustMngGrdCd', 'type': 'text', sortable: true},
            {'label' : '관할교육청', 'fieldName' : 'educationOffice', 'type': 'text', sortable: true},
            {'label' : '전화번호', 'fieldName' : 'phone', 'type': 'text', sortable: true},
            {'label' : '', 'fieldName' : 'recordLink', 'type': 'url', typeAttributes: {label: { fieldName: 'viewDetail' }, target: '_blank'}}
        ]);
        component.set("v.listColumnUser", [
            {'label' : '이름', 'fieldName' : 'userName', 'type': 'text', sortable: true},
            {'label' : '사원번호', 'fieldName' : 'employeeNumber', 'type': 'text', sortable: true},
            {'label' : '영업그룹', 'fieldName' : 'team', 'type': 'text', sortable: true},
            {'label' : '직책', 'fieldName' : 'title', 'type': 'text', sortable: true},
            {'label' : '전화번호', 'fieldName' : 'phone', 'type': 'text', sortable: true},
            {'label' : '', 'fieldName' : 'recordLink', 'type': 'url', typeAttributes: {label: { fieldName: 'viewDetail' }, target: '_blank'}}
        ]);
        component.set("v.listColumnChange", [
            {'label' : '이름', 'fieldName' : 'name', 'type': 'text', initialWidth: 150, sortable: true},            
            {'label' : '변경 전 담당 SMA', 'fieldName' : 'ownerName', 'type': 'text', initialWidth: 150, sortable: true},
            {'label' : '변경 전 담당 SMA 사원번호', 'fieldName' : 'ownerEmployeeNumber', 'type': 'text', initialWidth: 205, sortable: true},
            {'label' : '변경 후 담당 SMA', 'fieldName' : 'userName', 'type': 'text', initialWidth: 150},
            {'label' : '변경 후 담당 SMA 사원번호', 'fieldName' : 'employeeNumber', 'type': 'text', initialWidth: 205},
            {'label' : '', 'fieldName' : 'recordLink', 'type': 'url', initialWidth: 120, typeAttributes: {label: { fieldName: 'viewDetail' }, target: '_blank'}}
        ]);

        var action = component.get("c.doInit");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                var strStatus = returnVal.strStatus;
                var strMessage = returnVal.strMessage;
                if(strStatus == 'SUCCESS'){
                    component.set("v.listLocationStateProvince", returnVal.listLocationStateProvince);
                    component.set("v.listSmaCustMngGrdCd", returnVal.listSmaCustMngGrdCd);
                    let mapLocation = returnVal.mapLocation;
                    let reportUrl = returnVal.reportUrl;
                    console.log ('returnVal :: ' + JSON.stringify(returnVal) );
                    component.set("v.mapLocation", mapLocation);
                    component.set("v.reportUrl", reportUrl);
                    console.log( 'reportUrl ::: ' + reportUrl);
                    console.log( 'returnVal.reportUrl ::: ' + returnVal.reportUrl);
                }else{
                    helper.showToast("ERROR",strMessage);
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

    // 조회
    getDataTable : function(component, event, helper) {
        var selectedLocationStateProvince = component.get("v.selectedLocationStateProvince");
        var selectedLocationState = component.get("v.selectedLocationState");
        var selectedUserId = component.get("v.selectedUserId");
        var action = component.get("c.getDataTable");
        var mapParam = {
            'selectedLocationStateProvince' : selectedLocationStateProvince,
            'selectedLocationState' : selectedLocationState,
            'selectedUserId' : selectedUserId
        };
        console.log('=============> mapParam : '+JSON.stringify(mapParam));

        action.setParams({
            'mapParam' : mapParam
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();

                // 초기화
                component.set('v.listSelected', []);
                component.set('v.selectedRows', []);
                component.set('v.totalCount', 0);

                if(returnVal.listSearchWrapper.length > 0) {
                    var listSelected = {};
                    var dataLength = returnVal.listSearchWrapper.length;
                    component.set('v.isData', true);
                    component.set('v.listSearchWrapper', returnVal.listSearchWrapper);
                    component.set('v.totalNum', returnVal.listSearchWrapper.length);
                    console.log('listSearchWrapper : ' + component.get("v.listSearchWrapper").length);
                }
                else {
                    component.set('v.listSearchWrapper', []);
                    this.showToast('info', '검색된 결과가 없습니다.');
                    component.set('v.totalNum', 0);
                }
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();

                if(errors) {
                    if(errors[0] && errors[0].message) {

                        this.showToast('ERROR', errors[0].message);

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

    // 사용자 조회
    getUserDataTable : function(component, event, helper) {
        var action = component.get("c.getUserDataTable");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();

                // 초기화
                component.set('v.listSelectedUser', []);
                component.set('v.selectedRowsUser', []);

                console.log(returnVal.listSearchWrapper);
                if(returnVal.listSearchWrapper.length > 0) {
                    component.set('v.isDataUser', true);
                    component.set('v.listSearchWrapperUser', returnVal.listSearchWrapper);
                }
                else {
                    component.set('v.listSearchWrapperUser', []);
                    this.showToast('info', '해당 팀 유저가 없습니다.');
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

    // 사용자 변경
    doChangeOwner : function(component, event, helper) {
        var listSelected = component.get("v.listSelected");      
        let chunkSize = component.get("v.chunkSize");   
        helper.doChunk(component, event, helper, 'chgOwner', listSelected, 0, (chunkSize < listSelected.length ? chunkSize : listSelected.length)); 
    },
    doChangeSmaCustMngGrdCd : function(component, event, helper) {
        var listSelected = component.get("v.listSelected");      
        let chunkSize = component.get("v.chunkSize");   
        helper.doChunk(component, event, helper, 'chgCd', listSelected, 0, (chunkSize < listSelected.length ? chunkSize : listSelected.length)); 
    },
    // Null , Undefined , '' 체크
    isNullCheck : function(value){
        if(value == null || value == undefined || value == ""){
            return true;
        }
        else{
            return false;
        }
    },
    // Toast 메시지
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
    // Sort 
    fnSortData : function(component, event, strTarget) {
        console.log('strTarget : ' + strTarget);
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        var listSearchWrapper = component.get("v.listSearchWrapper" + strTarget);
        var reverse = sortDirection !== "asc";
        component.set("v.sortedBy"+strTarget, fieldName);
        component.set("v.sortedDirection"+strTarget, sortDirection);
        console.log(component.get("v.sortedBy"+strTarget));
        console.log(listSearchWrapper);
        listSearchWrapper.sort(this.fnSortBy(fieldName, reverse));
        component.set("v.listSearchWrapper" + strTarget, listSearchWrapper);
    },
    // Sort
    fnSortBy : function(field, reverse, primer) {
        var key = primer ? function(x) {return primer(x[field])} : function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a) == undefined ? "" :  key(a)
            , b = key(b) == undefined ? "" :  key(b)
            , reverse * ((a > b) - (b > a));
        }
    },
        /**
     * @description 대량 데이터 저장의 경우 진행
     * @param {String} targetInfo Target type(담당자 변경:chgOwner or 고객 등급 변경:chgCd )
     * @param {List<Object>} listTarget Target Object List
     * @param {String} startIdx Chunk startIdx
     * @param {String} endIdx Chunk endIdx
     */
    doChunk : function(component, event, helper, targetInfo, listTarget, startIdx, endIdx) {
        
        let chunkSize = component.get("v.chunkSize");
        let listTargetLength = listTarget.length;
        let listChunk = listTarget.slice(startIdx, endIdx);

        let action;
        if( targetInfo == 'chgOwner'){
            action = component.get("c.doChangeOwner");
            var strUserId = component.get("v.listSelectedUser")[0].id;
            action.setParams({
                'strOwnerId' : strUserId,
                'strListTarget' : JSON.stringify(listChunk)
            });
        }
        else if( targetInfo == 'chgCd'){
            action = component.get("c.doChangeSmaCustMngGrdCd");
            var selectedSmaCustMngGrdCd = component.get("v.selectedSmaCustMngGrdCd");    
            action.setParams({
                'strSmaCustMngGrdCd' : selectedSmaCustMngGrdCd,
                'strListTarget' : JSON.stringify(listChunk)
            });
        }

        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                // endIdx 가 총 길이와 같아질 때 까지 Chunk
                if(listTargetLength > endIdx) {
                    helper.doChunk(component, event, helper, targetInfo, listTarget, (startIdx + chunkSize), 
                                    (endIdx + chunkSize < listTargetLength ? endIdx + chunkSize : listTargetLength));
                }else{
                    if( targetInfo == 'chgOwner'){
                        helper.showToast('success', '담당자가 변경되었습니다.');                         
                    }else if( targetInfo == 'chgCd'){
                        component.set("v.selectedSmaCustMngGrdCd", "none"); 
                        helper.showToast('success', 'SMA 고객 관리 등급 코드가 변경되었습니다.');  
                    }                    
                    setTimeout(function(){
                        helper.getDataTable(component, event, helper);
                    }, 10);
                }
                
            } else if(state === "ERROR") {
                let errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else if(errors[0] && errors[0].pageErrors[0].message){
                        this.showToast("error", errors[0].pageErrors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });        
        $A.enqueueAction(action);
    },
})