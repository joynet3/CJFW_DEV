/**
 * @Class : IFN_ManagementController.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.08.29
 * @Version : 1.0
 * @Description : 인터페이스 메니져
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.29 | 조일근  | 최초작성
 * */
public class IFN_ManagementController {


    /**										
     * @Description: Interface, Batch Data 조회.							
    */	
    @AuraEnabled 
    public static Data getData()
    {
        List<InterfaceData> interfaceDataList = new List<InterfaceData>();
        List<BatchData> batchDataList = new List<BatchData>();
        
        try
        {
        
            List<IFMaster__c> ifProgramList = [SELECT Id
                                                        , Name
                                                        , ClassName__c
                                                        , TargetSystem__c
                                                        , Description__c
                                                        , CallORBatch__c
                                                        , ExampleBody__c
                                                        , BatchClass__c 
                                                        , ExecuteCode__c 
                                                        , project__c
                                                    FROM IFMaster__c 
                                                    WHERE CallORBatch__c != null
                                                    AND TargetSystem__c != null
                                                    AND EndPoint__c != ''
                                                    ORDER BY TargetSystem__c, Name];
            
            if(!ifProgramList.isEmpty())
            {
                Map<String, List<Example>> examPleMap = new Map<String, List<Example>>();  //Real Interface example map
                Map<String, List<BatchItem>> batchItemMap = new Map<String,List<BatchItem>>(); //Batch Interface map
                
                for(IFMaster__c program : ifProgramList)
                {

                    // 좌측 시스템 구분 생성 
                    if(examPleMap.containsKey(program.TargetSystem__c))
                    {
                        List<Example> exampleList = examPleMap.get(program.TargetSystem__c);
                        exampleList.add(new Example(program));
                        examPleMap.put(program.TargetSystem__c, exampleList);
                    }
                    else
                    {
                        examPleMap.put(program.TargetSystem__c, new List<Example>{new Example(program)});
                    }


                    if(String.isNotBlank(program.BatchClass__c))
                    {
                        if(batchItemMap.containsKey(program.TargetSystem__c))
                        {
                            List<BatchItem> batchItemList = batchItemMap.get(program.TargetSystem__c);
                            batchItemList.add(new BatchItem(program));
                            batchItemMap.put(program.TargetSystem__c, batchItemList);
                        }
                        else
                        {
                            batchItemMap.put(program.TargetSystem__c, new List<BatchItem>{new BatchItem(program)});
                        }
                    }

                }

                if(!examPleMap.isEmpty())
                {
                    Set<String> examPleMapKeys = examPleMap.keySet();

                    for(String key : examPleMapKeys)
                    {
                        interfaceDataList.add(new InterfaceData(key, examPleMap.get(key)));
                    }
                }


                if(!batchItemMap.isEmpty())
                {
                    Set<String> batchItemMapKeys = batchItemMap.keySet();

                    for(String key : batchItemMapKeys)
                    {
                        batchDataList.add(new BatchData(key, batchItemMap.get(key)));
                    }
                }

            }
        }// try end
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage() + ' / ' + e.getLineNumber());
        }

        return new Data(interfaceDataList, batchDataList);
    }


    /**										
     * @Description: Interface 호출				
     * @Param:  
     *  IFMgmt : targetSystem : 호출 시스템, interfaceId : Interface Id, params : Parameter (JSON형식)			
    */	
    @AuraEnabled
    public static Object getResponse(IFMgmt param){
        Object res;
        IFN_CalloutResult result = new IFN_CalloutResult();

        try {

            System.debug('=========================================');
            System.debug(param.project);
            System.debug(param.targetSystem);
            switch on param.targetSystem {
                when 'LIF1002'{
                    
                    result = new IFN_LIF1002_Callout(param.interfaceId,'Real').getResponse(param.interfaceId, param.params);
                    res = Json.serialize(result);
                }
                when 'EIF1001'{
                    if('IFN_EIF1001_FS001_MD001'.equals(param.interfaceId)) {
                        String getRquest = '';

                        API_Authenticationkey__mdt authKey =    [SELECT KeyValue__c, DateRange__c, MasterLabel FROM API_Authenticationkey__mdt WHERE MasterLabel = '식품의약품안전처_Key'];

                        getRquest += '/' + authKey.KeyValue__c;
                        getRquest += '/' + 'I1250';                 //서비스명
                        getRquest += '/' + 'json';                  //json or xml
                        getRquest += '/1/1000';                     //from~to
                        
                        //1.전용유 픽스
                        getRquest += '/' + 'PRDLST_NM=%EC%A0%84%EC%9A%A9%EC%9C%A0'; //전용유 

                        param.params = getRquest;
                    }
                    result = new IFN_EIF1001_Callout(param.interfaceId,'Real').getResponse(param.interfaceId, param.params);
                    res = Json.serialize(result);
                }                
                when else {
                    result.setResult('E', 'Method parameter check', null);
                    res = result;
                }
            }


        } catch (Exception e) {
            res = e.getMessage() + ' / ' + e.getLineNumber();
        }

        return res;
    }


    /**										
     * @Description: Batch OR Queueable 실행 				
     * @Param:  
     *  IFMgmt :  IFMgmt.batchClass : Batch Class Name , IFMgmt.batchOrqueueable : Batch 인지 Queueable인지 구분	
    */	
    @AuraEnabled
    public static Id execute(IFMgmt param){
        Id result = null;
        try {
            if('Batch'.equals(param.batchOrqueueable))
            {
                result = Database.executeBatch((Database.Batchable<SObject>)Type.forName(param.batchClass).newInstance(), 1);
            }
            else
            {
                result = System.enqueueJob((System.Queueable)Type.forName(param.batchClass).newInstance());
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' / ' + e.getLineNumber());
        }

        return result;
    }


    @AuraEnabled
    public static String doExecuteAnonymous(String code)
    {
        try
        {
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + getUserSessionId());
            req.setHeader('Content-Type', 'application/json');
            
            req.setEndpoint(
                Url.getOrgDomainUrl().toExternalForm()
            +   '/services/data/v51.0/tooling/executeAnonymous/?anonymousBody='
            +   EncodingUtil.urlEncode(code, 'UTF-8')
            );
            req.setMethod('GET');

            Http h = new Http();
            HttpResponse res = h.send(req);

            return res.getBody();
        }
        catch (Exception e)
        {
            throw new AuraHandledException(e.getMessage() + ' / ' + e.getLineNumber());
        }

    }
 

    /**
     * 참고 : https://salesforce.stackexchange.com/questions/223809/salesforce-lightning-how-can-i-get-session-id-of-current-user-in-salesforce-lig
     */
    public static String getUserSessionId(){
        String sessionId = '';
       // Refer to the Page
       PageReference reportPage = Page.CJFW_UserSession;
       // Get the content of the VF page
       String vfContent = '';
       if(!Test.isRunningTest()) 
       { 
        vfContent = reportPage.getContent().toString();
       }
       else
       {
        vfContent = 'Start_Of_Session_Id12345End_Of_Session_Id';
       }
       
       // Find the position of Start_Of_Session_Id and End_Of_Session_Id
       Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
       endP = vfContent.indexOf('End_Of_Session_Id');
       // Get the Session Id
       sessionId = vfContent.substring(startP, endP);
       System.debug('sessionId '+sessionId);
       // Return Session Id
       return sessionId;
    }

    /**										
     * @Description: getData return Class		
    */	
    public class Data
    {
        @AuraEnabled public List<InterfaceData> interfaceData{get;set;}
        @AuraEnabled public List<BatchData> batchData{get;set;}

        public Data(){}

        public Data(List<InterfaceData> interfaceData, List<BatchData> batchData)
        {
            this.interfaceData     = interfaceData;
            this.batchData         = batchData;
        }
    }


    /**										
     * @Description: InterfaceData Class		
    */
    public class InterfaceData
    {
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public List<IFDiv> ifdiv{get;set;}
        @AuraEnabled public List<Example> example{get;set;}

        public InterfaceData(){}

        public InterfaceData(String name, List<Example> example)
        {
            this.name    = name;
            this.label   = name;
            this.example = example;
        }
    }

    /**										
     * @Description: IFDiv Class		
    */
    public class IFDiv
    {
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public String label{get;set;}

        public IFDiv(){}

        public IFDiv(IFMaster__c program)
        {
            this.name         = program.project__c + '-' + program.TargetSystem__c;
            this.label        = program.project__c + '-' + program.TargetSystem__c;
        }
    }


    /**										
     * @Description: Example Class		
    */
    public class Example
    {
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String example{get;set;}
        @AuraEnabled public String targetSystem{get;set;}
        @AuraEnabled public String project{get;set;}
        @AuraEnabled public String division{get;set;}
        @AuraEnabled public String divLabel{get;set;}

        public Example(){}

        public Example(IFMaster__c program)
        {
            this.name         = program.Name;
            this.label        = program.Name + '(' + program.Description__c + ')';
            this.example      = program.ExampleBody__c;
            this.targetSystem = program.TargetSystem__c;
            this.project      = program.project__c;
            this.division     = program.TargetSystem__c;
            this.divLabel     = program.project__c + '-' + program.TargetSystem__c;
        }
    }


    /**										
     * @Description: BatchData Class		
    */
    public class BatchData
    {
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public List<BatchItem> item{get;set;}

        public BatchData(){}

        public BatchData(String name, List<BatchItem> item)
        {
            this.name = name;
            this.item = item;
        }
    }


    /**										
     * @Description: BatchItem Class		
    */
    public class BatchItem
    {
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String batchClass{get;set;}
        @AuraEnabled public String batchORqueueable{get;set;}
        @AuraEnabled public String executeCode{get;set;}

        @AuraEnabled public String project{get;set;}
        @AuraEnabled public String division{get;set;}
        @AuraEnabled public String divLabel{get;set;}

        public BatchItem(){}

        public BatchItem(IFMaster__c program)
        {
            this.label            = program.Name + '(' + program.Description__c + ')';
            this.batchClass       = program.BatchClass__c;
            this.batchORqueueable = program.BatchClass__c.contains('Batch') ? 'Batch' : 'Queueable';
            this.executeCode      = program.ExecuteCode__c;

            this.project      = program.project__c;
            this.division     = program.TargetSystem__c;
            this.divLabel     = program.project__c + '-' + program.TargetSystem__c;
                        
        }
    }

    public class IFMgmt{
        @AuraEnabled public String interfaceId{get;set;}
        @AuraEnabled public String targetSystem{get;set;}
        @AuraEnabled public Object params{get;set;}
        @AuraEnabled public String division{get;set;}
        @AuraEnabled public String batchClass{get;set;}
        @AuraEnabled public String batchOrqueueable{get;set;}
        @AuraEnabled public String project{get;set;}
    }
}