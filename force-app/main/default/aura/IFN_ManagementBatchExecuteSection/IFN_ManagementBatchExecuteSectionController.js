({
    fn_doInit : function(cmp, evt, helper)
    {
        //console.log("RealExampleSection fn_doInit");
        try
        {
            let param = {};
            param = cmp.get("v.Param");
            //console.log(JSON.stringify(param));
            cmp.set("v.label"  , param.label);
            cmp.set("v.batchClass" , param.batchClass);
            cmp.set("v.batchORqueueable" , param.batchORqueueable);
            cmp.set("v.executeCode" , param.executeCode);

        }
        catch(e)
        {
            console.log(e);
        }

    },

    fn_execute : function(cmp, evt, helper)
    {
        //console.log('### fn_execute ');
        cmp.set('v.isShowSpinner' , true);

        const batchClass = evt.currentTarget.dataset.batchclass;
        const batchOrqueueable  = evt.currentTarget.dataset.batchorqueueable;

        //console.log('### fn_execute :: batchClass = ', batchClass);
        //console.log('### fn_execute :: batchOrqueueable = ', batchOrqueueable);

        helper.fn_promise(cmp, helper, 'execute', 
        {
            'param' : {
                'batchClass'         : batchClass
                , 'batchOrqueueable' : batchOrqueueable
            }
        })
        .then($A.getCallback(function(result){
            const res = result.r;
            const c   = result.c;
            const h   = result.h;

            if(res)
            {   
                //console.log('### fn_execute :: res = ' , res);
                helper.fn_showToast('success' , 'Success' , '실행 성공 ( JobId : ' + res + ' )');
            }
            cmp.set('v.isShowSpinner' , false);
        }));

    },

    
    fn_executeCode : function(cmp, evt, helper)
    {
        //console.log('### fn_execute ');
        cmp.set('v.isShowSpinner' , true);

        const executeCode = cmp.get('v.executeCode');

        //console.log('### fn_execute :: batchClass = ', batchClass);
        //console.log('### fn_execute :: batchOrqueueable = ', batchOrqueueable);

        helper.fn_promise(cmp, helper, 'doExecuteAnonymous', 
        {
            'code' : executeCode
        })
        .then($A.getCallback(function(result){
            const res = result.r;
            const c   = result.c;
            const h   = result.h;

            if(res)
            {   
                cmp.set('v.executeResult' , res);
            }
            cmp.set('v.isShowSpinner' , false);
        }));

    },
})