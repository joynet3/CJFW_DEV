/**
* 알림 데이터 생성 및 전송 기능
*
*@group  Notificatoin
*@author 진현욱
*@since 2023-07-24  최초 작성
*/
public virtual without sharing class CJFW_NotiHandler {
    
    private Map<String,String> categoryMapping = new Map<String, String>{
        'App' => 'CJFW_AppTemplate'
        ,'Email' => 'CJFW_NotiTemplate'
    }; //Mapping Object 설정으로 뺼지 고려필요
    protected CJFW_Notification__c noti;
    /*데이터 형식
        {
            'App' : [CJFW_AppTemplate]
            ,'Email': [CJFW_NotiTemplate]
        }
    */
    protected Map<String, List<CJFW_NotiTemplate>> categoryTemplateListMap;


    private static Map<String,User> allUserMap;
    private Set<Id> recipientIdSet;


    public CJFW_NotiHandler(CJFW_Notification__c noti) {
        this.noti = noti;
        this.categoryTemplateListMap = new Map<String, List<CJFW_NotiTemplate>>();
        this.recipientIdSet = new Set<Id>();

        if(allUserMap == null) allUserMap = new Map<String,User>();
        if(allUserMap.isEmpty()) {

            String userFields = 'Id,Email'; //설정으로 해당 정보 수정하게끔?

            List<String> fieldList = userFields.split(',');
            System.debug(fieldList);
    
            for(User u : database.query('select '+userFields+ ',LanguageLocaleKey' +' from User where IsActive = true')) {
                for(String field : fieldList) {
                    allUserMap.put(field, u);
                }
            }
        }
    }

    /**
    * Category: APP,Email 등.. Template 정보 가져오기
    *
    *@return  Map<String, List<CJFW_NotiTemplate>> Category 별 템플릿
    */
    private Map<String, List<CJFW_NotiTemplate>> getTemplate() {
        for(CJFW_NotificationTemplate__c template : noti.Notification_Template__r) {
            CJFW_AppTemplate notiTemplate;
            switch on template.RecordType.DeveloperName {
                when 'App'{
                    notiTemplate = new CJFW_AppTemplate();
                    notiTemplate.setMessage(template.Message__c);
                    notiTemplate.setTitle(template.Title__c);
                }
                when 'Email'{

                }
                //Category(알림 보낼 방법) 추가 될 때마다 when 문 추가 필요
                // when else {
                    
                // }
            }
            String category = notiTemplate.getCategory();
            if(categoryTemplateListMap.containsKey(category)) {
                categoryTemplateListMap.get(category).add(notiTemplate);
            }else {
                List<CJFW_NotiTemplate> templateList = (List<CJFW_NotiTemplate>)Type.forName('List<'+categoryMapping.get(category)+'>').newInstance();
                templateList.add(notiTemplate);
                categoryTemplateListMap.put(category, templateList);
            }
            
        }

        return categoryTemplateListMap;
    }

    private Set<Id> getRicipientIdSet() {
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

        // 발신자, 수신자가 동일한 경우 false: 제외
        if(!noti.IsSendToSender__c && recipientIdSet.contains(UserInfo.getUserId())) recipientIdSet.remove(UserInfo.getUserId());

        return recipientIdSet;
    }

    /**
    * 기본적으로 Category 별 템플릿으로 실제 알림 보낼 데이터로 변환 
    *
    *@param  targetIdSet 알림 내용을 만드는 데이터 Id
    *@param  recipientMap 레코드 데이터가 아닌 코드에서 추가하는 수신자 Map
    */
    public virtual void manuFactureNoti(Set<String> targetIdSet, Map<String,User> recipientMap) {
        getTemplate();
        getRicipientIdSet();

        
        if(categoryTemplateListMap.containsKey('App')) {
            for(CJFW_NotiTemplate appTemplate :  categoryTemplateListMap.get('App')) {
                CJFW_AppTemplate cloneTemplateData = (CJFW_AppTemplate) appTemplate.cloneTemplate();
            }

        }

        if(categoryTemplateListMap.containsKey('Email')) {

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
        
    }

    /**
     * Lookup Dynamic 조회 값 추출
     * @param relatedFieldList 
     * @param datas 
     * @return  `String`
     */
    public static String getFieldValue(List<String> relatedFieldList, sObject datas){
        //SObject Type일 경우 __r 이 사라짐
        Map<String, Object> dataMap = (Map<String, Object>)Json.deserializeUntyped(Json.serialize(datas));
        System.debug('dataMap : ' + Json.serialize(datas));
        System.debug('relatedFieldList : ' + relatedFieldList);
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

}