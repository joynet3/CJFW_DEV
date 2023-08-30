({

    fn_doInit : function(cmp, evt, helper)
    {
        //console.log("RealSystemSection fn_doInit");
        try
        {
            let param = {};
            param = cmp.get("v.Param");

            cmp.set("v.name"  , param.name);
            cmp.set("v.label" , param.label);
            console.log('length : ' + param.example.length);

            var param1 = [];
            var param2 = [];
   

            for(var i = 0; i < param.example.length; i++)
            {
                console.log('divLabel : ' + param.example[i].divLabel);
                if(param.example[i].divLabel == '고도화-LIF1002')
                {
                    param1.push(param.example[i]);
                }
                else if(param.example[i].divLabel == '고도화-EIF1001')
                {
                    param2.push(param.example[i]);
                }
            }

            cmp.set("v.exampleSectionParams1", param1);
            cmp.set("v.exampleSectionParams2", param2);

            console.log('v.exampleSectionParams1 : ' + cmp.get('v.exampleSectionParams1'));
            console.log('v.exampleSectionParams2 : ' + cmp.get('v.exampleSectionParams2'));
        }
        catch(e)
        {
            console.log(e);
        }

    },


    fn_sectionToggle : function(cmp, evt, helper)
    {
        
    },
})