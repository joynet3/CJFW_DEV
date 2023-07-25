/**
 * @description       : 
 * @author            : 안태진(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
public class IF_SFDC_SAP_REC_RELEASE {
    
    public IF_SFDC_SAP_REC_RELEASE() {}

    callCjCkSoapVer_2.sapCkInParameter inputData = new callCjCkSoapVer_2.sapCkInParameter();

    public class Input {
        public List<ReleaseH> header;
        public List<ReleaseD> detail;
    }

    public class Output {
        public Result result;
    }

    public class Result {
        public String resultCode;
        public String resultMessage;
        public String soapCallResult;
    }

    public class ReleaseH{
        public String IFDATE;
        public String EBELN;
        public String BSART;
        public String RESWK;
        public String EKORG;
        public String EKGRP;
        public String SND_YN;
        public String XDATS;
        public String XTIMS;
    }

    public class ReleaseD{
        public String ZTIMS;
        public String EBELN;
        public String EBELP;
        public String WERKS;
        public String LGORT;
        public String MATNR;
        public String MAKTX;
        public String CHARG;
        public String PBUDAT;
        public String MENGE;
        public String MEINS;
        public String RAUBE;
        public String EINDT;
        public String RETPO;
        public String BUDAT;
        public String SND_YN;
        public String PSMNG;
        public String R_PSMNG;
        public String RELEASEDKEY;
    }

    // public Output callOut() {
    public Output callOut(String sysdate) {
        Set<String> releaseEbelnDelSet = new Set<String>();
        Map<String, Id> id_ebelnMap = new Map<String, Id>();
        List<Release_H__c> releaseHList = new List<Release_H__c>(); 
        List<Release_D__c> releaseDList = new List<Release_D__c>(); 

        Result objResult = new Result();
        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '데이터가 성공적으로 수신 되었습니다.';
        String result = '';

        try {
            inputData.requestMsg = '{"sysdate" : "'+sysdate+'", "IF_ID" : "CK0003"}';
            system.debug('====================== requestMsg :::'+inputData.requestMsg);
            callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort soap = new callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort();
            result = soap.callSapCkProcedure(inputData);
            System.debug('=======================result:::'+result);

            if(result == '' || result == null) {
                strStatus = 'ERROR';
                strCode = '0003';
                strMessage = '수신받을 데이터가 없습니다.';
            }else {
                Input input = (Input)JSON.deserialize(result, Input.class);

                if (input.header == null || input.header.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = '수신받을 데이터가 없습니다.';
                }else if (input.detail == null || input.detail.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0002';
                    strMessage = '수신받을 데이터가 없습니다.';
                }else {
                    Map<String, String> mapSND_YN = CommonUtil.getMapPickListLabel('Release_H__c', 'Snd_Yn__c');
                    Set<String> releaseNoSet = new Set<String>();
                    List<RELEASE_H__c> delReleaseList = new List<RELEASE_H__c>();
                    List<RELEASE_H__c> updReleaseList = new List<RELEASE_H__c>();

                    for (ReleaseH obj : input.header) {
                        releaseNoSet.add(obj.EBELN);
                    }

                    delReleaseList = [
                        SELECT Id,IFDATE__c,EBELN__c,SND_YN__c,XDATS__c,XTIMS__c
                        FROM Release_H__c
                        WHERE Ebeln__c in: releaseNoSet 
                    ];

                    for (Release_H__c obj : delReleaseList) {
                        releaseEbelnDelSet.add(obj.Ebeln__c);
                    }

                    if (input.header <> null && input.header.size() > 0) {
                        for (ReleaseH obj : input.header) {
                            Release_H__c releaseObj = new Release_H__c();
                            if (releaseEbelnDelSet.contains(obj.EBELN)) {
                                continue;
                            }else {
                                releaseObj.IFDATE__c = Date.valueOf(obj.IFDATE);
                                releaseObj.EBELN__c = obj.EBELN;
                                releaseObj.Snd_Yn__c = mapSND_YN.get(obj.SND_YN);
                                releaseObj.Xdats__c = obj.XDATS;
                                releaseObj.Xtims__c = obj.XTIMS;
                                releaseHList.add(releaseObj);
                            }
                        }
                        System.debug('============= releaseHList :::' + releaseHList);
                    }

                    // if (input.header <> null && input.header.size() > 0) {
                    //     for (Integer i = 0; i < input.header.size(); i++) {
                    //         Release_H__c obj = new Release_H__c();
                    //         obj.IFDATE__c = Date.valueOf(input.header[i].IFDATE);
                    //         obj.EBELN__c = input.header[i].EBELN;
                    //         obj.Snd_Yn__c = mapSND_YN.get(input.header[i].SND_YN);
                    //         obj.Xdats__c = input.header[i].XDATS;
                    //         obj.Xtims__c = input.header[i].XTIMS;
                    //         releaseNoSet.add(input.header[i].EBELN);
                    //         releaseHList.add(obj);
                    //     }
                
                    insert releaseHList;

                    for (Release_H__c obj : releaseHList) {
                        id_ebelnMap.put(obj.Ebeln__c, obj.id);
                    }

                    if (input.detail <> null && input.detail.size() > 0) {
                        // Map<String, String> mapWERKS = CommonUtil.getMapPickListLabel('Release_D__c', 'WERKS__c');
                        for (Integer i = 0; i < input.detail.size(); i++) {
                            if (releaseEbelnDelSet.contains(input.detail[i].EBELN)) {
                                continue;
                            }else {
                            Release_D__c obj = new Release_D__c();
                            obj.Name = input.detail[i].MAKTX;
                            obj.EBELN__c = input.detail[i].EBELN;
                            obj.EBELP__c = input.detail[i].EBELP;
                            obj.WERKS__c = input.detail[i].WERKS;
                            obj.LGORT__c = input.detail[i].LGORT;
                            obj.MATNR__c = input.detail[i].MATNR;
                            obj.MAKTX__c = input.detail[i].MAKTX;
                            obj.CHARG__c = input.detail[i].CHARG;
                            obj.PBUDAT__c = Date.valueOf(input.detail[i].PBUDAT);
                            obj.MENGE__c = Decimal.valueOf(input.detail[i].MENGE);
                            obj.MEINS__c = input.detail[i].MEINS;
                            obj.RAUBE__c = input.detail[i].RAUBE;
                            obj.EINDT__c = Date.valueOf(input.detail[i].EINDT);
                            obj.RETPO__c = input.detail[i].RETPO;
                            obj.PSMNG__c = Decimal.valueOf(input.detail[i].PSMNG);
                            obj.R_PSMNG__c = Decimal.valueOf(input.detail[i].R_PSMNG);
                            // obj.BUDAT__c = Date.valueOf(input.detail[i].BUDAT);
                            obj.Release_H__c = id_ebelnMap.get(input.detail[i].EBELN);
                            obj.RELEASEDKEY__c = input.detail[i].RELEASEDKEY;
                            releaseDList.add(obj);
                            }
                        }
                        
                        System.debug('============= dtail list :::' + releaseDList);
                        insert releaseDList;
                    }    
                }    
            }
        } catch (Exception e) {
            strStatus = 'ERROR';
            strCode = '-1';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage(); 
            System.debug(strMessage);
        } finally {
            objResult.resultCode = strCode;
            objResult.resultMessage = strMessage;
            objResult.soapCallResult = result;

            objOutput.result = objResult;

            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'message:::' + strMessage + ':::result:::' + result;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = inputdata.requestMsg;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
        
            IFUtil objIF = new IFUtil('IF_SFDC_SAP_REC_RELEASE');
            objIF.setLog(LogWrapper);
        }

        return objOutput;
    }

}