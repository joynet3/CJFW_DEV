/************************************************************************************
 * File Name   		: Lead_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.08.19
 * Tester	  		: Lead_tr_test.cls
 * Description 		: Lead_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.08.19      Minje.Kim       Create
*************************************************************************************/

public without sharing class Lead_tr extends TriggerHandler {
    public Lead_tr() {
        listNew = (List<Lead>) trigger.new;
        mapOld = (Map<Id, Lead>) trigger.oldMap;
        listOld = (List<Lead>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<Lead> listNew { get; set; }
    private List<Lead> listOld { get; set; }
    private Map<Id, Lead> mapOld { get; set; }

    public override void beforeInsert() {    
    }

    public override void afterInsert() {        
        createOrderServiceRequest();
    }

    public override void beforeUpdate() {
        doOwnerUpdateCheck();
    }

    public override void afterUpdate() {
        doFieldTracking();
        orderServiceRequestMappingAccount();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking(사용자들이 변경한 데이터만 생성되도록 I/F를 통한 업데이트는 제외)
    ************************************************************************************************************/
    private void doFieldTracking() {
        List<Lead> listTargetNew = new List<Lead>();
        Map<Id, Lead> mapTargetOld = new Map<Id, Lead>();

        for(Lead obj : listNew) {
            String UserName = UserInfo.getUserName().toLowerCase(); 
            if(!(UserName.contains('admin') || UserName.contains('interface')) || UserName.contains('freshway')) {
                listTargetNew.add(obj);
                mapTargetOld.put(obj.Id, mapOld.get(obj.Id));
            }
        }

        // 2022-11-11 LEAD 공공데이터 API I/F로 인해 수정될 경우 필드트래킹 하지 않는다
        if(listTargetNew <> null && listTargetNew.size() > 0) {
            DN_FieldTracking.doFieldTrackingInsert('Lead', 'LeadTracking', listTargetNew, mapTargetOld);
        }
    }

    /***********************************************************************************************************
    *  Trigger : Before Update    
    *  내용    : 자신이 소유한 레코드만 소유자를 변경할 수 있도록 Validation
    ************************************************************************************************************/    
    private void doOwnerUpdateCheck() {
        List<Lead> listTarget = new List<Lead>();
        Set<String> setOwnerId = new Set<String>();

        for(Lead obj : listNew) {
            if(obj.OwnerId <> mapOld.get(obj.Id).OwnerId) {
                listTarget.add(obj);
                setOwnerId.add(mapOld.get(obj.Id).OwnerId);
            }
        }

        if(listTarget <> null && listTarget.size() > 0) {
            Map<String, String> mapUser = new Map<String, String>();

            for(User obj : [
                SELECT  Id, Name
                FROM    User
                WHERE   Id In:setOwnerId
            ]) {
                mapUser.put(obj.Id, obj.Name);
            }

            for(Lead obj : listTarget) {
                if(mapUser <> null && mapUser.get(obj.OwnerId) <> null) {
                    String strTargetUserName = mapUser.get(obj.OwnerId);
                    System.debug('============> strTargetUserName : '+strTargetUserName);
                    String UserName = UserInfo.getUserName().toLowerCase(); 
                    if(!(UserName.contains('admin') || UserName.contains('interface')) || UserName.contains('freshway')) {
                        if(!Test.isRunningTest()) 
                            obj.addError('다른 사용자 잠재고객의 소유자는 변경 불가합니다.');
                    }
                }
            }
        }
    }

    /**
    * 리드 생성 시 1:1문의 생성(온리원비즈넷)
    *
    *@param  listNew
    *@return  
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    private void createOrderServiceRequest() {
        System.debug('createOrderServiceRequest Start');
        Map<String, List<String>> pickSolutionMap = new Map<String, List<String>>();
        Map<String, Account> accountMap = new Map<String, Account>();

        List<OrderServiceRequest__c> orderServiceRequestList = new List<OrderServiceRequest__c>();
        List<Account> accounts = new List<Account>();

        Map<String, Lead> leadMap = new Map<String, Lead>();
        Map<String, Lead> duplicateLeadMap = new Map<String, Lead>();
        List<Lead> duplicateLeadList = new List<Lead>();
        List<Lead> deleteLeadList = new List<Lead>();

        Set<String> newId = new Set<String>();

        //리드 중복 체크
        for(Lead obj : listNew){
            if(String.isNotBlank(obj.InquiryDivision__c)){
                if(String.isNotBlank(obj.CompanyRegisterNumber__c))leadMap.put(obj.CompanyRegisterNumber__c, obj); newId.add(obj.Id);
            }
        }
        System.debug('leadMap : ' + leadMap);

        duplicateLeadList = [SELECT Id
                                    , Name
                                    , CompanyRegisterNumber__c
                             FROM Lead
                             WHERE CompanyRegisterNumber__c != null
                             AND InquiryDivision__c != null
                             AND CompanyRegisterNumber__c IN :leadMap.keySet()
                             AND(NOT Id IN :newId)
                             ORDER BY CreatedDate DESC
                             ];

        //중복 건에 대한 업데이트 작업
        for(Lead obj : duplicateLeadList){
            obj.LastName = leadMap.get(obj.CompanyRegisterNumber__c).LastName ;
            obj.isPersonalInfoUse__c = leadMap.get(obj.CompanyRegisterNumber__c).isPersonalInfoUse__c ;
            obj.isThirdPartyInfoUse__c = leadMap.get(obj.CompanyRegisterNumber__c).isThirdPartyInfoUse__c;
            obj.isMarketingUse__c = leadMap.get(obj.CompanyRegisterNumber__c).isMarketingUse__c;
            obj.isMarketingUseCall__c = leadMap.get(obj.CompanyRegisterNumber__c).isMarketingUseCall__c;
            obj.isMarketingUseEmail__c = leadMap.get(obj.CompanyRegisterNumber__c).isMarketingUseEmail__c;
            obj.isMarketingUseSMS__c = leadMap.get(obj.CompanyRegisterNumber__c).isMarketingUseSMS__c;

            duplicateLeadMap.put(obj.CompanyRegisterNumber__c, obj);
        }

        System.debug('duplicateLeadMap : ' + duplicateLeadMap);

        Update duplicateLeadList;

        //온리원비즈넷 상담 구분용 레코드 타입 아이디 가져오기
        String recordTypeId = [SELECT Id
                                        , Name
                                FROM RecordType
                                WHERE sObjectType = 'OrderServiceRequest__c'
                                AND DeveloperName = 'OnlyoneBiznetInquiry']?.Id
                                ;

        Set<String> setCompanyRegisterNumber = new Set<String>();

        //솔루션 상담은 솔루션 매핑을 위해 솔루션 id 가공
        for(Lead obj : listNew){
            if(String.isNotBlank(obj.SolutionIds__c)) pickSolutionMap.put(obj.CompanyRegisterNumber__c, obj.SolutionIds__c.split(','));
            setCompanyRegisterNumber.add(obj.CompanyRegisterNumber__c);
        }

        //기존(잠재)고객의 경우 고객정보 룩업(사업자 번호 기준)
        accounts = [SELECT Id
                        , CompanyRegisterNumber__c
                    FROM Account
                    WHERE CompanyRegisterNumber__c != null
                    // AND (NOT Owner.Profile.Name IN ('시스템 관리자', 'System Administrator'))
                    AND CompanyRegisterNumber__c IN :setCompanyRegisterNumber
                    ORDER BY LastModifiedDate ASC
                    ];

        for(Account obj : accounts){
            accountMap.put(obj.CompanyRegisterNumber__c, obj);
        }

        //1:1문의내역 생성 작업
        for(Lead obj : listNew){
            //중복 리드 적재
            if(duplicateLeadMap.containsKey(obj.CompanyRegisterNumber__c)) deleteLeadList.add(obj);
            //온리원비즈넷 상담(리드)에 대해서만 1:1문의 생성
            if(String.isNotBlank(obj.InquiryDivision__c)){
                //솔루션 상담
                if(pickSolutionMap.containsKey(obj.CompanyRegisterNumber__c)){
                    List<String> pickSolutionList = pickSolutionMap.get(obj.CompanyRegisterNumber__c);
                    for(String str : pickSolutionList){
                        OrderServiceRequest__c sObj = new OrderServiceRequest__c();                  
    
                        sObj.RecordTypeId = recordTypeId;
                        sObj.Lead__c = duplicateLeadMap.containsKey(obj.CompanyRegisterNumber__c) ? duplicateLeadMap.get(obj.CompanyRegisterNumber__c).Id : obj.Id;
                        sObj.Solution__c = str;
                        sObj.Account__c = accountMap.containsKey(obj.CompanyRegisterNumber__c) ? accountMap.get(obj.CompanyRegisterNumber__c).Id : null;
                        sObj.InquiryContent__c = obj.InquiryContent__c;
                        sObj.InquiryStyle__c = obj.InquiryStyle__c;
                        sObj.InquiryDivision__c = obj.InquiryDivision__c;
                        sObj.InquiryStyleContent__c = obj.InquiryStyleContent__c;
                        sObj.isPersonalInfoUse__c = obj.isPersonalInfoUse__c;
                        sObj.isMarketingUse__c = obj.isMarketingUse__c;
                        sObj.isMarketingUseSMS__c = obj.isMarketingUseSMS__c;
                        sObj.isMarketingUseCall__c = obj.isMarketingUseCall__c;
                        sObj.isMarketingUseEmail__c = obj.isMarketingUseEmail__c;
                        sObj.isthirdPartyInfoUse__c = obj.isthirdPartyInfoUse__c;
                        sObj.StoreAmount__c = obj.StoreAmount__c;
                        sObj.isSeller__c = obj.isSeller__c;
                        sObj.CompanyRegisterNumber__c = obj.CompanyRegisterNumber__c;
                        sObj.RequesterName__c = obj.RequesterName__c;
                        sObj.RequesterEmail__c = obj.Email;
                        sObj.RequesterPhone__c = obj.Phone;
                        sObj.LocationStateProvince__c = obj.LocationStateProvince__c;
                        sObj.LocationState__c = obj.LocationState__c;
                        sObj.SiteDivision__c = obj.SiteDivision__c;
    
                        orderServiceRequestList.add(sObj);
                    }
                }else{//식자재 상담
                        OrderServiceRequest__c sObj = new OrderServiceRequest__c();                  
    
                        sObj.RecordTypeId = recordTypeId;
                        sObj.Lead__c = duplicateLeadMap.containsKey(obj.CompanyRegisterNumber__c) ? duplicateLeadMap.get(obj.CompanyRegisterNumber__c).Id : obj.Id;
                        sObj.Account__c = accountMap.containsKey(obj.CompanyRegisterNumber__c) ? accountMap.get(obj.CompanyRegisterNumber__c).Id : null;
                        sObj.InquiryContent__c = obj.InquiryContent__c;
                        sObj.InquiryStyle__c = obj.InquiryStyle__c;
                        sObj.InquiryDivision__c = obj.InquiryDivision__c;
                        sObj.InquiryStyleContent__c = obj.InquiryStyleContent__c;
                        sObj.isPersonalInfoUse__c = obj.isPersonalInfoUse__c;
                        sObj.isMarketingUse__c = obj.isMarketingUse__c;
                        sObj.isMarketingUseSMS__c = obj.isMarketingUseSMS__c;
                        sObj.isMarketingUseCall__c = obj.isMarketingUseCall__c;
                        sObj.isMarketingUseEmail__c = obj.isMarketingUseEmail__c;
                        sObj.isthirdPartyInfoUse__c = obj.isthirdPartyInfoUse__c;
                        sObj.StoreAmount__c = obj.StoreAmount__c;
                        sObj.isSeller__c = obj.isSeller__c;
                        sObj.CompanyRegisterNumber__c = obj.CompanyRegisterNumber__c;
                        sObj.RequesterName__c = obj.RequesterName__c;
                        sObj.RequesterEmail__c = obj.Email;
                        sObj.RequesterPhone__c = obj.Phone;
                        sObj.LocationStateProvince__c = obj.LocationStateProvince__c;
                        sObj.LocationState__c = obj.LocationState__c;
                        sObj.SiteDivision__c = obj.SiteDivision__c;
    
                        orderServiceRequestList.add(sObj);
                }
            }
        }

        System.debug('deleteLeadList : ' + deleteLeadList);
        System.debug('orderServiceRequestList : ' + orderServiceRequestList);

        if(orderServiceRequestList!= null && orderServiceRequestList.size() > 0) {
            //Web to Lead 기능 사용으로 인하여 중복 리드 삭제 및 1:1문의 생성용 배치 값 전달 및 호출
            DE_CreateOrderServiceRequestQueueable queueable = new DE_CreateOrderServiceRequestQueueable();
            queueable.orderServiceRequestList = orderServiceRequestList;
            queueable.deleteLeadList = deleteLeadList;
            System.debug('queueable.orderServiceRequestList : ' + queueable.orderServiceRequestList);
            System.enqueueJob(queueable);
        }
    }

    /**
    * 리드 >> 고객으로 변환 시 1:1문의내역 오브젝트에 매핑 작업
    *
    *@param  listNew
    *@return  
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    private void orderServiceRequestMappingAccount() {
        Map<String, String> leadToAccountMap = new Map<String, String>();
        List<OrderServiceRequest__c> OrderServiceRequestList = new List<OrderServiceRequest__c>();

        for(Lead obj : listNew){
            if(obj.isConverted) leadToAccountMap.put(obj.Id, obj.ConvertedAccountId);
        }

        OrderServiceRequestList = [SELECT Id
                                        , Lead__c
                                    FROM OrderServiceRequest__c
                                    WHERE Account__c = null
                                    AND Lead__c != null
                                    AND Lead__c IN :leadToAccountMap.keySet()
                                    ];

        for(OrderServiceRequest__c obj : OrderServiceRequestList){
            obj.Account__c = leadToAccountMap.get(obj.Lead__c);
        }

        Update OrderServiceRequestList;
    }
}