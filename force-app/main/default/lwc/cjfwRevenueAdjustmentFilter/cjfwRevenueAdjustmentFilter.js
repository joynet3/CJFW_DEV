import { LightningElement, api, track } from 'lwc';

//Search Modal
import CjfwAccountSearchModal from 'c/cjfwAccountSearchModal';

export default class CjfwRevenueAdjustmentFilter extends LightningElement {

    @api
    isNotSeparate =  false; // 부모 자식 종속 여부

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
    { label: '급식SU직속(원가절감)'       , value: '급식SU직속(원가절감)'},
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
    { label: '외식SU직속(FO)'             , value: '외식SU직속(FO)'},
    { label: '외식남부사업부'             , value: '외식남부사업부'},
    { label: '외식남부사업부(FO)(영업)'   , value: '외식남부사업부(FO)'},
    { label: '외식중부사업부'             , value: '외식중부사업부'},
    { label: '외식중부사업부(FO)'         , value: '외식중부사업부(FO)'},
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

  @track typeOptions = [
      {"label":"상품 매출조정","value":"상품 매출조정"},
      {"label":"VoC 조정","value":"VoC 조정"},
      {"label":"마감 차액조정","value":"마감 차액조정"}
  ];


    today;

  connectedCallback() {
    this.today =  new Date();

  }

  handleSelected(event) {
    console.log(event.detail);
  }


  handleSearch(evnet) {
    console.log('조회버튼 클릭');
    console.log(
        JSON.parse(
        JSON.stringify(this.template.querySelector('.headOffice').getSelectedValue()))
    );

    let searchEvent =  new CustomEvent('search', {

    });

    this.dispatchEvent(searchEvent);

  }

  handleSave(event) {
    console.log('save버튼 클릭');

    let saveEvent = new CustomEvent('save', {

    });

    this.dispatchEvent(saveEvent);
  }


  renderedCallback() {
    if(!this._isInit) {
      let beforeMonth0fOneDay = new Date(this.today.getFullYear(), this.today.getMonth() - 1 , 1);
      let beforeMonthOfLastDay = new Date(this.today.getFullYear(), this.today.getMonth() , beforeMonth0fOneDay.getDate() - 1);
      // console.log('beforeMonth0fOneDay :: ', beforeMonth0fOneDay.toLocaleDateString());
      // console.log('beforeMonthOfLastDay :: ', beforeMonthOfLastDay.toLocaleDateString());

      this.template.querySelector('.fromDate').value = this.dateFormat(beforeMonth0fOneDay);
      this.template.querySelector('.toDate').value   = this.dateFormat(beforeMonthOfLastDay);
      this.template.querySelector('.dueDate').value  = this.dateFormat(this.today);
      

      this._isInit = true;
    }

  }

  handleSearchModalClick(event) {

    this.openAccountModal('.soldTo');
  }

   /* 
    거래처 검색 Component 호출 
    */
    async openAccountModal(className) {
      //console.log('openAccountModal !!!');
      let accCmp = this.template.querySelector('.soldTo');

      let result = await CjfwAccountSearchModal.open({
          size: 'medium',
          searchKey : accCmp.value,
          // accountType : this.accountType,
          // onclose : this.handleClose,
          message : 'FilterToCmp'
      })
      //then 문 추가시 return 필요
      .then(result => {
          if( result !=undefined ){
              if(result.length > 0) accCmp.value = result[0].CustomerID__c;
              return result;
          }
      });
      // if( result !=undefined ){
      //   if(result.length > 0) accCmp.value = result[0].CustomerID__c;
      // }
      // console.log('resutl check : ', JSON.stringify(result));
      // console.log('검색해온 거래처 코드 확인 //////');
    }


  dateFormat(date) {
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();

    return [year, month, day].join('-');
  }
}