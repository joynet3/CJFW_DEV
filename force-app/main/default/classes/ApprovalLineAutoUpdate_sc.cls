/************************************************************************************
 * File Name   		: ApprovalLineAutoUpdate_sc.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.02
 * Tester	  		: ApprovalLineAutoUpdate_test.cls
 * Description 		: 전자결재 상태 업데이트 스케쥴러
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.02      Minje.Kim       Create
*************************************************************************************/

public with sharing class ApprovalLineAutoUpdate_sc implements Schedulable{
    /***********************************************************************************************************
    *  Scheduler : execute
    *  내용      : 단가 미등록 주유비 재계산 스케쥴러 실행
    *  주기      : 매 시 10분 (1시간 간격)
    *  실행 코드 : ApprovalLineAutoUpdate_sc sc = new ApprovalLineAutoUpdate_sc();
    *              System.schedule('ApprovalLineAutoUpdate_sc','0 10 * * * ?', sc);
    ************************************************************************************************************/
    public void execute(SchedulableContext sc) {
        ApprovalLineAutoUpdate_ba ba = new ApprovalLineAutoUpdate_ba();
        Database.executeBatch(ba, 1);
    }
}