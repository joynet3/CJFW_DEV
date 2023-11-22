/**
* @Class : IFN_ScheduleBatch
* @group Framework : Common
* @Author : 조일근 
* @Date : 2023. 07. 18
* @Version : 1.0
* @Description : 
* @Modified : 인터페이스 스케쥴 배치
    - Batch_Sequence__mdt 에 등록된 스케쥴링 배치에 대하여 재 등록수행
    - 배치 프로그램이 죽어서 스케쥴이 돌아 가지 않는 부분에 대하여 보완하기 위함
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2023. 07. 18 | 조일근    | 최초작성
* */
global class IFN_ScheduleBatch extends MasterBatchBase implements Database.AllowsCallouts {
    global Integer sTime;

    public IFN_ScheduleBatch(){}
    
    //배치 시작(Scope에 담을 데이터 쿼리 동작)
    public override Database.QueryLocator start(Database.BatchableContext bc) {
        logwrap = new IFN_CommonLog.logWrap('dummy', 'Batch');//로그 기록

        if(sTime == null) sTime = System.now().addhours(1).hour();
        
        System.debug('IFN_ScheduleBatch start!!');
        logwrap.BatchCronId = bc.getJobId();
        logwrap.BatchStartTime = System.now();
        logwrap.ClassName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
        logwrap.LogText.add('### [Batch Start] ###');
        if(ifDate == null) ifDate = Date.today();
        
        return Database.getQueryLocator([SELECT Id
                                                , DeveloperName
                                                , MasterLabel
                                                , Language
                                                , NamespacePrefix
                                                , Label
                                                , QualifiedApiName
                                                , IsActive__c
                                                , NextBatchName__c
                                                , ScopeSize__c
                                                , isScheduled__c
                                                , ScheduleClass__c
                                                , Interval__c
                                                , CronExpression__c
                                        FROM Batch_Sequence__mdt
                                        WHERE isScheduled__c = true
                                        AND IsActive__c  = true
                                        ]);
    }
    
    public override void execute(Database.BatchableContext bc, List<sObject> scope) {

        logWrap.LogText.add('IFN_ScheduleBatch execute!!');

        Savepoint sp = null;

        List<Batch_Sequence__mdt> scList = (List<Batch_Sequence__mdt>)scope;

        List<CronTrigger> delList = new List<CronTrigger>();
        List<Batch_Sequence__mdt> executeList = new List<Batch_Sequence__mdt>();
        Map<String, Batch_Sequence__mdt> itMap = new Map<String, Batch_Sequence__mdt>();
        List<CronTrigger> itCheckList = new List<CronTrigger>();
        Map<String, CronTrigger> itCheckMap = new Map<String, CronTrigger>();

        logWrap.logText.add('sTime : ' + sTime);

        try 
        {
            //이전 스케줄 삭제
            delList = [ SELECT Id
                                ,CronExpression
                                ,CronJobDetail.Name
                        FROM CronTrigger 
                        WHERE CronJobDetail.Name LIKE '[INTERFACE]%'];

            if(delList.size() > 0)
            {
                for(CronTrigger del : delList)
                {
                    System.abortJob(del.Id);
                }
            }

            //  *************************************
            //  1. Cron 표현식은 시간 단위, 현재 배치가 60분 단위로 돌며, 시간단위를 확인하여 재등록작업을 한다.
            //  2. Interval 형식은 간격으로 재단한다.
            for(Batch_Sequence__mdt schedule : scList){
                
                // 1.Cron 표현식의 배치
                if(schedule.CronExpression__c != null){
                    List<String> cronList = schedule.CronExpression__c.split(' ');
                    
                    // 3번째 인자 현재 시간대 (1 10 1 * * ?   :  오전 1시 10분 1초)
                    if(sTime == Integer.valueOf(cronList[2])){
                        IFN_Scheduler sch = new IFN_Scheduler(schedule.ScheduleClass__c,String.valueOf(schedule.ScopeSize__c));
                        system.schedule('[INTERFACE] ' + schedule.ScheduleClass__c.trim(), schedule.CronExpression__c, sch);
                        executeList.add(schedule);
                    }

                    // sancho try
                    //3번째 인자 아스타(*) 일 때 - (이런 배치 되나 모르겠네...)
                    // 테스트용 5분 단위로(0 0/5 * * * ?)
                    //  -> 이런... 매5분단위 이거 않먹히네...
                    //  -> e.getMessage():[Seconds and minutes must be specified as integers: 0 0/5 * * * ?]/e.getLineNumber():[99]

                    // if( '*'.equals(cronList[2]) ){
                    //     IFN_Scheduler sch = new IFN_Scheduler(schedule.ScheduleClass__c,String.valueOf(schedule.ScopeSize__c));
                    //     system.schedule('[INTERFACE] ' + schedule.ScheduleClass__c.trim(), schedule.CronExpression__c, sch);
                    //     executeList.add(schedule);
                    //
                    // ===>>> 결론, 관두... Interval 쓰자.

                //2. Interval 형식의 배치
                }else if(schedule.Interval__c != null){
                    itMap.put(schedule.DeveloperName, schedule);
                }
            }

            //반복 스케줄 등록 여부 확인
            itCheckList = [SELECT Id,CronExpression,CronJobDetail.Name
                            FROM CronTrigger 
                            WHERE CronJobDetail.Name IN :itMap.keySet()];

            if(itCheckList.size() > 0)
            {
                for(CronTrigger ct : itCheckList)
                {
                    itCheckMap.put(ct.CronJobDetail.Name, ct);
                }
            }
            
            //반복 스케줄 등록
            for(Batch_Sequence__mdt it : itMap.values())
            {
                if(itCheckMap.get(it.ScheduleClass__c) == null)
                {
                    IFN_Util.NextScheduleCheck(it.DeveloperName);
                }
            }

            logwrap.IFTotalCount  += 1;
            logwrap.IFRequestSize += 1;
            logWrap.LogText.add(JSON.serialize(executeList));
            logWrap.LogText.add('IFN_ScheduleBatch is End');
        } 
        catch(System.Exception e) 
        {
            logWrap.ErrorText.add('e.getMessage():[' + e.getMessage() + ']' + '/' + 'e.getLineNumber():[' + e.getLineNumber() + ']' );
        }
    }
}