/**
* App 전용 알림 Template
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 진현욱
*@since 2023-07-24  내용 작성
*/
public with sharing class CJFW_AppTemplate extends CJFW_NotiTemplate{
    
    @TestVisible private String pageReference;
    
    public CJFW_AppTemplate() {
        this.category = 'App';
    }

    public String getPageReference() {
        return this.pageReference;
    }

    public void setPageReference(String pageReference) {
        this.pageReference = pageReference;
    }

    public override CJFW_NotiTemplate cloneTemplate() {
        CJFW_AppTemplate cloneTemplate = new CJFW_AppTemplate();
        cloneTemplate.setToAddresses(this.getToAddresses());
        cloneTemplate.setTitle(this.getTitle());
        cloneTemplate.setMessage(this.getMessage());
        cloneTemplate.setTargetId(this.getTargetId());
        cloneTemplate.setTemplateId(this.getTemplateId());
        cloneTemplate.setCategory(this.getCategory());
        cloneTemplate.setPageReference(this.getPageReference());
        
        return cloneTemplate;
    }

}