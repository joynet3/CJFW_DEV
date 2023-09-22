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
    
    public String OpptyId { get; set; }
    public DecisionProcess__c decisionProcessRecord { get; set; }
    
    /* 
     * 생성자
     */
    public CJFW_CreateNewReportPageController() {
        
        OpptyId = '0060w00000D8yoKAAR'; // 추후 url에서 Id값 가져오는 걸로 변경예정 
        // OpptyId = ApexPages.currentPage().getParameters().get('recordId');
        // System.debug('Id = ' + OpptyId);
        
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
                                WHERE Opportunity__c =: OpptyId
                                ORDER BY CreatedDate DESC
                                LIMIT 1]; 
    }

}