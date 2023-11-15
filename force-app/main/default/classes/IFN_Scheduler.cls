/**
* @Class : IFN_Scheduler
* @group Framework : Common
* @Author : 조일근 
* @Date : 2023. 07. 18
* @Version : 1.0
* @Description : 
* @Modified : 배치/큐러블 스케쥴러 (IFN_ScheduleBatch 에서 호출하여 사용)
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2023. 07. 18 | 조일근    | 최초작성
* */

public class IFN_Scheduler implements Schedulable {
    public String scheduleClass;
    public Integer scopSize;

    public IFN_Scheduler(String scheduleClass,String scopSize)
    {
        this.scheduleClass = scheduleClass;
        this.scopSize = String.isBlank(scopSize) ? 1 : Integer.valueOf(scopSize);
    }

    //system.schedule('[PLMX] B2BI_PLMX_EA_COLORDEVORDER_01 (ColorDevOrder Search)', '0 22 * * * ?', new IFN_Scheduler());
    public void execute(SchedulableContext SC){

        Type tp = Type.forName(this.scheduleClass.trim());
        
        if(this.scheduleClass.contains('Queueable') || this.scheduleClass.contains('_que'))
        {
            Queueable job = (Queueable)tp.newInstance();
            System.enqueueJob(job);
        }
        else if(this.scheduleClass.contains('Batch') || this.scheduleClass.contains('_ba'))
        {
            Database.Batchable<sObject> job = (Database.Batchable<sObject>)tp.newInstance();
            Database.executeBatch(job,this.scopSize);
        }
        System.debug('scopSize : ' + scopSize);
    }
}