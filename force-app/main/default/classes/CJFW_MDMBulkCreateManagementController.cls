/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 11-22-2023
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
  public static SaveResult doSave(List<MDMRegRequestCustomer__c> customerList, String type){
    system.debug('type ' + type);

    SaveResult saveResult = new SaveResult();

    String recordTypeName = 'MDMManagement';     // 관리처
    String MDMRecordTypeId = '';  
    String Status = 'Waiting';                   // 이거
    system.debug('#CJFW_MDMBulkCreateHeadController >>>doSave ');
    MDMRecordTypeId = Schema.SObjectType.MDMRegRequestCustomer__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId(); // 이거
    // mdmCustomer obj =  JSON.deserialize(mdmCustomer, 래퍼클래스명.class);
    try {
        if(customerList != null){    
            MDMRegRequestBulkCustomer__c mdmRequestbulk = new MDMRegRequestBulkCustomer__c();
            //bulk 첫번째 => (0번째 Name) + 외 ( )건;
            mdmRequestbulk.Name = customerList[0].PV_NAME1__c + ' 외 ' + customerList.size() + '건';
            mdmRequestbulk.RequestType__c = 'Create';
            insert mdmRequestbulk;

            saveResult.bulkId = mdmRequestbulk.id;
            
            for(MDMRegRequestCustomer__c customerObj : customerList){
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
    * @description : 대량생성 유효성 검사 (대량의 경우 JS에서 하면 시간이 너무 올래 걸려서 Controller로 이동)
    * @params      : X
    * @return      : `List<ErrorData>`
    * =======================================================================================================================
    */
    @AuraEnabled
    public static List<ErrorData> validationCheckBeforeSave(List<MDMRegRequestCustomer__c> mdmList) {
        System.debug(' ### validationCheckBeforeSave() ' );
        try {
            System.debug('mdmList ' + mdmList);
    
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
                checkRequiredField(mdm.PV_NAME1__c, i,  '고객명(영문명 포함)', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_NAME_G__c, i, '고객명(G) / 자국명', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_NAME2__c, i, '고객약칭명(변경)', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_KTOKD__c, i, '고객계정그룹[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_CUSTTYPE__c, i, '고객유형[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_STCD2__c, i, '사업자등록번호', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_STCD3__c, i, '법인코드', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_STCD4__c, i, '종사업장번호', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_GFORM__c, i, '법적상태[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_J_1KFREPRE__c, i, '대표자이름', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_STCD1__c, i, '대표자 생년월일', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_J_1KFTBUS__c, i, '업태', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_J_1KFTIND__c, i, '업종', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_TELF1__c, i, '전화번호', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_VKGRP__c, i, '영업그룹[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PVRA_VKGRP__c, i, '영업그룹[VALID FROM]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_PERNR__c, i, '담당MA[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PVRA_PERNR__c, i, '담당MA[VALID FROM]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_LOGISCENTER__c, i, 'FW 출고센터[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PVRA_LOGISCENTER__c, i, 'FW 출고센터[VALID FROM]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_STCDT__c, i, '세금계산서발행유형[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_FITYP__c, i, '과세유형[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_HDOFFICEYN__c, i, '본점사용 유무', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_HKUNNR__c, i, '본점코드[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_SUBSIDIARYYN__c, i, '관계사여부', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_VBUND__c, i, '관계사 코드[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_LAND1__c, i, '국가키[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_KNVKTYPE__c, i, '주문유형[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_REGIO__c, i, '지역[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_ADRES_ZIPCODE__c, i, '주소[ZIPCODE]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_ADRES_ADDR1__c, i, '주소[ADDR1]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_ADRES_ADDR2__c, i, '주소[ADDR2]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_ADRES_ROADADDR1__c, i, '주소[ROAD ADDR1]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_ADRES_ROADADDR2__c, i, '주소[ROAD ADDR2]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_SALESCUST__c, i, '판매처[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_BUSAB__c, i, '매출형태[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_CESSION_KZ__c, i, '고객상태[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_ZUAWA__c, i, '정렬키[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_AKONT__c, i, '조정계정[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_FDGRV__c, i, '현금관리그룹[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_TAXKDD__c, i, '세금분류[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_KATR5__c, i, '세금납부방법[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_CUHR1__c, i, '고객분류[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PVRA_CUHR1__c, i, '고객분류[VALID FROM]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_KONDA__c, i, '가격그룹[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PVRA_KONDA__c, i, '가격그룹[VALID FROM]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_KVGR1__c, i, '단가그룹[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PVRA_KVGR1__c, i, '단가그룹[VALID FROM]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_WAERS__c, i, '통화[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_KVGR3__c, i, '납품서유형[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_KVGR3_BOT__c, i, '납품서 하단유형[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_ODCLOSEGB__c, i, '고객 주문마감 유형코드[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_VACCPRTEXCYN__c, i, '가상계좌 출력 제외', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_ZTERM_VV__c, i, '지급조건[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_DSTRHISTREGYN__c, i, '유통이력 신고대상 유형[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_OLD_BIZPLACE_NEW__c, i, '경로(사업부)[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PVRA_OLD_BIZPLACE_NEW__c, i, '경로(사업부)[VALID FROM]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_EXAMYN__c, i, '대면검수여부', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_DELIGROUP__c, i, '배송그룹[ID]', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_KEYYN__c, i, '업장key 여부', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_KEYINFO__c, i, '업장key 정보', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_ISFDFTF__c, i, '초도배송 대면검수', '필수값', errorDataidList);
                checkRequiredField(mdm.PV_TEMPTARGET__c, i, '온도기록지 제출 대상 여부[ID]', '필수값', errorDataidList);
                
                // 구코드(As-Is)
                if(mdm.PV_OLDCD__c != null){
                    System.debug('## mdm.PV_OLDCD__c => ' + mdm.PV_OLDCD__c);

                    Matcher matcher = pattern1.matcher(mdm.PV_OLDCD__c);

                    System.debug('matcher.matches()' + matcher.matches());

                    if(mdm.PV_OLDCD__c != '' && mdm.PV_OLDCD__c != null && !matcher.matches()) {
                        ErrorData obj = new ErrorData(i + 1, '구코드(As-Is)', '구코드(As-Is): 구코드는 10자리 이하의 숫자만 가능합니다.', '유효성');
                        System.debug('## obj : PV_OLDCD__c => ' + obj);
                        errorDataidList.add(obj);
                    }
                }
                // 사업자등록번호 
                if(mdm.PV_STCD2__c != null ){
                    System.debug('## mdm.PV_STCD2__c => ' + mdm.PV_STCD2__c);

                    Matcher matcher = pattern2.matcher(mdm.PV_STCD2__c);

                    System.debug('matcher.matches()' + matcher.matches());

                    if(mdm.PV_STCD2__c != '' && mdm.PV_STCD2__c != null && !matcher.matches()) {
                        ErrorData obj = new ErrorData(i + 1, '사업자등록번호', '올바른 형식의 사업자등록번호가 아닙니다. 10자리 숫자만 입력이 가능합니다.', '유효성');
                        System.debug('## obj : PV_STCD2__c => ' + obj);
                        errorDataidList.add(obj);
                    }
                }
                // 종사업자번호
                if(mdm.PV_STCD4__c != null ){
                    System.debug('## mdm.PV_STCD4__c => ' + mdm.PV_STCD4__c);

                    Matcher matcher = pattern9.matcher(mdm.PV_STCD4__c);

                    System.debug('matcher.matches()' + matcher.matches());

                    if(mdm.PV_STCD4__c != '' && mdm.PV_STCD4__c != null && !matcher.matches()) {
                        ErrorData obj = new ErrorData(i + 1, '종사업자번호', '올바른 형식의 종사업자번호가 아닙니다. 4자리 숫자만 입력이 가능합니다.', '유효성');
                        System.debug('## obj : PV_STCD2__c => ' + obj);
                        errorDataidList.add(obj);
                    }
                }
                // 법인코드 
                if(mdm.PV_STCD3__c != null){
                    System.debug('## mdm.PV_STCD3__c => ' + mdm.PV_STCD3__c);

                    Matcher matcher = pattern3.matcher(mdm.PV_STCD3__c);

                    System.debug('matcher.matches()' + matcher.matches());

                    if(mdm.PV_STCD3__c != '' && mdm.PV_STCD3__c != null && !matcher.matches()) {
                        ErrorData obj = new ErrorData(i + 1, '법인코드', '올바른 형식의 법인코드가 아닙니다. 13자리 숫자만 입력이 가능합니다.', '유효성');
                        System.debug('## obj : PV_STCD2__c => ' + obj);
                        errorDataidList.add(obj);
                    }
                }
                // 대표자 생년월일 
                if(mdm.PV_STCD1__c != null){
                    System.debug('## mdm.PV_STCD1__c => ' + mdm.PV_STCD1__c);

                    Matcher matcher = pattern4.matcher(mdm.PV_STCD1__c);

                    System.debug('matcher.matches()' + matcher.matches());

                    if(mdm.PV_STCD1__c != '' && mdm.PV_STCD1__c != null && !matcher.matches()) {
                        ErrorData obj = new ErrorData(i + 1, '대표자 생년월일', '올바른 형식의 대표자 생년월일이 아닙니다. 6자리만 입력이 가능합니다. 예시) 750101', '유효성');
                        System.debug('## obj : PV_STCD1__c => ' + obj);
                        errorDataidList.add(obj);
                    }
                }
                // 전화번호
                if(mdm.PV_TELF1__c != null){
                    System.debug('## mdm.PV_TELF1__c => ' + mdm.PV_TELF1__c);

                    Matcher matcher = pattern5.matcher(mdm.PV_TELF1__c);

                    System.debug('matcher.matches()' + matcher.matches());

                    if(mdm.PV_TELF1__c != '' && mdm.PV_TELF1__c != null && !matcher.matches()) {
                        ErrorData obj = new ErrorData(i + 1, '전화번호', '올바른 형식의 전화번호가 아닙니다. "-" 값을 포함하여 입력', '유효성');
                        System.debug('## obj : PV_TELF1__c => ' + obj);
                        errorDataidList.add(obj);
                    }
                }
                // 팩스번호
                if(mdm.PV_TELFX__c != null){
                    System.debug('## mdm.PV_TELF1__c => ' + mdm.PV_TELFX__c);

                    Matcher matcher = pattern6.matcher(mdm.PV_TELFX__c);

                    System.debug('matcher.matches()' + matcher.matches());

                    if(mdm.PV_TELFX__c != '' && mdm.PV_TELFX__c != null && !matcher.matches()) {
                        ErrorData obj = new ErrorData(i + 1, '전화번호', '올바른 형식의 전화번호가 아닙니다. "-" 값을 포함하여 입력', '유효성');
                        System.debug('## obj : PV_TELFX__c => ' + obj);
                        errorDataidList.add(obj);
                    }
                }
                // 약정회전일
                if(mdm.PV_KULTG__c != null){
                    System.debug('## mdm.PV_TELF1__c => ' + mdm.PV_KULTG__c);

                    Matcher matcher = pattern7.matcher(mdm.PV_KULTG__c);

                    System.debug('matcher.matches()' + matcher.matches());

                    if(mdm.PV_KULTG__c != '' && mdm.PV_KULTG__c != null && !matcher.matches()) {
                        ErrorData obj = new ErrorData(i + 1, '약정회전일', '올바른 형식의 약정회전일이 아닙니다.', '유효성');
                        System.debug('## obj : PV_KULTG__c => ' + obj);
                        errorDataidList.add(obj);
                    }
                }
                // 외형(정원)
                if(mdm.PV_SHAPE__c != null){
                    System.debug('## mdm.PV_TELF1__c => ' + mdm.PV_SHAPE__c);

                    Matcher matcher = pattern8.matcher(mdm.PV_SHAPE__c);

                    System.debug('matcher.matches()' + matcher.matches());

                    if(mdm.PV_SHAPE__c != '' && mdm.PV_SHAPE__c != null && !matcher.matches()) {
                        ErrorData obj = new ErrorData(i + 1, '외형(정원)', '올바른 형식의 외형이 아닙니다.', '유효성');
                        System.debug('## obj : PV_SHAPE__c => ' + obj);
                        errorDataidList.add(obj);
                    }
                }
                
            }
    
            System.debug('errorDataidList => ' + errorDataidList);
            return errorDataidList;
    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * =======================================================================================================================
    * @description : 대량생성의 참조코드 매뉴얼 다운로드 URL 
    * @params      : (필드API명, i, 필드명, '필수값', errorDataidList);
    * @return      : X
    * =======================================================================================================================
    */
    public static void checkRequiredField(Object fieldValue, Integer index, String fieldName, String type, List<ErrorData> errorDataidList) {
        if (fieldValue == null || (fieldValue instanceof String && String.isBlank((String)fieldValue))) {
            ErrorData obj = new ErrorData(index + 1, fieldName, '필수 값 입니다.', '필수값');
            System.debug('## obj => ' + obj);
            errorDataidList.add(obj);
        }
    }
    
   /**
    * =======================================================================================================================
    * @description : 대량생성의 참조코드 매뉴얼 다운로드 URL 
    * @params      : X
    * @return      : `String`
    *              let hiddenElement = document.createElement('a');
    *                  hiddenElement.href = result;
    *                  hiddenElement.target = '_blank';
    *                  hiddenElement.download = 'download';
    *                  hiddenElement.click();
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

    public class SaveResult{
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String massage{get;set;}
        @AuraEnabled public String customerId{get;set;}
        @AuraEnabled public String bulkId{get;set;}
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
        @AuraEnabled public String type;

        public ErrorData(Integer no, String field, String errorMsg, String type) {
            this.no = no;
            this.field = field;
            this.errorMsg = errorMsg;
            this.type = type;
        }
    }
}