/**
 * @Class : IF_SFDC_LOCAL_DATA_INFO_MEDI_sc.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.10.25
 * @Version : 1.0
 * @Description : IFN_ScheduleBatch 및 Batch Sequence 에 등록으로는 불가능한 구조. finish  후 재귀 호출을 다시 등록해야는 구조이기에, 
 *                기존 1차 때 양식인 *_sc 를 사용한다.
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.10.25 | sancho         | 최초작성
 * */
global with sharing class IF_SFDC_LOCAL_DATA_INFO_MEDI_sc implements Schedulable{
    global IF_SFDC_LOCAL_DATA_INFO_MEDI_sc() {

    }

    //global void execute(SchedulableContext sc) {}
    global void execute(SchedulableContext sc) {
        
        List<String> upsertFailList = new List<String>();
        
        //IF_SFDC_LOCAL_DATA_INFO_MEDI_ba ba4 = new IF_SFDC_LOCAL_DATA_INFO_MEDI_ba(upsertFailList);
        //Database.executeBatch(ba4,1);
        
    }
}


/*

global with sharing class IF_SFDC_LOCAL_DATA_INFO_FOOD_sc implements Schedulable{
    global IF_SFDC_LOCAL_DATA_INFO_FOOD_sc() {
    }

    global void execute(SchedulableContext sc) {}

*/