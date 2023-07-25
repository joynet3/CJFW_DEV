/**
 * @description       : 
 * @author            : 안태진
 * @group             : 
 * @last modified on  : 06-24-2022
 * @last modified by  : 안태진(tj.ahn@daeunextier.com)
**/
public class IF_SFDC_SAP_SAND_RELEASE {
    public IF_SFDC_SAP_SAND_RELEASE() {}

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
        public String ZTIMS;
        public String IFDATE;
        public String EBELN;
        public String BSART;
        public String RESWK;
        public String EKORG;
        public String EKGRP;
        public String SND_YN;
        public String XDATS;
        public String XTIMS;
        public String XMSGS;
        public String xstat;
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

    public Output callOut() {
        callCjCkSoapVer_2.sapCkInParameter inputData = new callCjCkSoapVer_2.sapCkInParameter();
        List<RELEASE_H__c> inputHeader = new List<RELEASE_H__c>(); 
        List<RELEASE_D__c> inputDetail = new List<RELEASE_D__c>();
        List<RELEASE_H__c> targetHList = new List<RELEASE_H__c>(); 
        List<RELEASE_H__c> updateHList = new List<RELEASE_H__c>(); 
        Map<String,Object> inputMap = new Map<String,Object>();

        Result objResult = new Result();
        Output objOutput = new Output();
        LogWrapper LogWrapper = new LogWrapper();
        LogWrapper.requestTime = Datetime.now();

        String strStatus = 'SUCCESS';
        String strCode = '0000';
        String strMessage = '확정 데이터 전송 성공';
        String result = '';
        String inputString = '';
        
        try {
            inputHeader = [
                SELECT IFDATE__c,
                EBELN__c,
                SND_YN__c,
                XDATS__c,
                XTIMS__c,
                xmsgs__c
                FROM RELEASE_H__c
                WHERE CHECK__c = 'Y' AND CONFIRM__c = 'N'
            ];
            inputDetail = [
                SELECT EBELN__c,
                EBELP__c,
                WERKS__c,
                LGORT__c,
                MATNR__c,
                MAKTX__c,
                CHARG__c,
                PBUDAT__c,
                MENGE__c,
                MEINS__c,
                RAUBE__c,
                EINDT__c,
                RETPO__c,
                PSMNG__c,
                R_PSMNG__c,
                RELEASEDKEY__c,
                xmsgs__c
                FROM RELEASE_D__c
                WHERE RELEASE_H__r.CHECK__c = 'Y' AND RELEASE_H__r.CONFIRM__c = 'N'
            ];

            inputMap.put('header', inputHeader);
            inputMap.put('detail', inputDetail);
            inputMap.put('IF_ID', 'CK0004');

            inputString = JSON.serialize(inputMap);
            inputData.requestMsg = inputString;

            System.debug('========================requestMsg :::'+inputData.requestMsg);

            callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort soap = new callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort();
            result = soap.callSapCkProcedure(inputData);
            System.debug('result======================= :::'+result);

            if(result == '' || result == null) {
                strStatus = 'ERROR';
                strCode = '0003';
                strMessage = '확정 데이터 전송 실패';
            }else {
                Input input = (Input)JSON.deserialize(result, Input.class);

                if (input.header == null || input.header.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0001';
                    strMessage = '확정 데이터 전송 실패';
                }else if (input.detail == null || input.detail.size() < 1) {
                    strStatus = 'ERROR';
                    strCode = '0002';
                    strMessage = '확정 데이터 전송 실패';
                }
                else {
                    Map<String, RELEASE_H__c> mapUpOrder = new Map<String, RELEASE_H__c>();
    
                    if (input.header <> null && input.header.size() > 0) {
                        targetHList = [
                            SELECT Id, IFDATE__c,  EBELN__c, SND_YN__c, XDATS__c, XTIMS__c, xmsgs__c
                            FROM RELEASE_H__c
                            WHERE CHECK__c = 'Y' AND CONFIRM__c = 'N'
                        ];
                        System.debug('==================targetList:::'+targetHList);

                        for (RELEASE_H__c obj : targetHList) {
                            mapUpOrder.put(obj.EBELN__C, obj);
                        }
                        System.debug(('====================mapUpOrder:::' + mapUpOrder));
                        if (!targetHList.isEmpty()) {
                            for (ReleaseH obj : input.header) {
                                RELEASE_H__c releaseHObj = new RELEASE_H__c();
                                releaseHObj = mapUpOrder.get(obj.EBELN);
                                releaseHObj.Confirm__c = 'Y';
                                // releaseHObj.xmsgs__c = obj.XMSGS;
                                // releaseHObj.xstat__c = obj.xstat;
                                updateHList.add(releaseHObj);
                            }
                            System.debug('====================updateHList:::' + updateHList);
                            update updateHList;
                        }else {
                            strCode = '0004';
                            strMessage = '확정 데이터 전송 실패';
                            strStatus = 'ERROR';
                        }
                    }
                }
            }
        } catch (Exception e) {
            strCode = '-1';
            strStatus = 'ERROR';
            strMessage = e.getLineNumber() + e.getStackTraceString() + e.getMessage();
            System.debug(strMessage);
        }finally{

            objResult.resultCode = strCode;
            objResult.resultMessage = strMessage;
            objResult.soapCallResult = result;

            objOutput.result = objResult;

            LogWrapper.status = strStatus;
            LogWrapper.resultCode = strCode;
            LogWrapper.resultMessage = 'strMessage:::' + strMessage + ':::soapCallResult:::' + result;
            LogWrapper.responseTime = Datetime.now();
            LogWrapper.requestBody = inputString;
            LogWrapper.responseBody = result;
            System.debug('===========================finally:::'+strMessage+'  status:::'+strStatus+'  code:::'+strCode);
            
            IFUtil objIF = new IFUtil('IF_SFDC_SAP_SAND_RELEASE');
            objIF.setLog(LogWrapper);
        }
        return objOutput;
    }
    // public Output callOut(Boolean isRetry) {
    //     callCjCkSoapVer_2.sapCkInParameter inputData = new callCjCkSoapVer_2.sapCkInParameter();
    //     List<RELEASE_H__c> inputHeader = new List<RELEASE_H__c>(); 
    //     List<RELEASE_D__c> inputDetail = new List<RELEASE_D__c>();
    //     List<RELEASE_H__c> targetHList = new List<RELEASE_H__c>(); 
    //     List<RELEASE_H__c> updateHList = new List<RELEASE_H__c>(); 
    //     Map<String,Object> inputMap = new Map<String,Object>();

    //     Result objResult = new Result();
    //     Output objOutput = new Output();
    //     LogWrapper LogWrapper = new LogWrapper();
    //     LogWrapper.requestTime = Datetime.now();

    //     String strStatus = 'SUCCESS';
    //     String strCode = '0000';
    //     String strMessage = 'Soap Call Success';
    //     String result = '';
    //     String inputString = '';
        
    //     try {
    //         if(!isRetry){
    //             inputHeader = [
    //                 SELECT IFDATE__c,
    //                 EBELN__c,
    //                 SND_YN__c,
    //                 XDATS__c,
    //                 XTIMS__c,
    //                 xmsgs__c
    //                 FROM RELEASE_H__c
    //                 WHERE CHECK__c = 'Y' AND CONFIRM__c = 'N'
    //             ];
    //             inputDetail = [
    //                 SELECT EBELN__c,
    //                 EBELP__c,
    //                 WERKS__c,
    //                 LGORT__c,
    //                 MATNR__c,
    //                 MAKTX__c,
    //                 CHARG__c,
    //                 PBUDAT__c,
    //                 MENGE__c,
    //                 MEINS__c,
    //                 RAUBE__c,
    //                 EINDT__c,
    //                 RETPO__c,
    //                 PSMNG__c,
    //                 R_PSMNG__c,
    //                 RELEASEDKEY__c,
    //                 xmsgs__c
    //                 FROM RELEASE_D__c
    //                 WHERE RELEASE_H__r.CHECK__c = 'Y' AND RELEASE_H__r.CONFIRM__c = 'N'
    //             ];
    //         }else {
    //             inputHeader = [
    //                 SELECT IFDATE__c,
    //                 EBELN__c,
    //                 SND_YN__c,
    //                 XDATS__c,
    //                 XTIMS__c,
    //                 xmsgs__c
    //                 FROM RELEASE_H__c
    //                 WHERE (CHECK__c = 'Y' AND CONFIRM__c = 'N') /*OR EBELN_R__c = ''*/
    //             ];
    //             inputDetail = [
    //                 SELECT EBELN__c,
    //                 EBELP__c,
    //                 WERKS__c,
    //                 LGORT__c,
    //                 MATNR__c,
    //                 MAKTX__c,
    //                 CHARG__c,
    //                 PBUDAT__c,
    //                 MENGE__c,
    //                 MEINS__c,
    //                 RAUBE__c,
    //                 EINDT__c,
    //                 RETPO__c,
    //                 PSMNG__c,
    //                 R_PSMNG__c,
    //                 RELEASEDKEY__c,
    //                 xmsgs__c
    //                 FROM RELEASE_D__c
    //                 WHERE (RELEASE_H__r.CHECK__c = 'Y' AND RELEASE_H__r.CONFIRM__c = 'N') /*OR EBELN_R__c = ''*/
    //             ];  
    //         }

    //         inputMap.put('header', inputHeader);
    //         inputMap.put('detail', inputDetail);
    //         inputMap.put('IF_ID', 'CK0004');

    //         inputString = JSON.serialize(inputMap);
    //         inputData.requestMsg = inputString;

    //         System.debug('========================requestMsg :::'+inputData.requestMsg);

    //         callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort soap = new callCjCkSoapVer_2.CalllogisoneSapCkSoapImplPort();
    //         result = soap.callSapCkProcedure(inputData);
    //         System.debug('result======================= :::'+result);

    //         if(result == '' || result == null) {
    //             strStatus = 'ERROR';
    //             strCode = '-1';
    //             strMessage = 'response body value does not exist';
    //         }else {
    //             Input input = (Input)JSON.deserialize(result, Input.class);

    //             if (input.header == null || input.header.size() < 1) {
    //                 strStatus = 'ERROR';
    //                 strCode = '0001';
    //                 strMessage = 'header list is null';
    //             }else if (input.detail == null || input.detail.size() < 1) {
    //                 strStatus = 'ERROR';
    //                 strCode = '0002';
    //                 strMessage = 'detail list is null';
    //             }else {
    //                 Map<String, RELEASE_H__c> mapUpOrder = new Map<String, RELEASE_H__c>();
    
    //                 if (input.header <> null && input.header.size() > 0) {
    //                     targetHList = [
    //                         SELECT Id, IFDATE__c,  EBELN__c, SND_YN__c, XDATS__c, XTIMS__c, xmsgs__c
    //                         FROM RELEASE_H__c
    //                         WHERE CHECK__c = 'Y' AND CONFIRM__c = 'N'
    //                     ];
    //                     System.debug('==================targetList:::'+targetHList);

    //                     for (RELEASE_H__c obj : targetHList) {
    //                         mapUpOrder.put(obj.EBELN__C, obj);
    //                     }
    //                     System.debug(('====================mapUpOrder:::' + mapUpOrder));
    //                     if (!targetHList.isEmpty()) {
    //                         for (ReleaseH obj : input.header) {
    //                             RELEASE_H__c releaseHObj = new RELEASE_H__c();
    //                             releaseHObj = mapUpOrder.get(obj.EBELN);
    //                             releaseHObj.xmsgs__c = obj.XMSGS;
    //                             releaseHObj.xstat__c = obj.xstat;
    //                             updateHList.add(releaseHObj);
    //                         }
    
    //                         update updateHList;
    //                     }else {
    //                         strCode = '0003';
    //                         strMessage = 'The target to update does not exist';
    //                         strStatus = 'ERROR';
    //                     }
    //                 }
    //             }
    //         }
    //     } catch (Exception e) {
    //         strCode = '-1';
    //         strStatus = 'ERROR';
    //         System.debug('soapCallFaild...:::soapCallResult:::'+result+':::strMessage:::'+strMessage);
    //     }finally{

    //         objResult.resultCode = strCode;
    //         objResult.resultMessage = strMessage;
    //         objResult.soapCallResult = result;

    //         objOutput.result = objResult;

    //         LogWrapper.status = strStatus;
    //         LogWrapper.resultCode = strCode;
    //         LogWrapper.resultMessage = 'strMessage:::' + strMessage + ':::soapCallResult:::' + result;
    //         LogWrapper.responseTime = Datetime.now();
    //         LogWrapper.requestBody = inputString;
    //         LogWrapper.responseBody = result;
    //         System.debug(LogWrapper);
    //         IFUtil objIF = new IFUtil('IF_SFDC_SAP_SAND_RELEASE');
    //         objIF.setLog(LogWrapper);
    //     }
    //     return objOutput;
    // }
}