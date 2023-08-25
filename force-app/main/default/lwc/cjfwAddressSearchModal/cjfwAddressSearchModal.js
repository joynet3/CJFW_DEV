import { track, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import { utilShowToast } from 'c/commUtils';

export default class CjfwAddressSearchModal extends LightningModal {
    @track showModal = true
    /* 
    취소 클릭시
    */
    handleClose(){
        console.log('>>> 취소');
        this.close();
    }
}