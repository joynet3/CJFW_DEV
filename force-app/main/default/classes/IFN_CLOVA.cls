/**
 * Created by 박지오사원 on 2023-09-07.
 */

public with sharing class IFN_CLOVA {
private static final String CLOVA_INVOKE_URL = 'https://clovaspeech-gw.ncloud.com/external/v1/5556/089eef3dd183a59e0da2976e9d0e0349b7ec5f9c01cb70ceaff3ff1838afc88e';
private static final String CLOVA_SECRET_KEY = '0ad7fad5fab649f096c518928fe56184';

public static void sendMessage(String receiverId, String message) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(CLOVA_INVOKE_URL);
    request.setMethod('POST');
    request.setHeader('X-CLOVASPEECH-API-KEY', CLOVA_SECRET_KEY);
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=utf-8');

    String requestBody = 'template_object={"object_type":"text","text":"' + message + '","link":{"web_url":"https://example.com"}}';
    request.setBody(requestBody);

    HttpResponse response = new Http().send(request);
    if (response.getStatusCode() == 200) {
        // Message sent successfully
    } else {
        // Handle the error case
        String errorMessage = 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
        System.debug(errorMessage);
    }
}
}