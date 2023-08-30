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
            var param3 = [];
            var param4 = [];
            var param5 = [];
            var param6 = [];
            var param7 = [];
            var param8 = [];
            var param9 = [];
            var param10 = [];

            for(var i = 0; i < param.item.length; i++)
            {                   
                if(param.item[i].divLabel == 'ABS-null')
                {   
                    param1.push(param.item[i]);
                }
                else if(param.item[i].divLabel == '확산-Account')
                {
                    param2.push(param.item[i]);
                }
                else if(param.item[i].divLabel == '확산-Order&Fulfillment')                                                       
                {
                    param3.push(param.item[i]);
                }
                else if(param.item[i].divLabel == '확산-Requirement')
                {
                    param4.push(param.item[i]);
                }
                else if(param.item[i].divLabel == '확산-C&C')
                {
                    param5.push(param.item[i]);
                }
                else if(param.item[i].divLabel == '확산-Contents')
                {
                    param6.push(param.item[i]);
                }
                else if(param.item[i].divLabel == '확산-Dashboard')
                {
                    param7.push(param.item[i]);
                }
                else if(param.item[i].divLabel == 'RBU-null')
                {
                    param8.push(param.item[i]);
                }
                else if(param.item[i].divLabel == 'Pipeline-null')
                {
                    param9.push(param.item[i]);
                }
                else if(param.item[i].divLabel == 'EM-null')
                {
                    param10.push(param.item[i]);
                }
            }

            cmp.set("v.executeSectionParams1", param1);
            cmp.set("v.executeSectionParams2", param2);
            cmp.set("v.executeSectionParams3", param3);
            cmp.set("v.executeSectionParams4", param4);
            cmp.set("v.executeSectionParams5", param5);
            cmp.set("v.executeSectionParams6", param6);
            cmp.set("v.executeSectionParams7", param7);
            cmp.set("v.executeSectionParams8", param8);
            cmp.set("v.executeSectionParams9", param9);
            cmp.set("v.executeSectionParams10", param10);

        }
        catch(e)
        {
            console.log(e);
        }

    },
})