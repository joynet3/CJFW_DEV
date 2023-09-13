/**
* SolutionInquiryNotiHandler_Test
*
*@group  test
*@author 조형준
*@since 2023-08-16  내용 작성
*/
@isTest
public with sharing class SolutionInquiryNotiHandler_Test {
    @TestSetup
    static void makeData(){
        
        //솔루션
        PartnerCompany__c pc = new PartnerCompany__c(
            Name = 'test'
            , ManagerEmail__c = 'test@test.com'
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

        Account acc = new Account(
            Name = 'test'
            , CompanyRegisterNumber__c = 'test'
            , Address__c = 'test'
            , AddressDetails__c = 'test'
            , LocationStateProvince__c = '11'
            , LocationState__c = '11000'
            , Phone = '01012345678'
            , CustomerStatus__c = '01'
        );
        Insert acc;

        //상품관리
        Brochure__c brochure = new Brochure__c(
            Name = 'test'
            , issueDate__c = Date.today()
            , BrochureGroup__c = bg.Id
        );
        Insert brochure;

        Lead lead = new Lead(
            LastName = 'test'
            , Company = 'test'
            , CompanyRegisterNumber__c = 'test'
            , Email = 'test@test.com'
        );
        Insert lead;

        SolutionMapping__c sm = new SolutionMapping__c(
            Lead__c = lead.Id
            , Solution__c = sol.Id
        );
        Insert sm;
    }

    @isTest
    static void manuFactureNoti_Test(){
        SolutionMapping__c sm = [SELECT Id FROM SolutionMapping__c LIMIT 1];
        SolutionInquiryNotiHandler sh = new SolutionInquiryNotiHandler();
        sh.manuFactureNoti(sm.Id);
    }
}