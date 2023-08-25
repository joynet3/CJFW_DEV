/**
 * @description       : 공통 리스트 뷰
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-22-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-04-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
import { LightningElement , wire , api, track } from 'lwc';
import { utilShowToast } from 'c/commUtils';
import { subscribe , unsubscribe, MessageContext , publish } from 'lightning/messageService';
import getDataList from '@salesforce/apex/CommSearchDataController.getDataList';
import CJFW_MENUTOCOMP_CHANNEL from '@salesforce/messageChannel/commActionMsgCh__c';
import CJFW_HEADERTOLIST_CHANNEL from '@salesforce/messageChannel/commHeaderToLsitCh__c';
import CJFW_LISTTOPARENT_CHANNEL from '@salesforce/messageChannel/commListToParentCh__c';

export default class cjfwCommListView extends LightningElement {

    //LMS
    @wire(MessageContext)
    messageContext;

    itemList =[];
    dataList =[];
    itemColumnList =[];
    modifiedDataList =[];
    resultMap =[];

    selectQuery ='';
    fromQuery ='';
    whereQuery ='';
    finalQuery ='';
    @track totalCnt = 0;
    @track isAllLoaded = true;
    @track isLoaded = true; // false일때 로딩걸림 

    subscriptionMenuToComp = null;
    subscriptionHeaderToList = null;

    columLength ='';
    openColumnOne = false;
    openColumnTwo = false;
    openColumnThree = false;
    openColumnFour = false;
    openColumnFive = false;
    openColumnSix = false;
    openColumnSeven = false;
    openColumnEight = false;
    openColumnNine = false;
    openColumnTen = false;



    /* 
    DOM 연결 -> 메세지 구독
    */
    connectedCallback(){
        console.log('#cjfwCommListView # connected callback');
        this.handleSubscribe();
    }

    /* 
    [메세지 발행]
    2번 상위 컴포넌트 
    */
    handlePublish(){
        console.log('# cjfwCommListView  # handlePublish ->' , this.messageContext );
        /* const message = this.commSearchDataList; */
        const message = {
            totalCnt :this.totalCnt
        }
        console.log('message', message);
        publish(this.messageContext , CJFW_LISTTOPARENT_CHANNEL , message);
    }

    /*
    [메세지 구독] 
    발행처에서 가져온 데이터 확인 
    */
    handleSubscribe(){
        console.log('#cjfwCommListView # handleSubscribe');
        if (!this.subscriptionMenuToComp){
            console.log(' menu to cmp 구독');
            this.subscriptionMenuToComp = subscribe(
                this.messageContext,
                CJFW_MENUTOCOMP_CHANNEL,
                (message)=>{
                    this.handleMessage(message);
                }
            );
        }
        if (!this.subscriptionHeaderToList){
            console.log('header to List 구독');
            this.subscriptionHeaderToList = subscribe(
                this.messageContext,
                CJFW_HEADERTOLIST_CHANNEL,
                (message)=>{
                    this.dataMessage(message);
                }
            );
        }

    }

    /* 
    DOM 제거될때 구독취소
    */
    disconnectedCallback(){
        if (this.subscriptionMenuToComp) {
            unsubscribe(this.subscriptionMenuToComp);
            this.subscriptionMenuToComp = null;
        }
        
        if (this.subscriptionHeaderToList) {
            unsubscribe(this.subscriptionHeaderToList);
            this.subscriptionHeaderToList = null;
        }
    }

    /* 
    전달받은값으로 어떤것을 할지 로직구현 부분 
    */
    handleMessage(message){
        this.itemList = message.searchData;
        console.log('list view sub Message->', this.itemList);
        this.columsHeader();
    }

    /*
     Header에서 입력받은  [where 조건절 받아서 전체 쿼리조합]
     controller 에 조합된 쿼리로 DATA 받아오기 
     */
    dataMessage(message){
        this.isLoaded = false;
        this.whereQuery = message.whereQuery;
        this.finalQuery = this.selectQuery + this.fromQuery + this.whereQuery;
        console.log('Final Query ->' , this.finalQuery );

        getDataList({finalQuery : this.finalQuery})
        .then(result =>{
            this.dataList = result;
            console.log('dataList ->' , this.dataList);
            this.isLoaded = true;
            //console.log('dataList length ->' , this.dataList.length);
            //this.totalCnt = this.dataList.length;
            this.changeParseList();
        }).catch(error =>{
            console.log('error -> ' , error);
        });
    }


    /* 
    LIST 의 Column 명 노출구간 [select 절]
    */
    columsHeader(){
        console.log('#cjfwCommListView # columsHeader');
        this.itemList = this.itemList.filter(item => item.Type__c === 'List' || item.Type__c === 'All');
        this.columLength = this.itemList.length 
        console.log(' this.columLength-> ' , this.columLength );
        console.log('itemList sorting 전 -> ', this.itemList);

        // order by integer Type 으로 변경해서 하기
        this.itemList.sort((a, b) => {
            const orderA = parseInt(a.ListOrder__c);
            const orderB = parseInt(b.ListOrder__c);
            
            if (orderA < orderB) {
                return -1;
            }
            if (orderA > orderB) {
                return 1;
            }
            return 0;
        });

        console.log('itemList sorting 후 -> ', this.itemList);



       /*  샘플
        this.itemList.sort((a,b)=> a.ListOrder__c.localeCompare(b.ListOrder__c)); // ListOrder컬럼 기준으로 order by 처리 
        console.log('itemList sorting 후 -> ', this.itemList);
         */







        // item.ListOrder__c  "13" 이런식으로 값이 들어가서 텍스트 형식으로 order by 가 되고 있는데 , number 타입으로 order by 가 되어야됨
        const apiNames = this.itemList.map(item => item.ApiName__c).filter(apiName => apiName);
        this.selectQuery = ' SELECT ' + apiNames.join(',');
        this.itemColumnList = apiNames.join(',');
        if (this.itemList[0].Object__c) {
            this.fromQuery = ' FROM ' + this.itemList[0].Object__c;
        }

/*         this.selectQuery = ' SELECT ' + this.itemList.map(item => item.ApiName__c).join(',');
        this.itemColumnList = this.itemList.map(item => item.ApiName__c).join(',');
        this.fromQuery = ' FROM ' + this.itemList[0].Object__c; */

        /* 추후 api 기준 중복제거 할거면 주석 해제 [S] */        
        /*         
        const distinctApiNames = [...new Set(this.itemList.map(item => item.ApiName__c))];
        console.log(' api 중복제거 ', distinctApiNames);

        this.itemList.sort((a,b)=> a.ListOrder__c.localeCompare(b.ListOrder__c)); // ListOrder컬럼 기준으로 order by 처리 
        this.selectQuery = ' SELECT ' + distinctApiNames.join(',');
        this.itemColumnList = distinctApiNames.join(',');
        this.fromQuery = ' FROM ' + this.itemList[0].Object__c; 
        */
        /* 추후 api 기준 중복제거 할거면 주석 해제 [E] */    
    }

    hideColumn(columName){
        const columnCells = this.template.querySelectorAll(`td[data-column="${columnName}"]`);
        for (const cell of columnCells) {
            cell.style.display = 'none';
        }
    }
    
    

    /* 
    [1] dataList 에서 __r 로 받아진 이중Array 값을 치환하여 하위 example 과 같이 치환 
    @ example : Account__r.컬럼명__c 
    [2] table Header 정보와 API정보 비교후 value값 치환 
    @ example : (column1 ,column2 ,column3 ,column4...)
    */
    changeParseList() {
        console.log('#cjfwCommListView # changeParseList');
        this.modifiedDataList=[];
        // [1]
        if (this.dataList && this.dataList.length > 0) {
            const extractedList = this.dataList.filter(record => {
                const newObject = {};
                for (const field in record) {
                    if (field.endsWith('__r')) {
                        // console.log('field->', field);
                        const extractedObject = record[field]; 
                        for (const innerField in extractedObject) {
                            newObject[field + "." + innerField] = extractedObject[innerField];
                    }
                    }else{
                        newObject[field] = record[field];
                    }
                }
                this.modifiedDataList.push(newObject);
                // console.log('modifiedData->', this.modifiedDataList);
            });
        }

        // [2] BILI_DOC_NO__c : "column9" ( key : value )
        this.resultMap = [];
        const items = this.itemColumnList.split(',');
        const modifiedDataList = this.modifiedDataList;

        items.forEach((item, index) => {
            const columnKey = "column" + (index + 1);
            this.resultMap[item] = columnKey;
        });
        const resultMap = this.resultMap;

        modifiedDataList.forEach(item => {
            for (const key in item) {
                if (key in this.resultMap) {
                    const columnKey = this.resultMap[key];
                    item[columnKey] = item[key];
                    delete item[key];
                }
            }
        });
        this.dataList = modifiedDataList;
        console.log(' 변환한 data List -> ', this.dataList);
        console.log(' 변환한 data List length-> ', this.dataList.length);
        if(this.dataList.length === 0){
            utilShowToast('검색결과','검색된 결과값이 없습니다.','warning');
        }
        this.totalCnt = this.dataList.length;
        this.handlePublish();

/*         this.columLength 이 9이면 column 1,2,3,4,5,6,7,8,9 다 Open되어야함
        this.columLength 이 6이면 column 1,2,3,4,5,6다 Open되어야함
        this.columLength 이 4이면 column 1,2,3,4다 Open되어야함
 */
        const numberToWordMap ={
            1:'One',
            2: 'Two',
            3: 'Three',
            4: 'Four',
            5: 'Five',
            6: 'Six',
            7: 'Seven',
            8: 'Eight',
            9: 'Nine',
            10: 'Ten'
        }

        const maxVisibleColumns = Math.min(this.columLength, 10); // 최대 10개 컬럼까지
        for (let i = 1; i <= maxVisibleColumns; i++) {
            const columnName = 'column' + i;
            const stateVariable = 'openColumn' + numberToWordMap[i]; // 이부분을 

            if (i <= this.columLength) {
                this[stateVariable] = true;
            } else {
                this.setOpenColumnState(columnName, stateVariable);
            }
            
        }
    
    }


    // 컬럼의 존재 여부에 따라 상태 변수를 동적으로 설정하는 함수
    setOpenColumnState(columnName, stateVariable) {
        if (this.dataList.some(items => items[columnName])) {
            this[stateVariable] = true;
            console.log(columnName + ' OPEN ->', this[stateVariable]);
        } else {
            this[stateVariable] = false;
        }
    }
        
}