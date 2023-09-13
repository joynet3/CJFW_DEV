/**
* DE_MainController_Test
*
*@group  test
*@author 조형준
*@since 2023-08-16  내용 작성
*/
@isTest
public with sharing class DE_MainController_Test {
    @TestSetup
    static void makeData(){
        
        //솔루션
        PartnerCompany__c pc = new PartnerCompany__c(
            Name = 'test'
        );
        Insert pc;

        Solution__c sol = new Solution__c(
            Name = 'test'
            , AreaCategory__c = 'A01;A02;A03;A04'
            , FunctionCategory__c = 'F01;F02;F03;F04'
            , PartnerCompany__c = pc.Id
        );
        Insert sol;

        ServiceTag__c st = new ServiceTag__c(
            Name = 'test'
            , isActive__c = true
        );
        Insert st;

        ServiceTagMapping__c stm = new ServiceTagMapping__c(
            Solution__c = sol.Id
            , ServiceTag__c = st.Id
        );
        Insert stm;

        //메뉴
        SolutionGroup__c sg = new SolutionGroup__c(
            Name = 'test'
            , SiteDivision__c = 'common'
            , Position__c = 1
            , isActive__c = true
            , CommunityURL__c = 'test'
        );
        Insert sg;

        BrochureGroup__c bg = new BrochureGroup__c(
            Name = 'test'
            , SiteDivision__c = 'common'
            , Position__c = 1
            , isActive__c = true
            , CommunityURL__c = 'test'
        );
        Insert bg;

        CommunityGroup__c cg = new CommunityGroup__c(
            Name = 'test'
            , SiteDivision__c = 'common'
            , Position__c = 1
            , isActive__c = true
            , CommunityURL__c = 'test'
        );
        Insert cg;

        InqueryGroup__c ig = new InqueryGroup__c(
            Name = 'test'
            , SiteDivision__c = 'common'
            , Position__c = 1
            , isActive__c = true
            , CommunityURL__c = 'test'
        );
        Insert ig;

        //커뮤니티
        CommunityGroupDetail__c cgd = new CommunityGroupDetail__c(
            Name = 'test'
            , SiteDivision__c = 'common'
            , Position__c = 1
            , CommunityURL__c = 'test'
            , CommunityGroup__c = cg.Id
            , isActive__c = true
        );
        Insert cgd;

        CommunityBoard__c cb = new CommunityBoard__c(
            Name = 'test'
            , Content__c = 'test'
            , CommunityGroupDetail__c = cgd.Id
            , isMainVisible__c = true
        );
        Insert cb;
    }

    @isTest
    static void getMainBoards_Test(){
        //노출 기간 x
        DE_MainController.getMainBoards('test');

        CommunityBoard__c cb = [SELECT Id, Name FROM CommunityBoard__c LIMIT 1];

        //노출 기간 시작만
        cb.VisibleStartDatetime__c = System.now().addDays(-1);
        Update cb;
        DE_MainController.getMainBoards('test');
        //노출 기간 종료만
        cb.VisibleStartDatetime__c = null;
        cb.VisibleEndDatetime__c = System.now().addDays(1);
        Update cb;
        DE_MainController.getMainBoards('test');
        //노출 기간 시작,종료
        cb.VisibleStartDatetime__c = System.now().addDays(-1);
        cb.VisibleEndDatetime__c = System.now().addDays(1);
        Update cb;
        DE_MainController.getMainBoards('test');
    }

    @isTest
    static void getBannerServiceTags_Test(){
        DE_MainController.getBannerServiceTags();
    }

    @isTest
    static void getGlobalSearch_Test(){
        DE_MainController.getGlobalSearch('test');
    }

    @isTest
    static void getMenuItems_Test(){
        DE_MainController.getMenuItems('food');
    }
}