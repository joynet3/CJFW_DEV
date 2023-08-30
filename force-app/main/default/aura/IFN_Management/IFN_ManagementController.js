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
            }
            let obj = {};
            obj = cmp.get('v.batchData');

            for(var i = 0; i < obj.length; i++)
            {
                console.log('obj : ' + obj[i].name);
            }
        }));
        
    }

})