public with sharing class SampleDynamicNotiHandler extends NotiHandler {
    
    public override void manuFactureNoti(Object targetObject) {

        List<Account> targetAccountList = (List<Account>) targetObject;
        List<AppTemplate> appTemplateList = new List<AppTemplate>();

        List<CustomNotificationType> customNotiTyipeList = [
            select
                Id
                ,DeveloperName    
            from CustomNotificationType limit 1];

        for(Account targetAccount : targetAccountList) {
            String targetId = targetAccount.Id;
            
            NotiTarget recipientId = new NotiTarget('id');
            recipientId.setToAddresses(new Set<String>{UserInfo.getUserId()});
        
            AppTemplate appTemplate1 = new AppTemplate();
            appTemplate1.setTitle('Dynamic');
            appTemplate1.setBody('ClassName__c : SampleDynamicNotiHandler');
            appTemplate1.setTemplateId(customNotiTyipeList[0].Id);
            appTemplate1.setToAddresses(new Set<String>{UserInfo.getUserId()});
            appTemplate1.setTargetId(targetId);
            appTemplateList.add(appTemplate1);
        }


        categorySendDataListMap.put('App', appTemplateList);
    }


    public override void manuFactureNoti(Set<String> targetIdSet) {
        System.debug('SampleDynamicNotiHandler.categoryTemplateMapMap :: '+categoryTemplateMapMap);


        AppTemplate appTemplate1 = new AppTemplate();
        appTemplate1.settitle('IsDynamic title List View 2');
        appTemplate1.setBody('message');
        appTemplate1.setTemplateId('0ML0w0000008ShSGAU');
        appTemplate1.setToAddresses(new Set<String>{'0050w000005XKvNAAW'});
        appTemplate1.setTargetId('0010w0000115nxvAAA');
        Map<String, Object> pageRef = new Map<String, Object>{
            'type' => 'standard__objectPage',
            'attributes' => new Map<String, Object>{
                'objectApiName' => 'Account'
                ,'actionName' => 'list'
            },
            'state' => new Map<String, Object>{
                'filterName'=> 'AllAccounts'
            }
            
        };
            
        appTemplate1.setPageReference(JSON.serialize(pageRef));
            
        categorySendDataListMap.put('App', new List<AppTemplate>{
            appTemplate1
        });
    }
}