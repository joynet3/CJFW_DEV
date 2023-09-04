/**
* SolutionMappingTriggerHandler
*
*@group  Notificatoin
*@author 조형준
*@since 2023-08-14  최초작성
*/
public without sharing class SolutionMappingTriggerHandler extends TriggerHandler{
    @testVisible private List<SolutionMapping__c> news; 
    @testVisible private List<SolutionMapping__c> olds; 
    @testVisible private Map<Id, SolutionMapping__c> oldMap; 
    @testVisible private Map<Id, SolutionMapping__c> newMap;
    @testVisible private static Map<String, Schema.RecordTypeInfo> recordTypeMap;

    
    public SolutionMappingTriggerHandler() {
        news = (List<SolutionMapping__c>) Trigger.new;
        olds = (List<SolutionMapping__c>) Trigger.old;
        newMap  = (Map<Id,SolutionMapping__c>) Trigger.newMap;
        oldMap  = (Map<Id,SolutionMapping__c>) Trigger.oldMap;
    }

    public override void beforeInsert() {        
        getInquiryNumber(news);
    }

    public override void afterInsert() {        
        sendEmailToPartnerCompany(news);
    }

    /**
    * 솔루션 상담 리드 생성 시 해당 파트너사에 알림 이메일 송신
    *
    *@param  news 신규 생성 레코드
    *@return  
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    private void getInquiryNumber(List<SolutionMapping__c> news){
        List<SolutionMapping__c> solutionMappings = new List<SolutionMapping__c>();

        String inquiryNumber = '';

        solutionMappings = [SELECT InquiryNumber__c
                            FROM SolutionMapping__c 
                            WHERE CreatedDate = TODAY
                            ORDER BY InquiryNumber__c DESC
                            LIMIT 1
                            ];

        if(solutionMappings != null && solutionMappings.size() > 0)inquiryNumber = solutionMappings[0].InquiryNumber__c;

        for(SolutionMapping__c obj : news){
            //상담번호가 없는 경우 신규로 할당
            if(String.isBlank(inquiryNumber)){
                inquiryNumber = 'CJFW-' + System.now().format('yyyyMMdd') + '-0001';
            }else{
                String inquiryNumber1 = inquiryNumber.substringBeforeLast('-');
                Decimal inquiryNumber2 = Decimal.valueOf(inquiryNumber.substringAfterLast('-')) + 1;

                inquiryNumber = inquiryNumber1 + '-' + String.valueOf(inquiryNumber2).leftPad(4, '0');
            }  
            obj.InquiryNumber__c = inquiryNumber;
        }
    }
    /**
    * 솔루션 상담 리드 생성 시 해당 파트너사에 알림 이메일 송신
    *
    *@param  news 신규 생성 레코드
    *@return  
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    private void sendEmailToPartnerCompany(List<SolutionMapping__c> news){
        Map<Id, PartnerCompany__c> partnerCompanyMap = new Map<Id, PartnerCompany__c>();
        Set<String> setPartnerCompanyId = new Set<String>();

        // //파트너사 Id 가져오기
        // for(SolutionMapping__c obj : news){
        //     setPartnerCompanyId.add(obj.Solution__r.PartnerCompany__c);
        // }

        // //파트너사 정보 가져오기
        // partnerCompanyMap = new Map<Id, PartnerCompany__c>([
        //                                                     SELECT Id
        //                                                         , ManagerEmail__c
        //                                                     FROM PartnerCompany__c
        //                                                     WHERE Id IN :setPartnerCompanyId
        //                                                     ]);

        Map<String,List<NotiTarget>> notiPartnerMap = new Map<String,List<NotiTarget>>();       //파트너사
        Map<String,List<NotiTarget>> notiRequesterMap = new Map<String,List<NotiTarget>>();     //신청자
        Map<String,List<NotiTarget>> notiMAMap = new Map<String,List<NotiTarget>>();            //담당자

        Map<String,List<NotiTarget>> notiMap = new Map<String,List<NotiTarget>>();            //임시

        //이메일 발송 작업
        for(SolutionMapping__c obj : news){

            // List<NotiTarget> tempsPartner = new List<NotiTarget>();
            // List<NotiTarget> tempsRequester = new List<NotiTarget>();
            // List<NotiTarget> tempsMA = new List<NotiTarget>();

            // NotiTarget recipientPartnerId = new NotiTarget('Email');
            // NotiTarget recipientRequesterId = new NotiTarget('Email');
            // NotiTarget recipientMAId = new NotiTarget('Email');

            // if(String.isNotBlank(obj.Solution__r.PartnerCompany__r.ManagerEmail__c)) {
            //     recipientPartnerId.setToAddresses(new Set<String>{obj.Solution__r.PartnerCompany__r.ManagerEmail__c});
            //     tempsPartner.add(recipientPartnerId);
            //     notiPartnerMap.put(obj.Id, tempsPartner);
            // }

            // if(String.isNotBlank(obj.Lead__r.Email)){
            //     recipientRequesterId.setToAddresses(new Set<String>{obj.Lead__r.Email});
            //     tempsRequester.add(recipientRequesterId);
            //     notiRequesterMap.put(obj.Id, tempsRequester);
            // }
             
            // if(String.isNotBlank(obj.Account__r.Owner.Email)){
            //     recipientMAId.setToAddresses(new Set<String>{obj.Account__r.Owner.Email});
            //     tempsMA.add(recipientMAId);
            //     notiMAMap.put(obj.Id, tempsMA);
            // }

            List<NotiTarget> temps = new List<NotiTarget>();
            NotiTarget recipientId = new NotiTarget('Email');

            recipientId.setToAddresses(new Set<String>{'hj.jo16@cj.net'});

            temps.add(recipientId);
            notiMap.put(obj.Id, temps);
        }
        
        NotificationManager.getInstance()
                            .setTargetIdSet(notiMap.keySet())
                            .setRecipientListMap(notiMap)
                            .execute('Solution_Inquiry_Partner_Noti');

        // NotificationManager.getInstance()
        //                     .setTargetIdSet(notiPartnerMap.keySet())
        //                     .setRecipientListMap(notiPartnerMap)
        //                     .execute('Solution_Inquiry_Partner_Noti');

        // NotificationManager.getInstance()
        //                     .setTargetIdSet(notiRequesterMap.keySet())
        //                     .setRecipientListMap(notiRequesterMap)
        //                     .execute('Solution_Inquiry_Requester_Noti');

        // NotificationManager.getInstance()
        //                     .setTargetIdSet(notiMAMap.keySet())
        //                     .setRecipientListMap(notiMAMap)
        //                     .execute('Solution_Inquiry_MA_Noti');
    }
}