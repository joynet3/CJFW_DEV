/**
 * @description       : 카테고리를 선택해 파일을 저장할 수 있는 component
 * @author            : seol.kim@dkbmc.com
 * @since 08-25-2023  내용 작성
 * @group             : 
 * @last modified on  : 08-25-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
global class CategoryPicklist extends VisualEditor.DynamicPickList{

    //선택목록 기본 값
    global override VisualEditor.DataRow getDefaultValue(){
        
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Category', 'Category');
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