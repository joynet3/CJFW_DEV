import { track, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';

export default class CjfwTaxIssuanceCancelModal extends LightningModal {
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
    /**
     * 부모(Main)에서 보내준 데이터 확인
     */
    console.log('>>> This Is New Modal : headComboVal' + this.headComboVal);
    console.log('>>> This Is New Modal : suComboVal' + this.suComboVal);
    console.log('>>> This Is New Modal : teamComboVal' + this.teamComboVal);
    console.log('>>> This Is New Modal : searchKey' + this.searchKey);
    console.log('>>> This Is New Modal : searchEmpNum' + this.searchEmpNum);
    console.log('>>> This Is New Modal : firstDayOfMonthDate' + this.firstDayOfMonthDate);
    console.log('>>> This Is New Modal : todayDate' + this.todayDate);
    console.log('>>> This Is New Modal : fromCreatdDate' + this.fromCreatdDate);
    console.log('>>> This Is New Modal : toCreatedDate' + this.toCreatedDate);
    console.log('>>> This Is New Modal : typeComboVal' + this.typeComboVal);
    console.log('>>> This Is New Modal : statusComboVal' + this.statusComboVal);
    
  }

  /**
  * 취소 버튼 클릭 시 
  */  
  handleClose(){
    this.close();
  }

}