/**
 * @description       : 메뉴바(매출/채권관리)  > 매출채권 현황 리포트
 *                      cjfwSalesReceivablesReportPage
 *                      <c-cjfw-sales-receivables-report-page>
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-22-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification 
 * 1.0   08-07-2023   eunyoung.choi@dkbmc.com   Initial Version
 * 1.1   08-07-2023   eunyoung.choi@dkbmc.com   TBD 예정페이지로 임시교체 > 추후 매출채권 현황 리포트 요건이 나오면 해당페이지에서 개발
**/

import { LightningElement , wire } from 'lwc';
import getcommInfo from '@salesforce/apex/CommSearchDataController.getCommSearchData';
import { publish, MessageContext } from 'lightning/messageService';
import CJFW_MENUTOCOMP_CHANNEL from '@salesforce/messageChannel/commActionMsgCh__c';

export default class cjfwSalesReceivablesReportPage extends LightningElement {

    menuSearch  = '매출채권현황리포트';
    
    commSearchDataList=[];

    //LMS
    
    @wire(MessageContext)
    messageContext;
    

    
    @wire(getcommInfo,{menuSearch : '$menuSearch' })
    wireCommData({ error, data }){
        if(data){
            this.commSearchDataList = JSON.parse(JSON.stringify(data));
            console.log(' success get wire data 2 ->' , this.commSearchDataList ); // controller 에서 가져온 헤더정보 
            this.handlePublish(); // Data 받아왔을때 Commheader 에 해당 데이터 넘겨줌 
        }else if(error){
            console.log(' error get wire data ->' , error);
        }
    }
    

    connectedCallback(){
        console.log('#cjfwSalesReceivablesReportPage # connected callback');
    }

    /* 
    메세지 발행
    구독 : CommHeader / CommListView
     */
   
    handlePublish(){
        console.log('# cjfwSalesReceivablesReportPage  # handlePublish ->' , this.messageContext );

        const message = {
            searchData : this.commSearchDataList ,
            Title : '매출채권 현황 리포트'
        }
        console.log('message', message);
        publish(this.messageContext , CJFW_MENUTOCOMP_CHANNEL , message);
    }
    





}