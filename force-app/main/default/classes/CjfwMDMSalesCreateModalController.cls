/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 09-22-2023
 * @last modified by  : yeonji.lim@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   09-21-2023   yeonji.lim@dkbmc.com      Initial Version
**/
public with sharing class CjfwMDMSalesCreateModalController {
    
    public class DataWrapper {
        @AuraEnabled
        public String strStatus {get;set;}      // 성공, 실패
        @AuraEnabled
        public String strMessage {get;set;}     // 에러메세지
        @AuraEnabled
        public String strObjectType {get;set;}
        @AuraEnabled
        public String MDMRecordTypeId {get;set;}

        @AuraEnabled
        public List<Map<String, String>> listCustomerOrderType {get;set;}   //고객 주문마감 유형코드 pickList value

        @AuraEnabled
        public User objUser {get;set;}
        @AuraEnabled
        public Opportunity objOpportunity {get;set;}
        @AuraEnabled
        public MDMRegRequestCustomer__c objMDMRegReqCustomer {get;set;}     // MDM 고객 등록 및 수정 요청Obj
        @AuraEnabled
        public List<MDMRegRequestContact__c> listMDMReqContact {get;set;}   // MDM 고객 등록 요청 담당자 정보Obj
    }

    /* 
    * 고객 주문마감 유형코드 → PV_ODCLOSEGB__c Picklist Value 가져오기
    */
    @AuraEnabled
    public static List<Map<String,String>> getPvOdclosegbPicklist(){
        try {
            
            List<Map<String,String>> picklistValue = CommonUtil.getPickListValues('MDMRegRequestCustomer__c', 'PV_ODCLOSEGB__c', false);
            System.debug('picklistValue' + picklistValue);
            
            return picklistValue;

        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 출고센터, 고객분류 변경시 고객 주문마감 유형코드 SelectList 변경
     * 
     * @params strType : LOGIC(출고센터), CUHR(고객분류)
     * @return DataWrapper
     *
    **/
    @AuraEnabled
    public static DataWrapper doCheckOrderType(String strType, String PV_LOGISCENTER, String PV_CUHR1) {
        try {
            DataWrapper objWrapper = new DataWrapper();
            String strStatus = 'SUCCESS';
            String strMessage = '';
            String PV_ODCLOSEGB = '';

            System.debug('==============> strType : '+strType);
            System.debug('==============> PV_LOGISCENTER : '+PV_LOGISCENTER);

            // 고객분류 코드 앞에 숫자4자리만 가져오기
            System.debug('==============> before PV_CUHR1 : '+PV_CUHR1);
            if(PV_CUHR1 <> null && PV_CUHR1.contains('-')) {
                PV_CUHR1 = PV_CUHR1.split('-')[0];
            }
            System.debug('==============> after PV_CUHR1 : '+PV_CUHR1);


            // MDMCustomerOrderType__c obj에서 선택된 Fw출고센터&고객분류에 맞는 고객주문마감 유형코드 리스트 가져오기
            Set<String> setCloseGB = new Set<String>();

            String strQuery = 'SELECT Id, CUHR1__c, LOGISCENTER__c, CLOSEGB__c';
            strQuery += ' FROM  MDMCustomerOrderType__c';
            
            if(strType == 'LOGIC') {
                strQuery += ' WHERE LOGISCENTER__c LIKE \'%'+PV_LOGISCENTER+'%\'';
            }else {                
                strQuery += ' WHERE CUHR1__c =\''+PV_CUHR1+'\'';
            }
            
            strQuery += '   ORDER BY CLOSEGB__c ASC';


            System.debug('Database.query(strQuery)' + Database.query(strQuery));

            // 고객주문마감 유형코드 리스트에서 중복된 코드들 제외
            for(MDMCustomerOrderType__c obj : Database.query(strQuery)) {
                System.debug('=========> obj.CUHR1__c : '+obj.CUHR1__c);
                System.debug('=========> obj.PV_CUHR1 : '+PV_CUHR1);

                if(strType == 'LOGIC') {
                    if(obj.CUHR1__c == 'All') {
                        setCloseGB.add(obj.CLOSEGB__c);
                    }else if(obj.CUHR1__c == PV_CUHR1) {
                        setCloseGB.add(obj.CLOSEGB__c);
                    }
                }else {
                    if(obj.CUHR1__c == 'All') {
                        setCloseGB.add(obj.CLOSEGB__c);
                    }else if(obj.LOGISCENTER__c.contains(PV_LOGISCENTER)) {
                        setCloseGB.add(obj.CLOSEGB__c);
                    }
                }
            }
            
            System.debug('===========> setCloseGB : '+setCloseGB);

            // 고객주문마감 유형코드 pickList 가져오기
            List<Map<String, String>> listOrderType = CommonUtil.getPickListValues('MDMRegRequestCustomer__c', 'PV_ODCLOSEGB__c', false);
            
            List<Map<String, String>> listCustomerOrderType = new List<Map<String, String>>();
            // listCustomerOrderType.add(new Map<String, String>{
            //     'label' => '--없음--',
            //     'value' => 'none'
            // });

            // setCloseGB에 값이 있다면 pickList중 코드가 일치한 pickList value 값 가져오기
            if(!setCloseGB.isEmpty()) {
                for(Map<String, String> mapTarget : listOrderType) {
                    if(setCloseGB.contains(mapTarget.get('value'))) {
                        listCustomerOrderType.add(mapTarget);
                    }
                }
            }else {
                listCustomerOrderType = listOrderType;
            }

            objWrapper.listCustomerOrderType = listCustomerOrderType;
            System.debug('listOrderType =>' + listCustomerOrderType);

            objWrapper.strStatus = strStatus;

            return objWrapper;

        } catch (Exception e) {
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

}