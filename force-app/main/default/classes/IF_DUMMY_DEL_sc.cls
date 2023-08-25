/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-02-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class IF_DUMMY_DEL_sc implements Schedulable {
    /*
    // 매출원장 Dummy 데이터 삭제
    String CRON_EXP1 = '0 10 0 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    IF_DUMMY_DEL_sc sc1 = new IF_DUMMY_DEL_sc('IF_IFRESH_SFDC_INFO_ORDER_0001__c');
    System.schedule('IF Dummy 삭제 매출원장정보 (IF_IFRESH_SFDC_INFO_ORDER_0001__c) 00:10', CRON_EXP1, sc1);

    // VOC Master Dummy 데이터 삭제
    String CRON_EXP2 = '0 15 0 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    IF_DUMMY_DEL_sc sc2 = new IF_DUMMY_DEL_sc('IF_IFRESH_SFDC_VOC_INFO_MASTER__c');
    System.schedule('IF Dummy 삭제 VOC Master (IF_IFRESH_SFDC_VOC_INFO_MASTER__c) 00:15', CRON_EXP2, sc2);

    // VOC Detail Dummy 데이터 삭제
    String CRON_EXP3 = '0 20 0 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    IF_DUMMY_DEL_sc sc3 = new IF_DUMMY_DEL_sc('IF_IFRESH_SFDC_VOC_INFO_DETAIL__c');
    System.schedule('IF Dummy 삭제 VOC Detail (IF_IFRESH_SFDC_VOC_INFO_DETAIL__c) 00:20', CRON_EXP3, sc3);

    // VOC Comment Dummy 데이터 삭제
    String CRON_EXP4 = '0 25 0 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    IF_DUMMY_DEL_sc sc4 = new IF_DUMMY_DEL_sc('IF_IFRESH_SFDC_VOC_INFO_COMMENT__c');
    System.schedule('IF Dummy 삭제 VOC Comment (IF_IFRESH_SFDC_VOC_INFO_COMMENT__c) 00:25', CRON_EXP4, sc4);

    // 기준매입가격 Dummy 데이터 삭제
    String CRON_EXP5 = '0 30 0 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    IF_DUMMY_DEL_sc sc5 = new IF_DUMMY_DEL_sc('IF_SRM_SFDC_INFO_PRICE__c');
    System.schedule('IF Dummy 삭제 기준매입가격 (IF_SRM_SFDC_INFO_PRICE__c) 00:30', CRON_EXP5, sc5);

    // 상품정보 Dummy 데이터 삭제
    String CRON_EXP6 = '0 35 0 * * ? *';  // 초 분 시 일 월 ? ?  관련하여 Cron expression 검색.    
    IF_DUMMY_DEL_sc sc6 = new IF_DUMMY_DEL_sc('IF_MDM_SFDC_INFO_PRODUCT__c');
    System.schedule('IF Dummy 삭제 상품정보 (IF_MDM_SFDC_INFO_PRODUCT__c) 00:35', CRON_EXP6, sc6);
    */

    global String targetObject;
    
    global IF_DUMMY_DEL_sc(String targetObject) {
        this.targetObject = targetObject;

    }

    global void execute(SchedulableContext sc) {        
        IF_DUMMY_DEL_ba ba = new IF_DUMMY_DEL_ba(this.targetObject, 'ALL');
        Database.executeBatch(ba, 1000);
    }
}