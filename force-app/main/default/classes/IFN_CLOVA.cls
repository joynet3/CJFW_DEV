/**
 * Created by 박지오사원 on 2023-09-07.
 */

public with sharing class IFN_CLOVA {
    private static final String CLOVA_INVOKE_URL = 'https://clovaspeech-gw.ncloud.com/external/v1/5556/089eef3dd183a59e0da2976e9d0e0349b7ec5f9c01cb70ceaff3ff1838afc88e';
    private static final String CLOVA_SECRET_KEY = '0ad7fad5fab649f096c518928fe56184';

    public Clova_ResponseDTO sendMessage(String fileUrl) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(CLOVA_INVOKE_URL + '/recognizer/url');
        request.setMethod('POST');
        request.setHeader('X-CLOVASPEECH-API-KEY', CLOVA_SECRET_KEY);
        request.setHeader('Content-Type', 'application/json;charset=utf-8');
        Clova_ResponseDTO res = new Clova_ResponseDTO();
        String requestBody = System.JSON.serialize(new Clova_RequestDTO(fileUrl));
        request.setBody(requestBody);

        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 200) {
            res = (Clova_ResponseDTO) System.JSON.deserialize(response.getBody(), Clova_ResponseDTO.class);
        } else {
            // Handle the error case
            String errorMessage = 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            System.debug(errorMessage);
        }
        return res;
    }

    public class Clova_RequestDTO {
        String url { get; set; }
        String language = 'ko-KR';
        //completion optional, sync/async
//    String completion = "sync";4444
        String completion = 'async';
        //optional, used to receive the analyzed results
        String callback = 'https://cj-fresh-test-8be160f3f998.herokuapp.com/callback';
//    String callback;
        //optional, any data
        Map<String, Object> userdata;
        Boolean wordAlignment = true;
        Boolean fullText = true;
        Boolean resultToObs = false;
        //boosting object array
        //comma separated words
        String forbiddens = 'comma separated words';
        /*List<Boosting> boostings;
        Diarization diarization;
        public class Boosting {
           public String words = 'comma separated words';
        }

        public class Diarization {
           public Boolean enable = false;
           public Integer speakerCountMin;
           public Integer speakerCountMax;
        }*/
        public Clova_RequestDTO(String url) {
            this.url = url;
        }
    }
    public class Clova_ResponseDTO {
        String result { get; set; }
        String message { get; set; }
        String token { get; set; }
        String version { get; set; }
        Map<String, Object> params { get; set; }
        Integer progress { get; set; }
        List<Map<String, Object>> segments { get; set; }
        String text { get; set; }
        Double confidence { get; set; }
        List<Map<String, Object>> speakers { get; set; }

    }
}