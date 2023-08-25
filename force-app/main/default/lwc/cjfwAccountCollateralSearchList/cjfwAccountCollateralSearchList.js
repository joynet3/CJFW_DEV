/**
 * @description       : 
 * @author            : doyeon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 08-25-2023
 * @last modified by  : doyeon.kim@dkbmc.com
**/
import { LightningElement , wire , api, track } from 'lwc';
import { subscribe , unsubscribe, MessageContext } from 'lightning/messageService';
import { utilShowToast } from 'c/commUtils';
import CJFW_AccCollHEADERTOLIST_CHANNEL from '@salesforce/messageChannel/accCollateralHeaderToList__c';

export default class CjfwAccountCollateralSearchList extends LightningElement {

    //LMS
    @wire(MessageContext)
    messageContext;
    //담보별 Tab Show & Hide
    @track showTabSet = '';
    @track showGITab = '';
    @track showRETab = '';
    @track showBondTab = '';
    @track showTDTab = '';
    @track showCashTab = '';
    //Table Item 담보List 변수
    @track collParseDataList = [];//전체 담보 데이터
    @track GIItemList = [];//보증보험 데이터
    @track REItemList = [];//부동산 데이터
    @track TDItemList = [];//예적금 데이터
    @track BondItemList = [];//채권 데이터
    @track CashItemList = [];//현금 데이터
    @track departList = [];//부서별 배부 데이터
    @track totalCnt = '';//부서별 데이터
    //comma Field
    @track Actual = [];
    @track Total = [];
    @track Guarantee = [];
    @track Coll = [];
    @track FMColl = [];
    @track Mort = [];
    @track Deposit = [];
    @track Purcha = [];

    subscriptionHeaderToList = null;

    renderedCallback(){
        console.log('renderedCallback !!!!');
        this.commaCheck();
    }

/* 
    DOM 연결 -> 메세지 구독
    */
    connectedCallback(){
        console.log('#CjfwAccountCollateralSearchList # connected callback');
        this.handleSubscribe();
    }

    /* 
    발행처에서 가져온 데이터 확인 
    */
    handleSubscribe(){
        console.log('#cjfwAccountCollateralList # handleSubscribe');
        if (!this.subscriptionHeaderToList){
            console.log('Call header to List 구독');
            this.subscriptionHeaderToList = subscribe(
                this.messageContext,
                CJFW_AccCollHEADERTOLIST_CHANNEL,
                (message)=>{
                    this.collDataMessage(message);//담보
                    this.depDataMessage(message);//부서별
                }
            );
        }
    }

    /* 
    DOM 제거될때 구독취소
    */
    disconnectedCallback(){
        if (this.subscriptionHeaderToList) {
            unsubscribe(this.subscriptionHeaderToList);
            this.subscriptionHeaderToList = null;
        }
    }

    /*
    Header에서 서치한 dataList 확인
    tab에 뿌려주기
     */
    collDataMessage(message){
        console.log('collDataMessage ::::');
        //담보
        let collDataList = message.collParseDataList;
        console.log('collDataList->' , collDataList);
        for (let i = 0; i < collDataList.length; i++) {
            if (collDataList[i].ActualCollateralAmount__c != undefined) {
                let Actual        = collDataList[i].ActualCollateralAmount__c;
                console.log('actual Value ==>', Actual);
                console.log('actual Value ==>', Actual.toLocaleString());
                collDataList[i].ActualCollateralAmount__c = Actual.toLocaleString();
            }
            // this.Actual = Actual.toLocaleString();
            // let Total         = collDataList[i].TotalCollateralAmount__c;
            // let Guarantee     = collDataList[i].GuaranteeAmount__c;
            // let Coll          = collDataList[i].CollateralValue__c;
            // let FMColl        = collDataList[i].FM_CollateralValue__c;
            // let Mort          = collDataList[i].MortgageAmount__c;
            // let Deposit       = collDataList[i].Deposit__c;
            // let Purcha        = collDataList[i].PurchaseAmount__c;
        }
        this.collParseDataList = JSON.parse(JSON.stringify(collDataList));
        console.log('collParseDataList->' , this.collParseDataList.length);
        //데이터 갯수 Check
        if( this.collParseDataList.length === 0 ){
            console.log('$$$$$$$$타니1 collParseDataList  ----->' , this.collParseDataList );
            utilShowToast('거래처 담보 검색결과','검색된 담보가 없습니다.','warning');
        }
        //담보 종류에 맞게 필터링
        this.GIItemList     = this.collParseDataList.filter(item => item.RecordType.Name ==='GuaranteeInsurance');
        this.REItemList     = this.collParseDataList.filter(item => item.RecordType.Name ==='RealEstate');
        this.BondItemList   = this.collParseDataList.filter(item => item.RecordType.Name ==='Bond');
        this.TDItemList     = this.collParseDataList.filter(item => item.RecordType.Name ==='TimeDeposit');
        this.CashItemList   = this.collParseDataList.filter(item => item.RecordType.Name ==='Cash');
        //데이터 유무로 Tab 보여주기
        if (this.collParseDataList.length > 0) {
            console.log('# collParseDataList  ->' , this.collParseDataList.length );
            this.showTabSet = true;
        }
        if (this.GIItemList.length > 0) {
            console.log('# GIItemList  ->' , this.GIItemList.length );
            this.showGITab = true;
        }
        if (this.REItemList.length > 0) {
            console.log('# REItemList  ->' , this.REItemList.length );
            this.showRETab = true;
        }
        if (this.BondItemList.length > 0) {
            console.log('# BondItemList  ->' , this.BondItemList.length );
            this.showBondTab = true;
        }
        if (this.TDItemList.length > 0) {
            console.log('# TDItemList  ->' , this.TDItemList.length );
            this.showTDTab = true;
        }
        if (this.CashItemList.length > 0) {
            console.log('# CashItemList  ->' , this.CashItemList.length );
            this.showCashTab = true;
        }
        
    }

    //부서별 배부
    depDataMessage(message){
        console.log('depDataMessage ::::');
        let depart = message.departItemList;
        console.log('depart ->' , depart );
        this.departList = JSON.parse(JSON.stringify(depart));
        this.totalCnt = this.departList.length;
        console.log('this.totalCnt ----->' , this.totalCnt );
        if( this.totalCnt === 0 ){
            console.log('$$$$$$$$타니2 department ----->' , this.totalCnt );
            utilShowToast('부서별 배부 검색결과','검색된 부서별 배부가 없습니다.','warning');
        }
    }

    //담보Table 스크롤 시 왼쪽 Table 같이 스크롤 되게 함
    handleScroll(event) {
        let rightContainer = event.currentTarget;
        let leftDiv = this.template.querySelector('.ltable-container');
        leftDiv.scrollTop = event.currentTarget.scrollTop;
    
        let scrollxSize= rightContainer.offsetHeight - rightContainer.clientHeight;
        leftDiv.style.cssText = 'padding-bottom:'+scrollxSize+'px;';
    }

    //금액 콤마 넣기
    commaCheck(event){
        console.log('comma check 시작', this.collParseDataList);
        
        
        

    }

    searchCertiPage(event){
        console.log('----> 담보번호 클릭 <----');
        // location.href =  "/lightning/r/CJFW_CollateralEnrollment__c/" + this._id +"/view";
    }

}