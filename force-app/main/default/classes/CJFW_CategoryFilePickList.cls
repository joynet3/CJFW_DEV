/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-18-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
global class CJFW_CategoryFilePickList extends VisualEditor.DynamicPickList{
    
    //선택목록 기본 값
    global override VisualEditor.DataRow getDefaultValue(){
        
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('파일', '파일');
        return defaultValue;
    }

    // 선택한 목록 생성
    global override VisualEditor.DynamicPickListRows getValues() {

        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        Schema.DescribeFieldResult fieldResult = ContentVersion.Category__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            VisualEditor.DataRow value = new VisualEditor.DataRow(pickListVal.getLabel(),pickListVal.getValue());
            myValues.addRow(value);
        }
        return myValues;
    }
}