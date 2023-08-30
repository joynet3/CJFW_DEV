/**
 * @Class : IFN_LIF1002_SE001_Callout.cls
 * @group Framework : 
 * @Author : 조일근
 * @Date : 2023-08-24
 * @Version : 1.0
 * @Description : 검색엔진 서비스 callout
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.24 | 조일근 | 최초작성
 * */
public class IFN_LIF1002_SE001_Callout {

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;

    public IFN_LIF1002_SE001_Callout(){
        this.commlog = new IFN_CommonLog();
    }

    public IFN_LIF1002_SE001_Callout(String interfaceId, String type){
        this.commlog         = new IFN_CommonLog();
        this.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }




    public IFN_CalloutResult getResponse(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        
        try {
            switch on interfaceId {
                //----- 테스트 IF
                when 'IFN_LIF1002_SE001_MD001'{ 
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IFN_LIF1002_SE001_MD001(interfaceId, params);
                }
                
            }
        } catch(Exception e) {
            result.setResult('E' , e.getMessage() , null); 
        } //end of try~catch


        return result;

    }

    


    /**
     * 상품 조회(order_product)
     * @param interfaceId IFN_LIF1002_SE001_MD001
     * @param params (searchSp 로 검색 구분함. 검색 종류에 따라 파라메터가 조금씩 상이함 아래 예제 참조)
     * @return  
     * 1.상품 조회 count
     * @request Sample
        {
        "searchSp":"01",
        "keywd":"우유",
        }
     * @response Sample
       {
            "total": 649,
            "search": [],
            "code": ""
        }
     * 2.상품 조회 리스트
     * @request Sample
        {
        "searchSp":"02",
        "keywd":"우유",
        "limitCnt" : "10",
        "offset" : "1"
        }
     * @response Sample
        {
            "total": 649,
            "search": [
                {
                    "upd_dt": "2021-11-18T01:58:12.000Z",
                    "sale_unit_cd": "EA",
                    "co_id": "FW00",
                    "migr_orinat_cd_nm": "한국",
                    "gd_cls_id3": "600401",
                    "migr_orinat_cd": "KR",
                    "gd_cls_id2": "6004",
                    "gd_cls_id4": "60040101",
                    "gd_cls_nm3": "유제품류",
                    "gd_cls_nm2": "음료류",
                    "gd_cls_id1": "60",
                    "gd_cls_nm4": "우유",
                    "gd_cls_nm1": "매점상품",
                    "taxt_cl_cd": "0",
                    "gd_cls_id": "60040101",
                    "gd_no": "800865",
                    "brd_nm": null,
                    "id": "FW00-800865",
                    "gd_bd": "서울우유 흰우유(200g/EA)",
                    "gd_bd_kw": "서울우유 흰우유(200g/EA)",
                    "taxt_cl_cd_nm": "면세"
                }
            ]
        }
        3. 상품검색어 자동 완성
     * @request Sample
        {
        "searchSp":"03",
        "keywd":"우유"
        }
     * @response Sample
     * {
          "total": 16,
          "search": [
              {
                  "gd_bd": "우유크림빵(오가다용 140g*6입 840g/EA)",
                  "gd_bd_kw": "우유크림빵(오가다용 140g*6입 840g/EA)"
              },
              {
                  "gd_bd": "우유듬뿍믹스(오가다용 3kg*2입 6Kg/BOX)",
                  "gd_bd_kw": "우유듬뿍믹스(오가다용 3kg*2입 6Kg/BOX)"
              }
          ]
        }
       4. 상품대분류
     * @request Sample
        {
        "searchSp":"04",
        "keywd":"계란",
        "limitCnt":"30"
        }
     * @response Sample
     * {
            "total": 294,
            "search": [
                {
                    "gd_cls_nm1": "축산물"
                },
                {
                    "gd_cls_nm1": "가공식품"
                },
                {
                    "gd_cls_nm1": "매점상품"
                },
                {
                    "gd_cls_nm1": "CK제품"
                },
                {
                    "gd_cls_nm1": "비식품"
                },
                {
                    "gd_cls_nm1": "농산물"
                }
            ],
            "code": ""
       }
       5. 상품브랜드
     * @request Sample
        {
        "searchSp":"04",
        "keywd":"계란",
        "limitCnt":"3"
        }
     * @response Sample       
        {
            "total": 294,
            "search": [
                {
                    "co_id": "FW00",
                    "brd_nm": "푸른계란"
                },
                {
                    "co_id": "FW00"
                },
                {
                    "co_id": "FW00",
                    "brd_nm": "이츠웰"
                }
            ],
            "code": ""
        }
     */
    public IFN_CalloutResult IFN_LIF1002_SE001_MD001(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = '';
        
        SE001_01ResultWrapper infResponse = new SE001_01ResultWrapper();  
        

        try{


            Date dateToday = Date.today();
    
            this.logWrap.RequestTime = Datetime.now();

            this.logWrap.LogText.add(Json.serialize(params));

            SE001RequstWrapper reqparam = new SE001RequstWrapper();
            reqparam = (SE001RequstWrapper)params;

            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            String requestBody = JSON.serialize(reqparam);
            this.logWrap.RequestBody = requestBody;

            HttpResponse response = gateway.webCallout(requestBody,null, true);

            if(response.getStatusCode() == 200) {

                responsedata = response.getBody();
                infResponse =  (SE001_01ResultWrapper)JSON.deserializeStrict((String)responsedata, SE001_01ResultWrapper.class);
                this.logWrap.LogText.add(JSON.serialize(infResponse.search));
                this.logWrap.ResponseBody = (String)responsedata;
                this.logWrap.ResponseTime = Datetime.now();
            } else {
                result_code = 'F';
                result_message = 'Interface Error';
                responsedata = '';
                this.logWrap.LogText.add(response.getStatus());
                this.logWrap.ErrorText.add(response.getStatus());
            }

        } catch(Exception e) {
            
            this.logWrap.LogText.add(e.getMessage() + '/' + e.getLineNumber());
            this.logWrap.ErrorText.add(e.getMessage() + '/' + e.getLineNumber());

            result_code = 'F';
            result_message = 'Interface Error';
        }  

        this.logWrap.Status = result_code;
        this.logWrap.ErrorCode = 'S'.equals(result_code) ? 'Success' : 'error';
        if('F'.equals(result_code))  this.logWrap.ErrorText.add(result_message);

        commlog.insertLog(this.logWrap);
        
        
        result.setResult(
            result_code
            , result_message
            , infResponse
        );

        return result;
    }
    

    /**
     * ==================================== 
     * 검색엔진 조회 요청 Wrapper
     * =================================
     */
    /**
     * 요청 파라메터 
     */
    public class SE001RequstWrapper{
        public String searchSp {get;set;}
        public String keywd    {get;set;}
        public String limitCnt    {get;set;}
        public String offset   {get;set;}
    }


    /** 
     * 조회 결과 
     */
    public class SE001_01ResultWrapper {
        public String total;
        public List<SearchLst> search;
        public String code;
        public String err_cd;
        public String err_msg_ctt;
        
    }

    /** 
     * 조회 결과 
     */
    public class SearchLst {
        public String upd_dt {get;set;}
        public String sale_unit_cd {get;set;}
        public String co_id {get;set;}
        public String brd_nm {get;set;}        
        public String migr_orinat_cd_nm {get;set;}
        public String gd_cls_id3 {get;set;}
        public String migr_orinat_cd {get;set;}
        public String gd_cls_id2 {get;set;}
        public String gd_cls_id4 {get;set;}
        public String gd_cls_nm3 {get;set;}
        public String gd_cls_nm2 {get;set;}
        public String gd_cls_id1 {get;set;}
        public String gd_cls_nm4 {get;set;}
        public String gd_cls_nm1 {get;set;}
        public String taxt_cl_cd {get;set;}
        public String gd_cls_id {get;set;}
        public String gd_no {get;set;}
        public String id {get;set;}
        public String gd_bd {get;set;}
        public String gd_bd_kw {get;set;}
        public String taxt_cl_cd_nm {get;set;}
                
    }    


}