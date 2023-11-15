/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 11-15-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-29-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CJFW_MDMManagerSearchController {

    @AuraEnabled 
    public static List<MDMReferenceCode__c> getMdmNamesByCodes(List<String> codes){
        return [SELECT Id, Name, CODE__c  FROM MDMReferenceCode__c WHERE CODE__c IN :codes AND GROUPID__c = 'KNVKGB'];
    }
    /**
    * @description 선택한 recordId를 이용해 Account정보/ Contact정보 가져와 MDM 고객 등록 요청(관리처)에 보내주기
    * 
    * @return      `String`
    */ 
    @AuraEnabled
    public static  List<Map<String, Object>> getContactInfo(String selectedId){
        system.debug('### CJFW_MDMManagerSearchController.getContactInfo(String selectedId) 모달 ### ');
        system.debug('>>> managerModal Account Id ' + selectedId);
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        // List<Account> accList = [SELECT Id,
        //                                  (SELECT Id, Lastname, Firstname, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_KNVKGB__c FROM Contacts) 
        //                           FROM Account 
        //                           WHERE Id = :selectedId 
        //                           LIMIT 1];
        List<Contact> conList = [SELECT Id, LastName, Firstname, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_KNVKGB__c
                                     FROM Contact
                                     WHERE AccountId = :selectedId];

        system.debug('conList ' + JSON.serialize(conList));
         if(!conList.isEmpty()){
            for(Contact con : conList){
                Map<String, Object> contactData = new Map<String, Object>();
                integer i = 1;
                contactData.put('No', i);
                contactData.put('PV_NAME1_VK__c', con.LastName);
                contactData.put('PV_KNVKGB_lu__c', '');
                contactData.put('PV_KNVKGB__c', con.PV_KNVKGB__c);
                contactData.put('PV_TELF1_VK__c', con.MobilePhone);
                contactData.put('PV_EMAIL_VK__c', con.Email);
                contactData.put('PV_PAFKT_VK__c', con.PV_PAFKT_VK__c);
                contactData.put('PV_ABTNR_VK__c', con.Department);
                contactData.put('PV_TALKT_VK__c', con.PV_TALKT_VK__c);
                contactData.put('Contact__c', con.Id);
                result.add(contactData);
                i++;
            }
         }
        
        // if (!accList.isEmpty()) {
        //     for (Contact con : accList[0].Contacts) {
        //         Map<String, Object> contactData = new Map<String, Object>();
        //         integer i = 1;
        //         contactData.put('No', i);
        //         contactData.put('PV_NAME1_VK__c', con.LastName);
        //         contactData.put('PV_KNVKGB_lu__c', '');
        //         contactData.put('PV_KNVKGB__c', con.PV_KNVKGB__c);
        //         contactData.put('PV_TELF1_VK__c', con.MobilePhone);
        //         contactData.put('PV_EMAIL_VK__c', con.Email);
        //         contactData.put('PV_PAFKT_VK__c', con.PV_PAFKT_VK__c);
        //         contactData.put('PV_ABTNR_VK__c', con.Department);
        //         contactData.put('PV_TALKT_VK__c', con.PV_TALKT_VK__c);
        //         contactData.put('Contact__c', con.Id);
        //         result.add(contactData);
        //         i++;
        //     }
        // }
        system.debug('result ' + JSON.serialize(result));
        return result;
    }

     /**
    * @description 선택한 recordId를 이용해 Account정보/ Contact정보 가져와 MDM 고객 등록 요청(관리처)에 보내주기
    * 
    * @return      `String`
    */ 
    @AuraEnabled
    public static  List<Contact> searchContactInfo(String searchWord){
        system.debug('### CJFW_MDMManagerSearchController.searchContactInfo(String searchWord) 모달 ### ');
        system.debug('>>> 검색어 : ' + searchWord);
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        
        //여기서부터시작.
        List<Contact> listSearchResult = new List<Contact>();

        String strQuery = 'SELECT Id,';
        strQuery += '   Name, LastName, Firstname, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_KNVKGB__c ';
        strQuery += '   FROM    Contact ';
        strQuery += '   WHERE   LastName != null ';
        if(searchWord <> null) {
            strQuery += '   AND     (LastName LIKE \'%'+searchWord+'%\')';
        }
        listSearchResult = Database.query(strQuery);
        integer listSearchResultSize = listSearchResult.size();
     
        system.debug('result ' + JSON.serialize(result));
        return listSearchResult;
    }

     /**
    * @description 선택한 recordId를 이용해 Account정보/ Contact정보 가져와 MDM 고객 등록 요청(관리처)에 보내주기
    * 
    * @return      `String`
    */ 
   @AuraEnabled
   public static  DataWrapper getSingleContactInfo(String clickedAccId){
       system.debug('### CJFW_MDMManagerSearchController.getSingleContactInfo(String searchWord) 모달 ### ');
       system.debug('>>> contactId : ' + clickedAccId);
       
       DataWrapper objWrapper = new DataWrapper();
       
       //여기서부터시작.

        List<Contact> listReqContactList = [SELECT Id, Name, LastName, Firstname, Email, Phone, MobilePhone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, PV_KNVKGB__c
        FROM Contact
        WHERE id = :clickedAccId];

        Set<String> conCodeSet = new Set<String>();
        for(Contact con :listReqContactList){
            conCodeSet.add(con.PV_KNVKGB__c);
        }
        
        List<MDMReferenceCode__c> conReferenceCodeList = [SELECT Id, Name, Code__c FROM MDMReferenceCode__c WHERE code__c =: conCodeSet];
        
        Map<String, String> codeToConIdMap = new Map<String, String>();
        for(MDMReferenceCode__c conCode :conReferenceCodeList){ 
            codeToConIdMap.put(conCode.Code__c, conCode.id);
        }

        List<MDMRegRequestContact__c> mdmReqContactList = new List<MDMRegRequestContact__c>();
        for(Contact con : listReqContactList){
            MDMRegRequestContact__c mdmReqContact = new MDMRegRequestContact__c();
                mdmReqContact.PV_NAME1_VK__c  = con.Name;
                mdmReqContact.PV_KNVKGB__c    = con.PV_KNVKGB__c;        
                mdmReqContact.PV_KNVKGB_lu__c = codeToConIdMap.get(con?.PV_KNVKGB__c);
                mdmReqContact.PV_TELF1_VK__c  = con.MobilePhone;
                mdmReqContact.PV_ABTNR_VK__c  = con.Department; 
                mdmReqContact.PV_PAFKT_VK__c  = con.PV_PAFKT_VK__c;
                mdmReqContact.PV_EMAIL_VK__c  = con.Email;
                mdmReqContact.PV_TALKT_VK__c  = con.PV_TALKT_VK__c;
                mdmReqContact.Contact__c      = con.id;
                mdmReqContactList.add(mdmReqContact);
            
        }
        objWrapper.listMDMReqContact = mdmReqContactList;

   
       return objWrapper;
   }
    /**
    * 연락처(Contact) 정보 저장
    * 
    * @params List<Contact> : 대상 연락처
    *
    **/
    @AuraEnabled
    public static void doSaveContact(string contactTarget){
        try {
            system.debug(' ################################### doSaveContact > contactTarget :: ' + contactTarget);
            List<Contact> listContact = new List<contact>();
            listContact = (List<Contact>) JSON.deserialize(contactTarget, List<Contact>.class);
            if(!listContact.isEmpty()){
                // id가 없으면 Insert
                List<Contact> insertConList = new List<Contact>();
                // id가 있으면 Update
                List<Contact> updateConList = new List<Contact>();
                
                for(Contact con : listContact){
                    if(String.isNotBlank(con.Id)){
                        Contact updateCon = new Contact();
                        updateCon.LastName         = String.isBlank(con.LastName)         ? '' : con.LastName;
                        updateCon.PV_KNVKGB__c     = String.isBlank(con.PV_KNVKGB__c)     ? '' : con.PV_KNVKGB__c;
                        updateCon.MobilePhone      = String.isBlank(con.MobilePhone)      ? '' : con.MobilePhone;
                        updateCon.Email            = String.isBlank(con.Email)            ? '' : con.Email;
                        updateCon.PV_PAFKT_VK__c   = String.isBlank(con.PV_PAFKT_VK__c)   ? '' : con.PV_PAFKT_VK__c;
                        updateCon.Department       = String.isBlank(con.Department)       ? '' : con.Department;
                        updateCon.PV_TALKT_VK__c   = String.isBlank(con.PV_TALKT_VK__c)   ? '' : con.PV_TALKT_VK__c;
                        updateCon.Id               = String.isBlank(con.Id)               ? '' : con.Id;
                        updateCon.PV_KNVKGB__c     = String.isBlank(con.PV_KNVKGB__c)     ? '' : con.PV_KNVKGB__c;
                        updateConList.add(updateCon);
                    }else{
                        Contact insertCon = new Contact();
                        insertCon.LastName         = String.isBlank(con.LastName)         ? '' : con.LastName;
                        insertCon.PV_KNVKGB__c     = String.isBlank(con.PV_KNVKGB__c)     ? '' : con.PV_KNVKGB__c;
                        insertCon.MobilePhone      = String.isBlank(con.MobilePhone)      ? '' : con.MobilePhone;
                        insertCon.Email            = String.isBlank(con.Email)            ? '' : con.Email;
                        insertCon.PV_PAFKT_VK__c   = String.isBlank(con.PV_PAFKT_VK__c)   ? '' : con.PV_PAFKT_VK__c;
                        insertCon.Department       = String.isBlank(con.Department)       ? '' : con.Department;
                        insertCon.PV_TALKT_VK__c   = String.isBlank(con.PV_TALKT_VK__c)   ? '' : con.PV_TALKT_VK__c;
                        insertCon.PV_KNVKGB__c               = String.isBlank(con.PV_KNVKGB__c)  ? '' : con.PV_KNVKGB__c;
                        insertConList.add(insertCon);
                    }
                }
                if(!updateConList.isEmpty()){ update updateConList; }
                if(!insertConList.isEmpty()){ insert insertConList; }

                List<String> insertContactIdList = new List<String>();
                for(contact insertCon : insertConList){ 
                    insertContactIdList.add(insertCon.Id);
                }
                system.debug('insertContactIdList ' + JSON.serialize(insertContactIdList));
            }

            // Map<String, Object> cObjMap = (Map<String, Object>) JSON.deserializeUntyped(contactTarget);
            // List<Object> listContact = (List<Object>) JSON.deserialize(contactTarget, Contact.class);
            // system.debug('contactTarget :: ' + (List<Contact>) JSON.deserialize(contactTarget, List<Contact>.class)) ;
            // for (Object objContact: listContact){

            //     system.debug('contactTarget :: ' + (Contact) ((Object) objContact)) ;
            // }
            // if( !contactTarget.isEmpty()){
            //     update contactTarget;
            // }
        } catch(Exception e){
            system.debug('MDMRegRequest doSaveContact error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

    @AuraEnabled(cacheable=true)
    public static DataWrapper getContactInfoAdd(List<Map<String, String>> searchKey, Integer pageNumber, Integer pageSize){

        system.debug('### CJFW_MDMBulkSearchContactController ###');
        system.debug('>>> getContactInfo()');

        String strStatus = 'SUCCESS';
        String strMessage = '';

        System.debug('===============> searchKey : ' + searchKey);

        // Key와 Value 따로 담아 주기
        List<String> searchKeys = new List<String>();
        List<String> searchValues = new List<String>();
        Map<String, String> dateValues = new Map<String, String>();

        for(Map<String, String> data : searchKey) {

            String apiType = data.get('type');
            String fieldName = data.get('fieldName');
            String datePoint = data.get('datePoint');
            String searchWord = data.get('searchKey');

            System.debug('## get param > ' + 'fieldName: ' + fieldName + ', apiType: ' + apiType + ', datePoint: ' + datePoint + ', searchWord: ' + searchWord);

            if(searchWord != null) {
                searchWord = searchWord.trim();
            }

            if(searchWord != null && searchWord.length() > 0 && fieldName != 'CreatedDate') {
                searchKeys.add(fieldName);
                searchValues.add(searchWord);
            } else if(searchWord != null && searchWord.length() > 0 && fieldName == 'CreatedDate') {
                searchWord = searchWord + 'T00:00:00.000+0000'; // UTC
                dateValues.put(datePoint, searchWord);
            }

        }

        System.debug('===============> searchKeys : ' + searchKeys);
        System.debug('===============> searchValues : ' + searchValues);
        System.debug('===============> dateValues : ' + dateValues);
        
        List<String> ids = new List<String>();

        DataWrapper objWrapper = new DataWrapper();

        try {

            List<Contact> searchResult = new List<Contact>();       // 분할해서 담은
            List<Contact> listSearchResult = new List<Contact>();   // 모두 담은

            String strQuery = 'SELECT Id, AccountId, Account.CustomerId__c, Account.Name, Name, ';
            strQuery += ' PV_KNVKGB__c, toLabel(PV_KNVKGB__c) PV_KNVKGB__LABEL, ';
            strQuery += ' Phone, Department, PV_PAFKT_VK__c, PV_TALKT_VK__c, Email ';
            strQuery += ' FROM Contact ';
            strQuery += ' WHERE Account.CustomerId__c != null ';
         
            for(Integer i = 0; i < searchKeys.size(); i++) {
                if(searchKeys[i] == 'AccountId') {
                    strQuery += ' AND ' + searchKeys[i] + ' = \'' + searchValues[i] + '\'';
                } else {
                    strQuery += ' AND ' + searchKeys[i] + ' LIKE \'%' + searchValues[i] + '%\' ';
                }
            }

            System.debug('============> strQuery : '+strQuery);

            listSearchResult = Database.query(strQuery);

            Integer listSearchResultSize = listSearchResult.size();

            Integer startIndex = (pageNumber - 1) * pageSize;
            Integer endIndex = Math.min(startIndex + pageSize, listSearchResultSize);

            if(endIndex > startIndex){
                for (Integer i = startIndex; i < endIndex; i++) {
                    searchResult.add(listSearchResult[i]);
                }
            }

            objWrapper.searchResult = searchResult;

            System.debug('결과 => ' + searchResult);

            objWrapper.listSearchResult = listSearchResult;
            objWrapper.totalCnt = listSearchResultSize;

        } catch(Exception e) {
            strStatus = 'ERROR';
            strMessage = e.getMessage() + ' Line : '+e.getLineNumber();
        }

        objWrapper.strStatus = strStatus;
        objWrapper.strMessage = strMessage;

        return objWrapper;
        
    }

   public class ConatactDataWrapper { 
        //판매처에서 가져오는 기본정보
        @AuraEnabled public String Id{get;set;}                   // 고객명(영문명포함                 
        @AuraEnabled public String Name{get;set;}                   // 고객명(영문명포함                 
        @AuraEnabled public String Email{get;set;}                   // 고객약칭명(변경
        @AuraEnabled public String MobilePhone{get;set;}                // 고객유형
        @AuraEnabled public String Department{get;set;}                   // 법적상태
        @AuraEnabled public String PV_PAFKT_VK{get;set;}               // 업종
        @AuraEnabled public String PV_KNVKGB{get;set;}                   // 세금계산서발행유형
        @AuraEnabled public String PV_TALKT_VK{get;set;}           // 우편번호


        public ConatactDataWrapper(){}
        public ConatactDataWrapper(Contact con) {
            
            this.Id                                   = con.Id;                                               
            this.Name                                 = con.LastName;                                               
            this.Email                                = con.Email;                                                   
            this.MobilePhone                          = con.MobilePhone;                                                       
            this.Department                           = con.Department;                                                   
            this.PV_PAFKT_VK                          = con.PV_PAFKT_VK__c;                                                       
            this.PV_KNVKGB                            = con.PV_KNVKGB__c;                                                   
            this.PV_TALKT_VK                          = con.PV_TALKT_VK__c;                                                           
        }
    }

    
    /**
     * @description 로딩시 뿌려줘야할 데이터 Wrapper
     */
    public class DataWrapper {
        /** @description 반환성공을 알려주는 Status*/
        @AuraEnabled public String strStatus {get;set;}
        /** @description 에러메세지*/
        @AuraEnabled public String strMessage {get;set;}
        /** @description 레코드아이디를 통해 알아낸 ObjectName*/
        @AuraEnabled public String strObjectType {get;set;}
         /** @description */
        @AuraEnabled public String MDMRecordTypeId {get;set;}
        /** @description */
        @AuraEnabled public List<Map<String,  String>> listCustomerOrderType {get;set;}
        /** @description */
        @AuraEnabled public User objUser {get;set;}
        /** @description */
        @AuraEnabled public Opportunity objOpportunity {get;set;}
        /** @description */
        @AuraEnabled public MDMRegRequestCustomer__c objMDMRegReqCustomer {get;set;}
        /** @description */
        @AuraEnabled public List<MDMRegRequestContact__c> listMDMReqContact {get;set;}
        @AuraEnabled
        public List<Contact> searchResult {get;set;}
        @AuraEnabled
        public List<Contact> listSearchResult {get;set;}
        @AuraEnabled
        public Integer totalCnt {get;set;}

        public DataWrapper() {}
    }

}