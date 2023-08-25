import { LightningElement, api, track, wire } from 'lwc';

export default class CjfwMDMManagementInfoModal extends LightningElement {
    @track isShowMenu = true;
    @track issuanceTypeVal;
    @track isLoading;
    @track showTabAccounting = true;
    @track showTabSales = true;
    @track showTabPayment = true;
    @track test1 = 'value1'
    @track firstNameFieldValue = 'A고객사';
    @track firstNameFieldValue2 = '';
    @track objCustomer = [
       {key : 'sObjectType' ,value : 'MDMRegRequestCustomer__c'},
       {key : 'PV_CESSION_KZ__c' ,value : ''},
       {key : 'PV_KTOKD__c' ,value : 'Z300'}
    ];
    @track recordId = null;
    

    /**
    * 조회 버튼 위치 조정
    */  
    // renderedCallback(){
    //     const style = document.createElement('style');
        
    //     style.innerText = `
    //     .cjfw-info-modal.slds-modal__footer .slds-button_brand {
    //         background-color : #9D3E17;
    //     }
    //     `;
    //     this.template.querySelector('lightning-button').appendChild(style);
    // }
    
    /**
    * 취소 버튼 클릭 시 
    */  
    handleClose(){
        console.log('# 관리처 생성Btn > 정보입력 Modal >  취소 Btn');
        window.history.back();
      }

    connectedCallback(){
      console.log('#Info');
      this.isLoading = false;
    }
}