/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-06-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class IF_SRM_SFDC_INFO_PRICE_INACTIVE_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    global String transactionId;

    global IF_SRM_SFDC_INFO_PRICE_INACTIVE_ba(String transactionId) {
        this.transactionId = transactionId;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, transactionId__c, IsUpdate__c,';        
        strQuery += '   gd_nm__c, gd_no__c, lgs_ctr_nm__c, lgs_ctr_id__c, del_yn__c, cust_ordr_ddl_cl_cd__c, aply_stt_ymd__c, aply_end_ymd__c, crit_buy_prc__c,';
        strQuery += '   reg_dt__c, upd_dt__c';
        strQuery += '   FROM    IF_SRM_SFDC_INFO_PRICE__c';
        strQuery += '   WHERE   transactionId__c = \'' + transactionId + '\'' ;
        strQuery += '   AND     IsUpdate__c = false' ;
        strQuery += '   AND     del_yn__c = \'1\'' ;

        System.debug('strQuery: ' + strQuery);
        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }

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

        List<IF_SRM_SFDC_INFO_PRICE__c> listUpdate = new List<IF_SRM_SFDC_INFO_PRICE__c>();

        for (IF_SRM_SFDC_INFO_PRICE__c item : scope) {
            PricebookEntry pricebookObj = new PricebookEntry(); 
            if (product2IdMap <> null && product2IdMap.get(item.lgs_ctr_id__c + '_' + item.gd_no__c) <> null) {
                pricebookObj.Product2Id = product2IdMap.get(item.lgs_ctr_id__c + '_' + item.gd_no__c);
                pricebookObj.Pricebook2Id = pricebookId.Id;
                pricebookObj.UnitPrice = 0;
                pricebookObj.lgs_ctr__c = item.lgs_ctr_id__c;
                pricebookObj.put('Old'+month, pricebookObj.get('' + month));
                pricebookObj.put('' + month , 0);
                pricebookObj.ExtId__c = item.lgs_ctr_id__c + '_' + item.gd_no__c;
                upsertObjList.add(pricebookObj);
            }else {
                noneProductList.add(item.lgs_ctr_id__c + '_' + item.gd_no__c);
            }

            IF_SRM_SFDC_INFO_PRICE__c objTarget = new IF_SRM_SFDC_INFO_PRICE__c();
            objTarget.Id = item.Id;
            objTarget.IsUpdate__c = true;
            listUpdate.add(objTarget);
        }
        System.debug('upsertObjList: ' + upsertObjList);

        Savepoint sp = Database.setSavepoint();

        // try {
            if(upsertObjList <> null && upsertObjList.size() > 0) {
                upsert upsertObjList ExtId__c;
                System.debug('noneProductList: ' + noneProductList);

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

    global void finish(Database.BatchableContext BC) {
        System.debug('finish batch');
        IF_SRM_SFDC_INFO_PRICE_ba price_ba = new IF_SRM_SFDC_INFO_PRICE_ba(this.transactionId);
        Database.executeBatch(price_ba, 200);
    }
}