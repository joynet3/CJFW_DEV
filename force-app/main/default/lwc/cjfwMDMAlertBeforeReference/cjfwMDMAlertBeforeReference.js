import { track, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import CjfwMDMReferenceCreateModal  from 'c/cjfwMDMReferenceCreateModal';

export default class CjfwMDMAlertBeforeReference extends LightningModal {
    @track showModal = true;
    @track issuanceTypeVal;
    /**
     * Main에서 전달 받을 데이터
     */
    @api selectedOption;
    @api headComboVal;
    @api suComboVal;
    @api teamComboVal;
    @api searchKey;
    @api searchEmpNum;
    @api firstDayOfMonthDate;
    @api todayDate;
    @api fromCreatdDate;
    @api toCreatedDate;
    @api typeComboVal;
    @api statusComboVal;
  
    connectedCallback(){
    }
  
    /**
    * 취소 버튼 클릭 시 
    */  
    handleClose(){
      this.close();
    }

    // 참조생성 Btn 클릭 시 Modal 호출
    handleNext(){
        console.log('>>> 참조생성 버튼 클릭 ');
        this.referenceCreateModal();
        this.close();
    }

    // 참조생성 Component 호출 
    async referenceCreateModal() {
        this.result = await CjfwMDMReferenceCreateModal.open({
            size: 'mideum',
            
            message : 'FilterToCmp'
        }).then(result => {
            
        });
        console.log(this.result);
    }
}