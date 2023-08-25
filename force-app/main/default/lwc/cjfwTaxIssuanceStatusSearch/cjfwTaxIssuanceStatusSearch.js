import { LightningElement, track, api } from 'lwc';
import doDate from '@salesforce/apex/TaxIssuanceStatusSearchController.getTodayDate';
import doGetFirstDayOfMonth from '@salesforce/apex/TaxIssuanceStatusSearchController.getFirstDayOfMonthDate';
import doSearch from '@salesforce/apex/TaxIssuanceStatusSearchController.search';
import doCalloutInterface from '@salesforce/apex/TaxIssuanceStatusSearchController.calloutInterface';
import LightningModal from 'lightning/modal';
import CjfwAccountSearchModal from 'c/cjfwAccountSearchModal';
import CjfwTaxIssuanceNewModal from 'c/cjfwTaxIssuanceNewModal';
import CjfwTaxIssuanceCancelModal from 'c/cjfwTaxIssuanceCancelModal';
import CjfwTaxIssuanceManagementModal from 'c/cjfwTaxIssuanceManagementModal';



export default class CjfwTaxIssuanceStatusSearch extends LightningElement {
  @track searchKey = '';
  @track accountType = '';
  @track suOptions = [];
  @track showModal = false;
  @track isAllSelected = false;
  _selected = []; 
  IsShow = false;
  /**
   * IF로 보내줄 필터 데이터들
   */
  @track headComboVal;        // 본부
  @track suComboVal;          // SU
  @track teamComboVal;        // Team
  @track searchEmpNum;        // 사번
  @track firstDayOfMonthDate; // 발행일자 (달의 1일로 자동 셋팅)
  @track todayDate;           // ~발행일자 (오늘 날짜로 자동 셋팅)
  @track fromCreatdDate;      // 작성일자
  @track toCreatedDate;       // ~작성일자
  @track typeComboVal;        // 구분
  @track statusComboVal;      // 상태

  @track FilterHide='';       //show and hide
  
  /* 
  Show and Hide 기능 
  */
  showAndHide(){
    //this.FilterHide = !this.FilterHide;
   }
  
  connectedCallback(){
    /**
     * show and hide
     */
    this.FilterHide = true; 
     /**
     * 필터의 From발행일자을 달의 첫날로 Setting
     */
    doDate()
      .then(result => {
        console.log(JSON.stringify(result));
        this.todayDate = result;
      })
      .catch(error => {
      })
    /**
     * 필터의 to발행일자 오늘날짜로 Setting
     */
    doGetFirstDayOfMonth()
      .then(result => {
        console.log(JSON.stringify(result));
        this.firstDayOfMonthDate = result;
      })
      .catch(error => {
      })

    /**
     * fake데이터 만들어서 뿌려줌
     */   
    doSearch()
      .then(result => {
        //console.log(JSON.stringify(result));
        this.data = result;
      })
      .catch(error => {
      })
    }

  /**
  * 조회 버튼 위치 조정
  */  
  renderedCallback(){
    const style = document.createElement('style');
    
    style.innerText = `
    c-cjfw-tax-issuance-status-search .search-button-item {
      padding-top: 40px;
    }
    `;
    this.template.querySelector('lightning-layout-item').appendChild(style);
  }

  /**
  * Table Checkbox
  */   
  handleRowSelect(event) {
    const selectedId = event.target.dataset.id;
    this.data = this.data.map((item) => {
      if (item.id === selectedId) {
        item.isSelected = !item.isSelected;
      }
      return item;
    });

    this.isAllSelected = this.data.every((item) => item.isSelected);
  }
  handleSelectAll(event) {
    this.isAllSelected = event.target.checked;
    this.data = this.data.map((item) => {
      item.isSelected = this.isAllSelected;
      return item;
    });
  }

  /**
  * 본부/SU/Team/구분/상태 Selected onChange (나중에 Dependecy 작업예정)
  */   
  handleSelectedHead(event){
    this.headComboVal = this.template.querySelector('c-comm-custom-select').getSelectedValue();
    this.headComboVal =JSON.stringify(this.headComboVal);
    console.log('>>> Main head : ' + this.headComboVal);
  }
  handleSelectedSu(event){
    this.suComboVal = this.template.querySelector('c-comm-custom-select').getSelectedValue();
    this.suComboVal =JSON.stringify(this.suComboVal);
    console.log('>>> Main SU : ' + this.suComboVal);
  }
  handleSelectedTeam(event){
    this.teamComboVal = this.template.querySelector('c-comm-custom-select').getSelectedValue();
    this.teamComboVal =JSON.stringify(this.teamComboVal);
    console.log('>>> Main Team : ' + this.teamComboVal);
  }
  handleSelectedType(event){
    this.typeComboVal = this.template.querySelector('c-comm-custom-select').getSelectedValue();
    this.typeComboVal =JSON.stringify(this.typeComboVal);
    console.log('>>> Main 구분 : ' + this.typeComboVal);
  }
  handleSelectedStatus(event){
    this.statusComboVal = this.template.querySelector('c-comm-custom-select').getSelectedValue();
    this.statusComboVal =JSON.stringify(this.statusComboVal);
    console.log('>>> Main 상태 : ' + this.statusComboVal);
  }
  /**
  * 고객사/사번/발행일자~/작성일자~/ onChange
  */   
  changeHandleSearch(event){
    this.searchKey = event.detail.value;
    console.log('>>> Main 고객사 : ' + this.searchKey );
  }
  changeFromIssueData(event){
    this.firstDayOfMonthDate = event.detail.value;
    console.log('>>> Main 앞 발행일자 : ' + this.firstDayOfMonthDate );
  }
  changeToIssueData(event){
    this.todayDate = event.detail.value;
    console.log('>>> Main 뒤 발행일자 : ' + this.todayDate );
  }
  changeFromCreatedData(event){
    this.fromCreatdDate = event.detail.value;
    console.log('>>> Main 앞 작성일자 : ' + this.fromCreatdDate );
  }
  changeToCreatedData(event){
    this.toCreatedDate = event.detail.value;
    console.log('>>> Main 뒤 작성일자 : ' + this.statusComboVal );
  }

  /**
  *  조회 버튼 클릭 시, 필터에서 선택한 값을 담아서 Controller에 전달
  */   
    handleTaxbtn(){
      const params = {
        headComboVal         :  this.headComboVal,
        suComboVal           :  this.suComboVal,
        teamComboVal         :  this.teamComboVal,
        searchKey            :  this.searchKey,
        searchEmpNum         :  this.searchEmpNum,
        firstDayOfMonthDate  :  this.firstDayOfMonthDate,
        todayDate            :  this.todayDate,
        fromCreatdDate       :  this.fromCreatdDate,
        toCreatedDate        :  this.toCreatedDate,
        typeComboVal         :  this.typeComboVal,
        statusComboVal       :  this.statusComboVal
    };
    
    console.log('this.headComboVal 여기 무슨 값이야?' + this.headComboVal);
    console.log('>>> param ' + JSON.stringify(params));
    JSON.stringify(params);

    doCalloutInterface({ params : JSON.stringify(params) })
    .then(result => {
        console.log(JSON.stringify(result));
    })
    .catch(error => {
         console.log('error -> ', e);
    });
 
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
  *관리처 input field 에서 Enter 치면 호출
  *고객사 검색 모달 open
  */
  handleEnter(event){
    if(event.key === 'Enter'){
        this.openAccountModal();
    }
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
  * '신규발행' Btn Modal
  */  
  async handleNew() {
    console.log('>>> 보내줄 Data : headComboVal'        + this.headComboVal);
    console.log('>>> 보내줄 Data : suComboVal'          + this.suComboVal);
    console.log('>>> 보내줄 Data : teamComboVal'        + this.teamComboVal);
    console.log('>>> 보내줄 Data : searchKey'           + this.searchKey);
    console.log('>>> 보내줄 Data : searchEmpNum'        + this.searchEmpNum);
    console.log('>>> 보내줄 Data : firstDayOfMonthDate' + this.firstDayOfMonthDate);
    console.log('>>> 보내줄 Data : todayDate'           + this.todayDate);
    console.log('>>> 보내줄 Data : fromCreatdDate'      + this.fromCreatdDate);
    console.log('>>> 보내줄 Data : toCreatedDate'       + this.toCreatedDate);
    console.log('>>> 보내줄 Data : typeComboVal'        + this.typeComboVal);
    console.log('>>> 보내줄 Data : statusComboVal'      + this.statusComboVal);

    //1.Radio Modal로 보내고 -> 2.단건발행/일괄발행/대량발행/대량일괄발행에 보냄
    this.resultNew = await CjfwTaxIssuanceNewModal.open({
        size: 'small', //small, medium, large, and full 제공 됨
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
    });
    console.log(this.resultNew);
  }
  /**
  * '선택취소' Btn Modal
  */  
  async handleCancel() {
    console.log('>>> 보내줄 Data : headComboVal'        + this.headComboVal);
    console.log('>>> 보내줄 Data : suComboVal'          + this.suComboVal);
    console.log('>>> 보내줄 Data : teamComboVal'        + this.teamComboVal);
    console.log('>>> 보내줄 Data : searchKey'           + this.searchKey);
    console.log('>>> 보내줄 Data : searchEmpNum'        + this.searchEmpNum);
    console.log('>>> 보내줄 Data : firstDayOfMonthDate' + this.firstDayOfMonthDate);
    console.log('>>> 보내줄 Data : todayDate'           + this.todayDate);
    console.log('>>> 보내줄 Data : fromCreatdDate'      + this.fromCreatdDate);
    console.log('>>> 보내줄 Data : toCreatedDate'       + this.toCreatedDate);
    console.log('>>> 보내줄 Data : typeComboVal'        + this.typeComboVal);
    console.log('>>> 보내줄 Data : statusComboVal'      + this.statusComboVal);

    //1.Radio Modal로 보내고 -> 2.단건발행/일괄발행/대량발행/대량일괄발행에 보냄
    this.resultNew = await CjfwTaxIssuanceCancelModal.open({
        size: 'small', //small, medium, large, and full 제공 됨
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
    });
    console.log(this.resultNew);
  }
  
  /**
  * '수령자관리' Btn Modal
  */  
    async handleManagement() {
      console.log('>>> 보내줄 Data : headComboVal'        + this.headComboVal);
      console.log('>>> 보내줄 Data : suComboVal'          + this.suComboVal);
      console.log('>>> 보내줄 Data : teamComboVal'        + this.teamComboVal);
      console.log('>>> 보내줄 Data : searchKey'           + this.searchKey);
      console.log('>>> 보내줄 Data : searchEmpNum'        + this.searchEmpNum);
      console.log('>>> 보내줄 Data : firstDayOfMonthDate' + this.firstDayOfMonthDate);
      console.log('>>> 보내줄 Data : todayDate'           + this.todayDate);
      console.log('>>> 보내줄 Data : fromCreatdDate'      + this.fromCreatdDate);
      console.log('>>> 보내줄 Data : toCreatedDate'       + this.toCreatedDate);
      console.log('>>> 보내줄 Data : typeComboVal'        + this.typeComboVal);
      console.log('>>> 보내줄 Data : statusComboVal'      + this.statusComboVal);
  
      //1.Radio Modal로 보내고 -> 2.단건발행/일괄발행/대량발행/대량일괄발행에 보냄
      this.resultNew = await CjfwTaxIssuanceManagementModal.open({
          size: 'large', //small, medium, large, and full 제공 됨
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
      });
      console.log(this.resultNew);
    }
  /**
  * Table Colums
  */  
  columns = [
    { label: 'No.', fieldName: 'orderNo', type: 'text', editable: false },
    { label: '세금계산서 상태', fieldName: 'date', type: 'date', editable: false },
    { label: '에러메세지', fieldName: 'typeCode', type: 'number', editable: false },
    { label: '국세청 신고상태', fieldName: 'type', type: 'text', editable: false },
    { label: '이전 전자문서번호', fieldName: 'documentNo', type: 'text', editable: false },
    { label: '전자문서번호', fieldName: 'sellerCode', type: 'text', editable: false },
    { label: '고객코드', fieldName: 'sellerName', type: 'text', editable: false },
    { label: '고객사명', fieldName: 'managerCode', type: 'text', editable: false },
    { label: '팀명', fieldName: 'managerName', type: 'text', editable: false },
    { label: '담당MA', fieldName: 'suCode', type: 'text', editable: false },
    { label: '발행일', fieldName: 'suCode', type: 'text', editable: false },
    { label: '작성일', fieldName: 'suCode', type: 'text', editable: false },
    { label: '공급가액', fieldName: 'suCode', type: 'text', editable: false},
    { label: '세액', fieldName: 'suCode', type: 'text', editable: false },
    { label: '총액', fieldName: 'suCode', type: 'text', editable: false },
    { label: 'ASP 업체', fieldName: 'suCode', type: 'text', editable: false},
    { label: '계산서 구분', fieldName: 'suCode', type: 'text', editable: false},
    { label: '취소 여부', fieldName: 'suCode', type: 'text', editable: false}
  ];

  /**
  * combobox 본부
  */  
  @track headOfficeOptions = [
    { label: '미래성장사업본부'         , value: '미래성장사업본부'},
    { label: '유통사업총괄(영업)'       , value: '유통사업총괄(영업)'},
    { label: 'FS본부'                  , value: 'FS본부'},
    { label: '급식SU'                  , value: '급식SU'},
    { label: '상품·마케팅본부'          , value: '상품·마케팅본부'},
    { label: '해외유통'                , value: '해외유통'},
    { label: '외식SU'                  , value: '외식SU'},
    { label: '영업본부직속'             , value: '영업본부직속'},
    { label: '유통SU'                  , value: '유통SU'},
    { label: '축육혁신TF'               , value: '축육혁신TF'},
    { label: '기타'                     , value: '기타'},

  ];
  /**
  * combobox SU
  */  
  @track suOptions = [
    { label: 'FS중부운영1그룹'            , value: 'FS중부운영1그룹'},
    { label: 'FS남부운영그룹(영업)'       , value: 'FS남부운영그룹'},
    { label: 'FS서부사업부'               , value: 'FS서부사업부'},
    { label: 'FS레저운영그룹'             , value: 'FS레저운영그룹'},
    { label: 'FS전략사업부'               , value: 'FS전략사업부'},
    { label: 'FS병원운영그룹'             , value: 'FS병원운영그룹'},
    { label: 'FS개발사업부'               , value: 'FS개발사업부'},
    { label: 'FS컨세션운영그룹'           , value: 'FS컨세션운영그룹'},
    { label: 'FS중부운영2그룹'            , value: 'FS중부운영2그룹'},
    { label: '급식SU직속(원가절감)'       , value: '급식SU직속'},
    { label: '아이누리사업부'             , value: '아이누리사업부'},
    { label: '급실솔루션사업부'           , value: '급실솔루션사업부'},
    { label: '헬씨누리사업부(영업)'       , value: '헬씨누리사업부'},
    { label: '튼튼스쿨사업부'             , value: '튼튼스쿨사업부'},
    { label: '급식SU직속'                 , value: '급식SU직속'},
    { label: '상품본부'                   , value: '상품본부'},
    { label: '상품전략사업부'             , value: '상품전략사업부'},
    { label: 'MSC사업부'                  , value: 'MSC사업부'},
    { label: '마케팅담당'                 , value: '마케팅담당'},
    { label: '수출'                       , value: '수출'},
    { label: '해외유통사업'               , value: '해외유통사업'},
    { label: '외식SU직속(FO)'             , value: '외식SU직속'},
    { label: '외식남부사업부'             , value: '외식남부사업부'},
    { label: '외식남부사업부(FO)(영업)'   , value: '외식남부사업부'},
    { label: '외식중부사업부'             , value: '외식중부사업부'},
    { label: '외식중부사업부(FO)'         , value: '외식중부사업부'},
    { label: '디지털사업부'               , value: '디지털사업부'},
    { label: '외식SU직속'                 , value: '외식SU직속'},
    { label: '원료솔루션사업부'           , value: '원료솔루션사업부'},
    { label: '영업본부직속'               , value: '영업본부직속'},
    { label: '유통중부사업부'             , value: '유통중부사업부'},
    { label: '유통남부사업부'             , value: '유통남부사업부'},
    { label: '유통SU직속'                 , value: '유통SU직속'},
    { label: '축육도매사업부'             , value: '축육도매사업부'},
    { label: 'FO미트사업부(영업)'         , value: 'FO미트사업부'},
    { label: '축육SU'                     , value: '축육SU'},
    { label: '온라인사업부'               , value: '온라인사업부'},
    { label: '축육구매조직'               , value: '축육구매조직'},
    { label: '축육혁신TF'                 , value: '축육혁신TF'},
    { label: '전략기획담당'               , value: '전략기획담당'},
    { label: 'SCM혁신담당'                , value: 'SCM혁신담당'},
    { label: '전략지원담당'               , value: '전략지원담당'},
    { label: '인사담당'                   , value: '인사담당'},
    { label: '안전경영담당'               , value: '안전경영담당'},
    { label: '경영지원담당'               , value: '경영지원담당'},
    { label: '기타'                       , value: '기타'}
  ];    
  /**
  * combobox Team
  */  
  @track teamOptions = [
    { label: 'FS중부1)서울1지점'          , value: 'FS중부1)서울1지점'},
    { label: 'FS중부1)서울2지점'          , value: 'FS중부1)서울2지점'},
    { label: 'FS중부1)서울3지점'          , value: 'FS중부1)서울3지점'},
    { label: 'FS중부1)중부운영1그룹지원'   , value:'FS중부1)중부운영1그룹지원'},
    { label: 'FS경원)FS경원사업부'        , value: 'FS경원)FS경원사업부'},
    { label: 'FS중부1)인천지점'           , value: 'FS중부1)인천지점'},
    { label: 'FS서울)공유오피스'          , value: 'FS서울)공유오피스'},
    { label: 'FS남부)경북1지점'           , value: 'FS남부)경북1지점'},
    { label: 'FS남부)경북2지점'           , value: 'FS남부)경북2지점'},
    { label: 'FS남부)경남지점'            , value: 'FS남부)경남지점'},
    { label: 'FS남부)부산지점'            , value: 'FS남부)부산지점'},
    { label: 'FS남부)남부운영그룹지원'     , value:'FS남부)남부운영그룹지원'},
    { label: 'FS남부)충정1지점'           , value: 'FS남부)충정1지점'},
    { label: 'FS남부)충정2지점'           , value: 'FS남부)충정2지점'},
    { label: 'FS남부)충정3지점'           , value: 'FS남부)충정3지점'},
    { label: 'FS남부)호남지점'            , value: 'FS남부)호남지점'},
    { label: 'FS서부)지원(삭제)'          , value: 'FS서부)지원(삭제)'},
    { label: 'FS동부)동부직속'            , value: 'FS동부)동부직속'},
    { label: 'FS서부)제주지점(삭제)'      , value: 'FS서부)제주지점(삭제)'},
    { label: 'FS레저)레저운영그룹'        , value: 'FS레저)레저운영그룹'},
    { label: 'FS레저)레저1지점'           , value: 'FS레저)레저1지점'},
    { label: 'FS레저)레저2지점'           , value: 'FS레저)레저2지점'},
    { label: 'FS)동부1지점'               , value: 'FS)동부1지점'},
    { label: 'FS레저)레저서부지점'        , value: 'FS레저)레저서부지점'},
    { label: 'FS)레저동부2지점'           , value: 'FS)레저동부2지점'},
    { label: 'FS본부)특판매출'            , value: 'FS본부)특판매출'},
    { label: 'FS본부)쿠킹클래스'          , value: 'FS본부)쿠킹클래스'},
    { label: 'FS본부)FS기획팀'            , value: 'FS본부)FS기획팀'},
    { label: 'FS본부)FS인사팀'            , value: 'FS본부)FS인사팀'},
    { label: 'FS본부)서비스전문직관리파트' , value:'FS본부)서비스전문직관리파트'}, 
    { label: 'FS본부)복합화사업TF'        , value: 'FS본부)복합화사업TF'},
    { label: 'G-Project팀'               , value: 'G-Project팀'},
    { label: 'FS직속)Wework지점'          , value: 'FS직속)Wework지점'},
    { label: 'FS본부)기타'                , value: 'FS본부)기타'}
  ];
  /**
  * combobox Type
  */  
  @track typeOptions = [
    { label: '세금계산서 (주류제외)'      , value:'세금계산서 (주류제외)'},
    { label: '계산서 (주류제외)'          , value:'계산서 (주류제외)'},
    { label: '주류 세금계산서'            , value:'주류 세금계산서' },
    { label: '주류 계산서'                , value:'주류 계산서'},
  ];
  /**
  * combobox Status
  */  
  @track statusOptions = [
    { label: '공급자 발행'               , value: '공급자 발행'},
    { label: '공급받는자 반려'           , value: '공급받는자 반려'},
    { label: '공급받는자 승인'           , value: '공급받는자 승인'},
    { label: '공급자 발행취소'           , value: '공급자 발행취소'},
    { label: '오류발행'                 , value:  '오류발행'},
    { label: '발행요청'                 , value:  '발행요청'},
  ];
    
  //화면 fake 데이터
  @track data = [
    // { id: '1', date: '2023-07-31', typeCode: 12345, type: '유형 A', orderNo: 'ORDER-123', documentNo: 'DOC-456', sellerCode: 'SELLER-001', sellerName: '판매처 1', managerCode: 'MANAGER-001', managerName: '관리처 1', suCode: 'SU-001' },
    // { id: '2', date: '2023-07-30', typeCode: 67890, type: '유형 B', orderNo: 'ORDER-456', documentNo: 'DOC-789', sellerCode: 'SELLER-002', sellerName: '판매처 2', managerCode: 'MANAGER-002', managerName: '관리처 2', suCode: 'SU-002' },
    // { id: '3', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '4', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '5', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '6', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '7', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '8', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '9', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '10', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '11', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '12', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '13', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '14', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '15', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '16', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '17', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '18', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '19', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '20', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '21', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // { id: '22', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
    // // 추가 데이터 항목들...
  ]; 

}