/**
* 커뮤니티 상담 신청 기능 컨트롤러
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 조형준
*@since 2023-08-11  내용 작성
*/
public without sharing class DE_InquiryRequestController {
    public enum Existence {NEWER, EXISTENCE, STOP}

    /**
    * 기존 거래 고객 여부 확인 및 고객 정보 리턴
    *
    *@param  CompanyRegisterNumber 사업자 등록 번호(-없이)
    *@return  LeadWrapper 고객정보
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static LeadWrapper checkAccount(String CompanyRegisterNumber) {
        LeadWrapper result = new LeadWrapper();

        try{
            List<Account> accList = [SELECT Id
                                        ,CompanyRegisterNumber__c
                                        , Name
                                        , Address__c
                                        , AddressDetails__c
                                        , LocationStateProvince__c
                                        , LocationState__c
                                        , Phone
                                        , CustomerStatus__c
                                FROM Account
                                WHERE CompanyRegisterNumber__c = :CompanyRegisterNumber
                                ORDER BY CompanyRegisterNumber__c, CustomerID__c, CreatedDate
                                ];

            if(accList.size() > 0){
                result = new LeadWrapper(accList[0]);

                if(accList[0].CustomerStatus__c.equals('01') || accList[0].CustomerStatus__c.equals('02')){
                    result.accountCheck = String.valueOf(Existence.EXISTENCE);
                }else{
                    result.accountCheck = String.valueOf(Existence.STOP);
                }
            }else{
                result.accountCheck = String.valueOf(Existence.NEWER);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }

        return result;
    }

    /**
    * 메소드 설명 작성
    *
    *@param  
    *@return  Community Lead Record Type Id
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static String getLeadRecordTypeId(){
        String result = [SELECT Id
                                    , DeveloperName
                            FROM RecordType
                            WHERE SobjectType = 'Lead'
                            AND DeveloperName = 'Community_Lead'
                                ].Id;

        return result;
    }

    // /**
    // * 상담 신청 레코드 생성
    // *
    // *@param  leadJson 상담 신청 데이터(Json)
    // *@return  CommonWrapper 공통 리턴 정보
    // *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    // *@example 
    // * 예제코드 태그 아래줄에서 예제 작성
    // */
    // @AuraEnabled
    // public static CommonWrapper createLeadRecord(String leadJson){
    //     CommonWrapper result = new CommonWrapper();
    //     Savepoint sp = Database.setSavepoint();

    //     try {
    //         LeadWrapper wrapper = (LeadWrapper) JSON.deserialize(leadJson, LeadWrapper.class);

    //         String leadRecordTypeId = [SELECT Id
    //                                     , DeveloperName
    //                             FROM RecordType
    //                             WHERE SobjectType = 'Lead'
    //                             AND DeveloperName = 'Community_Lead_Data'
    //                             ].Id;

    //         Lead lead = wrapper.getLead(leadRecordTypeId);

    //         Database.SaveResult sr = Database.Insert(lead, false);

    //         System.debug(sr);

    //         if(!sr.isSuccess()){
    //             for (Database.Error err : sr.getErrors()) {
    //                 result.message = err.getMessage();
    //                 result.isSuccess  = false;
    //             }
    //             return result;
    //         }

    //         //선택한 솔루션이 있는 경우 리드와 매핑
    //         if(wrapper.pickSolutionList != null && wrapper.pickSolutionList.size() > 0){
    //             List<SolutionMapping__c> solutionJunctionList = new List<SolutionMapping__c>();
    //             String leadRecordId = sr.getId();

    //             // String inquiryNumber = [SELECT InquiryNumber__c
    //             //                         FROM SolutionMapping__c 
    //             //                         WHERE CreatedDate = TODAY
    //             //                         ORDER BY InquiryNumber__c DESC
    //             //                         ].InquiryNumber__c;

    //             for(String str : wrapper.pickSolutionList){
    //                 SolutionMapping__c obj = new SolutionMapping__c();

    //             //     //상담번호가 없는 경우 신규로 할당
    //             //     if(String.isBlank(inquiryNumber)){
    //             //         inquiryNumber = 'CJFW-' + Date.today().year() + '' + Date.today().month() + '' + Date.today().day() + '-0001';
    //             //     }else{
    //             //         String inquiryNumber1 = inquiryNumber.substringBeforeLast('-');
    //             //         Integer inquiryNumber2 = Integer.valueOf(inquiryNumber.substringAfterLast('-')) + 1;

    //             //         inquiryNumber = inquiryNumber1 + String.valueOf(inquiryNumber2).leftPad(4, '0');
    //             //     }                    

    //                 obj.Lead__c = leadRecordId;
    //                 obj.Solution__c = str;

    //                 solutionJunctionList.add(obj);
    //             }

    //             Database.SaveResult[] srList = Database.Insert(solutionJunctionList, false);

    //             for (Database.SaveResult obj : srList) {
    //                 if(!obj.isSuccess()){
    //                     for (Database.Error err : obj.getErrors()) {
    //                         result.message = err.getMessage();
    //                         result.isSuccess  = false;
    //                         System.debug(result);
    //                     }
    //                     return result;
    //                 }
    //             }
    //         }
    //     } catch (Exception e) {
    //         result.message = e.getMessage();
    //         result.isSuccess = false;
    //         System.debug(result);
    //         System.debug(e.getStackTraceString());
    //         Database.rollback(sp);
    //     }

    //     return result;
    // }

    /**
    * 파트너사 레코드 생성
    *
    *@param  partnerJson 파트너사 정보(Json)
    *@return  CommonWrapper 공통 리턴 정보
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static CommonWrapper createPartnerRecord(String partnerJson){
        CommonWrapper result = new CommonWrapper();
        Savepoint sp = Database.setSavepoint();

        try {
            PartnerWrapper wrapper = (PartnerWrapper) JSON.deserialize(partnerJson, PartnerWrapper.class);

            PartnerCompany__c partner = wrapper.getPartner();

            Database.SaveResult sr = Database.Insert(partner, false);

            if(!sr.isSuccess()){
                for (Database.Error err : sr.getErrors()) {
                    result.message = err.getMessage();
                    result.isSuccess  = false;
                }
                return result;
            }

        } catch (Exception e) {
            result.message = e.getMessage();
            result.isSuccess = false;
            Database.rollback(sp);
        }

        return result;
    }

    /**
    * 시도 라벨, 값 가져오기
    *
    *@param  
    *@return  List<valuesWrapper> List<label, value> 형태
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<valuesWrapper> getLocationStateProvince(){
        List<valuesWrapper> result= new List<valuesWrapper>();
        
        try {
            Schema.DescribeFieldResult fieldResult = Lead.LocationStateProvince__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            for(Schema.PicklistEntry value : ple){ 
                result.add(new valuesWrapper(value.getLabel(), value.getValue()));
            }     
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    /**
    * 시도에 해당하는 시도군 값 가져오기
    *
    *@param  locationStateProvince 시,도 값(value)
    *@return  List<valuesWrapper> List<label, value> 형태
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<valuesWrapper> getDependentPicklistValues(String locationStateProvince) {
        Schema.sObjectField dependToken = Lead.LocationState__c;
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();

        List<valuesWrapper> result = new List<valuesWrapper>();

        if (controlToken == null) {
            return result;
        }

        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<valuesWrapper>> dependentPicklistValues = new Map<String,List<valuesWrapper>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<valuesWrapper>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(new valuesWrapper(entry.getLabel(), entry.getValue()));
                }
            }
        }

        result = dependentPicklistValues.get(locationStateProvince);

        return result;
    }

    /**
    * 솔루션 기능 영역 값 가져오기
    *
    *@param  
    *@return  List<valuesWrapper> List<label, value> 형태
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<valuesWrapper> getFunctionCategory(){
        List<valuesWrapper> result= new List<valuesWrapper>();
        
        try {
            Schema.DescribeFieldResult fieldResult = Solution__c.FunctionCategory__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            for(Schema.PicklistEntry value : ple){ 
                result.add(new valuesWrapper(value.getLabel(), value.getValue()));
            }     
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    /**
    * 선택한 기능 카테고리에 해당하는 솔루션 가져오기
    * F01 : 운영효율
    * F02 : 비용절감
    * F03 : 수익확대
    * F04 : 인사이트
    *
    *@param  pickValues ex) F01;F02;F03;
    *@return  List<SolutionWrapper>
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<SolutionWrapper> getSolutions(String pickValues){
        List<SolutionWrapper> result= new List<SolutionWrapper>();
        List<Solution__c> solutions = new List<Solution__c>();

        try {
            String pickValuesAsString = '(\'' + String.join(pickValues.split(';'), '\', \'') + '\')';

            String query = 'SELECT Id'
                         +  '    , Name' 
                         +  '    , ServiceReport__c '
                         +  ' FROM Solution__c';
            String qWhere = 'WHERE RelatedUrl__c = null'; //23.09.11 외부 상담 건의 경우 제외

            if(String.isNotBlank(pickValues) && !pickValues.equals('ALL')) qWhere += ' AND FunctionCategory__c INCLUDES ' + pickValuesAsString;

            solutions = Database.query(query + qWhere);

            if(solutions.size() > 0){
                for(Solution__c obj : solutions){
                    result.add(new SolutionWrapper(obj));
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    /**
    * 파트너십 영역 픽리스트 값 가져오기
    *
    *@param  
    *@return  List<valuesWrapper> List<label, value> 형태
    *@exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
    *@example 
    * 예제코드 태그 아래줄에서 예제 작성
    */
    @AuraEnabled
    public static List<valuesWrapper> getDepartment(){
        List<valuesWrapper> result= new List<valuesWrapper>();
        
        try {
            Schema.DescribeFieldResult fieldResult = PartnerCompany__c.Department__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            for(Schema.PicklistEntry value : ple){ 
                result.add(new valuesWrapper(value.getLabel(), value.getValue()));
            }     
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    public class LeadWrapper{
        @AuraEnabled public String companyRegisterNumber  {get;set;}//사업자등록번호
        @AuraEnabled public String name                   {get;set;}//업장명
        @AuraEnabled public String address                {get;set;}//경로
        @AuraEnabled public String addressDetails         {get;set;}//상세주소
        @AuraEnabled public String locationStateProvince  {get;set;}//시도
        @AuraEnabled public String locationState          {get;set;}//시군구
        @AuraEnabled public String phone                  {get;set;}//신청자 연락처
        @AuraEnabled public String email                  {get;set;}//신청자 이메일
        @AuraEnabled public String requesterName          {get;set;}//신청자 명
        @AuraEnabled public String inquiryContent         {get;set;}//상담내용
        @AuraEnabled public String isPersonalInfoUse      {get;set;}//개인정보 수집 동의 여부
        @AuraEnabled public String isThirdPartyInfoUse    {get;set;}//제3자 정보제공 이용 동의
        @AuraEnabled public String isMarketingUse         {get;set;}//홍보 및 마케팅 이용 동의
        @AuraEnabled public Integer storeAmount           {get;set;}//운영중인 사업장 수
        @AuraEnabled public Boolean isSeller              {get;set;}//현재 거래중인 식자재 유통업채 유무
        @AuraEnabled public String inquiryStyle           {get;set;}//상담 방식 call, visit, etc
        @AuraEnabled public String inquiryStyleContent    {get;set;}//상담 방식(기타) 내용
        @AuraEnabled public List<String> pickSolutionList = new List<String>();//Solution Ids

        //신규 기존 확인용
        @AuraEnabled public String accountCheck           {get;set;} //EXISTENCE : 기존; STOP : 과거 고객; NEWER : 신규;

        // public Lead getLead(String leadRecordTypeId){
        //     Lead result = new Lead();

        //     result.RecordTypeId = leadRecordTypeId;

        //     result.CompanyRegisterNumber__c     = this.companyRegisterNumber;
        //     result.LastName                     = this.name;
        //     result.Address__c                   = this.address;
        //     result.AddressDetails__c            = this.addressDetails;
        //     result.LocationStateProvince__c     = this.locationStateProvince;
        //     result.LocationState__c             = this.locationState;
        //     result.Phone                        = this.phone;
        //     result.Email                        = this.email;
        //     result.RequesterName__c             = this.requesterName;
        //     result.InquiryContent__c            = this.inquiryContent;
        //     result.InformationAgreement__c      = this.informationAgreement;
        //     result.StoreAmount__c               = this.storeAmount;
        //     result.isSeller__c                  = this.isSeller == null ? false : this.isSeller;
        //     result.InquiryStyle__c              = this.inquiryStyle;
        //     result.InquiryStyleContent__c       = this.inquiryStyleContent;
        //     result.Company                      = this.name;

        //     //Required
        //     result.Company = this.name;

        //     return result;
        // }

        public leadWrapper(){}

        public leadWrapper(Account acc){
            this.companyRegisterNumber  = acc.CompanyRegisterNumber__c;
            this.name                   = acc.Name;
            this.address                = acc.Address__c;
            this.addressDetails         = acc.AddressDetails__c;
            this.locationStateProvince  = acc.LocationStateProvince__c;
            this.locationState          = acc.LocationState__c;
            this.phone                  = acc.Phone;
            //this.email                  = acc.Email; Account에 값 없음 확인 필요 >> 이메일 값은 무조건 받는걸로.
            this.inquiryContent         = '';
            // this.informationAgreement   = '';
        }
    }

    public class PartnerWrapper{
       @AuraEnabled public String department                {get;set;}//파트너십 분야
       @AuraEnabled public String name                      {get;set;}//회사명
       @AuraEnabled public String sectors                   {get;set;}//업종
       @AuraEnabled public String majorBussiness            {get;set;}//주요 사업
       @AuraEnabled public String managerName               {get;set;}//담당자명
       @AuraEnabled public String managerPhone              {get;set;}//담당자 연락처
       @AuraEnabled public String managerEmail              {get;set;}//담당자 이메일
       @AuraEnabled public String solutionName              {get;set;}//솔루션 명
       @AuraEnabled public String solutionDescription       {get;set;}//솔루션 설명
       @AuraEnabled public Boolean isPersonalInfoUse        {get;set;}//개인정보 수집 동의 여부
       @AuraEnabled public Boolean isThirdPartyInfoUse      {get;set;}//제3자 정보제공 이용 동의
       @AuraEnabled public Boolean isMarketingUse           {get;set;}//홍보 및 마케팅 이용 동의

       public PartnerCompany__c getPartner(){
            PartnerCompany__c result = new PartnerCompany__c();

            result.Department__c                = this.department;
            result.Name                         = this.name;
            result.Sectors__c                   = this.sectors;
            result.MajorBussiness__c            = this.majorBussiness;
            result.ManagerName__c               = this.managerName;
            result.ManagerPhone__c              = this.managerPhone;
            result.ManagerEmail__c              = this.managerEmail;
            result.SolutionName__c              = this.solutionName;
            result.SolutionDescription__c       = this.solutionDescription;
            result.isPersonalInfoUse__c         = this.isPersonalInfoUse;
            result.isThirdPartyInfoUse__c       = this.isThirdPartyInfoUse;
            result.isMarketingUse__c            = this.isMarketingUse;

            return result;
       }
    }

    public class CommonWrapper{
        @AuraEnabled public Boolean isSuccess   {get;set;} 
        @AuraEnabled public String message      {get;set;} 
        @AuraEnabled public String result       {get;set;} 

        public CommonWrapper(){
            this.isSuccess 		= true;
            this.message 	= '';
            this.result 	= '';
        }
    }

    public class valuesWrapper{
        @AuraEnabled public String label    {get;set;}
        @AuraEnabled public String value    {get;set;}

        public valuesWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    public class SolutionWrapper {
        @AuraEnabled public String label                    {get; set;} // 솔루션 명
        @AuraEnabled public String recordId                 {get; set;} // 솔루션 레코드 Id
        @AuraEnabled public String serviceReport            {get; set;} // 솔루션 요약 설명
        
        public SolutionWrapper(Solution__c obj){
            this.label = obj.Name;
            this.recordId = obj.Id;
            this.serviceReport = obj.ServiceReport__c;
        }
    }
}