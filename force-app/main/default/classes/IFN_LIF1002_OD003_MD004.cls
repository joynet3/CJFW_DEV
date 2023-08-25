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
 * */
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

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            logWrap.requestBody = requestBody;   

            if(requestBody == '' || requestBody == null) {
                strCode = IFN_Util.STATUS_BODYCTT_EMPTY_ERROR.split(':')[0];
                strMessage = IFN_Util.STATUS_BODYCTT_EMPTY_ERROR.split(':')[1];
                logWrap.ErrorCode = strCode;
                logWrap.ErrorText.add(strMessage);
            }else {

                Input input = (Input)JSON.deserialize(requestBody,  Input.class);

                if(String.isBlank(input.stDt) || String.isBlank(input.edDt)
                    || String.isBlank(input.pgNo)|| String.isBlank(input.dataCnt))
                {
                    // 필수 파라메터 누락
                    strCode = IFN_Util.STATUS_RQMT_PARAM_ERROR.split(':')[0];
                    strMessage = IFN_Util.STATUS_RQMT_PARAM_ERROR.split(':')[1];
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


                    String query_total = 'select Count() ' +
                    'from ClassService__c ' +
                    'where ServiceContent__r.Name like  :titleLike ' +
                    'and ServiceContent__r.OpenDate__c >= :seatchStDt ' +
                    'and ServiceContent__r.OpenDate__c <= :seatchEdDt ';
                    System.debug('>>>>>>>>>>>>> ' + query_total);
                    Integer totalSize = Database.countQuery(query_total);
                    System.debug(totalSize);

                    Integer limitSize = Integer.valueOf(input.dataCnt);
                    Integer pageNo = Integer.valueOf(input.pgNo) -1;
                    Integer offsetNum = (limitSize * pageNo);

                    
                    List<ClassService__c> datalist = [select id, Status__c
                                ,ServiceContent__r.Id
                                ,ServiceContent__r.Name
                                ,ServiceContent__r.Category__c
                                ,ServiceContent__r.Region__c
                                ,ServiceContent__r.Instructor__r.Name
                                ,ServiceContent__r.Instructor2__r.Name
                                ,ServiceContent__r.OpenDate__c
                                ,MDMCode__c
                                from ClassService__c
                                where ServiceContent__r.Name like  :titleLike
                                and ServiceContent__r.OpenDate__c >= :seatchStDt
                                and ServiceContent__r.OpenDate__c <= :seatchEdDt
                                Limit :limitSize offset :offsetNum
                    ];

                    List<DataList> listitem = new List<DataList>();
                    String chkMdmCd = String.isBlank(input.mdmCd) ? 'N' : input.mdmCd; 
                    for (ClassService__c itm : datalist) {
                        System.debug(itm.ServiceContent__r.Name);
                        DataList oitm = new DataList();
                        oitm.tp     = itm.ServiceContent__r.Category__c;
                        oitm.ttl	= itm.ServiceContent__r.Name;
                        oitm.rgNm	= String.isBlank(itm.ServiceContent__r.Region__c) ? '' : plServiceContentRegion.get(itm.ServiceContent__r.Region__c) ;
                        oitm.rgCd	= itm.ServiceContent__r.Region__c;
                        oitm.istrt1	= itm.ServiceContent__r.Instructor__r.Name;
                        oitm.istrt2	= itm.ServiceContent__r.Instructor2__r.Name;
                        oitm.opDt	= IFN_Util.converDateTimeToStrFormat(itm.ServiceContent__r.OpenDate__c);
                        oitm.cttId	= itm.ServiceContent__r.Id;
                        // 전달된 MDM 코드와 같은 경우만 상태값 전송
                        if('N'.equals(chkMdmCd)) {
                            oitm.stts	= '-';
                        } else {
                            oitm.stts	= chkMdmCd.equals(itm.MDMCode__c) ?  
                                        (String.isBlank(itm.Status__c) ? '-' : plClassServiceStatus.get(itm.Status__c)) : '';

                        }
                        
                        oitm.csId	= itm.Id;
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
            strCode = IFN_Util.STATUS_EXCEPT.split(':')[0];
            strMessage = IFN_Util.STATUS_EXCEPT.split(':')[1];
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