import { LightningElement, api, track, wire } from 'lwc';
import doDate from '@salesforce/apex/TaxIssuanceStatusSearchController.getTodayDate';



export default class CjfwSalesStatusReportSearch extends LightningElement {
    @api recordId;
    @track selectedType = '1';
    @track isAllSelected = false;
    @track toCreatedDate

    debentureLoading = true;
    /**
     * 고객사/사번/발행일자~/작성일자~/ onChange
     */   
    changeToCreatedData(event){
        this.searchKey = event.detail.value;
        console.log('>>> Main 고객사 : ' + this.searchKey );
    }
    renderedCallback(){
    const style = document.createElement('style');
    
    style.innerText = `
        .cjfw-sales-status-report .related-card .slds-card__header {
            border: 1px solid rgb(201,201,201);
            border-radius: 0.25rem 0.25rem 0 0;
            background-color: rgb(243, 243, 243);
            margin-bottom: 0;
            padding: 12px;
        }
        .cjfw-sales-status-report .related-card .slds-card__body {
            margin-top: 0;
            border: 1px solid rgb(201,201,201);
            border-top: 0;
            border-radius: 0 0 0.25rem 0.25rem;
            overflow: hidden;
        }
        
        .cjfw-sales-status-report .related-card .slds-table {
            border-bottom: 0;
        }
       
        .cjfw-sales-status-report .slds-no-flex{
            width : 50%;
        }
        .cjfw-sales-status-report .colMiddle{
            width : 45%;
        }
        
        .datatable-full-size {
            width: 100% !important;
        }

        .cjfw-sales-status-report .slds-table_header-fixed thead th,
        .cjfw-sales-status-report lightning-primitive-header-factory,
        .cjfw-sales-status-report .slds-cell-fixed.slds-has-button-menu {
            width: auto !important;
        }
        .cjfw-sales-status-report .slds-th__action {
            padding-right: 0.25rem;
        }
        .cjfw-sales-status-report .slds-th__action .slds-th__action-button {
            display: none !important;
        }
        .cjfw-sales-status-report .slds-text-heading_small {
            font-size: 14px;
        }
        .cjfw-sales-status-report .custom-input-container {
            width: 10px !important;
        }
    }
    `;
    this.template.querySelector('lightning-card').appendChild(style);
    }

    connectedCallback(){
        window.console.log('>>> connectedCallback');
        /**
         * 필터의 From발행일자을 달의 첫날로 Setting
         */
            doDate()
                .then(result => {
                    console.log(JSON.stringify(result));
                    this.toCreatedDate = result;
                    console.log('여기 ' + this.toCreatedDate);
                })
                .catch(error => {
                })

    }

    disconnectedCallback() {
        window.console.log('disconnectedCallback');
    }

    typeChange(event){
        window.console.log('typeChange');

        this.debentureList = [];

        this.selectedType = event.detail.value;
        window.console.log('selectedType : ', this.selectedType);
       
    }

  

    @track data = [
        { openingBalance: '780,000', grossSales: '69,505,000', taxAdjustmentAmount: '2,343,410', endBalance: '643,410', overdueDebt: '234,450', actualSecurityAmount: '4,234,450', badDebtReceivables: '2,234,450', securedLoan: '35,234,450', jointGuaranteeAmount: '5,723,450', warrantyExpiryDate: '2023.01.12', creditLimit: '1,200,000', creditMaturityDate:'2023.03.21'},
        { openingBalance: '432,000', grossSales: '69,505,000', taxAdjustmentAmount: '39,849,500', endBalance: '233,410', overdueDebt: '213,350', actualSecurityAmount: '6,234,450', badDebtReceivables: '123,234,450', securedLoan: '56,234,450', jointGuaranteeAmount: '32,234,450', warrantyExpiryDate: '2023.01.12', creditLimit: '1,300,000', creditMaturityDate: '2023.03.21'},
       
    ];
}