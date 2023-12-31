/**
* 알림 데이터 생성 및 전송 기능
*
*@group  Notificatoin
*@author 진현욱
*@since 2023-07-24  최초 작성
*/
public virtual without sharing class CJFW_NotiHandler {
    
    public static Map<String,User> allUserMap;

    protected Map<String,String> categoryMapping = new Map<String, String>{
        'App' => 'CJFW_AppTemplate'
        ,'Email' => 'CJFW_EmailTemplate'
    }; //Mapping Object 설정으로 뺼지 고려필요

    protected Map<String,String> categoryAlertMapping = new Map<String, String>{
        'App' => 'CJFW_AppAlert'
        ,'Email' => 'CJFW_NotiAlert'
    }; //Mapping Object 설정으로 뺼지 고려필요

    protected CJFW_Notification__c noti;
    /*데이터 형식
        {
            'App' : { 
                    'ko':CJFW_AppTemplate
                    ,'en_US':CJFW_AppTemplate
            }
            ,'Email': [CJFW_NotiTemplate]
        }
    */
    protected Map<String, Map<String,CJFW_NotiTemplate>> categoryTemplateMapMap;
    /*데이터 형식
        {
            
            'App':[CJFW_AppTemplate]
            ,'Eamil':[CJFW_NotiTemplate]
            
        }
    */
    protected Map<String, List<CJFW_NotiTemplate>> categorySendDataListMap;
    protected Set<Id> recipientIdSet;
    protected Map<String, String> customNotiTypeIdMap;

    public CJFW_NotiHandler() {

    }

    /**
    * Noti Master Data 설정
    *
    *@param  noti 
    */
    public void setNotiData(CJFW_Notification__c noti) {
        this.noti = noti;
        
        this.categoryTemplateMapMap = new Map<String, Map<String,CJFW_NotiTemplate>>();
        this.categorySendDataListMap = new Map<String, List<CJFW_NotiTemplate>>();
        this.recipientIdSet = new Set<Id>();
        this.customNotiTypeIdMap = new Map<String, String>();
        for(CustomNotificationType customNoti :[
            select
                Id
                ,DeveloperName    
            from CustomNotificationType 
        ]) {
            this.customNotiTypeIdMap.put(customNoti.DeveloperName, customNoti.Id);
        }

        if(allUserMap == null) allUserMap = new Map<String,User>();
        if(allUserMap.isEmpty()) {

            String userFields = 'Id,Email'; //설정으로 해당 정보 수정하게끔?

            List<String> fieldList = userFields.split(',');
            System.debug(fieldList);
    
            for(User u : database.query('select '+userFields+ ',LanguageLocaleKey' +' from User where IsActive = true')) {
                for(String field : fieldList) {
                    allUserMap.put(String.valueOf(u.get(field)), u);
                }
            }
        }
    }

    /**
    * Category: APP,Email 등.. Template 정보 가져오기
    *
    *@return  Map<String, List<CJFW_NotiTemplate>> Category 별 템플릿
    */
    protected Map<String, Map<String,CJFW_NotiTemplate>> getTemplate() {
        for(CJFW_NotificationTemplate__c template : noti.Notification_Template__r) {
            CJFW_NotiTemplate notiTemplate;
            switch on template.RecordType.DeveloperName {
                when 'App'{
                    notiTemplate = new CJFW_AppTemplate();
                    notiTemplate.setMessage(template.Message__c);
                    notiTemplate.setTitle(template.Title__c);
                    notiTemplate.setLang(template.Language__c);
                    notiTemplate.setTemplateId(this.customNotiTypeIdMap.get(noti.CustomNotificationTypeId__c));
                    ((CJFW_AppTemplate)notiTemplate).setPageReference(noti.PageReference__c);
                }
                when 'Email'{
                    //TBD Email Template 복사 구현 필요
                }
                //Category(알림 보낼 방법) 추가 될 때마다 when 문 추가 필요
                // when else {
                    
                // }
            }
            String category = notiTemplate.getCategory();
            
            //같은 언어의 템플릿은 중복 될 수 가 없음
            if(categoryTemplateMapMap.containsKey(category)) {
                categoryTemplateMapMap.get(category).put(notiTemplate.getLang() , notiTemplate);
            }else {
                Map<String,CJFW_NotiTemplate> langTemplateMap = (Map<String,CJFW_NotiTemplate>)Type.forName('Map<String,'+getMappingClass('',category)+'>').newInstance();
                langTemplateMap.put(notiTemplate.getLang(), notiTemplate);
                categoryTemplateMapMap.put(category, langTemplateMap);
            }
            
        }

        return categoryTemplateMapMap;
    }

    /**
    * CJFW_NotificationTarget__c 에서 관리하고 있는 수신자로 등록
    *
    */
    protected Set<Id> getRicipientIdSet() {
        Map<String, Schema.RecordTypeInfo> includedRecordTypeMap = Schema.SObjectType.CJFW_NotificationTarget__c.getRecordTypeInfosByDeveloperName();

        Map<String, Set<Id>> userTypeMap = new Map<String, Set<Id>>{
            'Group' => new Set<Id>(),
            'Role' => new Set<Id>()
        };

        // Record type 별 Id 할당
        for(CJFW_NotificationTarget__c tg : noti.Notification_Target__r) {
            if(tg.RecordTypeId == includedRecordTypeMap.get('User').getRecordTypeId()) recipientIdSet.add(tg.User__c);
            else if(tg.RecordTypeId == includedRecordTypeMap.get('Group').getRecordTypeId()) userTypeMap.get('Group').add(tg.GroupId__c);
            else if(tg.RecordTypeId == includedRecordTypeMap.get('Role').getRecordTypeId()) userTypeMap.get('Role').add(tg.RoleId__c);
        }

        // Record type이 Group인 경우
        if(!userTypeMap.get('Group').isEmpty()) {
            CollaborationGroupMember[] groupMembers = [SELECT MemberId FROM CollaborationGroupMember  WHERE CollaborationGroupId IN :(userTypeMap.get('Group'))];
            for(CollaborationGroupMember member : groupMembers){
                recipientIdSet.add(member.MemberId);
            }
        }

        // Record type이 Role인 경우
        if(!userTypeMap.get('Role').isEmpty()) {
            User[] users = [SELECT Id FROM User WHERE IsActive = true AND UserRoleId IN :(userTypeMap.get('Role'))];
            for(User user : users){
                recipientIdSet.add(user.Id);
            }
        }

        

        return recipientIdSet;
    }

    /**
    * 형변환할 Category 별 알림 템플릿 class 정보 반환
    *
    *@param  collectionType List, Set CollectionType
    *@param  category App, Email
    *@return  형변환할 ClassName
    */
    protected String getMappingClass(String collectionType, String category) {
        String className = categoryMapping.get(category);

        switch on collectionType {
            when  'List'{
                className = 'List<'+className+'>';
            }
            when 'Set' {
                className = 'Set<'+className+'>';
            }
        }
        
        return className;
    }


    /**
    * Category(App, Email..등)별 알림 보낼 Map 에 저장
    *
    *@param  categorySendDataListMap 보낼 알림 Map
    *@param  category  App, Email 등..
    *@param  notiTemplate  Map 담을 Template 정보
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    protected void setCategorySendDataListMap(Map<String, List<CJFW_NotiTemplate>> categorySendDataListMap, String category, CJFW_NotiTemplate notiTemplate) {
        if(categorySendDataListMap.containsKey(category)) {
            categorySendDataListMap.get(category).add(notiTemplate);
        }else {
            List<CJFW_NotiTemplate> templateList = (List<CJFW_NotiTemplate>)Type.forName(getMappingClass('List',category)).newInstance();
            templateList.add(notiTemplate);
            categorySendDataListMap.put(category, templateList);
        }
    }                

    /**
    * 수신자와 발신자 동일할 IsSendToSender__c 필드값에 따라 제외
    *
    */
    protected void setExcludeRecipient() {
        // 발신자, 수신자가 동일한 경우 false: 제외
        if(!noti.IsSendToSender__c && recipientIdSet.contains(UserInfo.getUserId())) recipientIdSet.remove(UserInfo.getUserId());
    }

    /**
    * 기본적으로 Category 별 템플릿으로 실제 알림 보낼 데이터로 변환 
    *
    *@param  targetIdSet 알림 내용을 만드는 데이터 Id
    *@param  recipientMap 레코드 데이터가 아닌 코드에서 추가하는 수신자 Map
    */
    public virtual void manuFactureNoti(Set<String> targetIdSet, Map<String,List<User>> recipientListMap) {
        getTemplate();
        getRicipientIdSet();

        if(recipientListMap != null) {
            for(User u : recipientListMap.get('Id')) {
                this.recipientIdSet.add(u.Id);
            }
        }
        /*
         TBD 이메일만 있을경우 어떻게 처리할지 생각
        */

        setExcludeRecipient();

        String query = 'SELECT ' + noti.TargetFields__c + ' FROM ' + noti.SObject__c + ' WHERE Id IN :targetIdSet ';
        
        List<sObject> datas;
        if(!targetIdSet.isEmpty()) datas = Database.query(query);

        makePersonalize(datas);

        for(String category : categorySendDataListMap.keySet()) {
            CJFW_NotiAlert alertHandler = (CJFW_NotiAlert)Type.forName(categoryAlertMapping.get(category)).newInstance();
            alertHandler.send(categorySendDataListMap.get(category));
        }
    }

    /**
    * 기본적으로 Category 별 템플릿으로 실제 알림 보낼 데이터로 변환
    *
    *@param  targetIdSet 알림 내용을 만드는 데이터 Id
    *@param  recipientMap 레코드 데이터가 아닌 코드에서 추가하는 수신자 Map
    */
    public virtual void manuFactureNoti(List<sObject> targetObjectList, Map<String,User> recipientMap) {
        getTemplate();
        getRicipientIdSet();
        
        setExcludeRecipient();

        makePersonalize(targetObjectList);

        for(String category : categorySendDataListMap.keySet()) {
            CJFW_NotiAlert alertHandler = (CJFW_NotiAlert)Type.forName(categoryAlertMapping.get(category)).newInstance();
            alertHandler.send(categorySendDataListMap.get(category));
        }
    }

    /**
    * 데이터 기준으로 사용자 알림 템플릿 언어별 개인화 // 기본 언어 ko
    *
    *@param  datas 
    */
    protected void makePersonalize(List<sObject> datas) {
        // Field api name : value 매핑
        List<String> targetFields = noti.TargetFields__c.replaceAll(' ','').replaceFirst('(?i)ToLabel','').replace('(','').replace(')','').split(',');

        for(sObject datum : datas) {
            Map<String, String> fieldsMap = new Map<String, String>();

            for(String field : targetFields) {
                String value = '';
                List<String> relatedFieldList = field.split('\\.');

                if(relatedFieldList.size() > 1) value = getFieldValue(relatedFieldList, datum);
                else value = String.valueOf(datum.get(field));

                fieldsMap.put(field, value);
            }

            if(categoryTemplateMapMap.containsKey('App')) {
                Map<String,CJFW_AppTemplate> langTemplateMap = (Map<String,CJFW_AppTemplate>)categoryTemplateMapMap.get('App');
                
                for(String recipientId : this.recipientIdSet) {
                    User recipient = allUserMap.get(recipientId);
                    if(recipient == null) continue;
                    CJFW_AppTemplate template = langTemplateMap.get(recipient.LanguageLocaleKey);
                    CJFW_AppTemplate cloneTemplateData = template == null ? (CJFW_AppTemplate) langTemplateMap.get('ko').cloneTemplate() : (CJFW_AppTemplate) langTemplateMap.get(recipient.LanguageLocaleKey).cloneTemplate();
                    cloneTemplateData.setTitle(setMessage(fieldsMap, cloneTemplateData.getTitle()));
                    cloneTemplateData.setMessage(setMessage(fieldsMap, cloneTemplateData.getMessage()));
                    cloneTemplateData.setToAddresses(new Set<String>{recipientId});
                    cloneTemplateData.setTargetId(String.valueOf(datum.get('Id')));
                    setCategorySendDataListMap(categorySendDataListMap ,cloneTemplateData.getCategory(), cloneTemplateData);
                }
                
            }
    
            if(categoryTemplateMapMap.containsKey('Email')) {
    
            }

        }
    }


    /**
     * Lookup Dynamic 조회 값 추출
     * @param relatedFieldList 
     * @param datas 
     * @return  `String`
     */
    public String getFieldValue(List<String> relatedFieldList, sObject datas){
        //SObject Type일 경우 __r 이 사라짐
        Map<String, Object> dataMap = (Map<String, Object>)Json.deserializeUntyped(Json.serialize(datas));
        //System.debug('dataMap : ' + Json.serialize(datas));
        //System.debug('relatedFieldList : ' + relatedFieldList);
        Object tempObj;
        Map<String,Object> tempMap;
        tempObj = dataMap.get(relatedFieldList[0]);
        
        Integer cnt = 0;
        for(String str : relatedFieldList){
            if(cnt== 0){
                ++cnt;
                continue;
            }
            tempMap = (Map<String,Object>)tempObj;
            
            if(tempMap == null) return '';
            
            tempObj = tempMap.get(str);
            ++cnt;
        }
        
        System.debug('tempObj : ' + String.valueOf(tempObj));
        return String.valueOf(tempObj);
    }

    /**
     * Noti 발송을 위한 Message 가공
     * @param datafieldsMap field : value 로 이루어진 Map
     * @param msg 
     * @return `String`
     */
    public String setMessage(Map<String, String> datafieldsMap, String msg){
        Pattern pattern = Pattern.compile('\\{[0-9]\\}');
        Matcher matcher = pattern.matcher(msg);
        
        if(matcher.find()){
            List<String> fields = new List<String>();
            fields.addAll(datafieldsMap.values());
            return String.format(
                msg
                ,fields
            );
        }else{
            return msg;
        }
    }

}