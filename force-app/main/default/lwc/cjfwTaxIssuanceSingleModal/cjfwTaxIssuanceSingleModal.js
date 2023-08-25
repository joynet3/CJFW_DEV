import { track, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import CjfwAccountSearchModal from 'c/cjfwAccountSearchModal';

export default class CjfwTaxIssuanceSingleModal extends LightningModal {
    @track showModal = true;
    @track issuanceTypeVal = '';
    @api selectedOption;
    @track searchKey = '';
    @track accountType = '';
    /**
    * 신규발행에서 전달 받을 데이터
    */
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
    @track singleHeadComboVal;
    @track singleHeadComboVal;
    @track singleheadComboVal;
    @track singlesuComboVal;
    @track singleteamComboVal;
    @track singlesearchKey;
    @track singlesearchEmpNum;
    @track singlefirstDayOfMonthDate;
    @track singletodayDate;
    @track singlefromCreatdDate;
    @track singletoCreatedDate;
    @track singletypeComboVal;
    @track singlestatusComboVal;


    // renderedCallback(){
    //     const style = document.createElement('style');
        
    //     style.innerText = `
            
    //         .cjfw-tax-single-modal .c-comm-custom-select.slds-form-element__label  {
    //             display: none !important;
    //         }
         
    //     }
    //     `;
    //     this.template.querySelector('lightning-card').appendChild(style);
    //     }
    /* 
    *관리처 input field 에서 Enter 치면 호출
    *고객사 검색 모달 open
    */
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
    
    connectedCallback(){
        /**
         * 부모(신규발행)에서 보내준 데이터 확인
         */
        console.log('>>> This Is Single Modal : headComboVal'        + this.headComboVal);
        console.log('>>> This Is Single Modal : suComboVal'          + this.suComboVal);
        console.log('>>> This Is Single Modal : teamComboVal'        + this.teamComboVal);
        console.log('>>> This Is Single Modal : searchKey'           + this.searchKey);
        console.log('>>> This Is Single Modal : searchEmpNum'        + this.searchEmpNum);
        console.log('>>> This Is Single Modal : firstDayOfMonthDate' + this.firstDayOfMonthDate);
        console.log('>>> This Is Single Modal : todayDate'           + this.todayDate);
        console.log('>>> This Is Single Modal : fromCreatdDate'      + this.fromCreatdDate);
        console.log('>>> This Is Single Modal : toCreatedDate'       + this.toCreatedDate);
        console.log('>>> This Is Single Modal : typeComboVal'        + this.typeComboVal);
        console.log('>>> This Is Single Modal : statusComboVal'      + this.statusComboVal);
        this.singleHeadComboVal           =         this.headComboVal;               
        this.singleSuComboVal             =         this.suComboVal;             
        this.singleTeamComboVal           =         this.teamComboVal;               
        this.singleSearchKey              =         this.searchKey;            
        this.singleSearchEmpNum           =         this.searchEmpNum;               
        this.singleFirstDayOfMonthDate    =         this.firstDayOfMonthDate;                      
        this.singleTodayDate              =         this.todayDate;            
        this.singleFromCreatdDate         =         this.fromCreatdDate;                 
        this.singleToCreatedDate          =         this.toCreatedDate;                
        this.singleTypeComboVal           =         this.typeComboVal;               
        this.singleStatusComboVal         =         this.statusComboVal;                 



        console.log('>>> this.singleHeadComboVal 후 : ' + this.singleHeadComboVal);
        
      }
    handleClose(){
        this.close();
    }
    handleAdd(){
        console.log('추가');
        this.close();
    }
    handleDelete(){
        console.log('삭제');
        this.close();
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
    @track nonPlationgOptions = [
        { label: '공급자 발행'               , value: '공급자 발행'},
        { label: '공급받는자 반려'           , value: '공급받는자 반려'},
        { label: '공급받는자 승인'           , value: '공급받는자 승인'},
        { label: '공급자 발행취소'           , value: '공급자 발행취소'},
        { label: '오류발행'                 , value:  '오류발행'},
        { label: '발행요청'                 , value:  '발행요청'},
    ];
    
    @track data = [
        { id: '1', date: '2023-07-31', typeCode: 12345, type: '유형 A', orderNo: 'ORDER-123', documentNo: 'DOC-456', sellerCode: 'SELLER-001', sellerName: '판매처 1', managerCode: 'MANAGER-001', managerName: '관리처 1', suCode: 'SU-001' },
        { id: '2', date: '2023-07-30', typeCode: 67890, type: '유형 B', orderNo: 'ORDER-456', documentNo: 'DOC-789', sellerCode: 'SELLER-002', sellerName: '판매처 2', managerCode: 'MANAGER-002', managerName: '관리처 2', suCode: 'SU-002' },
        { id: '3', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '4', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '5', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '6', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '7', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '8', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '9', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '10', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '11', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '12', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '13', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '14', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '15', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '16', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '17', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '18', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '19', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '20', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '21', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '22', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        // // 추가 데이터 항목들...
      ]; 
      @track producerDate = [
        { id: '등록번호', date: '2023-07-31', typeCode: 12345, type: '유형 A', orderNo: 'ORDER-123', documentNo: 'DOC-456', sellerCode: 'SELLER-001', sellerName: '판매처 1', managerCode: 'MANAGER-001', managerName: '관리처 1', suCode: 'SU-001' },
        { id: '종사업장번호', date: '2023-07-30', typeCode: 67890, type: '유형 B', orderNo: 'ORDER-456', documentNo: 'DOC-789', sellerCode: 'SELLER-002', sellerName: '판매처 2', managerCode: 'MANAGER-002', managerName: '관리처 2', suCode: 'SU-002' },
        { id: '상호', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '성명', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '사업장', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '업태', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '종목', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' },
        { id: '이메일', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' }

      ];
      @track supplierData = [
        
      ];

      @track itemData = [
        { id: '1', date: '2023-07-31', typeCode: 12345, type: '유형 A', orderNo: 'ORDER-123', documentNo: 'DOC-456', sellerCode: 'SELLER-001', sellerName: '판매처 1', managerCode: 'MANAGER-001', managerName: '관리처 1', suCode: 'SU-001' },
        { id: '2', date: '2023-07-30', typeCode: 67890, type: '유형 B', orderNo: 'ORDER-456', documentNo: 'DOC-789', sellerCode: 'SELLER-002', sellerName: '판매처 2', managerCode: 'MANAGER-002', managerName: '관리처 2', suCode: 'SU-002' },
        { id: '3', date: '2023-07-29', typeCode: 24680, type: '유형 C', orderNo: 'ORDER-789', documentNo: 'DOC-123', sellerCode: 'SELLER-003', sellerName: '판매처 3', managerCode: 'MANAGER-003', managerName: '관리처 3', suCode: 'SU-003' }
        // // 추가 데이터 항목들...
      ]; 
}