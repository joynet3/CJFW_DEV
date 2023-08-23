/**
* Email 전용 알림 Template
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 진현욱
*@since 2023-07-24  내용 작성
*/
public with sharing class NotiEmailTemplate extends NotiTemplate{
    public NotiEmailTemplate() {
        this.category = 'Email';
    }
    @TestVisible protected Set<String> ccAddresses;
    @TestVisible protected Set<String> bccAddresses;
    @TestVisible protected Set<String> attachmentIds;
    @TestVisible protected Boolean isCustom = false;
    @TestVisible protected Boolean isSystem = false;
    @TestVisible protected Boolean isUseOWE = false;
    @TestVisible protected Boolean isSaveAsActivity = false;
    @TestVisible protected Boolean isTargetObjectId = false; //수신자 setTargetObjectId로 설정여부 Single Email limit 제외하기 위해서
    
    public Boolean getIsTargetObjectId() {
        return this.isTargetObjectId;
    }

    public void setIsTargetObjectId(Boolean isTargetObjectId) {
        this.isTargetObjectId = isTargetObjectId;
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

    public Set<String> getAttachmentIds() {
        return this.attachmentIds;
    }

    public void setAttachmentIds(Set<String> attachmentIds) {
        this.attachmentIds = attachmentIds;
    }

    public Boolean getIsCustom() {
        return this.isCustom;
    }

    public void setIsCustom(Boolean isCustom) {
        this.isCustom = isCustom;
    }

    public Boolean getIsSystem() {
        return this.isSystem;
    }

    public void setIsSystem(Boolean isSystem) {
        this.isSystem = isSystem;
    }

    public Boolean getIsUseOWE() {
        return this.isUseOWE;
    }

    public void setIsUseOWE(Boolean isUseOWE) {
        this.isUseOWE = isUseOWE;
    }

    public Boolean getIsSaveAsActivity() {
        return this.isSaveAsActivity;
    }

    public void setIsSaveAsActivity(Boolean isSaveAsActivity) {
        this.isSaveAsActivity = isSaveAsActivity;
    }

    /**
    * override cloneData
    *
    *@return  NotiTemplate 
    */
    public override NotiTemplate cloneTemplate() {
        NotiEmailTemplate cloneTemplate = new NotiEmailTemplate();
        cloneTemplate.setToAddresses(this.getToAddresses());
        cloneTemplate.setCcAddresses(this.getCcAddresses());
        cloneTemplate.setBccAddresses(this.getBccAddresses());
        cloneTemplate.setAttachmentIds(this.getAttachmentIds());
        cloneTemplate.setTitle(this.getTitle());
        cloneTemplate.setBody(this.getBody());
        cloneTemplate.setTargetId(this.getTargetId());
        cloneTemplate.setTemplateId(this.getTemplateId());
        cloneTemplate.setCategory(this.getCategory());
        cloneTemplate.setLang(this.getLang());
        cloneTemplate.setErrorMsg(this.getErrorMsg());
        cloneTemplate.setFieldsMap(this.getFieldsMap());
        cloneTemplate.setIsCustom(this.getIsCustom());
        cloneTemplate.setIsSystem(this.getIsSystem());
        cloneTemplate.setIsUseOWE(this.getIsUseOWE());
        cloneTemplate.setIsSaveAsActivity(this.getIsSaveAsActivity());
        cloneTemplate.setIsTargetObjectId(this.getIsTargetObjectId());
        
        return cloneTemplate;
    }

    /**
     * override Email Noti 발송을 위한 Message 가공
     * @param msg 
     * @return `String`
     */
    public override String setMessage(String msg) {

        if(this.fieldsMap != null) {
            //System.debug('setMeesage:: ');
            for(String field : this.fieldsMap.keySet()) {
                //.replaceAll('\\{', '{').replaceAll('\\}', '}').replaceAll('\\{Account.Name\\}', 'TEST')
                String targetField = '\\{'+field+'\\}';
                //System.debug('msg:: '+msg);
                //System.debug('targetField:: '+targetField);
                String targetValue = this.fieldsMap.get(field);
                if(String.isNotBlank(targetValue))
                msg = msg.replaceAll(targetField, targetValue);
            }
            //System.debug('end. msg::'+msg);
        }
        return msg;
    }
}