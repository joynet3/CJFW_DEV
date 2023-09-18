/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 09-18-2023
 * @last modified by  : yeonji.lim@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   09-18-2023   yeonji.lim@dkbmc.com      Initial Version
**/
public with sharing class CJFW_CreateNewReportPageController {
    
    /* 품의생성 데이터 관련 변수 */
    public String recordId { get; set; }
    public DecisionProcess__c decisionProcessRecord { get; set; }
    
    public CJFW_CreateNewReportPageController() {
        // url에서 레코드 아이디 가져와야함
        getRecord();
    }

    /* 
     * 품의이력Obj에서 해당 레코드 데이터 가져오기
     */
    public void getRecord(){
        decisionProcessRecord = [SELECT Id,
                                        ReportSignature__c,
                                        Summary__c,
                                        ClientCompanyName__c,
                                        RepresentativeName__c,
                                        BusinessPath__c,
                                        SalesMonthly__c,
                                        OurSales__c,
                                        InitialDate__c,
                                        Address__c,
                                        RepresentativePhone__c,
                                        PV_EXISTSUP__c,
                                        ExceptionPrice__c,
                                        OpptyDescription__c,
                                        AttachedDocument__c
                                FROM DecisionProcess__c 
                                LIMIT 1];
    }

}