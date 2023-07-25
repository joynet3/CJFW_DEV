/**
* 전체 Trigger Handler On/Off 설정
*
*@group  Trigger
*@author 진현욱
*@since 2023-07-24  생성
*/
public with sharing class CJFW_TriggerSetting {
    private static CJFW_TriggerSetting instance;
    
    private Map<String, Boolean> trActiveMap;

    private CJFW_TriggerSetting() {
        trActiveMap = new Map<String, Boolean>();

        CJFW_TriggerSetting__c userTS = CJFW_TriggerSetting__c.getValues(UserInfo.getUserId());
        CJFW_TriggerSetting__c profileTS = CJFW_TriggerSetting__c.getValues(UserInfo.getProfileId());
        CJFW_TriggerSetting__c orgTS = CJFW_TriggerSetting__c.getOrgDefaults();
        
        if(userTS != null) trActiveMap.put('user', userTS.IsActive__c);
        if(profileTS != null) trActiveMap.put('profile', profileTS.IsActive__c);
        if(orgTS.getPopulatedFieldsAsMap().containsKey('IsActive__c')) trActiveMap.put('org', orgTS.IsActive__c);
    }

    public static CJFW_TriggerSetting getInstance() {
        if(instance == null) instance = new CJFW_TriggerSetting();        
        return instance;
    }

    /**
    * Trigger Setting 의 상태를 검사하여 Trigger Handler를 패스시킬지 여부 체크
    *
    *@return  Boolean 패스: true, 작동: false
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    public boolean checkByPass() {
        Boolean isPass = false;
        // System.debug(
        //     JSON.serialize(this.trActiveMap)
        // );
        //User Trigger Setiing 비활성화시 byPass
        if(this.trActiveMap.containsKey('user') && !this.trActiveMap.get('user')) {
            return isPass = true;
        }

        if(this.trActiveMap.containsKey('profile') && !this.trActiveMap.get('profile')) {
            return isPass = true;
        }

        if(this.trActiveMap.containsKey('org') && !this.trActiveMap.get('org')) {
            return isPass = true;
        }

        return isPass;
    }
}