({
    fnInit : function(component, event, helper) {
  
    },
  
    fnSave : function(component, event, helper) {
      helper.showToast("info", "해당 공고를 등록중 입니다.");
      component.set("v.showSpinner", true);
      helper.doSave(component, event);
    },
  
    fnClose : function (component, event, helper) {
      helper.doClose(component);
    },
  
    fnSearch : function (component, event, helper) {
      console.log('fnsearch start!!!');
      // var sourceSiteChk = component.get("v.sourceSiteChk");
      var workDivision = component.get("v.workDivision");
      let inputStr = component.get("v.bidNtceNo");
      //받아온 문자열중 연속된 3자리의 알파벳이 있는지 검사하는 정규식
      var regex = /[A-z]{3}[0-9]{4}/;

      console.log('============> workDivision : '+workDivision);
      console.log('============> inputStr : '+inputStr);
      
      if(workDivision == '' || workDivision == null || workDivision == 'none'){
        helper.showToast("error", "업무구분을 선택하세요");
      }else if(inputStr == '' || inputStr == null){
        helper.showToast("error", "공고번호를 입력하세요");
      }else{
        helper.showToast("info", "해당 공고번호 조회중 입니다.");
        component.set("v.showSpinner", true);
    
        helper.doSearch(component, event);
      }
    },

    fnChange : function (component, event, helper) {
      helper.doChange(component, event);
    },
  })