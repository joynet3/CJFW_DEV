@IsTest
public class EDMSFileListView_test {
@TestSetup
static void EDMSFileListView_testSetUp() {
    try{
        EDMSFile__c obj = new EDMSFile__c();
        obj.Name = 'test';
        obj.DownloadURL__c = 'test.com';
        obj.Status__c = 'Success';
        obj.Type__c = '1';
        obj.TargetId__c = 'testTargetId';
        insert obj;

    } catch (Exception e) {
        System.debug('EDMSFileListView_test line : ' + e.getLineNumber());
        System.debug('EDMSFileListView_test message : ' + e.getMessage());
        System.debug('EDMSFileListView_test cause : ' + e.getCause());
    }
}

@IsTest
static void EDMSFileListView_test() {
    Test.startTest();
    System.debug(EDMSFileListView.getDataTable('testTargetId'));
    System.debug(EDMSFileListView.getDataTable(null));
    Test.stopTest();
}
}