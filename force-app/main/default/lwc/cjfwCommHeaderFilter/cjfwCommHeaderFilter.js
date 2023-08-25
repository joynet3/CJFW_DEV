/**
 * @description       : cjfwCommHeaderFilter class 
 *                    : 공통 필터영역
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-22-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-07-2023   eunyoung.choi@dkbmc.com   Initial Version 
 * 1.1   08-18-2023   eunyoung.choi@dkbmc.com   account modal에서 선택된값 input 에 insert 되도록 수정 
 * 1.2   08-19-2023   eunyoung.choi@dkbmc.com   showAndHide css 로 컨트롤하는것으로 변경 
 * 1.3   08-21-2023   eunyoung.choi@dkbmc.com   containerPress 펑션추가 
**/
import { LightningElement ,wire , track} from 'lwc';
import { publish,  subscribe , unsubscribe ,  MessageContext } from 'lightning/messageService';

import { utilShowToast } from 'c/commUtils';
import cjfwAccountSearchModal from 'c/cjfwAccountSearchModal';
import getWhereQuery from '@salesforce/apex/CommSearchDataController.getWhereQuery';
import CJFW_MENUTOCOMP_CHANNEL from '@salesforce/messageChannel/commActionMsgCh__c';
import CJFW_HEADERTOLIST_CHANNEL from '@salesforce/messageChannel/commHeaderToLsitCh__c';

export default class cjfwCommHeaderFilter extends LightningElement {
    Title ='';

    /* 헤더 라인별 리스트  */
    @track oneLinefilteredList =[];
    @track twoLinefilteredList =[];
    @track threeLinefilteredList =[];
    @track fourLinefilteredList =[];

    /* 헤더전체데이터 */
    @track commSearchDataList = []; 

    @track selectboxData=[];
    filterDataList =[];      // Param List , track 쓰면 proxy 걸림
    requiredList=[]; // 필수값 컴럼항목
    @track whereQuery ='';          // where 절 반환값 

    /* Account modal return value */
    //searchKeyForAccount = '';    // 거래처 
    //searchKeyForManagement = ''; // 관리처 
    //searchKeyForSeller = '';     // 판매처 
    // accountCode =''; // 고객사 코드

    requiredFields = [
        { label: '거래처', key: 'searchKeyForAccount' },
        { label: '관리처', key: 'searchKeyForManagement' },
        { label: '판매처', key: 'searchKeyForSeller' }
    ];

    @track FilterHide= true;
    // @track AccModalShow =''; 
    @track orgOptionList;  // 본부
    @track suOptionList;   // SU
    @track teamOptionList; // TEAM
    @track largeOptionList;  // 고객대경로
    @track searchKey ='';
    
    //LMS
    @wire(MessageContext)
    messageContext;

    subscription = null;

    /* 
    DOM 연결 -> 메세지 구독
    */
    connectedCallback(){
        console.log('#cjfwCommHeaderFilter # connected callback');
        this.FilterHide = true;
        this.handleSubscribe();

        //slds-wrap 제거
        this.adjustCustomSelectBoxStyle();
    }

    /* 
    DOM 제거될때 구독취소
    */
    disconnectedCallback(){
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }
    

    /*
    모바일화면에서 CSS 잘나오게 하기위해 제거
    */
    adjustCustomSelectBoxStyle() {
        const customSelectBox = this.template.querySelector('.customSelectBox');
        if (customSelectBox) {
            customSelectBox.classList.remove('slds-wrap');
        }
    }

    /* 
    [구독]
    발행처에서 가져온 데이터 확인 
    */
    handleSubscribe(){
        console.log('#cjfwCommHeaderFilter # handleSubscribe');
        if (this.subscription){
            console.log('구독여부')
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            CJFW_MENUTOCOMP_CHANNEL,
            (message) => {
                this.handleMessage(message);
            }
        );
    }

    /* 
    [발행] header to List
    where 절 반환값 commList 에 발행하기 
    */
    handlePublish(){
        console.log('# cjfwSalesLedgerInfoPage  # handlePublish ->' , this.messageContext );
        const message = { whereQuery : this.whereQuery};
        publish(this.messageContext , CJFW_HEADERTOLIST_CHANNEL , message);
    }

    /* 
    메뉴바 cjfwCommMenubar > Header 전송한 CommDataList 정보 : 타이틀정보 
    */
    handleMessage(message){
        this.commSearchDataList = message.searchData;
        this.Title = message.Title;
        this.headerLines();
    }

    /*
    필드 클릭시 
    */
    onclickData(event){
        console.log('#cjfwCommHeaderFilter # onclickData');
        this.searchKey ='';
        this.accountType = event.currentTarget.label;
    }

    /* reset 버튼 클릭시 */
    resetbutton(){
        console.log ('#resetbutton');
        const inputFields = this.template.querySelectorAll('lightning-input');
        inputFields.forEach(field => {
            field.value = '';
        });
        this.filterDataList = [];
    }

    /* customSelectBox 클릭시 */
    handleSelected(event){
        console.log('#cjfwCommHeaderFilter # handleComboBoxChange');
        this.teamComboVal = this.template.querySelector('c-comm-custom-select').getSelectedValue();
        this.teamComboVal =JSON.stringify(this.teamComboVal);
        console.log('>>> Main Team : ' + this.teamComboVal);

        console.log('LABEL값', event.currentTarget.label);
        console.log('선택된값 ', event.detail.value);
        const apiName = event.currentTarget.getAttribute('data-field-name');
       console.log('apiName ->' , apiName);
    }

    /*
    헤더에서 데이터 입력시  [원본]
    */
   onDataChange1(event){
        //this.searchKey ='';
       console.log('#cjfwCommHeaderFilter # onDataChange');

       const apiName = event.currentTarget.getAttribute('data-field-name');
       console.log('apiName ->' , apiName);

       const objName = event.currentTarget.getAttribute('data-object-name');
       console.log('objName ->' , objName);

       const fieldType = event.currentTarget.getAttribute('data-field-type');
       console.log('fieldType ->' , fieldType);

       const datePointData = event.target.getAttribute('data-date-point');
       console.log('datePoint ->' , datePointData );

       this.searchKey = event.target.value;   // Accout 모달 값넘기기 
       console.log('searchKey 1 -> ', this.searchKey);
       

       const searchKey = event.target.value;   

        if(apiName !== null && objName !=null){
            // 이미 동일한 apiName 값이 있는지 확인
            const existingIndex = this.filterDataList.findIndex(item => item.apiName === apiName );

            console.log('existingIndex=> ', existingIndex );
            // apiName 값이 동일한 것이 있으면 , 기존 list dptj searchKey만 change 
            if (existingIndex !== -1) {
                // this.filterDataList[existingIndex].searchKey =searchKey;
                 console.log(' existingIndex => ', existingIndex); 
                    if (existingDatePointIndex === -1) {
                        this.filterDataList.push({ apiName, objName, fieldType, datePointData, searchKey });
                        console.log('수정 input 값 DATE => ', this.filterDataList);
                    } else {
                        this.filterDataList[existingDatePointIndex].searchKey = searchKey;
                        console.log('수정 List => ', this.filterDataList);
                    }
 
            }else{
                    this.filterDataList.push({apiName,objName,fieldType,datePointData,searchKey});
                    console.log(' 처음찍히는것들  List 2=> ', this.filterDataList);
            } 
        }

        console.log('searchKey final -> ', this.searchKey);
        this.accountType = event.target.label; // Accout 모달 값넘기기 
    }

    onDataChange(event){
        //this.searchKey ='';
       console.log('#cjfwCommHeaderFilter # onDataChange');

       const apiName = event.currentTarget.getAttribute('data-field-name');
       console.log('apiName ->' , apiName);

       const objName = event.currentTarget.getAttribute('data-object-name');
       console.log('objName ->' , objName);

       const fieldType = event.currentTarget.getAttribute('data-field-type');
       console.log('fieldType ->' , fieldType);

       const datePointData = event.target.getAttribute('data-date-point');
       console.log('datePoint ->' , datePointData );

       this.searchKey = event.target.value;   // Accout 모달 값넘기기 
       console.log('searchKey 1 -> ', this.searchKey);
       

       const searchKey = event.target.value;   

       if (apiName !== null && objName != null) {
        // 이미 동일한 apiName 값이 있는지 확인
        const existingIndex = this.filterDataList.findIndex(item => item.apiName === apiName);
    
        console.log('existingIndex=> ', existingIndex);
        // apiName 값이 동일한 것이 있으면, 기존 list의 searchKey만 변경
        if (existingIndex !== -1) {
            // this.filterDataList[existingIndex].searchKey = searchKey;
            console.log('existingIndex => ', existingIndex);
    
            if (datePointData !== null && fieldType === 'date') {
                const existingStartDateIndex = this.filterDataList.findIndex(item => item.apiName === apiName && item.fieldType === 'date' && item.datePointData === 'start');
                const existingEndDateIndex = this.filterDataList.findIndex(item => item.apiName === apiName && item.fieldType === 'date' && item.datePointData === 'end');
    
                if (datePointData === 'start') {
                    if (existingStartDateIndex !== -1) {
                        this.filterDataList[existingStartDateIndex].searchKey = searchKey;
                    } else {
                        this.filterDataList.push({ apiName, objName, fieldType, datePointData, searchKey });
                    }
                    console.log('수정 List => ', this.filterDataList);
                } else if (datePointData === 'end') {
                    if (existingEndDateIndex !== -1) {
                        this.filterDataList[existingEndDateIndex].searchKey = searchKey;
                    } else {
                        this.filterDataList.push({ apiName, objName, fieldType, datePointData, searchKey });
                    }
                    console.log('수정 List => ', this.filterDataList);
                }
            } else {
                this.filterDataList[existingIndex].searchKey = searchKey;
                console.log('수정 List => ', this.filterDataList);
            }
    
        } else {
            this.filterDataList.push({ apiName, objName, fieldType, datePointData, searchKey });
            console.log('처음 찍히는 것들 List => ', this.filterDataList);
        }
    }
        console.log('searchKey final -> ', this.searchKey);
       this.accountType = event.target.label; // Accout 모달 값넘기기 
    }
    
    /* 
    조회 클릭시
    Controller 에서 조회에 관한 입력값에 대한 WHERE 절 반환 받음 
    */
    searchbutton(){
        console.log('#cjfwCommHeaderFilter # searchbutton');
        // this.requiredCheck();
        getWhereQuery({ filterDataList : this.filterDataList})
        .then(result => {
            this.whereQuery = result;
            console.log('whereQuery -> ' , this.whereQuery );
            this.handlePublish();
        })
        .catch(error => { 
            console.log('error -> ' , error);
        });
    }

    
    /*
    엔터 검색시 
    */
    handleEnter(event){
        console.log('#cjfwCommHeaderFilter # handleEnter');
        console.log('Focused input:', event.currentTarget.label);
        if ( event.key === 'Enter' && (event.currentTarget.label === '관리처' || event.currentTarget.label === '거래처' || event.currentTarget.label === '판매처')) {
            this.openAccountModal();
        }else if(event.keyCode == 13){
            console.log(' 화면 엔터 ');
            this.searchbutton();
        }
    }

    /*
    23.08.21
    allContainer 에서 Enter 시에 전체검색되도록 추가
    */
    containerPress(event){
        console.log('#cjfwCommHeaderFilter # containerClick');
        console.log('event KeyCode ->', event.keyCode );
        console.log('event KeyCode ->', event.key );
        if(event.keyCode == 13){
            console.log(' 화면 엔터 ');
            this.requiredCheck();
        }
    }

    /* 
    필수값 체크
    */
    requiredCheck() {
        this.requiredList = this.commSearchDataList.filter(item => item.Required__c);
        console.log('requiredList ->', this.requiredList);
        let allRequiredValuesEntered = true;
    
        for (const requiredItem of this.requiredList) {
            const specialField = this.requiredFields.find(field => field.label === requiredItem.Label__c);
            let datematch = null;
    
            if (!specialField && requiredItem.FieldType__c === 'date') { // 등록일자 / 시작일자
                datematch = this.filterDataList.find(item => item.apiName === requiredItem.ApiName__c && item.datePointData === requiredItem.DatePoint__c);
                console.log('datematch---> ', datematch);
    
                if (!datematch || !datematch.searchKey) {
                    console.log('필수값 미입력1', requiredItem.Label__c);
                    utilShowToast('필수항목 미입력', requiredItem.Label__c + ' 입력 후 다시 검색해주세요.', 'warning');
                    allRequiredValuesEntered = false;
                }
            }
             else if (!specialField) { // 바코드 
                const matchingFilterItem = this.filterDataList.find(item => item.apiName === requiredItem.ApiName__c);
                if (!matchingFilterItem || !matchingFilterItem.searchKey) {
                    console.log('필수값 미입력2', requiredItem.Label__c);
                    utilShowToast('필수항목 미입력', requiredItem.Label__c + ' 입력 후 다시 검색해주세요.', 'warning');
                    allRequiredValuesEntered = false;
                }
            } 

            else if (!this[specialField.key]) { // 거래처
                console.log('필수값 미입력3', requiredItem.Label__c);
                utilShowToast('필수항목 미입력', requiredItem.Label__c + ' 입력 후 다시 검색해주세요.', 'warning');
                allRequiredValuesEntered = false;
            }
        }
    
        if (allRequiredValuesEntered) {
            this.searchbutton();
        }
    }
    
    
    

  
    /* 
    Header 라인에 따라서 list 담아주기 
    */ 
    headerLines() {
        console.log('# header Line Setting ');
    
        const lineNumbers = ['one', 'two', 'three', 'four'];
    
        lineNumbers.forEach((lineNumber, index) => {
            /* 조건에 맞는 값들 헤더리스트에 세팅 */

            this[`${lineNumber}LinefilteredList`] = this.commSearchDataList.filter(item =>
                item.HeaderLine__c === (index + 1).toString() && item.FieldType__c !== 'customComboBox'
            );
    
            const comboList = this.commSearchDataList.filter(item =>
                item.HeaderLine__c === (index + 1).toString() && item.FieldType__c === 'customComboBox'
            );
            
            /* 라인에따라서 보여줄 comboBox 체크  */
            this[`${lineNumber}showOrgOption`] = this.checkComboOption(comboList, '본부');
            this[`${lineNumber}showSuOption`] = this.checkComboOption(comboList, 'SU');
            this[`${lineNumber}showTeamOption`] = this.checkComboOption(comboList, 'TEAM');
            this[`${lineNumber}showLargeOption`] = this.checkComboOption(comboList, '고객대경로');
    
        });
    
        const selectboxData = this.commSearchDataList.filter(item =>
            item.OptionLabel__c !== undefined && item.OptionValue__c !== undefined
        );
    
        if (selectboxData.length > 0) {
            this.selectboxData = selectboxData;
            //console.log('# selectboxSetting start ->', this.selectboxData);
            this.selectboxSetting(this.selectboxData);
        }
    }
    
    checkComboOption(comboList, label) {
        return comboList.some(item => item.Label__c === label);
    }

    /* 
    CommData Selectbox Setting
    <c-comm-custom-select> 컴포넌트에 보내줄 Option과 Value 세팅해주는 펑션 
    */
    selectboxSetting(selectboxData){
        console.log('#cjfwCommHeaderFilter # selectboxSetting' );

        const customComboBoxMapping = {
            '본부': 'orgOptionList',
            'SU': 'suOptionList',
            'TEAM': 'teamOptionList',
            '고객대경로': 'largeOptionList'
        };
        
        for (const label in customComboBoxMapping) {
            if (this.selectboxData.some(item => item.Label__c === label && item.FieldType__c === 'customComboBox')) {
                const filteredData = this.selectboxData.filter(item => item.Label__c === label && item.FieldType__c === 'customComboBox');
        
                const Label = filteredData.map(item => item.OptionLabel__c);
                const Value = filteredData.map(item => item.OptionValue__c);
        
                const combinedArray = Label.flatMap(value => {
                    const labels = value.split(',').map(val => ({ label: val.trim() }));
                    const values = Value.flatMap(val => val.split(',').map(v => ({ value: v.trim() })));
                    return labels.map((label, index) => ({ ...label, ...values[index] }));
                });
        
                // console.log(`${label} 픽리스트 -> `, combinedArray);
                this[customComboBoxMapping[label]] = combinedArray;
            }
        }

    }

    /* 
    Show and Hide 기능 
    */
    showAndHide(){
        // this.FilterHide = !this.FilterHide;
        const allContainer = this.template.querySelector('.allContainer');
        if (allContainer) {
            allContainer.classList.toggle('hideStyle');
        }
    }

    /* 
    [1] 고객사 검색 Component 호출 
    */
    async openAccountModal() {
        //console.log('1 openAccountModal >' , this.accountType);
        //console.log('1 searchKey >' , this.searchKey);
        this.result = await cjfwAccountSearchModal.open({
            size: 'medium',
            searchKey : this.searchKey,
            accountType : this.accountType,
            // onclose : this.handleClose,
            message : 'FilterToCmp'
        }).then(result => {
            //onsole.log('Acc 모달 close 1>' , this.searchKey);
            //onsole.log('Acc 모달 close 2>' , this.accountType);

            if (result != undefined && result.length > 0) {
                switch (this.accountType) {
                    case '거래처':
                        console.log('1');
                        this.searchKeyForAccount = result[0].searchKey__c;
                        this.accountCode= result[0].CustomerID__c; // 코드
                        this.accountType = result[0].CustomerType__c; // 유형
                        this.accountName = result[0].Name; // 이름
                        break;
                    case '관리처':
                        console.log('2');
                        this.searchKeyForManagement = result[0].searchKey__c;
                        break;
                    case '판매처':
                        console.log('3');
                        this.searchKeyForSeller = result[0].searchKey__c;
                        break;
                    default:
                        break;
                }
            }
            this.updateFilteredList();
        });
    }

    /* 
    [2] openAccountModal 이후 반환된 result 에 따라서 value값 세팅하기 
    */
    updateFilteredList() {
        console.log(' # updateFilteredList' );
        this.oneLinefilteredList = this.updateListValues(this.oneLinefilteredList);
        //console.log('this.oneLinefilteredList =>', JSON.parse(JSON.stringify(this.oneLinefilteredList)));
        this.twoLinefilteredList = this.updateListValues(this.twoLinefilteredList);
        //console.log('this.twoLinefilteredList =>', this.twoLinefilteredList);
        
        
        this.threeLinefilteredList = this.updateListValues(this.threeLinefilteredList);
        //console.log('this.threeLinefilteredList =>', this.threeLinefilteredList);
        this.fourLinefilteredList = this.updateListValues(this.fourLinefilteredList);
        //console.log('this.fourLinefilteredList =>', this.fourLinefilteredList);
        //console.log('this.fourLinefilteredList =>', JSON.parse(JSON.stringify(this.fourLinefilteredList)));

    }

    /* 
    [3] value값 세팅하기 
    */
    updateListValues(list) {
        console.log(' # updateListValues' );


        //console.log(' value 세팅 1' , this.searchKeyForAccount );
        //console.log(' value 세팅 2' , this.searchKeyForManagement );
        //console.log(' value 세팅 3' , this.searchKeyForSeller );

        return list.map(item => {
            let value = item.value;
            //console.log(' Label -> ', item.Label__c );
            //console.log(' item -> ', item );
            const label = item.Label__c;

            /* 현재는 거래처인 경우만 > 고객사 코드 , 명 , 유형 값넣어주기 */
            
            if( item.ApiName__c !== undefined ){
                //let value = '';
                const apiName = item.ApiName__c;
                console.log(' apiName -> ' , apiName );
                if( apiName.includes("CustomerID")){
                    console.log(' 고객사 코드 !!! ' , this.accountCode);
                    value = this.accountCode;
                }else if(apiName.includes("searchKey")){
                    console.log(' 고객사 명 !!! ' , this.accountName);
                    value = this.accountName;
                }else if(apiName.includes("CustomerType")){
                    console.log(' 고객사 유형 !!! ' , this.accountType);
                    value = this.accountType;
                } 
            }


            if( item.FieldType__c === 'search' ){
                if (label === '거래처'){
                    console.log(' Value 1 ' , label);
                    value = this.searchKeyForAccount; // [501731809]60계(전남여수충무점)
                }else if(label === '관리처'){
                    console.log(' Value 2 ' , label);
                    value = this.searchKeyForManagement;
                }else if (label === '판매처'){
                    console.log(' Value 3 ' , label);
                    value = this.searchKeyForSeller;
                } 
                
            }

            return { ...item, value };
            
        });
    }


    /* 
    자식에서 넘어온 Event 듣는곳 
    */
/*     setCustomEvent(){
        this.template.addEventListener('setSearchAcc', event =>{
            console.log('자식의소리 ' , event.detail.searchKey );
        });
    } */
    
    

}