/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 05-10-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
public class LogWrapper {
    /** 상태값 : SUCCESS, ERROR */    
    public String status;
    /** 결과코드 : SUCCESS(0000, 200, 201), ERROR(SUCCESS를 제외한 나머지) */
    public String resultCode;
    /** 결과메시지 */
    public String resultMessage;
    /** 요청시간 */
    public Datetime requestTime;
    /** 요청 Header */
    public String requestHeader;
    /** 요청 Body */
    public String requestBody;
    /** 응답시간 */
    public Datetime responseTime;
    /** 응답 Header */
    public String responseHeader;
    /** 응답 Body */
    public String responseBody;

    public LogWrapper() {
    }
}