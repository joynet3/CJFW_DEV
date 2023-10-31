/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-30-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
public with sharing class CJFW_ExternalProductController {
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