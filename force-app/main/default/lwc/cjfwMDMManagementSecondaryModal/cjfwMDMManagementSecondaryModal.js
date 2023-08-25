import { track, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import CjfwAccountSearchModal from 'c/cjfwAccountSearchModal';
import CjfwMDMManagementSearchModal from 'c/cjfwMDMManagementSearchModal';
import CjfwAddressSearchModal from 'c/cjfwAddressSearchModal';
import CjfwManagerSearchModal from 'c/cjfwManagerSearchModal';
import setDefaultInfo from '@salesforce/apex/CJFW_MDMManagementController.setDefaultInfo';
import { utilShowToast } from 'c/commUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CjfwMDMManagementSecondaryModal extends LightningModal {
  @track isLoading;

  @track showTabPayment = true;
  @track test1 = 'value1'
  @track firstNameFieldValue = 'A고객사';
  @track firstNameFieldValue2 = '';

  @track beforeObjCustomer = [
     {key : 'sObjectType' ,value : 'MDMRegRequestCustomer__c'},
     {key : 'PV_CESSION_KZ__c' ,value : ''},
     {key : 'PV_KTOKD__c' ,value : 'Z300'},
  ];

  @track objCustomer = {
      PV_OLDCD__c : ''
  };
  
  listRequriedErrorKey = [];
  // 위랑 아래랑 같음
  // Map<String, String> objCustomer = new Map<String, String>{ 
  // sobjectType => 'MDMRegRequestCustomer__c',
  // PV_CESSION_KZ__c => '',
  // PV_KTOKD__c => 'Z300'
  // };
  // 
  // objCustomer.put('PV_STCDT_lu__c','');
  /**
   * fnSave
   */
  
  @api recordId;
  @track isReadOnlyHKUNNR = false;
  @track RecordTypeId;
  @track searchKey = '';
  @track accountType = '';
  @track showModal = true;
  mdmCustomerType = 'MDMManagement';
  _selected = [];
  IsShow = false;
  previousFocusedElement = null;
  /**
   * Tab 활성화 
   */
  @track basicInfo = true;
  @track financialInfo = true;
  @track salesInfo = true;

 
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
  
  @track requiredField = true;

  connectedCallback(){
      /**
       *  생성 시, recordType:관리처로 저장
       * */        
      setDefaultInfo({
          recordTypeName : this.mdmCustomerType
      }).then(result => { 
          let data = JSON.parse(JSON.stringify(result));
          if(data.strStatus='SUCCESS'){
              this.objCustomer.RecordTypeId = data.MDMRecordTypeId;
          }
      }).catch(e => {
          console.log('error -> ', e);
      })
      /**
       *  생성 시, Default 값 넣어주기
       * */   
      if (!this.recordId) {
          this.objCustomer.RequestType = 'create';
          this.objCustomer.PV_NAME1__c = '';
      }else{
      }
  }
 
  renderedCallback() {
      console.log('renderedCallback::');
      /**
      * 관리처 생성 시(=recordId없음)
      * 필수값표시(*)는 고객명(영문명 포함)만 해당 됨 
      * (MDM 고객 등록 및 수정 요청 Obj에 생성 된 후 편집시에는 적용X)
      */
     // 신규 MDM 생성 시
      if (!this.recordId) {
          this.requiredField = false;
      // 기존 MDM 수정 시
      }else{

      }
  }

  /**
  * ==================================================================================
  *  날짜 Validation Start
  * ==================================================================================
  * AMA 정보 변경 이벤트 추가해야 함.
  */

  // 영업그룹(유효기간 관리) Validation  
  grpChanged(event) {
      console.log('>>> 영업그룹 (유효기간 관리) 클릭 ');
      const fields = event.detail.value;
  
      if (fields !== "") {
          const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
          if (fields <= today) {
              alert('영업그룹의 유효날짜는 오늘보다 커야 합니다.');
              this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
              return;
          } else {
              this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
          }
      }
  }

  // 고객그룹(유효기간 관리) Validation
  cuhrChanged(event) {
      console.log('>>> 고객그룹(유효기간 관리) 클릭 ');
      const fields = event.detail.value;
  
      if (fields !== "") {
          const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
          if (fields > today) {
              alert('고객분류의 유효날짜는 오늘보다 같거나 작아야 합니다.');
              //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
              return;
          } else {
              this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
          }
      }
  }
  
  // 가격그룹(유효기간 관리) Validation
  cuhrChanged(event) {
      console.log('>>> 가격그룹(유효기간 관리) 클릭 ');
      const fields = event.detail.value;
  
      if (fields !== "") {
          const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
          if (fields > today) {
              alert('가격그룹의 유효날짜는 오늘보다 같거나 작아야 합니다.');
              //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
              return;
          } else {
              this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
          }
      }
  }

  // 단가그룹(유효기간 관리) Validation
  kvgr1Changed(event) {
      console.log('>>> 단가그룹(유효기간 관리) 클릭 ');
      const fields = event.detail.value;
  
      if (fields !== "") {
          const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
          if (fields < today) {
              alert('단가그룹의 유효날짜는 오늘보다 같거나 커야 합니다.');
              //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
              return;
          } else {
              this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
          }
      }
  }

  // FW 출고센터(유효기간 관리) Validation
  logiscenterChanged(event) {
      console.log('>>> FW 출고센터(유효기간 관리) 클릭 ');
      const fields = event.detail.value;
  
      if (fields !== "") {
          const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
          if (fields <= today) {
              alert('FW 출고센터 유효날짜는 오늘보다 커야 합니다.');
              //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
              return;
          } else {
              this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
          }
      }
  }
  // 경로사업부-(유효기간 관리) Validation
  oldbizplzceChanged(event) {
      console.log('>>> 경로사업부-(유효기간 관리) 클릭 ');
      const fields = event.detail.value;
  
      if (fields !== "") {
          const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
          if (fields > today) {
              alert('경로사업부의 유효날짜는 오늘보다 같거나 작아야 합니다.');
              //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
              return;
          } else {
              this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
          }
      }
  }
  //MA 정보 변경시
  pvChanged(event){
      console.log('>>> MA 정보 변경 시 ');
      const fields = event.detail.value;
  }
  /**
   * End
   */



  /**
  * ==================================================================================
  *  체크박스(checkBox)의 여부에따라, 필드값 활성화 및 Disable 활성화시키기 Start
  * ==================================================================================
  */
  handlerChangeKEYYN(event){
      this.PV_KEYYN__c = event.target.checked;

      if (this.PV_KEYYN__c) {
          // 체크되었을 때의 동작 처리
          this.isDisableKEYINFO = false;
      } else {
          // 체크 해제되었을 때의 동작 처리
          this.isDisableKEYINFO = true;
      }
  }
  handlerChangeKXOTD(event){
      console.log('여기 key Check1');
      this.PV_KXOTD__c = event.target.checked;
      console.log('key ' + this.PV_KXOTD__c);
      console.log('여기 key Check2');
      if (this.PV_KXOTD__c) {
          // 체크되었을 때의 동작 처리
          this.isRequiredKXOTDTIME = false;

      } else {
          // 체크 해제되었을 때의 동작 처리
          this.isRequiredKXOTDTIME = true;
      }
  }

  handlerChangeFDINFO(event){
      this.PV_FDINFO__c = event.target.checked;
      console.log('key ' + this.PV_FDINFO__c);
      console.log('여기 key Check2');
      if (this.PV_FDINFO__c) {
          // 체크되었을 때의 동작 처리
          this.isRequiredFDINFO = false;
          this.PV_ISFDFTF__c = true;
      } else {
          // 체크 해제되었을 때의 동작 처리
          this.isRequiredFDINFO = true;
      }
  }
  /**
   * End
   */



  /**
  * ==================================================================================
  *  필드 선택 시 Modal 호출 Start
  * ==================================================================================
  */
  handleEnter(event){
      if(event.key === 'Enter'){
          this.openSearchModal();
      }
  }

  //조회 Modal
  async openSearchModal() {
      this.result = await CjfwMDMManagementSearchModal.open({
          size: 'small',
          searchKey : this.searchKey,
          accountType : this.accountType,
          // onclose : this.handleClose,
          message : 'FilterToCmp'
      }).then(result => {
          if( result !=undefined ){
              // if(result.length > 0) this.searchKey = result[0].CustomerID__c;
              if(result.length > 0) this.searchKey = result[0].searchKey__c;
          }
      });
      console.log(this.result);
  }
  /**
   * End
   */

  /**
  * ==================================================================================
  *  버튼 선택 시 Modal 호출 Start
  * ==================================================================================
  */
  addressSearch(){
      console.log('>>> 주소검색 버튼 ');
      this.addressSearchModal();
  }

  
  // 주소 검색 Component 호출 
  async addressSearchModal() {
      this.result = await CjfwAddressSearchModal.open({
          size: 'small',
          
          message : 'FilterToCmp'
      }).then(result => {
          
      });
      console.log(this.result);
  }
  
  // 담당자 Btn 클릭 시 Modal 호출
  managerSearch(){
      console.log('>>> 주소검색 버튼 ');
      this.managerSearchModal();
  }

  // 담당자 검색 Component 호출 
  async managerSearchModal() {
      this.result = await CjfwManagerSearchModal.open({
          size: 'small',
          
          message : 'FilterToCmp'
      }).then(result => {
          
      });
      console.log(this.result);
  }
  /**
   * End
   */

  
  /**
   * 취소 버튼 클릭 시 
   */  
  fnCancel(){
      console.log('>>> 취소 Btn');
      // window.history.back();
      const baseUrl = window.location.origin;
      window.location.href = baseUrl+'/lightning/o/MDMRegRequestCustomer__c/list?filterName=Recent';
  }
  /**
   * 유효성 Onchange 
   */  
  //[기본정보]
  handleInputFieldChange(event) {
      const fieldName = event.target.fieldName;
      this.objCustomer[fieldName] = event.target.value;
  }

  // pvOldcdOnChange(event){
  //     // this.objCustomer.PV_OLDCD__c = event.detail.value;
  //     // console.log('>>> 구코드' + this.objCustomer.PV_OLDCD__c);
  // }
  // pvStcd2onChange(event){
  //     this.objCustomer.PV_STCD2__c = event.detail.value;
  //     console.log('>>> 사업자번호' + this.objCustomer.PV_STCD2__c);
  // }
  // pvStcd3onChange(event){
  //     this.objCustomer.PV_STCD3__c = event.detail.value;
  //     console.log('>>> 법인코드' + this.objCustomer.PV_STCD3__c);
  // }
  // pvStcd4onChange(event){
  //     this.objCustomer.PV_STCD4__c = event.detail.value;
  //     console.log('>>> 종사업자번호' + this.objCustomer.PV_STCD4__c);
  // }
  // pvStcd1onChange(event){
  //     this.objCustomer.PV_STCD1__c = event.detail.value;
  //     console.log('>>> 종사업자번호' + this.objCustomer.PV_STCD1__c);
  // }
  // pvTelf1onChange(event){
  //     this.objCustomer.PV_TELF1__c = event.detail.value;
  //     console.log('>>> 전화번호' + this.objCustomer.PV_TELF1__c);
  // }
  // pvTelfxonChange(event){
  //     this.objCustomer.PV_TELFX__c = event.detail.value;
  //     console.log('>>> 팩스번호' + this.objCustomer.PV_TELFX__c);
  // }
  // requiredFieldOnChagne(event) {
  //     this.objCustomer.PV_NAME1__c = event.detail.value;
  //     console.log('>>> 고객명(영문포함)' + this.objCustomer.PV_NAME1__c);
  // }

  // submit으로 하는 방법
    fnSave(event){
        console.log('>>> Save');
        if(this.objCustomer.PV_NAME1__c != ''){
            console.log('값O');
            var isError = false;
            var isSelectbox = false;
            var errorMsg = '';
            const fields = event.detail.fields;
            var errorKey;
            var targetDiv = '';
            var listRequriedErrorKey = this.listRequriedErrorKey;

            var regex1 = /^(\d{0,10}|)$/;
            //사업자등록번호 제어        
            var regex2 = /^(\d{10}|)$/;
            //법적상태 제어
            var regex3 = /^(\d{13}|)$/;
            //생년월일
            var regex4 = /^(?:[0-9]{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[1,2][0-9]|3[0,1]))$|^$/;
            //전화번호
            var regex5 = /^\d{2,3}-\d{3,4}-\d{4}$/;;
            //팩스번호 
            var regex6 = /^\d{2,3}-\d{3,4}-\d{4}$/;
            //약정회전일
            var regex7 = /^\d{1,3}$|^$/;
            //외형(정원)
            var regex8 = /^\d{0,11}$/;
            //종사업자번호 제어
            var regex9 = /^(\d{4}|)$/;

            // fields = event.getParam('fields');
            var isErrorTab = '';
            var basicErrorCount = 0;
            var finErrorCount = 0;
            var salesErrorCount = 0;
            errorKey = '';
            //유효성 검사
            listRequriedErrorKey = [];

            //Error가 발생한 Data-id를 담아놓는 List(다건 에러 처리시 포문 돌려서 사용)
            let errorDataidList = [];

            //입력한값에 대한 Validation
            //기본정보
            /**
             * 입력한값에 대한 Validation
             */
            //[기본정보] 
            if (this.objCustomer.PV_OLDCD__c && !regex1.test(this.objCustomer.PV_OLDCD__c)) {
                // let docu1 = this.template.querySelector('.PV_OLDCD');
                // let docu1 = this.template.querySelector('.PV_OLDCD');
                let docu1 = this.template.querySelector("[data-id='PV_OLDCD__c']");

                isError = true;
                isErrorTab = 'basic';
                errorMsg = '구코드(As-Is): 구코드는 10자리 이하의 숫자만 입력이 가능합니다.';
                errorKey = 'PV_OLDCD__c';

                if (!targetDiv) {
                    targetDiv = 'PV_OLDCD__c';
                }

                errorDataidList.push(errorKey);

            }
            else  if(this.objCustomer.PV_STCD2__c && !regex2.test(this.objCustomer.PV_STCD2__c)) {
                isError = true;
                isErrorTab = 'basic';
                errorMsg = '옳바른 형식의 사업자등록번호가 아닙니다. 10자리 숫자만 입력이 가능합니다.';
                errorKey = 'PV_STCD2__c';
                if (!targetDiv) {
                    targetDiv = 'PV_STCD2__c';
                }

                errorDataidList.push(errorKey);
            }

            // 유효성 검사 실패 시
            if(isError) {
                console.log('==============> isErrorTab : '+isErrorTab);
                console.log('==============> errorKey : '+errorKey);
                console.log('==============> isError : '+isError);
                console.log('==============> errorMsg : '+errorMsg);
                utilShowToast(errorMsg,'','warning');

                const style = document.createElement('style');

                style.innerText = `
                    c-meeting-modal .modal-container {
                        max-width: 1500px;
                    }
                `;

                // 에러 발생한 error-id로 스크롤 하는 메소드 추가
                this.errorScollMove(targetDiv);

                //에러 발생한 error-id에 slds-has-error class 할당 (단건 처리시)
                this.errorBoxChangeColor(targetDiv);
                
                // 에러 발생한 error-id에 slds-has-error class 할당 (다건 처리시)
                // this.errorBoxListChangeColor(errorDataidList);

            }else{
            //코드추가전
            //const fields = event.detail.fields;
            console.log('>>> 저장 Btn ' + JSON.stringify(event.detail.fields));
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            console.log('>>> 저장 Btn fields ' + fields);
            const baseUrl = window.location.origin;
            window.location.href = baseUrl+'/lightning/o/MDMRegRequestCustomer__c/list?filterName=Recent';
            }
        }else{
            utilShowToast('필수값을 입력해주세요','','warning');
            //utilShowToast('필수항목 미입력', missingColumns + '개를 추가적으로 입력하세요', 'warning');
        }
    }

    /**
     * 에러 발생한 data-id로 스크롤 이동하는 기능 담당 
     * @param {에러가 발생한 data-id값 전달} targetDiv 
     */
    errorScollMove(targetDiv)
    {
        let currentIdxRow = this.template.querySelector("[data-id='" + targetDiv + "']");
        if(currentIdxRow) {
            // 해당 돔으로 이동
            currentIdxRow.scrollIntoView({behavior: "smooth", block: "start", inline: "start"});
        }else {
            console.log('not!!');
        }
    }
    
    /**
     * 에러 발생한 data-id에 slds-has-error class 할당(단일)
     * @param {에러가 발생한 data-id값 전달} targetDiv 
     */
    errorBoxChangeColor(targetDiv){
        let targetComp = this.template.querySelector("[data-id='" + targetDiv + "']");

        if(targetComp) {
            // classList라는걸 쓰면 data-id로 찾은 dom에 class를 Add 할 수 있음
            targetComp.classList.add("slds-has-error");

        }else {
            console.log('==============> none target');
        }
    }
    /**
     * 에러 발생한 data-id에 slds-has-error class 할당(다건)
     * @param {에러가 발생한 data-id List 전달} targetDiv 
     */
    errorBoxListChangeColor(errorDataidList){
        if (errorDataidList.length > 0) {
            // errorDataidList 배열이 비어있지 않은 경우에만 루프 실행
            errorDataidList.forEach(dataId => {
                let targetComp = this.template.querySelector("[data-id='" + dataId + "']");
                if(targetComp) {
                    // classList라는걸 쓰면 data-id로 찾은 dom에 class를 Add 할 수 있음
                    targetComp.classList.add("slds-has-error");
                }
            });
          } else {
            console.log("errorDataidList 배열이 비어있습니다.");
          }
    }
}