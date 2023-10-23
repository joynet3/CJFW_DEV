/**
 * @Class : IFN_EIF1003_RE001_MD001_ba.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023.09.13
 * @Version : 1.0
 * @Description : Remember 명함 데이터 리드등록 - 배치
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.13 | 박지오         | 최초작성
 *  2. | 2023.10.12 | 박지오         | 코드수정 - 레코드타입 아이디를 하드코딩에서 디비에서 가져오도록 수정.
 * */
public with sharing class IFN_EIF1003_RE001_MD001_ba implements Database.Batchable<IFN_EIF1003_RE001_MD001.Stack>, Database.Stateful, Database.AllowsCallouts {

    List<IFN_EIF1003_RE001_MD001.Stack> rememberStacks = new List<IFN_EIF1003_RE001_MD001.Stack>();

    public IFN_EIF1003_RE001_MD001_ba(List<IFN_EIF1003_RE001_MD001.Stack> rememberStacks) {
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
        try {
            List <Lead> rememberLeads = new List<Lead>();
            String rememberLeadName = 'RememberLead';

            for (IFN_EIF1003_RE001_MD001.Stack stack : scope) {
                User user;
                RecordType recordType;
                try {
                    user = [SELECT Id, CompanyName, Department, Email FROM User WHERE Email = :stack.main_card.user.email ORDER BY CreatedDate DESC LIMIT 1];   // 이메일이 중복되는 아이디가 있을시 가장 마지막에 등록된 유저 하나만 가져온다.
                    recordType = [SELECT Id FROM RecordType WHERE Name = :rememberLeadName ORDER BY CreatedDate DESC LIMIT 1];                                  // RecordType - RememberLead RecordTypeId.
                    Lead rememberLead = new Lead(
                            LastName = stack.main_card.name,
                            RecordTypeId = recordType.Id,
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