({
    fn_doInit : function(cmp, evt, helper)
    {
        //console.log("RealSystemSection fn_doInit");
        try
        {
            let param = {};
            param = cmp.get("v.Param");
            //console.log('param::' , JSON.stringify(param));

            var param1 = [];
            var param2 = [];


            for(var i = 0; i < param.item.length; i++)
            {                   
                if(param.example[i].divLabel == '고도화-LIF1002')
                {
                    param1.push(param.example[i]);
                }
                else if(param.example[i].divLabel == '고도화-EIF1001')
                {
                    param2.push(param.example[i]);
                }
               
            }

            cmp.set("v.executeSectionParams1", param1);
            cmp.set("v.executeSectionParams2", param2);


        }
        catch(e)
        {
            console.log(e);
        }

    },
})