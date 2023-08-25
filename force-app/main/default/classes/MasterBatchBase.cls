/**
* @Class : MasterBatchBase
* @group Framework : Common
* @Author : 조일근 
* @Date : 2023. 07. 18
* @Version : 1.0
* @Description : 
* @Modified : 인터페이스 배치에 공통적으로 사용하는 기능을 모아놓은 마스터 배치 ex) 로그기록, 다음 배치 체크 및 실행 등
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2023. 07. 18 | 조일근    | 최초작성
* */


public abstract inherited sharing class MasterBatchBase implements Database.Batchable<sObject>, Database.Stateful {
    public Date 		ifDate;			 //Interface Date
    public Date         stD;             //Interface Date
    public Date         edD;             //Interface Date
    public DateTime     stdt;               //stD 를 기반으로한 조회 시작일시
    public DateTime     eddt;               //edD 를 기반으로한 조회 종료일시
    public Boolean      isContinue = false;   //후속 배치 실행 여부
    public Boolean      isSchedule = true;
    public Integer      gCnt = 0;               //guess count
    public Integer      tCnt = 0;               //total count
    public IFN_CommonLog utilLog = new IFN_CommonLog();	//로그 저장
    public Boolean isTest = false;	//테스트시 true
    public Boolean filter = false;

    public String successJson;
    public String failJson;


    public IFN_CommonLog.logWrap logwrap = new IFN_CommonLog.logWrap();
    public List<IFN_CommonLog.LogWrap> logWrapList = new List<IFN_CommonLog.LogWrap>();


    //공통변수
    public String param1 = '';
    public String param2 = '';
    public String param3 = '';
    public String param4 = '';


    
    public abstract Database.QueryLocator start(Database.BatchableContext context);
    public abstract void execute(Database.BatchableContext context, SObject[] scope);
    
    public void finish(Database.BatchableContext context) {
        
        try {
            String currentClassName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
            System.debug('currentClassName : ' + currentClassName);
            
            logwrap.LogText.add('### [Batch finish] ###');
            logwrap.BatchEndTime = System.now();
            System.debug('### [Batch finish] ###');
            logWrapList.add(logwrap);
            System.debug('### [logwrap] ### : '  + logwrap);
            if(!logWrapList.isEmpty()) utilLog.InsertLog(logWrapList);
            
            //isContinue = true이면 다음 배치 수행(Metadata) / 기본값 : false
            if(isContinue) IFN_Util.NextBatchCheck(currentClassName);
            //스케줄 체크
            if(isSchedule) IFN_Util.NextScheduleCheck(currentClassName);
            
        } catch(System.Exception e) {
            logwrap.ErrorText.add(e.getStackTraceString() + ' / ' + e.getMessage());
            
            utilLog = new IFN_CommonLog();
            utilLog.insertLog(logwrap);
        }
    }
}