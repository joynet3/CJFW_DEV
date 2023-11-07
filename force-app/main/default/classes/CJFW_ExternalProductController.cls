/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-06-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
public with sharing class CJFW_ExternalProductController {

    @AuraEnabled
    public static List<Product2> getIFData(List<String> codeList){
        try {
            System.debug('codeList : '+ codeList);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return null;
    }

    @AuraEnabled
    public static List<Product2> doSearch(Map<String, Object> mapParam) {
        System.debug('# CJFW_ExternalProductController # doSearch ');
        
        Set<String> productCodeSet;
        if(mapParam.get('productCodeSet') != null) productCodeSet = (Set<String>) JSON.deserialize(JSON.serialize(mapParam.get('productCodeSet')), Set<String>.class);
        
        System.debug(' productCodeSet ->'+ productCodeSet );

        List<Product2> productList = [ SELECT Id
                                            ,   Name 
                                            ,   gd_no__c 
                                            ,   gd_nm__c 
                                            ,   lgs_ctr__c 
                                            ,   lgl_dstr_tlmt_end_ymd__c 
                                            ,   mnfco_oriplc_cd__c 
                                            ,   bas_unit_cd__c
                                            ,   avg_wt__c
                                            ,   box_ctcnt_qty__c 
                                            ,   taxt_cl_cd__c //dlv_req_ymd 필드 없음
                                   FROM Product2
                                   WHERE  gd_no__c IN : productCodeSet
                                   AND lgs_ctr__c = '2170' ];

        System.debug('===== productList =====');
        System.debug(productList);

        // Map<String, Object> mapProductData = new Map<String, Object>{           
        //     'listSearchEntry' => productList
        // };

        // System.debug('mapProductData' + mapProductData);

        return productList;

    }
    
    @AuraEnabled
    public static Map<String,Object> doSendSearchEngine(Map<String,Object> params){
        try {
            Map<String,Object> result = new Map<String,Object>();
            result.put('params', params);
            String keyword = (String) params.get('keyword');
            String pageSize = (String) params.get('pageSize');
            String orderCriterion = 'asc';
            if(params.get('orderCriterion') != null) orderCriterion = (String) params.get('orderCriterion');
            String page = '1';
            if(params.get('page') != null) page = (String) params.get('page');

            IFN_LIF1002_SE001_MD001.SE001RequstWrapper ifParams = new IFN_LIF1002_SE001_MD001.SE001RequstWrapper();
            result.put('ifParams', ifParams);
            IFN_LIF1002_SE001_MD001 cont = new IFN_LIF1002_SE001_MD001();

            String interfaceId = 'IFN_LIF1002_SE001_MD001';
            ifParams.searchSp = '02'; // 02 : 상품조회
            
            ifParams.keywd      = keyword;
            ifParams.page       = page;       // 페이지
            ifParams.pageSize   = pageSize; // 페이지별 리스트 갯수
            ifParams.order      = 'gd_bd_kw'; // gd_bd_kw : 상품명 정렬, brd_nm : 브랜드명 정렬 , reg_dt : 등록일 정렬
            ifParams.order_mt   = orderCriterion; // asc , desc 

            // System.debug(
            //     JSON.serializePretty(ifParams)
            // );

            Set<String> productCodeSet = new Set<String>();

            IFN_LIF1002_SE001_MD001.SE001_01ResultWrapper res = cont.callout(ifParams);
            System.debug(
                JSON.serializePretty(res)
            );
            if(!'9999'.equals(res.err_cd)) {
                result.put('totalSize', res.total);
                for(IFN_LIF1002_SE001_MD001.SearchLst searchDatum : res.search) {
                    productCodeSet.add(searchDatum.gd_no);
                }
            }

            result.put('productCodeSet', productCodeSet);

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

}