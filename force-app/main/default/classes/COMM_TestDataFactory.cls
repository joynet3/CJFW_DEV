/**
* 테스트용 더미 데이터 
*
*@group  
*@author 진현욱
*@since 2023-10-05  최초작성
*/
@isTest
global with sharing class COMM_TestDataFactory {
    
    /**
    * 프로필 정보 조회
    *
    *@param  profileNameList 프로필명 리스트
    *@return  Map<String,Profile>
    */
    global static Map<String,Profile> getProfileMap(List<String> profileNameList) { 
        Map<String, Profile> profileMap = new Map<String, Profile>();
        for(Profile currProfile : [SELECT Id, Name FROM Profile WHERE Name IN :profileNameList]) {
            profileMap.put(currProfile.Name, currProfile);
        }
        
        return profileMap;
    }


    /**
    * UserRole 조회
    *
    *@param  roleName                (Required)
    *@return UserRole 
    */
    global static UserRole getUserRole(String roleName) { 
        UserRole role = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = :roleName];
        
        return role;
    }

    /**
    * User 생성 (Profile 이외 임의생성)
    *
    *@param  profileId               (Required)
    *@return User 
    */
    global static User createUser(String profileId){
        User user = new User(
            ProfileId = profileId
            , Alias = 'Alias'
            , Username = 'Test@test.com' + System.currentTimeMillis()
            , EmployeeNumber = '998877'
            , Email = 'Test@test.com'
            , FirstName = 'Test'
            , LastName = 'Test'
            , LocaleSidKey = 'en_US'
            , LanguageLocaleKey = 'en_US'
            , EmailEncodingKey = 'UTF-8'
            , TimeZoneSidKey = 'America/Los_Angeles'
            , IsActive = true
            , FederationIdentifier = 'Test' + System.currentTimeMillis()
        );

        return user;
    }

    /**
    * User 생성 (Name, EmployeeNumber, Profile, UserRole 지정 [커뮤니티 사용자 생성시 ContactId 필요])
    *
    *@param  name                    (Required)
    *@param  empNumber               (Required)
    *@param  profileId               (Required)
    *@param  contactId               (Option)
    *@return User 
    */
    global static User createUser(String name, String empNumber, String profileId, String contactId){
        User user = new User(
            ProfileId = profileId
            , Alias = name
            , Username = name + '@test.com' + System.currentTimeMillis()
            , EmployeeNumber = empNumber
            , Email = name + '@test.com'
            , FirstName = name
            , LastName = 'Test'
            , LocaleSidKey = 'en_US'
            , LanguageLocaleKey = 'en_US'
            , EmailEncodingKey = 'UTF-8'
            , TimeZoneSidKey = 'America/Los_Angeles'
            , IsActive = true
            , FederationIdentifier = name + System.currentTimeMillis()
            , contactId = contactId != '' ? contactId : null
        );

        return user;
    }
}