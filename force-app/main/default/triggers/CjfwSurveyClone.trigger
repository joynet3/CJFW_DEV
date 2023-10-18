/**
 * @description       : 
 * @author            : sunkyung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 10-17-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
trigger CjfwSurveyClone on CJFW_Survey__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CJFW_Survey_tr().run();
    // switch on trigger.operationType {
       
    //     when AFTER_INSERT {
    //         insertCheck(Trigger.new,Trigger.oldMap);
    //     }
    // }
    // private static void insertCheck(List<CJFW_Survey__c > copyList,Map<Id,CJFW_Survey__c > oldmap ){
    //     System.debug('insertCheck 시작 >>>>>> ');
        
    //     List<CJFW_SurveyQuestion__c> questionCloneList = new List<CJFW_SurveyQuestion__c>();
    //     List<CJFW_SurveyOption__c> optionCloneList = new List<CJFW_SurveyOption__c>();
        
    //     for (CJFW_Survey__c co : copyList) {
    //         System.debug('시작 확인 >>');
    //         List<CJFW_SurveyQuestion__c> QuestionList = [SELECT Id,Name, Name__c, Survey__c, Type__c, MultipleChoice__c, Order__c, DateType__c, TextType__c FROM CJFW_SurveyQuestion__c WHERE Survey__c = :co.Id];
    //          System.debug('시작 확인 >>');
    //         for (CJFW_SurveyQuestion__c queList : QuestionList) {
    //             CJFW_SurveyQuestion__c clonedBchild = queList.clone(false);
    //             clonedBchild.Survey__c = co.Id;
    //             questionCloneList.add(clonedBchild);
    //             System.debug('으아: ' + clonedBchild.Id);

    //             List<CJFW_SurveyOption__c> OptionList = [SELECT Id,  Name, Order__c, SurveyQuestion__c FROM CJFW_SurveyOption__c WHERE SurveyQuestion__c = :queList.Id];
    //             for (CJFW_SurveyOption__c OptiList : OptionList) {
    //                 CJFW_SurveyOption__c clonedCchild = optiList.clone(false);
    //                 clonedCchild.SurveyQuestion__c  = clonedBchild.Id;
    //                 optionList.add(clonedCchild);
    //                 System.debug('으아22: ' + clonedCchild.Id);
    //             }
    //         }

    //     }
       
    //     // 복제된 하위 레코드 삽입
    //     insert questionCloneList;
    //     insert optionCloneList;

    // }

}