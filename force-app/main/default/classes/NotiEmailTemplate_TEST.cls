@isTest
public with sharing class NotiEmailTemplate_TEST {
    @isTest
    static void execute_TEST() {
        test.startTest();

        NotiEmailTemplate template = new NotiEmailTemplate();

        Map<String, String> fieldsMap = new Map<String, String>();
        fieldsMap.put('Name', 'test');
        template.setFieldsMap(fieldsMap);

        //template cc 설정
        template.setCcAddresses(new Set<String>{'ccTest'});
        template.getCcAddresses();

        //template bcc 설정
        template.setBccAddresses(new Set<String>{'bccTest'});
        template.getBccAddresses();

        //AttachmentIds 설정
        template.setAttachmentIds(new Set<String>{''});
        template.getAttachmentIds();

        //getIsCustom() == true 일떄는 제목, 본문 정보로 바로 보낼때 사용
        template.setIsCustom(false);
        template.getIsCustom();

        //getIsSystem() == true 일떄는 시스템 기능을 통하여 개인화하여 보낼떄 사용
        template.setIsSystem(false);
        template.getIsSystem();

        //getIsUseOWE() == true 이메일 송신시 발신자 오그 전체 주소로 설정
        template.setIsUseOWE(false);
        template.getIsUseOWE();

        //getIsSaveAsActivity == true EmailMessage 에 이력생성 여부
        //System 이메일로 보낼경우 템플릿에 제목이랑 본문이 없으므로 필수적으로 남겨야함
        template.setIsSaveAsActivity(false);
        template.getIsSaveAsActivity();

        NotiEmailTemplate cloneTemplate = (NotiEmailTemplate)template.cloneTemplate();


        System.assert(cloneTemplate.getCcAddresses() == template.getCcAddresses());
        System.assert(cloneTemplate.getBccAddresses() == template.getBccAddresses());

        String msg = cloneTemplate.setMessage('{Name}');

        System.assert('test'.equals(msg));

        test.stopTest();
    }
}