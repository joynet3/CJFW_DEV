/*
* ==================================================================================
*   File Name   : AccountOwnerParentController.cls
*   Author      : sy.Lee
*   Date        : 2023.05.26
*   Tester      : AccountOwnerParentController_test.cls
*   Description : AccountOwnerParentController Controller
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2023.05.26    sy.Lee          Create
* ==================================================================================
*/
public without sharing class AccountOwnerParentController {
    /**
     * 고객 담당자 변경 탭 Init (현 사용자의 유형 FS, SMA, ADMIN 판단 )
     * 
     * @params 없음
     * @return Map<String, Object> 사용자 유형
     *
    **/
    @AuraEnabled
    public static Map<String, Object> doInit() {

        Boolean isIT = false;
        Boolean isSMA = false;
        Boolean isFS = false;

        // 1. 현 사용자 쿼리
        User objUser = [
            SELECT  Id, EmployeeNumber, HeadOffice__c, SU__c, Team__c, CJTitle__c, UserRole.DeveloperName, Profile.Name
            FROM    User
            WHERE   Id =: UserInfo.getUserId()
        ];

        List<PermissionSetAssignment> listUserPermissionSetAssignment = [
                SELECT Id,PermissionSet.Name, PermissionSetId
                FROM   PermissionSetAssignment
                WHERE  AssigneeId = :UserInfo.getUserId()
        ];

        // 2. 직책, 프로필명, 권한 집합 여부로 사용자 유형 및 탭 접근 권한 여부 판단
        if ( objUser.UserRole.DeveloperName == 'IT' || objUser.Profile.Name == '시스템 관리자' || objUser.Profile.Name == 'CJFW System Adminstrator' || objUser.Profile.Name == 'System Adminstrator')
        {
            isIT = true;
        }else if(objUser.Profile.Name == 'CJFW_FS개발사업부'){
            isFS = true;
        }else if(objUser.Profile.Name == 'CJFW_튼튼사업부'){
            isSMA = true;
        }

        if ( !listUserPermissionSetAssignment.isEmpty()){
            for(PermissionSetAssignment objPermissionSetAssignment : listUserPermissionSetAssignment) {
                if(objPermissionSetAssignment.PermissionSet.Name == 'SMAPermissionSet') {
                    isSMA = true;
                }
            }
        }

        // 3. Return 값 
        Map<String, Object> mapInitData = new Map<String, Object>{            
            'isIT' => isIT,
            'isSMA' => isSMA,
            'isFS' => isFS
        };

        return mapInitData;
    }
}