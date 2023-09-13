/**
* DE_CommunityBoardController_Test
*
*@group  test
*@author 조형준
*@since 2023-08-16  내용 작성
*/
@isTest
public with sharing class DE_CommunityBoardController_Test {
    @TestSetup
    static void makeData(){
        CommunityGroupDetail__c cg = new CommunityGroupDetail__c(
            Name = 'test'
            , CommunityURL__c = 'test'
        );
        Insert cg;

        CommunityBoard__c cb = new CommunityBoard__c(
            Name = 'test'
            , Content__c = 'test'
            , CommunityGroupDetail__c = cg.Id
        );
        Insert cb;
    }

    @isTest
    static void getBoards_Test(){
        //검색 값 유
        DE_CommunityBoardController.getBoards('test', 'test');
        //겂색 값 무
        DE_CommunityBoardController.getBoards('test', '');
    }

    @isTest
    static void getBoard_Test(){
        CommunityBoard__c cb = [SELECT Id FROM CommunityBoard__c LIMIT 1];

        DE_CommunityBoardController.getBoard(cb.Id);
    }

    @isTest
    static void updateCommunityBoardViews_Test(){
        CommunityBoard__c cb = [SELECT Id FROM CommunityBoard__c LIMIT 1];

        DE_CommunityBoardController.updateCommunityBoardViews(cb.Id);
    }
}