import { track, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import CjfwAccountSearchModal from 'c/cjfwAccountSearchModal';
import CjfwTaxIssuanceSingleModal from 'c/cjfwTaxIssuanceSingleModal';
import CjfwTaxIssuancePackageModal from 'c/cjfwTaxIssuancePackageModal';
import CjfwTaxIssuanceBulkModal from 'c/cjfwTaxIssuanceBulkModal';
import CjfwTaxIssuanceBulkLargeModal from 'c/cjfwTaxIssuanceBulkLargeModal';


export default class CjfwTaxIssuanceNewModal extends LightningModal {
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
  * radio Group
  */  
  get options() {
    return [
        { label: '단건 발행'        , value: 'single'    },
        { label: '일괄 발행'        , value: 'package'   },
        { label: '대량 발행'        , value: 'bulk'      },
        { label: '대량 일괄 발행'   , value: 'BulkLarge' },
    ];
  }
  /**
  * radio Group 선택 시 
  */ 
   handleChangeRadio(event) {
    this.issuanceTypeVal = event.detail.value;
    console.log('>>> 신규발행 Radio ' + this.issuanceTypeVal);
  }
  /**
  * 취소 버튼 클릭 시 
  */  
  handleClose(){
    this.close();
  }
  /**
  * 다음 버튼 클릭 시
  */ 
  async handleNext() {
    console.log('>>> 신규발행, 다음 Btn ' + this.issuanceTypeVal);
    //단일 발행
    if(this.issuanceTypeVal == 'single'){
      this.openSingleModal();
      this.close();
    }
    //일괄 발행
    if(this.issuanceTypeVal == 'package'){
      this.openPackgeModal();
      this.close();
    }
     //대량 발행
     if(this.issuanceTypeVal == 'bulk'){
      this.opeBulkModal();
      this.close();
    }
     //대량 일괄 발행
     if(this.issuanceTypeVal == 'BulkLarge'){
      this.opeBulkLargeModal();
      this.close();
    }
  }

  /* 
  *단건 발행 Modal 호출 :Single
  */
  async openSingleModal() {
    this.result = await CjfwTaxIssuanceSingleModal.open({
        size: 'large',
        headComboVal        :   this.headComboVal,
        suComboVal          :   this.suComboVal,
        teamComboVal        :   this.teamComboVal,
        searchKey           :   this.searchKey,
        searchEmpNum        :   this.searchEmpNum,
        firstDayOfMonthDate :   this.firstDayOfMonthDate,
        todayDate           :   this.todayDate,
        fromCreatdDate      :   this.fromCreatdDate,
        toCreatedDate       :   this.toCreatedDate,
        typeComboVal        :   this.typeComboVal,
        statusComboVal      :   this.statusComboVal,
        message : 'FilterToCmp'
    }).then(result => {
    });
  }

  /* 
  *일괄 발행 Modal 호출 : Package
  */
  async openPackgeModal() {
    this.result = await CjfwTaxIssuancePackageModal.open({
        size: 'large',
        headComboVal        :   this.headComboVal,
        suComboVal          :   this.suComboVal,
        teamComboVal        :   this.teamComboVal,
        searchKey           :   this.searchKey,
        searchEmpNum        :   this.searchEmpNum,
        firstDayOfMonthDate :   this.firstDayOfMonthDate,
        todayDate           :   this.todayDate,
        fromCreatdDate      :   this.fromCreatdDate,
        toCreatedDate       :   this.toCreatedDate,
        typeComboVal        :   this.typeComboVal,
        statusComboVal      :   this.statusComboVal,
        message : 'FilterToCmp'
    }).then(result => {
    });
  }

  /* 
  *대량 발행 Modal 호출 : Bulk
  */
  async opeBulkModal() { 
    this.result = await CjfwTaxIssuanceBulkModal.open({
        size: 'large',
        headComboVal        :   this.headComboVal,
        suComboVal          :   this.suComboVal,
        teamComboVal        :   this.teamComboVal,
        searchKey           :   this.searchKey,
        searchEmpNum        :   this.searchEmpNum,
        firstDayOfMonthDate :   this.firstDayOfMonthDate,
        todayDate           :   this.todayDate,
        fromCreatdDate      :   this.fromCreatdDate,
        toCreatedDate       :   this.toCreatedDate,
        typeComboVal        :   this.typeComboVal,
        statusComboVal      :   this.statusComboVal,
        message : 'FilterToCmp'
    }).then(result => {
    });
  }
  /* 
  *대량 일괄 발행 Modal 호출 : Bulk Large
  */
  async opeBulkLargeModal() { 
    this.result = await CjfwTaxIssuanceBulkLargeModal.open({
        size: 'large',
        headComboVal        :   this.headComboVal,
        suComboVal          :   this.suComboVal,
        teamComboVal        :   this.teamComboVal,
        searchKey           :   this.searchKey,
        searchEmpNum        :   this.searchEmpNum,
        firstDayOfMonthDate :   this.firstDayOfMonthDate,
        todayDate           :   this.todayDate,
        fromCreatdDate      :   this.fromCreatdDate,
        toCreatedDate       :   this.toCreatedDate,
        typeComboVal        :   this.typeComboVal,
        statusComboVal      :   this.statusComboVal,
        message : 'FilterToCmp'
    }).then(result => {
    });
  }

  // renderedCallback(){
  //   //스타일 만들어서
  //   const style = document.createElement('style');
  //   style.innerText = `
  //       c-cjfw-tax-issuance-new-modal .slds-modal__container {
  //           max-width: 50px;
  //       }
  //   `;
  //   this.template.querySelector('lightning-modal').appendChild(style);
  //   console.log('너머야' + this.template.querySelector('lightning-modal'));
  // }

}