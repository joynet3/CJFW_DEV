/**
 * @description       : 메뉴바(매출/채권관리) > 매출원장 클릭시 호출되는 페이지
 *                      cjfwSalesLedgerInfoPage
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-19-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification 
 * 1.0   08-07-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
import { LightningElement , wire , api, track } from 'lwc';
import getcommInfo from '@salesforce/apex/CommSearchDataController.getCommSearchData';
import { publish, subscribe ,unsubscribe , MessageContext } from 'lightning/messageService';
import CJFW_MENUTOCOMP_CHANNEL from '@salesforce/messageChannel/commActionMsgCh__c';
import CJFW_LISTTOPARENT_CHANNEL from '@salesforce/messageChannel/commListToParentCh__c';

// import mobileQuickActionChannel from '@salesforce/messageChannel/quikActionMsgCh__c';

export default class cjfwSalesLedgerInfoPage extends LightningElement {

    totalCnt = 0;
    // 매뉴탭 [CJFW_CommSearchData__c / MenuName__c 참조]
    menuSearch  = '매출원장';
    
    commSearchDataList=[];
    subscriptionListToParent = null;

    //LMS
    @wire(MessageContext)
    messageContext;
    
    @wire(getcommInfo,{menuSearch : '$menuSearch' })
    wireCommData({ error, data }){
        if(data){
            this.commSearchDataList = JSON.parse(JSON.stringify(data));
            this.handlePublish(); // Data 받아왔을때 Commheader 에 해당 데이터 넘겨줌 
        }else if(error){
            console.log(' error get wire data ->' , error);
        }
    }

    connectedCallback(){
        console.log('#cjfwSalesLedgerInfoPage # connected callback');
        this.handleSubscribe();
    }

    /* 
    [메세지 발행]
    구독자 : CommHeader / CommListView
     */
    handlePublish(){
        console.log('# cjfwSalesLedgerInfoPage  # handlePublish ->' , this.messageContext );
        /* const message = this.commSearchDataList; */
        const message = {
            searchData : this.commSearchDataList ,
            Title : '매출원장'
        }
        console.log('message', message);
        publish(this.messageContext , CJFW_MENUTOCOMP_CHANNEL , message);
    }

    /* 
    [메세지 구독] 
    발행처에서 가져온 데이터 확인 
    listview -> totalcnt 넘겨준것 확인
    */
    handleSubscribe(){
        console.log('#cjfwSalesLedgerInfoPage # handleSubscribe');
        if (!this.subscriptionListToParent){
            console.log(' list to parent 구독');
            this.subscriptionListToParent = subscribe(
                this.messageContext,
                CJFW_LISTTOPARENT_CHANNEL,
                (message)=>{
                    this.handleMessage(message);
                }
            );
        }
    }

    /* 
    전달받은값으로 어떤것을 할지 로직구현 부분 
    */
    handleMessage(message){
        this.totalCnt = message.totalCnt;
        console.log('totalCnt->', this.totalCnt);
    }


    /* 
    DOM 제거될때 구독취소
    */
    disconnectedCallback(){
        if (this.subscriptionListToParent) {
            unsubscribe(this.subscriptionListToParent);
            this.subscriptionListToParent = null;
        }
    }

    
}