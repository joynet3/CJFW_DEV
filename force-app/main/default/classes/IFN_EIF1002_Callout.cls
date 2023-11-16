/**
 * @Class : IFN_EIF1002_Callout.cls
 * @group Framework : 식품의약품안전처
 * @Author : sancho
 * @Date : 2023-11-07
 * @Version : 1.0
 * @Description : 식품의약품안전처 전용유
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.07 | sancho         | 최초작성
 * 
 * */
public class IFN_EIF1002_Callout {
    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
    
    public IFN_EIF1002_Callout() {
        this.commlog = new IFN_CommonLog();
    }

    public IFN_EIF1002_Callout(String interfaceId, String type) {
        this.commlog = new IFN_CommonLog();
        this.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }

    public IFN_CalloutResult getResponse(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();
        
        try {
            switch on interfaceId {
                //식품(첨가물)품목제조보고-전용유 조회
                when 'IFN_EIF1002_FS001_MD001'{ 
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IFN_EIF1002_FS001_MD001(interfaceId, params);
                }
            }
        } catch(Exception e) {
            result.setResult('E' , e.getMessage() , null); 
        } //end of try~catch
        return result;
    }

    /**
     *  식품(첨가물)품목제조보고-전용유 조회
     * 
     * @param  변수명 파라미터 설명 (있는경우)
     * @return  리턴값 설명 (있는경우)
     * @exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
     * @example 
     *  예제코드 태그 아래줄에서 예제 작성
        @request 
            REST get 방식 /I1250/json/1/1000/PRDLST_NM=%EC%A0%84%EC%9A%A9%EC%9C%A0
        @response
        {
            "I1250": {
                "total_count": "1000",
                "row": [
                    {
                        "PRDLST_REPORT_NO": "19630364001121",
                        "PRMS_DT": "19920822",
                        "LAST_UPDT_DTM": "20160706",
                        "LCNS_NO": "19630364001",
                        "PRDLST_NM": "허벌엣센스케이",
                        "QLITY_MNTNC_TMLMT_DAYCNT": "",
                        "BSSH_NM": "(주)보락",
                        "PRDLST_DCNM": "혼합제제",
                        "CHILD_CRTFC_YN": "",
                        "INDUTY_CD_NM": "식품첨가물제조업",
                        "USAGE": "착향료",
                        "POG_DAYCNT": "유통기간미등록",
                        "HIENG_LNTRT_DVS_NM": "해당없음",
                        "PRODUCTION": "아니오",
                        "PRPOS": ""
                    }
                ],
                "RESULT": {
                    "MSG": "정상처리되었습니다.",
                    "CODE": "INFO-000"
                }
            }
        }
     * */
    public IFN_CalloutResult IFN_EIF1002_FS001_MD001(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = 'Callout Success';
        
        IFN_EIF1002_FS001_MD001.Output infResponse = new IFN_EIF1002_FS001_MD001.Output();  
        
        try{
            System.debug('params >>>>>>>>>>>>>>>>>>>>>>>>>' + params);
            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            //String requestBody = JSON.serialize(reqparam);
            String requestBody = (String)params;
            Map<String,String> hemap = new Map<String,String>();
            HttpResponse response = gateway.webCallout(requestBody, hemap, true);

            responsedata = response.getBody();
            if(response.getStatusCode() == 200) {
                infResponse = (IFN_EIF1002_FS001_MD001.Output)JSON.deserializeStrict((String)responsedata, IFN_EIF1002_FS001_MD001.Output.class);
            } else {
                result_code = 'F';
                result_message = 'Callout Fail';
            }

        } catch(Exception e) {
            result_code = 'E';
            result_message = 'Interface Exception' + '/n';
            result_message +=  '[' + e.getMessage()+' Line : '+e.getLineNumber() + ']' ;
        }  

        result.setResult(
            result_code
            , result_message
            , infResponse
        );

        return result;
    }

}