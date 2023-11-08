/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 11-07-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   10-12-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMBulkCreateSellModalController {
    /**
   * Save 버튼을 클릭 했을 때 호출
   * 
   * @params mdmCustomer : 화면 mdmCustomer 데이터
   * @params contacts :화면 contacts (List)데이터 > 왜 리스트가 나올까? 데이터가 다건인가?
   * @params banks : 화면 banks (List) 데이터 
   * 
   * CRM 오브젝트 = wrapper class다 
   * contact < 스탠다드 오브젝트 
   */
    @AuraEnabled                  // List<MDMRequest> mdmCustomer
    public static SaveResult doSave(List<MDMRegRequestCustomer__c> customerList)
    {
        system.debug('gd');
        system.debug(customerList);

        SaveResult saveResult = new SaveResult();

        String recordTypeName = 'MDMChild';     // 판매처
        String MDMRecordTypeId = '';  
        String Status = 'Waiting';              // 이거
        system.debug('#CJFW_MDMBulkCreateHeadController >>>doSave ');
        MDMRecordTypeId = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(); // 이거
        // aura  String 으로 넘어와서 JSON.des
        // mdmCustomer obj =  JSON.deserialize(mdmCustomer, 래퍼클래스명.class);
        // system.debug('>>>doSave # mdmCustomer ' + JSON.serialize(mdmCustomer));
        //값을 나눠서 값이 없으면 안되는친구들
        //값이 없어도 되는친구들 
        try {
            if(customerList != null){    
                MDMRegRequestBulkCustomer__c mdmRequestbulk = new MDMRegRequestBulkCustomer__c();
                //bulk 첫번째 => (0번째 Name) + 외 ( )건;
                // 얘가
                //   mdmRequestbulk.Name	                                = '저장TEST.';
                mdmRequestbulk.Name = customerList[0].PV_NAME1__c + ' 외 ' + customerList.size() + '건';
                mdmRequestbulk.RequestType__c = 'Create';
                insert mdmRequestbulk;

                saveResult.customerId = mdmRequestbulk.id;
                
                for(MDMRegRequestCustomer__c customerObj : customerList)
                {
                    customerObj.MDMRegRequestBulkCustomer__c = mdmRequestbulk.id;
                    customerObj.recordTypeId = MDMRecordTypeId;
                    customerObj.Status__c = Status;
                }
                insert customerList;

                saveResult.status = 'S';
                saveResult.massage = '성공 하였습니다.';
            }
        } catch (Exception e) {
            saveResult.error = e.getMessage() +', '+ e.getLineNumber();
            saveResult.status = 'F';
            saveResult.massage = '실패 하였습니다.';
            
            throw new AuraHandledException(e.getMessage()+ ', '+ e.getLineNumber());
        }
        return saveResult;
    } 
    // // 사용 예:
    // List<String> accountFields = getAllFieldNames('Account');
    // System.debug(accountFields);

    /**
     *                  let hiddenElement = document.createElement('a');
                        hiddenElement.href = result;
                        hiddenElement.target = '_blank';
                        hiddenElement.download = 'download';
                        hiddenElement.click();
     */
    @AuraEnabled  
    public static String downloadMenualExcel(){
        ContentVersion cv = [SELECT   Title, id, VersionNumber 
                             FROM     ContentVersion 
                             WHERE    Title = 'MDM 참조코드 매뉴얼' 
                             ORDER BY VersionNumber DESC LIMIT 1];

        String contentId = cv.Id;

        return URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + contentId;
    }

    public class SaveResult{
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String massage{get;set;}
        @AuraEnabled public String customerId{get;set;}
        @AuraEnabled public String error{get;set;}

        public SaveResult(){}

    }
   
    /**
     * MDMRequest 공통
     */
    public class MDMRequest{
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String BusinessNumber {get;set;}
        @AuraEnabled public String CEOName {get;set;}
        
    }
}