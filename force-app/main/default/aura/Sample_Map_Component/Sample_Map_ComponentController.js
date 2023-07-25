/**
 * @description       : 
 * @author            : (서원) won.seo@daeunextier.com
 * @group             : 
 * @last modified on  : 09-15-2022
 * @last modified by  : (서원) won.seo@playful-impala-5wzu0.com
**/
({
   // iframe 지도 url 받기
   fnInit : function(component, event, helper) {
      helper.doGetIframeUrl(component);

      window.addEventListener('message', receiveMsgFromChild );

      // iframe에서 받은 정보 parent에 출력
      function receiveMsgFromChild( e ) {
         // console.log('msg::::::::::::' + e.data);
         // console.log('type::::::::::::' + e.data.get('type'));
         // console.log('msgStart::::::::::::' + e.data.get('msgStart'));
         // console.log('msgEnd::::::::::::' + e.data.get('msgEnd'));
         // console.log('msgDist::::::::::::' + e.data.get('msgDist'));

         var spinner = component.find("loadingSpinner");

         if (e.data.get('type') === 'IN PROCESS') {
            console.log('type::::::::::::' + e.data.get('type'));

            $A.util.removeClass(spinner, "slds-hide");
         } else if(e.data.get('type') === 'SUCCESS') {
            console.log('type::::::::::::' + e.data.get('type'));
            
            $A.util.addClass(spinner, "slds-hide");
         } else {
            console.log('type::::::::::::' + e.data.get('type'));
            console.log('msgStart::::::::::::' + e.data.get('msgStart'));
            console.log('msgEnd::::::::::::' + e.data.get('msgEnd'));
            console.log('msgDist::::::::::::' + e.data.get('msgDist'));

            component.set("v.tmapStartAddr", e.data.get('msgStart'));
            component.set("v.tmapEndAddr", e.data.get('msgEnd'));
            component.set("v.tmapDistance", e.data.get('msgDist'));

            component.set("v.isTmapModalOpen", false);

            // tmap2 닫기
            if (component.get("v.isTmap2") === true) {
               component.set("v.isTmap2", false);
            }
         }

      }

   },

   // Tmap 모달 열기
   fnTmapOpenModel: function(component, event, helper) {
      
      component.set("v.isTmapModalOpen", true);
   },

   // Tmap 모달2 열기
   fnTmapOpenModel2: function(component, event, helper) {
      
      component.set("v.isTmap2", true);
      component.set("v.isTmapModalOpen", true);
   },

   // 지도 열기 (출발지/도착지)
   fnOpenModel: function(component, event, helper) {
      // Set isModalOpen attribute to true

      window.addEventListener( 'message', receiveMsgFromChild );

      // 자식으로부터 메시지 수신
      function receiveMsgFromChild( e ) {
         component.set("v.addrInfo", e.data);
      }

      if (event.getSource().getLocalId() === "startBtn") {
         component.set("v.btnClick", "start");
      }else {
         component.set("v.btnClick", "goal");
      }

      component.set("v.isModalOpen", true);
   },

   // 모달 닫기
   fnCloseModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
      component.set("v.isList", false);
      component.set("v.resultList", "");

      //Tmap 닫기
      component.set("v.isTmapModalOpen", false);
      // component.set("v.isTmapList", false);
      // component.set("v.tmapResultList", "");

      // tmap2 닫기
      if (component.get("v.isTmap2") === true) {
         component.set("v.isTmap2", false);
      }
   },

   // 주소 정보 가져오기
   fnSubmitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing

      let dataList = component.get("v.addrInfo");

      if(component.get("v.btnClick") === "start") {
         component.set("v.start", dataList[0]);
         component.set("v.startCoord", dataList[1].x + ',' + dataList[1].y);
      }else {
         component.set("v.goal", dataList[0]);
         component.set("v.goalCoord", dataList[1].x + ',' + dataList[1].y);
      }

      var iframe = component.find("iframeMap");
      // console.log('iframe::: ' + iframe);
      // console.log('start::: ' + 'start:' + component.get("v.startCoord"))
      // console.log('goal::: ' + 'goal:' + component.get("v.goalCoord"))
      iframe.getElement().contentWindow.postMessage(component.get("v.startCoord") + '/' + component.get("v.goalCoord"), '*');

      window.addEventListener( 'message', receiveMsgFromChild );

      // 자식으로부터 메시지 수신
      function receiveMsgFromChild( e ) {
         component.set("v.childMsg", e.data);
         // console.log('lineDistanceParent::: ' + component.get('v.childMsg'));
      }

      window.setTimeout(
         $A.getCallback(function(){
            component.set("v.isModalOpen", false);
            component.set("v.isList", false);
            component.set("v.resultList", "");
         }), 500
      );

   },

   // 거리 측정  
   fnGetDistance: function(component, event, helper) {
      
      helper.doGetDistance(component, event, helper);      

   },

   // 키워드로 검색(엔터 버튼)
   fnFormPress: function(component, event, helper) {
      if(event.keyCode === 13) {
         
         helper.doGetKeywordAddress(component, event, helper);
      }
   },

   // 키워드로 검색(버튼 클릭)
   fnButtonPress: function(component, event, helper) {

      helper.doGetKeywordAddress(component, event, helper);

   },

   fnLocalSelect: function(component, event, helper) {
      var target = event.currentTarget;
      
      var rowIndex = target.dataset.record;

      var mapxy = component.get("v.resultList")[rowIndex].mapx + ',' + component.get("v.resultList")[rowIndex].mapy;
      component.set("v.coord", mapxy);
      var iframe = component.find("iframeMap");
      
      iframe.getElement().contentWindow.postMessage(component.get("v.coord"), '*');
   },

   // tmap 거리계산 정보 저장
   fnTmapSubmitDetails: function(component, event, helper) {
      var iframe = component.find("tmapIframeMap");

      iframe.getElement().contentWindow.postMessage('save', '*');

   }

})