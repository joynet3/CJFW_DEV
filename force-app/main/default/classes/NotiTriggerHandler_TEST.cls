@isTest
public with sharing class NotiTriggerHandler_TEST {
    
    @TestSetup
    static void makeData(){
        NotificationManager_TEST.makeData();
    }

    @isTest
    static void execute(){
        new NotiTriggerHandler();
    }
}