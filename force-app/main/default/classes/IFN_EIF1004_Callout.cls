/**
 * @Class : IFN_EIF1004_Callout.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.11.06
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.06 | sancho         | 최초작성
 * */
public class IFN_EIF1004_Callout {
    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
    
    public IFN_EIF1004_Callout() {
        this.commlog = new IFN_CommonLog();
    }

    public IFN_EIF1004_Callout(String interfaceId, String type) {
        this.commlog = new IFN_CommonLog();
        this.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }

    public IFN_CalloutResult getResponse(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();
        
        try {
            switch on interfaceId {

                //식품(첨가물)품목제조보고-전용유 조회
                when 'IFN_EIF1004_DT001_MD001'{ 
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IFN_EIF1004_DT001_MD001(interfaceId, params);
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
            REST get 방식 https://dotop.kr/Service/API/?serviceKey=944FB5A82EAE4149B3F8AAE5C48E7752&serviceDiv=A01&Address1=서울
        @response
        {
            "meta": [
                {
                    "result_code": "0",
                    "err_message": "",
                    "err_stack": "",
                    "total_count": "2000"
                }
            ],
            "item": [
                {
                    "NeisCodeStd": "7631226",
                    "SchoolTitle": "평택새빛초등학교",
                    "Tel": null,
                    "Fax": null,
                    "CountRoom": 0,
                    "CountTeacher": 0,
                    "CountStudent": 0,
                    "Address1": "경기",
                    "Address2": "경기"
                },
                {
                    "NeisCodeStd": "7451104",
                    "SchoolTitle": "대전수정초등학교",
                    "Tel": "0428285300",
                    "Fax": "0428225304",
                    "CountRoom": 13,
                    "CountTeacher": 18,
                    "CountStudent": 296,
                    "Address1": "대전",
                    "Address2": "유성구"
                }
            ]
        }
     * */
    public IFN_CalloutResult IFN_EIF1004_DT001_MD001(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = 'Callout Success';
        
        IFN_EIF1004_DT001_MD001.Output infResponse = new IFN_EIF1004_DT001_MD001.Output();  
        
        try{
            System.debug('params >>>>>>>>>>>>>>>>>>>>>>>>>' + params);
            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);
            //String requestBody = JSON.serialize(reqparam);
            String requestBody = (String)params;
            
            System.debug('requestBody:' + requestBody);

            Map<String,String> hemap = new Map<String,String>();
            HttpResponse response = gateway.webCallout(requestBody, hemap, true);

            System.debug(response.getBody());
            System.debug(response.getStatusCode());
            System.debug(response.getStatus());

            responsedata = response.getBody();
            if(response.getStatusCode() == 200) {
                infResponse = (IFN_EIF1004_DT001_MD001.Output)JSON.deserializeStrict((String)responsedata, IFN_EIF1004_DT001_MD001.Output.class);
            } else {
                result_code = 'F';
                result_message = 'Callout Fail';
            }

        } catch(Exception e) {
            result_code = 'E';
            result_message = 'Interface Exception';
        }  

        result.setResult(
            result_code
            , result_message
            , infResponse
        );

        return result;
    }
}