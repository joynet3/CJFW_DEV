public class NaverCloudOcrAPI {
    public static List<String> analyzeImage(String imageUrl) {
        List<String> contInfo = new List<String>();   
        
        //naver 계정 생성 후 얻은 값 1
        String endpointUrl = 'https://r5ju2qbf3c.apigw.ntruss.com/custom/v1/23365/0a62b38e58d402266882daa5a29115e428f286c421d827d4ff4626b881114a99/general';
        
        // Prepare the request JSON payload
        Map<String, Object> requestPayload = new Map<String, Object>();
        List<Object> images = new List<Object>();
        Map<String, Object> image = new Map<String, Object>();
        image.put('format','jpg');
        image.put('name', '차량등록증샘플');
        image.put('url', imageUrl);
        images.add(image);
        
        requestPayload.put('version', 'V2');
        requestPayload.put('requestId', 'guide-json-demo');
        requestPayload.put('timestamp', 0);
        requestPayload.put('lang', 'ko');
        requestPayload.put('images', images);
        // Send the request to naver ocr API
        HttpRequest req = new HttpRequest();
        //naver계정 생성 후 얻은 값 2
        req.setHeader('X-OCR-SECRET','cmZGT0JyREpsdkVNSlp1TWFWR1FxZFZCQ2JBSWNGVEE=');        
        req.setHeader('Content-Type','application/json');   
        req.setMethod('POST');        
        req.setEndpoint(endpointUrl);
        req.setTimeout(120000);
        req.setBody(JSON.serialize(requestPayload));
        
        HttpResponse httpResponse = new Http().send(req);
        // Process the response
        if (httpResponse.getStatusCode() == 200) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
          
            //첨부한 파일 가로, 높이 크기
            Integer imageWidth = (Integer)((Map<String, Object>)(((Map<String, Object>)(((List<Object>)(response.get('images')))[0])).get('convertedImageInfo'))).get('width');
            Integer imageHeight = (Integer)((Map<String, Object>)(((Map<String, Object>)(((List<Object>)(response.get('images')))[0])).get('convertedImageInfo'))).get('height');
            
            //샘플 파일을 기준으로 계산하는 것이므로 필요시 하드코딩한 수 변경해야함
            //첫번째 영역 지정을 위한 값
            Integer minX1 = (Integer)(imageWidth*200/2478);
            Integer maxX1 = (Integer)(imageWidth*2470/2478);
            Integer minY1 = (Integer)(imageHeight*10/3504);
            Integer maxY1 = (Integer)(imageHeight*1500/3504);

            //두번째 영역 지정을 위한 값
            Integer minX2 = (Integer)(imageWidth*100/2478);
            Integer maxX2 = (Integer)(imageWidth*1600/2478);
            Integer minY2 = (Integer)(imageHeight*100/3504);
            Integer maxY2 = (Integer)(imageHeight*1500/3504);

            //세번째 영역 지정을 위한 값
            Integer minX3 = (Integer)(imageWidth*100/2478);
            Integer maxX3 = (Integer)(imageWidth*2000/2478);
            Integer minY3 = (Integer)(imageHeight*1750/3504);
            Integer maxY3 = (Integer)(imageHeight*3000/3504);
            
            // Extract relevant information from the response and return it
            List<Object> responseImages = (List<Object>) response.get('images');            
            List<String> contInfo1 = new List<String>();
            List<String> contInfo2 = new List<String>();
            List<String> contInfo3 = new List<String>();
            
            for (Object imageEach : responseImages) {

                //naver ocr에 보낸 파일의 품질이 떨어지는 경우 error로 품질이 떨어진다는 내용이 넘어옴
                if(((Map<String, Object>)imageEach).get('error') == null){
                    for(Object each :(List<Object>)(((Map<String, Object>)imageEach).get('fields'))){
                        Object boundingPoly = ((Map<String, Object>)each).get('boundingPoly');
                        Boolean putFlag1 = false;     
                        Boolean putFlag2 = false;    
                        Boolean putFlag3 = false;                       
                        for(Object eachBp : (List<Object>)((Map<String, Object>)boundingPoly).get('vertices')){
                            Integer spotX = Integer.valueOf(((Map<String, Object>)eachBp).get('x'));
                            Integer spotY = Integer.valueOf(((Map<String, Object>)eachBp).get('y'));   
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
                        //'자동차등록증' 단어 기대
                        if(putFlag1){
                            contInfo1.add((String)((Map<String, Object>)each).get('inferText'));
                        }
                        //자동차등록번호 기대
                        if(putFlag2){
                            contInfo2.add((String)((Map<String, Object>)each).get('inferText'));
                        }   
                        //유류유형 기대
                        if(putFlag3){
                            contInfo3.add((String)((Map<String, Object>)each).get('inferText'));
                        }                 
                    }
                }else{
                    contInfo1.add('이미지 품질이 떨어집니다');
                }
                
            }
            contInfo.add(String.join(contInfo1, ''));
            contInfo.add(String.join(contInfo2, ''));
            contInfo.add(String.join(contInfo3, ''));
            return contInfo;
        } else {
            // Handle error response
            System.debug('naver ocr API request failed. Response: ' + httpResponse.getBody());
            return null;
        }
    }
}