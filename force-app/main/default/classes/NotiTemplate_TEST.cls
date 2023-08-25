@isTest
public with sharing class NotiTemplate_TEST {
    
    @TestSetup
    public static void makeData() {
        
    }
    

    @isTest
    static void execute_TEST() {
        test.startTest();
        NotiTemplate template = new NotiTemplate();

        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Name', 'test');
        //알림 개인화 시에 필요한 key, value Setter
        template.setFieldsMap(fieldsMap);
        System.assert('test'.equals(template.getFieldsMap().get('Name')));

        //알림 발송시 오류 메시지 설정
        template.setErrorMsg('erroMsg');
        template.getErrorMsg();

        //알림 템플릿 언어(수신자 기준 다건일떈 대표만) 설정
        template.setLang('ko');
        template.getLang();

        //알림 템플릿 카테고리 설정 App,Email
        template.setCategory('App');
        template.getCategory();

        //알림 템플릿 수신자 설정
        template.setToAddresses(new Set<String>{'test'});
        template.getToAddresses();

        //알림 템플릿 제목 설정
        template.setTitle('제목');
        template.getTitle();

        //알림 템플릿 본문 설정
        template.setBody('본문 {0}');
        template.getBody();

        //알림 템플릿 개인화시 해당 sObject Id
        template.setTargetId(UserInfo.getUserId());
        template.getTargetId();

        //알림 템플릿 Id 및 DeveloperName
        template.setTemplateId('');
        template.getTemplateId();

        NotiTemplate copyTemplate = template.cloneTemplate();
        String body = copyTemplate.setMessage(copyTemplate.getBody());
        System.assert('본문 test'.equals(body));

        copyTemplate.setMessage(copyTemplate.getTitle());
        test.stopTest();
    }
}