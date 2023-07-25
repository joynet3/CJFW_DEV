/**
* CJFW_TriggerSetting Test Class
*
*@group  Trigger
*@author 진현욱
*@since 2023-07-24  생성
*/
@isTest
public with sharing class CJFW_TriggerSetting_Test {
    @isTest
    static void noDataCJFW_TriggerSetting() {
        Test.startTest();

        System.debug(CJFW_TriggerSetting__c.getInstance());

        System.assert(false == CJFW_TriggerSetting.getInstance().checkByPass());
        Test.stopTest();
    }

    @isTest
    static void inActiveOrg() {
        Test.startTest();

        
        CJFW_TriggerSetting__c orgSetting = CJFW_TriggerSetting__c.getOrgDefaults();
        orgSetting.IsActive__c = false;
        insert orgSetting;

        CJFW_TriggerSetting__c profileSetting = new CJFW_TriggerSetting__c();
        profileSetting.Name = 'CustomSettingName (Profile)';
        profileSetting.IsActive__c = true;
        profileSetting.SetupOwnerId = UserInfo.getProfileId();
        insert profileSetting;

        CJFW_TriggerSetting__c userSetting = new CJFW_TriggerSetting__c();
        userSetting.Name = 'CustomSettingName (User)';
        userSetting.IsActive__c = true;
        userSetting.SetupOwnerId = UserInfo.getUserId();
        insert userSetting;

        //System.debug(CJFW_TriggerSetting__c.getOrgDefaults());

        System.assert(true ==CJFW_TriggerSetting.getInstance().checkByPass());

        Test.stopTest();
    }

    @isTest
    static void inActiveProfile() {
        Test.startTest();

        
        CJFW_TriggerSetting__c orgSetting = CJFW_TriggerSetting__c.getOrgDefaults();
        orgSetting.IsActive__c = true;
        insert orgSetting;

        CJFW_TriggerSetting__c profileSetting = new CJFW_TriggerSetting__c();
        profileSetting.Name = 'CustomSettingName (Profile)';
        profileSetting.IsActive__c = false;
        profileSetting.SetupOwnerId = UserInfo.getProfileId();
        insert profileSetting;

        CJFW_TriggerSetting__c userSetting = new CJFW_TriggerSetting__c();
        userSetting.Name = 'CustomSettingName (User)';
        userSetting.IsActive__c = true;
        userSetting.SetupOwnerId = UserInfo.getUserId();
        insert userSetting;

       //System.debug(CJFW_TriggerSetting__c.getOrgDefaults());

        System.assert(true ==CJFW_TriggerSetting.getInstance().checkByPass());
        Test.stopTest();
    }

    @isTest
    static void inActiveUser() {
        Test.startTest();

        
        CJFW_TriggerSetting__c orgSetting = CJFW_TriggerSetting__c.getOrgDefaults();
        orgSetting.IsActive__c = true;
        insert orgSetting;

        CJFW_TriggerSetting__c profileSetting = new CJFW_TriggerSetting__c();
        profileSetting.Name = 'CustomSettingName (Profile)';
        profileSetting.IsActive__c = true;
        profileSetting.SetupOwnerId = UserInfo.getProfileId();
        insert profileSetting;

        CJFW_TriggerSetting__c userSetting = new CJFW_TriggerSetting__c();
        userSetting.Name = 'CustomSettingName (User)';
        userSetting.IsActive__c = false;
        userSetting.SetupOwnerId = UserInfo.getUserId();
        insert userSetting;

        //System.debug(CJFW_TriggerSetting__c.getOrgDefaults());
        System.assert(true ==CJFW_TriggerSetting.getInstance().checkByPass());
        
        Test.stopTest();
    }

    @isTest
    static void inActiveUserandOrg() {
        Test.startTest();

        
        CJFW_TriggerSetting__c orgSetting = CJFW_TriggerSetting__c.getOrgDefaults();
        orgSetting.IsActive__c = false;
        insert orgSetting;

        CJFW_TriggerSetting__c profileSetting = new CJFW_TriggerSetting__c();
        profileSetting.Name = 'CustomSettingName (Profile)';
        profileSetting.IsActive__c = true;
        profileSetting.SetupOwnerId = UserInfo.getProfileId();
        insert profileSetting;

        CJFW_TriggerSetting__c userSetting = new CJFW_TriggerSetting__c();
        userSetting.Name = 'CustomSettingName (User)';
        userSetting.IsActive__c = false;
        userSetting.SetupOwnerId = UserInfo.getUserId();
        insert userSetting;

        //System.debug(CJFW_TriggerSetting__c.getOrgDefaults());
        System.assert(true == CJFW_TriggerSetting.getInstance().checkByPass());
        
        Test.stopTest();
    }
}