/**
 * @description       : VOC 조치이력 Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class IF_IFRESH_SFDC_VOC_INFO_COMMENT_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{
    
    global String transactionId;

    global IF_IFRESH_SFDC_VOC_INFO_COMMENT_ba(String transactionId) {
        this.transactionId = transactionId;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : IF Dummy Object 레코드 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, transactionId__c, VOC_NO__c, PRS_BD_NO__c, PRS_DT__c, PRSR_NM__c,';
        strQuery += '   PRSR_EMP_NO__c, PRS_CL_NM__c, PRS_CL_CD__c, PRS_TXT_NM__c, PRS_TXT_CD__c, DLWR_NM__c, BCNR_OPN_YN__c, TXT__c, REG_DT__c, UPD_DT__c';
        strQuery += '   FROM IF_IFRESH_SFDC_VOC_INFO_COMMENT__c';
        strQuery += '   WHERE transactionId__c = \'' + transactionId + '\'' ;
        strQuery += '   AND     IsUpdate__c = false' ;

        System.debug('strQuery: ' + strQuery);
        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : VOC 조치이력 upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<IF_IFRESH_SFDC_VOC_INFO_COMMENT__c> scope) {
        System.debug('execute batch');
        List<VOCComment__c> upsertVOCCommentList = new List<VOCComment__c>();
        Set<String> vocNoSet = new Set<String>();
        for (IF_IFRESH_SFDC_VOC_INFO_COMMENT__c obj : scope) {
            vocNoSet.add(obj.VOC_NO__c);
        }

        List<VOC__C> vocList = new List<VOC__C>();
        vocList = [
                    SELECT Id, VOCNumber__c
                    FROM VOC__c
                    WHERE VOCNumber__c IN :vocNoSet
        ];

        Map<String, Id> vocMap = new Map<String, Id>();
        for (VOC__c obj : vocList) {
            vocMap.put(obj.VOCNumber__c, obj.Id);
        }

        List<IF_IFRESH_SFDC_VOC_INFO_COMMENT__c> listUpdate = new List<IF_IFRESH_SFDC_VOC_INFO_COMMENT__c>();

        for (IF_IFRESH_SFDC_VOC_INFO_COMMENT__c objDummy : scope) {
            IF_IFRESH_SFDC_VOC_INFO_COMMENT__c objTarget = new IF_IFRESH_SFDC_VOC_INFO_COMMENT__c();
            objTarget.Id = objDummy.Id;

            if(vocMap <> null && vocMap.get(objDummy.VOC_NO__c) <> null){
                VOCComment__c obj = new VOCComment__c();
                obj.ExtId__c = objDummy.VOC_NO__c + '_' + objDummy.PRS_BD_NO__c;
                
                obj.VOC__c = vocMap.get(objDummy.VOC_NO__c);
                obj.VOCNumber__c = objDummy.VOC_NO__c;
                obj.PRS_BD_NO__c = objDummy.PRS_BD_NO__c;
                obj.DateofAction__c = objDummy.PRS_DT__c == null ? null : Datetime.valueOf(objDummy.PRS_DT__c);
                obj.ResolverName__c = objDummy.PRSR_NM__c;
                obj.ResolverNumber__c = objDummy.PRSR_EMP_NO__c;                
                obj.SolutionCode__c = objDummy.PRS_CL_CD__c;                
                obj.ActionDetailCode__c = objDummy.PRS_TXT_CD__c;
                obj.CustomerSideResponder__c = objDummy.DLWR_NM__c;
                obj.IsPartnerDisclosure__c = objDummy.BCNR_OPN_YN__c == '1' ? true : false;
                obj.Description__c = objDummy.TXT__c;
                obj.RegDT__c = objDummy.REG_DT__c <> null ? Datetime.valueOf(objDummy.REG_DT__c) : null;
                obj.UpdDT__c = objDummy.UPD_DT__c <> null ? Datetime.valueOf(objDummy.UPD_DT__c) : null;

                upsertVOCCommentList.add(obj);
            }else {
                objTarget.IsNotVOC__c = true;                
            }

            objTarget.IsUpdate__c = true;
            listUpdate.add(objTarget);
        }

        Savepoint sp = Database.setSavepoint();

        // try {
            if(upsertVOCCommentList <> null && upsertVOCCommentList.size() > 0) {
                upsert upsertVOCCommentList ExtId__c;
            }

            if(listUpdate <> null && listUpdate.size() > 0) {
                update listUpdate;
            }
        // }catch(Exception e) {
        //     Database.rollback(sp);

        //     System.debug('=============================> Error Line '+e.getLineNumber());
        //     System.debug('=============================> Error '+e.getMessage());
        // }
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : 없음
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        /*
        IF_DUMMY_DEL_ba master = new IF_DUMMY_DEL_ba('IF_IFRESH_SFDC_VOC_INFO_MASTER__c', this.transactionId);
        Database.executeBatch(master, 200);

        IF_DUMMY_DEL_ba detail = new IF_DUMMY_DEL_ba('IF_IFRESH_SFDC_VOC_INFO_DETAIL__c', this.transactionId);
        Database.executeBatch(detail, 200);

        IF_DUMMY_DEL_ba comment = new IF_DUMMY_DEL_ba('IF_IFRESH_SFDC_VOC_INFO_COMMENT__c', this.transactionId);
        Database.executeBatch(comment, 200);
        */
    }
}