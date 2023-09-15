/**
 * @Class : IFN_LIF1002_OD003_MD004.cls
 * @group Framework : 주문
 * @Author : 조일근
 * @Date : 2023-08-09
 * @Version : 1.0
 * @Description : 교육 서비스신청 리스트
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.09 | 조일근         | 최초작성
 *  2. | 2023.09.14 | 백영주         | 코드수정
 * */
/**
 * 수정한내용 20230914백영주대리
 * 1. 조회조건에 페이징처리 수정 (ClassService__c -> ServiceContents__c)
 * 2. 데이터 리스트 오브젝트 수정
 * 3. 이중반복문으로 classservice에 mdm이랑 컨텐츠아이디가 같을경우만 스테이터스값과 클레스서비스아이디 추가
 */
@RestResource(urlMapping='/LIF1002/OD003/MD004')
global with sharing class IFN_LIF1002_OD003_MD004 {
    global IFN_LIF1002_OD003_MD004() {}

    global class Input {
        public String schttl {get;set;}
        public String stDt {get;set;}
        public String edDt {get;set;}
        public String dataCnt {get;set;}
        public String pgNo {get;set;}
        public String mdmCd {get;set;}
    }

    global class Output {
        public String interface_id{get;set;}
        public String err_cd{get;set;}
        public String err_msg_ctt{get;set;}
        public resData response {get;set;}

    }

    global class resData {
        public String totDataCnt{get;set;}
        public String pgNo{get;set;}
        public List<DataList> listitem{get;set;}        
    }


    global class DataList {
        public String tp     {get;set;}
        public String ttl    {get;set;}
        public String rgNm   {get;set;}
        public String rgCd   {get;set;}
        public String istrt1 {get;set;}
        public String istrt2 {get;set;}
        public String opDt   {get;set;}
        public String stts   {get;set;}
        public String cttId  {get;set;}
        public String csId   {get;set;}
    }


    @HttpPost
    global static Output doPost() {
        String strCode = '0000';
        String strMessage = 'Success.';
        String interfaceId = 'IFN_LIF1002_OD003_MD004';

        IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
        IFN_CommonLog commlog = new IFN_CommonLog();

        Output objOutput = new Output();
        objOutput.interface_id = interfaceId;
        String requestBody = '';
        IFN_CMM_ERRUTIL.ErrorValueWrapper errWr = new IFN_CMM_ERRUTIL.ErrorValueWrapper();

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            logWrap.requestBody = requestBody;   

            if(requestBody == '' || requestBody == null) {
                errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_BODYCTT_EMPTY_ERROR);
                strCode = errWr.err_code;
                strMessage = errWr.err_msg;
                logWrap.ErrorCode = strCode;
                logWrap.ErrorText.add(strMessage);
            }else {

                Input input = (Input)JSON.deserialize(requestBody,  Input.class);

                if(String.isBlank(input.stDt) || String.isBlank(input.edDt)
                    || String.isBlank(input.pgNo)|| String.isBlank(input.dataCnt))
                {
                    // 필수 파라메터 누락
                    errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_RQMT_PARAM_ERROR);
                    strCode = errWr.err_code;
                    strMessage = errWr.err_msg;
                    strMessage = strMessage + ' 누락 항목 : [ ';
                    strMessage = String.isBlank(input.stDt) ? strMessage + 'stDt ,' : strMessage;
                    strMessage = String.isBlank(input.edDt) ? strMessage + 'edDt ,' : strMessage;
                    strMessage = String.isBlank(input.pgNo) ? strMessage + 'pgNo ,' : strMessage;
                    strMessage = String.isBlank(input.dataCnt) ? strMessage + 'dataCnt' : strMessage;
                    strMessage = strMessage + ' ]';
                    logWrap.ErrorCode = strCode;
                    logWrap.ErrorText.add(strMessage);
                } else {

                    Map<String, String> plClassServiceStatus = CommonUtil.getMapPickListLabel('ClassService__c', 'Status__c');
                    Map<String, String> plServiceContentRegion = CommonUtil.getMapPickListLabel('ServiceContents__c', 'Region__c');

                    
                    // 필수 파라메터가 있는 경우 
                    String titleLike = '%' + input.schttl + '%';
                    Date seatchStDt = IFN_Util.convertDate(input.stDt);
                    Date seatchEdDt = IFN_Util.convertDate(input.edDt);

                    //1. 조회조건에 페이징처리 수정 (ClassService__c -> ServiceContents__c)
                    String query_total = 'select Count() ' +
                    'from ServiceContents__c ' +
                    'where Name like  :titleLike ' +
                    'and OpenDate__c >= :seatchStDt ' +
                    'and OpenDate__c <= :seatchEdDt ';
                    Integer totalSize = Database.countQuery(query_total);

                    Integer limitSize = Integer.valueOf(input.dataCnt);
                    Integer pageNo = Integer.valueOf(input.pgNo) -1;
                    Integer offsetNum = (limitSize * pageNo);

                    //2. 데이터 리스트 오브젝트 수정
                    List<ServiceContents__c> datalist2 = [select id
                                ,Name
                                ,Category__c
                                ,Region__c
                                ,Instructor__r.Name
                                ,Instructor2__r.Name
                                ,OpenDate__c
                                from ServiceContents__c
                                where Name like  :titleLike
                                and OpenDate__c >= :seatchStDt
                                and OpenDate__c <= :seatchEdDt
                                and IsUsage__c = true
                                Limit :limitSize offset :offsetNum
                    ];
                    String chkMdmCd = String.isBlank(input.mdmCd) ? 'N' : input.mdmCd; 
                    List<ClassService__c> datalist = [select id, Status__c
                                ,MDMCode__c
                                ,ServiceContent__c
                                from ClassService__c
                                where ServiceContent__r.Name like  :titleLike
                                and ServiceContent__r.OpenDate__c >= :seatchStDt
                                and ServiceContent__r.OpenDate__c <= :seatchEdDt
                                and ServiceContent__r.IsUsage__c = true
                                and MDMCode__c = :chkMdmCd
                    ];
                    //3. 이중반복문으로 classservice에 mdm이랑 컨텐츠아이디가 같을경우만 스테이터스값과 클레스서비스아이디 추가
                    List<DataList> listitem = new List<DataList>();
                    for(ServiceContents__c itm2 : datalist2){
                        System.debug(itm2.Name);
                        DataList oitm = new DataList();
                        oitm.tp     = itm2.Category__c;
                        oitm.ttl	= itm2.Name;
                        oitm.rgNm	= String.isBlank(itm2.Region__c) ? '' : plServiceContentRegion.get(itm2.Region__c) ;
                        oitm.rgCd	= itm2.Region__c;
                        oitm.istrt1	= itm2.Instructor__r.Name;
                        oitm.istrt2	= itm2.Instructor2__r.Name;
                        oitm.opDt	= IFN_Util.converDateTimeToStrFormat(itm2.OpenDate__c);
                        oitm.cttId	= itm2.Id;
                        oitm.stts	= '-';
                        oitm.csId	= '';
                        for (ClassService__c itm : datalist) {
                            
                            // 전달된 MDM 코드와 같은 경우만 상태값 전송
                            // 전달된 contentId와 같은 경우만 상태값 및 classService아이디값 전송
                            if(itm.ServiceContent__c == itm2.Id){
                                oitm.stts	= plClassServiceStatus.get(itm.Status__c);
                                oitm.csId	= itm.Id;
                            }
                            /*
                            if('N'.equals(chkMdmCd)) {
                                oitm.stts	= '-';
                            } else {
                                oitm.stts	= chkMdmCd.equals(itm.MDMCode__c) ?  
                                            (String.isBlank(itm.Status__c) ? '-' : plClassServiceStatus.get(itm.Status__c)) : '-';
                                oitm.csId	= itm.Id;
                            }
                            */
                        }
                        listitem.add(oitm);
                    }

                    resData resppnseData = new resData();
                    resppnseData.totDataCnt = String.valueOf(totalSize);
                    resppnseData.listitem = listitem;
                    resppnseData.pgNo = input.pgNo;                    
                    objOutput.response = resppnseData;
                    logWrap.ResponseBody = Json.serialize(resppnseData);
                }

            }
        } catch(Exception e) {
            errWr = IFN_CMM_ERRUTIL.GET_ERRORINFO_BYERRORKEY('COMMON', IFN_CMM_ERRUTIL.ERRKEY_SERVER_ERROR);
            strCode = errWr.err_code;
            strMessage = errWr.err_msg;
            strMessage +=  '[' + e.getMessage()+' Line : '+e.getLineNumber() + ']';
            logWrap.ErrorCode = strCode;
            logWrap.ErrorText.add(strMessage);
        }

        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strMessage;
        logWrap.ResponseBody = Json.serialize(objOutput);
        commlog.insertLog(logWrap);

        return objOutput;
        
    }


}