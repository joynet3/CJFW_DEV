/**
 * @Class : IFN_EIF1003_RE001_MD002_Batch.cls
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
public with sharing class IFN_EIF1003_RE001_MD002_Batch implements Database.Batchable<IFN_EIF1003_RE001_MD001.Stack>, Database.Stateful, Database.AllowsCallouts {

    String interfaceId = 'IFN_EIF1003_RE001_MD002_Batch';
    List<IFN_EIF1003_RE001_MD001.Stack> rememberStacks = new List<IFN_EIF1003_RE001_MD001.Stack>();

//    IFMaster__c ifMasterObj = [SELECT Id, Name, ContentType__c, Endpoint__c, Method__c FROM IFMaster__c WHERE Name = :interfaceId];

    public IFN_EIF1003_RE001_MD002_Batch(List<IFN_EIF1003_RE001_MD001.Stack> rememberStacks) {
        this.rememberStacks = rememberStacks;
    }

    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;


    /***********************************************************************************************************
    *  Bacth   : start
    *  내용    : 리멤버 명함첩 전체 데이터 리턴
    ************************************************************************************************************/
    public Iterable<IFN_EIF1003_RE001_MD001.Stack> start(Database.BatchableContext bc) {
        return rememberStacks;
    }
    /***********************************************************************************************************
    *  Bacth   : execute
    *  내용    : 리멤버 데이터 리드에 등록
    ************************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<IFN_EIF1003_RE001_MD001.Stack> scope) {
        Map<String, List<IFN_EIF1003_RE001_MD001.Stack>> userStackGroup = new Map<String, List<IFN_EIF1003_RE001_MD001.Stack>>();
        try {
            List <Lead> rememberLeads = new List<Lead>();
            for (IFN_EIF1003_RE001_MD001.Stack stack : scope) {
                User user;
                try {
                    user = [SELECT Id, CompanyName, Department, Email FROM User WHERE Email = :stack.main_card.user.email ORDER BY CreatedDate DESC LIMIT 1];
                    Lead rememberLead = new Lead(
                            LastName = stack.main_card.name,
                            RecordTypeId = '0120w0000022e4uAAA',
                            Company = stack.main_card.company,
                            MobilePhone = formatPhoneNumber(stack.main_card.mobile.national_number),
                            OwnerId = user.Id

                    );
                    rememberLeads.add(rememberLead);
                } catch (System.QueryException e) {
                    logWrap.ErrorText.add(e.getMessage());
                    System.debug('[' + stack.main_card.user.email + ']' + '해당 이메일이 등록된 사용자가 없습니다.');
                }
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

        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber() + e.getMessage() + e.getStackTraceString());
            this.logWrap.Status = 'ERROR';
        }
    }
    public void finish(Database.BatchableContext bc) {
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