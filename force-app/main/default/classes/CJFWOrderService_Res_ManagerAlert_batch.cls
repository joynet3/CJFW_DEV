/**
 * @description       : 주문시스템 담당자알림 및 상태변경
 * @author            : 백영주
 * @group             : 
 * @last modified on  : 08-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
/***
 * 1. status '접수' '답변지연' 레코드 조회
 * 2. 접수 상태 레코드 접수일 + 10일 = 오늘 에 해당하는경우 답변지연상태로 변경
 * 3. 
 * 
 */
public without sharing class CJFWOrderService_Res_ManagerAlert_batch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    public CJFWOrderService_Res_ManagerAlert_batch() {
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        string strQuery = 'SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Title__c, ReqType__c, RequestMessage__c, SampleitemText1__c, SampleitemText2__c, SampleitemText3__c, ExtraServiceCategory__c, MDMReferenceCode__c, RequestDate__c, Finder__c, Status__c, ResponseDate__c, ResponseTitle__c, Manager__c, ResponseMessage__c, ReqRecordId__c, Sampleitem1__c, Sampleitem2__c, Sampleitem3__c from OrderServiceRequest__c where';
        strQuery += ' WHERE Status__c =\'접수\'';
        strQuery += ' OR Status__c =\'답변지연\'';
        return Database.getQueryLocator(strQuery);
    }
    public void execute(Database.BatchableContext BC, List<OrderServiceRequest__c> listTarget) {
        List<OrderServiceRequest__c> newResList = new List<OrderServiceRequest__c>();
        List<OrderServiceRequest__c> lateResList = new List<OrderServiceRequest__c>();
        // 현재 날짜를 가져옴
        Date today = Date.today();

        // 10일 전 날짜를 계산하여 변수에 저장
        Date targetDate = today.addDays(-10);
        try{
            for(OrderServiceRequest__c OSR : listTarget){
                if(OSR.Status__c == '접수' && OSR.RequestDate__c > targetDate){
                    newResList.add(OSR);
                }else{
                    OSR.Status__c = '답변지연';
                    lateResList.add(OSR);
                }
            }
            update lateResList;
        }catch(exception e){

        }finally{

        }

    }
    public void finish(Database.BatchableContext BC) {
        System.debug('CJFWOrderService_Res_ManagerAlert_batch finish !!');
    }
}