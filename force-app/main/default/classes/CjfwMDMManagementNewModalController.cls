/**
 * @description       : 
 * @author            : joohyeon.jang@dkbmc.com
 * @group             : 
 * @last modified on  : 08-09-2023
 * @last modified by  : joohyeon.jang@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-09-2023   joohyeon.jang@dkbmc.com   Initial Version
**/
public with sharing class CjfwMDMManagementNewModalController {
    public CjfwMDMManagementNewModalController(ApexPages.StandardSetController controller){
    }

     /**
     * @description 세금계산서 발행 Tab의 From발행일자을 달의 첫날로 Setting
     * 
     * @return      `Date`
     */
    @AuraEnabled
    public static Date getTodayDate(){
        Date result = System.today();
        
        return result;
    }
}