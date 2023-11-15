/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 11-14-2023
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
     /**
    * =======================================================================================================================
    * @description : 대량생성의 참조코드 매뉴얼 다운로드 URL 
    * @params      : X
    * @return      : `String`
    *   let hiddenElement = document.createElement('a');
    *       hiddenElement.href = result;
    *       hiddenElement.target = '_blank';
    *       hiddenElement.download = 'download';
    *       hiddenElement.click();
    * =======================================================================================================================
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
   
   /**
   * =======================================================================================================================
   * @description : 대량생성 유효성 검사 (대량의 경우 JS에서 하면 시간이 너무 올래 걸려서 Controller로 이동)
   * @params      : X
   * @return      : `List<ErrorData>`
   * =======================================================================================================================
   */
  @AuraEnabled
  public static List<ErrorData> validationCheckBeforeSave(List<MDMRegRequestCustomer__c> mdmList, List<String> headerList) {
      try {
          System.debug('mdmList ' + mdmList);
          System.debug('headerList ' + headerList);
  
          List<ErrorData> errorDataidList = new List<ErrorData>();
  
          // 구코드 validation
          String regex1 = '^(\\d{0,10}|)$';
          Pattern pattern1 = Pattern.compile(regex1);
          // 사업자등록번호 제어 validation
          String regex2 = '^(\\d{10}|)$';
          Pattern pattern2 = Pattern.compile(regex2);
          // 법인코드 제어 validation
          String regex3 = '^(\\d{13}|)$';
          Pattern pattern3 = Pattern.compile(regex3);
          // 대표자 생년월일 validation
          String regex4 = '^(?:[0-9]{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[1,2][0-9]|3[0,1]))$|^$';
          Pattern pattern4 = Pattern.compile(regex4);
          // 전화번호 validation
          String regex5 = '^\\d{2,3}-\\d{3,4}-\\d{4}$';
          Pattern pattern5 = Pattern.compile(regex5);
          // 팩스번호 validation
          String regex6 = '^\\d{2,3}-\\d{3,4}-\\d{4}$';
          Pattern pattern6 = Pattern.compile(regex6);
          // 약정회전일 validation
          String regex7 = '^\\d{1,3}$|^$';
          Pattern pattern7 = Pattern.compile(regex7);
          // 외형(정원) validation
          String regex8 = '^\\d{0,11}$';
          Pattern pattern8 = Pattern.compile(regex8);
          // 종사업자번호 제어 validation
          String regex9 = '^(\\d{4}|)$';
          Pattern pattern9 = Pattern.compile(regex9);
  
          for (Integer i = 0; i < mdmList.size(); i++) {
              MDMRegRequestCustomer__c mdm = mdmList[i];
              checkRequiredField(mdm.PV_NAME1__c, i, '고객명(영문명 포함)', errorDataidList);
              checkRequiredField(mdm.PV_NAME_G__c, i, '고객명(G) / 자국명', errorDataidList);
          }
  
          System.debug('errorDataidList => ' + errorDataidList);
          return errorDataidList;
  
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
  }
  
  public static void checkRequiredField(String fieldValue, Integer index, String fieldName, List<ErrorData> errorDataidList) {
      if (String.isBlank(fieldValue)) {
          ErrorData obj = new ErrorData(index + 1, fieldName, '필수 값 입니다.');
          System.debug('## obj => ' + obj);
          errorDataidList.add(obj);
      }
  }
  
    /**
    * SaveResult Wrapper
    */
    public class SaveResult{
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String massage{get;set;}
        @AuraEnabled public String customerId{get;set;}
        @AuraEnabled public String error{get;set;}

        public SaveResult(){}

    }
   
    /**
    * MDMRequest Wrapper
    */
    public class MDMRequest{
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String BusinessNumber {get;set;}
        @AuraEnabled public String CEOName {get;set;}
        
    }

    /**
    * ErrorData Wrapper
    */
    public class ErrorData {
        @AuraEnabled public Integer no;
        @AuraEnabled public String field;
        @AuraEnabled public String errorMsg;
        
        public ErrorData(Integer no, String field, String errorMsg) {
            this.no = no;
            this.field = field;
            this.errorMsg = errorMsg;
        }
    }
}