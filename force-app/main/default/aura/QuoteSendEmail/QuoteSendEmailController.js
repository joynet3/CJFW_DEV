/**
 * Created by 천유정 on 2022-12-26.
 */

({
    /**
     * @description 초기화
     */
    fnInit : function(component, event, helper) {
        component.set("v.listColumn", [
                {   label: '고객명',   fieldName: 'AccountURL',  type: 'url',    sortable: false,
                    typeAttributes: {
                        label: {    fieldName: 'AccountName'     },
                        target: '_blank'
                    }
                },
                {   label: '견적',   fieldName: 'QuoteURL',   type: 'url',    sortable: false,
                    typeAttributes: {
                        label: {    fieldName: 'QuoteName'     },
                        target: '_blank'
                    }
                },
        ]);
        component.set("v.isShowPopup", true);
        component.set("v.isFirstPage", true);
        helper.getInitData(component, event, helper);
    },

    /**
     * @description Account 검색
     */
    fnSearchAccount: function(component, event, helper){
        var keyCode = event.keyCode;
        console.log('[fnSearchAccount] keyCode =============================>', keyCode);
        let userEnteredValue = component.find("SearchKey").get("v.value");
        console.log('[fnSearchAccount] countPage =============================>' + userEnteredValue);
        //Enter Key
        if (keyCode == 13) {
            helper.doSearchAccount(component, event, helper, userEnteredValue);
        }
    },

    /**
     * @description 행 선택(Account 검색 결과창에서 체크박스 선택/해제 시)
     */
    fnSelectRow: function(component, event, helper){
        console.log('[fnSelectRow] Start =============================>');
        var idx = event.getSource().get("v.name");
        console.log('[fnSelectRow] idx =============================>' + idx);
        var value = event.getSource().get("v.checked");
        console.log('[fnSelectRow] value =============================>' + value);
        var data = component.get("v.pageRecords");
        var listSelectedData = component.get("v.listSelectedData");
        console.log('[fnSelectRow] listSelectedData', JSON.stringify(listSelectedData));

        if (idx != 'selectAll') {
            data[idx].checked = value;
            if(value) {
                if (!listSelectedData.includes(data[idx])) {
                    listSelectedData.push(data[idx]);
                }
            } else {
                console.log('[fnSelectRow] data[idx]?', data[idx]);
                //console.log('[fnSelectRow] listSelectedData.indexOf(data[idx])', listSelectedData.indexOf(data[idx]));
                //listSelectedData.splice(listSelectedData.indexOf(data[idx]), 1);
                let deleteIdx = 0;
                for(var index = 0; index < listSelectedData.length; index++){
                    console.log('[fnSelectRow] data[idx].Id)', data[idx].Id);
                    console.log('[fnSelectRow] listSelectedData[idx].Id', listSelectedData[index].Id);
                    if (data[idx].Id == listSelectedData[index].Id) {
                        deleteIdx = index;
                    }
                }
                listSelectedData.splice(deleteIdx, 1); 
            }
            component.set("v.listSelectedData", listSelectedData);
            component.set("v.pageRecords", data);
            let isUnChecked = true;
            for(var row of data){
                console.log('[fnSelectRow] row is checked?', row.checked);
                if(row.checked){
                    isUnChecked = false;
                }
            }
        } else {
            console.log('[fnSelectRow] select All');
            for(var idx = 0; idx < data.length; idx++){
                if (value != data[idx].checked) {
                    if(value){
                        if (!listSelectedData.includes(data[idx]))
                            listSelectedData.push(data[idx]);
                    } else {
                        listSelectedData.splice(listSelectedData.indexOf(data[idx]), 1);
                    }
                }
                data[idx].checked = value;
            }
            component.set("v.listSelectedData", listSelectedData);
            component.set("v.pageRecords", data);
        }
        console.log('[doRenderSelectedPage] listSelectedData.length =============================>' + listSelectedData.length);
        console.log('[fnSelectRow] End =============================>');
        helper.doSetDisability(component, event, helper);
    },

    /**
     * @description 행 삭제(Account 선택 목록의 'X' 아이콘 클릭 시)
     */
    fnSelectDelete: function(component, event, helper){
        console.log('[fnSelectDelete] ======================> Start!!! ');
        var selectedItem = event.currentTarget;
        let paramStr = JSON.stringify(event.currentTarget, null, 4);
        console.log('[fnSelectDelete] ======================> paramStr ' + paramStr);
        var index = selectedItem.dataset.index;
        console.log('[fnSelectDelete] ======================> index ' + index);
        var dataRow = selectedItem.dataset.record;
        console.log('[fnSelectDelete] ======================> dataRow ' + JSON.stringify(dataRow));

        var data = component.get("v.listSearchResult");
        var SelectedPageRecords = component.get("v.SelectedPageRecords");
        var listSelectedData = component.get("v.listSelectedData");
        let obj = SelectedPageRecords[dataRow];

        console.log('[fnSelectDelete] ======================> SelectedPageRecords[dataRow] ' + JSON.stringify(SelectedPageRecords[dataRow]));
        console.log('[fnSelectDelete] ======================> SelectedPageRecords.indexOf(SelectedPageRecords[dataRow] ' + JSON.stringify(SelectedPageRecords.indexOf(SelectedPageRecords[dataRow])));
        console.log('[fnSelectDelete] ======================> listSelectedData.indexOf(SelectedPageRecords[dataRow]) ' + JSON.stringify(listSelectedData.indexOf(SelectedPageRecords[dataRow])));
        listSelectedData.splice(listSelectedData.indexOf(SelectedPageRecords[dataRow]), 1);
        SelectedPageRecords.splice(SelectedPageRecords.indexOf(SelectedPageRecords[dataRow]), 1);



        component.set("v.SelectedPageRecords", SelectedPageRecords);
        component.set("v.listSelectedData", listSelectedData);
        console.log('[fnSelectDelete] ======================> SelectedPageRecords ' + JSON.stringify(SelectedPageRecords));
        console.log('[fnSelectDelete] ======================> listSelectedData ' + JSON.stringify(listSelectedData));

        for(var row of data){
            if (row.Id === obj.Id) {
                if(row.checked){
                    row.checked = false;
                }
            }
        }
        component.set("v.listSearchResult", data);
        helper.doSetDisability(component, event, helper);
        helper.doRenderPage(component);
        helper.doRenderSelectedPage(component);
        console.log('[fnSelectDelete] ======================> End!!!');
    },

    /**
     * @description 다음 페이지로 이동
     *              1. Quote 생성, 파일생성 및 이메일 전송 여부 체크
     *              2. Account 검색
     *              3. 선택한 Account 목록 및 Email 지정
     *              4. Email 작성(Email 전송 여부 체크 시)
     */
    fnNextPage: function(component, event, helper){
        var currentPage = component.get("v.countPage");                 //현재 페이지 위치
        var sendYN = component.get("v.sendYN");                         //이메일 전송 여부 선택값
        var fileType = component.get("v.fileType");                     //파일 생성 여부 선택값
        let listSelectedData = component.get("v.listSelectedData");     //Account 선택 목록

        console.log('[fnNextPage] sendYN =============================>' + sendYN);

        if (currentPage === 1) {
            if (fileType == 'N') {
                component.set("v.sendYN", 'N');
            }
            component.set("v.isFirstPage", false);
            component.set("v.isSecondPage", true);
            component.set("v.countPage", 2);
        } else if (currentPage === 2) {
            component.set("v.isSecondPage", false);
            component.set("v.isThirdPage", true);
            component.set("v.countPage", 3);
            // 선택 목록 Paging
            var dataLength = listSelectedData.length;
            component.set('v.SelectedPageNumber', 1);
            component.set('v.SelectedTotal', dataLength);
            component.set('v.SelectedPages', Math.ceil(dataLength / 10));
            component.set('v.SelectedMaxPage', Math.floor((dataLength + 9) / 10));
            helper.doRenderSelectedPage(component);
        } else if (currentPage === 3) {
            component.set("v.isThirdPage", false);
            component.set("v.isForthPage", true);
            component.set("v.countPage", 4);
        }
        console.log('[fnNextPage] countPage =============================>' + component.get("v.countPage"));
        helper.doSetDisability(component, event, helper);
    },

    /**
     * @description 이전 페이지로 이동
     */
    fnPrevPage: function(component, event, helper){
        var currentPage = component.get("v.countPage");                 //현재 페이지 위치
        if (currentPage === 2) {
            component.set("v.isFirstPage", true);
            component.set("v.isSecondPage", false);
            component.set("v.countPage", 1);
        } else if (currentPage === 3) {
            component.set("v.isSecondPage", true);
            component.set("v.isThirdPage", false);
            component.set("v.countPage", 2);
        } else if (currentPage === 4) {
            component.set("v.isThirdPage", true);
            component.set("v.isForthPage", false);
            component.set("v.countPage", 3);
        }
        console.log('[fnPrevPage] countPage =============================>' + component.get("v.countPage"));
        helper.doSetDisability(component, event, helper);
    },

    /**
     * @description 저장 버튼 클릭 시
     */
    fnSave: function(component, event, helper){
        helper.showSpinner(component);

        var validMessage = '';
        var emailContent = component.get("v.emailContent");         //메일의 제목
        var emailSubject = component.get("v.emailSubject");         //메일의 내용
        var listColumn = component.get("v.listColumn");             //생성 완료된 Quote 목록 컬럼
        var sendYN = component.get("v.sendYN");                     //이메일 전송 여부 선택값

        if (sendYN == 'Y') {
            if (helper.isNullCheck(emailSubject)) {
                validMessage = '메일의 제목을 작성해주세요.';
            }
            if (helper.isNullCheck(emailContent)) {
                validMessage = '메일의 내용을 작성해주세요.'; 
            }
            listColumn.push({ label: '고객 메일 주소',   fieldName: 'EmailAddress',  type: 'String',    sortable: false },
                                                { label: '메일 전송 여부',   fieldName: 'IsSucceedSendEmail',  type: 'String',    sortable: false });
            component.set("v.listColumn", listColumn);
        }

        if(validMessage != '') {
            helper.hideSpinner(component);
            helper.showToast('info', validMessage);
            return;
        }

        component.set("v.isThirdPage", false);
        component.set("v.isForthPage", false);
        component.set("v.isShowProgressBar", true);
        helper.doSave(component, event, helper);
    },

    /**
     * @description 메인 화면 닫기
     */
    fnCancel : function(component, event, helper) {
        window.location.href = "/" + component.get("v.recordId"); 
    },

/*    editRecord : function(component, event, helper) {
        console.log('==========> editRecord');
        var selectedItem =  event.currentTarget;
        console.log('======================> selectedItem ' + selectedItem);
        var index = selectedItem.dataset.index;
        console.log('======================> index ' + index);
        var listSelectedData = component.get('v.listSelectedData');
        console.log('listSelectedData[index].ContactId ::: ' + listSelectedData[index].ContactId);
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
             "recordId": listSelectedData[index].ContactId
       });
        editRecordEvent.fire();
    },*/

    /**
     * @description Account 검색 결과 Paging(DN_Paging)
     */
    fnRenderPage: function(component, event, helper) {
        component.set('v.isShowSpinner', true);
        helper.doRenderPage(component);
    },

    /**
     * @description Account 선택 목록 Paging(DN_Paging)
     */
    fnRenderSelectedPage: function(component, event, helper) {
        component.set('v.isShowSpinner', true);
        helper.doRenderSelectedPage(component);
    },

    /**
     * @description '연락처 검색(QuoteSendEmail_SelectContact)' 컴포넌트에서 연락처 선택 시 getEvent
     */
    fnSearchTarget : function(component, event, helper) {
        console.log('[fnSearchTarget] ========> Start!!!!');

        let paramStr = JSON.stringify(event.getParams(), null, 4);
        console.log('[fnSearchTarget] ========> paramStr ' + paramStr);
        var index = event.getParam("index");
        console.log('[fnSearchTarget] ========> index :  ' + index);
        var eventTarget = event.getParam("targetObject");
        console.log('[fnSearchTarget] ========> targetObject :  ' + eventTarget);

        var listSelectedData = component.get('v.listSelectedData');
        for ( var data of listSelectedData ) {
            if(data.Id == eventTarget.AccountId) {
                data.ContactId = eventTarget.Id;
                data.ContactName = eventTarget.Name;
                data.ContactEmail = eventTarget.Email;
                data.ContactURL = window.location.origin + '/lightning/r/Contact/' + eventTarget.Id + '/view';
            }
        }
        component.set('v.listSelectedData', listSelectedData);
        console.log('[fnSearchTarget] ========> listSelectedData :  ' + JSON.stringify(listSelectedData));
        helper.doRenderSelectedPage(component);
        helper.doSetDisability(component, event, helper);
    },

    /**
     * @description countPage(현재 페이지 위치) Value 변경 시, 각 Attributes 및 버튼 Disability 설정
     */
    fnSetDisability  : function(component, event, helper) {
        helper.doSetDisability(component, event, helper);
    },

/*    fnToggleFieldSelect : function(component, event, helper) {
        let isOpenFieldSelect = component.get("v.isOpenFieldSelect");
        component.set("v.isOpenFieldSelect", !isOpenFieldSelect);
    },

    fnSaveFieldSelect : function(component, event, helper) {
        component.set("v.isOpenFieldSelect", false);
        let listSelected = component.get("v.listSelected");
        console.log ( 'listSelected :: ' + listSelected);
        component.set("v.listSelectedSave", listSelected);
    },*/
});