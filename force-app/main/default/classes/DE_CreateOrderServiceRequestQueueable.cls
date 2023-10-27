/**
* 1:1문의 생성 및 중복 리드 삭제 배치
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 조형준
*@since 2023-08-16  내용 작성
*/
public class DE_CreateOrderServiceRequestQueueable implements Queueable {
    public List<OrderServiceRequest__c> orderServiceRequestList = new List<OrderServiceRequest__c>();
    public List<Lead> deleteLeadList = new List<Lead>();

    public void execute(QueueableContext context) {
        try{
            System.debug('orderServiceRequestList : ' + orderServiceRequestList);
            System.debug('deleteLeadList : ' + deleteLeadList);
            if(deleteLeadList.size() > 0) Delete deleteLeadList;//중복 리드 삭제
            if(orderServiceRequestList.size() > 0) Insert orderServiceRequestList;//1:1문의 생성
        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            System.debug('ERROR STACK TRACE : ' + e.getStackTraceString());
        }
    }
}