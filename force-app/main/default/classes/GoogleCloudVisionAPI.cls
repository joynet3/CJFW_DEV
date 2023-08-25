public class GoogleCloudVisionAPI {
    public static List<String> analyzeImage(String imageUrl) {
        String apiKey='';

        // Retrieve the static resource
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'GoogleCloudVisionCredentials'];

        // Get the JSON content from the static resource
        String jsonContent = sr.Body.toString();

        // Parse the JSON content to extract the API key
        Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(jsonContent);
        String privateKey = (String) jsonData.get('private_key');

        // Extract the API key from the private key value
        List<String> privateKeyLines = privateKey.split('\n');
        String apiKeyLine ='';

        for (Integer i = 1; i < privateKeyLines.size() - 1; i++) {
            apiKeyLine+=privateKeyLines[i].trim();
        }

        apiKey = apiKeyLine;
        String endpointUrl = 'https://vision.googleapis.com/v1/images:annotate';
        
        // Prepare the request JSON payload
        Map<String, Object> requestPayload = new Map<String, Object>();
        List<Object> requests = new List<Object>();
        
        Map<String, Object> image = new Map<String, Object>();
        image.put('source', new Map<String, Object>{ 'imageUri' => imageUrl });
        
        List<Object> features = new List<Object>();
        features.add(new Map<String, Object>{ 'type' => 'text_detection', 'maxResults' => 5 });
        
        Map<String, Object> request = new Map<String, Object>();
        request.put('image', image);
        request.put('features', features);        
        requests.add(request);
        requestPayload.put('requests', requests);
        String token = 'ya29.c.b0Aaekm1IEA93yn5UHrgB3gIb0Cy8ntWFroH4ze7NJFKL9dKmWdgkUy7JCdygD3KKYcN6WsumFny4E4fWnxI9M3ENOO8TrEVQ1NJzYQ5x-ld2fWBrFac2g0q5Ys0NipgJEbF7H5dnZxhaUYRlpMWGILeiHS1K5sjArkkp-6WAhZg3mQ2Z_Buo7HP1qQoyAOPS15igw6QujiNEJsakOYFROXt-PM_wf2ii9hY0ZVtKwUJ4UxFn_DxhvkDcfo_7jDbL64wIy3qHArPScnFTlB-DXCS_p-1nLaYNtoot1uE6RSLWFxPCJvOgv3f1Kq7dF2ECjYV4mvquCidhdEUcLIE7RoAE351PiowU_dl-w7UMwmigeVI20FRc35Odo8r62M3ihJiYOeMfSli6vqnMS55JjFnJV89M3imbuhrXsFYRtcFI33_Yhxb3-n6SfhyMYjrmcR-_uB2bkOk8pZwbqIYw_haMhpMpFpJ8n_03ipx70-Vk9FFJhj7a2_l04Mvl71xSe72fUvv_hYJJ5JmVOQmQpl-9fgkopis-gudzWi-F1jlo9elS18nbVyZJVUqq3yXWhmz2IeYJ_suRyvZRMXjq6atVXc0F8ISRwl6ZMwyVvfF2zmSWXfs8Slnue8v4WyW7IMVyXhc3kk4g875Wqvqxf8YlVygYnhtuIk_-2okxtyeRF9y9yrUMnkj2jYqXcivtuyqyp3FBM3siM_XMYMf9j-8ji5aQwlp3vcbYn-s-uFluSu2-FJeqwR-fsSmqOa6XyohMhgmB0tS2JSUJsolVwRXVYjtfy1064an9WYa-vyttFV1hhqBjiXJuMnpzr03_IyfI4nOhWcbtMZi_kZIt-FVbI-IzetoB1JsF3pm1YdiYzRYFymvetvIVonVvz5qa5_4I9boOiqdj9Zfc7XRF4JRhcqSI9ytv0S_e2-bcr7b3-kqtlhvr7bcYbcdaf05zr1woojfY_cxbcVpO24WaqUXceYnJ4iZ8pZ2f34lVu9nv0zvUydBnzdqo';
        // Send the request to Google Cloud Vision API
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization','Bearer '+ token);
        req.setHeader('Content-Type','application/json; charset=utf-8');        
        req.setMethod('POST');        
        req.setEndpoint(endpointUrl);
        req.setTimeout(120000);
        req.setBody(JSON.serialize(requestPayload));
        
        HttpResponse httpResponse = new Http().send(req);

        System.debug('httpResponse: ' + httpResponse);
        
        // Process the response
        if (httpResponse.getStatusCode() == 200) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            // Calculate the ratio coordinates
            Integer imageWidth = (Integer)((Map<String, Object>)((Map<String, Object>)(((List<Object>)((Map<String, Object>)((Map<String, Object>)(((List<Object>)response.get('responses'))[0])).get('fullTextAnnotation')).get('pages'))[0]))).get('width');
            Integer imageHeight = (Integer)((Map<String, Object>)((Map<String, Object>)(((List<Object>)((Map<String, Object>)((Map<String, Object>)(((List<Object>)response.get('responses'))[0])).get('fullTextAnnotation')).get('pages'))[0]))).get('height');
            System.debug('imageWidth: ' + imageWidth);
            System.debug('imageHeight: ' + imageHeight);
            Integer minX1 = (Integer)(imageWidth*745/2478);
            Integer maxX1 = (Integer)(imageWidth*1771/2478);
            Integer minY1 = (Integer)(imageHeight*261/3504);
            Integer maxY1 = (Integer)(imageHeight*383/3504);

            Integer minX2 = (Integer)(imageWidth*441/2478);
            Integer maxX2 = (Integer)(imageWidth*1290/2478);
            Integer minY2 = (Integer)(imageHeight*450/3504);
            Integer maxY2 = (Integer)(imageHeight*550/3504);

            Integer minX3 = (Integer)(imageWidth*883/2478);
            Integer maxX3 = (Integer)(imageWidth*1225/2478);
            Integer minY3 = (Integer)(imageHeight*2168/3504);
            Integer maxY3 = (Integer)(imageHeight*2244/3504);
            System.debug('minX: ' + minX1);
            System.debug('maxX: ' + maxX1);
            System.debug('minY: ' + minY1);
            System.debug('maxY: ' + maxY1);
            
            // Extract relevant information from the response and return it
            List<Object> textAnnotations = (List<Object>) response.get('responses');
            List<String> contInfo = new List<String>();
            List<String> contInfo1 = new List<String>();
            List<String> contInfo2 = new List<String>();
            List<String> contInfo3 = new List<String>();
            System.debug('google ocr API request successed !! Response: ' + httpResponse.getBody());
            
            for (Object annotation : textAnnotations) {
                System.debug('error >>'+((Map<String, Object>)annotation).get('error'));
                if(((Map<String, Object>)annotation).get('error') == null){
                    for(Object each :(List<Object>)(((Map<String, Object>)annotation).get('textAnnotations'))){
                        Object boundingPoly = ((Map<String, Object>)each).get('boundingPoly');
                        Boolean putFlag1 = false;     
                        Boolean putFlag2 = false;    
                        Boolean putFlag3 = false;                       
                        for(Object eachBb : (List<Object>)((Map<String, Object>)boundingPoly).get('vertices')){
                            Integer spotX = (Integer)((Map<String, Object>)eachBb).get('x');
                            Integer spotY = (Integer)((Map<String, Object>)eachBb).get('y');   
                            if(spotX >= minX1 && spotX <= maxX1 && spotY >= minY1 && spotY <= maxY1 ){
                                putFlag1 = true;                                
                            }else{
                                putFlag1 = false;
                            }
                            if(spotX >= minX2 && spotX <= maxX2 && spotY >= minY2 && spotY <= maxY2 ){
                                putFlag2 = true;                                
                            }else{
                                putFlag2 = false;
                            }
                            if(spotX >= minX3 && spotX <= maxX3 && spotY >= minY3 && spotY <= maxY3 ){
                                putFlag3 = true;                                
                            }else{
                                putFlag3 = false;
                            }
                        }
                        if(putFlag1){
                            contInfo1.add((String)((Map<String, Object>)each).get('description'));
                        }
                        if(putFlag2){
                            contInfo2.add((String)((Map<String, Object>)each).get('description'));
                        }   
                        if(putFlag3){
                            contInfo3.add((String)((Map<String, Object>)each).get('description'));
                        }                 
                    }
                }else{
                    contInfo1.add('이미지 품질이 떨어집니다');
                }
                
            }
            contInfo.add(String.join(contInfo1, ' '));
            contInfo.add(String.join(contInfo2, ' '));
            contInfo.add(String.join(contInfo3, ' '));
            System.debug('추출한 결과값 !! >>'+contInfo);
            return contInfo;
        } else {
            // Handle error response
            System.debug('google ocr API request failed. Response: ' + httpResponse.getBody());
            return null;
        }
    }
}