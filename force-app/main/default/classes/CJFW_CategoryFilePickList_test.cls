/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-11-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
@isTest
public with sharing class CJFW_CategoryFilePickList_test {

    
        @isTest
        static void testGetDefaultValue() {
            // Test.startTest()로 시작
            Test.startTest();
    
            CJFW_CategoryFilePickList pickList = new CJFW_CategoryFilePickList();
    
            // getDefaultValue 메서드를 호출하여 기본값을 가져옵니다.
            VisualEditor.DataRow defaultValue = pickList.getDefaultValue();
    
            // 기본값을 확인합니다.
            System.assertEquals('Category 1', defaultValue.getLabel(), '기본값 레이블이 예상과 일치하지 않습니다.');
            System.assertEquals('Category 1', defaultValue.getValue(), '기본값 값이 예상과 일치하지 않습니다.');
    
            // Test.stopTest()로 종료
            Test.stopTest();
        }
    

    
}