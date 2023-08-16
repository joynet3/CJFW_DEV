/**
* App 전용 알림 Template
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 진현욱
*@since 2023-07-24  내용 작성
*/
public with sharing class AppTemplate extends NotiTemplate{
    
    @TestVisible private String pageReference;
    
    public AppTemplate() {
        this.category = 'App';
    }

    public String getPageReference() {
        return this.pageReference;
    }

    public void setPageReference(String pageReference) {
        this.pageReference = pageReference;
    }

    public override NotiTemplate cloneTemplate() {
        AppTemplate cloneTemplate = new AppTemplate();
        cloneTemplate.setToAddresses(this.getToAddresses());
        cloneTemplate.setTitle(this.getTitle());
        cloneTemplate.setBody(this.getBody());
        cloneTemplate.setTargetId(this.getTargetId());
        cloneTemplate.setTemplateId(this.getTemplateId());
        cloneTemplate.setCategory(this.getCategory());
        cloneTemplate.setPageReference(this.getPageReference());
        cloneTemplate.setLang(this.getLang());
        cloneTemplate.setErrorMsg(this.getErrorMsg());
        cloneTemplate.setFieldsMap(this.getFieldsMap());
        
        return cloneTemplate;
    }

}