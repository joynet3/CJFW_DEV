/************************************************************************************
 * File Name   		: CalcNoPriceFuelActivity_sc.cls
 * Author	  		: Kim.Minje
 * Date				: 2023.02.02
 * Tester	  		: CalcNoPriceFuelActivity_test.cls
 * Description 		: 단가 미등록 주유비 재계산 스케쥴러
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.02.02      Minje.Kim       Create
*************************************************************************************/
public with sharing class CalcNoPriceFuelActivity_sc implements Schedulable{
    /***********************************************************************************************************
    *  Scheduler : execute
    *  내용      : 단가 미등록 주유비 재계산 스케쥴러 실행
    *  실행 코드 : CalcNoPriceFuelActivity_sc sc = new CalcNoPriceFuelActivity_sc();
    *              System.schedule('CalcNoPriceFuelActivity_sc','0 40 0 * * ?', sc);
    ************************************************************************************************************/
    public void execute(SchedulableContext sc) {
        CalcNoPriceFuelActivity_ba ba = new CalcNoPriceFuelActivity_ba();
        Database.executeBatch(ba, 10);
    }
}