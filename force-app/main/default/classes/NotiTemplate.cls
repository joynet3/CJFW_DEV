/**
* 알림 보낼 템플릿 양식
*
*@group  Notification
*@author 진현욱
*@since 2023-07-24 최초작성
*/
public virtual with sharing class NotiTemplate {
    
    @TestVisible protected String category;               //App, Email, 등..
    @TestVisible protected Set<String> toAddresses;       //수신자
    @TestVisible protected String title;                  //제목
    @TestVisible protected String body;                   //본문
    @TestVisible protected String targetId;               //
    @TestVisible protected String templateId;             //App : CustomNotificationType.Id, Email: EmailTemplate.DeveloperName
    @TestVisible protected String lang;                   //언어
    @TestVisible protected Map<String, String> fieldsMap; //key: 필드, value: 값 > 개인화할떄 필요한 값
    @TestVisible protected String errorMsg;
    @TestVisible protected String notiId;
    @TestVisible protected String status;                 //SUCCESS, FAIL
    
    //@TestVisible private String pageReference;

    public NotiTemplate() {

    }

    public void setFieldsMap(Map<String, String> fieldsMap) {
        this.fieldsMap = fieldsMap;
    }

    public Map<String, String> getFieldsMap() {
        return this.fieldsMap;
    }

    public String getErrorMsg() {
        return this.errorMsg;
    }

    public void setErrorMsg(String errorMsg) {
        this.errorMsg = errorMsg;
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

    public String getTitle() {
        return this.title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getBody() {
        return this.body;
    }

    public void setBody(String body) {
        this.body = body;
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

    public String getNotiId() {
        return this.notiId;
    }

    public void setNotiId(String notiId) {
        this.notiId = notiId;
    }

    public String getStatus() {
        return this.status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    /**
    * template 데이터 clone 자식에서 이 기능 사용하려면 override 필수
    *
    *@return  NotiTemplate 
    */
    public virtual NotiTemplate cloneTemplate() {
        NotiTemplate cloneTemplate = new NotiTemplate();
        cloneTemplate.setToAddresses(this.getToAddresses());
        cloneTemplate.setTitle(this.getTitle());
        cloneTemplate.setBody(this.getBody());
        cloneTemplate.setTargetId(this.getTargetId());
        cloneTemplate.setTemplateId(this.getTemplateId());
        cloneTemplate.setCategory(this.getCategory());
        cloneTemplate.setLang(this.getLang());
        cloneTemplate.setErrorMsg(this.getErrorMsg());
        cloneTemplate.setFieldsMap(this.getFieldsMap());
        cloneTemplate.setNotiId(this.getNotiId());
        return cloneTemplate;
    }

    /**
     * Noti 발송을 위한 Message 가공
     * @param msg 
     * @return `String`
     */
    public virtual String setMessage(String msg) {
        Pattern pattern = Pattern.compile('\\{[0-9]\\}');
        Matcher matcher = pattern.matcher(msg);
        
        if(matcher.find() && this.fieldsMap != null){
            List<String> fields = new List<String>();
            fields.addAll(this.fieldsMap.values());
            return String.format(
                msg
                ,fields
            );
        }else{
            return msg;
        }
    }
}