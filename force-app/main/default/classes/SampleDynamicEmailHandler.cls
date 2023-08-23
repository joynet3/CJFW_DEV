public with sharing class SampleDynamicEmailHandler extends NotiHandler {
    

    public override void manuFactureNoti(Object targetObject) {

        List<Opportunity> optyList = (List<Opportunity>) targetObject;

        List<NotiEmailTemplate> emailTemplateList = new List<NotiEmailTemplate>();
        for(Opportunity opty : optyList) {
            NotiEmailTemplate emailTemplate = new NotiEmailTemplate();
            emailTemplate.setTitle('Dynamic');
            emailTemplate.setBody('ClassName__c : SampleDynamicEmailHandler');
            emailTemplate.setTemplateId('NotiSampleTest'); //Email 일 경우 Developer API 명
            emailTemplate.setIsCustom(true);
            emailTemplate.setIsTargetObjectId(true);
            emailTemplate.setToAddresses(new Set<String>{UserInfo.getUserId()});
            emailTemplateList.add(emailTemplate);
        }

        //발송할 채널별 Email Template Lis 대입
        categorySendDataListMap.put('Email', emailTemplateList);
    }
}