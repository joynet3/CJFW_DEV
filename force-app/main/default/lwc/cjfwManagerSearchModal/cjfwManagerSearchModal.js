import { track, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import { utilShowToast } from 'c/commUtils';

export default class CjfwManagerSearchModal extends LightningModal {
    @track showModal = true;

    /* 
    취소 클릭시
    */
    handleClose(){
        console.log('>>> 취소');
        this.close();
    }

    @track data = [
        { PV_NO__c: '김길동', PV_NAME1_VK__c: '[A01] 회계 담당자', PV_KNVKGB__c: '010-2123-4343', PV_TELF1_VK__c: '부서 A', PV_ABTNR_VK__c: '직책 B', PV_PAFKT_VK__c: 'kim@cj.net', PV_EMAIL_VK__c: 'SELLER-001', PV_TALKT_VK__c: '판매처 1'},
        { PV_NO__c: '홍길동', PV_NAME1_VK__c: '[A01] 회계 담당자', PV_KNVKGB__c: '010-2323-4412', PV_TELF1_VK__c: '부서 A', PV_ABTNR_VK__c: '직책 B', PV_PAFKT_VK__c: 'hong@cj.net', PV_EMAIL_VK__c: 'SELLER-001', PV_TALKT_VK__c: '판매처 1'},
        { PV_NO__c: '윤길동', PV_NAME1_VK__c: '[A01] 회계 담당자', PV_KNVKGB__c: '010-3983-9443', PV_TELF1_VK__c: '부서 A', PV_ABTNR_VK__c: '직책 B', PV_PAFKT_VK__c: 'yun@cj.net', PV_EMAIL_VK__c: 'SELLER-001', PV_TALKT_VK__c: '판매처 1'}
        // 추가 데이터 항목들...
      ]; 
}