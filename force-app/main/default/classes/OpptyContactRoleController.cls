public without sharing class OpptyContactRoleController {

    @AuraEnabled
    public static Map<String, Object> doGetParentId(String recordId) {

        OpportunityContactRole objRole = [
            SELECT  Id, OpportunityId
            FROM    OpportunityContactRole
            WHERE   Id =: recordId
        ];

        Map<String, Object> mapInitData = new Map<String, Object>{
            'parentId' => objRole.OpportunityId
        };
        return mapInitData;
    }
}