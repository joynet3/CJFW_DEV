/**
 * @Class : IFN_EIF1006_Callout.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023.11.14
 * @Version : 1.0
 * @Description : 낙찰정보 I/F Callout // 방사청, 나라장터
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.11.14 | sancho         | 최초작성
 * */
public class IFN_EIF1006_Callout {
    public IFN_CommonLog.LogWrap logWrap{get;set;}
    public IFN_CommonLog commlog;
    
    public IFN_EIF1006_Callout() {
        this.commlog = new IFN_CommonLog();
    }

    public IFN_EIF1006_Callout(String interfaceId, String type) {
        this.commlog = new IFN_CommonLog();
        this.logWrap = new IFN_CommonLog.LogWrap(interfaceId, type);
    }

    public IFN_CalloutResult getResponse(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();
        
        try {
            switch on interfaceId {

                //PD001 : 조달청(나라장터)
                when 'IFN_EIF1006_PD001_MD001'{ 
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IFN_EIF1006_PD001_MD001(interfaceId, params);
                }
                // 공공 데이터 휴일 조회
                when 'IFN_EIF1006_PD003_MD001'{ 
                    System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                    result = IFN_EIF1006_PD003_MD001(interfaceId, params);
                }


                // //PD002 : 방사청
                // when 'IFN_EIF1006_DT002_MD001'{ 
                //     System.debug(' getResponse >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + params);
                //     result = IFN_EIF1006_DT002_MD001(interfaceId, params);
                // }
            }
        } catch(Exception e) {
            result.setResult('E' , e.getMessage() , null); 
        } //end of try~catch
        return result;
    }

    

    /**
     *  나라장터 낙찰 현황 물품
     * 
     * @param  변수명 파라미터 설명 (있는경우)
     * @return  리턴값 설명 (있는경우)
     * @exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
     * @example 
     *  예제코드 태그 아래줄에서 예제 작성
        
        @request 
            REST get 방식 http://apis.data.go.kr/1230000/ScsbidInfoService/getScsbidListSttusThng?inqryDiv=3&type=json&inqryBgnDt=202311060000&inqryEndDt=202311090000&pageNo=1&numOfRows=999&ServiceKey=ewhZMDDBM/3wCJ5TMuXdFe5vxILI2XeTLbR3d1lUd2k2JC6NJWNVV3FO0djoICGHfrNQ7I19CFt10EzulcQXzw==
        @response
        {
        "response": {
            "header": {
                "resultCode": "00",
                "resultMsg": "정상"
            },
            "body": {
                "items": [
                    {
                        "bidNtceNo": "20231102658",
                        "bidNtceOrd": "00",
                        "bidClsfcNo": "1",
                        "rbidNo": "0",
                        "ntceDivCd": "1",
                        "bidNtceNm": "나-1-1 응용연구팀 기자재(컴퓨터서버) 구매_통계학과",
                        "prtcptCnum": "1",
                        "bidwinnrNm": "포스코테크 주식회사",
                        "bidwinnrBizno": "8438101313",
                        "bidwinnrCeoNm": "황형섭",
                        "bidwinnrAdrs": "서울특별시 성동구 아차산로7길 21 (성수동2가), 4층 111호",
                        "bidwinnrTelNo": "***-****-****",
                        "sucsfbidAmt": "8550000",
                        "sucsfbidRate": "95",
                        "rlOpengDt": "2023-11-06 09:00:00",
                        "dminsttCd": "6110158",
                        "dminsttNm": "서울특별시 서울시립대학교",
                        "rgstDt": "2023-11-06 10:01:36",
                        "fnlSucsfDate": "2023-11-06",
                        "fnlSucsfCorpOfcl": "황형섭",
                        "linkInsttNm": ""
                    },
                    ......
                ],
                "numOfRows": 999,
                "pageNo": 1,
                "totalCount": 666
            }
        }
    }
     * */
    public IFN_CalloutResult IFN_EIF1006_PD001_MD001(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = 'Callout Success';
        
        IFN_EIF1006_PD001_MD001.Output infResponse = new IFN_EIF1006_PD001_MD001.Output();  
        
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
                infResponse = (IFN_EIF1006_PD001_MD001.Output)JSON.deserializeStrict((String)responsedata, IFN_EIF1006_PD001_MD001.Output.class);
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




    /**
     *  메소드 설명 작성
     * 
     * @param  변수명 파라미터 설명 (있는경우)
     * @return  리턴값 설명 (있는경우)
     * @exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
     * @example 
     *  예제코드 태그 아래줄에서 예제 작성
     * */
    public IFN_CalloutResult IFN_EIF1006_PD003_MD001(String interfaceId, Object params){
        IFN_CalloutResult result = new IFN_CalloutResult();

        String responsedata = '';
        String result_code = 'S';
        String result_message = 'Callout Success';
        
        IFN_EIF1006_PD003_MD001.PD003_MD001ResWrapper  infResponse = new IFN_EIF1006_PD003_MD001.PD003_MD001ResWrapper();  
        
        try{

            
            Date dateToday = Date.today();    
            this.logWrap.RequestTime = Datetime.now();
            String requestBody = '';

            IFN_ApiGateWay gateway = new IFN_ApiGateWay(interfaceId);


            IFN_EIF1006_PD003_MD001.PD003_MD001RequstWrapper paramConvert = (IFN_EIF1006_PD003_MD001.PD003_MD001RequstWrapper)params;

            API_Authenticationkey__mdt authmdt = [SELECT KeyValue__c,DeveloperName  FROM API_Authenticationkey__mdt WHERE DeveloperName  = :interfaceId Limit 1];
            requestBody = paramConvert.searchSp + '?'
                                + 'ServiceKey=' + authmdt.KeyValue__c
                                + '&pageNo=1&numOfRows=100'
                                + '&solYear=' +   paramConvert.solYear;

            if(String.isNotBlank(paramConvert.solMonth)) requestBody = requestBody + '&solMonth=' +   paramConvert.solMonth;
            
            this.logWrap.RequestBody = Json.serialize(params);

            Map<String,String> hemap = new Map<String,String>();
            HttpResponse response = gateway.webCallout(requestBody, hemap, true);
           
            if(response.getStatusCode() == 200) {

                responsedata = response.getBody();
                infResponse =  (IFN_EIF1006_PD003_MD001.PD003_MD001ResWrapper)JSON.deserializeStrict((String)responsedata, IFN_EIF1006_PD003_MD001.PD003_MD001ResWrapper.class);
                
            } else {
                result_code = 'F';
                result_message = 'Callout Fail';
                this.logWrap.LogText.add('Callout Fail');
                this.logWrap.ErrorText.add(response.getStatus());                
            }

        } catch(Exception e) {
            result_code = 'E';
            result_message = 'Interface Exception' + '/n';
            result_message +=  '[' + e.getMessage()+' Line : '+e.getLineNumber() + ']' ;

            this.logWrap.LogText.add(e.getMessage() + '/' + e.getLineNumber());
            this.logWrap.ErrorText.add(e.getMessage() + '/' + e.getLineNumber());
                        
        }  

        result.setResult(
            result_code
            , result_message
            , infResponse
        );

        commlog.insertLog(this.logWrap);


        return result;
    }


}