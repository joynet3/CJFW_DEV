/**
* 알림 수신자 
*
*@group  Notification
*@author 진현욱
*@since 2023-08-05  최초 생성
*/
public with sharing class NotiTarget {

    @testVisible private String type;                //Id,Email,Phone
    @testVisible private Set<String> toAddresses;    //수신자
    @testVisible private Set<String> ccAddresses;    //참조     Notification RecordType: Email일 경우 동작      
    @testVisible private Set<String> bccAddresses;   //숨은참조  Notification RecordType: Email일 경우 동작          
    @TestVisible private Set<String> attachmentIds;  //type: Email 일 경우 사용 첨부파일 IdSet
    @testVisible private String lang = 'ko';         //언어  

    public NotiTarget() {

    }

    public NotiTarget(String type) {
        this.setType(type);
    }

    public Set<String> getAttachmentIds() {
        return this.attachmentIds;
    }
    
    public void setAttachmentIds(Set<String> attachmentIds) {
        this.attachmentIds = attachmentIds;
    }

    public String getType() {
        return this.type;
    }
    
    public void setType(String type) {
        this.type = type.toLowerCase();
    }

    
    public String getLang() {
        return this.lang;
    }
    
    public void setLang(String lang) {
        this.lang = lang;
    }

    public void setToAddresses(Set<String> toAddresses) {
        this.toAddresses = toAddresses;
    }

    public Set<String> getToAddresses() {
        return this.toAddresses;
    }

    public void setCcAddresses(Set<String> ccAddresses) {
        this.ccAddresses = ccAddresses;
    }
    public Set<String> getCcAddresses() {
        return this.ccAddresses;
    }

    public void setBccAddresses(Set<String> bccAddresses) {
        this.bccAddresses = bccAddresses;
    }
    public Set<String> getBccAddresses() {
        return this.bccAddresses;
    }

   
}