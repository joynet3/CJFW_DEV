/**
 * @Class : IFN_CMM_ERRUTIL.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.09.12
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.12 | 조일근  | 최초작성
 * */
public class IFN_CMM_ERRUTIL {
    
        //============================ COMMON ===========================
        /** SUCCESS */
        public static String ERRKEY_SUCCESS = 'MSG_COMMON_0000';
        /** 인증키 오류 */
        public static String ERRKEY_AUTH_ERROR = 'MSG_COMMON_9901';
        /** 필수 파라메터 누락 오류 */ 
        public static String ERRKEY_RQMT_PARAM_ERROR = 'MSG_COMMON_9902';
        /** 파라메터 밸리데이션 오류 */       
        public static String ERRKEY_PARAMETER_ERROR = 'MSG_COMMON_9903';
        /** Body Data 누락 */               
        public static String ERRKEY_BODYCTT_EMPTY_ERROR = 'MSG_COMMON_9904';  
        /** 조회되는 데이터가 없습니다. */    
        public static String ERRKEY_DATA_NOTFOUND_ERROR = 'MSG_COMMON_9905';
        /** 중복된 데이터 입력입니다. */      
        public static String ERRKEY_DUPLICATION_INPUT_ERROR = 'MSG_COMMON_9906';
        /** SERVER ERROR */  
        public static String ERRKEY_SERVER_ERROR = 'MSG_COMMON_9999';

        //============================ LIF1002 ===========================
        /** 이미 등록된 샘플 또는 부가서비스 신청이 존재합니다. */  
        public static String ERRKEY_MSG_LIF1002_0001 = 'MSG_LIF10002_0001';
         /**요청한 샘플 또는 부가서비스 신청이 존재하지 않습니다. */
    	public static String ERRKEY_MSG_LIF1002_0002 = 'MSG_LIF10002_0002';


   public class IFN_CommonException extends Exception{}

    /**
     *  메소드 설명 작성
     * 
     * @param  변수명 파라미터 설명 (있는경우)
     * @return  리턴값 설명 (있는경우)
     * @exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
     * @example 
     *  예제코드 태그 아래줄에서 예제 작성
     * */
    public static Map<String,ErrorValueWrapper> GET_SYSTEM_ERRMAP(String SystemCode) {
        Map<String,ErrorValueWrapper> retMap = new Map<String,ErrorValueWrapper>();

        List<IF_ERROR_CODE_MST__c> errInfoLst =  [Select Id, SYSTEM_CODE__c, ERROR_KEY__c, ERROR_CODE__c, ERROR_MSG__c 
        From IF_ERROR_CODE_MST__c where SYSTEM_CODE__c = :SystemCode];
        for (IF_ERROR_CODE_MST__c itm : errInfoLst) {
            ErrorValueWrapper ev = new ErrorValueWrapper();
            ev.err_code = itm.ERROR_CODE__c;
            ev.err_msg = itm.ERROR_MSG__c;
            retMap.put(itm.ERROR_KEY__c, ev);
        }
        return retMap;
    }

    /**
     *  에러 정보를 에러코드 키값으로 가져와 에러코드 및 에러 메세지 세팅
     * 
     * @param  변수명 파라미터 설명 (있는경우)
     * @return  리턴값 설명 (있는경우)
     * @exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
     * @example 
     *  예제코드 태그 아래줄에서 예제 작성
     * */
    public static ErrorValueWrapper GET_ERRORINFO_BYERRORKEY(String SystemCode,String ErrorKey) {
        ErrorValueWrapper retVal = new ErrorValueWrapper();

        IF_ERROR_CODE_MST__c errInfo =  [Select Id, SYSTEM_CODE__c, ERROR_KEY__c, ERROR_CODE__c, ERROR_MSG__c 
        From IF_ERROR_CODE_MST__c 
        where SYSTEM_CODE__c = :SystemCode
        and ERROR_KEY__c = :ErrorKey
        Limit 1];
        
        retVal.err_code = errInfo.ERROR_CODE__c;
        retVal.err_msg = errInfo.ERROR_MSG__c;


        return retVal;
    }


    /**
     *  에러 정보를 에러코드 키값으로 가져와 에러코드 및 에러 메세지 세팅.
     *  -  메세지의 경우 파라메터 처리할 경우 사용
     * 
     * @param  변수명 파라미터 설명 (있는경우)
     * @return  리턴값 설명 (있는경우)
     * @exception  메소드가 발생시키는 예외에 대한 설명 또는 목록
     * @example 
     *  예제코드 태그 아래줄에서 예제 작성
     * */
    public static ErrorValueWrapper GET_ERRORINFO_BYERRORKEY_FORMAT(String SystemCode,String ErrorKey,List<String> addParam) {
        ErrorValueWrapper retVal = new ErrorValueWrapper();

        IF_ERROR_CODE_MST__c errInfo =  [Select Id, SYSTEM_CODE__c, ERROR_KEY__c, ERROR_CODE__c, ERROR_MSG__c 
        From IF_ERROR_CODE_MST__c 
        where SYSTEM_CODE__c = :SystemCode
        and ERROR_KEY__c = :ErrorKey
        Limit 1];
        
        retVal.err_code = errInfo.ERROR_CODE__c;
        retVal.err_msg = String.format(errInfo.ERROR_MSG__c, addParam);


        return retVal;
    }


    /**
     *  ErrorValue
     * 에러코드 정보 Wrapper
     * @param  
     * @return  
     * @exception  
     * */
    public class ErrorValueWrapper {
        public String err_code {get;set;}
        public String err_msg {get;set;}
    }


}