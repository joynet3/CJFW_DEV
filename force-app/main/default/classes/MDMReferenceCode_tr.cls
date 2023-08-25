/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class MDMReferenceCode_tr extends TriggerHandler {
    public MDMReferenceCode_tr() {
        listNew = (List<MDMReferenceCode__c>) trigger.new;
        mapOld = (Map<Id, MDMReferenceCode__c>) trigger.oldMap;
        listOld = (List<MDMReferenceCode__c>) trigger.old;
    }

    /*** TriggerHandler ***/
    private List<MDMReferenceCode__c> listNew { get; set; }
    private List<MDMReferenceCode__c> listOld { get; set; }
    private Map<Id, MDMReferenceCode__c> mapOld { get; set; }

    public override void beforeInsert() {
        doSetDefaultData();
        doCheckIsDefault();
        doCheckParent();
    }

    public override void beforeUpdate() {
        doSetDefaultData();
        doCheckIsDefault();
        doCheckParent();
    }

    public override void afterUpdate() {
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert, Before Update    
    *  내용    : 레코드 생성, 변경시 Name, ExtId__c(Key) 자동 세팅
    ************************************************************************************************************/    
    private void doSetDefaultData() {
        for(MDMReferenceCode__c obj : listNew) {
            obj.Name = '['+obj.Code__c+']'+obj.NAME_KO__c;
            obj.ExtId__c = obj.GROUPID__c+'_'+obj.Code__c;
        }
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert, Before Update    
    *  내용    : 레코드 생성, 변경시 기본값이 true로 변경될 경우 이전 기본값 false로 변경
    ************************************************************************************************************/        
    private void doCheckIsDefault() {
        List<MDMReferenceCode__c> listTarget = new List<MDMReferenceCode__c>();
        Set<String> setRefId = new Set<String>();
        Set<String> setGroupId = new Set<String>();
        for(MDMReferenceCode__c obj : listNew) {
            if(obj.IsDefault__c) {
                setRefId.add(obj.Id);
                listTarget.add(obj);

                if(obj.GROUPID__c <> null) {
                    setGroupId.add(obj.GROUPID__c);
                }
            }
        }

        if(listTarget <> null && listTarget.size() > 0) {
            List<MDMReferenceCode__c> listBeforeDefault = new List<MDMReferenceCode__c>();

            listBeforeDefault = [
                SELECT  Id, GROUPID__c, IsDefault__c
                FROM    MDMReferenceCode__c
                WHERE   GROUPID__c In:setGroupId
                AND     IsDefault__c = true
                AND    (Id NOT In:setRefId)
            ];

            if(listBeforeDefault <> null && listBeforeDefault.size() > 0) {
                for(MDMReferenceCode__c obj : listBeforeDefault) {
                    obj.IsDefault__c = false;
                }

                update listBeforeDefault;
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger : Before Insert, Before Update    
    *  내용    : 레코드 생성, 변경시 ParentGroupId__c, ParentCode__c 값이 빈값이 아닌경우 Parent__c 연결
    ************************************************************************************************************/        
    private void doCheckParent() {
        List<MDMReferenceCode__c> listTarget = new List<MDMReferenceCode__c>();
        Set<String> setParentCode = new Set<String>();

        for(MDMReferenceCode__c obj : listNew) {
            if(obj.ParentGroupId__c <> null && obj.ParentCode__c <> null) {
                String strParentExtId = obj.ParentGroupId__c+'_'+obj.ParentCode__c;
                setParentCode.add(strParentExtId);
                listTarget.add(obj);
            }
        }

        if(listTarget <> null && listTarget.size() > 0) {
            Map<String, String> mapParentId = new Map<String, String>();

            for(MDMReferenceCode__c obj : [
                SELECT  Id, ExtId__c
                FROM    MDMReferenceCode__c
                WHERE   ExtId__c In:setParentCode
            ]) {
                mapParentId.put(obj.ExtId__c, obj.Id);
            }

            for(MDMReferenceCode__c obj : listTarget) {
                String strParentExtId = obj.ParentGroupId__c+'_'+obj.ParentCode__c;
                obj.Parent__c = mapParentId.get(strParentExtId);
            }
        }
    }
}