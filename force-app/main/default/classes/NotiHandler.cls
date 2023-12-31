/**
* 알림 데이터 생성 및 전송 기능
*
*@group  Notificatoin
*@author 진현욱
*@since 2023-07-24  최초 작성
*/
public virtual without sharing class NotiHandler {
    
    public static Map<String,User> allUserMap;          //전체 Active 유저 soql query 호출 수 줄이기 위해

    protected NotiClassManagement__mdt managementData;

    @testVisible protected Notification__c noti;
    /*데이터 형식
        {
            'App' : { 
                    'ko':AppTemplate
                    ,'en_US':AppTemplate
            }
            ,'Email': { 
                    'ko':NotiEmailTemplate
                    ,'en_US':NotiEmailTemplate
            }
        }
    */
    @testVisible protected Map<String, Map<String,NotiTemplate>> categoryTemplateMapMap;
    /*데이터 형식
        {
            
            'App':[AppTemplate]
            ,'Eamil':[NotiEmailTemplate]
            
        }
    */
    @testVisible protected Map<String, List<NotiTemplate>> categorySendDataListMap;
    @testVisible protected Set<String> recipientIdSet;
    public static Map<String, String> customNotiTypeIdMap;

    public NotiHandler() {

    }

    /**
    * Noti Master Data 설정
    *
    *@param  noti 
    */
    public void setNotiData(Notification__c noti) {
        this.noti = noti;
        managementData = NotiClassManagement__mdt.getInstance(noti.RecordType.DeveloperName);
        this.categoryTemplateMapMap = new Map<String, Map<String,NotiTemplate>>();
        this.categorySendDataListMap = new Map<String, List<NotiTemplate>>();
        this.recipientIdSet = new Set<String>();
        if(customNotiTypeIdMap == null) customNotiTypeIdMap = new Map<String, String>();
        if(customNotiTypeIdMap.isEmpty()) {
            for(CustomNotificationType customNoti :[
                select
                    Id
                    ,DeveloperName    
                from CustomNotificationType 
            ]) {
                customNotiTypeIdMap.put(customNoti.DeveloperName, customNoti.Id);
            }
        }

        if(allUserMap == null) allUserMap = new Map<String,User>();
        if(allUserMap.isEmpty()) {

            String userFields = 'Id,Email'; //설정으로 해당 정보 수정하게끔?

            List<String> fieldList = userFields.split(',');
            //System.debug(fieldList);
    
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
    *@return  Map<String, List<NotiTemplate>> Category 별 템플릿
    */
    @testVisible protected Map<String, Map<String,NotiTemplate>> getTemplate() {
        for(NotificationTemplate__c template : noti.Notification_Template__r) {
            NotiTemplate notiTemplate;
            switch on template.RecordType.DeveloperName {
                when 'App'{
                    notiTemplate = new AppTemplate();
                    notiTemplate.setBody(template.Message__c);
                    notiTemplate.setTitle(template.Title__c);
                    notiTemplate.setLang(template.Language__c);
                    notiTemplate.setTemplateId(customNotiTypeIdMap.get(noti.CustomNotificationTypeId__c));
                    ((AppTemplate)notiTemplate).setPageReference(noti.PageReference__c);
                }
                when 'Email'{
                    notiTemplate = new NotiEmailTemplate();
                    notiTemplate.setLang(template.Language__c);
                    notiTemplate.setTemplateId(template.EmailDeveloperName__c);
                    if(noti.IsDynamic__c) ((NotiEmailTemplate)notiTemplate).setIsCustom(noti.IsDynamic__c);
                    ((NotiEmailTemplate)notiTemplate).setIsSystem(noti.IsSystemEmail__c);
                    ((NotiEmailTemplate)notiTemplate).setIsUseOWE(noti.IsUseOWE__c);
                    ((NotiEmailTemplate)notiTemplate).setIsSaveAsActivity(noti.IsSaveAsActivity__c);
                }
                //TBD Category(알림 보낼 방법) 추가 될 때마다 when 문 추가 필요
                // when 'Category' {                    
                // }
            }
            String category = notiTemplate.getCategory();
            
            //같은 언어의 템플릿은 중복 될 수 가 없기 때문에
            if(categoryTemplateMapMap.containsKey(category)) {
                categoryTemplateMapMap.get(category).put(notiTemplate.getLang() , notiTemplate);
            }else {
                Map<String,NotiTemplate> langTemplateMap = (Map<String,NotiTemplate>)Type.forName('Map<String,'+getMappingClass('',category)+'>').newInstance();
                langTemplateMap.put(notiTemplate.getLang(), notiTemplate);
                categoryTemplateMapMap.put(category, langTemplateMap);
            }
            
        }

        return categoryTemplateMapMap;
    }

    /**
    * NotificationTarget__c 에서 관리하고 있는 수신자로 등록
    *
    *@return  Set<String> NotiTargetObject 에 저장된 수신자 Id Set
    */
    @testVisible protected Set<String> getRecipientIdSet() {
        Map<String, Schema.RecordTypeInfo> includedRecordTypeMap = Schema.SObjectType.NotificationTarget__c.getRecordTypeInfosByDeveloperName();

        Map<String, Set<String>> userTypeMap = new Map<String, Set<String>>{
            'Group' => new Set<String>(),
            'Role' => new Set<String>()
        };

        // Record type 별 Id 할당
        for(NotificationTarget__c tg : noti.Notification_Target__r) {
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
    *@return  String 형변환할 ClassName
    */
    @testVisible protected String getMappingClass(String collectionType, String category) {
        String className = managementData.TemplateClass__c;

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
    */
    @testVisible protected void setCategorySendDataListMap(Map<String, List<NotiTemplate>> categorySendDataListMap, String category, NotiTemplate notiTemplate) {
        if(categorySendDataListMap.containsKey(category)) {
            categorySendDataListMap.get(category).add(notiTemplate);
        }else {
            List<NotiTemplate> templateList = (List<NotiTemplate>)Type.forName(getMappingClass('List',category)).newInstance();
            templateList.add(notiTemplate);
            categorySendDataListMap.put(category, templateList);
        }
    }                

    /**
    * 수신자와 발신자 동일할 IsSendToSender__c 필드값에 따라 제외
    *
    */
    @testVisible protected void setExcludeRecipient() {
        // 발신자, 수신자가 동일한 경우 false: 제외
        if(!noti.IsSendToSender__c && recipientIdSet.contains(UserInfo.getUserId())) recipientIdSet.remove(UserInfo.getUserId());
    }


    /**
    * 알림 템플릿 개인화시에 필요한 레코드 정보(Id Set or Record List or Object)
    *
    *@param  targetIdSet 개인화할 레코드 데이터 Id Set
    *@param  targetSObjectList 개인화할 레코드 데이터 List
    *@param  targetObject 개인화할 Object
    */
    public void execute(Set<String> targetIdSet, List<sObject> targetSObjectList, Object targetObject) {
        getTemplate();
        getRecipientIdSet();

        setExcludeRecipient();

        
        if(targetIdSet != null && !targetIdSet.isEmpty()) manuFactureNoti(targetIdSet);
        else if(targetSObjectList != null && !targetSObjectList.isEmpty()) manuFactureNoti(targetSObjectList); 
        else if(targetObject != null) manuFactureNoti(targetObject);
        
        sendHandler();
    }

    /**
    * 발송 처리
    *
    */
    @testVisible protected void sendHandler() {
        String category = noti.RecordType.DeveloperName;
        CJFW_ModuleSetting__c setting = CJFW_ModuleSetting__c.getInstance();
        if(noti.IsNotiTest__c && setting.getPopulatedFieldsAsMap().containsKey('IsNotiTest__c') && setting.IsNotiTest__c) {
            //TBD Test 일때 이력만 생성
            IFLog__c objLog = new IFLog__c();
            objLog.Status__c = 'SUCCESS';
            String resultDataStr = 'Noti Test : \n' + JSON.serialize(categorySendDataListMap.get(category));
            objLog.ResultMessage__c = resultDataStr <> null && resultDataStr.length() > 130000 ? resultDataStr.substring(0,130000) : resultDataStr;
            
            NotificationManager.saveHistory(new List<IFLog__c>{objLog});

        }else {
            NotiAlert alertHandler = (NotiAlert)Type.forName(managementData.AlertClass__c).newInstance();
            //System.debug('categorySendDataListMap:: ' +JSON.serialize(categorySendDataListMap));
            if(!categorySendDataListMap.isEmpty()) alertHandler.send(categorySendDataListMap.get(category));
        }
    }

    /**
    * Id 집합으로 Category 별 템플릿 개인화를 위해 데이터 불러오는 메소드 
    * override 시 Map<String, List<NotiTemplate>> categorySendDataListMap 값 저장 필수
    *@param  targetIdSet 알림 내용을 만드는 데이터 sObject Id Set
    */
    public virtual void manuFactureNoti(Set<String> targetIdSet) {
        
        String query = 'SELECT ' + noti.TargetFields__c + ' FROM ' + noti.SObject__c + ' WHERE Id IN :targetIdSet ';
        
        List<sObject> datas;
        if(!targetIdSet.isEmpty()) datas = Database.query(query);

        makePersonalize(datas);
    }

    /**
    * sObject List로 Category 별 템플릿 개인화 하기위한 메소드
    * override 시 Map<String, List<NotiTemplate>> categorySendDataListMap 값 저장 필수
    *@param  targetSObjectList 알림 내용을 만드는 sObject 데이터 리스트
    */
    public virtual void manuFactureNoti(List<sObject> targetSObjectList) {
        makePersonalize(targetSObjectList);
    }

    /**
    * Object로 Category 별 템플릿 개인화 하기 위해 확장 클래스(자식)에서 필수적으로 구현이 필요함 
    * override 시 Map<String, List<NotiTemplate>> categorySendDataListMap 값 저장 필수
    *@param  targetObject 알림 내용을 만드는 Object 데이터
    */
    public virtual void manuFactureNoti(Object targetObject) {
        
    }

    /**
    * Email Template 개인화 공통 로직
    * 수신자 및 송신할 데이터 저장
    *
    *@param  langTemplateMap 언어별 Template Master Map
    *@param  fieldsMap 개인화시 필요한 key: fieldApi, value: fieldValue
    *@param  targetId 개인화시에 필요한 SingleEmailMessage WhatId
    *@param  lang 수신자 언어
    *@param  toAddresses 수신자
    *@param  ccAddresses 참조
    *@param  bccAddresses 숨은참조
    *@param  attachmentIds 첨부파일 Id Set
    *@param  isTargetObjectId 수신자 setTargetObjectId로 설정여부
    */
    @testVisible protected void setEmailPersonalize(Map<String,NotiEmailTemplate> langTemplateMap, Map<String, String> fieldsMap, String targetId, String lang, Set<String> toAddresses, Set<String> ccAddresses, Set<String> bccAddresses, Set<String> attachmentIds, Boolean isTargetObjectId) {
        NotiEmailTemplate template = langTemplateMap.get(lang);
        NotiEmailTemplate cloneTemplateData = template == null ? (NotiEmailTemplate) langTemplateMap.get('ko').cloneTemplate() : (NotiEmailTemplate) langTemplateMap.get(lang).cloneTemplate();
        cloneTemplateData.setFieldsMap(fieldsMap);
        cloneTemplateData.setToAddresses(toAddresses);
        cloneTemplateData.setCcAddresses(ccAddresses);
        cloneTemplateData.setBccAddresses(bccAddresses);
        cloneTemplateData.setTargetId(targetId);
        cloneTemplateData.setAttachmentIds(attachmentIds);
        cloneTemplateData.setIsTargetObjectId(isTargetObjectId);
        setCategorySendDataListMap(categorySendDataListMap ,cloneTemplateData.getCategory(), cloneTemplateData);
    }

    /**
    * 데이터 기준으로 사용자 알림 템플릿 언어별 개인화 // 기본 언어 ko
    *
    *@param  datas 
    */
    @testVisible protected void makePersonalize(List<sObject> datas) {
        // Field api name : value 매핑 
        // TBD 만약 다언어 추가 될 경우 toLabel 은 현재 사용자 기준이라 PickList value 번역 해주는 기능 추가 
        List<String> targetFields = noti.TargetFields__c.replaceAll(' ','').replaceFirst('(?i)ToLabel','').replace('(','').replace(')','').split(',');

        Map<String,List<NotiTarget>> recipientListMap = NotificationManager.getInstance().getRecipientListMap(); 

        for(sObject datum : datas) {
            Map<String, String> fieldsMap = new Map<String, String>();
            String targetId = String.valueOf(datum.get('Id'));
            for(String field : targetFields) {
                String value = '';
                List<String> relatedFieldList = field.split('\\.');

                if(relatedFieldList.size() > 1) value = getFieldValue(relatedFieldList, datum);
                else value = String.valueOf(datum.get(field));

                fieldsMap.put(field, value);
            }
            Set<String> tmpRecipientIdSet = new Set<String>(this.recipientIdSet);
            List<NotiTarget> recipientList = recipientListMap.get(targetId);
            if(recipientList == null) continue;

            if(categoryTemplateMapMap.containsKey('App')) {
                for(NotiTarget recipient : recipientList) {
                    if('id'.equals(recipient.getType())) tmpRecipientIdSet.addAll(recipient.getToAddresses());
                }

                Map<String,AppTemplate> langTemplateMap = (Map<String,AppTemplate>)categoryTemplateMapMap.get('App');
                if(langTemplateMap.isEmpty()) continue;

                for(String recipientId : tmpRecipientIdSet) {
                    User recipient = allUserMap.get(recipientId);
                    if(recipient == null) continue;
                    AppTemplate template = langTemplateMap.get(recipient.LanguageLocaleKey);
                    AppTemplate cloneTemplateData = template == null ? (AppTemplate) langTemplateMap.get('ko').cloneTemplate() : (AppTemplate) langTemplateMap.get(recipient.LanguageLocaleKey).cloneTemplate();
                    cloneTemplateData.setFieldsMap(fieldsMap);
                    cloneTemplateData.setTitle(cloneTemplateData.setMessage(cloneTemplateData.getTitle()));
                    cloneTemplateData.setBody(cloneTemplateData.setMessage(cloneTemplateData.getBody()));
                    cloneTemplateData.setToAddresses(new Set<String>{recipientId});
                    cloneTemplateData.setTargetId(targetId);
                    setCategorySendDataListMap(categorySendDataListMap ,cloneTemplateData.getCategory(), cloneTemplateData);
                }
                
            }
    
            if(categoryTemplateMapMap.containsKey('Email')) {
                Map<String,NotiEmailTemplate> langTemplateMap = (Map<String,NotiEmailTemplate>)categoryTemplateMapMap.get('Email');
                if(langTemplateMap.isEmpty()) continue;

                for(NotiTarget recipient : recipientList) {
                    if(recipient.getToAddresses().size() > 1) {
                        setEmailPersonalize(
                            langTemplateMap
                            , fieldsMap
                            , targetId
                            , recipient.getLang()
                            , recipient.getToAddresses()
                            , recipient.getCcAddresses()
                            , recipient.getBccAddresses()
                            , recipient.getAttachmentIds()
                            , false
                        );
                        
                    }else {
                        //수신자 1건 일때 
                        if('id'.equals(recipient.getType())) {
                            if(recipient.getToAddresses().size() == 1) {
                                //size가 1이라 List 로 변환해서 첫번째 데이터 꺼내오기
                                List<String> tmpToAddressList = new List<String>(recipient.getToAddresses());
                            
                                User user = allUserMap.get(tmpToAddressList.get(0));
                                if(user == null) continue;
                                setEmailPersonalize(
                                    langTemplateMap
                                    , fieldsMap
                                    , targetId
                                    , user.LanguageLocaleKey
                                    , recipient.getToAddresses()
                                    , recipient.getCcAddresses()
                                    , recipient.getBccAddresses()
                                    , recipient.getAttachmentIds()
                                    , this.noti.IsTargetObjectId__c
                                );
                                
                            }
    
                        }else if('email'.equals(recipient.getType())) {
                            if(recipient.getToAddresses().size() == 1) {
                                //size가 1이라 List 로 변환해서 첫번째 데이터 꺼내오기
                                List<String> tmpToAddressList = new List<String>(recipient.getToAddresses());
                            
                                User user = allUserMap.get(tmpToAddressList.get(0));
                                //비회원일 경우 
                                if(user == null) user = new User(LanguageLocaleKey=recipient.getLang());
                                setEmailPersonalize(
                                    langTemplateMap
                                    , fieldsMap
                                    , targetId
                                    , user.LanguageLocaleKey
                                    , recipient.getToAddresses()
                                    , recipient.getCcAddresses()
                                    , recipient.getBccAddresses()
                                    , recipient.getAttachmentIds()
                                    , false
                                );
                            }
                        }
                    }
                }
                
                //Record에 추가된 수신자
                for(String recipientId : tmpRecipientIdSet) {
                    User user = allUserMap.get(recipientId);
                    if(user == null) continue;
                    setEmailPersonalize(
                        langTemplateMap
                        , fieldsMap
                        , targetId
                        , user.LanguageLocaleKey
                        , new Set<String>{user.Id}
                        , null
                        , null
                        , null
                        , false
                    );
                }
            }

            //TBD 다른 카테고리 추가시

        }
    }


    /**
     * Lookup Dynamic 조회 값 추출
     * @param relatedFieldList 
     * @param datas 
     * @return  `String`
     */
    @testVisible protected String getFieldValue(List<String> relatedFieldList, sObject datas){
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
        
        //System.debug('tempObj : ' + String.valueOf(tempObj));
        return String.valueOf(tempObj);
    }

}