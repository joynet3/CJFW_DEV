({

    fn_doInit : function(cmp, evt, helper)
    {
        //console.log("RealSystemSection fn_doInit");
        try
        {
            let param = {};
            param = cmp.get("v.Param");

            console.log('system section param' ,JSON.stringify(param));
            cmp.set("v.name"  , param.name);
            cmp.set("v.label" , param.label);
            console.log('length : ' + param.example.length);

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
            var param11 = [];

            for(var i = 0; i < param.example.length; i++)
            {
                console.log('divLabel : ' + param.example[i].divLabel);
                if(param.example[i].divLabel == 'ABS-null')
                {
                    param1.push(param.example[i]);
                }
                else if(param.example[i].divLabel == '확산-Account')
                {
                    param2.push(param.example[i]);
                }
                else if(param.example[i].divLabel == '확산-Order&Fulfillment')
                {
                    param3.push(param.example[i]);
                }
                else if(param.example[i].divLabel == '확산-Requirement')
                {
                    param4.push(param.example[i]);
                }
                else if(param.example[i].divLabel == '확산-C&C')
                {
                    param5.push(param.example[i]);
                }
                else if(param.example[i].divLabel == '확산-Contents')
                {
                    param6.push(param.example[i]);
                }
                else if(param.example[i].divLabel == '확산-Dashboard')
                {
                    param7.push(param.example[i]);
                }
                else if(param.example[i].divLabel == 'RBU-null')
                {
                    param8.push(param.example[i]);
                }
                else if(param.example[i].divLabel == 'Pipeline-null')
                {
                    param9.push(param.example[i]);
                }
                else if(param.example[i].divLabel == 'EM-null')
                {
                    param10.push(param.example[i]);
                }
                // 2022.10.13 GSI용 섹션 추가 (Suan, lee)
                else if(param.example[i].divLabel == 'GSI-null')
                {
                    param11.push(param.example[i]);
                }
            }

            cmp.set("v.exampleSectionParams1", param1);
            cmp.set("v.exampleSectionParams2", param2);
            cmp.set("v.exampleSectionParams3", param3);
            cmp.set("v.exampleSectionParams4", param4);
            cmp.set("v.exampleSectionParams5", param5);
            cmp.set("v.exampleSectionParams6", param6);
            cmp.set("v.exampleSectionParams7", param7);
            cmp.set("v.exampleSectionParams8", param8);
            cmp.set("v.exampleSectionParams9", param9);
            cmp.set("v.exampleSectionParams10", param10);
            cmp.set("v.exampleSectionParams11", param11);

            console.log('v.exampleSectionParams1 : ' + cmp.get('v.exampleSectionParams1'));
            console.log('v.exampleSectionParams2 : ' + cmp.get('v.exampleSectionParams2'));
            console.log('v.exampleSectionParams3 : ' + cmp.get('v.exampleSectionParams3'));
            console.log('v.exampleSectionParams4 : ' + cmp.get('v.exampleSectionParams4'));
            console.log('v.exampleSectionParams5 : ' + cmp.get('v.exampleSectionParams5'));
            console.log('v.exampleSectionParams6 : ' + cmp.get('v.exampleSectionParams6'));
            console.log('v.exampleSectionParams7 : ' + cmp.get('v.exampleSectionParams7'));
            console.log('v.exampleSectionParams8 : ' + cmp.get('v.exampleSectionParams8'));
            console.log('v.exampleSectionParams9 : ' + cmp.get('v.exampleSectionParams9'));
            console.log('v.exampleSectionParams11 : ' + cmp.get('v.exampleSectionParams11'));
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