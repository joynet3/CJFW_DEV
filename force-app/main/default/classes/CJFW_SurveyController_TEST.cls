/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
@isTest
public with sharing class CJFW_SurveyController_TEST {
    
    @TestSetup
    static void makeData(){
        List<User> userList = new List<User>();
        Profile prof = [SELECT Id from profile WHERE name LIKE '%아이누리%'];
        User ibUser = new User(
            LastName = '테스트Staff',
            Alias ='테스트 유저',
            Email='test@test.com',
            ProfileId =prof.Id
        );
        userList.add(ibUser);
        insert userList;
    }
    @isTest
    static void getCurrentUserInfoTest(){
        Test.startTest();

        String result = CJFW_SurveyController.getCurrentUserInfo();
        Test.stopTest();
    }
}