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

            if ( objActivityReport == null) {
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    "scope": "ActivityReport__c"
                });
                homeEvent.fire();
                return false;
            }
    
            let dDayMap = returnValue.dDayMap;
            let exceptionDateMap = returnValue.exceptionDateMap;
            let dueWeekMap = returnValue.dueWeekMap;
            let strStatus = returnValue.strStatus;
            let strMessage = returnValue.strMessage;

            let today = new Date();
            today = new Date(today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
            let strActivityDate = objActivityReport.EventStartDate__c;
            let activityDate = new Date(strActivityDate);
            activityDate.setHours(activityDate.getHours() - 9);
            component.set("v.activityDateMonth", activityDate.getMonth() + 1 );

            component.set("v.activityDate", activityDate.getFullYear().toString().substring(2,4) + '년 ' + (activityDate.getMonth()+1) +'월 ' + activityDate.getDate() + '일 ');

            console.log("strActivityDate :: " + strActivityDate);
            console.log("activityDate :: " + activityDate);

            console.log("오늘 날짜 :: " + today.toLocaleString());
            component.set("v.today", (today.getMonth()+1) +'월 ' + today.getDate() +'일' );
            
            console.log("활동 날짜 :: " + activityDate.toLocaleString());

            if (strStatus == "ERROR") {
                this.showToast(strStatus, strMessage);
                return false;
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

            if ( isExceptionDateExist){
                component.set("v.minDateTime",  minDateTime.getFullYear().toString().substring(2,4) + '년 ' + (minDateTime.getMonth()+1) +'월 ' + minDateTime.getDate() + '일 ');
                component.set("v.StartDateTime",  (StartDateTime.getMonth()+1) +'월 ' + StartDateTime.getDate() + '일 ' + (StartDateTime.getHours() < 13 ? '오전 ' : '오후 ') + (StartDateTime.getHours()%12)+ '시 ' + StartDateTime.getMinutes() + '분');
                component.set("v.EndDateTime",  (EndDateTime.getMonth()+1) +'월 ' + EndDateTime.getDate() + '일 '+ (EndDateTime.getHours() < 13 ? '오전 ' : '오후 ') + (EndDateTime.getHours()%12) + '시 ' + EndDateTime.getMinutes() + '분');
                component.set("v.isExceptionDateExist",  isExceptionDateExist);
            }
            console.log( 'isExceptionDateExist ::: ' + isExceptionDateExist);

            if ( now >= StartDateTime && now <= EndDateTime && activityDate >= minDateTime && activityDate <= today){
                component.set("v.isActiveException", true);
            }

            // 3. 전체 주유비 마감 기한 설정 유효성 체크
            let isdueWeekExist = false;
            let dueWeek = 1;
            let dueWeekValidDate = null;
            let strDueWeekValidDate = '';

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
            } else { 
                strDueWeekValidDate = mapFriday.get(dueWeek); 
                dueWeekValidDate = new Date(strDueWeekValidDate);
            }
            
            let dueWeekYear = dueWeekValidDate.getFullYear().toString().substring(2,4);
            let dueWeekMonth = dueWeekValidDate.getMonth()+1;
            let dueWeekDate = dueWeekValidDate.getDate();

            component.set("v.dueWeekValidDate", dueWeekYear + '년 ' + dueWeekMonth + '월 ' + dueWeekDate + '일');
                


            // 4. 조직별 주유비 신청 가능 기간 설정 유효성 체크
            let isNDayExist = false;
            let NDay = 7;
            let NDayValidDate = new Date(activityDate);

            if (dDayMap.user != undefined) {
                NDayValidDate.setDate(NDayValidDate.getDate() + dDayMap.user.Nday__c);
                NDay = dDayMap.user.Nday__c;
                isNDayExist = true;
            } else if (dDayMap.profile != undefined) {
                NDayValidDate.setDate(NDayValidDate.getDate() + dDayMap.profile.Nday__c);
                NDay = dDayMap.profile.Nday__c;
                isNDayExist = true;
            } else if (dDayMap.default != undefined) {
                NDayValidDate.setDate(NDayValidDate.getDate() + dDayMap.default.Nday__c);
                NDay = dDayMap.default.Nday__c;
                isNDayExist = true;
            }
            component.set("v.NDay", NDay);

            if ( !isNDayExist ){
                NDayValidDate.setDate(NDayValidDate.getDate() + 7);
            }

            component.set("v.NDayValidDate", NDayValidDate.getFullYear().toString().substring(2,4) + '년 ' + (NDayValidDate.getMonth()+1) +'월 ' + NDayValidDate.getDate() + '일 ');

            let totalValidDate = new Date(activityDate);
            if ( dueWeekValidDate != null){ 
                totalValidDate = dueWeekValidDate < NDayValidDate ? new Date(dueWeekValidDate) : new Date(NDayValidDate);
            } else {
                totalValidDate = new Date(NDayValidDate);
            }
            component.set("v.totalValidDate", totalValidDate.getFullYear().toString().substring(2,4) + '년 ' + (totalValidDate.getMonth()+1) +'월 ' + totalValidDate.getDate() + '일 ');    

            if ( today >= activityDate && today <= totalValidDate){
                component.set("v.isActiveDefault", true);
            }

            component.set("v.showSpinner", false);

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

})