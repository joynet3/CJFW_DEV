public  class IFN_DELETEIF_DATA_BATCH implements Database.Batchable<sObject>, Database.Stateful {

    public IFN_CommonLog utilLog = new IFN_CommonLog();	//로그 저장
    public IFN_CommonLog.logWrap logwrap = new IFN_CommonLog.logWrap();
    public List<IFN_CommonLog.LogWrap> logWrapList = new List<IFN_CommonLog.LogWrap>();

    private String tabNm = '';
    private String whereStr = '';

    public IFN_DELETEIF_DATA_BATCH(String pTabNm,String pWhere) {
        tabNm = pTabNm;
        whereStr = pWhere;
    }


    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
   
        logwrap = new IFN_CommonLog.logWrap('Dummy', 'Batch');//로그 기록
        
        logwrap.BatchCronId         = bc.getJobId();
        logwrap.BatchStartTime      = System.now();
        logwrap.ClassName           = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
        logwrap.LogText.add('### [Batch Start] ###\n');


        String query = ' SELECT Id FROM ' + this.tabNm + ' ' + this.whereStr;        
        logwrap.LogText.add('### query ###' + query +'\n');
        return Database.getQueryLocator(query);
                                       
    }
   
       public void execute(Database.BatchableContext info, List<SObject> deleteLst) 
       {
        

           try
           {
             logwrap.LogText.add('deleteLst ' + deleteLst.size() +'\n');
                Delete deleteLst;
            } catch(Exception e) {
               logWrap.ErrorText.add(e.getMessage());
           }
       }
   
   

       public void finish(Database.BatchableContext context) {
        
        try {
            String currentClassName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));            
            logwrap.LogText.add('### [Batch finish] ###');
            
        } catch(System.Exception e) {
            //logwrap.logText = '';
            logwrap.ErrorText.add(e.getStackTraceString() + ' / ' + e.getMessage());            
        }

        logWrapList.add(logwrap);
        if(!logWrapList.isEmpty()) utilLog.InsertLog(logWrapList);
    }
    
   }