import { LightningElement, api, track } from 'lwc';
import { utilAlert, utilShowToast, utilConfrim,  setCustomStyle, removeCustomStyle} from 'c/commUtils';

//
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

//Static Resource
import CJFWCOMMCSS from '@salesforce/resourceUrl/cjfwCOMMCss'

export default class CjfwReplacementRequest extends LightningElement {

    customStyle = {
        id:'replaceRequest'
        ,style:`
        .replacementRequest.related-card .slds-card__header {
            border: 1px solid rgb(201,201,201);
            border-radius: 0.25rem 0.25rem 0 0;
            background-color: rgb(243, 243, 243);
            margin-bottom: 0;
            padding: 12px;
        }
        .replacementRequest.related-card .slds-card__body {
            margin-top: 0;
            margin-bottom:0;
            border: 1px solid rgb(201,201,201);
            border-top: 0;
            border-radius: 0 0 0.25rem 0.25rem;
            overflow: hidden;
        }
        `
    };
    connectedCallback() {
        setCustomStyle(this.customStyle.style, this.customStyle.id);

        Promise.all([
            loadStyle(this, CJFWCOMMCSS) 
        ])
        .then(() => {
            console.log('성공')
        })
        .catch(error => {
            console.error('error');
        });
    
        
    }

    /**
    * destroy method
    *
    */
    disconnectedCallback() {
        removeCustomStyle(this.customStyle.id);
    }

    @track replacementRequestData = [
        {idx:0, shipmentQuantity:null, isShipmentQuantity:false}
        ,{idx:1, shipmentQuantity:null, isShipmentQuantity:false}
    ];


    handleFocus(event) {
    
        let tdCmp = event.currentTarget;
        let targetInfo = tdCmp.dataset.name;
        let field = tdCmp.dataset.field;
        let trCmp = tdCmp.parentElement;
    
        let idx = trCmp.dataset.idx;
        this.replacementRequestData[idx][targetInfo] = true;
        let self = this;
        setTimeout(()=>{
          let input = this.template.querySelector('.'+targetInfo);
          if(input) {
            input.value = self.replacementRequestData[idx][field];
            input.focus();
          }
        }, 150);
      }
    
      handleFocusOut(event) {
        //console.log('handleFocusOut')
        let inputCmp = event.currentTarget;
        //console.log(inputCmp.value);
        
        let tdCmp = inputCmp.parentElement;
        let targetInfo = tdCmp.dataset.name;
        let field = tdCmp.dataset.field;
        let trCmp = inputCmp.parentElement.parentElement;
        let idx = trCmp.dataset.idx;
    
        let changeValue = inputCmp.value;
    
        if(changeValue == 0) {
          inputCmp.value = undefined;
        }
       
    
        if(changeValue) {
          this.replacementRequestData[idx][field] = inputCmp.value;
    
        }

        this.replacementRequestData[idx][targetInfo] = false;
      }

}