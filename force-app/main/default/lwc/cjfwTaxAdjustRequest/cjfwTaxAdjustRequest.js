/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 08-21-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
import { LightningElement } from 'lwc';
import { utilAlert, utilShowToast, utilConfrim,  setCustomStyle, removeCustomStyle} from 'c/commUtils';

//
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

//Static Resource
import CJFWCOMMCSS from '@salesforce/resourceUrl/cjfwCOMMCss'

export default class CjfwTaxAdjustRequest extends LightningElement {

    customStyle = {
        id:'taxAdjusttRequest'
        ,style:`
        .taxAdjusttRequest.related-card .slds-card__header {
            border: 1px solid rgb(201,201,201);
            border-radius: 0.25rem 0.25rem 0 0;
            background-color: rgb(243, 243, 243);
            margin-bottom: 0;
            padding: 12px;
        }
        .taxAdjusttRequest.related-card .slds-card__body {
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

    disconnectedCallback() {
        removeCustomStyle(this.customStyle.id);
    }
}