public class IF_API_ProductSuspend_test {
    
    public class Input {
        public String system_type_cd;
        public String opcode;
        public String lgs_ctr_id;
        public String CUST_ID;
        public String REF_DATE;
        public List<String> GD_NO;
    }

    public static void callOut() {
        Input objInput = new Input();
        Map<String, Object> mapInputSub = new Map<String, Object>();

        try {
            List<String> listProductCode = new List<String>();
            listProductCode.add('270231');
            listProductCode.add('342212');
            listProductCode.add('342214');
            listProductCode.add('287123');
            listProductCode.add('144803');
            listProductCode.add('357539');
            listProductCode.add('357540');
            listProductCode.add('357805');
            listProductCode.add('357447');
            listProductCode.add('194758');
            listProductCode.add('344320');
            listProductCode.add('194755');
            listProductCode.add('362576');
            listProductCode.add('372254');
            listProductCode.add('243406');
            listProductCode.add('351858');
            listProductCode.add('351839');
            listProductCode.add('351853');
            listProductCode.add('351856');
            listProductCode.add('362577');
            listProductCode.add('274625');
            listProductCode.add('173159');
            listProductCode.add('369270');
            listProductCode.add('235235');
            listProductCode.add('160075');
            listProductCode.add('368118');
            listProductCode.add('351850');
            listProductCode.add('372262');
            listProductCode.add('344017');
            listProductCode.add('136931');
            listProductCode.add('362088');
            listProductCode.add('362086');
            listProductCode.add('354796');
            listProductCode.add('131687');
            listProductCode.add('371771');
            listProductCode.add('354511');
            listProductCode.add('354895');
            listProductCode.add('354901');
            listProductCode.add('252020');
            listProductCode.add('354794');
            listProductCode.add('130283');
            listProductCode.add('354882');
            listProductCode.add('354902');
            listProductCode.add('342474');
            listProductCode.add('147365');
            listProductCode.add('198734');
            listProductCode.add('180855');
            listProductCode.add('354066');
            listProductCode.add('361700');
            listProductCode.add('237893');
            listProductCode.add('172017');
            listProductCode.add('124041');
            listProductCode.add('361714');
            listProductCode.add('168359');
            listProductCode.add('339168');
            listProductCode.add('293849');
            listProductCode.add('138742');
            listProductCode.add('143825');
            listProductCode.add('121452');
            listProductCode.add('303028');
            listProductCode.add('342011');
            listProductCode.add('329520');
            listProductCode.add('334287');
            listProductCode.add('198288');
            listProductCode.add('145749');
            listProductCode.add('331512');
            listProductCode.add('356254');
            listProductCode.add('133910');
            listProductCode.add('357624');
            listProductCode.add('354318');
            listProductCode.add('354572');
            listProductCode.add('105582');
            listProductCode.add('262084');

            // objInput.CLASS_NM = 'cj.com.cjfwinterface.server.fs.service.CJCRM0030Service'; 
            // objInput.METHOD_NM = 'getGoodsControlData'; 
            objInput.system_type_cd = 'IF0004'; 
            objInput.opcode = 'CR006'; 
            objInput.lgs_ctr_id = '2620'; 
            objInput.CUST_ID = '527271001'; 
            objInput.REF_DATE = '20221119'; 
            objInput.GD_NO = listProductCode; 
            // mapInputSub.put('lgs_ctr_id', '2620');
            // mapInputSub.put('ra_ds_list.fieldInfo', 'GD_NO');
            // mapInputSub.put('START_ROW', '1');
            // mapInputSub.put('END_ROW', '');
            // mapInputSub.put('DO_COUNTTOT', 'true');

            // mapInputSub.put('CUST_ID', '527271001');
            // mapInputSub.put('REF_DATE', '20221119');
            // mapInputSub.put('GD_NO', listProductCode);
            // objInput.inParams = mapInputSub; 

            System.debug(' objInput ::: ' + JSON.serialize(objInput));

            IFUtil ifutilWrapper = new IFUtil('IF_IFRESH_SFDC_PRICE_CONTROL_INFO');

            String strJsonRequestBody = JSON.serialize(objInput);
            HttpResponse response = ifutilWrapper.webCallout(strJsonRequestBody, true);

            if(response.getStatusCode() == 200) {
                system.debug( ':: 성공' );
                system.debug( 'check Input ::: ' + strJsonRequestBody );
                system.debug( 'check Output ::: ' + response.getBody() );
            }else {
                system.debug( ':: 실패' );
                system.debug( 'check Input ::: ' + strJsonRequestBody );
                system.debug( 'check Output ::: ' + response.getBody() );
            }

        }
        catch(Exception e){
            system.debug('ActivityFuelMgmtController doSave error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }
}