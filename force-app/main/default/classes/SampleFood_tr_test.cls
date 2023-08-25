/**
 * Created by kw on 2023-01-29.
 */

@IsTest
private class SampleFood_tr_test {
    @IsTest
    static void SampleFood_tr_test() {
        Event objEvent1 = new Event();
        objEvent1.StartDateTime = Datetime.valueOf('2022-01-01 09:00:00');
        objEvent1.DurationInMinutes = 2;
        objEvent1.VehicleRefuelingCosts__c = 2000;
        insert objEvent1;

        SampleFood__c objSampleFood = new SampleFood__c();
        objSampleFood.Name = 'test';
        objSampleFood.ActivityInfo__c = 'test SampleFood';
        objSampleFood.StartDateTime__c = Datetime.now();
        objSampleFood.EndDateTime__c = Datetime.now()+1;
        objSampleFood.WorkType__c = '외근';
        objSampleFood.LinkedRecordId__c = objEvent1.Id;
        objSampleFood.SalesStage__c = '시식 시행';
        insert objSampleFood;
        Test.startTest();
        objSampleFood.Name = 'test1';
        update objSampleFood;
        delete objSampleFood;

        Test.stopTest();
    }
}