/**
 * @description       : I-FRESH SMA고객정보 전송 Class
 * @author            : admin
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : admin
**/
global without sharing class IF_SFDC_IFRESH_REG_ACCOUNT {
    @Future(Callout=true)
    public static void doSend(List<String> listTargetAccoutId, Set<Id> setUserId, Map<Id, String> mapCUD, Set<String> setTargetcustId) {
        System.debug('[IF_SFDC_IFRESH_REG_ACCOUNT] doSend !!!!!');
//        String strStatus = 'SUCCESS';
//        String strMessage = '성공';
//        DataWrapper objDataWrap = new DataWrapper();
        try {
            System.debug('setUserId :: ' + setUserId);
            Map<Id, User> mapUser = new Map<Id, User>([SELECT Id, EmployeeNumber FROM User WHERE Id IN :setUserId]);
            User objUser = [SELECT Id, EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()];
            String if_Id = 'IF_SFDC_IFRESH_REG_ACCOUNT';
            System.debug('if_Id =========>' + if_Id);
            List<Map<String, Object>> listJsonData = new List<Map<String, Object>>();
            Map<String, List<Map<String,Object>>> mapDataWrap = new Map<String, List<Map<String, Object>>>();
            IFUtil i = new IFUtil(if_Id);

            if (listTargetAccoutId != null) {
                List<Account> targetAccout = new List<Account>(
                [
                        SELECT custID__c, Name, sma_cust_bid_mtd_cd__c, sma_cust_bid_cycl_cd__c
                                , sma_cust_mng_frm_cd__c, dstfd_mtd_cd__c, brf_mlcnt__c, lnc_mlcnt__c, din_mlcnt__c
                                , schl_cust_div_cd__c, OwnerId, jrsdt_cido_eduofic_cd__c, jrsdt_gugun_eduofic_cd__c, dlv_agc_nm__c
                                , sma_cust_mng_grd_cd__c, sboil_us_brd_nm__c, ecof_fdr_us_rt__c, odd_txt__c, PostalCode__c, Address__c, AddressDetails__c
                                , pmeal_cst__c, Phone, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, LocationStateProvince__c, LocationState__c
                                ,tot_mlcnt__c
                        FROM Account
                        WHERE Id IN :listTargetAccoutId
                ]);
                System.debug('TargetAccount :: ' + targetAccout);


                for (Account obj : targetAccout) {
                    Map<String, Object> mapData = new Map<String, Object>();
                    if (mapCUD != null) {
                        String CUDCode = mapCUD.get(obj.Id);
                        System.debug('[IF_SFDC_IFRESH_REG_ACCOUNT] Upsert');
                        mapData.put('co_id', 'FW00');                //회사 ID : FW00으로 고정
                        mapData.put('sma_cust_bid_mtd_cd', obj.sma_cust_bid_mtd_cd__c <> null ? obj.sma_cust_bid_mtd_cd__c : ' ');       //SMA 고객 입찰 방법 코드
                        mapData.put('sma_cust_bid_cycl_cd', obj.sma_cust_bid_cycl_cd__c <> null ? obj.sma_cust_bid_cycl_cd__c : ' ');       //SMA 고객 입찰 주기 코드
                        mapData.put('sma_cust_mng_frm_cd', obj.sma_cust_mng_frm_cd__c <> null ? obj.sma_cust_mng_frm_cd__c : ' ');       //SMA 고객 운영 형태 코드
                        mapData.put('dstfd_mtd_cd', obj.dstfd_mtd_cd__c <> null ? obj.dstfd_mtd_cd__c : ' ');       //배식 방법 코드
                        mapData.put('tot_mlcnt', obj.tot_mlcnt__c <> null ? obj.tot_mlcnt__c : 0);       //총 식수
                        mapData.put('brf_mlcnt', obj.brf_mlcnt__c <> null ? obj.brf_mlcnt__c : 0);       //조식 식수
                        mapData.put('lnc_mlcnt', obj.lnc_mlcnt__c <> null ? obj.lnc_mlcnt__c : 0);       //중식 식수
                        mapData.put('din_mlcnt', obj.din_mlcnt__c <> null ? obj.din_mlcnt__c : 0);       //석식 식수
                        mapData.put('schl_cust_div_cd', obj.schl_cust_div_cd__c <> null ? obj.schl_cust_div_cd__c : ' ');       //학교 고객 구분 코드
                        mapData.put('sma_crg_sman_id', mapUser.get(obj.OwnerId).EmployeeNumber);       //SMA 담당 영업사원 ID
                        mapData.put('jrsdt_cido_eduofic_cd', obj.jrsdt_cido_eduofic_cd__c <> null ? obj.jrsdt_cido_eduofic_cd__c : ' ');       //관할 시도 교육청 코드
                        mapData.put('jrsdt_gugun_eduofic_cd', obj.jrsdt_gugun_eduofic_cd__c <> null ? obj.jrsdt_gugun_eduofic_cd__c : ' ');       //관할 구군 교육청 코드
                        mapData.put('dlv_agc_nm',obj.dlv_agc_nm__c);       //납품 대리점 명
                        mapData.put('sma_cust_mng_grd_cd', obj.sma_cust_mng_grd_cd__c <> null ? obj.sma_cust_mng_grd_cd__c : ' ');       //SMA 고객 관리 등급 코드
                        mapData.put('sboil_us_brd_nm', obj.sboil_us_brd_nm__c);       //대두유 사용 브랜드 명
                        mapData.put('ecof_fdr_us_rt', obj.ecof_fdr_us_rt__c <> null ? obj.ecof_fdr_us_rt__c : 0);       //친환경 식자재 사용 률
                        mapData.put('odd_txt', obj.odd_txt__c <> null ? obj.odd_txt__c : ' ');       //특이 내용
                        mapData.put('cust_zip', obj.PostalCode__c <> null ? obj.PostalCode__c : ' ');       //고객 우편번호
                        mapData.put('cust_addr', obj.Address__c <> null ? obj.Address__c : ' ');       //고객 주소
                        mapData.put('cust_dtl_addr', obj.AddressDetails__c <> null ? obj.AddressDetails__c : ' ');       //고객 상세 주소
                        mapData.put('pmeal_cst', obj.pmeal_cst__c <> null ? obj.pmeal_cst__c : 0);       //급식 비
                        mapData.put('cust_tel_no', obj.Phone <> null ? obj.Phone : ' ');       //고객 전화 번호
                        if ( CUDCode == 'C'){
                            mapData.put('regr_id', mapUser.get(obj.CreatedById).EmployeeNumber <> null ? mapUser.get(obj.CreatedById).EmployeeNumber : ' ');       //등록자 ID
                            mapData.put('reg_dt', obj.CreatedDate);       //등록 일시
                        }
                        mapData.put('updr_id', objUser.EmployeeNumber <> null ? objUser.EmployeeNumber : ' ');       //수정자 ID
                        mapData.put('upd_dt', obj.LastModifiedDate);       //수정 일시
                        mapData.put('cido_cd', obj.LocationStateProvince__c <> null ? obj.LocationStateProvince__c : ' ');       //시도 코드
                        mapData.put('gugun_cd', obj.LocationState__c <> null ? obj.LocationState__c : ' ');       //구군 코드
//                        mapData.put('gugun_cd', obj.oven_poss_yn__c);       //오븐 보유 여부
//                        mapData.put('gugun_cd', obj.crt_wrt_cycl_bd__c);       //식단 작성주기 내역
                        mapData.put('system_type_cd', 'IF1004');     //적용 구분 코드
                        mapData.put('opcode', 'CR017');     //적용 구분 코드
                        mapData.put('sma_cust_nm', obj.Name);        //SMA 고객 명
                        mapData.put('cust_id', obj.custID__c);       //고객 ID
                        mapData.put('APLY_DIV_CD', CUDCode);     //적용 구분 코드
                    }
                    listJsonData.add(mapData);
                }
            } else {
                for (String custId : setTargetcustId) {
                    Map<String, Object> mapData = new Map<String, Object>();
                    System.debug('[IF_SFDC_IFRESH_REG_ACCOUNT] Delete');
                    mapData.put('cust_id', custId);       //고객 ID
                    mapData.put('APLY_DIV_CD', 'D');
                    listJsonData.add(mapData);
                }
            }

            mapDataWrap.put('ds_list', listJsonData);
            String strReqJSON = JSON.serialize(mapDataWrap);
            System.debug('============================> strReqJSON : ' + strReqJSON);

            HttpResponse response = i.webCallout(strReqJSON, true);
            System.debug('response.getStatusCode() =======> ' + response.getStatusCode());

            String responseBody = response.getBody();
            System.debug('responseBody =======> ' + responseBody);

            Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('mapResponse =======> ' + mapResponse);
            String strCode = String.valueOf(mapResponse.get('err_cd'));
            if (strCode.equals('9999') && mapResponse.get('err_msg_ctt') != null) {
                if (mapResponse.get('err_msg_ctt') != '') {
                    String jsonErrMsgCtt = JSON.serialize(mapResponse.get('err_msg_ctt'));
                    List<Map<String,String>> mapErrMsgCtt = (List<Map<String,String>>) JSON.deserialize(jsonErrMsgCtt, List<Map<String,String>>.class);
                    System.debug(mapErrMsgCtt);
                    //Error msg 처리
                }
//                System.debug('err_msg_ctt :: ' + mapResponse.get('err_msg_ctt'));
            }
            System.debug('err_msg_ctt :: ' + mapResponse.get('err_msg_ctt'));
        } catch (Exception e) {
//            strStatus = 'ERROR';
//            strMessage = e.getMessage() + ' Line : ' + e.getLineNumber();
            System.debug('strMessage ===> ' + e.getMessage() + ' Line : ' + e.getLineNumber());
        }

//        objDataWrap.strStatus = strStatus;
//        objDataWrap.strMessage = strMessage;
//        return objDataWrap;
    }

    public class DataWrapper {
        public String strStatus { get; set; }
        public String strMessage { get; set; }
    }
}