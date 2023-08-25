import { LightningElement, track, api } from 'lwc';

export default class CjfwReplacementRequestFilter extends LightningElement {
    @track orderTypeOptions = [
        {label:'정상', value:'정상'},
        {label:'반품', value:'반품'},
        {label:'물량대체', value:'물량대체'},
    ];

    orderTypeValue = ['정상', '반품', '물량대체'];

    handleOrderTypeChange(event) {
        this.orderTypeValue = event.detail.value;
    }
}