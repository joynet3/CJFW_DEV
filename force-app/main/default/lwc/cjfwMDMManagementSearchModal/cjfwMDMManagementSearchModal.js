import {  api , track , wire} from 'lwc';
import { utilShowToast } from 'c/commUtils';
import LightningModal from 'lightning/modal';

export default class CjfwMDMManagementSearchModal extends LightningModal {
    @api accountType; // 본점 or 관리처 or 판매처 
    @api searchKey; // 고객코드/명 
    @api message; 

    showModal = true;
    Title ='';
    helpText = '고객사코드 또는 고객사명을 입력해주세요.'
    EnterControl='';
    _selectData = [];


/*     columns = [
        { label: '고객사코드', fieldName: 'CustomerID__c', type: 'date', editable: false },
        { label: '고객사명', fieldName: 'searchKey__c', type: 'number', editable: false },
        { label: '사업자 번호', fieldName: 'CompanyRegisterNumber__c', type: 'text', editable: false },
        { label: '고객사 상태', fieldName: 'CustomerStatus__c', type: 'text', editable: false },
        { label: '고객사 담당 MA', fieldName: 'PIC__r.Name', type: 'text', editable: false },
        { label: '고객사 담당자 사번 ', fieldName: 'PICCode__c', type: 'text', editable: false },
    ]; */

    @track itemList = [];
    // 고객유형 
    @track customerType = [
        { label: '전체'         , value: '전체'   },
        { label: '본점'         , value: '본점'   },
        { label: '판매처'       , value: '판매처' },
        { label: '관리처'       , value: '관리처' }
    ];

    

    /* 
    DOM 연결 
    아무것도 입력하지 않을 경우 : 고객사검색 모달 (전체검색)
    input에서 값을 입력 받은 경우 : 타입별 조회 모달 (타입별검색)
    */
    connectedCallback() {
        console.log(' # CjfwMDMManagementSearchModal # connected call back ')
        console.log('accountType -> ' , this.accountType );
        console.log('searchKey -> ' , this.searchKey );

        if (!this.accountType && !this.searchKey) {
            this.Title = '조회 TEST';
            this.accountType='전체';
            console.log('1----->' , this.accountType);
        }else{
            this.Title = this.accountType + ' 조회';
        }

        if(this.message === 'FilterToCmp'){

            if(this.accountType !== undefined){
                console.log(' handle search======');
                this.handleSearch();
            }
        }
        // document.addEventListener('keyup', this.handleKeyUp);


    }

    /* 
    DOM 해제 
    */
    disconnectedCallback() {
        document.removeEventListener('keyup', this.handleKeyUp);
    }

    /*
    조회 클릭시 해당 매소드 호출 
    */
    handleSearch(){
        console.log(' # CjfwMDMManagementSearchModal # handleSearch   ')
        console.log(' # MDM 조회 searchKey -> ' , this.searchKey );
        console.log(' # MDM 조회 accountType -> ' , this.accountType );
        console.log(' # MDM 조회 message -> ' , this.message );
    //&& this.searchKey.trim() !== ""
        if(this.searchKey !== undefined) {
            console.log(' # accountType 2-> ' , this.accountType );
            this.message = '';
            console.log(' # message -> ' , this.message );
            /* this.accountType =''; */
            /* utilShowToast('검색결과','고객유형을 선택하세요','warning'); */

            // getAccInfo({
            //     searchKey : this.searchKey ,
            //     accountType : this.accountType
            // }).then(result => { 
            //     let parseData = JSON.parse(JSON.stringify(result));
            //     console.log('itemList -> ', parseData );
            //     this.records = parseData.length;
            //     console.log('data length -> ', this.records );
            //     this.totalCnt = this.records;
            //     this.itemList = parseData;
            //     if(this.records === 0){
            //         utilShowToast('검색결과','검색된 결과값이 없습니다.','warning');
            //     }
            // }).catch(e => {
            //     console.log('error -> ', e);
            // })
        
        }
    }



    /* 
    고객유형 변경시 , 고객코드/명 value 비우기 
    */
    onDataChange(event){
        console.log(' # CjfwMDMManagementSearchModal # onDataChange   ')
        /* this.searchKey =''; */
        this.accountType = event.target.value;
        console.log('   search Key ' ,this.searchKey);
        console.log('   accountType ' ,this.accountType);
    }

    /* 
    Enter Key 클릭시 조회
    */
    handleEnter(event){
        console.log('엔터 => ', event.key); // 눌린 키의 문자 확인
        if(event.key === 'Enter'){
            this.handleSearch();
        }
    }

    /* 
    고객코드/명 Data가 변경되었을 때 
    */
    codeDataChange(event){
        console.log(' # codeDataChange');
        this.searchKey = event.target.value;
        console.log('searchKey => ' , this.searchKey );
    }


    /* 
     DataTable 더블클릭시 해당 row의 item 값 전달
    */
     handleDoubleClick(event){
        console.log(' # handleDoubleClick');
        const clickedIndex = event.currentTarget.dataset.index;
        let selectedItem = this.itemList[clickedIndex];
        selectedItem = JSON.parse(JSON.stringify(selectedItem));
        this._selectData.push(selectedItem);

        console.log('클릭한 행의 데이터:', selectedItem);
        console.log('_selectData :', this._selectData );
        this.handleClose();
    }


    /*
    DataTable 클릭시  해당 row의 item 값 전달  
    */
    handleClick(event) {
        console.log(' # handleClick');
        const clickedIndex = event.currentTarget.dataset.index;
        let selectedItem = this.itemList[clickedIndex];
        selectedItem = JSON.parse(JSON.stringify(selectedItem));
        console.log('클릭한 행의 데이터:', selectedItem);
    }


    /* 
    취소 클릭시
    */
    handleClose(){
        console.log('# handleClose');
        this.close(this._selectData);
    }

}