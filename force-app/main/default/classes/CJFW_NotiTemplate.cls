/**
* 알림 보낼 템플릿 양식
*
*@group  Notification
*@author 진현욱
*@since 2023-07-24 최초작성
*/
public virtual with sharing class CJFW_NotiTemplate {
    
    @TestVisible protected String category;
    @TestVisible protected Set<String> toAddresses;
    //@TestVisible protected List<String> ccAddresses;
    //@TestVisible protected List<String> bccAddresses;
    @TestVisible protected String title;
    @TestVisible protected String message;
    @TestVisible protected String targetId;
    @TestVisible protected String templateId;
    @TestVisible protected String lang;
    
    //@TestVisible private String pageReference;

    public CJFW_NotiTemplate() {

    }

    public String getLang() {
        return this.lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getCategory() {
        return this.category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Set<String> getToAddresses() {
        return this.toAddresses;
    }

    public void setToAddresses(Set<String> toAddresses) {
        this.toAddresses = toAddresses;
    }
    /*
    public Set<String> getCcAddresses() {
        return this.ccAddresses;
    }

    public void setCcAddresses(Set<String> ccAddresses) {
        this.ccAddresses = ccAddresses;
    }

    public Set<String> getBccAddresses() {
        return this.bccAddresses;
    }

    public void setBccAddresses(Set<String> bccAddresses) {
        this.bccAddresses = bccAddresses;
    }*/

    public String getTitle() {
        return this.title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return this.message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getTargetId() {
        return this.targetId;
    }

    public void setTargetId(String targetId) {
        this.targetId = targetId;
    }

    public String getTemplateId() {
        return this.templateId;
    }

    public void setTemplateId(String templateId) {
        this.templateId = templateId;
    }

    /**
    * template 데이터 clone 자식에서 이 기능 사용하려면 override 필수
    *
    *@return  CJFW_NotiTemplate 
    */
    public virtual CJFW_NotiTemplate cloneTemplate() {
        CJFW_NotiTemplate cloneTemplate = new CJFW_NotiTemplate();
        cloneTemplate.setToAddresses(this.getToAddresses());
        cloneTemplate.setTitle(this.getTitle());
        cloneTemplate.setMessage(this.getMessage());
        cloneTemplate.setTargetId(this.getTargetId());
        cloneTemplate.setTemplateId(this.getTemplateId());
        cloneTemplate.setCategory(this.getCategory());
        
        return cloneTemplate;
    }
}