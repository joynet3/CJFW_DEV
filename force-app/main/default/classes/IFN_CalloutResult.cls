/**										
 * @Class : IFN_CalloutResult				
 * @Description : Callout reesult class					
 * @Author : Sungh-Ho, Jo
 * @Date : 2020-11-09								
 * @Version : 1.0								
 * @Modified : 									
 *  ---------------------------------------------						
 *  NO | Date       | Modifier      | Description				
 *  ---------------------------------------------						
 *  1. | 2020-11-09 | Sungh-Ho, Jo  | 최초작성							
 */
public class IFN_CalloutResult {
    @AuraEnabled public String result{get;set;}
    @AuraEnabled public String message{get;set;}
    @AuraEnabled public Object response{get;set;}
    @AuraEnabled public Integer totalCount{get;set;}    
    public IFN_CommonLog.LogWrap log{get;set;}

    public IFN_CalloutResult() {
        /**
         * result : success , error  두개로 관리?
         * meessage : salesforce exception 메시지 전달만?
         * response : interface에서 받은 객체 or Exception 
        */
        this.result   = 'S';  
        this.message  = 'S';  
        this.response = null;       
        this.totalCount = 0;
    }

    public void setResult(String result, String message, Object response) {
        this.result   = result;
        this.message  = message;
        this.response = response;

    }


    public void setResult(String result, String message, Object response, IFN_CommonLog.LogWrap log) {
        this.result   = result;
        this.message  = message;
        this.response = response;
        this.log      = log;
    }

    public void setResult(String result, String message,Integer totalCount, Object response, IFN_CommonLog.LogWrap log) {
        this.result   = result;
        this.message  = message;
        this.response = response;
        this.log      = log;
        this.totalCount = totalCount;
    }

    public void setResult(String response) {
        this.response = response;
    }

}