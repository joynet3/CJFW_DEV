/**
 * @Class : IFN_sancho_test.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.07.21
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.07.21 |  | 최초작성
 * */
public with sharing class IFN_sancho_test {
    public IFN_sancho_test() {
    }

    /*
    *   윈도 업뎃 후 VSCode 실행 않됨. 바로가기 [대상]에 아래 옵션 추가
    *   "C:\Microsoft VS Code\Code.exe" --verbose --no-sandbox
    *
    */

    /**
     *  중요 수행 스크맆트 및 테스트
     * */
    public void testIf() {
        
        /************************** 스케쥴 등록 ************************/
        //1차에서 사용한 스케쥴 등록법. - NEAT 학교급식(농수산식품공사)는 기존 개발안이므로 기존 폼 유지한다.
        IF_SFDC_DATA_REQ_EAT_BID_INFO_sc sch = new IF_SFDC_DATA_REQ_EAT_BID_INFO_sc();
        //system.schedule('IF_SFDC_DATA_REQ_EAT_BID_INFO_sc 학교급식 NEAT 02시00분', '0 10 16 * * ?', sch);
        system.schedule('IF_SFDC_DATA_REQ_EAT_BID_INFO_sc 학교급식 NEAT 02시00분', '0 0 02 * * ?', sch);

        //전용유
        IFN_EIF1002_FS001_MD001 b = new IFN_EIF1002_FS001_MD001();
        Database.executeBatch(b, 1);

        //전용유 신규 스케쥴 등록 
        IFN_EIF1002_FS001_MD001_sc EIF1002_FS001 = new IFN_EIF1002_FS001_MD001_sc();
        system.schedule('IFN_EIF1002_FS001_MD001_sc 식약청 전용유 01:05', '0 30 01 * * ?', EIF1002_FS001);

        //기존 어린이집/지방인허가/나라장터
        /* - 운영 Scheduled Jobs
        IF_SFDC_CRCT_REQ_CENTER_INFO_sc 어린이집정보공개포털 01:30	            CJ Freshway	2023. 2. 7. 오전 11:26	2023. 10. 24. 오전 1:30	2023. 10. 25. 오전 1:30	예약된 Apex
        IF_SFDC_LOCAL_DATA_INFO_sc 지방인허가정보 05시00분	                    Interface	2023. 2. 5. 오후 5:28	2023. 10. 24. 오전 5:00	2023. 10. 25. 오전 5:00	예약된 Apex
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc 나라장터 입찰공고(기타) 03시00분	Interface	2023. 2. 5. 오후 5:24	2023. 10. 24. 오전 3:00	2023. 10. 25. 오전 3:00	예약된 Apex
        IF_SFDC_DATA_REQ_NARA_TENDER_FRGC_sc 나라장터 입찰공고(외자) 03시30분	Interface	2023. 2. 5. 오후 5:24	2023. 10. 24. 오전 3:30	2023. 10. 25. 오전 3:30	예약된 Apex
        IF_SFDC_DATA_REQ_NARA_TENDER_SERVC_sc 나라장터 입찰공고(용역) 04시00분	Interface	2023. 2. 5. 오후 5:24	2023. 10. 24. 오전 4:00	2023. 10. 25. 오전 4:00	예약된 Apex
        IF_SFDC_DATA_REQ_NARA_TENDER_THNG_sc 나라장터 입찰공고(물품) 04시30분

        IF_SFDC_DATA_REQ_D2BBID_INFO_sc 국방전자조달시스템 입찰공고 01시00분
        */

        IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc nara_info = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc();
        system.schedule('IF_SFDC_DATA_REQ_NARA_TENDER_INFO_sc 나라장터 입찰공고(기타) 03시00분',    '0 00 03 * * ?', nara_info);

        IF_SFDC_DATA_REQ_NARA_TENDER_FRGC_sc nara_frgc = new IF_SFDC_DATA_REQ_NARA_TENDER_FRGC_sc();
        system.schedule('IF_SFDC_DATA_REQ_NARA_TENDER_FRGC_sc 나라장터 입찰공고(외자) 03시30분',    '0 30 03 * * ?', nara_frgc);

        IF_SFDC_DATA_REQ_NARA_TENDER_SERVC_sc nara_serv = new IF_SFDC_DATA_REQ_NARA_TENDER_SERVC_sc();
        system.schedule('IF_SFDC_DATA_REQ_NARA_TENDER_SERVC_sc 나라장터 입찰공고(용역) 04시00분',   '0 00 04 * * ?', nara_serv);

        IF_SFDC_DATA_REQ_NARA_TENDER_THNG_sc nara_thng = new IF_SFDC_DATA_REQ_NARA_TENDER_THNG_sc();
        system.schedule('IF_SFDC_DATA_REQ_NARA_TENDER_THNG_sc 나라장터 입찰공고(물품) 04시30분',    '0 30 04 * * ?', nara_thng);

        IF_SFDC_DATA_REQ_D2BBID_INFO_sc d2bbid_info = new IF_SFDC_DATA_REQ_D2BBID_INFO_sc();
        system.schedule('IF_SFDC_DATA_REQ_D2BBID_INFO_sc 국방전자조달시스템 입찰공고 01시00분',    '0 00 01 * * ?', d2bbid_info);

        //local 4종 이 안에 다 있다.-----------------------------------------------------------------------------------------------
        IF_SFDC_LOCAL_DATA_INFO_sc local_info = new IF_SFDC_LOCAL_DATA_INFO_sc();
        system.schedule('IF_SFDC_LOCAL_DATA_INFO_sc 지방인허가정보 05시00분',                       '0 00 05 * * ?', local_info);
        //local 4종 이 안에 다 있다.-----------------------------------------------------------------------------------------------

        IF_SFDC_CRCT_REQ_CENTER_INFO_sc crct = new IF_SFDC_CRCT_REQ_CENTER_INFO_sc();
        system.schedule('IF_SFDC_CRCT_REQ_CENTER_INFO_sc 어린이집정보공개포털 01:30', '0 30 01 * * ?', crct);

        IF_SFDC_KIND_REQ_sc kinder = new IF_SFDC_KIND_REQ_sc();
        system.schedule('IF_SFDC_KIND_REQ_sc 어린이집정보공개포털 01:40', '0 40 01 * * ?', kinder);


        //IF_SFDC_KIND_REQ_sc
        

        
        //  ***** Scheduled Jobs 에 등록해서 사용 하려 했으나, 페이징처리 로직과 충돌(미실행, 재등록등)이 까다로원 기존 타 배치양식으로 처리한다. ***** // 2023.10.24
        //	IFN_ScheduleBatch
        // List<String> upsertFailList = new List<String>();
        // IF_SFDC_LOCAL_DATA_INFO_MEDI_ba b = new IF_SFDC_LOCAL_DATA_INFO_MEDI_ba(upsertFailList);
        // Database.executeBatch(b,1);


        /*  batch 직 수행
        
        ---- LOCAL 3종  + 1
        List<String> upsertFailList = new List<String>();
        IF_SFDC_LOCAL_DATA_INFO_ba ba = new IF_SFDC_LOCAL_DATA_INFO_ba(upsertFailList);
        IF_SFDC_LOCAL_DATA_INFO_FOOD_ba ba2 = new IF_SFDC_LOCAL_DATA_INFO_FOOD_ba(upsertFailList);
        IF_SFDC_LOCAL_DATA_INFO_RESTAURANT_ba ba3 = new IF_SFDC_LOCAL_DATA_INFO_RESTAURANT_ba(upsertFailList);
        Database.executeBatch(ba,1);
        Database.executeBatch(ba2,1);
        Database.executeBatch(ba3,1);

        IF_SFDC_LOCAL_DATA_INFO_MEDI_ba ba4 = new IF_SFDC_LOCAL_DATA_INFO_MEDI_ba(upsertFailList);
        Database.executeBatch(ba4,1);
        ---- LOCAL 3종  + 1

        //어린이집
        IF_SFDC_CRCT_REQ_CENTER_INFO_ba b = new IF_SFDC_CRCT_REQ_CENTER_INFO_ba(false,null);
        Database.executeBatch(b,1);
        //유치원
        IF_SFDC_KIND_REQ_BASE_INFO b = new IF_SFDC_KIND_REQ_BASE_INFO(false,null);
        Database.executeBatch(b,1);

        IF_SFDC_KIND_REQ_SCHOOL_MEAL m = new IF_SFDC_KIND_REQ_SCHOOL_MEAL(false,null);
        Database.executeBatch(m,1);


        //------------------------------------------------------------------------------------------------------------------
        List<NaramarketKeyword__mdt> keywordList = [
            SELECT Keyword__c
            FROM NaramarketKeyword__mdt
            WHERE Keyword_Lv__c = 1
        ];
        Set<Id> nextBatchLeadSet = new Set<Id>();
        // 용역조회
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba b2 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba(keywordList, 'getBidPblancListInfoServcPPSSrch01', 0, nextBatchLeadSet, null, null);
        Database.executeBatch(b2, 1);
        // 외자조회
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba b3 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba(keywordList, 'getBidPblancListInfoFrgcptPPSSrch01', 0, nextBatchLeadSet, null, null);
        Database.executeBatch(b3, 1);
        // 물품조회
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba b4 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba(keywordList, 'getBidPblancListInfoThngPPSSrch01', 0, nextBatchLeadSet, null, null);
        Database.executeBatch(b4, 1);
        // 기타조회
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba b5 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO_ba(keywordList, 'getBidPblancListInfoEtcPPSSrch01', 0, nextBatchLeadSet, null, null);
        Database.executeBatch(b5, 1);


        // 민간조회
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba b6 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba(keywordList, 'getPrvtBidPblancListInfoServcPPSSrch', 0, nextBatchLeadSet);
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba b7 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba(keywordList, 'getPrvtBidPblancListInfoThngPPSSrch', 0, nextBatchLeadSet);
        IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba b8 = new IF_SFDC_DATA_REQ_NARA_TENDER_INFO2_ba(keywordList, 'getPrvtBidPblancListInfoEtcPPSSrch', 0, nextBatchLeadSet);
    
        Database.executeBatch(b6, 1);
        Database.executeBatch(b7, 1);
        Database.executeBatch(b8, 1);
        //------------------------------------------------------------------------------------------------------------------



        */

    }

    public void restRun(){

        IFMaster__c ifMasterObj = [
            SELECT Id, Name, ContentType__c, Endpoint__c, Method__c
            FROM IFMaster__c
            WHERE Name = 'IF_SFDC_DATA_REQ_EAT_BID_INFO'
        ];
        API_Authenticationkey__mdt authKey = [
            SELECT KeyValue__c, DateRange__c, MasterLabel
            FROM API_Authenticationkey__mdt
            WHERE MasterLabel = '공공데이터_Key'
        ];
        //
        String today = String.valueOf(Datetime.now().format('yyyyMMdd'));
        //String todayM = String.valueOf(Datetime.now().format('yyyyMMdd') - 1);
        //Datetime ddd    = Datetime.now().format('yyyyMMdd');
        Datetime endDt  = Datetime.now().addDays(Integer.valueOf(authKey.DateRange__c));
        System.debug('today:' + today);

        Date nowD = Date.today();
        Date nowDD = Date.today() - 1;  //OK
        Date nowMM = Date.today() - Integer.valueOf(authKey.DateRange__c);
        
        System.debug('nowDD:' + nowDD);
        System.debug('nowMM:' + nowMM);

        Datetime todaytime = Datetime.now();
        Integer dateRange = Integer.valueOf(authKey.DateRange__c);
        String sDt = '&lastModTsBgn=' + todaytime.addDays(-1).format('yyyyMMdd');
        String eDt = '&lastModTsEnd=' + todaytime.addDays(-dateRange).format('yyyyMMdd');

        System.debug('sDt:' + sDt);
        System.debug('eDt:' + eDt);


/*

        //학교급식 지역별 학교정보
        IFN_EIF1004_DT001_MD001.Output              outputObj   = new IFN_EIF1004_DT001_MD001.Output();
        IFN_EIF1004_DT001_MD001                     iftest      = new IFN_EIF1004_DT001_MD001();
        IFN_EIF1004_DT001_MD001.MD001RequstWrapper  reqmap      = new IFN_EIF1004_DT001_MD001.MD001RequstWrapper();

        ////https://dotop.kr/Service/API/?serviceKey=944FB5A82EAE4149B3F8AAE5C48E7752&serviceDiv=A01&Address1=서울
        reqmap.serviceKey   = '944FB5A82EAE4149B3F8AAE5C48E7752';
        reqmap.serviceDiv   = 'A01';
        reqmap.Address1     = '서울';
        reqmap.Keyword     = '가양';
        outputObj = iftest.callout(reqmap);
        System.debug('outputObj:' + outputObj);


        //학교급식 - 학교별 급식정보 
        IFN_EIF1004_DT001_MD002.Output              outputObj   = new IFN_EIF1004_DT001_MD002.Output();
        IFN_EIF1004_DT001_MD002                     iftest      = new IFN_EIF1004_DT001_MD002();
        IFN_EIF1004_DT001_MD002.MD002RequstWrapper  reqmap      = new IFN_EIF1004_DT001_MD002.MD002RequstWrapper();

        //https://dotop.kr/Service/API/?serviceKey=944FB5A82EAE4149B3F8AAE5C48E7752&serviceDiv=A02&NeisCodeStd=7569036&StartDate=20231001&EndDate=20231030
        reqmap.serviceKey   = '944FB5A82EAE4149B3F8AAE5C48E7752';
        reqmap.serviceDiv   = 'A02';
        reqmap.NeisCodeStd  = '7569036';
        reqmap.StartDate    = '20231001';
        reqmap.EndDate      = '20231030';

        outputObj = iftest.callout(reqmap);

        System.debug('outputObj:' + outputObj);

*/







        //nowDD.format().     //  . format('yyyyMMdd');
        //String sDt = String.valueOf(nowDD.format('yyyyMMdd'));
        //String eDt = String.valueOf(nowDD.addDays(-Integer.valueOf(authKey.DateRange__c)).format('yyyyMMdd'));
        //System.debug('ddd:' + ddd);
        //System.debug('todayM:' + todayM);
        //Datetime endDt = Datetime.now().addDays(Integer.valueOf(authKey.DateRange__c));


    }

    public void makeIFMaster(){
        
        List<IFMaster__c> listIFMaster = new List<IFMaster__c>();

        IFMaster__c objIFMaster = new IFMaster__c();
        objIFMaster.Name                = 'IFN_EIF1004_DT001_MD002';
        objIFMaster.Type__c             = 'Outbound';
        objIFMaster.WebserviceType__c   = 'REST';
        objIFMaster.Method__c           = 'GET';
        objIFMaster.ContentType__c      = 'application/json';
        objIFMaster.Endpoint__c         = 'https://dotop.kr/Service/API/';
        listIFMaster.add(objIFMaster);
		
        insert listIFMaster;

    }


    
}