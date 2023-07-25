/**
 * @description       : 
 * @author            : (서원) won.seo@daeunextier.com
 * @group             : 
 * @last modified on  : 09-15-2022
 * @last modified by  : (서원) won.seo@playful-impala-5wzu0.com
**/
({
    doGetIframeUrl : function(component) {
        var action = component.get("c.getPrefix");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var url = returnValue + "/apex/Sample_Map";
                // var tmapUrlSample = returnValue + "/apex/Sample_Tmap";
                var tmapUrlDesktop = returnValue + "/apex/Tmap_DESKTOP";
                // var tmapUrlMobile = returnValue + "/apex/Tmap_MOBILE";

                // console.log('tmapUrlDesktop::::::::::::::' + tmapUrlDesktop);
                // console.log('tmapUrlMobile::::::::::::::' + tmapUrlMobile);

                // New Sample Tmap
                var tmapUrlDesktop2 = returnValue + "/apex/Sample_Tmap2";
            }
            component.set("v.iframeUrl", url);
            component.set("v.tmapIframeUrl", tmapUrlDesktop);
            component.set("v.tmapIframeUrl2", tmapUrlDesktop2);
        });
        $A.enqueueAction(action);
    },

    doGetDistance: function(component, event, helper) {
        var action = component.get("c.getDistanceApex");
        
        var mapParams = {
            "startCoord" : component.get("v.startCoord"),
            "goalCoord" : component.get("v.goalCoord")
        };
        
        action.setParams({
            mapParam : mapParams
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                var distance = returnValue.distance / 1000;
            }
            component.set("v.distance", distance.toFixed(2));
            component.set("v.lineDistance", component.get('v.childMsg'));
        });
        $A.enqueueAction(action);
    },

    doGetKeywordAddress: function(component, event, helper) {
        var sample = component.find("keyword").get("v.value");

        console.log("keyword:::::::::" + sample);

        var action = component.get("c.searchPlace");
        
        action.setParams({
            keyword: component.find("keyword").get("v.value")
        })

        action.setCallback(this, function(response){
            var state = response.getState();

            console.log("state:::::::::" + state);

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();

                for (let i=0; i<returnValue.length; i++) {

                    returnValue[i].title = returnValue[i].title.replace('<b>', '');
                    returnValue[i].title = returnValue[i].title.replace('</b>', '');

                }

                component.set("v.resultList", returnValue);
                if (returnValue.length > 0) {
                    component.set("v.isList", true);
                }
                // console.log(component.get("v.resultList"));
            }
        });
        $A.enqueueAction(action);

    },

    // -----------------------TMAP--------------------------------

})