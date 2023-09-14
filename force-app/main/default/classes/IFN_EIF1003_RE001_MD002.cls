/**
 * @Class : IFN_EIF1003_RE001_MD002.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023.09.13
 * @Version : 1.0
 * @Description : 리멤버 명함데이터 리드등록 - 배치
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.13 | 박지오         | 최초작성
 * */
global with sharing class IFN_EIF1003_RE001_MD002 implements Database.Batchable<IFN_EIF1003_RE001_MD001.Stack>, Database.Stateful, Database.AllowsCallouts {

    String interfaceId = 'IFN_EIF1003_RE001_MD002';

    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = :interfaceId];

    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;

    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 리멤버 명함첩 전체 데이터
    ************************************************************************************************************/
    global Iterable<IFN_EIF1003_RE001_MD001.Stack> start(Database.BatchableContext bc) {
        IFN_EIF1003_RE001_MD001 RE001 = new IFN_EIF1003_RE001_MD001();
        IFN_EIF1003_RE001_MD001.RE001RequestWrapper request = new IFN_EIF1003_RE001_MD001.RE001RequestWrapper();
        List<IFN_EIF1003_RE001_MD001.Stack> rememberStacks = new List<IFN_EIF1003_RE001_MD001.Stack>();

        request.page = 1;

        RE001.param = request;

        IFN_CalloutResult getRemember = RE001.callout();

        if ('S'.equals(getRemember.result)) {
            IFN_EIF1003_RE001_MD001.RE001SuccessWrapper response = (IFN_EIF1003_RE001_MD001.RE001SuccessWrapper) getRemember.response;
            rememberStacks.addAll(response.stacks);
            if (response.metainfo.total_pages > 0) {
                for (Integer i = 2; i <= response.metainfo.total_pages; i++) {
                    request.page = i;
                    RE001.param = request;
                    getRemember = RE001.callout();
                    response = (IFN_EIF1003_RE001_MD001.RE001SuccessWrapper) getRemember.response;
                    rememberStacks.addAll(response.stacks);
                }
            }
        }
        return rememberStacks;
    }
    /***********************************************************************************************************
*  Bacth   : excute
*  내용    : 리멤버 데이터 리드에 등록
************************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<IFN_EIF1003_RE001_MD001.Stack> scope) {
        Map<String, List<IFN_EIF1003_RE001_MD001.Stack>> userStackGroup = new Map<String, List<IFN_EIF1003_RE001_MD001.Stack>>();
        try {
            for (IFN_EIF1003_RE001_MD001.Stack stack : scope) {
                if (!userStackGroup.containsKey(stack.main_card.email)) {
                    userStackGroup.put(stack.main_card.user.email, new List<IFN_EIF1003_RE001_MD001.Stack>());
                }
                userStackGroup.get(stack.main_card.user.email).add(stack);
            }
            for (String userEmail : userStackGroup.keySet()) {
                List <Lead> rememberLeads = new List<Lead>();
                User user = [SELECT Id, CompanyName, Department, Email FROM User WHERE Email = :userEmail ORDER BY CreatedDate DESC LIMIT 1];

                List<IFN_EIF1003_RE001_MD001.Stack> stacks = userStackGroup.get(userEmail);
                for (IFN_EIF1003_RE001_MD001.Stack stack : stacks) {
                    Lead rememberLead = new Lead(
                            LastName = stack.main_card.name,
                            RecordTypeId = '0120w0000022e4uAAA',
                            Company = stack.main_card.company,
                            MobilePhone = formatPhoneNumber(stack.main_card.mobile.national_number),
                            OwnerId = user.Id
                    );
                    rememberLeads.add(rememberLead);
                }
                Database.SaveResult[] results = Database.insert(rememberLeads, false);
                for (Database.SaveResult res : results) {
                    if (!res.isSuccess()) {
                        for (Database.Error err : res.getErrors()) {
                            logWrap.ErrorCode = String.valueOf(err.getStatusCode());
                            logWrap.ErrorText.add(err.getMessage());
                            logWrap.ErrorText.add(String.valueOf(err.getFields()));
                        }
                    }
                }
            }
        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber()+e.getMessage() + e.getStackTraceString());
            this.logWrap.Status = 'ERROR';
        }
    }
    global void finish(Database.BatchableContext bc) {
        System.debug('batch finish start ====================');
    }
    public static String formatPhoneNumber(String phoneNumber) {
        String cleanedNumber = phoneNumber.replaceAll('[^0-9]', '');
        if (cleanedNumber.length() == 10) {
            return cleanedNumber.substring(0, 3) + '-' + cleanedNumber.substring(3, 6) + '-' + cleanedNumber.substring(6, 10);
        } else if (cleanedNumber.length() == 11) {
            return cleanedNumber.substring(0, 3) + '-' + cleanedNumber.substring(3, 7) + '-' + cleanedNumber.substring(7, 11);
        }
        return phoneNumber;
    }
}