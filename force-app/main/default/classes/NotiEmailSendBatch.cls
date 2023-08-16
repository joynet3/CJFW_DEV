public with sharing class NotiEmailSendBatch implements Database.Batchable<NotiEmailTemplate>, Database.Stateful, Database.AllowsCallouts {
    private List<NotiEmailTemplate> emailTemplateList;

    public NotiEmailSendBatch() {
        emailTemplateList = new List<NotiEmailTemplate>();
    }

    public NotiEmailSendBatch(List<NotiEmailTemplate> emailTemplateList) {
        this.setEmailTemplateList(emailTemplateList);
    }

    public Iterable<NotiEmailTemplate> start(Database.BatchableContext BC){
        return emailTemplateList;
    }
    
    public void execute(Database.BatchableContext BC, List<NotiEmailTemplate> scope){
        try {
            EmailAlert emailAlert = new EmailAlert();
            emailAlert.setIsBatch(true);
            emailAlert.send(emailTemplateList);
        } catch (Exception e) {
            System.debug(e.getMessage());
            //TBD 에러 발생시 로그 필요
        }
    }

    public void finish(Database.BatchableContext BC){
        
    }

    private void setEmailTemplateList(List<NotiEmailTemplate> emailTemplateList) {
        this.emailTemplateList = emailTemplateList; 
    }
}