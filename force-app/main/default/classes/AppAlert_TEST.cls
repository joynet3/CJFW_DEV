@isTest
public with sharing class AppAlert_TEST {
    
    @TestSetup
    static void makeData(){

    }

    @isTest
    static void successAlert_TEST() {
        test.startTest();

        List<CustomNotificationType> customNotiTypeList = [
                select
                    Id
                    ,DeveloperName    
                from CustomNotificationType 
        ];
        
        List<AppTemplate> appTemplateList = new List<AppTemplate>();

        AppTemplate appTemplate = new AppTemplate();
        appTemplate.setTitle('Test Title!');
        appTemplate.setBody('Test Body!');
        //
        appTemplate.setTemplateId(customNotiTypeList[0].Id);
        appTemplate.setToAddresses(new Set<String>{UserInfo.getUserId()});
        appTemplateList.add(appTemplate);

        AppAlert alert = new AppAlert();
        alert.send(appTemplateList);
        test.stopTest();
    }

    @isTest
    static void errorAlert_TEST() {
        test.startTest();

        List<AppTemplate> appTemplateList = new List<AppTemplate>();

        AppTemplate appTemplate = new AppTemplate();
        appTemplate.setTitle('Test Title!');
        appTemplate.setBody('Test Body!');
        appTemplateList.add(appTemplate);
        AppAlert alert = new AppAlert();
        alert.isTestException = true;
        alert.send(appTemplateList);
        
        test.stopTest();
    }

}