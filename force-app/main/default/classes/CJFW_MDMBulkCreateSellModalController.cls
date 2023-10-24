/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 10-18-2023
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
  @AuraEnabled
  public static SaveResult doSave(List<MDMRequest> mdmCustomer)
  {
     String recordTypeName = 'MDMChild';  
     String MDMRecordTypeId = '';  
    system.debug('#CJFW_MDMBulkCreateHeadController >>>doSave ');
    MDMRecordTypeId = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
    SaveResult saveResult = new SaveResult();
    // aura  String 으로 넘어와서 JSON.des
    // mdmCustomer obj =  JSON.deserialize(mdmCustomer, 래퍼클래스명.class);
    system.debug('>>>doSave # mdmCustomer ' + JSON.serialize(mdmCustomer));
    //값을 나눠서 값이 없으면 안되는친구들
    //값이 없어도 되는친구들 
    try {
        if(mdmCustomer != null){    
            MDMRegRequestBulkCustomer__c mdmRequestbulk = new MDMRegRequestBulkCustomer__c();
            //bulk 첫번째 => (0번째 Name) + 외 ( )건;
            // 얘가
        //   mdmRequestbulk.Name	                                = '저장TEST.';
            mdmRequestbulk.Name = mdmCustomer[0].Name + ' 외 ' + mdmCustomer.size() + '건';
            mdmRequestbulk.RequestType__c = 'Create';
            insert mdmRequestbulk;
            saveResult.customerId = mdmRequestbulk.id;
            
            for (MDMRequest mdm : mdmCustomer) {
                MDMRegRequestCustomer__c mdmRequest = new MDMRegRequestCustomer__c();
                system.debug('안녕하세요 ' + mdmRequestbulk.id);
                system.debug('mdm.name ' + mdm.name);
                system.debug('mdm.name ' + mdm.BusinessNumber);
                system.debug('mdm.name ' + mdm.CEOName);
                
                mdmRequest.PV_NAME1__c                   =      String.isBlank(mdm.Name) ? null : mdm.Name;
                mdmRequest.PV_STCD2__c                   =      String.isBlank(mdm.BusinessNumber) ? null : mdm.BusinessNumber;
                mdmRequest.PV_J_1KFREPRE__c              =      String.isBlank(mdm.CEOName) ? null : mdm.CEOName;
                mdmRequest.recordTypeId                  =      MDMRecordTypeId;
                mdmRequest.MDMRegRequestBulkCustomer__c  =      mdmRequestbulk.id;
                mdmRequest.PV_CUSTTYPE__c                =      'C02';
                system.debug('mdmRequest ' + mdmRequest);
                insert mdmRequest;
            }
            saveResult.status = 'S';
            saveResult.massage = '성공 하였습니다.';
        }
      } catch (Exception e) {
          saveResult.error = e.getMessage() +', '+ e.getLineNumber();
      }

      return saveResult;
  } 
  
  public static List<String> getAllFieldNames(String sObjectName) {
        List<String> fieldNames = new List<String>();
        
        // sObject의 토큰을 가져옵니다.
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
        
        // null 체크
        if(sObjectType == null) {
            System.debug('sObject not found: ' + sObjectName);
            return fieldNames;
        }
        
        // 모든 필드의 맵을 가져옵니다.
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        
        // 필드 이름들을 목록에 추가합니다.
        for(String fieldName : fieldMap.keySet()) {
            fieldNames.add(fieldName);
        }
        
        system.debug('fieldNames ' + fieldNames);

        return fieldNames;
    }

// // 사용 예:
// List<String> accountFields = getAllFieldNames('Account');
// System.debug(accountFields);


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