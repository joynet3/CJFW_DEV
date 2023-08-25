/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : AhnTaeJin(tj.ahn@daeunextier.com)
**/
public with sharing class IF_API_Franchise_TEST {
    public IF_API_Franchise_TEST() {}

    public class Output {
        public Result result;
    }

    public class Result {
        public String resultCode;
        public String resultMessage;
        public List<Map<String,Object>> resultMapList;
    }

    public Output callOut(){
        Result objResult = new Result();
        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'callout success';
        String result = '';
        String getAdress = '';

        List<Map<String,Object>> dataMapList = new List<Map<String,Object>>();

        try {
            IFMaster__c franchiseIF = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = 'IF_API_Franchise_TEST'];
            API_Authenticationkey__mdt authKey = [select KeyValue__c, MasterLabel from API_Authenticationkey__mdt where MasterLabel = '프랜차이즈_일반_Encoding'];
            getAdress += ('uddi:13bb1a02-1166-4d0e-a349-e7f04047772b');
            getAdress += ('?page=1');
            getAdress += ('&perPage=2000');
            getAdress += ('&returnType=json');
            getAdress += ('&serviceKey=' + authKey.KeyValue__c);
            System.debug('======================:::getAdress' + getAdress);
    
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(franchiseIF.Endpoint__c + getAdress);
            request.setHeader('content-type', franchiseIF.ContentType__c);
            request.setMethod(franchiseIF.Method__c);
    
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                result = response.getBody();
                System.debug('======================:::result' + result);
                Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> myMapObjects = (List<Object>) resultMap.get('data');
                for (Object obj : myMapObjects) {
                    dataMapList.add((Map<String, Object>)obj);
                }
                System.debug(JSON.serialize(resultMap.get('data')));
                for (Integer i = 0; i < 5; i++) {
                    System.debug('======================:::dataMapList 브랜드명:::' + dataMapList[i].get('브랜드명'));
                }
            }else {
                strCode = '-1';
                strStatus = 'ERROR';
                strMessage = 'httpcallout error';
            }
        } catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
        } finally {
            objResult.resultCode = strCode;
            objResult.resultMessage = strMessage;
            objResult.resultMapList = dataMapList;
            
            objOutput.result = objResult;

            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'strMessage:::' + strMessage;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = getAdress;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
            IFUtil objIF = new IFUtil('IF_API_Franchise_TEST');
            objIF.setLog(LogWrapper);
        }
        System.debug('======================Output:::' + objOutput);
        return objOutput;
    }
}