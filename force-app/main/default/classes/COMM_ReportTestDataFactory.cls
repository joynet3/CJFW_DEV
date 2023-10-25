/**
 * @description       : 품의서전용 데이터 팩토리 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
**/

global with sharing class COMM_ReportTestDataFactory {
    
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

    

    /**
     * 고객사 생성 Account 정보 만들기 
    */
    global static Account createAccount(String name, String rcdTypeDevName){
        Account acc;
        try{

            // 레코드 타입 넣어줄때 샘플 
            RecordType recordType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive 
                                    FROM RecordType 
                                    WHERE SobjectType = 'Account' 
                                    AND DeveloperName = :rcdTypeDevName];

            acc = new Account(
                Name = name,
                RecordTypeId = (recordType != null) ? recordType.Id : null
                // 아래 추가로 쭉쭉 데이터 만들어주면됨 ( 필수값들은 반드시 데이터 만들어 줘야함 )
            );

        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
        
        return acc;
    }

    /**
     * 영업기회 (Opportunity) 테스트데이터 
     */
    global static Opportunity createOpportunity(Id recordTypeId, String name, Id accountId, Date closeDate ){
        Opportunity oppty = new Opportunity(
            RecordTypeId = recordTypeId
            , Name = name
            , AccountId = accountId
            , CloseDate = closeDate
            , StageName = 'Close' 
            // 아래 추가로 쭉쭉 데이터 만들어주면됨 ( 필수값들은 반드시 데이터 만들어 줘야함 )
        );
        return oppty;
    }

    /**
     * 물류비관리 (CJFW_DistributionCost__c)테스트데이터 
     */
    global static CJFW_DistributionCost__c createDistributeCost(String rcdTypeDevName){
        CJFW_DistributionCost__c distCost = new CJFW_DistributionCost__c(
            HeadOffice__c = '외식SU'
            , Region__c = '수도권'
            , Type__c = '간접' 
            // 아래 추가로 쭉쭉 데이터 만들어주면됨 ( 필수값들은 반드시 데이터 만들어 줘야함 )
        );
        return distCost;
    }


    /**
     * 예상손익관리 (CJFW_ExpectedIncomeManager__c) 테스트데이터 
     */
    global static CJFW_ExpectedIncomeManager__c createExpectedIncomeManager(){
        CJFW_ExpectedIncomeManager__c ExIncomeManager = new CJFW_ExpectedIncomeManager__c(
            HeadOffice__c = '급식SU'
            , CardFee__c = 300
           // 아래 추가로 쭉쭉 데이터 만들어주면됨 ( 필수값들은 반드시 데이터 만들어 줘야함 )
        );
        return ExIncomeManager;
    }

    // 신규개설품의 (CJFW_ExpectedIncomeExpenses__c) 테스트데이터 
    global static CJFW_ExpectedIncomeExpenses__c createExpectedIncome( String OpportunityId ){
        CJFW_ExpectedIncomeExpenses__c ExIncome = new CJFW_ExpectedIncomeExpenses__c(
            Opportunity__c = OpportunityId
            , Version__c = 1
           // 아래 추가로 쭉쭉 데이터 만들어주면됨 ( 필수값들은 반드시 데이터 만들어 줘야함 )
        );
        return ExIncome;
    }


}