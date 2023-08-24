/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-02-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
@RestResource(urlMapping= '/sap/info/release')
global without sharing class IF_SAP_SFDC_INFO_RELEASE {
    public IF_SAP_SFDC_INFO_RELEASE() {}

    global class Input {
        public List<ReleaseH> release_Hlist;
        public List<ReleaseD> release_Dlist;
    }

    global class Output {
        public Result result;
        public ResultData resultData;
    }

    global class Result {
        public String resultCode;
        public String resultMessage;
    }

    global class ResultData {
    }

    global class ReleaseH{
        public String ZTIMS;
        public String IFDATE;
        public String EBELN;
        public String BSART;
        public String RESWK;
        public String EKORG;
        public String EKGRP;
        public String SND_YN;
        public String SHIP_TYP;
        public String XDATS;
        public String XTIMS;
    }

    global class ReleaseD{
        public String ZTIMS;
        public String EBELN;
        public String EBELP;
        public String WERKS;
        public String LGORT;
        public String MATNR;
        public String MAKTX;
        public String CHARG;
        public String MENGE;
        public String MEINS;
        public String RAUBE;
        public String EINDT;
        public String RETPO;
        public String BUDAT;
        public String SND_YN;
        public String PSMNG;
        public String R_PSMNG;
    }

    @HttpPost
    global static Output doPost() {
        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = 'Data has been successfully inserted';

        Result objResult = new Result();
        ResultData resultData = new ResultData();

        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        List<Release_H__c> releaseHList = new List<Release_H__c>(); 
        List<Release_D__c> releaseDList = new List<Release_D__c>(); 

        String requestBody = '';

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            LogWrapper.requestBody = requestBody;     
            
            if(requestBody == '' || requestBody == null) {
                strStatus = 'ERROR';
                strCode = '-1';
                strMessage = 'request body value does not exist';
            }else {
                Input input = (Input)JSON.deserialize(requestBody, Input.class);

                if (input.release_Hlist == null || input.release_Hlist.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = 'release_Hlist is null';
                }else if (input.release_Dlist == null || input.release_Dlist.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0002';
                    strMessage = 'release_Dlist is null';
                }else {
                    Map<String, Id> id_ebelnMap = new Map<String, Id>();
                    Map<String, String> mapSND_YN = CommonUtil.getMapPickListLabel('Release_H__c', 'Snd_Yn__c');
                    Set<String> releaseNoSet = new Set<String>();

                    if (input.release_Hlist <> null && input.release_Hlist.size() > 0) {
                        for (Integer i = 0; i < input.release_Hlist.size(); i++) {
                            Release_H__c obj = new Release_H__c();
                            obj.IFDATE__c = Date.valueOf(input.release_Hlist[i].IFDATE);
                            obj.EBELN__c = input.release_Hlist[i].EBELN;
                            obj.Snd_Yn__c = mapSND_YN.get(input.release_Hlist[i].SND_YN);
                            obj.Xdats__c = input.release_Hlist[i].XDATS;
                            obj.Xtims__c = input.release_Hlist[i].XTIMS;
                            releaseNoSet.add(input.release_Hlist[i].EBELN);
                            releaseHList.add(obj);
                        }
                
                            upsert releaseHList EBELN__c;

                            releaseHList = [SELECT Id,EBELN__C FROM Release_H__c WHERE EBELN__c in:releaseNoSet];
                            System.debug('===========releaseHList=='+releaseHList);
                        for (Release_H__c obj : releaseHList) {
                            id_ebelnMap.put(obj.EBELN__c, obj.Id);
                        }
                        System.debug('==================id_ebelnMap++++'+id_ebelnMap);
                        
                    }    
                    if (input.release_Dlist <> null && input.release_Dlist.size() > 0) {
                        // Map<String, String> mapWERKS = CommonUtil.getMapPickListLabel('Release_D__c', 'WERKS__c');
                        for (Integer i = 0; i < input.release_Hlist.size(); i++) {
                            Release_D__c obj = new Release_D__c();
                            obj.EBELN__c = input.release_Dlist[i].EBELN;
                            obj.EBELP__c = input.release_Dlist[i].EBELP;
                            obj.WERKS__c = input.release_Dlist[i].WERKS;
                            // obj.LGORT__c = input.release_Dlist[i].LGORT;
                            obj.MATNR__c = input.release_Dlist[i].MATNR;
                            obj.MAKTX__c = input.release_Dlist[i].MAKTX;
                            obj.CHARG__c = input.release_Dlist[i].CHARG;
                            obj.MENGE__c = Decimal.valueOf(input.release_Dlist[i].MENGE);
                            obj.MEINS__c = input.release_Dlist[i].MEINS;
                            obj.RAUBE__c = input.release_Dlist[i].RAUBE;
                            obj.EINDT__c = Date.valueOf(input.release_Dlist[i].EINDT);
                            obj.RETPO__c = input.release_Dlist[i].RETPO;
                            obj.PSMNG__c = Decimal.valueOf(input.release_Dlist[i].PSMNG);
                            obj.R_PSMNG__c = Decimal.valueOf(input.release_Dlist[i].R_PSMNG);
                            
                            // obj.BUDAT__c = Date.valueOf(input.release_Dlist[i].BUDAT);
                            obj.Release_H__c = id_ebelnMap.get(input.release_Dlist[i].EBELN);
                            releaseDList.add(obj);
                        }
                        
                        System.debug('===========orderHList==' + releaseDList);
                        insert releaseDList;
                    }    
                }
            }
        } catch (Exception e){
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();
        }

        objResult.resultCode = strCode;
        objResult.resultMessage = strMessage;
        
        objOutput.resultData = resultData;
        objOutput.result = objResult;        

        LogWrapper.status = strStatus;
        LogWrapper.resultCode = strCode;
        LogWrapper.resultMessage = strMessage;
        LogWrapper.responseTime = Datetime.now();
        LogWrapper.requestBody = requestBody;
        LogWrapper.responseBody = JSON.serialize(objOutput);
        
        IFUtil objIF = new IFUtil('IF_SAP_SFDC_INFO_RELEASE');
        objIF.setLog(LogWrapper);

        return objOutput;
    }

}