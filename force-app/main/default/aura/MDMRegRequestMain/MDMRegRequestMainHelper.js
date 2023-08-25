({
    doCreateComponent : function(component, cmpName, param) {
        $A.createComponent(
            cmpName, // 컴포넌트이름
            param, // Attribute param
            function(cCmp, status, errorMessage) {
                if(status === "SUCCESS") {
                    console.log("success");
                    // callback action
                    component.set("v.CustomComponent", cCmp); // 새로운 Attribute에 저장
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    // 카테고리 Lv1 세팅
    helperGetCategoryLevel1: function(component, event, helper) {
        var categoryLevel1 = [];
        component.set("v.isLoading", true);
        const action = component.get("c.getCategoryLevel1");
		
        // categoryLevel1.push({ Name: "전체", LargeCode__c: "all"});
        component.set("v.categoryLevel1Selected", null);
        component.set("v.categoryLevel2Selected", null);
        component.set("v.categoryLevel3Selected", null);
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                data.forEach(element => {
                    categoryLevel1.push(element);
                });
				//console.log(JSON.stringify(data)+'1 Values');
                component.set("v.categoryLevel1Options", categoryLevel1);
                component.set("v.isShowMenu", true);
                
            } else if(state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();   
                }
            }
            component.set("v.isLoading", false);
        });

        $A.enqueueAction(action);
    },

    // 카테고리 Lv2 세팅
    helperGetCategoryLevel2: function(component, event, helper, target) {
        this.targetName = target.Name;

        console.log('>>> 카테고리 Lv2 세팅 ' + this.targetName);
        var categoryLevel2 = [];
        var action = component.get("c.getCategoryLevel2");
        component.set("v.isLoading", true);
        component.set("v.categoryLevel3Options", null);
        component.set("v.categoryLevel3Selected", null);
        action.setParams({
            largeCode : target.Name
        });
		//console.log('선택 Larger code' + target.Name);
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                data.forEach(element => {
                    categoryLevel2.push(element);
                });

                if (!(categoryLevel2.length === 0)) {
                    // categoryLevel2.unshift({ Name: "전체", MidCode__c: "all" });
                }

                component.set("v.categoryLevel2Options", categoryLevel2);
            } else if(state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();   
                }
            }
            component.set("v.isLoading", false);
        });


        this.colorRowOnClick(component, event, helper, "v.prevRowLevel1", "row-level-1");
        $A.enqueueAction(action);
    },

    // 카테고리 Lv3 세팅
    helperGetCategoryLevel3: function(component, event, helper, target) {
        var categoryLevel3 = [];
        var action = component.get("c.getCategoryLevel3");
        let currentCatLv1 = component.get('v.categoryLevel1Selected');
        
        //console.log('첫번쨰' + target.Name);
        //console.log('레벨'+JSON.stringify(currentCatLv1));
        action.setParams({
            midCode : target.Name,
            largeCode : currentCatLv1
        });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                data.forEach(element => {
                    element.isChecked = true;
                    categoryLevel3.push(element);
                });
                component.set("v.categoryLevel3Options", categoryLevel3);
                console.log('>>> categoryLevel3Options 뭐가 담겼 ' +  JSON.stringify(categoryLevel3));
                //console.log('================> Click 3 ' + JSON.stringify(component.get('v.categoryLevel3Options')));
                  
            } else if(state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();   
                }
            }
            component.set("v.isLoading", false);
        });

        this.colorRowOnClick(component, event, helper, "v.prevRowLevel2", "row-level-2");
        $A.enqueueAction(action);
    },
    // 다음 버튼 클릭 이벤트
    helperHandleLevel3Clicked: function(component, event, helper) {
       
        let redirectCategory = component.get("v.categoryLevel3Options"); 
        let cat1 = component.get("v.categoryLevel1Options");
        
        console.log('# 다음 > categoryLevel3Options ' + JSON.stringify(redirectCategory));
        console.log('# 다음 > categoryLevel1Options ' + JSON.stringify(cat1));



        //console.log(redirectCategory+'OPTIONS');
		var categoryvalue = [];
        var i;
        for (i = 0 ; i < redirectCategory.length ; i++) {
            if (redirectCategory[i].isChecked) {
                redirectCategory[i].isDisabled = true;
				categoryvalue.push(redirectCategory[i]);
            } 
            //console.log('# 다음 > categoryLevel1Options ' + json.stringify(categoryvalue));
            /*
            else {
                	redirectCategory[i].isChecked=true;
                	categoryvalue.push(redirectCategory[i]);   
            }*/
        }                
		
        component.set("v.categoryLevel3values", categoryvalue);
		//console.log('comp'+JSON.stringify(component.get('v.categoryLevel3values')));
        if(typeof categoryvalue !== 'undefined' && categoryvalue.length > 0){
            // 판매처인경우 MDMRegRequestChild Component Show
            if ('판매처' == this.targetName) {
                component.set('v.isOpenOrgModal2', true);
            }
            // 본점인경우 MDMRegRequestParent Component Show
            else {
                console.log('>>> 본점 인경우, categoryLevel3values의 값 ' + categoryvalue);
                console.log('>>> 본점 인경우, categoryLevel3values의 값 ' + JSON.stringify(categoryvalue))
                component.set('v.isOpenOrgModal', true);
            }
            // Main Component 숨김처리
            component.set("v.isShowMenu", false);
        }
        
    },
    // 카테고리 선택시 색변경 class 추가
    colorRowOnClick: function(component, event, helper, prevRowAttribute, row) {
        const curRow = event.currentTarget;
        var prevRow = null; 
        
        if (!(component.get(prevRowAttribute) == curRow)) {
            if (component.get(prevRowAttribute) === undefined) {
                prevRow = null; 
            } else {
                prevRow = component.get(prevRowAttribute);
            }
    
            if (curRow.className == "selected") {
                curRow.className = curRow.className.substring(8, 19);
                prevRow = null;
            } else {
                curRow.className = "selected";
    
                if (prevRow != null) {
                    prevRow.className = row;
                }
                
                prevRow = curRow;
            }
    
            component.set(prevRowAttribute, prevRow);
        }
    },

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