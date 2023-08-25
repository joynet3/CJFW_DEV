import { LightningElement, api, track, wire  } from 'lwc'
import CjfwAccountSearchModal from 'c/cjfwAccountSearchModal';

export default class CjfwMDMManagementDeliveryModal extends LightningElement {
    @track isShowMenu = true;
    @track issuanceTypeVal;
    @track isLoading;
    @track showTabAccounting = true;
    @track showTabSales = true;
    @track showTabPayment = true;
    @track test1 = 'value1'
    @track firstNameFieldValue = 'A고객사';
    @track firstNameFieldValue2 = '';
    @track recordId = null;
    @track basicInfo = true;
    @track isReadOnlyHKUNNR = false;

    @api groupId;
    @api label;
    @api id;
    @api value;
    @api inputText;
    @api isRequired;
    @api isDisabled;
    @api isError;
    @track objCustomer = [
       {key : 'sObjectType' ,value : 'MDMRegRequestCustomer__c'},
       {key : 'PV_CESSION_KZ__c' ,value : ''},
       {key : 'PV_KTOKD__c' ,value : 'Z300'}
    ];
    @track pvODCLOSEGB=[
      { label: '유통KX'          , value: '	10'},
      { label: '급식'          , value: '	20'}
    ]

      /**
   * 필수, 활성화 Attr
   */
      @api PV_KEYYN__c; //입장여부
      @track isDisableKEYINFO = true; //입장여부정보
      @api PV_KXOTD__c;
      @track isRequiredKXOTDTIME = true; //KX OTD 요청시간 
      @api PV_FDINFO__c; //초도배송 정보공유
      @track isRequiredFDINFO = true;
      @track PV_ISFDFTF__c = false;
    
    
    /**
     * 모달 변수
     */
    IsShow = false;
    @track searchKey = '';
    @track accountType = '';


    handleSearchb(){
      console.log('>>> 돋보기 클릭');
    }

    /* 
    *관리처 input field 에서 Enter 치면 호출
    *고객사 검색 모달 open
    */
    handleEnter(event){
      if(event.key === 'Enter'){
          this.openAccountModal();
      }
    }

    /**
    * 고객사/사번/발행일자~/작성일자~/ onChange
    */   
    changeHandleSearch(event){
      this.searchKey = event.detail.value;
      console.log('>>> Main 고객사 : ' + this.searchKey );
    }

    /* 
    자식에서 넘어온 Event 듣는곳 
    */
    setCustomEvent(){
      this.template.addEventListener('setSearchAcc', event =>{
          console.log('자식의소리 ' , event.detail.searchKey );
      });
    }
    handleSearch(event) {
      this.searchKey = event.target.value; //searchKey 넘겨주기 
      this.accountType = event.target.label;
      console.log('searchKey => ' , this.searchKey);
      console.log('accountType => ' , this.accountType);
      // this.showCjfwAccountSearchModal();
    }

    /* 
    *고객사 검색 Component 호출 
    */
    async openAccountModal() {
      this.result = await CjfwAccountSearchModal.open({
          size: 'medium',
          searchKey : this.searchKey,
          accountType : this.accountType,
          // onclose : this.handleClose,
          message : 'FilterToCmp'
      }).then(result => {
          if( result !=undefined ){
              if(result.length > 0) this.searchKey = result[0].CustomerID__c;
          }
      });
      console.log(this.result);
    }
    
    /**
    * 취소 버튼 클릭 시 
    */  
    handleClose(){
        console.log('# 관리처 생성Btn > 정보입력 Modal >  취소 Btn');
        const baseUrl = window.location.origin;
        window.location.href = baseUrl+'/lightning/o/MDMRegRequestCustomer__c/list?filterName=Recent';
      }

    connectedCallback(){
      console.log('#Delivery');
      this.isLoading = false;
    }

    handleHdofficeynChange(event){
      console.log('클릭 됨');
    }

    /**
     * 저장
     */
    PV_NAME1__c = '';

    requiredFill(event) {
      this.PV_NAME1__c = event.detail.value;
  }
    // submit으로 하는 방법
    handleSave(event){

      if(this.PV_NAME1__c != ''){
        const fields = event.detail.fields;
        console.log(JSON.stringify(event.detail.fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        const baseUrl = window.location.origin;
        window.location.href = baseUrl+'/lightning/o/MDMRegRequestCustomer__c/list?filterName=Recent';
      }else{
        alert('필수값 !');
      }
    }

}