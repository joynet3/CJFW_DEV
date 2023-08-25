import {  api , track , wire} from 'lwc';
import { utilShowToast } from 'c/commUtils';
import LightningModal from 'lightning/modal';
import doInit from '@salesforce/apex/CJFW_MDMReferenceCreateController.doInit';
import doSearch from '@salesforce/apex/CJFW_MDMReferenceCreateController.doSearch';
import { subscribe , unsubscribe, MessageContext , publish } from 'lightning/messageService';
import CJFW_ACCREFERENCETOMANAGEMENT_CHANNEL from '@salesforce/messageChannel/accReferenceToManagement__c';

export default class CjfwMDMReferenceCreateModal extends LightningModal {
    @track showModal = true;
    @api accountType; // 본점 or 관리처 or 판매처 
    @api message; 
    @track isAllSelected = false; //전체선택여부
    @track selectedId;
    

    //LMS
    @wire(MessageContext)
    messageContext;
    referencAccountData = [];
    referencToDivisionAccId;
    
    handlePublish(){
        console.log('# CjfwMDMReferenceCreateModal  # handlePublish ->' , this.messageContext );
        /* const message = this.commSearchDataList; */
        const message = {
            referencToDivisionAccId :this.referencToDivisionAccId
        }
        console.log('# CjfwMDMReferenceCreateModal  # message', message);
        publish(this.messageContext , CJFW_ACCREFERENCETOMANAGEMENT_CHANNEL , message);
    }

    /**
    * 로딩 시,
    */
    connectedCallback() {
        doInit()
        .then(result => {
            console.log(JSON.stringify(result));
            // doInit에서 받아온 결과를 data 배열에 추가

            for (let item of result) {
                this.data.push(item);
            }
        })
        .catch(error => {
            console.error(error);
        });
    }
    @track data = [];

    /**
    * Table Checkbox
    */   
    handleRowSelect(event) {
        this.selectedId = event.target.dataset.id;
        console.log('>>> 체크 됨' + this.selectedId);
        this.data = this.data.map((item) => {
        if (item.id === this.selectedId) {
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
    * Enter Key 클릭시 조회
    */
    handleEnter(event){
        console.log('엔터 => ', event.key); // 눌린 키의 문자 확인
        if(event.key === 'Enter'){
            this.handleSearch();
        }
    }

    /**
    * 검색 버튼 클릭 시 조회
    */
    handleSearch(){
        console.log('>>> 검색 Btn 클릭 ');
        let customerId = this.template.querySelector("[data-id='customerId']").value;
        let customerName = this.template.querySelector("[data-id='customerName']").value;
        let managerMA = this.template.querySelector("[data-id='managerMA']").value;

        console.log('>>> 고객ID ' + customerId);
        console.log('>>> 고객명(영문명 포함) ' + customerName);
        console.log('>>> 담당MA ' + managerMA);

        if(customerId || customerName || managerMA ) {
            doSearch({
            customerId : customerId,
            customerName : customerName,
            managerMA : managerMA
            })
            .then(result => {
                console.log(JSON.stringify(result));
                // doInit에서 받아온 결과를 data 배열에 추가
                this.data = [];
                for (let item of result) {
                    this.data.push(item);
                }
            })
            .catch(error => {
                console.error(error);
            });
        }
    }
    /* 
    * 선택 버튼 클릭 시 Account 화면에 뿌려줘야 할 데이터 가져오기
    */
    handleSelected(){
        console.log('>>> 선택 Btn 클릭 ');
        console.log('>>> this.selectedId ' + this.selectedId);
        if(this.selectedId) {
                this.referencToDivisionAccId = this.selectedId;
                console.log('>> this.referencAccountData ' + this.referencToDivisionAccId);
                this.handlePublish();
                this.close();
        }
    }
    // handlePublish(){
    //     console.log('# CjfwMDMReferenceCreateModal  # handlePublish ->' , this.messageContext );

    //     const message = {referencAccountData : this.referencAccountData}
    //     console.log('message', message);
    //     publish(this.messageContext , CJFW_MDMREFERENCECREATE_CHANNEL , message);
    // }

    /**
    * 취소 버튼 클릭 시,
    */
    handleClose(){
        this.close();
    }
}