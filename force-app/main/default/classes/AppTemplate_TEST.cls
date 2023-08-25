@isTest
public with sharing class AppTemplate_TEST {
    
    @isTest
    static void execute_TEST() {
        test.startTest();
        AppTemplate template = new AppTemplate();

        Map<String, Object> pageRefMap = new Map<String, Object>{
            'type' => 'standard__objectPage',
            'attributes' => new Map<String, Object>{
                'objectApiName' => 'Account'
                ,'actionName' => 'list'
            },
            'state' => new Map<String, Object>{
                'filterName'=> 'AllAccounts'
            }            
        };

        //App 알림 클릭시 이동할 pageReference 등록
        template.setPageReference(JSON.serialize(pageRefMap));
        template.getPageReference();

        //
        AppTemplate cloneTemplate = (AppTemplate)template.cloneTemplate();
        System.assert(JSON.serialize(pageRefMap).equals(cloneTemplate.getPageReference()));

        test.stopTest();
    }
}