/**
 * @description       :
 * @author            : sunkyung.choi@dkbmc.com
 * @group             :
 * @last modified on  : 11-22-2023
 * @last modified by  : sunkyung.choi@dkbmc.com
**/
public with sharing class CJFW_SurveyMapping {

    @AuraEnabled public static void getMappingInfo(
        CJFW_SurveyResponse__c response,
        List<CJFW_SurveyResult__c> responsResultList
    ) {

        System.debug('response check' + response);
        Map<String, String> resultMap = new Map<String, String>();
        Set<Id> responseIdSet = new Set<Id>();

        Set<Id> accIdSet = new Set<Id>();
        Set<Id> leadIdSet = new Set<Id>();

        for (CJFW_SurveyResult__c resRes : responsResultList) {
            responseIdSet.add(resRes.SurveyResponse__c);
        }
        System.debug('responseIdSet ??? ' + responseIdSet);

        List<CJFW_SurveyResult__c> resultList = [
            SELECT Id,
            Name,
            SurveyResponse__r.Lead__c,
            SurveyResponse__c,
            SurveyQuestion__c,
            SurveyOption__c,
            OpenEnded__c,
            DateResult__c,
            TimeResult__c,
            FM_Question__c FROM CJFW_SurveyResult__c WHERE SurveyResponse__c = : responseIdSet
        ];
        System.debug('resultList' + resultList);

        List<CJFW_SurveyResponse__c> responseList = [
            SELECT Id,
            Name,
            Survey__c,
            ResponseDate__c,
            Lead__c,
            Lead__r.LastName,
            Lead__r.FirstName,
            Lead__r.Email,
            Lead__r.Phone,
            Lead__r.MobilePhone,
            Account__c,
            Opportunity__c FROM CJFW_SurveyResponse__c WHERE Id = : responseIdSet
        ];

        System.debug('responseList' + responseList);

        for (CJFW_SurveyResult__c suveyResult : resultList) {
            resultMap.put(suveyResult.FM_Question__c, suveyResult.OpenEnded__c);
        }

        for (CJFW_SurveyResponse__c suveyRespon : responseList) {
            accIdSet.add(suveyRespon.Account__c);
            leadIdSet.add(suveyRespon.Lead__c);
        }

        System.debug('resultMap ??? ' + resultMap);
        System.debug('accIdSet ??? ' + accIdSet);

        if (response.Lead__c != null) {
            System.debug('Lead Start');
            Lead updateLead = new Lead (Id = response.Lead__c);
            for (CJFW_SurveyResult__c res : resultList) {
                System.debug('Lead Start 22'); 

                // System.debug('updateLeadLists'+updateLeadLists);
                if (resultMap.containsKey(res.FM_Question__c)) {
                    String openEndedValue = resultMap.get(res.FM_Question__c);
                    // for (Lead leadList : updateLeadLists) {
                        if (res.FM_Question__c.contains('이름')) {
                            updateLead.LastName = openEndedValue;
                            system.debug('lead LastName 확인' + updateLead.LastName);
                        } else if (res.FM_Question__c.contains('이메일')) {
                            updateLead.Email = openEndedValue;
                            system.debug('lead Email 확인' + updateLead.Email);
                        } else if (res.FM_Question__c.contains('연락처')) {
                            updateLead.Phone = openEndedValue;
                            system.debug('lead Phone 확인' + updateLead.Phone);
                        }
                    // }
                    

                }
            }
            System.debug('updateLead '+updateLead);
            update updateLead;

        } else if (response.Opportunity__c != null || response.Account__c != null) {
            List<Contact> conList = [
                SELECT id, name, AccountId, Phone, Email FROM Contact WHERE AccountId IN: accIdSet
            ];
            List<Contact> allConLists = [
                SELECT id, name, AccountId, Phone, Email FROM Contact 
            ];
            Boolean check = false;

            for (CJFW_SurveyResult__c res : resultList) {
                System.debug('contact Start');
                if (resultMap.containsKey(res.FM_Question__c)) {
                    System.debug('contact Start 22');
                    String openEndedValue = resultMap.get(res.FM_Question__c);
                    for (Contact con : conList) {
                            if (res.FM_Question__c.contains('이름')) {
                                con.LastName = openEndedValue;
                                system.debug('contact Phone 확인' + con.LastName);
                            } else if (res.FM_Question__c.contains('이메일')) {
                                con.Email = openEndedValue;
                                system.debug('contact Phone 확인' + con.Email);
                            } else if (res.FM_Question__c.contains('연락처')) {
                                con.Phone = openEndedValue;
                                system.debug('contact Phone 확인' + con.Phone);
                            }
                    }
                }
            }
            Contact newContact = new Contact();
            for (Contact allConList : allConLists) {
                if (allConList.Email == conList[0].Email) {
                    check =true;
                }else if (allConList.Email != conList[0].Email) {
                    
                    newContact.AccountId = response.Account__c;
                    newContact.LastName = conList[0].LastName;
                    newContact.Email = conList[0].Email;
                    newContact.Phone = conList[0].Phone;
                }
            }
            if (check) {
                update conList;
            }else{
                insert newContact;
            }
        }
    }
}