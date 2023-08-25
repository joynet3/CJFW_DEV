/**
 * @description       : 
 * @author            : (서원) won.seo@daeunextier.com
 * @group             : 
 * @last modified on  : 10-11-2022
 * @last modified by  : (서원) won.seo@playful-impala-5wzu0.com
**/
({
   /**
    * @description : iframe 지도 url 받기
    */
   fnInit : function(component, event, helper) {

      helper.doGetIframeUrl(component);

      helper.doOnChangeAddEventHandler(component, event, helper);

      if (component.get("v.isMobile") === true) {
         // 현재 위치
         window.setTimeout(function(){ helper.doGetCurrentLocation(component, event, helper)}, 300);
      }
   },

   /**
    * @description : Tmap 모달 열기
    */
   fnTmapOpenModel: function(component, event, helper) {
      component.set("v.isOpenTmap", true);
   },

   /**
    * @description : Tmap 모달 닫기
    */
   fnCloseModel: function(component, event, helper) {
      console.log("Cancel::::::::::::::::");
      var iframe = component.find("tmapIframeMap");
      // iframe.getElement().contentWindow.postMessage('cancel', '*');

      var msgObj = new Map([
          ["type", "CANCEL"]
      ]);

      iframe.getElement().contentWindow.postMessage(msgObj, '*');
   },

   /**
    * @description : Tmap 거리계산 정보 저장
    */
   fnTmapSubmitDetails: function(component, event, helper) {
      var iframe = component.find("tmapIframeMap");
      // iframe.getElement().contentWindow.postMessage('save', '*');

      var msgObj = new Map([
          ["type", "SAVE"]
      ]);

      iframe.getElement().contentWindow.postMessage(msgObj, '*');
   },

   /**
    * @description : Tmap 검색 화면 Open 시 Event Handler 추가
    */
   fnOnChangeAddEventHandler: function(component, event, helper) {
      helper.doOnChangeAddEventHandler(component, event, helper);
   },
   
    /**
     * @description 비고입력 화면 닫기
     */
	fnCloseModal : function(component, event, helper) {
		component.set("v.modalStatus", 'Hide');
	},

   /**
     * @description 비고입력 화면 저장
     */
    fnSaveDescription : function(component, event, helper) {
      let iframe = component.find("tmapIframeMap");

      let msgObj = new Map([
          ["type", "DESCRIPTION"],
          ["msgType", component.get("v.modalType")],
          ["msgViaNo", component.get("v.modalViaNo")],
          ["msgDesc", component.get("v.modalDesc")]
      ]);

      console.log('msgObj::::::::::::::' + msgObj);
      iframe.getElement().contentWindow.postMessage(msgObj, '*');

		component.set("v.modalStatus", 'Hide');
	},
   
})