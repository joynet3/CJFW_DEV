({
    /**
     * @description : 초기 데이터
     */
    doInit: function (component) {
        component.set("v.showSpinner", true);
        var action = component.get("c.getInitData");

        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                let objActivityReport = returnValue.objActivityReport;
                component.set("v.totalDistance", objActivityReport.OilTotalDistance__c);
                component.set("v.totalCost", objActivityReport.OilTotalAmount__c);
                let dDayMap = returnValue.dDayMap;
                let exceptionDateMap = returnValue.exceptionDateMap;
                let dueWeekMap = returnValue.dueWeekMap;
                let strStatus = returnValue.strStatus;
                let strMessage = returnValue.strMessage;

                // 일자 계산
                // this.searchPeriodCalculation(component);
                let today = new Date();
                today = new Date(today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
                let strActivityDate = objActivityReport.EventStartDate__c;
                let activityDate = new Date(strActivityDate);
                activityDate.setHours(activityDate.getHours() - 9);
                let CalcDay = Math.floor((today.getTime() - activityDate.getTime()) / (1000 * 60 * 60 * 24));

                console.log("strActivityDate :: " + strActivityDate);
                console.log("activityDate :: " + activityDate);

                console.log("오늘 날짜 :: " + today.toLocaleString());
                console.log("활동 날짜 :: " + activityDate.toLocaleString());
                console.log("차이 :: " + CalcDay + "일");

                // 1. 기본 유효성 체크 
                if (CalcDay < 0) {
                    this.showToast("error", "미래일자의 활동은 주유비를 수정할 수 없습니다.");
                    this.doCloseModal(component);
                    return false;
                } else if (objActivityReport.ApprovalStatus__c == "Request") {
                    this.showToast("error", "승인요청 상태에서는 주유비를 수정할 수 없습니다.");
                    this.doCloseModal(component);
                    return false;
                } else if (objActivityReport.ApprovalStatus__c == "Approved") {
                    this.showToast("error", "승인완료 상태에서는 주유비를 수정할 수 없습니다.");
                    this.doCloseModal(component);
                    return false;
                } else if (strStatus == "ERROR") {
                    this.showToast(strStatus, strMessage);
                    this.doCloseModal(component);
                    return false;
                } else if (strStatus == "warning") {
                    this.showToast(strStatus, strMessage);
                }

                // 2. 개인별 주유비 신청 가능 기간 예외처리 설정 유효성 체크
                let minDateTime = null;
                let StartDateTime = null;
                let EndDateTime = null;
                let isExceptionDateExist = false;
                let isExceptionDateValid = false;
                let now = new Date();

                if (exceptionDateMap.user != undefined) {
                    minDateTime = new Date(exceptionDateMap.user.MinDateTime__c);
                    minDateTime.setHours(minDateTime.getHours() - 9);
                    StartDateTime = new Date(exceptionDateMap.user.StartDateTime__c);
                    EndDateTime = new Date(exceptionDateMap.user.EndDateTime__c);
                    isExceptionDateExist = true;
                } else if (exceptionDateMap.profile != undefined) {
                    minDateTime = new Date(exceptionDateMap.profile.MinDateTime__c);
                    minDateTime.setHours(minDateTime.getHours() - 9);
                    StartDateTime = new Date(exceptionDateMap.profile.StartDateTime__c);
                    EndDateTime = new Date(exceptionDateMap.profile.EndDateTime__c);
                    isExceptionDateExist = true;
                } else if (exceptionDateMap.default != undefined ) {
                    minDateTime = new Date(exceptionDateMap.default.MinDateTime__c);
                    minDateTime.setHours(minDateTime.getHours() - 9);
                    StartDateTime = new Date(exceptionDateMap.default.StartDateTime__c);
                    EndDateTime = new Date(exceptionDateMap.default.EndDateTime__c);
                    isExceptionDateExist = true;
                }

                if ( isExceptionDateExist ){
                    // (오늘 >= 예외시작일) AND (오늘 <= 예외종료일)
                    if ( now >= StartDateTime && now <= EndDateTime ) {
                        // (활동일 >= 최소관리일) 
                        if ( activityDate >= minDateTime ){
                            isExceptionDateValid = true;
                        }
                        else {
                            this.showToast("error", minDateTime.getFullYear()+"년 "+ (minDateTime.getMonth()+1) +"월 " + minDateTime.getDate() +"일 " + "이후 활동만 주유비 설정이 가능합니다.");
                            this.doCloseModal(component);
                            return false;
                        }
                    } else {
                        isExceptionDateExist = false;
                    }
                }


                // 3. 전체 주유비 마감 기한 설정 유효성 체크
                let isdueWeekExist = false;
                let dueWeek = 1;
                let dueWeekValidDate = null;
                let strDueWeekValidDate = '';

                if (!isExceptionDateValid){
                    if (dueWeekMap.user != undefined) {
                        dueWeek = dueWeekMap.user.DueWeek__c;
                        isdueWeekExist = true;
                    } else if (dueWeekMap.profile != undefined) {
                        dueWeek = dueWeekMap.profile.DueWeek__c;
                        isdueWeekExist = true;
                    } else if (dueWeekMap.default != undefined) {
                        dueWeek = dueWeekMap.default.DueWeek__c;
                        isdueWeekExist = true;
                    } 
                    
                    // 개발자 하드 코딩용 
                    // let date = new Date('2023', '03')
                    // // 해당월의 첫날
                    // let firstDate = new Date(date.getFullYear(), date.getMonth(), 1);
                    // // 해당월의 마지막날 
                    // let lastDate = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                    
                    // 활동일 다음 월 계산
                    let activityDateNextMonth = new Date(activityDate.getFullYear(), activityDate.getMonth(), 1);
                    activityDateNextMonth.setMonth( activityDateNextMonth.getMonth() + 1 );
                    
                    // 활동일 다음 월의 첫날
                    let firstDate = new Date(activityDateNextMonth.getFullYear(), activityDateNextMonth.getMonth(), 1);
                    // 활동일 다음 월의 마지막날 
                    let lastDate = new Date(activityDateNextMonth.getFullYear(), activityDateNextMonth.getMonth() + 1, 0);

                    // 해당 월 첫 날의 요일 조회 
                    // 요일 ( JS기준 : 일:0 / 월:1 / 화:2 / 수:3 / 목:4 / 금:5 / 토:6 )
                    let dayOfFirstDate = firstDate.getDay();

                    let weekcount = 1;
                    let firstFridate = new Date(firstDate);

                    let mapFriday = new Map();

                    // 첫주차 금요일 체크
                    // (첫 주 시작일이 토요일인 경우, 다음 주 금요일을 1주차로 정의)
                    if ( dayOfFirstDate == 6){
                        firstFridate.setDate(firstDate.getDate() + 6);
                    } else {
                        let diffwithFri = 5 - dayOfFirstDate; 
                        firstFridate.setDate(firstDate.getDate() + diffwithFri);
                    }

                    // 나머지 주차별 금요일 찾기 
                    while (firstDate.getMonth() == firstFridate.getMonth() ){
                        let strMonth = (firstFridate.getMonth() + 1).toString();
                        strMonth = strMonth.length >= 2 ? strMonth : "0" + strMonth;
                        let strDate = firstFridate.getDate().toString()
                        strDate = strDate.length >= 2 ? strDate : "0" + strDate;
                        let srtFirstFridate = firstFridate.getFullYear().toString() + "-" + strMonth + "-" + strDate;
                        mapFriday.set(weekcount, srtFirstFridate);
                        firstFridate.setDate(firstFridate.getDate() + 7);
                        weekcount++;
                    }
                    
                    if ( mapFriday.get(dueWeek) == null) {
                        let lastWeek = weekcount-1;
                        strDueWeekValidDate = mapFriday.get(lastWeek); 
                        dueWeekValidDate = new Date(strDueWeekValidDate);
                        dueWeekValidDate.setHours(dueWeekValidDate.getHours() - 9);
                    } else { 
                        strDueWeekValidDate = mapFriday.get(dueWeek); 
                        dueWeekValidDate = new Date(strDueWeekValidDate);
                        dueWeekValidDate.setHours(dueWeekValidDate.getHours() - 9);
                    }
                    console.log( 'dueWeekValidDate ::: ' + dueWeekValidDate);
                    console.log( 'today ::: ' + today);

                    // 오늘 날짜가 마감기한을 넘겼고, 현재 월보다 활동월이 작은 경우 
                    if ( today > dueWeekValidDate && activityDate.getMonth() < today.getMonth()) {
                        let dueWeekMonth = dueWeekValidDate.getMonth()+1;
                        let dueWeekDate = dueWeekValidDate.getDate();
                        this.showToast("error", (activityDate.getMonth()+1) + "월 마감 기한("+ dueWeekMonth + "월 " + dueWeekDate + "일)이 지났습니다. " + (activityDate.getMonth()+1) + "월 주유비는 입력할 수 없습니다.");
                        this.doCloseModal(component);
                        return false;
                    } 
                }


                // 4. 조직별 주유비 신청 가능 기간 설정 유효성 체크
                let isNDayExist = false;
                let NDay = null;
                let NDayValidDate = new Date(today);

                if (!isExceptionDateValid){
                    if (dDayMap.user != undefined) {
                        NDayValidDate.setDate(NDayValidDate.getDate() - dDayMap.user.Nday__c);
                        NDay = dDayMap.user.Nday__c;
                        isNDayExist = true;
                    } else if (dDayMap.profile != undefined) {
                        NDayValidDate.setDate(NDayValidDate.getDate() - dDayMap.profile.Nday__c);
                        NDay = dDayMap.profile.Nday__c;
                        isNDayExist = true;
                    } else if (dDayMap.default != undefined) {
                        NDayValidDate.setDate(NDayValidDate.getDate() - dDayMap.default.Nday__c);
                        NDay = dDayMap.default.Nday__c;
                        isNDayExist = true;
                    } 
                    
                    if ( isNDayExist ){
                        if ( activityDate < NDayValidDate) {
                            this.showToast("error", NDay + "일이 지난 활동은 주유비를 입력(또는 수정)할 수 없습니다.");
                            this.doCloseModal(component);
                            return false;
                        } 
                    }
                }
                
                // NDay, 마감기한, 예외기간이 설정되지 않은 경우 Validate
                if ( !isExceptionDateExist && !isdueWeekExist && !isNDayExist ){
                    let defaultValidDate = new Date(activityDate);
                    defaultValidDate.setDate(defaultValidDate.getDate() + 7);
                    if (today > defaultValidDate) {
                        this.showToast("error", "7일이 지난 활동은 주유비를 수정할 수 없습니다.");
                        this.doCloseModal(component);
                        return false;
                    }
                }
                for (let i in returnValue.listData) {
                    let objData = returnValue.listData[i];
                    objData.isDetailOpen = false;
                    objData.isWayPointOpen = false;
                    if(objData.Account__c != null){
                        objData.accountName = objData.Account__r.Name;
                    }
                    if(objData.Lead__c != null){
                        objData.leadName = objData.Lead__r.Name;                    
                    }                   
                    if (objData.What != null) {
                        objData.WhatId = objData.WhatId;
                        objData.WhatName = objData.What.Name;
                        objData.WhatType = objData.What.Type.toLowerCase();
                    }
                    objData.WayPointCount = 0;
                    for (let i = 15; i > 0 ; i--){
                        if ( objData['WayPoint'+i+'__c'] ){
                            objData.WayPointCount = i;
                            console.log (' 경유지 개수 :: ' + i);
                            break;
                        }
                    }
                }

                // 시작일자로 Sort
                returnValue.listData.sort((a, b) => {
                    if (a.StartDateTime > b.StartDateTime) {
                        return 1;
                    }
                    if (a.StartDateTime < b.StartDateTime) {
                        return -1;
                    }
                    return 0;
                });

                component.set("v.listData", returnValue.listData);
                component.set("v.listDatalength", returnValue.listData.length);
                component.set("v.objOilInfo", returnValue.objOilInfo);
                component.set("v.showSpinner", false);

                console.log("returnValue.listData :: " + JSON.stringify(returnValue.listData));
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    } else if (errors[0] && errors[0].pageErrors[0].message) {
                        this.showToast("error", errors[0].pageErrors[0].message);
                    } else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
    },

    /**
     * @description : 주유비 설정 데이터 저장&제출
     */
    doSave: function (component, saveType) {
        component.set("v.showSpinner", true);
        var action = component.get("c.doSave");
        let pSaveType = saveType;
        action.setParams({
            recordId: component.get("v.recordId"),
            saveType: pSaveType,
            listData: component.get("v.listData"),
            totalCost: component.get("v.totalCost")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                if (saveType == "Temp") {
                    this.showToast("success", "성공적으로 임시저장되었습니다.");
                } else if (saveType == "Final") {
                    this.showToast("success", "성공적으로 제출되었습니다.");
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    } else if (errors[0] && errors[0].pageErrors[0].message) {
                        this.showToast("error", errors[0].pageErrors[0].message);
                    } else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.isBTNClicked", false);
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },

    /**
     * @description : 주유비 화면 닫기
     */
    doCloseModal: function (component, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },

    /**
     * @description : 세일즈포스 데이트 유형에 맞게 변경
     * @param {*} date 자바스크립트 date 객체
     */
    doParseYYYYMMDD: function (date) {
        var mm = date.getMonth() + 1;
        var dd = date.getDate();

        return [date.getFullYear(), (mm > 9 ? "" : "0") + mm, (dd > 9 ? "" : "0") + dd].join("-");
    },

    /**
     * @description 토스트 메세지 출력 이벤트 발생
     * @param {string} type 메세지 유형 (success, error, info, warning, other)
     * @param {string} message 토스트에 보여질 메세지
     */
    showToast: function (type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key: "info_alt",
            type: type,
            message: message
        });
        evt.fire();
    },

});