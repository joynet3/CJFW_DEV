/**
 * @description       : VOC 마스터 Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global with sharing class IF_IFRESH_SFDC_VOC_INFO_MASTER_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global String transactionId;

    global IF_IFRESH_SFDC_VOC_INFO_MASTER_ba(String transactionId) {
        this.transactionId = transactionId;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : IF Dummy Object 레코드 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, transactionId__c, voc_no__c, rcp_rout_cd__c,reqr_div_cd__c, cll_div_cd__c, cll_stg_cd__c,';
        strQuery += '   cust_reqr_nm__c, reqr_nm__c, cllr_tel_no__c, isu_yn__c, isu_cl_cd__c, reg_dt__c, REGR_ID__c, REGR_NM__c, upd_dt__c, updr_id__c, UPDR_NM__c';
        strQuery += '   FROM IF_IFRESH_SFDC_VOC_INFO_MASTER__c';
        strQuery += '   WHERE transactionId__c =\'' + transactionId + '\'';
        strQuery += '   AND     IsUpdate__c = false' ;

        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : VOC upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<IF_IFRESH_SFDC_VOC_INFO_MASTER__c> scope) {
        List<VOC__c> upsertVOCList = new List<VOC__c>();
        Id recordId = Schema.SObjectType.VOC__c.getRecordTypeInfosByDeveloperName().get('OwnCustomer').getRecordTypeId();
        Id recordId2 = Schema.SObjectType.VOC__c.getRecordTypeInfosByDeveloperName().get('Etc').getRecordTypeId();
        Set<String> productCodeSet = new Set<String>();

        List<IF_IFRESH_SFDC_VOC_INFO_MASTER__c> listUpdate = new List<IF_IFRESH_SFDC_VOC_INFO_MASTER__c>();

        for (IF_IFRESH_SFDC_VOC_INFO_MASTER__c objDummy : scope) {
            VOC__C obj = new VOC__c();
            obj.Name = objDummy.VOC_NO__c;
            obj.VOCNumber__c = objDummy.VOC_NO__c;
            obj.VOCOriginCode__c = objDummy.RCP_ROUT_CD__c;
            obj.CallTypeCode__c = objDummy.CLL_DIV_CD__c;
            obj.PriorityCode__c = objDummy.CLL_STG_CD__c;            
            obj.Requester__c = objDummy.REQR_DIV_CD__c;
            obj.RequesterName__c = objDummy.REQR_NM__c;
            /*
            // 요청자구분코드 고객(10)일경우            
            if(objDummy.REQR_DIV_CD__c == '10') {
                obj.RequesterName__c = objDummy.REQR_NM__c;
            }else {
                obj.RequesterName__c = objDummy.REQR_NM__c;
            }
            */
            
            obj.CallNumber__c = objDummy.CLLR_TEL_NO__c;
            obj.IsIssue__c = objDummy.ISU_YN__c == 'Y' ? true : false;
            obj.IssueType__c = objDummy.ISU_CL_CD__c;
            obj.RegisterCode__c = objDummy.REGR_ID__c;
            obj.RegisterName__c = objDummy.REGR_NM__c;
            obj.RegDate__c =  Datetime.valueOf(objDummy.REG_DT__c);
            obj.UpdaterCode__c = objDummy.UPDR_ID__c;
            obj.UpdaterName__c = objDummy.UPDR_NM__c;
            obj.UpdDate__c = Datetime.valueOf(objDummy.UPD_DT__c);
            
            upsertVOCList.add(obj);

            IF_IFRESH_SFDC_VOC_INFO_MASTER__c objTarget = new IF_IFRESH_SFDC_VOC_INFO_MASTER__c();
            objTarget.Id = objDummy.Id;
            objTarget.IsUpdate__c = true;
            listUpdate.add(objTarget);
        }

        Savepoint sp = Database.setSavepoint();

        // try {
            if(upsertVOCList <> null && upsertVOCList.size() > 0) {
                upsert upsertVOCList VOCNumber__c;

                if(listUpdate <> null && listUpdate.size() > 0) {
                    update listUpdate;
                }
            }
            
        // }catch(Exception e) {
        //     Database.rollback(sp);

        //     System.debug('=============================> Error Line '+e.getLineNumber());
        //     System.debug('=============================> Error '+e.getMessage());
        // }
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : VOC 항목 Batch 실행
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        IF_IFRESH_SFDC_VOC_INFO_DETAIL_ba ba = new IF_IFRESH_SFDC_VOC_INFO_DETAIL_ba(this.transactionId);
        Database.executeBatch(ba, 200);
    }
}