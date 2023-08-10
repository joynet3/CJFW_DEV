/**
 * @Class : IFN_LIF1002_OD003_NOF004.cls
 * @group Framework : 
 * @Author : 
 * @Date : 2023-08-09
 * @Version : 1.0
 * @Description : 
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.09 |  | 최초작성
 * */
@RestResource(urlMapping='/lif1002/od003/nof004')
global with sharing class IFN_LIF1002_OD003_NOF004 {
    global IFN_LIF1002_OD003_NOF004() {}

    global class Input {
        public String schttl {get;set;}
        public String stDt {get;set;}
        public String edDt {get;set;}
        public String dataCnt {get;set;}
        public String pgNo {get;set;}
        public String mdmCd {get;set;}
    }

    global class Output {
        public Integer totDataCnt{get;set;}
        public String pgNo{get;set;}
        public String err_cd{get;set;}
        public String err_msg_ctt{get;set;}
        public List<DataList> listitem{get;set;}
    }

    global class DataList {
        public String tp     {get;set;}
        public String ttl    {get;set;}
        public String rgNm   {get;set;}
        public String rgCd   {get;set;}
        public String istrt1 {get;set;}
        public String istrt2 {get;set;}
        public Date opDt   {get;set;}
        public String stts   {get;set;}
        public String cttId  {get;set;}
        public String csId   {get;set;}
    }


    @HttpPost
    global static Output doPost() {
        String strCode = '0000';
        String strMessage = 'Success.';
        String interfaceId = 'IFN_LIF1002_OD003_NOF004';

        IFN_CommonLog.LogWrap logWrap = new IFN_CommonLog.logWrap(interfaceId, 'Real');
        IFN_CommonLog commlog = new IFN_CommonLog();

        Output objOutput = new Output();
        
        String requestBody = '';

        try {
            RestRequest request = RestContext.request;
            requestBody = request.requestBody.toString();
            logWrap.requestBody = requestBody;   

            if(requestBody == '' || requestBody == null) {
                strCode = IFN_Util.STATUS_PARAMETER_ERROR.split(':')[0];
                strMessage = IFN_Util.STATUS_PARAMETER_ERROR.split(':')[1];
                logWrap.ErrorCode = strCode;
                logWrap.ErrorText.add(strMessage);
            }else {

                Map<String, String> plClassServiceStatus = CommonUtil.getMapPickListLabel('ClassService__c', 'Status__c');
                Map<String, String> plServiceContentRegion = CommonUtil.getMapPickListLabel('ServiceContent__c', 'Region__c');

                Input input = (Input)JSON.deserialize(requestBody,  Input.class);
                //System.debug(plClassService.get('H'));
                String titleLike = '%' + input.schttl + '%';
                Date seatchStDt = IFN_Util.convertDate(input.stDt);
                Date seatchEdDt = IFN_Util.convertDate(input.edDt);


                String query_total = 'select Count() ' +
                'from ClassService__c ' +
                'where ServiceContent__r.Name like  :titleLike' +
                'and ServiceContent__r.OpenDate__c >= :seatchStDt' +
                'and ServiceContent__r.OpenDate__c <= :seatchStDt';
                Integer totalSize = Database.countQuery(query_total);
                System.debug(totalSize);


                
                List<ClassService__c> datalist = [select id, Status__c
                            ,ServiceContent__r.Id
                            ,ServiceContent__r.Name
                            ,ServiceContent__r.Category__c
                            ,ServiceContent__r.Region__c
                            ,ServiceContent__r.Instructor__c
                            ,ServiceContent__r.Instructor2__c
                            ,ServiceContent__r.OpenDate__c
                            ,MDMCode__c
                            from ClassService__c
                            where ServiceContent__r.Name like  :titleLike
                            and ServiceContent__r.OpenDate__c >= :seatchStDt
                            and ServiceContent__r.OpenDate__c <= :seatchStDt
                ];

                List<DataList> listitem = new List<DataList>();
                for (ClassService__c itm : datalist) {
                    System.debug(itm.ServiceContent__r.Name);
                    DataList oitm = new DataList();
                    oitm.tp     = itm.ServiceContent__r.Category__c;
                    oitm.ttl	= itm.ServiceContent__r.Name;
                    oitm.rgNm	= String.isBlank(itm.ServiceContent__r.Region__c) ? '' : plServiceContentRegion.get(itm.ServiceContent__r.Region__c) ;
                    oitm.rgCd	= itm.ServiceContent__r.Region__c;
                    oitm.istrt1	= itm.ServiceContent__r.Instructor__c;
                    oitm.istrt2	= itm.ServiceContent__r.Instructor2__c;
                    oitm.opDt	= itm.ServiceContent__r.OpenDate__c;
                    oitm.cttId	= itm.ServiceContent__r.Id;
                    oitm.stts	= String.isBlank(itm.Status__c) ? '-' : plClassServiceStatus.get(itm.Status__c);
                    oitm.csId	= itm.Id;
                    listitem.add(oitm);
                }

                objOutput.err_cd = strCode;
                objOutput.err_msg_ctt = strMessage;
                objOutput.totDataCnt = totalSize;
                objOutput.listitem = listitem;
                objOutput.pgNo = input.pgNo;

            }
        } catch(Exception e) {
            strCode = '-1';
            strMessage = e.getMessage()+' Line : '+e.getLineNumber();                       
            logWrap.ErrorCode = strCode;
            logWrap.ErrorText.add(strMessage);
        }

        objOutput.err_cd = strCode;
        objOutput.err_msg_ctt = strMessage;
        commlog.insertLog(logWrap);

        return objOutput;
        
    }


}