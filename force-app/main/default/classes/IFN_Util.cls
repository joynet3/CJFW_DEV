/**
* @Class : IFN_Util
* @group Framework : Common
* @Author : 조일근 
* @Date : 2023. 07. 18
* @Version : 1.0
* @Description : 
* @Modified : 인터페이스 공통 유틸함수 모음 클래스
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2023. 07. 18 | 조일근    | 최초작성
* */

public with sharing class IFN_Util {

    public class IFN_UtilException extends Exception{}
    
    public static String STATUS_SUCCESS = '0000:SUCCESS';
    public static String STATUS_EXCEPT = '9999:SERVER ERROR';
    public static String STATUS_VALIDATION_ERROR = '9998:PARAMETER VAIDATION ERROR';
    public static String STATUS_AUTH_ERROR = '9901:AUTH KEY INVALID';
    public static String STATUS_PARAMETER_ERROR = '9997:SEND PARAMETER INVALD';

 
        

    /**
     * 세일즈 포스 알람 전송용 함수
     * @param recipientsIds 
     * @param targetId 
     * @param pageRef 
     * @param notificationTypeId 
     * @param title 
     * @param body 
     */
    public static void notifyUsers(Set<String> recipientsIds, String targetId, String pageRef, String notificationTypeId, String title, String body) {             
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(title);
        notification.setBody(body);
        
        // Set the notification type and target
        notification.setNotificationTypeId(notificationTypeId);
        if(targetId != null) {
            notification.setTargetId(targetId);
        } else if(pageRef != null) {	// ex) String pageRef = '{"type": "standard__objectPage","attributes": {"objectApiName": "Account","actionName": "list"},"state":{"filterName":"Recent"}}';
            notification.setTargetPageRef(pageRef);
        }
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

    /**
     * 테이블 쿼기 
     * @param sObjectName 
     * @param fieldSetName 
     * @return  `String`
     */
    public static String getSObjectQuery(String sObjectName, String fieldSetName){        
        List<Schema.FieldSetMember> fmList = getFieldSetMembers(sObjectName, fieldSetName);
        
        String query = 'SELECT ';
        
        for(Schema.FieldSetMember f : fmList) {
            query += f.getFieldPath() + ', ';
        }
        query = query.removeEnd(', ');
        query += ' FROM '+ sObjectName;
        return query;
    }

    /**
     * Sobject 필드 리스트 추출
     * @param objectTypeName 
     * @param fieldSetName 
     * @return  `List<Schema.FieldSetMember>`
     */
    private static List<Schema.FieldSetMember> getFieldSetMembers(String objectTypeName, String fieldSetName) {
        System.debug(fieldSetName);
        DescribeSObjectResult[] describes = Schema.describeSObjects(new String[] {
            objectTypeName
                });
        
        if (describes != null && describes.size() > 0) {
            System.debug(describes[0].fieldSets);
            System.debug(describes[0].fieldSets.getMap());
            Schema.FieldSet fs = describes[0].fieldSets.getMap().get(fieldSetName);
            System.debug(fs.getFields());
            return fs.getFields();
        } else {
            return null;
        }
    }

    /**
     * obj의 recordtype name을 통해 id가져오기
     * @param objName 
     * @param recrodTypeDevName 
     * @return  `Id`
     */
    public static Id getRecordTypeId(String objName, String recrodTypeDevName)
    {
        return Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByDeveloperName().get(recrodTypeDevName).getRecordTypeId();
    }
    

    //숫자 외 제거
    public static String replaceText(String value){
        String result = '';

        if(value != null) {
            String str = String.valueOf(value).trim();
            String trim = str.replaceAll('[^0-9]', '');
            result = trim;
        }

        return result;
    }

    public static double[] convertCIELabtoRGB255(double CIE_L, double CIE_A, double CIE_B)
    {
        double[] result;

        double[] convertXYZ = IFN_Util.convertCIELabtoXYZ(CIE_L, CIE_A, CIE_B);
        result = IFN_Util.convertXYZtoRGB255(convertXYZ[0], convertXYZ[1], convertXYZ[2]);

        return result;
    }

    public static double[] convertCIELabtoXYZ(double CIE_L, double CIE_A, double CIE_B)
    {
        //D65/10°
        double data_xnxx = 94.811;
        double data_ynxx = 100.000;
        double data_znxx = 107.304;

        double tmp_X, tmp_Y, tmp_Z;
		double X, Y, Z;
		tmp_Y = ( CIE_L + 16 ) / 116;
		tmp_X = CIE_A / 500 + tmp_Y;
		tmp_Z = tmp_Y - CIE_B / 200;

		if ( Math.pow(tmp_Y, 3.0D) > 0.008856 ) tmp_Y = Math.pow(tmp_Y, 3.0D);
		else                      tmp_Y = ( tmp_Y - 16 / 116 ) / 7.787;
		if ( Math.pow(tmp_X, 3.0D) > 0.008856 ) tmp_X = Math.pow(tmp_X, 3.0D);
		else                      tmp_X = ( tmp_X - 16 / 116 ) / 7.787;
		if ( Math.pow(tmp_Z, 3.0D) > 0.008856 ) tmp_Z = Math.pow(tmp_Z, 3.0D);
		else                      tmp_Z = ( tmp_Z - 16 / 116 ) / 7.787;

		X = data_xnxx * tmp_X;
		Y = data_ynxx * tmp_Y;
		Z = data_znxx * tmp_Z;

		double[] tmp_Value = new double[3];
		tmp_Value[0] = X;
		tmp_Value[1] = Y;
		tmp_Value[2] = Z;

		return tmp_Value;
    }

    public static double[] convertXYZtoRGB255(double x, double y, double z)
    {
        double tmp_X, tmp_Y, tmp_Z;
        double tmp_R, tmp_G, tmp_B;
        
        tmp_X = X / 100;
		tmp_Y = Y / 100;
        tmp_Z = Z / 100;
        
        tmp_R = tmp_X * 3.240479    + tmp_Y * (-1.53715) + tmp_Z * (-0.498535);
		tmp_G = tmp_X * (-0.9689) + tmp_Y *  1.8758   + tmp_Z *  0.0415;
        tmp_B = tmp_X * 0.0557    + tmp_Y * (-0.2040) + tmp_Z *  1.0570;
        
        if ( tmp_R > 0.00304 ) tmp_R = 1.055 * ( Math.pow( tmp_R, double.valueOf(( 1 / 2.4 )) ) ) - 0.055;
		else                   tmp_R = 12.92 * tmp_R;
		if ( tmp_G > 0.00304 ) tmp_G = 1.055 * ( Math.pow( tmp_G, double.valueOf(( 1 / 2.4 )) ) ) - 0.055;
		else                   tmp_G = 12.92 * tmp_G;
		if ( tmp_B > 0.00304 ) tmp_B = 1.055 * ( Math.pow( tmp_B, double.valueOf(( 1 / 2.4 )) ) ) - 0.055;
		else                   tmp_B = 12.92 * tmp_B;

		double R = tmp_R * 255;
		double G = tmp_G * 255;
		double B = tmp_B * 255 ;

		if ( R < 0.0D )
		{
			R = 0.0D;
		}else if ( R > 255.0D )
		{
			R = 255.0D;
		}

		if ( G < 0.0D )
		{
			G = 0.0D;
		}else if ( G > 255.0D )
		{
			G = 255.0D;
		}

		if ( B < 0.0D )
		{
			B = 0.0D;
		}else if ( B > 255.0D )
		{
			B = 255.0D;
		}

        double[] tmp_Value = new double[3];
        //Math.Round 추가
		tmp_Value[0] = Math.round(R);
		tmp_Value[1] = Math.round(G);
		tmp_Value[2] = Math.round(B);

		return tmp_Value;
    }

    //Datetime > String (숫자만)
    public static String trimDatetimeNum(Datetime value){
        String result = '';

        if(value != null) {
            String str = String.valueOf(value);
            String trim = str.replaceAll('[^\\d]', '');
            result = trim + String.valueOf(value.millisecond());
        }

        return result;
    }
    
    //문자열을 입력한 숫자 보다 초과시 자름, 미만시 앞에 0추가
    public static String trimString(String trim, Integer num) {
        String result = '';
        
        if (trim != null && trim != '') {
            String temp = trim.trim();
            Integer leng;
            
            if(temp.length() > num){
                leng = temp.length() - num;
                result = temp.substring(leng, temp.length());
            } else if(temp.length() < num) {
                leng = num - temp.length();
                for(Integer i = 0; i < leng; i++) {
                    result += '0';
                }
                result += temp;
            } else {
                result = temp;
            }
        }        
        //System.debug('Account trimString : ' + result);
        return result;
    }
    
    /**
    * @description Convert '-' / -가 뒤에 붙어서 오는 숫자값의 경우 오류를 막기 위해 -를 앞으로 옮겨줌.
    * @author 
    * @param String minus 
    * @return decimal
    **/
    public static decimal convertMinus(String minus) {
        decimal result;
        if(minus != null && minus != '') {
            Integer check = minus.indexOf('-');
            String temp = '-';
            if(check == minus.length() - 1) {
                temp += minus.substring(0, check);
            } else {
                temp = minus;
            }
            result = decimal.valueOf(Double.valueOf(temp));
        } else {
            result = 0;
        }
        return result;
    }

    /**
    * @description CONVERT TIME / 문자열로 들어온 시간 형태의 값을 시간(Time)로 치환하여 리턴
    * @author 
    * @param String oTime / HHMMSS or HH:MM:SS
    * @return Time
    **/
    public static Time convertTime(String oTime){
        String cTime;
        Time rTime = null;

        try
        {
            if(oTime != null && oTime != '') 
            {
                cTime = oTime.replaceAll('[^0-9]', '');

                Pattern p = pattern.compile('(\\d{2})(\\d{2})(\\d{2})');
                Matcher m = p.matcher(cTime);
                m.find();
                Integer cHH = Integer.valueOf(m.group(1));
                Integer cMM = Integer.valueOf(m.group(2));
                Integer cSS = Integer.valueOf(m.group(3));
                
                rTime = Time.newInstance(cHH, cMM, cSS, 00);
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage() + ' / ' + e.getStackTraceString());
        }

        return rTime;

    } //end of convertTime()

    public static Time convertTime(String oTime, Integer leng){
        String cTime;
        Time rTime = null;

        try
        {
            if(!String.isBlank(oTime)) 
            {
                cTime = oTime.trim().replaceAll('[^0-9]', '');

                Pattern p = pattern.compile('(\\d{2})(\\d{2})(\\d{2})');
                Matcher m = p.matcher(cTime);
                m.find();
                Integer cHH = Integer.valueOf(m.group(1));
                Integer cMM = Integer.valueOf(m.group(2));
                Integer cSS = Integer.valueOf(m.group(3));
                
                rTime = Time.newInstance(cHH, cMM, cSS, 00);
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage() + ' / ' + e.getStackTraceString());
        }

        return rTime;

    } //end of convertTime()

    /**
    * @description CONVERT DATE / 문자열로 들어온 날짜 형태의 값을 날짜로 치환하여 리턴
    * @author 
    * @param String cDate 
    * @return Date
    **/
    public static Date convertDate(String cDate) {
        String conDate;
        Date resultDate;
        
        try{
            if(cDate != null && cDate != '' && cDAte != '00000000')
            {
                conDate = cDate.trim().replaceAll('[^0-9]', '');
                //System.debug('cDate : ' + cDate);
                
                Pattern p = pattern.compile('(\\d{4})(\\d{2})(\\d{2})');
                Matcher m = p.matcher(conDate);
                m.find();
                Integer cYear = Integer.valueOf(m.group(1));
                Integer cMonth = Integer.valueOf(m.group(2));
                Integer cDay = Integer.valueOf(m.group(3));
                
                resultDate = Date.valueOf(cYear + '-' + cMonth + '-' + cDay);
                //System.debug('resultDate : ' + resultDate);
                if(resultDate > date.newInstance(4000,12,30) || resultDate < date.newInstance(1700,1,1))
                {
                    resultDate = null;
                }
            }
            else
            {
                resultDate = null;
            }
        } 
        catch(Exception e)
        {
            System.debug(e.getMessage() + ' / ' + e.getStackTraceString());
        }
        return resultDate;
    }
    
    /**
    * @description 문자열로 들어온 날짜시간 형태의 값을 날짜:시간로 치환하여 리턴
    * @author 
    * @param String cDate 
    * @return Datetime 
    **/
    public static Datetime convertDateTime(String cDate) {
        String conDate;
        Datetime resultDateTime = null;
        
        try
        {
            if(!String.isBlank(cDate)) 
            {
                conDate = cDate.trim().replaceAll('[^0-9]', '');
                //System.debug('cDate : ' + cDate);
                
                Pattern p = pattern.compile('(\\d{4})(\\d{2})(\\d{2})(\\d{2})(\\d{2})(\\d{2})');
                Matcher m = p.matcher(conDate);
                m.find();
                Integer cYear = Integer.valueOf(m.group(1));
                Integer cMonth = Integer.valueOf(m.group(2));
                Integer cDay = Integer.valueOf(m.group(3));
                Integer cHour = Integer.valueOf(m.group(4));
                Integer cMin = Integer.valueOf(m.group(5));
                Integer cSec = Integer.valueOf(m.group(6));

                resultDateTime = Datetime.valueOf(cYear + '-' + cMonth + '-' + cDay + ' ' + cHour + ':' + cMin + ':' + cSec);
                if(resultDateTime > date.newInstance(4000,12,30) || resultDateTime < date.newInstance(1700,1,1))
                {
                    resultDateTime = null;
                }
                
                //System.debug('resultDate : ' + resultDate);
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage() + ' / ' + e.getStackTraceString());
        }
        return resultDateTime;
    }

    /**
    * @description DATETIME CHECK / 문자열로 들어온 날짜:시간 형태 값을 날짜:시간 값으로 치환 및 리턴
    * @author 
    * @param String check
    * @return Boolean 
    **/
    public static Boolean datetimeCheck(String check) {
        Boolean result;
        
        try
        {
            if(check != null && check != '') {
                String DatetimeRegex = '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}((\\+|-)[0-1][0-9]{3})?$';
                Pattern p = Pattern.compile(DatetimeRegex);
                Matcher m = p.matcher(check);
                result = m.find();
            } else {
                result = false;
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage() + ' / ' + e.getStackTraceString());
        }
        return result;
    }
    
    /**
    * @description Date + Time / 날짜와 시간값이 각각 다른 문자열로 들어오는 경우 날짜:시간 값으로 치환 및 리턴
    * @author 
    * @param String sDate, String sTime
    * @return Datetime 
    **/
    public static Datetime dateSumTime(String sDate, String sTime) {
        Integer year;
        Integer mon;
        Integer day;
        Integer hour;
        Integer min;
        Integer sec;
        Datetime result = null;
        
        try
        {
            if(!String.isBlank(sDate) && !String.isBlank(sTime)) {
                
                year = Integer.valueOf(sDate.substring(0, 4));
                mon = Integer.valueOf(sDate.substring(4, 6));
                day = Integer.valueOf(sDate.substring(6, 8));
                hour = Integer.valueOf(sTime.substring(0, 2));
                min = Integer.valueOf(sTime.substring(2, 4));
                sec = Integer.valueOf(sTime.substring(4, 6));
                System.debug('substring : ' + year + '-' + mon + '-' + day + ' ' + hour + ':' + min + ':' + sec);
                //2020-06-26 10:27:30        
                result = Datetime.valueOf(year + '-' + mon + '-' + day + ' ' + hour + ':' + min + ':' + sec);
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage() + ' / ' + e.getStackTraceString());
        }
        return result;
    }


    public static List<String> getListDividedByByteSize(String value, Integer limitByteSize)
    {
        List<String> result = new List<String>();
        Integer totalByteSize = 0;
        List<String> strSplit = value.split('');
        String addStr = '';
        for(Integer i = 0; i < strSplit.size(); i ++)
        {
            totalByteSize += Blob.valueof(strSplit[i]).size();
            if(totalByteSize > limitByteSize)
            {
                result.add(addStr);
                totalByteSize = 0;
                addStr = strSplit[i];
            }
            else
            {
                addStr += strSplit[i];
                if((i+1) == strSplit.size()) result.add(addStr);
            }
        }

        return result;
    }
    

    /**
     * datetime 문자열 format 으로 변경
     */
    public static String converDateTimeToStrFormat(Datetime dt) {
        return converDateTimeToStrFormat(dt,'yyyy-MM-dd');
    }

    /**
     * datetime 문자열 format 으로 변경
     */    
    public static String converDateTimeToStrFormat(Datetime dt, String format) {
        String ret='';
        if(dt !=null) {
            ret = dt.format(format);
        }
        return ret;
    }

    /**
    * date 문자열 format 으로 변경
    */    
    public static String converDateToStrFormat(Datetime dt) {
        return converDateToStrFormat(dt,'yyyy-MM-dd');
    }
    /**
    * date 문자열 format 으로 변경
    */
    public static String converDateToStrFormat(Datetime dt, String format) {
        String ret='';

        if(dt !=null) {
            ret = Datetime.newInstance(dt.year(),dt.month(),dt.day()).format(format);
        }
        return ret;
    }
    
    /**
    * Date와 Time을 Datetime 으로 변경
    */
    public static Datetime convertDateAddTime(Date d, Time t){
                
        if(d == null){
            return null;
        }

        if(t == null){
            return DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
        }

        return DateTime.newInstance(d, t);

    }

    /**
    * Date와 Time을 Datetime 으로 변경
    */
    public static Datetime convertDateTimeGMT(String pDate, String pTime)
    {
        // 날짜 없음
        if(pDate == null || pDate == '' || pDate == '00000000')
        {
            return null;
        }

        String sDate = pDate.Trim();        
        
        Integer year    = Integer.valueOf(sDate.substring(0, 4));
        Integer mon     = Integer.valueOf(sDate.substring(4, 6));
        Integer day     = Integer.valueOf(sDate.substring(6, 8));
        Integer hour    = 0;
        Integer min     = 0;
        Integer sec     = 0;

        Date resultDate;
        resultDate = Date.valueOf(year + '-' + mon + '-' + day);
        if(resultDate > date.newInstance(4000,12,30) || resultDate < date.newInstance(1700,1,1))
        {
            return null;
        }
        else
        {
            // 시간 없음
            if(pTime == null || pTime == '' || pTime == '000000')
            {   
                day -= 1;
                hour = 15;         
                return Datetime.newInstanceGmt(year,mon,day,hour,min,sec);
            }
            String sTime = pTime.Trim();

            switch on pTime.length()
            {
                when 6 
                {
                    hour = Integer.valueOf(sTime.substring(0, 2));
                    min  = Integer.valueOf(sTime.substring(2, 4));
                    sec  = Integer.valueOf(sTime.substring(4, 6));
                }

                when 4 
                {
                    hour = Integer.valueOf(sTime.substring(0, 2));
                    min  = Integer.valueOf(sTime.substring(2, 4));
                }

                when 2 
                {
                    hour = Integer.valueOf(sTime.substring(0, 2));
                }

                when else
                {
                }
            }
            // 날짜 시간 둘다 있음
            return Datetime.newInstance(year,mon,day,hour,min,sec);
            //return Datetime.valueOf(year + '-' + mon + '-' + day + ' ' + hour + ':' + min + ':' + sec);
        }
    }

    public static String encDataGcredit(String endText){
        
        Blob key = EncodingUtil.base64Decode('mRMjHmlC1C+1L/Dkz8EJuw==');
        Blob cipherText = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(endText));
        String encodedCipherText = EncodingUtil.convertToHex(cipherText); 
        //String encodedCipherText = EncodingUtil.base64Encode(cipherText); 
        
        System.debug(encodedCipherText);
        return encodedCipherText;
    }

    
    /**
    * String을 숫자형 String으로 반환 0010907597 -> 10907597
    */
    public static String converStringToNumber(String value){
        
        if(value != null && Pattern.matches('^[0-9]*$', value)){
            try{
                return String.valueOf(Integer.valueOf(value));
            }
            catch(Exception e){
                System.debug('Error : ' + e.getMEssage()  + ', line : ' + e.getLineNumber());
                return String.valueOf(Long.valueOf(value));
            }
        }
        
        return value;
    }

    public static String searchText(String Key, Set<String> textSet){
        String result = '';

        for(String text : textSet){
            result += text + '|';
        }

        return result;

    }

    //다음 배치 확인 및 실행
    public static void NextBatchCheck(String className){

        List<Batch_Sequence__mdt> mb = [
            SELECT Id
                , DeveloperName
                , NextBatchName__c
                , ScopeSize__c
                , isScheduled__c
                , ScheduleClass__c
                , Interval__c
                , CronExpression__c
                , Queueable__c
            FROM Batch_Sequence__mdt 
            WHERE DeveloperName = :className 
            AND IsActive__c = true
            LIMIT 1
        ];

        //Next Batch Class = Queueable 형태일때도 실행되게끔 수정 : 2022.01.14 김은태
        if(mb.size() > 0 && String.isNotBlank(mb[0].NextBatchName__c)) {

            Type tp = Type.forName(mb[0].NextBatchName__c.trim());
            
            if(mb[0].Queueable__c == true){
                Queueable Que = (Queueable)tp.newInstance();
                System.enqueueJob(Que);
            } else {
                Database.Batchable<sObject> batch = (Database.Batchable<sObject>)tp.newInstance();
                Database.executeBatch(batch, Integer.valueOf(mb[0].ScopeSize__c));
            }
        }
        

        System.debug(mb.size());
    }

    public static void NextScheduleCheck(String className){
        
        List<Batch_Sequence__mdt> mb = [SELECT Id
                                            , DeveloperName
                                            , NextBatchName__c
                                            , ScopeSize__c
                                            , isScheduled__c
                                            , ScheduleClass__c
                                            , Interval__c
                                            , CronExpression__c
                                            FROM Batch_Sequence__mdt 
                                            WHERE DeveloperName = :className 
                                            AND isScheduled__c = true
                                            LIMIT 1];

        //Schedule Check
        if(mb.size() > 0)
        {
            System.debug('mb' + mb[0]);
            
            if(mb[0].Interval__c != null)
            {
                List<CronTrigger> cronTr = [SELECT Id,CronExpression,CronJobDetail.Name
                                        FROM CronTrigger 
                                        WHERE CronJobDetail.Name = :mb[0].ScheduleClass__c LIMIT 1];
            
                if(!cronTr.isEmpty()) System.abortJob(cronTr[0].Id);
                
                IFN_Scheduler sch = new IFN_Scheduler(mb[0].ScheduleClass__c, String.valueOf(mb[0].ScopeSize__c));
                String cronExp = '';
                
                Datetime dt = Datetime.now().addMinutes(Integer.valueOf(mb[0].Interval__c));
                cronExp = dt.format('s mm HH') + ' * * ?';

                // 테스트시 실행 되지않도록 함
                if(!Test.isRunningTest()){
                    system.schedule(mb[0].ScheduleClass__c.trim(), cronExp, sch);
                }
                
            }
        }
    }

    public static boolean minusCheck(String val){
        boolean result = false;
        if(val != null) result = val.contains('-');
        return result;
    }


}