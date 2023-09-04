/**
* 솔루션 상담 신청 이메일 알림 전용 동적 헨들러
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 조형준
*@since 2023-08-31  내용 작성
*/
public without sharing class SolutionInquiryNotiHandler extends NotiHandler {
    /**
    * Id 집합으로 Category 별 템플릿 개인화를 위해 데이터 불러오는 메소드 
    * override 시 Map<String, List<NotiTemplate>> categorySendDataListMap 값 저장 필수
    *@param  targetIdSet 알림 내용을 만드는 데이터 sObject Id Set
    */
    public override void manuFactureNoti(Set<String> targetIdSet) {
        //담당MA 소속 팀 관련
        List<UserRole> userRoles = new List<UserRole>();
        Map<String, UserRole> userRoleMap = new Map<String, UserRole>();
    
        try{
            String query = 'SELECT Solution__r.Name'
                     + '         , Solution__r.PartnerCompany__r.Department__c'
                     + '         , Lead__r.InquiryContent__c'
                     + '         , InquiryNumber__c'
                     + '         , Lead__r.LastName'
                     + '         , Lead__r.RequesterName__c'
                     + '         , Lead__r.Phone'
                     + '         , Lead__r.Email'
                     + '         , Account__r.Owner.Id'
                     + '         , Account__r.Owner.Name'
                     + '         , Account__r.Owner.UserRoleId' 
                     + '         , Account__r.Owner.UserRole.Name' 
                     + '         , Account__r.Owner.UserRole.ParentRoleId' 
                     + '         , Account__r.Owner.Profile.Name' 
                     + ' FROM SolutionMapping__c'
                     + ' WHERE Id IN :targetIdSet ';
    
            List<SolutionMapping__c> datas;
            if(!targetIdSet.isEmpty()) datas = Database.query(query);

            System.debug('datas size : ' + datas.size());

            //담당MA 소속 팀 정보
            userRoles = [SELECT Id
                                    , Name
                                    , ParentRoleId
                            FROM UserRole
                            WHERE Id IN :userRoles
                            ];

            for(UserRole obj : userRoles){
                userRoleMap.put(obj.Id, obj);
            }

            Map<String,List<NotiTarget>> recipientListMap = NotificationManager.getInstance().getRecipientListMap(); 

            for(SolutionMapping__c obj : datas){
                //필요한 데이터 쿼리 및 맵으로 가공
                Map<String,NotiEmailTemplate> langTemplateMap = (Map<String,NotiEmailTemplate>)categoryTemplateMapMap.get('Email');
                Map<String, String> fieldsMap = new Map<String, String>();
                List<NotiTarget> recipientList = recipientListMap.get(obj.Id);
                System.debug('langTemplateMap : ' + langTemplateMap);
                System.debug('recipientList size : ' + recipientList.size());

                String requestName = obj.Lead__r.RequesterName__c;

                fieldsMap.put('Solution__r.Name', obj.Solution__r.Name);
                fieldsMap.put('Solution__r.PartnerCompany__r.Department__c', obj.Solution__r.PartnerCompany__r.Department__c);
                fieldsMap.put('Lead__r.InquiryContent__c', obj.Lead__r.InquiryContent__c);
                fieldsMap.put('InquiryNumber__c', obj.InquiryNumber__c);
                fieldsMap.put('Lead__r.LastName', obj.Lead__r.LastName);
                fieldsMap.put('Lead__r.Phone', obj.Lead__r.Phone);
                fieldsMap.put('Lead__r.Email', obj.Lead__r.Email);
                
                //담당MA(기존 고객만)
                if(String.isNotBlank(obj.Account__r.Owner.Name) 
                && !obj.Account__r.Owner.Profile.Name.equals('시스템 관리자') 
                && !obj.Account__r.Owner.Profile.Name.equals('System Administrator')){
                    String userRole = obj.Account__r.Owner.UserRole.Name;

                    if(obj.Account__r.Owner.UserRole.Name.endsWith('팀')){
                        requestName += ' (담당 MA : ' + obj.Account__r.Owner.Name + '/' + userRole + ')'; //(담당 MA : 여지영님 / DT추진팀)
                    } else {
                        //팀을 찾을때 까지 반복
                        Boolean doFlag = true;
                        do {
                            if(userRoleMap.containsKey(obj.Account__r.Owner.UserRole.ParentRoleId) 
                            && userRoleMap.get(obj.Account__r.Owner.UserRole.ParentRoleId).Name.endsWith('팀')){
                                userRole = userRoleMap.get(obj.Account__r.Owner.UserRole.ParentRoleId).Name;
                                doFlag = false;
                            }
                        } while (doFlag);
                        requestName += ' (담당 MA : ' + obj.Account__r.Owner.Name + '/' + userRole + ')';
                    }
                }
                
                fieldsMap.put('requestName', requestName);

                for(NotiTarget recipient : recipientList) {
                    setEmailPersonalize(
                        langTemplateMap
                        , fieldsMap
                        , obj.Id
                        , recipient.getLang()
                        , recipient.getToAddresses()
                        , recipient.getCcAddresses()
                        , recipient.getBccAddresses()
                        , recipient.getAttachmentIds()
                        , false
                    );
                }
            }
        }catch(Exception e){
            System.debug('ERROR MESSAGE : ' + e.getMessage());
            System.debug('ERROR STACK : ' + e.getStackTraceString());
        }
    }
}