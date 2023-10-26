/**
 * @Class : IF_SFDC_KIND_REQ_sc.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.10.25
 * @Version : 1.0
 * @Description : 유치원 배치, 스케쥴 등록 base, meal 2종
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.10.25 | sancho         | 최초작성
 * */
global with sharing class IF_SFDC_KIND_REQ_sc implements Schedulable{
    global IF_SFDC_KIND_REQ_sc() {
    }

    global void execute(SchedulableContext sc) {
        IF_SFDC_KIND_REQ_BASE_INFO b = new IF_SFDC_KIND_REQ_BASE_INFO(false,null);
        IF_SFDC_KIND_REQ_SCHOOL_MEAL m = new IF_SFDC_KIND_REQ_SCHOOL_MEAL(false,null);
        Database.executeBatch(b,1);
        Database.executeBatch(m,1);

        
    }
}