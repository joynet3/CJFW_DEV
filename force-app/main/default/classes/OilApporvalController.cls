/*
* ==================================================================================
*   File Name   : OilApporvalController.cls
*   Author      : Minje.Kim
*   Date        : 2022.11.27
*   Tester      : OilApporvalController_test.cls
*   Description : OilApporvalController Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.11.27    Minje.Kim    Create
* ==================================================================================
*/
public without sharing class OilApporvalController {

    /**
     * 주유비 정산 탭 Init (현 사용자의 유형 [사업부장(BM), 팀장(TM), IT, 어시스턴스(AS)] 및 탭 권한 판단 )
     * 
     * @params 없음
     * @return Map<String, Object> 사용자 유형, 주유비 승인 권한, 주유비 전표처리 권한
     *
    **/
    @AuraEnabled
    public static Map<String, Object> doInit() {

        String UserType = 'None';
        Boolean approvalTabAccess = false;
        Boolean sendTabAccess = false;

        // 1. 현 사용자 쿼리
        User objUser = [
            SELECT  Id, EmployeeNumber, HeadOffice__c, SU__c, Team__c, CJTitle__c, UserRole.DeveloperName, Profile.Name
            FROM    User
            WHERE   Id =: UserInfo.getUserId()
        ];

        // 2. 직책, 프로필명, 권한 집합 여부로 사용자 유형 및 탭 접근 권한 여부 판단
        if ( objUser.CJTitle__c == 'BM' || objUser.CJTitle__c == 'TM'){
            UserType = objUser.CJTitle__c;
        }
        else if ( objUser.UserRole.DeveloperName == 'IT' || objUser.Profile.Name == '시스템 관리자' || objUser.Profile.Name == 'CJFW System Adminstrator' || objUser.Profile.Name == 'System Adminstrator')
        {
            UserType = 'IT';
            approvalTabAccess = true;
            sendTabAccess = true;
        }

        List<PermissionSetAssignment> listUserPermissionSetAssignment = [
                SELECT Id,PermissionSet.Name, PermissionSetId
                FROM   PermissionSetAssignment
                WHERE  AssigneeId = :UserInfo.getUserId()
        ];

        if ( !listUserPermissionSetAssignment.isEmpty()){
            for(PermissionSetAssignment objPermissionSetAssignment : listUserPermissionSetAssignment) {
                if(objPermissionSetAssignment.PermissionSet.Name == 'OilPermission_Approval') {
                    approvalTabAccess = true;
                }
                if(objPermissionSetAssignment.PermissionSet.Name == 'OilPermission_Send') {
                    approvalTabAccess = true;
                    sendTabAccess = true;
                    UserType = 'AS';
                }
            }
        }

        // 3. Return 값 
        Map<String, Object> mapInitData = new Map<String, Object>{            
            'userType' => UserType,
            'approvalTabAccess' => approvalTabAccess,
            'sendTabAccess' => sendTabAccess
        };

        return mapInitData;
    }
}