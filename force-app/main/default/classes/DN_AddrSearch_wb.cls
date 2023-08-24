/*
* ==================================================================================
*   File Name   : DN_AddrSearch_wb.cls
*   Author      : Soyoung.Jung
*   Date        : 2019.04.02
*   Tester      : DN_AddrSearch_wb_test.cls
*   Description : 행정안전부 도로명주소 검색API 콜아웃
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2019.04.02    Soyoung.Jung    Create
* ==================================================================================
*/

public with sharing class DN_AddrSearch_wb {
    
    private static DN_AddrSearch_wb sInstance = null;
    public static DN_AddrSearch_wb getInstance() {
        if(sInstance == null) sInstance = new DN_AddrSearch_wb();
        return sInstance;
    }


    /**
     * 주소정보 데이터 deserialize 및 Output 형태로 변환
     * 
     * @param objInput 
     *        - confmKey : 신청시 발급받은 승인키
     *        - keyword : 주소 검색어
     *        - resultType : 검색 결과 형식 설정 xml, json
     *        - currentPage : 현재 페이지 번호
     *        - countPerPage :페이지당 출력할 결과 row 수
     * @return Output
     *         - common
     *           - totalCount : 총 검색 데이터수 
     *           - currentPage : 페이지 번호
     *           - countPerPage : 페이지당 출력할 결과 row 수
     *           - errorCode : 에러 코드
     *           - errorMessage : 에러 메세지
     *         - juso : 주소정보
     *
    **/
    public Output execute(Input objInput) {
        Output objOutput = new Output();

        try {
            String responseBody = webCallOut(objInput);
            System.debug('responseBody : ' + responseBody);

            objOutput = (Output)JSON.deserialize(responseBody, Output.class);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        return objOutput;
    }


    /**
     * 주소정보 API 호출
     * 
     * @param objInput 
     *        - confmKey : 신청시 발급받은 승인키
     *        - keyword : 주소 검색어
     *        - resultType : 검색 결과 형식 설정 xml, json
     *        - currentPage : 현재 페이지 번호
     *        - countPerPage :페이지당 출력할 결과 row 수
     * @return responseBody : 반환 받은 Response 데이터
     *
    **/
    public static String webCallOut(Input objInput) {
        System.debug('objInput : '+ objInput);

        Http            http        = new Http();
        HttpRequest     request     = new HttpRequest();
        HttpResponse    response    = new HttpResponse();
        
        String responseBody = null;

        // API 호출 URL 정보 설정  
        String apiURL = 'http://www.juso.go.kr/addrlink/addrLinkApi.do'
                      + '?currentPage=' + objInput.currentPage
                      + '&countPerPage=' + objInput.countPerPage
                      + '&keyword=' + objInput.keyword.replaceAll(' ', '')
                      + '&confmKey=' + objInput.confmKey
                      + '&resultType=' + objInput.resultType;
        
        // API 호출                      
        request.setMethod('GET');
        request.setTimeout(110000);
        request.setEndpoint(apiURL);

        response     = http.send(request);
        responseBody = response.getBody();

        return responseBody;
    } 


    /************************************************************************************
    *   inputBody / outputBody innerClass
    *************************************************************************************/
    public class Input {
        public String  confmKey;        // 신청시 발급받은 승인키             
        public String  keyword;         // 주소 검색어
        public String  resultType;      // 검색 결과 형식 설정 xml, json
        public Integer currentPage;     // 현재 페이지 번호
        public Integer countPerPage;    // 페이지당 출력할 결과 row 수
    }

    public class Output {
        public OutputBody results;

        public Output() {
            results = new OutputBody();
        }
    }

    public class OutputBody {
        public Common           common;
        public List<Address>    juso;
    }

    public class Common {
        public String  totalCount;      // 총 검색 데이터수 
        public Integer currentPage;     // 페이지 번호
        public Integer countPerPage;    // 페이지당 출력할 결과 row 수
        public String  errorCode;       // 에러 코드
        public String  errorMessage;    // 에러 메세지
    }

    public class Address {
        public String  roadAddr;
        public String  roadAddrPart1;
        public String  roadAddrPart2;
        public String  jibunAddr;
        public String  engAddr;
        public String  zipNo;
        public String  admCd;
        public String  rnMgtSn;
        public String  bdMgtSn;
        public String  detBdNmList;
        public String  bdNm;
        public String  bdKdcd;
        public String  siNm;
        public String  sggNm;
        public String  emdNm;
        public String  liNm;
        public String  rn;
        public String  udrtYn;
        public String  mtYn;
        public Integer buldMnnm; 
        public Integer buldSlno;
        public Integer lnbrMnnm;
        public Integer lnbrSlno;
    } 

}