/**
 * @description       : 
 * @author            : admin@vatech.com.dev
 * @group             : 
 * @last modified on  : 01-29-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class CommonUtil_test {
    @testSetup 
    public static void setup(){
    }

    @isTest 
    static void itShould() {
        Test.startTest();

        CommonUtil.getFieldSet('ActivityReport__c', 'ActivityReportTracking');
        CommonUtil.getFieldSetForAPIName('ActivityReport__c', 'ActivityReportTracking');
        CommonUtil.getMapPickListActive('Account', 'AccountSource');
        CommonUtil.getMapPickListLabeltoValue('Account', 'AccountSource');
        CommonUtil.getMapPickListValuetoLabel('Account', 'AccountSource');

        CommonUtil.WrapperPicklistEntry obj = new CommonUtil.WrapperPicklistEntry();
        System.debug(obj.active);
        System.debug(obj.defaultValue);
        System.debug(obj.label);
        System.debug(obj.value);
        System.debug(obj.validFor);


        User objUser = [
            SELECT  Id, EmployeeNumber, HeadOffice__c, SU__c, Team__c
            FROM    User
            WHERE   Id =: UserInfo.getUserId()
        ];

        CommonUtil.findObjectNameFromRecordIdPrefix(objUser.Id);
        CommonUtil.getDependentPicklistValues(User.Team__c);
        CommonUtil.getPickListValues('Order_D__c', 'WERKS__c', false);
        CommonUtil.getPickListValues('Order_D__c', 'WERKS__c', true);
        CommonUtil.getMapPickList('Order_D__c', 'WERKS__c');
        CommonUtil.getMapPickListLabel('Order_D__c', 'WERKS__c');
        CommonUtil.getDecimalCommaFormat((Decimal.valueOf(1000)/1024/1024).setScale(2));
        
        CommonUtil.getPhoneFormat('03112345678', false);
        CommonUtil.getPhoneFormat('0311234567', false);
        CommonUtil.getPhoneFormat('0212345678', false);
        CommonUtil.getPhoneFormat('021234567', false);
        CommonUtil.getPhoneFormat('16008080', false);

        Decimal decTest = 1.5;
        CommonUtil.nulltoBlank(decTest);

        Integer intTest = 1;
        CommonUtil.nulltoBlank(intTest);

        String strTest = 'test';
        CommonUtil.nulltoBlank(strTest);

        Date dtDate = Date.today();
        CommonUtil.nulltoBlank(dtDate);

    }
}