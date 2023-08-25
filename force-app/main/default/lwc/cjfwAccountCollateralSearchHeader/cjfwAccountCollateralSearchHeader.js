/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 08-21-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
import { LightningElement ,wire , track} from 'lwc';
import { publish,  subscribe , MessageContext } from 'lightning/messageService';
import cjfwAccountSearchModal from 'c/cjfwAccountSearchModal';
import CJFW_AccCollHEADERTOLIST_CHANNEL from '@salesforce/messageChannel/accCollateralHeaderToList__c';

import { utilShowToast } from 'c/commUtils';
import getAccDamBoInfo from '@salesforce/apex/CJFW_AccountDamBoSearchController.getAccDamBoInfo';//담보 조회
import getAccCertiInfo from '@salesforce/apex/CJFW_AccountDamBoSearchController.getAccCertiInfo';//증서번호 조회
import getDepartInfo from '@salesforce/apex/CJFW_AccountDamBoSearchController.getDepartInfo';//부서별 배부 조회

export default class CjfwAccountCollateralSearchHeader extends LightningElement {

    //검색 변수
    @track searchKey = '';//Acc - CustomerID__c
    @track searchKeyName = '';//Acc - searchKey__c
    @track searchCertiCode = '';//증서번호
    @track Dambovalue = '외상물품대금';//담보구분val
    @track isEmptyOption = true;
    @track onselected = '';
    //Table Item 담보 별 변수
    collParseDataList = [];//전체 담보 데이터
    departItemList = [];//부서별 배부 데이터
    @track totalCnt = '';//부서별 데이터
    //검색필터 Show & Hide
    @track FilterTemplateHide= true;
    // 담보구분 select option
    @track options = [
        { label: '외상물품대금'     , value: '외상물품대금' },
        { label: '계약이행'         , value: '계약이행' }
    ];

    //LMS
    @wire(MessageContext)
    messageContext;

    handleSelectedDambo(event){
        this.onselected = event.target.value;
        this.Dambovalue = event.target.value;
        console.log('onselected >>>', this.onselected);
        console.log('Dambovalue >>>', this.Dambovalue);
    }
    
    /* 
    header to List
    검색해온 담보data => List cmp에 발행하기 
    */
    handlePublish(){
        console.log('# Search cjfwAccountCollateral  # handlePublish ->' , this.messageContext );
        const message = { 
            collParseDataList : this.collParseDataList , 
            departItemList : this.departItemList};
        console.log('message', message);
        publish(this.messageContext , CJFW_AccCollHEADERTOLIST_CHANNEL , message);
    }

    /* 
    자식에서 넘어온 Event 듣는곳 
    */
    setCustomEvent(){
        console.log('Check Parent Page');
        this.template.addEventListener('setSearchAcc', event =>{
            console.log('자식의소리 ' , event.detail.searchKey );
        });
    }
    

    /**
     * 거래처 입력 check
    */
    handleSearch(event){
        console.log('거래처 onChange');
        this.searchKey = event.target.value; //searchKey 넘겨주기 
        this.Dambovalue = event.detail.value;//event.target.label;
        console.log('searchKey => ' , this.searchKey);
        console.log('Dambovalue => ' , this.Dambovalue);
    }

    handleCertiCodeSearch(event){
        this.searchCertiCode = event.target.value;
        console.log('증서번호 입력 중>>> ',this.searchCertiCode);
    }

    handleCertiEnter(event){
        console.log('Enter handleCertiEnter => ', event.key); // 눌린 키의 문자 확인
        if(event.keyCode  === 13){
            this.searchAll();
        }
    }

    /**
     * 거래처 input field 에서 Enter 치면 호출
     */
    handleEnter(event){
        console.log('event key => ', event.key); // 눌린 키의 문자 확인
        if(event.key === 'Enter'){
            // this.openAccountModal();
            this.searchAll();
        }
    }

    /*
        고객 담보 조회 조건확인
    */
    searchAll(event){
        console.log( '-----------------searchAll ');
        console.log( this.searchKey,' /조회 버튼 click/ ',this.Dambovalue);
        console.log('증서번호 조회 확인 / ', this.searchCertiCode);
        
        if (this.searchCertiCode != '') { //증서 검색 조건확인
            console.log('Search CertiCode !!!');
            this.getCertiNum();
        }else if(this.searchKey == ''){ //거래처 & 담보 검색 조건 확인
            utilShowToast('필수항목 미입력','거래처 입력 후 다시 검색해주세요.','warning');
            
        }else if(this.searchKey != '' && this.Dambovalue != ''){//고객사 & 담보구분 확인
            console.log('Go Search Account Data => ',this.searchKey, ' + ', this.Dambovalue);
            this.getDambo();
        }
    }


    /*
        거래처 & 담보구분으로 고객 담보 조회
        CJFW_AccountDamBoSearchController 클래스
        getAccDamBoInfo 메서드
        getDepartInfo 메서드
    */
    getDambo(event){
        //부서별 배부
        getDepartInfo({
            searchKey : this.searchKey
        }).then(result =>{
            let deparseData = JSON.parse(JSON.stringify(result));
            // console.log('getDepartInfo Check ===> ', deparseData);
            this.departItemList = deparseData;
            // this.departItemList = result;
            console.log('departItemList @@@@@@@ ', this.departItemList);
            console.log('departItemList길이 @@@@@@@ ', this.departItemList.length);
            //this.handlePublish();
        })
        .catch(error => { 
            console.log('error -> ' , error);
        })
        .finally(()=>{
            //담보조회
            getAccDamBoInfo({
                searchKey : this.searchKey,
                Dambovalue : this.Dambovalue
            }).then(result => {
                let collParseData = JSON.parse(JSON.stringify(result));
                console.log('getAccDamBoInfo Check ===> ', collParseData);
                //종류 별 담보 나누기
                this.collParseDataList = collParseData;
                // this.collParseDataList = result;
                console.log('collParseDataList @@@@@@@ ', this.collParseDataList);
                console.log('collParseDataList길이 @@@@@@@ ', this.collParseDataList.length);
                // this.handlePublish();
            })
            .catch(error => { 
                console.log('error -> ' , error);
            })
            .finally(() => {
                // 리스트 2개 콘솔찍어보고 
                console.log('최종 collParseDataList-> ', this.collParseDataList);
                console.log('최종 this.departItemList-> ', this.departItemList);
                // 2개다 데이터값이 있으면 발행
                this.handlePublish();
            });

        });
    }
    

    /**
     * 증서번호로 보증보험 증서 조회
        CJFW_AccountDamBoSearchController 클래스
        getAccCertiInfo 메서드
    */
    getCertiNum(){
        console.log('증서번호 확인 / ', this.searchCertiCode);
        // utilShowToast('증서번호 미입력','증서번호 전체자리 입력 후 다시 검색해주세요.','warning');
        getAccCertiInfo({
            searchCertiCode : this.searchCertiCode
        }).then(result => {
            let collParseData = JSON.parse(JSON.stringify(result));
            console.log('getAccCertiInfo Check ===> ', collParseData);
            this.collParseDataList = collParseData;
            // this.collParseDataList = result;
            this.handlePublish();
            // this.GIItemList     = this.collParseDataList.filter(item => item.RecordType.Name ==='GuaranteeInsurance');
            // //데이터 유무로 Tab 보여주기
            // if (this.collParseDataList.length > 0) {
            //     console.log('# collParseDataList  ->' , this.collParseDataList.length );
            //     this.showTabSet = true;
            // }
            // if (this.GIItemList.length > 0) {
            //     console.log('# GIItemList  ->' , this.GIItemList.length );
            //     this.showGITab = true;
            // }else{
            //     utilShowToast('증서번호 검색결과','조회된 데이터가 없습니다.','warning');
            // }
        })
        .catch(error => { 
            console.log('error -> ' , error);
        });
    }

    /**
     * 거래처 input field 클릭 시 자동 모달 생성
    */
    openSearchAccModal(){
        console.log('거래처 필드 클릭');
        this.openAccountModal();
    }

    /* 
    Show and Hide 기능 
    */
    showAndHide(){
        this.FilterTemplateHide = !this.FilterTemplateHide;
    }

    /* 
    거래처 검색 Component 호출 
    */
    async openAccountModal() {
        console.log('openAccountModal !!!');
        this.result = await cjfwAccountSearchModal.open({
            size: 'medium',
            searchKey : this.searchKey,
            // accountType : this.accountType,
            // onclose : this.handleClose,
            message : 'FilterToCmp'
        }).then(result => {
            if( result !=undefined ){
                if(result.length > 0) {
                    this.searchKey = result[0].CustomerID__c;
                    this.searchKeyName = result[0].searchKey__c;
                }
            }
        });
        console.log('검색 check : ',this.searchKeyName);
        console.log('검색해온 거래처 코드 확인 //////', this.searchKey);
    }
}