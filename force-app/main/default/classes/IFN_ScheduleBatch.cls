/**
* @Class : IFN_ScheduleBatch
*
* @Author : Jo Hyeong Jun
* @Date : 2020. 01. 27
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2020-01-27 | Jo Hyeong Jun   | 최초작성
* 
* */
global class IFN_ScheduleBatch extends MasterBatchBase implements Database.AllowsCallouts {
    global Integer sTime;

    
    public IFN_ScheduleBatch(){}
    
    //배치 시작(Scope에 담을 데이터 쿼리 동작)
    public override Database.QueryLocator start(Database.BatchableContext bc) {
        logwrap = new LogWrapper();//로그 기록

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
                                                , ScopeSize__c
                                                , NextBatchName__c
                                                , isScheduled__c
                                                , ScheduleClass__c
                                                , Interval__c
                                                , CronExpression__c
                                        FROM Batch_Sequence__mdt
                                        WHERE isScheduled__c = true
                                        ]);
    }
    
    public override void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug('IFN_ScheduleBatch execute!!');

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
            delList = [SELECT Id
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

            for(Batch_Sequence__mdt schedule : scList)
            {
                if(schedule.CronExpression__c != null && schedule.Interval__c == null)
                {
                    List<String> cronList = schedule.CronExpression__c.split(' ');

                    if(sTime == Integer.valueOf(cronList[2]))
                    {
                        IFN_Scheduler sch = new IFN_Scheduler(schedule.ScheduleClass__c,String.valueOf(schedule.ScopeSize__c));
                        system.schedule('[INTERFACE] ' + schedule.ScheduleClass__c.trim(), schedule.CronExpression__c, sch);

                        executeList.add(schedule);
                    }
                }
                else if(schedule.Interval__c != null)
                {
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
                    IFUtil.NextScheduleCheck(it.DeveloperName);
                }
            }

            logWrap.LogText.add(JSON.serialize(executeList));
        } 
        catch(System.Exception e) 
        {

            logWrap.ErrorText.add(e.getMessage());
            logWrap.LogText.add('### Exception.getMessage() = ' + e.getMessage());
            logWrap.LogText.add('### Exception.getLineNumber() = ' + e.getLineNumber());
            logWrap.LogText.add('### Exception.getStackTraceString() = ' + e.getStackTraceString());
        }
    }
}