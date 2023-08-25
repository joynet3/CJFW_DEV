/**
 * @description       : 
 * @author            : (서원) won.seo@daeunextier.com
 * @group             : 
 * @last modified on  : 09-28-2022
 * @last modified by  : (서원) won.seo@playful-impala-5wzu0.com
**/
({
    
   /**
    * @description : iframe 지도 url 받기
    */
    doGetIframeUrl : function(component) {
        var action = component.get("c.getPrefix");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();

                console.log("isMobile::::::::::::" + component.get("v.isMobile"));
                var tmapUrl;
                if (component.get("v.isMobile") === false) {
                    tmapUrl = returnValue + "/apex/Tmap_DESKTOP";
                    console.log('tmapUrl::::::::::::::' + tmapUrl);
                } else {
                    tmapUrl = returnValue + "/apex/Tmap_MOBILE";
                    console.log('tmapUrl::::::::::::::' + tmapUrl);
                }
            }
            component.set("v.tmapIframeUrl", tmapUrl);
        });
        $A.enqueueAction(action);

    },

   /**
    * @description : Tmap 검색 화면 Open 시 Event Handler 추가 및 Iframe의 정보 조회
    */
    doOnChangeAddEventHandler: function(component, event, helper) {
        let isModalCmp = component.get("v.isOpenTmap");
  
        console.log("Changed isModal:::::::::::::::::" + isModalCmp);

        if (isModalCmp === true) {
            console.log("Open:::::::::::::::::");
            window.addEventListener('message', receiveMsgFromChild);
         } 
  
        // iframe에서 받은 정보 parent에 출력
       function receiveMsgFromChild( e ) {

            let type = e.data.get('type');
            console.log("Received msg from Child:::::::::::::::::", type);
  
            var spinner = component.find("loadingSpinner");
            if (type === 'DESCRIPTION'){
                component.set("v.modalStatus", 'Description');
                let msgType = e.data.get('msgType');
                let msgViaNo = e.data.get('msgViaNo');
                let msgDesc = e.data.get('msgDesc');
                console.log("msgDesc :: " + msgDesc);
                component.set("v.modalType", msgType);
                component.set("v.modalViaNo", msgViaNo);
                component.set("v.modalDesc", msgDesc);

                if ( msgType == 'Start'){
                    component.set("v.modalTitle", '[출발지] 비고');
                    component.set("v.msgDesc", msgDesc);
                } else if (msgType == 'End'){
                    component.set("v.modalTitle", '[도착지] 비고');
                    component.set("v.msgDesc", msgDesc);
                } else if (msgType == 'Via'){
                    component.set("v.modalTitle", '[경유지 ' + msgViaNo + '] 비고');
                    component.set("v.msgDesc", msgDesc);
                }
                console.log("component.set(v.modalTitle) :: " + component.get("v.modalTitle"));
                console.log("component.set(v.modalType) :: " + component.get("v.modalType"));
                console.log("component.set(v.modalViaNo) :: " + component.get("v.modalViaNo"));
                console.log("component.set(v.modalDesc) :: " + component.get("v.modalDesc"));
            } else if (type === 'IN PROCESS') {
                $A.util.removeClass(spinner, "slds-hide");
            } else if(type === 'SUCCESS') {
                console.log("Received msg SUCCESS");
                // TMAP 계산 데이터 
                component.set("v.tmapOriginDistance", e.data.get('msgDist'));
                $A.util.addClass(spinner, "slds-hide");
            } else if (type === 'SAVE') {
                console.log("Received msg SAVE");
                component.set("v.tmapStartAddr", e.data.get('msgStart'));
                component.set("v.tmapEndAddr", e.data.get('msgEnd'));
                component.set("v.tmapDistance", e.data.get('msgDist'));

                component.set("v.tmapStartDesc", e.data.get('msgStartDesc'));
                component.set("v.tmapEndDesc", e.data.get('msgEndDesc'));

                console.log ("---------------- 결과 ----------------");
                console.log (" msgStartDesc ::: " + e.data.get('msgStartDesc'));
                console.log (" msgEndDesc ::: " + e.data.get('msgEndDesc'));
                console.log (" msgViaPointsDesc ::: " + e.data.get('msgViaPointsDesc'));
                console.log ("--------------------------------------");

                if (e.data.get('msgViaPoints').length != 0) {
                    component.set("v.tmapViaPoints", e.data.get('msgViaPoints'));
                    console.log('There are via points==================' + e.data.get('msgViaPoints'));
                }

                if (e.data.get('msgViaPointsDesc').length != 0) {
                    component.set("v.tmapViaPointsDesc", e.data.get('msgViaPointsDesc'));
                    console.log('There are via points Desc==================' + e.data.get('msgViaPointsDesc'));
                }

                component.set("v.isComplete", true);
                component.set("v.isOpenTmap", false);

                window.removeEventListener('message', receiveMsgFromChild, false);
                console.log("Save and Close:::::::::::::::::");
            } else if (type === 'GET CURRENT LOCATION') {
                console.log("GET CURRENT LOCATION:::::::::::::::::");
                helper.doGetCurrentLocation(component, event, helper);
            } else if (type === 'CANCEL') {
                component.set("v.isOpenTmap", false);
                window.removeEventListener('message', receiveMsgFromChild, false);
                console.log("Cancel and Close:::::::::::::::::");
            } 
        };
     },

   /**
    * @description : 현재 위치 조회
    */
    doGetCurrentLocation: function(component, event, helper) {
        var pos = {};
        function success(position) {
            pos = position.coords;
            var iframe = component.find("tmapIframeMap");

            var msgObj = new Map([
                ["type", "POSITION"],
                ["msgLat", pos.latitude],
                ["msgLng", pos.longitude]
            ]);

            console.log('msgObj::::::::::::::' + msgObj);
            iframe.getElement().contentWindow.postMessage(msgObj, '*');
        }
  
        function error(msg) {
            alert(msg);
            console.log(msg);
        }
  
        if (window.navigator.geolocation) {
            window.navigator.geolocation.getCurrentPosition(success, error);
        } else {
            error('지원 되지 않음');
        }
    }

})