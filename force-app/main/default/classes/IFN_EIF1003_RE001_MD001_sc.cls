/**
 * @Class : IFN_EIF1003_RE001_MD001_sc.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023.09.15
 * @Version : 1.0
 * @Description :
 *     /***********************************************************************************************************
    *  Scheduler : execute
    *  내용      : REMEMBER 명함 데이터 리드등록 스케쥴러 실행
    *  주기      : 매일 오전 12시 5뷴
    *  실행 코드 : IFN_EIF1003_RE001_MD001_sc = new IFN_EIF1003_RE001_MD001_sc();
    *              System.schedule('GetRememberInsertLead','0 05 0 * * ?', sc);
    **************************************************************************************************************/
public with sharing class IFN_EIF1003_RE001_MD001_sc implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new IFN_EIF1003_RE001_MD001_que(1, new List<IFN_EIF1003_RE001_MD001.Stack>()));
    }
}