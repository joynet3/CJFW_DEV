/**
 * @description       : 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-16-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-01-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CjfwAccountSearchModal from 'c/cjfwAccountSearchModal';
import MyMfodal from 'c/myModal';

export default class CjfwListViewSample extends LightningElement {
    @track searchKey = '';
    @track accountType = '';
    
    _selected = [];
    IsShow = false;
    
    get options() {
        return [
            { label: 'English', value: 'en' },
            { label: 'German', value: 'de' },
            { label: 'Spanish', value: 'es' },
            { label: 'French', value: 'fr' },
            { label: 'Italian', value: 'it' },
            { label: 'Japanese', value: 'ja' },
        ];
    }

      columns = [
        { label: '청구일자', fieldName: 'date', type: 'date', editable: false },
        { label: '유형코드', fieldName: 'typeCode', type: 'number', editable: false },
        { label: '유형', fieldName: 'type', type: 'text', editable: false },
        { label: '주문번호', fieldName: 'orderNo', type: 'text', editable: false },
        { label: '청구문서번호', fieldName: 'documentNo', type: 'text', editable: false },
        { label: '판매처코드', fieldName: 'sellerCode', type: 'text', editable: false },
        { label: '판매처명', fieldName: 'sellerName', type: 'text', editable: false },
        { label: '관리처코드', fieldName: 'managerCode', type: 'text', editable: false },
        { label: '관리처명', fieldName: 'managerName', type: 'text', editable: false },
        { label: 'SU코드', fieldName: 'suCode', type: 'text', editable: false }
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
        // 추가 데이터 항목들...
      ]; 
    


    picklistOptions = [
        { label: '옵션 1', value: 'Option1' },
        { label: '옵션 2', value: 'Option2' },
        { label: '옵션 3', value: 'Option3' },
      ];

    
    /* 
    자식에서 넘어온 Event 듣는곳 
    */
    setCustomEvent(){
        this.template.addEventListener('setSearchAcc', event =>{
            console.log('자식의소리 ' , event.detail.searchKey );
        });
    }
    
    onPicklistChange(event){
    this.selectedValue = event.detail.value;
    console.log('선택한 picklist -> ' + this.selectedValue );
    }

    handleSearch(event) {
        this.searchKey = event.target.value; //searchKey 넘겨주기 
        this.accountType = event.target.label;
        console.log('searchKey => ' , this.searchKey);
        console.log('accountType => ' , this.accountType);
        // this.showCjfwAccountSearchModal();
    }

    /* 
    관리처 input field 에서 Enter 치면 호출
    고객사 검색 모달 open
     */
    handleEnter(event){
        if(event.key === 'Enter'){
            this.openAccountModal();
        }
    }

    /* 전체 keyDown > Enter  */
    connectedCallback(){
        document.body.addEventListener('keydown', this.handleKeyDown);
    }
    /* 일반 Enter  */
    handleKeyDown(event){
        console.log(' 전체 엔터!!!! ');
    }

    disconnectedCallback() {
        window.removeEventListener('keydown', this.handleKeyDown);
    }

    /* 
    고객사 검색 Component 호출 
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
                // if(result.length > 0) this.searchKey = result[0].CustomerID__c;
                if(result.length > 0) this.searchKey = result[0].searchKey__c;
            }
        });
        console.log(this.result);
    }

    /* 
    취소 클릭시
    */
/*     handleClose(){
        console.log('# handleClose');
        this.close();
    } */



}