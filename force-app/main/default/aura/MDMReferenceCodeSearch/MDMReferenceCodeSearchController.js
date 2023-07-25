({
	// Component Init
	fnInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},

	// 키워드 입력 이벤트
	fnHandleKeyup : function(component, event, helper) {
        // event.preventDefault();
        // event.stopPropagation();
        
		var inputCmp = component.find("customSearch");
        var value = inputCmp.get("v.value");
		// 엔터키일 경우 검색 호출
        if(event.which == 13){
			helper.doSearch(component, event, helper);
		}
	},
	// 룩업필드 클릭 이벤트 
	handlerClick : function(component, event, helper) {
		component.set("v.isShowPopup", true);

		var isShowPopup = component.get("v.isShowPopup");

		var label = component.get("v.label");
		
		if(isShowPopup) {
			setTimeout(function(){
				var cmp = component.find("customSearch");
				if(cmp) {					
					console.log('=============> focus');
					cmp.focus();
					/*
					var cmpE = cmp.getElement();

					alert('focus cmpE : '+typeof cmpE);
					*/
				}else {
					console.log('=============> not focus');
				}
				//component.find("customSearch").getElement().focus();
			}, 200);
		}
	},
	// 조회 버튼 이벤트
	fnSearch : function(component, event, helper) {
		helper.doSearch(component, event, helper);
	},
	// 취소 버튼 이벤트
	handlerInputCancel : function(component, event, helper) {
		// 초기화
		component.set("v.value", "");
		component.set("v.inputText", "");
		component.set("v.inputTextLabel", "");
		component.set("v.listSearchResult", []);

		component.set('v.totalCount', 0);
		component.set("v.curCount", 0);

		/*
		var ztermEvent = component.getEvent("ztermEvent");        
        ztermEvent.fire();
		*/
	},
	// 조회리스트 선택 이벤트
	handlerClickList : function(component, event, helper) {
		var target =  event.currentTarget;
        var index = target.dataset.index;

		var listSearchResult = component.get('v.listSearchResult');

		/*
        console.log('===============> popup click target index : '+index);
        console.log('===============> popup click target Object : '+JSON.stringify(listSearchResult[index]));
		console.log('===============> listSearchResult[index].Id : '+listSearchResult[index].Id);
		*/

		component.set('v.value', listSearchResult[index].CODE__c);

        

		component.set('v.id', listSearchResult[index].Id);
		component.set('v.inputText', listSearchResult[index].Name);
		component.set('v.inputTextLabel', listSearchResult[index].Name);

		/*
        console.log('==========> component.get v.id '+component.get('v.id'));
        console.log('==========> component.get v.value '+component.get('v.value'));
		*/
		
		// 세팅 후 검색은 Reset
		component.set('v.listSearchResult', []);
		component.set('v.curCount', 0);
		component.set('v.totalCount', 0);		
		component.set("v.isShowPopup", false);
		
		/* Event 사용하지 않고 자체 Change Event Actino으로 변경		
		var cmpEvent = component.getEvent("cmpEvent");
        var ztermEvent = component.getEvent("ztermEvent");
        
        ztermEvent.fire();
		cmpEvent.fire();
		*/
	},
	// 더보기 이벤트
	fnListMore : function(component, event, helper) {
		var currCnt = component.get("v.curCount");
		var maxCnt = component.get("v.totalCount");

		var viewCount = component.get("v.viewCount");
		
		var addCnt = currCnt + viewCount;
		if(maxCnt > addCnt){
			component.set("v.curCount", addCnt);
		}else{
			component.set("v.curCount", maxCnt);
		}
	},
	// 닫기 버튼 이벤트
	fnCancel : function(component, event, helper) {
//        $A.get("e.force:closeQuickAction").fire();
        component.set("v.isShowPopup", false);

		component.set('v.curCount', 0);
		component.set('v.totalCount', 0);
		component.set("v.listSearchResult", []);
    },
	// value 변경 이벤트
	onChangeValue : function(component, event, helper) {
		console.log("value has changed");
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));

		var oldValue = event.getParam("oldValue");
		var value = event.getParam("value");

		if(oldValue != value) {
			component.set('v.inputText', value);
			helper.doInit(component, event, helper);
		}
	},
})