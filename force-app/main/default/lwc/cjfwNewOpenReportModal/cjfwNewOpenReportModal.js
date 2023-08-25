/**
 * @description       : 
 *  
 * [ 품의서 종류 ]
    (급식솔루션,헬씨,아이누리)_신규개설품의 page : CJFW_NewOpenReport
    (아이누리)_신규개설품의 page : CJFW_NewInuriOpenReport
    (급식)_보증금양식 page : CJFW_DepositForm
    (외식)_수주심의운영 page : CJFW_OrderConsiderManage
    (외식)_수주심의양식(신규) page : CJFW_OrderConsiderNewForm
    (외식)_수주심의양식(재계약) page : CJFW_OrderConsiderReContractForm 

 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-25-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-23-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
import {  api, track } from 'lwc';
import LightningModal from 'lightning/modal';

export default class cjfwNewOpenReportModal extends LightningModal {
    @api selectValue;
    @track vfPageUrl;

    connectedCallback() {
        console.log('#cjfwNewOpenReportModal #connectedCallback');
        console.log('selectValue ->', this.selectValue);
        if(this.selectValue !== undefined) this.openReport();
    }

    openReport(){
            console.log('#openReport -> select value' , this.selectValue);
            
            if(this.selectValue === 'healthy'){ 
                // (급식솔루션,헬씨,아이누리)_신규개설품의 page
                this.vfPageUrl ='/apex/CJFW_NewOpenReport';
            }else if(this.selectValue ==='inuri'){
                // (아이누리)_신규개설품의 page
                this.vfPageUrl ='/apex/CJFW_NewOpenReportInuri';
            }else if(this.selectValue ==='Deposit'){
                // (급식)_보증금양식 page
                this.vfPageUrl ='/apex/CJFW_DepositForm';
            }else if(this.selectValue ==='strategy'){
                // 수주심의양식(재계약)
                this.vfPageUrl ='/apex/CJFW_NewOpenReport';
            }else if(this.selectValue ==='OrderConsider'){
                // (외식)_수주심의운영
                this.vfPageUrl ='CJFW_OrderConsiderManage';
            }else if(this.selectValue ==='OrderConsiderNew'){
                // (외식)수주양식_신규
                this.vfPageUrl ='/apex/CJFW_OrderConsiderNewForm';
            }else if(this.selectValue ==='OrderConsiderReContract'){
                // (외식)_수주심의양식(재계약)
                this.vfPageUrl ='/apex/CJFW_OrderConsiderReContractForm';
            }
    }

    handlePDF(){
        console.log('#cjfwNewOpenReportModal #handlePDF');
        const iframe = this.template.querySelector('iframe');
        const iframeContent = iframe.contentDocument.documentElement.innerHTML;
        console.log('iframeContent -> ', iframeContent);
    }

    handleClose(){
        this.close();
    }
    /*  Title='품의서 HEADER'; */
    // vfPageUrl ='/apex/CJFW_NewOpenReport';
}