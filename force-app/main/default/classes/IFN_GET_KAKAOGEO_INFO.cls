/**
 * @Class : IFN_GET_KAKAOGEO_INFO.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.11.13
 * @Version : 1.0
 * @Description : kakaomap 이용 주소로 geocode 정보 가져오기
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.13 | 조일근  | 최초작성
 * */
public class IFN_GET_KAKAOGEO_INFO {

    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;

    public String interfaceId = 'IFN_COMMMON_KAKAO_GEOINFO';
    

    public IFN_CalloutResult getResponse(String fineAddr){

        IFN_CalloutResult result = new IFN_CalloutResult();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();


        String responsedata = '';
        String result_code = 'S';
        String result_message = '';
        IFN_GET_KAKAOGEO_INFO.SearcXY xyData = new IFN_GET_KAKAOGEO_INFO.SearcXY();

        IFN_CMM_ERRUTIL.ErrorValueWrapper errWr = new IFN_CMM_ERRUTIL.ErrorValueWrapper();

        try{



            IFN_GET_KAKAOGEO_INFO.SearcData infResponse = new IFN_GET_KAKAOGEO_INFO.SearcData();  

            Date dateToday = Date.today();    
            this.logWrap.RequestTime = Datetime.now();
            
            
            IFN_ApiGateWay gateway = new IFN_ApiGateWay(this.interfaceId);
            String requestQuery = 'query='+EncodingUtil.urlEncode(fineAddr, 'UTF-8');

            this.logWrap.LogText.add('requestQuery>>>>> ' + requestQuery);            
            
            HttpResponse response = gateway.webCallout(requestQuery,null, true);
            if(response.getStatusCode() == 200) {

                responsedata = response.getBody();
                infResponse =  (IFN_GET_KAKAOGEO_INFO.SearcData)JSON.deserializeStrict((String)responsedata, IFN_GET_KAKAOGEO_INFO.SearcData.class);

                xyData.XPoint =  infResponse.documents[0].x;
                xyData.YPoint =  infResponse.documents[0].y;

                this.logWrap.LogText.add('xyData >>>>>>> ' + JSON.serialize(xyData));                


                this.logWrap.ResponseBody = (String)responsedata;
                this.logWrap.ResponseTime = Datetime.now();
            } else {

                List<String> errMsgLst = new List<String>{String.valueOf(response.getStatus())};
                errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY_FORMAT('COMMON', IFN_CMM_ERRUTIL.ERRKEY_INTERFACE_STATUS_ERROR,errMsgLst);
                result_code =  errWr.err_code;
                result_message =  errWr.err_msg;
                
                responsedata = '';
                this.logWrap.LogText.add(response.getStatus());
                this.logWrap.ErrorText.add(response.getStatus());
            }


        } catch(Exception e) {
                
            this.logWrap.LogText.add(e.getMessage() + '/' + e.getLineNumber());
            this.logWrap.ErrorText.add(e.getMessage() + '/' + e.getLineNumber());

            List<String> errMsgLst = new List<String>{String.valueOf(e.getMessage())};
            errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY_FORMAT('COMMON', IFN_CMM_ERRUTIL.ERRKEY_INTERFACE_STATUS_ERROR,errMsgLst);
            result_code =  errWr.err_code;
            result_message =  errWr.err_msg;

        }  


        this.logWrap.Status = result_code;
        this.logWrap.ErrorCode = 'S'.equals(result_code) ? 'Success' : 'error';
        if('F'.equals(result_code))  this.logWrap.ErrorText.add(result_message);

        commlog.insertLog(this.logWrap);
        
        
        result.setResult(
            result_code
            , result_message
            , xyData
        );

        return result;
        
    }


    
    /** ===========================================================
     * 조회 결과  ===============================================
     ============================================================= */



     public class SearcXY {
        public String XPoint {get;set;}
        public String YPoint {get;set;}

     }
     
     
     public class SearcData {
        public List<SearcDoc> documents{get;set;}
        public SearcMeta meta{get;set;}
        public String errorType {get;set;}
        public String message {get;set;}

     }

     public class SearcMeta {
        public String is_end{get;set;}
        public String pageable_count{get;set;}
        public String total_count{get;set;}
     }
     
     
     public class SearcDoc {
        public SearcAddr address{get;set;}
        public SearcRoadAddr road_address{get;set;}
        public String address_name{get;set;}
        public String address_type{get;set;}
        public String x{get;set;}
        public String y{get;set;}
     }


    public class SearcAddr {
        public String address_name {get;set;}
        public String b_code {get;set;}
        public String h_code {get;set;}
        public String main_address_no {get;set;}
        public String mountain_yn {get;set;}
        public String region_1depth_name {get;set;}
        public String region_2depth_name {get;set;}
        public String region_3depth_h_name {get;set;}
        public String region_3depth_name {get;set;}
        public String sub_address_no {get;set;}
        public String x {get;set;}
        public String y {get;set;}
                
    }    


    public class SearcRoadAddr {
        public String address_name {get;set;}
        public String building_name {get;set;}
        public String main_building_no {get;set;}
        public String region_1depth_name {get;set;}
        public String region_2depth_name {get;set;}
        public String region_3depth_name {get;set;}
        public String road_name {get;set;}
        public String sub_building_no {get;set;}
        public String underground_yn {get;set;}
        public String zone_no {get;set;}        
        public String x {get;set;}
        public String y {get;set;}
    }    



}