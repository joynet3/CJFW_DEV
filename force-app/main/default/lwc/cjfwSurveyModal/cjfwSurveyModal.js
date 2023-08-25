import {api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';

//LMS
import mobileQuickActionChannel from '@salesforce/messageChannel/quikActionMsgCh__c';
import { publish, MessageContext } from 'lightning/messageService';

import { utilAlert, utilShowToast, utilConfrim, utilCloseActionScreenEvent, setCustomStyle, removeCustomStyle} from 'c/commUtils';

export default class CjfwSurveyModal extends LightningModal {
    //LMS
    @wire(MessageContext)
    messageContext;
    @api recordId;
    @api objectApiName;

    @api parentType = 'lwc';  //호출할 component Type: aura, lwc
    @api label = '설문지';
    @track isSelected = false;


    connectedCallback() {
        console.log('IsInit!!');
    }

    handleSave() {
        this.template.querySelector('c-cjfw-survey').save();
        
    }

    handleClose() {
        //utilShowToast('close 버튼 클릭', '과연' );
        //utilCloseActionScreenEvent();
        
        
        if(this.parentType == 'lwc') {
            this.close();
        }else if(this.parentType == 'aura') {
            
            //LMS publish
            const payload = { 
                pageType:'cjfwSurveyModal' 
                , data:{} 
                , btnType:'close'
            };
            publish(this.messageContext, mobileQuickActionChannel, payload);
        }
    }

    handleNext() {
        let surveyCmp = this.template.querySelector('c-cjfw-survey');
        let selectedValue = surveyCmp.getSelectedSurveyType();
        console.log('handleNext Clic')
        console.log(JSON.stringify(selectedValue))

        if(selectedValue) {
            this.label = selectedValue.label + ' 설문지';
            this.isSelected = true;
        }else {
            utilShowToast('에러!' ,'설문지 유형을 선택해 주세요.', 'error');
        }

    }

    handlePrevious() {
        this.isSelected = false;
        this.label = '설문지';
        
    }

    renderedCallback() {
        if(!this._isInit) {

            // 프로토타입 시현용 [s] 자동

            setTimeout(()=>{this.handleNext();} , 279)
            
            this._isInit = true;
            // 프로토타입 시현용 [e]
        }
    }
    
}