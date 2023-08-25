import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getCategoryLevel1 from '@salesforce/apex/CjfwMDMManagementNewModalController.getCategoryLevel1';
import getCategoryLevel2 from '@salesforce/apex/CjfwMDMManagementNewModalController.getCategoryLevel2';
import getCategoryLevel3 from '@salesforce/apex/CjfwMDMManagementNewModalController.getCategoryLevel3';
import CjfwMDMManagementDivisionModal from 'c/cjfwMDMManagementDivisionModal';
import CjfwMDMManagementSecondaryModal from 'c/cjfwMDMManagementSecondaryModal';
import { utilShowToast } from 'c/commUtils';

export default class CjfwMDMManagementNewModal extends LightningElement {
    @track isShowMenu = false;
    @track issuanceTypeVal;
    @api testId = '111';
    @track isNextButtonDisabled = true;
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
    @track categoryLevel1Options = [];
    @track categoryLevel2Options = [];
    @track categoryLevel3Options = [];
    @track isLoading;
    @track IsShowDelivery;
    clickedNameKey;
  
    connectedCallback() {
       // 초기화

    Promise.all([getCategoryLevel1(), getCategoryLevel2()])
        .then(([result1, result2]) => {
            let data1 = [];
            for (let data of result1) {
                data1.push({ label: data.Name, value: data.Name });
            }
            this.categoryLevel1Options = data1;

            let data2 = [];
            for (let data of result2) {
                data2.push({ label: data.Name, value: data.Name, isSelected: false });
            }
            this.categoryLevel2Options = data2;

            // 데이터가 준비되었으므로 로딩 상태 해제
            this.isLoading = false;
            this.isShowMenu = true; // 화면 표시
        })
        .catch(error => {
            // 오류 처리
            this.isLoading = false; // 오류 발생 시 로딩 상태 해제
        });

    }
  
    handleLevel2Clicked(event){
      console.log('>>> Level2 클릭 시');
      
      const clickedRow = event.currentTarget;
      const rowIndex = clickedRow.getAttribute('data-index');
      const recordIndex = clickedRow.getAttribute('data-record');
      const clickedName = clickedRow.dataset.name; 
      this.clickedNameKey = clickedName;
      // console.log('>>> Clicked row index:', rowIndex);
      // console.log('>>> Clicked record index:', recordIndex);
      // console.log('>>> Clicked Name:', clickedName);

      this.getCategoryLevel3(clickedName);

      // ------------------ Lev2 선택 시 색깔변경  적용 시작! ------------------------------
      /**
       * visualforce에서 lwc호출 시, style(color)만 안먹음
       * innerText를 이용해 style(css)를 querySelector로 적용 함.
       * disabled가 버튼에 적용 안된 이유 : visualforcePage에서 important(최우선)으로 넣는다고 했기때문임
       */
      // 선택한 행의 배경색을 변경하는 스타일 요소 생성
      const style = document.createElement('style');
      
      style.innerText = `
          .clicked-row {
              background-color: #EB5F26 !important;
              border: 1px solid #EB5F26 !important;
          }
      `;
  
          
      // row2 클래스 포문돌려서 각각의 TR에 적용되어있는 .clicked-row 클래스 전부 제거 
      // 왜 ? 선택되지 않은 Lev2 TR은 색깔을 지워줘야함
      const rows = this.template.querySelectorAll('.row2');
      // console.log(JSON.stringify(rows));
      rows.forEach((v,i,a) => { // v는 Value, i는 Index, a는 Array
          a[i].classList.remove('clicked-row');
      });

      
      // 삭제한 다음 선택된 얘만 .clicked-row 클래스 적용
      // clickedRow는 event.currentTarget;
      clickedRow.classList.add('clicked-row');
      
      // 새로운 스타일 요소 추가
      this.template.querySelector('lightning-modal-body').appendChild(style);
      // ------------------ Lev2 선택 시 색깔변경  적용 끝! ------------------------------
 

      this.isNextButtonDisabled = false;

    } 

    getCategoryLevel3(value){
      getCategoryLevel3({
        pageMidCode : value
      })
      .then(result => {
                  let data3 = [];
                  console.log('>>> Level3 ' + JSON.stringify(result));
                  if(result.length > 0){
                      for(let data of result){                           
                          data3.push({ label: data.Name , value: data.Name })
                      } 
                      this.categoryLevel3Options = data3; //값이 있으면 true, 없으면 False 
                  }else{

                  }
              })
      .catch(errors => {
              //에러
              })
      .finally(()=> {
        // ------------------ Lev3 선택 시 색깔변경  적용 시작! ------------------------------
        const rows3 = this.template.querySelectorAll('.row3');
        rows3.forEach((v,i,a) => {
            a[i].classList.add('clicked-row');
        });   
        // 아래 코드 안 쓰는 이유 : 이미 handleLevel2Clicked 이벤트에서 적용해놔서 클래스만 넣어줘도 적용됨
        // this.template.querySelector('lightning-modal-body').appendChild(style);
        // ------------------ Lev3 선택 시 색깔변경  적용 끝! ------------------------------

      });



    }
    /**
    * 취소 버튼 클릭 시 
    */  
    handleClose(){
      console.log('>>> 관리처 생성Btn, 취소');
      const baseUrl = window.location.origin;
      window.location.href = baseUrl+'/lightning/o/MDMRegRequestCustomer__c/list?filterName=Recent';
    }
    
    /**
    * 다음 버튼 클릭 시
    */ 
    handleNext() {
        console.log('>>> test 모달 띄우는 중 ');
            this.isShowMenu = false;
            //Modal상속O
            if(this.clickedNameKey == '고객(관리처-분할) 생성 프로세스'){
                this.openDivisiojModal();
                console.log('여기1');
   
            }
            if(this.clickedNameKey == '고객(관리처-배송) 생성 프로세스'){
                //utilShowToast('개발중입니다. "관리처 - 분할"로 화면 확인 부탁드립니다.','','warning');
                this.openDivisiojModal();
                console.log('여기2');
   
            }
            if(this.clickedNameKey == '고객(관리처-2차) 생성 프로세스'){
                this.openSecondaryModal();
                console.log('여기3');
            }
        }

    /* 
    * 분할 모달 호출
    */
    async openDivisiojModal() {
        this.result = await CjfwMDMManagementDivisionModal.open({
            size: 'midium',

            message : 'FilterToCmp'
        }).then(result => {
        });
    }
    /* 
    * 2챠 모달 호출
    */
    async openSecondaryModal() {
        this.result = await CjfwMDMManagementSecondaryModal.open({
            size: 'midium',

            message : 'FilterToCmp'
        }).then(result => {
        });
    }
      

    // handleNext() {
    //     // 예시: 다음 버튼을 클릭하면 버튼을 비활성화하고 어떤 로직을 수행할 수 있습니다.
    //     this.isNextButtonDisabled = true;

    //     // 다른 로직 수행...
    // }
    
}