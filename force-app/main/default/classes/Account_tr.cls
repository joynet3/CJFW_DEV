/************************************************************************************
 * File Name   		: Account_tr.cls
 * Author	  		: Kim.Minje
 * Date				: 2022.08.19
 * Tester	  		: Account_tr_test.cls
 * Description 		: Account_tr Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2022.08.19      Minje.Kim       Create
*************************************************************************************/

public without sharing class Account_tr extends TriggerHandler {
    public Account_tr() {
        listNew = (List<Account>) Trigger.new;
        listOld = (List<Account>) Trigger.old;
        mapNew = (Map<Id, Account>) Trigger.newMap;
        mapOld = (Map<Id, Account>) Trigger.oldMap;
        recordIdEx = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ExistingCustomer').getRecordTypeId();
        strSchoolDepartmentId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SchoolDepartment').getRecordTypeId();
        strFSDepartmentId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FSDiscoveryDepartment').getRecordTypeId();
    }

    /*** TriggerHandler ***/
    private List<Account> listNew { get; set; }
    private List<Account> listOld { get; set; }
    private Map<Id, Account> mapOld { get; set; }
    private Map<Id, Account> mapNew { get; set; }
    private Id recordIdEx { get; set; }
    private Id strSchoolDepartmentId { get; set; }
    private Id strFSDepartmentId { get; set; }
    public override void beforeInsert() {        
        doInsertCustId();
        // 2023-02-22 필수값체크 제외 및 SMA 고객 I/F 필수값이 비어있는 경우 공백 넣어서 처리하도록 수정
        // 추후 필수값 데이터 전체 다 넣게 되면 주석해제
        //doCheckSMAField();
    }

    public override void beforeUpdate() {
        // 2023-02-22 필수값체크 제외 및 SMA 고객 I/F 필수값이 비어있는 경우 공백 넣어서 처리하도록 수정
        // 추후 필수값 데이터 전체 다 넣게 되면 주석해제
        //doCheckSMAField();
        doUpdateCheck();
    }

    public override void beforeDelete() {
        doDeleteCheck();
        doDeleteSendIFresh();
    }

    public override void afterInsert() {
        doUpsertSendIFresh();
        doUpdateParentId();
    }

    public override void afterUpdate() {
        doFieldTracking();
        // doUpsertSendIFresh();//AddrBulkUpdate_ba 테스트를 위해 임시 주석처리
        doUpdateParentId();
    }

    /***********************************************************************************************************
    *  Trigger : After Update    
    *  내용    : Field Tracking
    ************************************************************************************************************/
    private void doFieldTracking() {
        List<Account> listTargetNew = new List<Account>();
        Map<Id, Account> mapTargetOld = new Map<Id, Account>();

        for (Account obj : listNew) {
            if (obj.RecordTypeId != recordIdEx) {
                listTargetNew.add(obj);
                mapTargetOld.put(obj.Id, mapOld.get(obj.Id));
            }
        }

        // 2022-11-11 기존고객정보는 MDM으로 I/F하여 수정되기때문에 필드트래킹을 하지 않는다
        if (listTargetNew <> null && listTargetNew.size() > 0) {
            DN_FieldTracking.doFieldTrackingInsert('Account', 'AccountTracking', listTargetNew, mapTargetOld);
        }
    }

    /***********************************************************************************************************
    *  Trigger  : After Update    
    *  내용     : MDM고객정보(기존고객) 상위 고객 설정
    ************************************************************************************************************/
    private void doUpdateParentId() {
        Map<String,Account> mapTargetParent = new Map<String,Account>();

        for (Account obj : listNew) {
            if (obj.RecordTypeId == recordIdEx) {
                if ( (obj.HeadOfficeCode__c == null || obj.HeadOfficeCode__c == '') && obj.CustomerID__c != null && obj.CustomerID__c != '') {
                    mapTargetParent.put(obj.CustomerID__c, obj);
                }
            } 
        }

        if (!mapTargetParent.isEmpty()){
            
            List<Account> listChild = new List<Account>();
            listChild =  [SELECT  Id, CustomerID__c, HeadOfficeCode__c
                          FROM   Account 
                          WHERE  HeadOfficeCode__c IN: mapTargetParent.keySet()
                          AND    ParentId = null
                         ];

            if (!listChild.isEmpty()){
                for (Account objChild : listChild){
                    if (mapTargetParent.get(objChild.HeadOfficeCode__c) <> null){
                        objChild.parentId = mapTargetParent.get(objChild.HeadOfficeCode__c).Id;
                        objChild.isAdminUpdate__c = true;                    
                    }
                }
                update listChild;
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger  : Before Update    
    *  내용     :  MDM고객정보(기존고객)인경우 수정 불가 Valdiation
    ************************************************************************************************************/
    private void doUpdateCheck() {
        String strProfileName = [SELECT Name FROM profile WHERE id =: userinfo.getProfileId()].Name;
        for (Account obj : listNew) {
            if (obj.isAdminUpdate__c) {
                obj.isAdminUpdate__c = false;
            } else if (obj.RecordTypeId == recordIdEx) {
                if (!(strProfileName.contains('System Adminstrator') || strProfileName.contains('시스템 관리자'))) {
                    if (!Test.isRunningTest()) {
                        obj.addError('기존고객정보는 CRM에서 수정할 수 없습니다.');
                    }
                }
            } 
            // else if (mapOld.get(obj.Id).IsRequestMDMReg__c == true && obj.IsRequestMDMReg__c == true){
            //     if (!Test.isRunningTest()) {
            //         obj.addError('MDM 신규 고객 등록 요청 중인 고객은 수정할 수 없습니다.');
            //     }
            // }
        }
    }

    /***********************************************************************************************************
    *  Trigger  : Before Delete    
    *  내용     :  MDM고객정보(기존고객)인경우 삭제 불가 Valdiation
    ************************************************************************************************************/
    private void doDeleteCheck() {        
        String strProfileName = [SELECT Name FROM profile WHERE id =: userinfo.getProfileId()].Name;

        for (Account obj : listOld) {
            if (obj.isAdminUpdate__c) {
                obj.isAdminUpdate__c = false;
            } else if ( obj.RecordTypeId == strSchoolDepartmentId) {
                if (!(strProfileName.contains('System Adminstrator') || strProfileName.contains('시스템 관리자'))) {
                    if (!Test.isRunningTest())
                        obj.addError('학교정보는 직접 삭제할 수 없습니다. 관리자에게 문의하세요.');
                }
            } else if (obj.RecordTypeId == recordIdEx) {
                if (!(strProfileName.contains('System Adminstrator') || strProfileName.contains('시스템 관리자'))) {
                    if (!Test.isRunningTest())
                        obj.addError('기존고객정보는 CRM에서 삭제할 수 없습니다.');
                }
            } else if (mapOld.get(obj.Id).IsRequestMDMReg__c == true && obj.IsRequestMDMReg__c == true){
                if (!Test.isRunningTest()) {
                    obj.addError('MDM 신규 고객 등록 요청 중인 고객은 삭제할 수 없습니다.');
                }
            }
        }
    }
    
    /*
    private void doCheckSMAField() {
        for(Account obj : listNew) {
            if(obj.RecordTypeId == strSchoolDepartmentId) {
                // 고객ID 체크
                if(obj.custID__c == null || obj.custID__c ==  '') {
                    obj.custID__c.addError('['+obj.Name+'] 고객Id가 존재하지 않습니다. 관리자에게 문의하여 주시기 바랍니다.');
                }                
                // 전화번호 체크
                else if(obj.Phone == null || obj.Phone ==  '') {
                    obj.Phone.addError('['+obj.Name+'('+obj.custID__c+')] 필수값 전화번호 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // SMA 고객 입찰 방법 코드 체크
                else if(obj.sma_cust_bid_mtd_cd__c == null || obj.sma_cust_bid_mtd_cd__c ==  '') {
                    obj.sma_cust_bid_mtd_cd__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 MA 고객 입찰 방법 코드 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // SMA 고객 입찰 주기 코드 체크
                else if(obj.sma_cust_bid_cycl_cd__c == null || obj.sma_cust_bid_cycl_cd__c ==  '') {
                    obj.sma_cust_bid_cycl_cd__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 SMA 고객 입찰 주기 코드 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // SMA 고객 운영 형태 코드 체크
                else if(obj.sma_cust_mng_frm_cd__c == null || obj.sma_cust_mng_frm_cd__c ==  '') {
                    obj.sma_cust_mng_frm_cd__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 SMA 고객 운영 형태 코드 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // 배식 장소 코드 체크
                else if(obj.dstfd_mtd_cd__c == null || obj.dstfd_mtd_cd__c ==  '') {
                    obj.dstfd_mtd_cd__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 배식 장소 코드 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // 지역(시/도) 체크
                else if(obj.LocationStateProvince__c == null || obj.LocationStateProvince__c ==  '') {
                    obj.LocationStateProvince__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 지역(시/도) 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // 지역 체크
                else if(obj.LocationState__c == null || obj.LocationState__c ==  '') {
                    obj.LocationState__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 지역 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // 학교 고객 구분 코드 체크
                else if(obj.schl_cust_div_cd__c == null || obj.schl_cust_div_cd__c ==  '') {
                    obj.schl_cust_div_cd__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 학교 고객 구분 코드 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // 관할 시도 교육청 코드 체크
                else if(obj.jrsdt_cido_eduofic_cd__c == null || obj.jrsdt_cido_eduofic_cd__c ==  '') {
                    obj.jrsdt_cido_eduofic_cd__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 관할 시도 교육청 코드 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // 관할 구군 교육청 코드 체크
                else if(obj.jrsdt_gugun_eduofic_cd__c == null || obj.jrsdt_gugun_eduofic_cd__c ==  '') {
                    obj.jrsdt_gugun_eduofic_cd__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 관할 구군 교육청 코드 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // SMA 고객 관리 등급 코드 체크
                else if(obj.sma_cust_mng_grd_cd__c == null || obj.sma_cust_mng_grd_cd__c ==  '') {
                    obj.sma_cust_mng_grd_cd__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 SMA 고객 관리 등급 코드 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
                // 특이 내용 체크
                else if(obj.odd_txt__c == null || obj.odd_txt__c ==  '') {
                    obj.odd_txt__c.addError('['+obj.Name+'('+obj.custID__c+')] 필수값인 특이 내용 정보가 존재하지 않습니다. 고객정보를 확인하여 주시기 바랍니다.');
                }
            }
        }
    }
    */

    /***********************************************************************************************************
    *  Trigger  : After Insert, After Update   
    *  내용     :  SMA고객정보인 경우 I-FRESH I/F 실행
    ************************************************************************************************************/
    private void doUpsertSendIFresh() {
        System.debug(':: doUpsertSendIFresh ::');
        Map<String, Account> mapCustIdToAcc = new Map<String, Account>();
        Boolean flag = false;

        for (Account obj : listNew) {
            // 2023-03-03 주소(Address__c)와 우편번호(PostalCode__c)가 없어도 전송되도록 수정
            if (obj.RecordTypeId.equals(strSchoolDepartmentId)) {
                if (mapCustIdToAcc.get(obj.custID__c) != null) {
                    flag = true;
                    obj.addError('중복된 고객ID가 있습니다. 관리자에게 문의해주세요');
                }else{
                    mapCustIdToAcc.put(obj.custID__c, obj);
                }
            }
            /*
            if (obj.RecordTypeId.equals(strSchoolDepartmentId) && obj.Address__c != null && obj.PostalCode__c != null) {
                if (mapCustIdToAcc.get(obj.custID__c) != null) {
                    flag = true;
                    obj.addError('중복된 고객ID가 있습니다. 관리자에게 문의해주세요');
                }else{
                    mapCustIdToAcc.put(obj.custID__c, obj);
                }
            }
            */
        }

        if (mapCustIdToAcc != null && mapCustIdToAcc.size() >    0) {
            if (flag == true) {
                for (Account obj :  mapCustIdToAcc.values()) {
                    obj.addError('중복된 고객ID가 있습니다. 관리자에게 문의해주세요');
                }
            }else{
                List<Id> listTargetId = new List<Id>();
                Set<Id> setUserId = new Set<Id>();
                Map<Id, String> mapCUD = new Map<Id, String>();

                for (Account obj : mapCustIdToAcc.values()) {
                    listTargetId.add(obj.Id);
                    setUserId.add(obj.CreatedById);
                    setUserId.add(obj.OwnerId);
                    
                    if ((mapOld == null || mapOld.get(obj.Id) == null)) {
                        mapCUD.put(obj.Id, 'C');
                    } else {
                        mapCUD.put(obj.Id, 'U');
                    }

                    // if ((mapOld == null || mapOld.get(obj.Id) == null)) {
                    //     mapCUD.put(obj.Id, 'C');
                    // } else if (!mapNew.get(obj.Id).IsSentToSma__c && (mapOld.get(obj.Id).Address__c == null || mapOld.get(obj.Id).PostalCode__c == null)) {
                    //     mapCUD.put(obj.Id, 'C');
                    // } else {
                    //     mapCUD.put(obj.Id, 'U');
                    // }
                }
                if (listTargetId != null && !listTargetId.isEmpty() && mapCUD != null && !mapCUD.isEmpty()) {
                    IF_SFDC_IFRESH_REG_ACCOUNT.doSend(listTargetId, setUserId, mapCUD, null);
                }
            }
        }
    }

    /***********************************************************************************************************
    *  Trigger  : Before Delete    
    *  내용     :  SMA 고객정보 삭제시 I-FRESH I/F
    ************************************************************************************************************/
    private void doDeleteSendIFresh() {
        System.debug(' :: doDeleteSendIFresh ::');
        Map<String, Account> mapCustIdToAcc = new Map<String, Account>();
        Boolean flag = false;
        for (Account obj : listOld) {
            if (obj.RecordTypeId.equals(strSchoolDepartmentId)) {
                if (mapCustIdToAcc.get(obj.custID__c) != null) {
                    flag = true;
                    obj.addError('중복된 고객ID가 있습니다. 관리자에게 문의해주세요');
                }else {
                    mapCustIdToAcc.put(obj.custID__c, obj);
                }
            }
        }
        if (mapCustIdToAcc != null && mapCustIdToAcc.size() > 0) {
            if (flag) {
                for (Account obj: mapCustIdToAcc.values()){
                    obj.addError('중복된 고객ID가 있습니다. 관리자에게 문의해주세요');
                }
            }else {

                System.debug('mapCustIdToAcc.keySet() :: ' + mapCustIdToAcc.keySet());
                IF_SFDC_IFRESH_REG_ACCOUNT.doSend(null, null, null, mapCustIdToAcc.keySet());
            }
        }
    }
    
    /***********************************************************************************************************
    *  Trigger  : Before Insert    
    *  내용     :  SMA 고객정보 신규 생성시 고객번호(custId__c) 생성
    ************************************************************************************************************/
    public void doInsertCustId() {
        List<Account> listSMTarget = new List<Account>();
        List<Account> listFSTarget = new List<Account>();

        for (Account obj : listNew) {
            if (obj.RecordTypeId.equals(strSchoolDepartmentId) && obj.custID__c == null) {
                listSMTarget.add(obj);
            }
            else if (obj.RecordTypeId.equals(strFSDepartmentId) && obj.custID__c == null){
                listFSTarget.add(obj);
            }
        }

        if (!listSMTarget.isEmpty()) {
            String year = String.valueOf(Date.today().year()).substring(2, 4);
            Integer cntNumber = 0;
            List<Account> listLastAccount = new List<Account>([SELECT custID__c FROM Account WHERE custID__c != NULL AND custID__c LIKE 'SM%' ORDER BY custID__c DESC LIMIT 1]);
            if (listLastAccount <> null && listLastAccount.size() > 0) {
                cntNumber = year.equals(listLastAccount[0].custID__c.substring(2, 4)) ? Integer.valueOf(listLastAccount[0].custID__c.substring(4)) : 0;
            }

            for (Account obj : listSMTarget) {
                cntNumber += 1;
                obj.custID__c = 'SM' + year + String.valueOf(cntNumber).leftPad(5, '0');
            }
        }

        
        if (!listFSTarget.isEmpty()) {
            String year = String.valueOf(Date.today().year()).substring(2, 4);
            Integer cntNumber = 0;
            List<Account> listLastAccount = new List<Account>([SELECT custID__c FROM Account WHERE custID__c != NULL AND custID__c LIKE 'FS%' ORDER BY custID__c DESC LIMIT 1]);
            if (listLastAccount <> null && listLastAccount.size() > 0) {
                cntNumber = year.equals(listLastAccount[0].custID__c.substring(2, 4)) ? Integer.valueOf(listLastAccount[0].custID__c.substring(4)) : 0;
            }

            for (Account obj : listFSTarget) {
                cntNumber += 1;
                obj.custID__c = 'FS' + year + String.valueOf(cntNumber).leftPad(5, '0');
            }
        }
    }
}