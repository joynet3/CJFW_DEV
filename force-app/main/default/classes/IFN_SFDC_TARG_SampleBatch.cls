/**
 * @Class       : IFN_SFDC_TARG_SampleBatch
 * @Description : CONNECT-I 상태정보 전송 Batch class
 * @Author      : 최의규
 * @Date        : 2022-11-25
 * @Version     : 1.0
 * @Modified    :
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-11-25 | 최의규        | 최초작성
*
* */
public with sharing class IFN_SFDC_TARG_SampleBatch extends MasterBatchBase implements Database.AllowsCallouts {

    public String interfaceId = 'B2BI_SSIG_EA_PJTSTATUS_01';

    public override Database.QueryLocator start(Database.BatchableContext BC) {
        // ifid , Batch(배치 프로그램 일 경우 , reatime : 실시간 if 일 경우)
        logwrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Batch');  
        logwrap.BatchCronId = bc.getJobId();
        logwrap.BatchStartTime = System.now();
        logwrap.ClassName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
        logwrap.LogText.add('### [Batch Start] ###');

        if(ifDate == null) ifDate = Date.today();
        isContinue = true;

        return Database.getQueryLocator([
                                        SELECT Id, transactionId__c, VOC_NO__c, 
                                                VOC_DTL_NO__c, VOC_PRG_NM__c, VOC_PRG_CD__c, DLV_YMD__c,
                                                OCCR_YMD__c, MNGPLC_NM__c, MNGPLC_ID__c, GD_NO__c, GD_BD__c, 
                                                MIGR_ORINAT_NM__c, ORDR_UNIT_CD__c
                                        FROM IF_IFRESH_SFDC_VOC_INFO_DETAIL__c
                                        WHERE IsUpdate__c = false
                                        ORDER BY transactionId__c
                                        ]);
    }

    public override void execute(Database.BatchableContext bc, List<SObject> scope){

        List<IF_IFRESH_SFDC_VOC_INFO_DETAIL__c> ifDataLst = (List<IF_IFRESH_SFDC_VOC_INFO_DETAIL__c>)(scope);

        try{

            for(IF_IFRESH_SFDC_VOC_INFO_DETAIL__c nowlow : ifDataLst) {
                IFN_LIF007_Callout.EC001RequstWrapper param = new IFN_LIF007_Callout.EC001RequstWrapper();
                param.BASE_MON = '202212'; // 쿼리에서 조회 된 파라메터를 이용하여 세팅
                param.OIL_TYPE_CD = '1'; // 쿼리에서 조회 된 파라메터를 이용하여 세팅
    
                
                IFN_LIF007_Callout callout = new IFN_LIF007_Callout(this.interfaceId, 'Real');
                IFN_CalloutResult calloutResult =  callout.getResponse(this.interfaceId, param);
    
    
                
    
                if('S'.equals(calloutResult.result)) {
    
                    // 수신 데이터 따로 입력이 필요한 경우 
                    insIFX();
                }
            }            
            


        } catch(Exception e){

            logwrap.ErrorText.add(e.getMessage() + '/'+e.getLineNumber());
        }
        logwrap.LogText.add('### IFN_SFDC_TARG_SampleBatch End ###');
    } //end of execute()

    //IFX ins.
    public static void insIFX(){
        // 수신 데이터 따로 입력이 필요한 경우 

    }


      /**
     * 조회 파라메터  
     */
    public class requstParam{
        public String system_type_cd ='LIF007';
        public String opcode = 'EC001';
        public String COM_CD = 'FW00';
        public String BASE_MON {get;set;}
        public String OIL_TYPE_CD {get;set;}
    }

    /**
     * ==================================== 
     * 조회 결과 
     * =================================
     */
    public class Result {
        public String ERR_CD;
        public String ERR_MSG_CTT;
        public String DS_MASTER;
    }

    public class dsMsterData {
        public List<dataList> data;
        public String SVC_ERR_MSG_TEXT;
        public Integer ErrorCode;
    }

    public class dataList {
        public Integer OIL_UNITP;
        public String BASE_MON;
        public String COM_CD;
        public String OIL_TYPE_CD;
        public Integer DPRC_UNITP;
    }
    /**
     * ==================================== 
     * 조회 결과 
     * =================================
     */


}