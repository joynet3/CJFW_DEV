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
        
        //1차에서 사용한 스케쥴 등록법. - NEAT 학교급식(농수산식품공사)는 기존 개발안이므로 기존 폼 유지한다.
        IF_SFDC_DATA_REQ_EAT_BID_INFO_sc sch = new IF_SFDC_DATA_REQ_EAT_BID_INFO_sc();
        system.schedule('IF_SFDC_DATA_REQ_EAT_BID_INFO_sc 학교급식 NEAT 02시00분', '0 10 16 * * ?', sch);
        system.schedule('IF_SFDC_DATA_REQ_EAT_BID_INFO_sc 학교급식 NEAT 02시00분', '0 0 02 * * ?', sch);


        IFN_EIF1001_FS001_MD001 b = new IFN_EIF1001_FS001_MD001();
        Database.executeBatch(b, 1);

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




        //nowDD.format().     //  . format('yyyyMMdd');
        //String sDt = String.valueOf(nowDD.format('yyyyMMdd'));
        //String eDt = String.valueOf(nowDD.addDays(-Integer.valueOf(authKey.DateRange__c)).format('yyyyMMdd'));
        //System.debug('ddd:' + ddd);
        //System.debug('todayM:' + todayM);
        //Datetime endDt = Datetime.now().addDays(Integer.valueOf(authKey.DateRange__c));


    }


    
}