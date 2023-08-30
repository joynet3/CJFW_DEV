({
    fn_doInit : function(cmp, evt, helper)
    {
        //console.log("RealExampleSection fn_doInit");
        try
        {
            let param = {};
            param = cmp.get("v.Param");
            // console.log("===============================================");
            // console.log(JSON.stringify(param));
            cmp.set("v.name"  , param.name);
            cmp.set("v.label" , param.label);
            cmp.set("v.example" , param.example);
            cmp.set("v.system" , param.targetSystem);
            cmp.set("v.division", param.division);
            cmp.set("v.project", param.project);
        }
        catch(e)
        {
            console.log(e);
        }

    },

    fn_getResponse : function(cmp, evt, helper)
    {
        console.log('### fn_getResponse ');
        evt.preventDefault();
        cmp.set('v.isShowSpinner' , true);

        const targetSystem = evt.currentTarget.dataset.targetsystem;
        const interfaceId  = evt.currentTarget.dataset.interfaceid;
        const division = evt.currentTarget.dataset.division;
        const project = cmp.get('v.project');
        const params = cmp.get('v.params');


        console.log('### targetSystem ' + targetSystem);
        console.log('### interfaceId ' + interfaceId);
        console.log('### division ' + division);
        console.log('### project ' + project);
        console.log('### params ' + params);

        // console.log('### fn_getResponse :: project = ', project);
        //console.log('### fn_getResponse :: interfaceId = ', interfaceId);
        //console.log('### fn_getResponse :: params  = ', params);

        helper.fn_promise(cmp, helper, 'getResponse', 
        {
            'param' : {
                'targetSystem'  : targetSystem
                , 'interfaceId' : interfaceId
                , 'division'    : division 
                , 'params'      : params
                , 'project'      : project
            }
        })
        .then($A.getCallback(function(result){
            const res = result.r;
            const c   = result.c;
            const h   = result.h;

            if(res)
            {   
                //console.log('### fn_getResponse :: res = ' , res);
                cmp.set('v.result' , JSON.stringify(res));

                if(res.result != 'S')
                {
                    helper.fn_showToast(res.result, res.result, res.message);
                }
            }
            cmp.set('v.isShowSpinner' , false);
        }));

    }
})