/**
* DE_SolutionController_Test
*
*@group  test
*@author 조형준
*@since 2023-08-16  내용 작성
*/
@isTest
public with sharing class DE_SolutionController_Test {
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
    static void getAreaCategory_Test(){
        DE_SolutionController.getAreaCategory();
    }

    @isTest
    static void getFunctionCategory_Test(){
        DE_SolutionController.getFunctionCategory();
    }

    @isTest
    static void getServiceTags_Test(){
        DE_SolutionController.getServiceTags('ALL', 'ALL');
    }

    @isTest
    static void getFilterSolutions_Test(){
        ServiceTag__c st = [SELECT Id FROM ServiceTag__c LIMIT 1];

        DE_SolutionController.getFilterSolutions('ALL', 'ALL', new List<String>{st.Id}, true, 'date', 'food');
        DE_SolutionController.getFilterSolutions('ALL', 'ALL', new List<String>{st.Id}, true, 'views', 'school');
        DE_SolutionController.getFilterSolutions('ALL', 'ALL', new List<String>{st.Id}, true, 'views', 'food');
        DE_SolutionController.getFilterSolutions('ALL', 'ALL', new List<String>{st.Id}, true, 'alphabet', 'school');
        DE_SolutionController.getFilterSolutions('ALL', 'ALL', new List<String>{st.Id}, false, 'alphabet', 'school');
    }

    @isTest
    static void getSolutions_Test(){
        DE_SolutionController.getSolutions('partner', 'date', 'food');
        DE_SolutionController.getSolutions('partner', 'views', 'school');
        DE_SolutionController.getSolutions('partner', 'views', 'food');
        DE_SolutionController.getSolutions('partner', 'alphabet', 'food');
        DE_SolutionController.getSolutions('cjfreshway', 'alphabet', 'food');
    }

    @isTest
    static void getProperSolutions_Test(){
        Solution__c sol = [SELECT Id, Name FROM Solution__c LIMIT 1];

        //노출 기간 시작만
        sol.VisibleStartDatetime__c = System.now().addDays(-1);
        Update sol;
        DE_SolutionController.getProperSolutions('date', 'food');
        //노출 기간 종료만
        sol.VisibleStartDatetime__c = null;
        sol.VisibleEndDatetime__c = System.now().addDays(1);
        Update sol;
        DE_SolutionController.getProperSolutions('views', 'school');
        //노출 기간 시작,종료
        sol.VisibleStartDatetime__c = System.now().addDays(-1);
        sol.VisibleEndDatetime__c = System.now().addDays(1);
        Update sol;
        DE_SolutionController.getProperSolutions('views', 'food');
        DE_SolutionController.getProperSolutions('alphabet', 'food');
    }

    @isTest
    static void getSolution_Test(){
        Solution__c sol = [SELECT Id, Name FROM Solution__c LIMIT 1];

        DE_SolutionController.getSolution(sol.Id);
    }

    @isTest
    static void updateSolutionViews_Test(){
        Solution__c sol = [SELECT Id, Name FROM Solution__c LIMIT 1];

        DE_SolutionController.updateSolutionViews(sol.Id, 'food');
        DE_SolutionController.updateSolutionViews(sol.Id, 'school');
    }
}