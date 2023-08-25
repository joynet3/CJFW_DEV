/*
* ==================================================================================
*   File Name   : FlowRepository.cls
*   Author      : Minje.kim
*   Date        : 2022.08.03
*   Tester      : FlowRepository_test.cls
*   Description : Flow 에서 사용하는 공통 함수 저장소
*   Modification Log
* ==================================================================================
*   Ver     Date          Author          Modification
* ==================================================================================
*   1.0     2022.08.03    Minje.kim       Create
* ==================================================================================
*/
public with sharing class FlowRepository {

    // @InvocableMethod(label='sumEventDescription')
    // public static List<String> sumEventDescription(List<Id> listTargetId) {

    //     List<String> listResult = new List<String>();
    //     String DescriptionSum = '';

    //     try{
    //         List<Event> listEvent = new List<Event>();
    //         listEvent = [SELECT  Id, Description
    //                         FROM  Event 
    //                         WHERE   Id IN: listTargetId ];

    //         if(!listEvent.isEmpty()){
    //             List<String> listDescription = new List<String>();
    //             for(Event objEvent : listEvent){
    //                 listDescription.add(objEvent.Description);
    //             }
    //             DescriptionSum = String.join(listDescription, '\n-----\n');
    //         }
    //         listResult.add(DescriptionSum);
    //     } 
    //     catch(Exception e){
    //         system.debug('FlowRepository EventDescriptionSum error : ' + e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');    
    //     }
    //     return listResult;
    // }

    @InvocableMethod(label='getLineBreak')
    public static List<String> getLineBreak() {
        List<String> listResult = new List<String>();
        listResult.add('\n');
        return listResult;
    }
}