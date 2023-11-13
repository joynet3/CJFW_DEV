/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 11-13-2023
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
  @AuraEnabled                  // List<MDMRequest> mdmCustomer
  public static SaveResult doSave(List<MDMRegRequestCustomer__c> customerList)
  {
    system.debug('gd');
    system.debug(customerList);

    SaveResult saveResult = new SaveResult();

    String recordTypeName = 'MDMManagement';     // 판매처
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
    public static List<ErrorData> validationCheckBeforeSave(List<MDMRegRequestCustomer__c> mdmList, List<String> headerList){
        try {

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

            // for(Integer i = 0; i < mdmList.size(); i++) {

            //     MDMRequest mdm = mdmList[i];

            //     if(headerList.contains('구코드(As-Is)')) {
            //         if(mdm.PV_OLDCD != null) {

            //             System.debug('## mdm.PV_OLDCD => ' + mdm.PV_OLDCD);

            //             Matcher matcher = pattern1.matcher(mdm.PV_OLDCD);

            //             System.debug('matcher.matches()' + matcher.matches());

            //             if(mdm.PV_OLDCD != '' && mdm.PV_OLDCD != null && !matcher.matches()) {
            //                 ErrorData obj = new ErrorData(i + 1, '구코드(As-Is)', '구코드(As-Is): 구코드는 10자리 이하의 숫자만 가능합니다.');
            //                 System.debug('## obj => ' + obj);
            //                 errorDataidList.add(obj);
            //             }
            //         }
            //     }

                // if(headerList.contains('사업자등록번호')) {
                //     if(mdm.PV_STCD2 != null) {

                //         System.debug('## mdm.PV_STCD2 => ' + mdm.PV_STCD2);

                //         Matcher matcher = pattern2.matcher(mdm.PV_STCD2);

                //         System.debug('matcher.matches()' + matcher.matches());

                //         if(mdm.PV_STCD2 != '' && mdm.PV_STCD2 != null && !matcher.matches()) {
                //             ErrorData obj = new ErrorData(i + 1, '사업자등록번호', '올바른 형식의 사업자등록번호가 아닙니다. 10자리 숫자만 입력이 가능합니다.');
                //             System.debug('## obj => ' + obj);
                //             errorDataidList.add(obj);
                //         }
                //     }
                // }

                // if(headerList.contains('법인코드')) {
                //     if(mdm.PV_STCD3 != null) {

                //         System.debug('## mdm.PV_STCD3 => ' + mdm.PV_STCD3);

                //         Matcher matcher = pattern3.matcher(mdm.PV_STCD3);

                //         System.debug('matcher.matches()' + matcher.matches());

                //         if(mdm.PV_STCD3 != '' && mdm.PV_STCD3 != null && !matcher.matches()) {
                //             ErrorData obj = new ErrorData(i + 1, '법인코드', '올바른 형식의 법인코드가 아닙니다. 13자리 숫자만 입력이 가능합니다.');
                //             System.debug('## obj => ' + obj);
                //             errorDataidList.add(obj);
                //         }
                //     }
                // }

                // if(headerList.contains('대표자 생년월일')) {
                //     if(mdm.PV_STCD1 != null) {

                //         System.debug('## mdm.PV_STCD1 => ' + mdm.PV_STCD1);

                //         Matcher matcher = pattern4.matcher(mdm.PV_STCD1);

                //         System.debug('matcher.matches()' + matcher.matches());

                //         if(mdm.PV_STCD1 != '' && mdm.PV_STCD1 != null && !matcher.matches()) {
                //             ErrorData obj = new ErrorData(i + 1, '대표자 생년월일', '올바른 형식의 대표자 생년월일이 아닙니다. 6자리만 입력이 가능합니다. 예시) 750101');
                //             System.debug('## obj => ' + obj);
                //             errorDataidList.add(obj);
                //         }
                //     }
                // }

                // if(headerList.contains('전화번호')) {
                //     if(mdm.PV_TELF1 != null) {

                //         System.debug('## mdm.PV_TELF1 => ' + mdm.PV_TELF1);

                //         Matcher matcher = pattern5.matcher(mdm.PV_TELF1);

                //         System.debug('matcher.matches()' + matcher.matches());

                //         if(mdm.PV_TELF1 != '' && mdm.PV_TELF1 != null && !matcher.matches()) {
                //             ErrorData obj = new ErrorData(i + 1, '전화번호', '올바른 형식의 전화번호가 아닙니다. "-" 값을 포함하여 입력');
                //             System.debug('## obj => ' + obj);
                //             errorDataidList.add(obj);
                //         }
                //     }
                // }

            //}

            System.debug('errorDataidList => ' + errorDataidList);

            return errorDataidList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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