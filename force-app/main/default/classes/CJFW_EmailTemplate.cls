public with sharing class CJFW_EmailTemplate extends CJFW_NotiTemplate{
    
    @TestVisible protected Set<String> ccAddresses;
    @TestVisible protected Set<String> bccAddresses;
    
    public CJFW_EmailTemplate() {

    }

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
    }

    /**
    * cloneData
    *
    *@return  CJFW_NotiTemplate 
    */
    public override CJFW_NotiTemplate cloneTemplate() {
        CJFW_EmailTemplate cloneTemplate = new CJFW_EmailTemplate();
        cloneTemplate.setToAddresses(this.getToAddresses());
        cloneTemplate.setCcAddresses(this.getCcAddresses());
        cloneTemplate.setBccAddresses(this.getBccAddresses());
        cloneTemplate.setTitle(this.getTitle());
        cloneTemplate.setMessage(this.getMessage());
        cloneTemplate.setTargetId(this.getTargetId());
        cloneTemplate.setTemplateId(this.getTemplateId());
        cloneTemplate.setCategory(this.getCategory());
        
        return cloneTemplate;
    }
}