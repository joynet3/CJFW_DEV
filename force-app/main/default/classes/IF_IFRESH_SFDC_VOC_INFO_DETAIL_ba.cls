/**
 * @description       : VOC 항목 Batch Class
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class IF_IFRESH_SFDC_VOC_INFO_DETAIL_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{

    global String transactionId;

    global IF_IFRESH_SFDC_VOC_INFO_DETAIL_ba(String transactionId) {
        this.transactionId = transactionId;
    }
    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : IF Dummy Object 레코드 조회
    ************************************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = '';
        strQuery += 'SELECT Id, transactionId__c, VOC_NO__c, VOC_DTL_NO__c, VOC_PRG_NM__c, VOC_PRG_CD__c, DLV_YMD__c,';
        strQuery += '       OCCR_YMD__c, MNGPLC_NM__c, MNGPLC_ID__c, GD_NO__c, GD_BD__c, MIGR_ORINAT_NM__c, ORDR_UNIT_CD__c,';
        strQuery += '       ORDR_QTY__c, DLV_QTY__c, VOC_UNIT_CD__c, VOC_QTY__c, RTN_NFXAT_BOX_QTY__c, SALE_PRC__c, VOC_LCLS_ID__c,';
        strQuery += '       VOC_MCLS_ID__c, VOC_DCLS_ID__c, RQRM_CD__c, PRS_TXT_CD__c, MENU_TXT__c, IMPT_DEPT_DIV_CD__c, CHG_RSN__c,';
        strQuery += '       BLNG_DEPT_DIV_CD__c, REAL_YN__c, NORM_YN__c, LGS_ACTN_RSLT_CD__c, DSTFD_DIV_CD__c, DSTR_TLMT_YMD__c,';
        strQuery += '       MNF_YMD__c, DSTR_HIS_NO__c, RTN_REQ_YMD__c, RTN_CFM_YMD__c, ORDR_NO__c, ORDR_DTL_NO__c, VOC_SCLS_ID__c,';
        strQuery += '       VOC_RSN_NO__c, REG_DT__c, REGR_ID__c, UPD_DT__c, UPDR_ID__c, SLST_NM__c, SLST_ID__c, LOTN_DTL_ADDR__c,';
        strQuery += '       SMA_EMP_HPNO__c, BRC_NM__c, BRC_ID__c, NUTR_EMP_NM__c, NUTR_EMP_ID__c, GEND_CD__c, AGE__c, MA_EMP_NM__c,';
        strQuery += '       MA_EMP_ID__c, NUTR_EMP_HPNO__c, CUST_REQR_NM__c, MA_EMP_HPNO__c, CRGR_DIV_CD__c, CUST_REQR_TEL_NO__c,';
        strQuery += '       SMA_EMP_NM__c, SMA_EMP_ID__c, SLF_PRS_YN__c, MNFCO_NM__c, MNF_NO__c, BCNR_NM__c, BCNR_ID__c, GD_NM__c,';
        strQuery += '       BCNR_VOC_TEL_NO__c, BCNR_STED_TXT__c, BCNR_VOC_CRGR_NM__c, IMPT_VGU_YN__c, MD_EMP_NM__c, MD_EMP_ID__c,';
        strQuery += '       GD_DIV_CD__c, MD_EMP_HPNO__c, VOC_DTL_TXT__c, img_file_url1__c, img_file_url2__c, img_file_url3__c,';
        strQuery += '       SHPTO_ADDR__c, MNGPLC_ADDR__c, SHPTO_ID__c, SHPTO_NM__c, LGS_CTR_ID__c';
        strQuery += '   FROM IF_IFRESH_SFDC_VOC_INFO_DETAIL__c';
        strQuery += '   WHERE transactionId__c = \'' + transactionId + '\'';
        strQuery += '   AND     IsUpdate__c = false' ;

        System.debug('start batch');
        return  Database.getQueryLocator(strQuery);
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : VOC 항목 upsert
    ************************************************************************************************************/
    global void execute(Database.BatchableContext bc, List<IF_IFRESH_SFDC_VOC_INFO_DETAIL__c> scope) {
        Id recordIdOwn = Schema.SObjectType.VOC__c.getRecordTypeInfosByDeveloperName().get('OwnCustomer').getRecordTypeId();
        Id recordIdEtc = Schema.SObjectType.VOC__c.getRecordTypeInfosByDeveloperName().get('Etc').getRecordTypeId();

        List<VOCLineItem__c> upsertVOCLineItemList = new List<VOCLineItem__c>();

        Set<String> setUpdateVOCNumber = new Set<String>();
        List<VOC__c> upsertVocList = new List<VOC__c>();
        Set<String> productCodeSet = new Set<String>();
        Set<String> vocNoSet = new Set<String>();

        // 2022-11-08 User 맵핑 추가
        Set<String> setUserEmployeeNumber = new Set<String>();
        // 2022-11-08 Account 맵핑 추가
        Set<String> setAccountNo = new Set<String>();

        for (IF_IFRESH_SFDC_VOC_INFO_DETAIL__c obj : scope) {

            if(obj.LGS_CTR_ID__c <> null && obj.GD_NO__c <> null) {
                String productCode = obj.LGS_CTR_ID__c+'_'+obj.GD_NO__c;
                productCodeSet.add(productCode);
            }

            vocNoSet.add(obj.VOC_NO__c);

            if(obj.slst_id__c <> null) {
                setAccountNo.add(obj.slst_id__c);
            }

            if(obj.ma_emp_id__c <> null) {
                setUserEmployeeNumber.add(obj.ma_emp_id__c);
            }

            if(obj.sma_emp_id__c <> null) {
                setUserEmployeeNumber.add(obj.sma_emp_id__c);
            }
        }

        Map<String, Id> mapUserId = new Map<String, Id>();

        for(User obj : [
            SELECT  Id, EmployeeNumber
            FROM    User
            WHERE   EmployeeNumber In:setUserEmployeeNumber
        ]) {
            mapUserId.put(obj.EmployeeNumber, obj.Id);
        }

        Map<String, Id> mapAccountId = new Map<String, Id>();
        Map<String, Id> mapAccParentId = new Map<String, Id>();

        for(Account obj : [
            SELECT  Id, CustomerID__c, ParentId
            FROM    Account
            WHERE   CustomerID__c In:setAccountNo
        ]) {
            mapAccountId.put(obj.CustomerID__c, obj.Id);

            if(obj.ParentId <> null) {
                mapAccParentId.put(obj.CustomerID__c, obj.ParentId);
            }
        }

        List<Product2> productCodeList = new List<Product2>();
        productCodeList = [
                            SELECT Id, ProductCode
                            FROM Product2
                            WHERE ProductCode IN:productCodeSet
                            ];
        Map<String, Id> productCodeMap = new Map<String, Id>();
        for (Product2 obj : productCodeList) {
            productCodeMap.put(obj.ProductCode, obj.Id);
        }

        List<VOC__C> vocList = new List<VOC__C>();
        vocList = [
                    SELECT Id, Name, VOCNumber__c, VOCOriginCode__C
                    FROM VOC__c
                    WHERE VOCNumber__c IN :vocNoSet
        ];

        Map<String, VOC__c> vocMap = new Map<String, VOC__c>();
        for (VOC__c obj : vocList) {
            vocMap.put(obj.Name, obj);
        }

        List<IF_IFRESH_SFDC_VOC_INFO_DETAIL__c> listUpdate = new List<IF_IFRESH_SFDC_VOC_INFO_DETAIL__c>();

        for (IF_IFRESH_SFDC_VOC_INFO_DETAIL__c objDummy : scope) {
            IF_IFRESH_SFDC_VOC_INFO_DETAIL__c objTarget = new IF_IFRESH_SFDC_VOC_INFO_DETAIL__c();
            objTarget.Id = objDummy.Id;

            VOCLineItem__c obj = new VOCLineItem__c();
            VOC__c vocObj = new VOC__c();
            vocobj = vocMap.get(objDummy.VOC_NO__c);
            // 2022-11-07 VOC__c가 존재하지 않는 건은 생성하지 않는다
            if(vocMap <> null && vocMap.get(objDummy.VOC_NO__c) <> null) {
                // vocMap.get(objDummy.VOC_NO__c) 데이터가 없는 경우 null error 발생하므로 위에서 처리
                System.debug('====================> vocMap.get(objDummy.VOC_NO__c).VOCOriginCode__c : '+vocMap.get(objDummy.VOC_NO__c).VOCOriginCode__c);
                if(vocMap.get(objDummy.VOC_NO__c).VOCOriginCode__c == '10') {
                    obj.VOC__c = vocMap.get(objDummy.VOC_NO__c).Id;
                    obj.ExtId__c = objDummy.VOC_NO__c+'_'+ objDummy.VOC_DTL_NO__c;
                    obj.VOCNumber__c = objDummy.VOC_NO__c;
                    obj.VOCLineItemNumber__c = objDummy.VOC_DTL_NO__c;
                    obj.VOCDetailNumber__c = objDummy.VOC_DTL_NO__c;
                    obj.Process__c = objDummy.VOC_PRG_CD__c;
                    if (objDummy.DLV_YMD__c <> '' && objDummy.DLV_YMD__c != null) {
                        Date dt = Date.newInstance(
                        Integer.valueOf(objDummy.DLV_YMD__c.substring(0,4))
                        ,Integer.valueOf(objDummy.DLV_YMD__c.substring(4,6))
                        ,Integer.valueOf(objDummy.DLV_YMD__c.substring(6,8))
                        );
                        obj.DeliveryDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }
                    if (objDummy.OCCR_YMD__c <> '' && objDummy.OCCR_YMD__c <> null) {
                        Date dt = Date.newInstance(
                        Integer.valueOf(objDummy.OCCR_YMD__c.substring(0,4))
                        ,Integer.valueOf(objDummy.OCCR_YMD__c.substring(4,6))
                        ,Integer.valueOf(objDummy.OCCR_YMD__c.substring(6,8))
                        );
                        obj.OccurrenceDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }

                    obj.ManagementWebsite__c = objDummy.MNGPLC_NM__c;
                    obj.ManagementWebsiteCode__c = objDummy.MNGPLC_ID__c;

                    if(objDummy.LGS_CTR_ID__c <> null && objDummy.GD_NO__c <> null) {
                        String productCode = objDummy.LGS_CTR_ID__c+'_'+objDummy.GD_NO__c;
                        obj.Product__c = productCodeMap.get(productCode);
                    }
                    
                    obj.ProductCode__c = objDummy.GD_NO__c;
                    obj.ProductName__c = objDummy.GD_BD__c;
                    obj.CountryofOrigin__c = objDummy.MIGR_ORINAT_NM__c;
                    obj.QuantityofMeasure__c = objDummy.ORDR_UNIT_CD__c;
                    obj.OrderQuantity__c =  objDummy.ORDR_QTY__c == null ? null : Decimal.valueOf(objDummy.ORDR_QTY__c);
                    obj.DeliveryQuantity__c =  objDummy.DLV_QTY__c == null ? null : Decimal.valueOf(objDummy.DLV_QTY__c);
                    obj.VOCUnit__c = objDummy.VOC_UNIT_CD__c;
                    obj.VOCQuantity__c =  objDummy.VOC_QTY__c == null ? null : Decimal.valueOf(objDummy.VOC_QTY__c);
                    obj.BoxVOCQuantity__c =  objDummy.RTN_NFXAT_BOX_QTY__c == null ? null : Decimal.valueOf(objDummy.RTN_NFXAT_BOX_QTY__c);
                    obj.SalePrice__c =  objDummy.SALE_PRC__c == null ? null : Decimal.valueOf(objDummy.SALE_PRC__c);
                    obj.VOCTypeLargeCode__c = objDummy.VOC_LCLS_ID__c;
                    obj.VOCTypeMediumCode__c = objDummy.VOC_MCLS_ID__c;
                    obj.VOCTypeSmallCode__c = objDummy.VOC_SCLS_ID__c;
                    obj.VOCTypeSubdivisionCode__c = objDummy.VOC_DCLS_ID__c;
                    obj.Requirement__c = objDummy.RQRM_CD__c;
                    obj.ActionResult__c = objDummy.PRS_TXT_CD__c;
                    obj.MenuInformation__c = objDummy.MENU_TXT__c;
                    obj.ResponsibleDepartment__c = objDummy.IMPT_DEPT_DIV_CD__c;
                    obj.ChangeReason__c = objDummy.CHG_RSN__c;
                    obj.AffiliatedDepartment__c = objDummy.BLNG_DEPT_DIV_CD__c;
                    obj.HasItem__c = objDummy.REAL_YN__c == 'Y' ? true : false;
                    obj.IsNormal__c = objDummy.NORM_YN__c == 'Y' ? true : false;
                    obj.LogisticsMeasureResults__c = objDummy.LGS_ACTN_RSLT_CD__c;
                    obj.BeforeAfterServing__c = objDummy.DSTFD_DIV_CD__c;
                    // obj.ExpireDate__c = objDummy.DSTR_TLMT_YMD__c;
                    // obj.ManufactureDate__c = objDummy.MNF_YMD__c;
                    if (objDummy.DSTR_TLMT_YMD__c <> '' && objDummy.DSTR_TLMT_YMD__c <> null) {
                        Date dt = Date.newInstance(
                            Integer.valueOf(objDummy.DSTR_TLMT_YMD__c.substring(0,4))
                            ,Integer.valueOf(objDummy.DSTR_TLMT_YMD__c.substring(4,6))
                            ,Integer.valueOf(objDummy.DSTR_TLMT_YMD__c.substring(6,8))
                        );
                        obj.ExpireDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }
                    if (objDummy.MNF_YMD__c <> '' && objDummy.MNF_YMD__c <> null) {
                        Date dt = Date.newInstance(
                            Integer.valueOf(objDummy.MNF_YMD__c.substring(0,4))
                            ,Integer.valueOf(objDummy.MNF_YMD__c.substring(4,6))
                            ,Integer.valueOf(objDummy.MNF_YMD__c.substring(6,8))
                        );
                        obj.ManufactureDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }
                    obj.DelliveryHistoryNumber__c = objDummy.DSTR_HIS_NO__c;
                    // obj.ReturnRequestDate__c = objDummy.RTN_REQ_YMD__c;
                    // obj.ReturnFixedDate__c = objDummy.RTN_CFM_YMD__c;
                    if (objDummy.RTN_REQ_YMD__c <> '' && objDummy.RTN_REQ_YMD__c <> null) {
                        Date dt = Date.newInstance(
                            Integer.valueOf(objDummy.RTN_REQ_YMD__c.substring(0,4))
                            ,Integer.valueOf(objDummy.RTN_REQ_YMD__c.substring(4,6))
                            ,Integer.valueOf(objDummy.RTN_REQ_YMD__c.substring(6,8))
                        );
                        obj.ReturnRequestDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }
                    if (objDummy.RTN_CFM_YMD__c <> '' && objDummy.RTN_CFM_YMD__c <> null) {
                        Date dt = Date.newInstance(
                            Integer.valueOf(objDummy.RTN_CFM_YMD__c.substring(0,4))
                            ,Integer.valueOf(objDummy.RTN_CFM_YMD__c.substring(4,6))
                            ,Integer.valueOf(objDummy.RTN_CFM_YMD__c.substring(6,8))
                        );
                        obj.ReturnFixedDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }
                    obj.OrderNumber__c = objDummy.ORDR_NO__c;
                    obj.OderDetailNumber__c = objDummy.ORDR_DTL_NO__c;                    
                    obj.VOCReasonCode__c = objDummy.VOC_RSN_NO__c;
                    obj.VOCDetails__c = objDummy.VOC_DTL_TXT__c;
                    obj.reg_dt__c = Datetime.valueOf(objDummy.reg_dt__c.replace('T', ' '));
                    obj.reg_id__c = objDummy.REGR_ID__c;
                    obj.upd_dt__c = Datetime.valueOf(objDummy.upd_dt__c.replace('T', ' '));
                    obj.updr_id__c = objDummy.UPDR_ID__c;
                    obj.img_file_url1__c = objDummy.img_file_url1__c;
                    obj.img_file_url2__c = objDummy.img_file_url2__c;
                    obj.img_file_url3__c = objDummy.img_file_url3__c;

                    // 자사고객인경우 VOC : VOClineItem = 1 : N 관계이므로 VOC__c는 하나만 업데이트
                    if(!setUpdateVOCNumber.contains(objDummy.VOC_NO__c)) {
                        // 2022-11-07 RecordTypeId 세팅 추가
                        vocObj.RecordTypeId = recordIdOwn;

                        vocObj.VOCTypeLargeCode__c = objDummy.VOC_LCLS_ID__c;
                        vocObj.VOCTypeMediumCode__c = objDummy.VOC_MCLS_ID__c;
                        vocObj.VOCTypeSmallCode__c = objDummy.voc_scls_id__c;
                        vocObj.VOCTypeSubdivisionCode__c = objDummy.VOC_DCLS_ID__c;
                        // 2022-11-20 Detail 필드인데 자사고객 같은 경우 1:N 관계.. 한번에 처리를 하는것인지 확인필요
                        vocObj.Process__c = objDummy.voc_prg_cd__c;
                        
                        // 2022-11-08 VOC Account 연결 추가
                        vocObj.VendorStore__c = mapAccountId.get(objDummy.slst_id__c);
                        vocObj.VendorStoreName__c = objDummy.slst_nm__c;                    
                        vocObj.VendorStoreCode__c = objDummy.slst_id__c;

                        vocObj.TeamBranch__c = objDummy.brc_nm__c;
                        vocObj.TeamBranchCode__c = objDummy.brc_id__c;
                        vocObj.SalesAddress__c = objDummy.shpto_addr__c;

                        vocObj.ManagementWebsite__c = objDummy.MNGPLC_NM__c;
                        vocObj.ManagementWebsiteCode__c = objDummy.MNGPLC_ID__c;
                        vocObj.ManagementAddress__c = objDummy.mngplc_addr__c;

                        vocObj.MAMobilePhone__c = objDummy.MA_EMP_HPNO__c;
                        vocObj.MAName__c = objDummy.ma_emp_nm__c;
                        vocObj.MACode__c = objDummy.ma_emp_id__c;
                        vocObj.MA__c = mapUserId.get(objDummy.ma_emp_id__c);

                        if (objDummy.slst_id__c <> null && mapAccParentId.get(objDummy.slst_id__c) <> null) {
                            vocObj.slst_master_id__c = mapAccParentId.get(objDummy.slst_id__c);
                        }
                        //vocObj.IMAGE1__c = objDummy.IMG_FILE_ID__c;

                        upsertVocList.add(vocObj);
                        setUpdateVOCNumber.add(objDummy.VOC_NO__c);
                    }
                    
                    upsertVOCLineItemList.add(obj);
                    
                }else {
                    // 2022-11-07 RecordTypeId 세팅 추가
                    vocObj.RecordTypeId = recordIdEtc;
    
                    vocObj.VOCNumber__c = objDummy.voc_no__c;                    
                    vocObj.Process__c = objDummy.voc_prg_cd__c;

                    if (objDummy.DLV_YMD__c <> '' && objDummy.DLV_YMD__c != null) {
                        Date dt = Date.newInstance(
                            Integer.valueOf(objDummy.DLV_YMD__c.substring(0,4))
                            ,Integer.valueOf(objDummy.DLV_YMD__c.substring(4,6))
                            ,Integer.valueOf(objDummy.DLV_YMD__c.substring(6,8))
                        );
                        vocObj.DeliveryDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }

                    if (objDummy.OCCR_YMD__c <> '' && objDummy.OCCR_YMD__c <> null) {
                        Date dt = Date.newInstance(
                            Integer.valueOf(objDummy.OCCR_YMD__c.substring(0,4))
                            ,Integer.valueOf(objDummy.OCCR_YMD__c.substring(4,6))
                            ,Integer.valueOf(objDummy.OCCR_YMD__c.substring(6,8))
                        );
                        vocObj.OccurrenceDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }
    
                    vocObj.ManagementWebsite__c = objDummy.mngplc_nm__c;
                    vocObj.ManagementWebsiteCode__c = objDummy.mngplc_id__c;
                    vocobj.Product__c = productCodeMap.get(objDummy.GD_NO__c);
                    vocObj.ProductCode__c = objDummy.gd_no__c;
                    vocObj.ProductName__c = objDummy.gd_bd__c;
                    vocobj.DeliveryQuantity__c = objDummy.DLV_QTY__c == null ? null : Integer.valueOf(objDummy.DLV_QTY__c);
                    vocObj.VOCUnit__c = objDummy.voc_unit_cd__c;
                    vocobj.VOCQuantity__c = objDummy.VOC_QTY__c == null ? null : Integer.valueOf(objDummy.VOC_QTY__c);
                    vocObj.VOCTypeSubdivisionCode__c = objDummy.voc_dcls_id__c;
                    vocObj.Requirement__c = objDummy.rqrm_cd__c;
                    vocObj.ActionResult__c = objDummy.prs_txt_cd__c;
                    vocObj.MenuInformation__c = objDummy.menu_txt__c;
                    vocObj.ResponsibleDepartment__c = objDummy.impt_dept_div_cd__c;
                    vocObj.AffiliatedDepartment__c = objDummy.blng_dept_div_cd__c;
                    vocObj.HasItem__c = objDummy.real_yn__c == 'Y' ? true : false;
                    vocObj.IsNormal__c = objDummy.norm_yn__c == 'Y' ? true : false;
                    vocObj.BeforeAfterServing__c = objDummy.DSTFD_DIV_CD__c;

                    if (objDummy.DSTR_TLMT_YMD__c <> '' && objDummy.DSTR_TLMT_YMD__c <> null) {
                        Date dt = Date.newInstance(
                            Integer.valueOf(objDummy.DSTR_TLMT_YMD__c.substring(0,4))
                            ,Integer.valueOf(objDummy.DSTR_TLMT_YMD__c.substring(4,6))
                            ,Integer.valueOf(objDummy.DSTR_TLMT_YMD__c.substring(6,8))
                        );
                        vocObj.ExpireDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }
                    if (objDummy.MNF_YMD__c <> '' && objDummy.MNF_YMD__c <> null) {
                        Date dt = Date.newInstance(
                            Integer.valueOf(objDummy.MNF_YMD__c.substring(0,4))
                            ,Integer.valueOf(objDummy.MNF_YMD__c.substring(4,6))
                            ,Integer.valueOf(objDummy.MNF_YMD__c.substring(6,8))
                        );
                        vocObj.ManufactureDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                    }

                    vocObj.VOCTypeLargeCode__c = objDummy.VOC_LCLS_ID__c;
                    vocObj.VOCTypeMediumCode__c = objDummy.VOC_MCLS_ID__c;
                    vocObj.VOCTypeSubdivisionCode__c = objDummy.VOC_DCLS_ID__c;
                    vocObj.VOCTypeSmallCode__c = objDummy.voc_scls_id__c;
                    
                    vocObj.VendorStore__c = mapAccountId.get(objDummy.slst_id__c);
                    vocObj.VendorStoreName__c = objDummy.slst_nm__c;
                    vocObj.VendorStoreCode__c = objDummy.slst_id__c;
                    vocObj.CustomerAddress__c = objDummy.lotn_dtl_addr__c;
                    vocObj.SMAPhone__c = objDummy.sma_emp_hpno__c;
                    vocObj.TeamBranch__c = objDummy.brc_nm__c;
                    vocObj.TeamBranchCode__c = objDummy.brc_id__c;
                    vocObj.MAStoreManagerName__c = objDummy.nutr_emp_nm__c;
                    vocObj.MAStoreManagerCode__c = objDummy.nutr_emp_id__c;
                    vocObj.CustomerGenderCode__c = objDummy.gend_cd__c;
                    vocObj.CustomerAge__c = objDummy.age__c == null ? null : Integer.valueOf(objDummy.age__c);
                    vocObj.MAName__c = objDummy.ma_emp_nm__c;
                    vocObj.MACode__c = objDummy.ma_emp_id__c;
                    vocObj.MA__c = mapUserId.get(objDummy.ma_emp_id__c);
                    vocObj.MAStoreManagerHP__c = objDummy.nutr_emp_hpno__c;
                    
                    // 2022-11-09 RequesterName__c -> CustRequesterName__c 변경
                    vocObj.CustRequesterName__c = objDummy.cust_reqr_nm__c;
                    vocObj.MAMobilePhone__c = objDummy.ma_emp_hpno__c;
                    vocObj.ManagerCategoryCode__c = objDummy.crgr_div_cd__c;
                    vocObj.CustomerPhone__c = objDummy.cust_reqr_tel_no__c;
                    vocObj.SMAName__c = objDummy.sma_emp_nm__c;
                    vocObj.SMACode__c = objDummy.sma_emp_id__c;
                    vocObj.SMA__c = mapUserId.get(objDummy.sma_emp_id__c);
                    vocObj.SelfProcessingCode__c = objDummy.slf_prs_yn__c;
                    vocObj.ManufactureName__c = objDummy.mnfco_nm__c;
                    vocObj.ManufactureNumberLOT__c = objDummy.mnf_no__c;
                    vocObj.PartnerName__c = objDummy.BCNR_NM__c;
                    vocObj.PartnerCode__c = objDummy.bcnr_id__c;
                    vocObj.ProductName__c = objDummy.gd_nm__c;
                    vocObj.PartnerPhone__c = objDummy.bcnr_voc_tel_no__c;
                    vocObj.PartnerAddress__c = objDummy.bcnr_sted_txt__c;
                    vocObj.PartnerManagerName__c = objDummy.bcnr_voc_crgr_nm__c;
                    vocObj.RequestforJudgment__c = objDummy.impt_vgu_yn__c == 'Y' ? true : false;
                    vocObj.MDName__c = objDummy.md_emp_nm__c;
                    vocObj.MDCode__c = objDummy.md_emp_id__c;
                    vocObj.ProductCategoryCode__c = objDummy.gd_div_cd__c;
                    vocObj.MDPhone__c = objDummy.md_emp_hpno__c;
                    vocObj.Description__c = objDummy.voc_dtl_txt__c;
                    //vocObj.IMAGE1__c = objDummy.img_file_id__c;
                    vocObj.img_file_url1__c = objDummy.img_file_url1__c;
                    vocObj.img_file_url2__c = objDummy.img_file_url2__c;
                    vocObj.img_file_url3__c = objDummy.img_file_url3__c;

                    if(objDummy.slst_id__c <> null && mapAccParentId.get(objDummy.slst_id__c) <> null) {
                        vocObj.slst_master_id__c = mapAccParentId.get(objDummy.slst_id__c);
                    }
                    upsertVocList.add(vocObj);
                }
            }else {                
                objTarget.IsNotVOC__c = true;
                System.debug('==================>  vocMap 없음');
                System.debug('==================>  objDummy.VOC_NO__c : '+objDummy.VOC_NO__c);
            }

            objTarget.IsUpdate__c = true;
            listUpdate.add(objTarget);                
        }

        Savepoint sp = Database.setSavepoint();

        if(upsertVOCLineItemList <> null && upsertVOCLineItemList.size() > 0) {
            upsert upsertVOCLineItemList ExtId__c;
        }

        if(upsertVocList <> null && upsertVocList.size() > 0) {
            upsert upsertVocList VOCNumber__c;
        }

        if(listUpdate <> null && listUpdate.size() > 0) {
            update listUpdate;
        }

        /*
        try {
            if(upsertVOCLineItemList <> null && upsertVOCLineItemList.size() > 0) {
                upsert upsertVOCLineItemList ExtId__c;
            }

            System.debug('========================> upsertVocList : '+JSON.stringify(upsertVocList));


            if(upsertVocList <> null && upsertVocList.size() > 0) {
                upsert upsertVocList VOCNumber__c;
            }
        }catch(Exception e) {
            Database.rollback(sp);

            System.debug('=============================> Error Line '+e.getLineNumber());
            System.debug('=============================> Error '+e.getMessage());
        }
        */
    }
    /***********************************************************************************************************
    *  Bacth   : finish
    *  내용    : VOC 조치이력 Batch Class 실행
    ************************************************************************************************************/
    global void finish(Database.BatchableContext BC) {
        IF_IFRESH_SFDC_VOC_INFO_COMMENT_ba ba = new IF_IFRESH_SFDC_VOC_INFO_COMMENT_ba(this.transactionId);
        Database.executeBatch(ba, 200);
    }
}