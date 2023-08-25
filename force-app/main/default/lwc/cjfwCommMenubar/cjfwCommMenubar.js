/**
 * @description       : 매출/채권관리 OverView Container
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-22-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-04-2023   eunyoung.choi@dkbmc.com   Initial Version
 * 1.1   08-11-2023   eunyoung.choi@dkbmc.com   아코디언 제거 , 탭별 메뉴바 분리 
**/
import { LightningElement , track } from 'lwc';

export default class cjfwCommMenubar extends LightningElement {

    /* 탭 이름  */
    @track developer =false;
    @track CollateralLoan = false;                  // 담보여신
    @track SalesPerformanceClosingManage = false;   // 매출실적 마감관리
    @track SalesClosingManage =false;               // 매출마감관리
    @track Incentive = false;                       // 장려금
    @track TaxIssuance = false;                     // 세금계산서
    @track DebentureBalanceManage = false;          // 채권 여신 잔고 관리
    @track ChainSalesFeeManage =false;              // 체인 판매수수료 관리 

    /* 컴포넌트별 모달 */
    @track showSalesLedger = false;
    @track showOtherSales = false;
    @track showAccountDamboSearch = false;
    @track showReceivables = false;
    @track showReceivablesDaily = false;
    @track showIssuanceSearch =false;
    @track showRevenuAdjustment =false;
    @track showTBDPage =false;


    @track showMenubar = true;
    
    connectedCallback(){
        console.log('#cjfwCommMenubar # connected callback');
        this.getUrl();
        // this.showSalesLedger = true; // 테스트용으로 잠깐 주석해제
    }

    disconnectedCallback(){
        console.log('#cjfwCommMenubar # disconnectedCallback');
    }

    /* 
    현재 페이지에서 URL 가져오기  
    URL별 분기치기 위함 
    */
    getUrl(){
        const currentUrl = window.location.href;
        console.log('current URL-> ' , currentUrl);
        const urlParts = currentUrl.split('/');
        const lastUrl = urlParts[urlParts.length -1];
        console.log('Last URL-> ' , lastUrl );


        switch (lastUrl){
            case "CommMenubar":
            console.log('<===개발중===>');
            this.showSalesLedger = true;
            this.developer = true;

            case "CollateralLoan":
            this.CollateralLoan = true;
            break;

            case "SalesPerformanceClosingManage":
            this.SalesPerformanceClosingManage = true;
            break;

            case "SalesClosingManage":
            this.SalesClosingManage = true;
            break;

            case "Incentive":
            this.Incentive = true;
            break;

            case "TaxIssuance":
            this.TaxIssuance = true;
            break;

            case "DebentureBalanceManage":
            this.DebentureBalanceManage = true;
            break;

            case "ChainSalesFeeManage":
            this.ChainSalesFeeManage = true;
            break;

        }
    }


    
    /* 컴포넌트 추가될때마다 아래 작성하면 됨 */
    menuTab(event) {
        const name = event.target.name;
        let flagValue = {};
    
        switch (name) {
            case "salesLedger":
                flagValue = { showSalesLedger: true };
                console.log('-> 매출원장 호출');
                break;
    
            case "OtherSales":
                flagValue = { showOtherSales: true };
                console.log('-> 기타매출관리 호출');
                break;
    
            case "Receivables":
                flagValue = { showReceivables: true };
                console.log('-> 매출채권 현황 리포트 호출');
                break;

            case "ReceivablesDaily":
                flagValue = { showReceivablesDaily: true };
                console.log('-> 일자별 매출채권 리포트 호출');
                break;

            case "IssuanceSearch":
                flagValue = { showIssuanceSearch: true };
                console.log('-> 세금계산서 발행 호출');
                break;

            case "AccountDamboSearch":
                flagValue = { showAccountDamboSearch: true };
                console.log('-> 고객 담보현황 조회 발행 호출');
                break;

            case "RevenuAdjustment":
                flagValue = { showRevenuAdjustment: true };
                console.log('-> 고객 담보현황 조회 발행 호출');
                break;

            case "TBDPage":
                flagValue = { showTBDPage: true };
                console.log('-> showTBDPage 호출');
                break;

        }
        this.setShowFlags(flagValue);
    }

    /* 컴포넌트가 하나 열리면 , 나머지는 닫혀야함 */
    setShowFlags(flagValue) {
        console.log('flagValue ->' , flagValue);
        this.showSalesLedger = flagValue.showSalesLedger || false;
        this.showOtherSales = flagValue.showOtherSales || false;
        this.showReceivables = flagValue.showReceivables || false;
        this.showReceivablesDaily = flagValue.showReceivablesDaily || false;
        this.showIssuanceSearch = flagValue.showIssuanceSearch || false;
        this.showAccountDamboSearch = flagValue.showAccountDamboSearch || false;
        this.showRevenuAdjustment = flagValue.showRevenuAdjustment || false;
        this.showTBDPage = flagValue.showTBDPage || false;
    }


    /* 
    Menubar Show and Hide 기능 
    */
    showMenu(){
        console.log('showMenu Click -->');
        this.showMenubar = !this.showMenubar;
    }


}