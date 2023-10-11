/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 10-10-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   10-10-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMBulkCreateManagementController {
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
     String recordTypeName = 'MDMManagement';  
     String MDMRecordTypeId = '';  
    // JSON.deserialize(mdmCustomer, mdmCustomer.class);
      system.debug('mdmCustomer ' + mdmCustomer);
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
            system.debug('mdmCustomer!@@@ ' + json.serialize(mdmCustomer));
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
                    
                    mdmRequest.PV_NAME1__c       =      String.isBlank(mdm.Name) ? null : mdm.Name;
                    mdmRequest.PV_STCD2__c       =      String.isBlank(mdm.BusinessNumber) ? null : mdm.BusinessNumber;
                    mdmRequest.PV_J_1KFREPRE__c  =      String.isBlank(mdm.CEOName) ? null : mdm.CEOName;
                    mdmRequest.recordTypeId      =      MDMRecordTypeId;
                    mdmRequest.MDMRegRequestBulkCustomer__c  = mdmRequestbulk.id;
                    
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

  public class SaveResult{
      @AuraEnabled public String status{get;set;}
      @AuraEnabled public String massage{get;set;}
      @AuraEnabled public String customerId{get;set;}
      @AuraEnabled public String error{get;set;}

      // 생성자의 역할은 기본적으로
      // 전역변수(인스턴스변수) 초기화 해주는 역할을함
    //   public SaveResult(){
    //       this.status = 'S';
    //       this.massage = '성공 하였습니다.';
    //   }

    //   public SaveResult(String status, String massage){
    //       this.status  = status;
    //       this.massage = massage;
    //   }
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