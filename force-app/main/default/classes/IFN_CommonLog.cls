/**
* @Class : IFN_CommonLog
* @group Framework : Common
* @Author : 조일근 
* @Date : 2023. 07. 18
* @Version : 1.0
* @Description : 
* @Modified : 인터페이스 로그 공통 함수
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2023. 07. 18 | 조일근    | 최초작성
* */
global class IFN_CommonLog {
    
    public String className; //클래스명
    public List<AsyncApexJob> apexJobs;
    public AsyncApexJob apexJob;
    public ApexClass apexClass;
    public IFLog__c progLog;
    public LogWrap logWrap;

    public class LogWrap{
        @AuraEnabled public String        BatchCronId{get;set;}
        @AuraEnabled public Datetime      BatchEndTime{get;set;}
        @AuraEnabled public String        BatchParameter{get;set;}
        @AuraEnabled public Datetime      BatchStartTime{get;set;}
        @AuraEnabled public String        BatchUser{get;set;}
        @AuraEnabled public String        ClassName{get;set;}
        @AuraEnabled public String        ErrorCode{get;set;}
        @AuraEnabled public List<String>  ErrorText{get;set;}
        @AuraEnabled public String        RequestBody{get;set;}
        @AuraEnabled public String        RequestHeader{get;set;}
        @AuraEnabled public Datetime      RequestTime{get;set;}
        @AuraEnabled public String        ResponseBody{get;set;}
        @AuraEnabled public String        ResponseHeader{get;set;}
        @AuraEnabled public Datetime      ResponseTime{get;set;}
        @AuraEnabled public Integer       IFTotalCount{get;set;}
        @AuraEnabled public Integer       IFSuccessCount{get;set;}
        @AuraEnabled public Integer       IFFailCount{get;set;}
        @AuraEnabled public List<String>        LogText{get;set;}
        @AuraEnabled public IFMaster__c   IF_Program{get;set;}
        @AuraEnabled public String        IF_ProgramClassName{get;set;} // 2021 11 10 ClassName__c 김성규 추가
        @AuraEnabled public String        IF_ProgramDescription{get;set;} // 2021 11 10 Description__c 김성규 추가
        @AuraEnabled public String        Status{get;set;}
        @AuraEnabled public String        DMLInfo{get;set;}
        @AuraEnabled public String        DMLSuccessInfo{get;set;}
        @AuraEnabled public Integer       IFRequestSize{get;set;}
        @AuraEnabled public Integer       IFResponseSize{get;set;}
        @AuraEnabled public String        RecordTypeId{get;set;}
        @AuraEnabled public Boolean       isRealLogInsert{get;set;}        
        @AuraEnabled public String        resultCode{get;set;}
        @AuraEnabled public String        resultMessage{get;set;}

        public LogWrap(){}

        public LogWrap(String interfaceId, String type)
        {

            List<IFMaster__c> ifObj = [SELECT ID,Name, ClassName__c, Description__c, IsRealLogInsert__c,ContentType__c,Header__c,Method__c,Param1__c,Param2__c,Param3__c,Param4__c FROM IFMaster__c WHERE Name=:InterfaceId];


            if(!ifObj.isEmpty())
            {


                this.IF_ProgramClassName = ifObj[0].ClassName__c; 
                this.IF_ProgramDescription = ifObj[0].Description__c; 
                this.IF_Program  = ifObj[0];
                this.isRealLogInsert = ifObj[0].IsRealLogInsert__c;
            }
            else
            {
                ifObj = [SELECT ID,Name, ClassName__c, Description__c, IsRealLogInsert__c,ContentType__c,Header__c,Method__c,Param1__c,Param2__c,Param3__c,Param4__c FROM IFMaster__c WHERE Name LIKE '%Dummy%'];
                if(ifObj.size() > 0) {
                    this.IF_Program  = ifObj[0];
                }
                

                if('REAL'.equalsignorecase(type))
                {
                    this.isRealLogInsert = true;
                }
            }



            if('Batch'.equals(type))
            {
                this.BatchCronId            = '';
                this.BatchEndTime           = null;
                this.BatchParameter         = '';
                this.BatchStartTime         = null;
                this.BatchUser              = UserInfo.getUserId();
                this.RecordTypeId = Schema.getGlobalDescribe().get('IFLog__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Batch').getRecordTypeId();
            }
            else
            {
                this.RecordTypeId = Schema.getGlobalDescribe().get('IFLog__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Interface').getRecordTypeId();
            }
            this.IFTotalCount    = 0;
            this.IFSuccessCount  = 0;
            this.IFFailCount     = 0;
            this.ClassName       = '';
            this.ErrorCode       = '';
            this.ErrorText       = new List<String>();
            this.RequestBody     = '';
            this.RequestHeader   = '';
            this.RequestTime     = null;
            this.ResponseBody    = '';
            this.ResponseHeader  = '';
            this.ResponseTime    = null;
            this.LogText         = new List<String>();
            this.Status          = '';
            this.DMLInfo         = '';
            this.DMLSuccessInfo  = '';
            this.IFRequestSize  = 0;
            this.IFResponseSize = 0;
            this.resultCode     = '';
            this.resultMessage  = '';
        }

        public IFLog__c convert()
        {
            IFLog__c result = new IFLog__c();
            result.RecordTypeId = this.RecordTypeId;


            if(String.isNotBlank(this.BatchCronId))    result.BatchCronId__c       = this.BatchCronId;
            if(String.isNotBlank(this.BatchParameter)) result.BatchParameter__c    = this.BatchParameter;
            if(String.isNotBlank(this.ClassName))      result.ClassName__c         = this.ClassName;
            if(String.isNotBlank(this.ErrorCode))      result.ErrorCode__c         = this.ErrorCode;
            if(String.isNotBlank(this.RequestBody))    result.RequestBody__c    = getText(this.RequestBody);
            if(String.isNotBlank(this.RequestHeader))  result.RequestHeader__c  = this.RequestHeader;
            if(String.isNotBlank(this.ResponseBody))   result.ResponseBody__c   = getText(this.ResponseBody);
            if(String.isNotBlank(this.ResponseHeader)) result.ResponseHeader__c = this.ResponseHeader;

            if(this.BatchStartTime != null)  result.BatchStartTime__c   = this.BatchStartTime;
            if(this.BatchEndTime   != null)  result.BatchEndTime__c     = this.BatchEndTime;
            if(this.RequestTime    != null)  result.RequestTime__c      = this.RequestTime;
            if(this.ResponseTime   != null)  result.ResponseTime__c     = this.ResponseTime;
            //if(this.ErrorText      != null)  result.ErrorText__c        = getText(JSON.serialize(this.ErrorText));//orin
            if(this.ErrorText      != null)  result.ErrorText__c        = sanchoGetText(this.ErrorText);            //2023.11.16 sancho : 가독성 바꿔봄
            //if(this.LogText      != null)  result.LogText__c            = getText(JSON.serialize(this.LogText));  //orin
            if(this.LogText      != null)  result.LogText__c            = sanchoGetText(this.LogText);              //2023.11.16 sancho : 가독성 바꿔봄

            if(String.isNotBlank(this.resultCode))      result.resultCode__c    = this.resultCode;
            if(String.isNotBlank(this.resultMessage))   result.resultMessage__c = getText(this.resultMessage);

            if(this.IFRequestSize  != null && this.IFRequestSize > 0)   result.IF_RequestSize__c  = this.IFRequestSize;
            if(this.IFResponseSize != null && this.IFResponseSize > 0)  result.IF_ResponseSize__c = this.IFResponseSize;

            result.IFMaster__c  = this.IF_Program.Id;
            //result.Status__c      = this.ErrorText.isEmpty() ? 'Success' : 'Error';


            return result;
        }

        private String getText(String str)
        {
            return str.length() > 120000 ?  str.subString(0,120000) : str;
        }
        
        private String sanchoGetText(List<String> sLogText)
        {
            String str = '';
            for(String nowstr : sLogText){
                str += nowstr + '\n';
            }
            return str.length() > 120000 ?  str.subString(0,120000) : str;
        }
    }
    

    public void insertLog(List<IFN_CommonLog.LogWrap> logWrapList){

        List<IFLog__c> insertLogList = new List<IFLog__c>();
        
        try
        {
            Map<Id, AsyncApexJob> jobMap    = new Map<Id, AsyncApexJob>();
            Map<Id, ApexClass> apexClassMap = new Map<Id, ApexClass>();

            Set<Id> jobIds = new Set<Id>();

            for(IFN_CommonLog.LogWrap logWrap : logWrapList)
            {
                if(String.isNotBlank(logWrap.BatchCronId)) jobIds.add(logWrap.BatchCronId);
            }

            if(!jobIds.isEmpty()) jobMap = new Map<Id, AsyncApexJob>([SELECT Id,CreatedById, JobItemsProcessed, Status, TotalJobItems, ApexClassId FROM AsyncApexJob WHERE Id IN:jobIds]);

            Set<Id> apexClassIds = new Set<Id>();
            if(!jobMap.values().isEmpty())
            {
                for(AsyncApexJob job : jobMap.values()){
                    apexClassIds.add(job.ApexClassId);
                }
            }

            if(!apexClassIds.isEmpty()) apexClassMap = new Map<Id, ApexClass>([SELECT Id,Name FROM ApexClass WHERE Id IN:apexClassIds]);
			
     
            for(IFN_CommonLog.LogWrap logWrap : logWrapList)
            {
                
                IFLog__c log = logWrap.convert();
                
                if(log.BatchEndTime__c == null) log.BatchEndTime__c = System.now();
                
                if(String.isNotBlank(log.BatchCronId__c)){
                    if(jobMap.containsKey(log.BatchCronId__c)){

                        AsyncApexJob job = jobMap.get(log.BatchCronId__c);
                        log.BatchTotalJobItems__c     = job?.TotalJobItems;
                        log.BatchJobItemsProcessed__c = job?.JobItemsProcessed;
                        log.BatchUser__c              = job?.CreatedById;

                        String className = apexClassMap.containsKey(job.ApexClassId) ? apexClassMap.get(job.ApexClassId)?.Name : '';
    
                        log.ClassName__c = className;
                    }
                } 

                insertLogList.add(log);
            }

            INSERT insertLogList;
        }
        catch(Exception e)
        {
            System.debug('### insertLog Exception Message = ' + e.getMEssage()  + ' : line : ' + e.getLineNumber());
        }
    }

    public void insertLog(IFN_CommonLog.LogWrap logWrap)
    {

        progLog = new IFLog__c();
        try
        {            
            if(logWrap != null){

                
                progLog = logWrap.convert();
                
                if(String.isNotBlank(progLog.BatchCronId__c)) 
                {

                    //처리중인 배치 클래스명 찾기
                    apexJobs = new List<AsyncApexJob>();
                    apexJobs = [SELECT CreatedById, JobItemsProcessed, Status, TotalJobItems, ApexClassId FROM AsyncApexJob
                                WHERE Id =: progLog.BatchCronId__c];
                                
                    if(!apexJobs.isEmpty())
                    {
                        apexJob = apexJobs[0];
                        progLog.BatchTotalJobItems__c     = apexJob.TotalJobItems;
                        progLog.BatchJobItemsProcessed__c = apexJob.JobItemsProcessed;
                        progLog.BatchUser__c              = apexJob.CreatedById;

                        apexClass = new ApexClass();
                        apexClass = [SELECT Id, Name FROM ApexClass WHERE Id =: apexJob.ApexClassId];
                        progLog.ClassName__c = apexClass.Name;
                    }
                    
                } 


                Insert progLog;
            }
            //로그 적재중 에러 발생시 기존 로그 초기화 후 에러 텍스트만 기록 및 Insert
        } 
        catch(Exception e) 
        {

            progLog.ErrorText__c += e.getStackTraceString() + ' / ' + e.getMessage();
            progLog.Status__c    = 'Error';

            insert progLog;
        }
    }


    
}