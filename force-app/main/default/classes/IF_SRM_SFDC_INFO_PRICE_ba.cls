/**
 * @description       : 기준매입가정보 API Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global without sharing class IF_SRM_SFDC_INFO_PRICE_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global String transactionId;

    global IF_SRM_SFDC_INFO_PRICE_ba(String transactionId) {
        this.transactionId = transactionId;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : IF Dummy Object 레코드 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, transactionId__c, IsUpdate__c, Description__c,';        
        strQuery += '   gd_nm__c, gd_no__c, lgs_ctr_nm__c, lgs_ctr_id__c, del_yn__c, cust_ordr_ddl_cl_cd__c, aply_stt_ymd__c, aply_end_ymd__c, crit_buy_prc__c,';
        strQuery += '   reg_dt__c, upd_dt__c';
        strQuery += '   FROM    IF_SRM_SFDC_INFO_PRICE__c';
        strQuery += '   WHERE   transactionId__c = \'' + transactionId + '\'' ;
        strQuery += '   AND     IsUpdate__c = false' ;
        strQuery += '   AND     del_yn__c = \'0\'' ;

        System.debug('strQuery: ' + strQuery);
        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 기준매입가정보 upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<IF_SRM_SFDC_INFO_PRICE__c> scope) {
        System.debug('execute batch');
        List<PricebookEntry> upsertObjList = new List<PricebookEntry>();
        Set<String> productCodeSet = new Set<String>();
        Datetime dt = Datetime.now();
        String month = '';
        system.debug(dt.format('MMM'));
        
        for (IF_SRM_SFDC_INFO_PRICE__c item : scope) {
            productCodeSet.add(item.lgs_ctr_id__c + '_' + item.gd_no__c);
        }

        if (Integer.valueOf(dt.format('dd')) < 16) {
            month = 'Early' + dt.format('MMM') + '__c';
        }else {
            month = 'Late' + dt.format('MMM') + '__c';
        }

        System.debug('month: ' + month);
        Map<String, PricebookEntry> productCodeMap = new Map<String, PricebookEntry>();
        Map<String, Id> product2IdMap = new Map<String,Id>();
        List<String> noneProductList = new List<String>();
        
        // List<PricebookEntry> pridcebookEntryList = [
        //     SELECT Id, ProductCode, EarlyJan__c,LateJan__c,EarlyFeb__c,LateFeb__c,EarlyMar__c,LateMar__c,EarlyApr__c,LateApr__c,EarlyMay__c,LateMay__c,EarlyJun__c,LateJun__c,EarlyJul__c,LateJul__c,EarlyAug__c,LateAug__c,EarlySep__c,LateSep__c,EarlyOct__c,LateOct__c,EarlyNov__c,LateNov__c,EarlyDec__c,LateDec__c
        //     FROM PricebookEntry
        //     WHERE ProductCode IN:productCodeSet
        // ];

        // List<Product2> product2Obj = [
        //     SELECT Id, ProductCode
        //     FROM Product2
        //     WHERE ProductCode IN:productCodeSet
        // ];

        Pricebook2 pricebookId = [
            SELECT Id
            FROM Pricebook2
            WHERE IsStandard = true LIMIT 1
        ];
        for (PricebookEntry obj : [
            SELECT Id, ProductCode, EarlyJan__c,LateJan__c,EarlyFeb__c,LateFeb__c,EarlyMar__c,LateMar__c,EarlyApr__c,LateApr__c,EarlyMay__c,LateMay__c,EarlyJun__c,LateJun__c,EarlyJul__c,LateJul__c,EarlyAug__c,LateAug__c,EarlySep__c,LateSep__c,EarlyOct__c,LateOct__c,EarlyNov__c,LateNov__c,EarlyDec__c,LateDec__c
            FROM PricebookEntry
            WHERE ProductCode IN:productCodeSet
        ]) {
            productCodeMap.put(obj.ProductCode, obj);
        }

        for (Product2 obj : [
            SELECT Id, ProductCode
            FROM Product2
            WHERE ProductCode IN:productCodeSet
        ]) {
            product2IdMap.put(obj.ProductCode, obj.Id);
        }

        // 2022-11-21 중복되는 데이터가 있는 경우 적용일자가 미래인 값으로 세팅한다
        Map<String, IF_SRM_SFDC_INFO_PRICE__c> mapTargetPBO = new Map<String, IF_SRM_SFDC_INFO_PRICE__c>();

        List<IF_SRM_SFDC_INFO_PRICE__c> listDuplicateData = new List<IF_SRM_SFDC_INFO_PRICE__c>();

        for(IF_SRM_SFDC_INFO_PRICE__c item : scope) {
            String strKey = item.lgs_ctr_id__c + '_' + item.gd_no__c;            

            IF_SRM_SFDC_INFO_PRICE__c objTarget = item;

            if(mapTargetPBO <> null && mapTargetPBO.get(strKey) <> null) {
                IF_SRM_SFDC_INFO_PRICE__c objBefore = mapTargetPBO.get(strKey);

                if(objBefore.aply_stt_ymd__c > item.aply_stt_ymd__c) {
                    objTarget = objBefore;

                    item.IsUpdate__c = false;
                    item.Description__c = 'Duplicate : lgs_ctr_id_gd_no'+strKey+'|aply_stt_ymd : '+objBefore.aply_stt_ymd__c+'/'+item.aply_stt_ymd__c+'|aply_end_ymd : '+objBefore.aply_end_ymd__c+'/'+item.aply_end_ymd__c;
                    listDuplicateData.add(item);
                }else {
                    objBefore.IsUpdate__c = false;
                    objBefore.Description__c = 'Duplicate : lgs_ctr_id_gd_no'+strKey+'|aply_stt_ymd : '+objBefore.aply_stt_ymd__c+'/'+item.aply_stt_ymd__c+'|aply_end_ymd : '+objBefore.aply_end_ymd__c+'/'+item.aply_end_ymd__c;
                    listDuplicateData.add(objBefore);
                }
            }

            mapTargetPBO.put(strKey, objTarget);
        }

        List<IF_SRM_SFDC_INFO_PRICE__c> listUpdate = new List<IF_SRM_SFDC_INFO_PRICE__c>();

        for(IF_SRM_SFDC_INFO_PRICE__c item : mapTargetPBO.values()) {
            PricebookEntry pricebookObj = new PricebookEntry(); 
            String strKey = item.lgs_ctr_id__c + '_' + item.gd_no__c;
            if (product2IdMap <> null && product2IdMap.get(strKey) <> null) {
                pricebookObj.Product2Id = product2IdMap.get(strKey);
                pricebookObj.Pricebook2Id = pricebookId.Id;
                pricebookObj.UnitPrice = 0;
                pricebookObj.isActive = true;

                // pricebookObj.gd_no__c = item.gd_no__c;
                pricebookObj.lgs_ctr__c = item.lgs_ctr_id__c;
                // pricebookObj.lgs_ctr_id__c = item.lgs_ctr_id__c;

                pricebookObj.put('' + month , item.crit_buy_prc__c == null ? 0 : Decimal.valueOf(item.crit_buy_prc__c));
                // pricebookObj.put('isNo' + month , item.crit_buy_prc__c == null || item.crit_buy_prc__c == '0' ? true : false);

                // 2022-11-11 del_yn__c 값이 1인 경우 0 세팅
                /*
                if(item.del_yn__c == '1') {
                    pricebookObj.put('' + month , 0);
                }else {
                    pricebookObj.put('' + month , item.crit_buy_prc__c == null ? null : Decimal.valueOf(item.crit_buy_prc__c));
                }
                */
                pricebookObj.ExtId__c = strKey;
                upsertObjList.add(pricebookObj);

                item.IsUpdate__c = true;                
            }else {
                item.IsUpdate__c = false;
                item.Description__c = 'None Master : '+strKey;
            }

            IF_SRM_SFDC_INFO_PRICE__c objTarget = new IF_SRM_SFDC_INFO_PRICE__c();
            objTarget.Id = item.Id;
            objTarget.IsUpdate__c = item.IsUpdate__c;
            objTarget.Description__c = item.Description__c;
            listUpdate.add(objTarget);
        }
        System.debug('upsertObjList: ' + upsertObjList);

        Savepoint sp = Database.setSavepoint();

        // try {
            if(upsertObjList <> null && upsertObjList.size() > 0) {
                upsert upsertObjList ExtId__c;
            }

            if(listUpdate <> null && listUpdate.size() > 0) {
                update listUpdate;
            }

            if(listDuplicateData <> null && listDuplicateData.size() > 0) {
                update listDuplicateData;
            }

        // }catch(Exception e) {
        //     Database.rollback(sp);

        //     System.debug('=============================> Error Line '+e.getLineNumber());
        //     System.debug('=============================> Error '+e.getMessage());
        // }
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : IF_DUMMY_DEL_ba Batch 실행 
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        System.debug('finish batch');
        IF_DUMMY_DEL_ba price_ba = new IF_DUMMY_DEL_ba('IF_SRM_SFDC_INFO_PRICE__c', this.transactionId);
        Database.executeBatch(price_ba, 200);
    }
}