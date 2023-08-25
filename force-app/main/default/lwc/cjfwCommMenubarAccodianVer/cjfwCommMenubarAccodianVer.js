/**
 * @description       : 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-22-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-17-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
import { LightningElement , track } from 'lwc';

export default class cjfwCommMenubarAccodianVer extends LightningElement {
    
    /* 컴포넌트별 모달 */
    @track showSalesLedger = false;
    @track showOtherSales = false;
    @track showReceivables = false;
    @track showReceivablesDaily =false;
    @track showIssuanceSearch =false;
    @track showAccountDamboSearch =false;
    @track showRevenuAdjustment =false;
    @track showTBDPage =false;

    @track showMenubar = true;
    
    connectedCallback(){
        console.log('#cjfwCommMenubar # connected callback');
        //this.showSalesLedger = true;
        //console.log('showSales => ' , this.showSalesLedger );
    }
    clickSalesLedger(){
        console.log('#cjfwCommMenubar # clickSalesLedger ');
        this.showSalesLedger = true;
        console.log('showSales => ' , this.showSalesLedger );
    }
    
    clickSalesAnalyze(){
        console.log('#cjfwCommMenubar # clickSalesAnalyze ');
        this.showSalesLedger = false;
    }

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