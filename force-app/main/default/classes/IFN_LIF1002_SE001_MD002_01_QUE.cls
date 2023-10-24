/**
 * @Class : IFN_LIF1002_SE001_MD002_01_QUE.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.10.24
 * @Version : 1.0
 * @Description : 검색엔진을 통한 상품 대분류 카테고리 검색 저장
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.10.24 | 조일근  | 최초작성
 * */
global class IFN_LIF1002_SE001_MD002_01_QUE  implements Queueable , Database.AllowsCallouts{
    
    global Object param;
    public IFN_CommonLog commlog;
    public IFN_CommonLog.LogWrap logWrap{get;set;}
    global List<IFN_CommonLog.LogWrap> logWrapList;


    global String searchSp;
    
    
    global String  interfaceId = 'IFN_LIF1002_SE001_MD002_01';


    global IFN_LIF1002_SE001_MD002_01_QUE() {

        this.commlog     = new IFN_CommonLog();
        this.logWrap     = new IFN_CommonLog.logWrap(this.interfaceId, 'Batch');
        this.logWrapList = new List<IFN_CommonLog.logWrap>();
        this.searchSp = '11';
    }
    
    
    global IFN_LIF1002_SE001_MD002_01_QUE(String searchSp) {

        this.commlog     = new IFN_CommonLog();
        this.logWrap     = new IFN_CommonLog.logWrap(this.interfaceId, 'Batch');
        this.logWrapList = new List<IFN_CommonLog.logWrap>();
        this.searchSp = searchSp;
    }

        

    global void execute(QueueableContext sc) {
        Boolean isSchedule = true;
        this.logWrap.BatchCronId = sc.getJobId();
        try {
            
            IFN_LIF1002_SE001_MD001.SE001RequstWrapper params = new IFN_LIF1002_SE001_MD001.SE001RequstWrapper();
            params.searchSp = this.searchSp;
            params.keywd = '';
            params.keywd_sp = '';
            params.order = '';
            params.order_mt = '';
            params.page = '';
            params.pageSize = '';


            IFN_LIF1002_SE001_MD001.SE001_01ResultWrapper result = new IFN_LIF1002_SE001_MD001.SE001_01ResultWrapper();

            Map<String,String> prodCate_01_map = new Map<String,String>();
            Map<String,String> prodCate_02_map = new Map<String,String>();
            Map<String,String> prodCate_03_map = new Map<String,String>();

            List<ProductCategory__c> prodCate_01_Lst = [select id, gd_cls_id__c from ProductCategory__c where gd_cls_lvl_dpt__c ='1'];
            for (ProductCategory__c itm : prodCate_01_Lst) {
                prodCate_01_map.put(itm.gd_cls_id__c, itm.id);
            }


            List<ProductCategory__c> prodCate_02_Lst = [select id, gd_cls_id__c from ProductCategory__c where gd_cls_lvl_dpt__c ='2'];
            for (ProductCategory__c itm : prodCate_02_Lst) {
                prodCate_02_map.put(itm.gd_cls_id__c, itm.id);
            }

            List<ProductCategory__c> prodCate_03_Lst = [select id, gd_cls_id__c from ProductCategory__c where gd_cls_lvl_dpt__c ='3'];
            for (ProductCategory__c itm : prodCate_03_Lst) {
                prodCate_03_map.put(itm.gd_cls_id__c, itm.id);
            }            



            IFN_LIF1002_Callout callout = new IFN_LIF1002_Callout('IFN_LIF1002_SE001_MD001', 'Real');
            IFN_CalloutResult calloutRes = callout.getResponse('IFN_LIF1002_SE001_MD001', Json.serialize(params));

            result = (IFN_LIF1002_SE001_MD001.SE001_01ResultWrapper)calloutRes.response;
            this.logWrap.LogText.add('=========== full res  ==================');
            this.logWrap.LogText.add(Json.serialize(result));

            if('S'.equals(calloutRes.result) && result !=null) {

                List<IFN_LIF1002_SE001_MD001.SearchLst> searchLst = new List<IFN_LIF1002_SE001_MD001.SearchLst>();
                searchLst = result.search;
                List<ProductCategory__c> upsertData = new List<ProductCategory__c>();
                if(searchLst !=null && searchLst.size() > 0 ) {
                    for(IFN_LIF1002_SE001_MD001.SearchLst itm : searchLst) {

                        ProductCategory__c idata = convertData(itm, this.searchSp , prodCate_01_map, prodCate_02_map, prodCate_03_map);
                        if(idata !=null) upsertData.add(idata);
                    }
                    if(upsertData.size()>0) upsert upsertData gd_cls_id__c;
                }
                this.logWrap.LogText.add('=========== search list ==================');
                this.logWrap.LogText.add(Json.serialize(searchLst));
            } else {
                this.logWrap.LogText.add('인터페이스 에러' + result.err_msg_ctt);
            }

        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString()); 
            this.logWrap.Status = 'ERROR';
        }

        commlog.insertLog(this.logWrap);

        if(!'14'.equals(this.searchSp) && !Test.isRunningTest()) {
            if('11'.equals(this.searchSp)) System.enqueueJob(new IFN_LIF1002_SE001_MD002_01_QUE('12'));
            if('12'.equals(this.searchSp)) System.enqueueJob(new IFN_LIF1002_SE001_MD002_01_QUE('13'));
            if('13'.equals(this.searchSp)) System.enqueueJob(new IFN_LIF1002_SE001_MD002_01_QUE('14'));            
        }
        
        //다음 스케줄 체크
        String currentClassName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));        
        if(isSchedule) IFN_Util.NextScheduleCheck(currentClassName);
        
    } //end of execute()


    static ProductCategory__c convertData(IFN_LIF1002_SE001_MD001.SearchLst param, String searchSp , Map<String,String> pMap01, Map<String,String> pMap02, Map<String,String> pMap03){
        ProductCategory__c r = new ProductCategory__c();
        r.Name = param.gd_cls_nm;
        r.gd_cls_id__c = param.gd_cls_id;                
        r.gd_cls_nm__c = param.gd_cls_nm;
        r.co_id__c = 'FW00';

        
        r.gd_cls_lvl_dpt__c = '11'.equals(searchSp) ? '1' : ('12'.equals(searchSp) ? '2' : ('13'.equals(searchSp) ? '3': ('14'.equals(searchSp) ? '4': '')));


        if(!'11'.equals(searchSp)) {
             //상위코드 
            if('12'.equals(searchSp))  {
                r.upp_gd_cls_id__c = param.gd_cls_id1;
                r.ProductCategory__c = pMap01.get(param.gd_cls_id1) == null? null : pMap01.get(param.gd_cls_id1) ; // 상위코드 id
            }
            if('13'.equals(searchSp))  {
                r.upp_gd_cls_id__c = param.gd_cls_id2;
                r.ProductCategory__c = pMap02.get(param.gd_cls_id2) == null? null : pMap02.get(param.gd_cls_id2) ; // 상위코드 id
            }
            if('14'.equals(searchSp))  {
                r.upp_gd_cls_id__c = param.gd_cls_id3;
                r.ProductCategory__c = pMap03.get(param.gd_cls_id3) == null? null : pMap03.get(param.gd_cls_id3) ; // 상위코드 id
            }
            
        }
        r.IsActive__c = true;
        return r;        
    } //end of convertCrmToApis()
}