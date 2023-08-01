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

    public Boolean getIsCustom() {
        return this.isCustom;
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
        cloneTemplate.setTitle(this.getTitle());
        cloneTemplate.setBody(this.getBody());
        cloneTemplate.setTargetId(this.getTargetId());
        cloneTemplate.setTemplateId(this.getTemplateId());
        cloneTemplate.setCategory(this.getCategory());
        
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
                msg = msg.replaceAll(targetField, this.fieldsMap.get(field));
            }
            //System.debug('end. msg::'+msg);
        }
        return msg;
    }
}