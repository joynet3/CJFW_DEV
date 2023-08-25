/**
* LWC 용 select
*
*@group  COMM
*@author 진현욱
*@since 2023-08-04  내용 작성
*/
import { LightningElement, api, track } from 'lwc';

export default class CommCustomSelect extends LightningElement {

    _isEmptyOption = false;                 //초기값 여부
    initialOption = [{
        label:'Select...'
        , value:''
    }];
    selectedData;

    @api errorMsg = 'Select an option.';    //errorMsg
    @api label = '';                        //label
    @api name  = '';                        //name
    @api isRequired = false;                //필수값 표시 여부
    @track isError = false;                 //error 여부
    @track _options = [];                   //선택옵션

    connectedCallback() {
        //console.log('CommCustomSelect Init');
        this.reset();
    }


    isOptionData() {
        return this._options.size() > 0 ? true : false
    }

    @api get isEmptyOption() {
        return this._isEmptyOption;
    }

    set isEmptyOption(value) {
        this._isEmptyOption = value;
    }
    
    @api 
    get options() {
        //console.log('CommCustomSelect getter options')
        return this._options;
    }

    set options(options) {
        //console.log('CommCustomSelect setter options')
        if(typeof options == 'string') {
            options = JSON.parse(options);
        }
        //console.log(JSON.stringify(options));
        if(options)  {
            //this.initailSetOption;
            let optionList = [...this.initialOption];
            
            if(!this.isEmptyOption) {
                //|| this.isEmptyOption == 'false'
                optionList.splice(0,1);            
                //DeepClone 방법> Object.assign([], this._options);
                //DeepClone 방법> [...this._options];
                //DeepClone 방법> JSON.parse(JSON.stringify(this._options)); Object 로 복사됨
            }
    
            optionList = optionList.concat(JSON.parse(JSON.stringify(options)));
            //
            
            optionList[0].selected = true;
            
            this._options = optionList;
            // if(this.value) {
            //     this.setValue(this.value);
            // }
        }

    }

    @api 
    get value() {
        return this._value;
    }

    set value(value) {
        this._value = value;     
        this.setValue(value);
    }

    @api setValue(value) {
        //console.log('setValue')
        let options = this.options.map((option)=>{
            if(option.value === value) {
                option.selected = true;
                this.selectedData = option;
            }else {
                option.selected = false;
            }
            return option;
        });
        this._options = options;
        //this.template.querySelector('.slds-select').value = value;
        //console.log(JSON.parse(JSON.stringify(this.options)))
    }

    
    getSelectData() {
        
        let selectCmp = this.template.querySelector('.slds-select');
        //console.log(selectCmp.value);

        let idx = selectCmp.selectedIndex;
        this.selectedData = this.options[idx];
        
        if(selectCmp)
        this.value = selectCmp.value;
        return this.selectedData;
    }


    changeHandler(event) {
        this.isValid();

        this.getSelectData();

        let info = this.getSelectedValue();
        
        let selectedEvent = new CustomEvent('selected', {
            detail: info
        });

        this.dispatchEvent(selectedEvent);

    }

    @api getSelectedValue() {
        this.getSelectData();

        let info = {
            selectedData : this.selectedData
            ,name : this.name
        }
        return info;
    }

    @api isValid() {
        let error = false;
        let selectCmp = this.template.querySelector('.slds-select');
        let customSelectContainer = this.template.querySelector('.customSelect');
        if(!selectCmp.value) {
            if(customSelectContainer) 
            customSelectContainer.classList.add('slds-has-error');
            this.isError = error = true;
        }else {
            if(customSelectContainer)
            customSelectContainer.classList.remove('slds-has-error');
            this.isError = error = false;
        }
        

        return error;
    }

   

    @api reset() {
        this.selectedData = undefined;
    }


    renderedCallback() {
        //console.log('CommCustomSelect renderedCallback')
    }

}