({
    fn_doInit : function(cmp, evt, helper) {
        //console.log('### fn_doInit');
        helper.fn_promise(cmp, helper, 'getData', 
                          {
                          })
        .then($A.getCallback(function(result){
            const res = result.r;
            const c   = result.c;
            const h   = result.h;
            
            if(res)
            {   
                //console.log('res : ', res);
                cmp.set('v.interfaceData' ,res.interfaceData);
                cmp.set('v.batchData' ,res.batchData);
                cmp.set('v.logDeleteSettings' , res.logDeleteSettings);
                //추가
                cmp.set('v.programDeleteSettings' , res.programDeleteSettings);
            }
            let obj = {};
            obj = cmp.get('v.batchData');

            for(var i = 0; i < obj.length; i++)
            {
                console.log('obj : ' + obj[i].name);
            }
        }));
        
    },
    
    fn_saveLogDeleteTerm : function(cmp, evt, helper)
    {
        console.log('### fn_saveLogDeleteTerm');
        const logDeleteSettings = cmp.get("v.logDeleteSettings");
        
        if(logDeleteSettings.Term__c == '' || logDeleteSettings.Term__c == undefined) {
            helper.fn_showToast('Error', 'Error', '기간을 입력하여 주시기 바랍니다.');
            return false;
        }
        
        helper.fn_promise(cmp, helper, 'saveLogDeleteTerm', 
                          {
                              'ifLogDeleteSettings' : logDeleteSettings
                          })
        .then($A.getCallback(function(result){
            const res = result.r;
            const c   = result.c;
            const h   = result.h;
            helper.fn_showToast('success', 'Success', '저장되었습니다.');
        }));
    },



    // 2022-01-24 3개월 전 Log delete 설정
    executeBatch : function(cmp, evt, helper)
    {
        console.log('### executeBatch');
        const logDelete = cmp.find("logDelete").get("v.value");

        helper.fn_promise(cmp, helper, 'executeBatchJob', 
        {
            'logDelete' : logDelete
        })
        .then($A.getCallback(function(result){
        const res = result.r;
        const c   = result.c;
        const h   = result.h;
        console.log('result==>',res);
        if(logDelete == ''){
            helper.fn_showToast('Error', 'Error', 'Class 명을 입력해주세요.');
        }else{
            helper.fn_showToast('success', 'Success', '성공적으로 Batch가 돌았습니다.');
        }
        
        }));

        // action.setCallback(this, function(response) {
        //     var state = response.getState();
        //     if (state === "SUCCESS") {
        //         var toastEvent = $A.get("e.force:showToast");
        //         toastEvent.setParams({
        //             "type": "success",
        //             "title": "성공",
        //             "message": "성공적으로 Batch가 돌았습니다."
        //         });
        //         toastEvent.fire();
        //     }
        //     else if (state === "ERROR") {
        //         var toastEvent = $A.get("e.force:showToast");
        //         toastEvent.setParams({
        //             "type": "error",
        //             "title": "Error",
        //             "message": "Error가 발생했습니다."
        //         });
        //         toastEvent.fire();
        //     }
        // });
        // $A.enqueueAction(action);
    },
    



    fn_jsonSizeCheck : function(cmp, evt, helper)
    {   
        const JSONInput = cmp.get('v.JSONInput');
        const JSONObj   = JSON.parse(JSONInput);
        const keys      = Object.keys(JSONObj);
        
        var result = '';
        if( keys.length > 0 )
        {
            if(keys[0] == '0')
            {
                result = 'JSON Array length : ' + JSONObj.length + '\n\n';
                
                keys.forEach(function(key){
                    result += 'JSON Object index : ' + key +' \n' ; 
                    var innerJSONObj = JSONObj[key];
                    var innerJSONObjKeys = Object.keys(innerJSONObj);
                    
                    if( innerJSONObjKeys.length > 0 )
                    {
                        innerJSONObjKeys.forEach(function(innerkey){
                            if(Array.isArray(innerJSONObj[innerkey]))
                            {
                                result += (innerkey + ' length : ' + innerJSONObj[innerkey].length + '\n');
                            }
                        })
                    }
                    result += '\n';
                })   
            } 
            else
            {
                result += 'JSON Object \n' ; 
                keys.forEach(function(key){
                    if(Array.isArray(JSONObj[key]))
                    {
                        result += (key + ' length : ' + JSONObj[key].length + '\n');
                    }
                })                
            }
            
        }
        else
        {
            result = 'JSON length : ' + JSONObj.length;
        }
        
        cmp.set('v.JSONOutput', result);
    }
})