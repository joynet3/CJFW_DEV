/************************************************************************************
 * File Name   		: KXDeliveryClaim_tr.cls
 * Author	  		: Jeongin.Jo
 * Date				: 2023.08.08
 * Target	  		: KXDeliveryClaim_tr.cls
 * Description 		: KXDeliveryClaim_tr Test Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.08.08      Jeongin.Jo       Create
*************************************************************************************/
@IsTest
public with sharing class KXDeliveryClaim_tr_test {
    @IsTest
    static void KXDeliveryClaim_tr_test() {
        Test.startTest();

        KXDeliveryClaim__c objKXDeliveryClaim = new KXDeliveryClaim__c();
        objKXDeliveryClaim.Name = '배송클레임 등록 테스트 1';
        objKXDeliveryClaim.CJLCenter__c = '서울센터';
        //objKXDeliveryClaim.Account__c = '1L커피다스(신연산점)';
        /* objKXDeliveryClaim.OrderDate__c = '2023. 8. 1.'; */
        objKXDeliveryClaim.ClaimType__c = '기타';
        objKXDeliveryClaim.Description__c = '배송클레임 등록 테스트 내용 입력';
        insert objKXDeliveryClaim;

        Test.stopTest();
    }
}