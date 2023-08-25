import { LightningElement, api, wire, track } from 'lwc';
import { utilAlert, utilShowToast, utilConfrim,  setCustomStyle, removeCustomStyle} from 'c/commUtils';

//refresh
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

import cjfwSurveyType from './RecordPage/cjfwSurveyType.html'; //Survey Category 선택 화면
import cjfwSurvey from './cjfwSurvey.html';                    //Survey 작성 화면

//apex
import getSurvey from '@salesforce/apex/CJFW_SurveyController.getSurvey';
import getSurveyType from '@salesforce/apex/CJFW_SurveyController.getSurveyType';
import saveSurveyResponse from '@salesforce/apex/CJFW_SurveyController.saveSurveyResponse';

export default class CjfwSurvey extends LightningElement {

    @api recordId;
    
    @track isShowParentInfo = false;
    @track survey;
    @track isData = false;
    @track surveyOptionList;
    @track _isCategorySelected = false;
    @track isLoading  = false;
    selectedValueList = [];

    @api get objectApiName() {
        return this._objectApiName;
    }

    set objectApiName(value) {
        this._objectApiName = value;

        if('Account' == value || 'Lead' == value) {
            this.isShowParentInfo = true;
        }

    }


    @api get isCategorySelected() {
        return this._isCategorySelected;
    }

    set isCategorySelected(value) {
        this._isCategorySelected = value;
    }

    /**
    * 저장시 저장하기 쉽게 계층구조를 하나의 리스트로 변경
    *
    *@param  questionList 설문지 질문 리스트
    */
    changeSaveData(questionList) {

        questionList.forEach((question) => {
            if(question.isSelected){
                this.selectedValueList.push(question);

                if(question.selectedValue.subQuestionList && question.selectedValue.subQuestionList.length > 0)
                this.changeSaveData(question.selectedValue.subQuestionList);
            }
        });

    }


    /**
    * Init 메소드
    *
    */
    connectedCallback() {
        

        let customStyle = `
        .survey .slds-accordion__section {
            border: 1px solid var(--slds-c-card-color-border, var(--sds-c-card-color-border, var(--slds-g-color-border-base-1, var(--lwc-cardColorBorder,rgb(201, 201, 201)))));
            border-radius: 15px;
        }
        .survey .slds-accordion__list-item {
            margin: 15px 0;
            border-top-style: initial;
        }
        .survey .slds-accordion__summary-heading {
            margin-top: 4px;
            /*padding-bottom: 5px;*/
        }
        /* 모바일 보다 큰 화면일 경우 */
        @media (min-width: 767px){ 
            .survey .radioContainer .slds-form-element__control {
                display: grid;
                grid-template-columns: repeat(2, 1fr);
            }
        }
        `;
        
        setCustomStyle(customStyle, 'surveyCmp');
        this.isLoading = true;
        getSurveyType().then(result=>{
            //console.log(result);
            this.surveyOptionList = result.optionList;
            this.isLoading = false;
            this._fristSurveyTypeComplete = true;
        }).catch(error=>{
            utilShowToast('에러! ', error);
        });

        
    }

    @api close() {
        let closeEvent = new CustomEvent('customclose', {
            detail: true
        });

        this.dispatchEvent(closeEvent);
    }

    /**
    * 저장
    *
    */
    @api save() {
        //console.log('save btn clicked!!');
        // console.log(
        //     JSON.parse(
        //         JSON.stringify(this.survey)
        //     )
        // );
        //console.log('recordId :: ', this.recordId);
        //console.log('objectApiName :: ', this.objectApiName);

        //초기화
        this.selectedValueList = [];

        this.changeSaveData(this.survey.questionList);

        console.log(
            JSON.parse(JSON.stringify(this.selectedValueList))
        );

        this.survey.resultQuestionList = this.selectedValueList;

        let params = {
            recordId:this.recordId
            ,objectApiName:this.objectApiName
            ,selectedValueList:this.selectedValueList
            ,surveyTypeId:this.getSelectedSurveyType().value
        };
        this.isLoading = true;
        saveSurveyResponse({
            params:params
        }).then(result=>{
            console.log(result);
            if(result.insertData) {
                utilShowToast('성공!!', '성공적으로 설문을 완료하였습니다.', 'success');
                notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                this.close();
                this.isLoading = false;
            }
        }).catch(error=>{
            utilShowToast('에러!!', error, 'error')
        });
    }
    
    /**
    * 선택된 설문지 유형 가져오기
    *
    *@return  _selectedSurveyType 설문지유형 
    */
    @api getSelectedSurveyType() {
        return this._selectedSurveyType;
    }

    /**
    * 제목 클릭시 페이지 이동 막음
    *
    */
    handleTitleClick(event) {
        event.preventDefault();
    }

    handleChangeSelectedData(event) {
        // console.log('1. 변경전');
        // console.log(JSON.parse(JSON.stringify(this.survey)));

        let changeQuestion = event.detail.question;   //question;
        let optionId = event.detail.optionId;         //optionId;

        let subQuestionList;
        let changeOption;

        this.survey.questionList.forEach((thisQuestion, idx)=>{
            thisQuestion.optionList.forEach((option, idx) => {
                if(option.id == optionId) {
                    subQuestionList = option.subQuestionList;
                    changeOption = option;
                }
            });
        });
        

        let thisChangeQuestion;
        subQuestionList.forEach((question, idx)=>{
            //자기 자신 호출해서 받을 경우는 변경 데이터 Question 단건
            if(question.id == changeQuestion.id) {
                thisChangeQuestion = subQuestionList[idx] = changeQuestion;
            }
        });

        this.survey.questionList.forEach((thisQuestion, idx)=>{
            thisQuestion.optionList.forEach((option, idx) => {
                if(option.id == optionId) {
                    option.subQuestionList = subQuestionList;

                    //selectedValue
                    thisQuestion.selectedValue = changeOption;
                }
            });
        });

        // console.log('2. 변경후');
        // console.log(JSON.parse(JSON.stringify(this.survey)));
    }

    /**
    * Accordion Click on/off 시
    *
    */
    handleAccordionClick(event) {
        //console.log('handleAccordionClick');
        let btnCmp = event.currentTarget;
        let accordionSectioCmp = btnCmp.parentElement.parentElement.parentElement;
        accordionSectioCmp.classList.toggle('slds-is-open');
        let expanded = btnCmp.getAttribute('aria-expanded')
        btnCmp.setAttribute('aria-expanded', !expanded);
        let dataset = btnCmp.dataset;
        let parentQuestionIdx = dataset.qidx;
        let subQuestionIdx    = dataset.subqidx;
        let optionInfo        = dataset.option;
        console.log(JSON.parse(JSON.stringify(this.survey)));
        if(!subQuestionIdx) {
            console.log('this.survey.questionList[parentQuestionIdx].isShowDetail :: ',this.survey.questionList[parentQuestionIdx].isShowDetail);
            let isShowDetail = this.survey.questionList[parentQuestionIdx].isShowDetail;
            this.survey.questionList[parentQuestionIdx].isShowDetail = isShowDetail;
            // let question = this.survey.questionList[parentQuestionIdx];
            // let isShowDetail = question.isShowDetail;
            // question.isShowDetail = !isShowDetail;
            // this.survey.questionList[parentQuestionIdx] = question;
            console.log('this.survey.questionList[parentQuestionIdx].isShowDetail2 :: ',this.survey.questionList[parentQuestionIdx].isShowDetail);
        }
        else {
            this.survey.questionList[parentQuestionIdx].optionList.forEach((option)=>{
                if(option.id == optionInfo.id) {
                    let isShowDetail = option.subQuestionList[subQuestionIdx].isShowDetail;
                    option.subQuestionList[subQuestionIdx].isShowDetail = !isShowDetail;
                }
            });
        }

        //console.log(JSON.parse(JSON.stringify(this.survey)));
    }

    /**
    * 설문지 종류 선택 ./RecordPage/cjfwSurveyType.html 에서 사용하는 함수
    *
    */
    handleSelected(event) {
        // console.log(event.detail);
        // console.log(JSON.stringify(event.detail));

        this._selectedSurveyType = event.detail.selectedData;

        let params = {
            recordId:event.detail.selectedData.value
        };
        
        if(this._selectedSurveyType?.value) {
            this.isLoading = true;
            this._getSurvey(params);
        }
    }

    /**
    * 설문지 정보 조회
    *
    *@param  params
    *           recordId:선택된 설문지Id
    */
    async _getSurvey(params) {
        getSurvey({
            params:params
        }).then(result=>{
            console.log(result);
            this.survey = result.survey;
            this.isData = true;
            //utilShowToast('성공','survey 데이터 가져오기');
        }).catch(error=>{
            let errors = error;
            utilShowToast('실패', error);
        }).finally(()=>{
            this.isLoading = false;
        });
    }

    /**
    * 주관식 데이터 변경시
    *
    *@param  event
    */
    handleTextChange(event) {
        let textInputCmp = event.currentTarget;
        let questoinIdx = textInputCmp.dataset.qidx;
        this.survey.questionList[questoinIdx].selectedValue = textInputCmp.value;
        this.survey.questionList[questoinIdx].isSelected = true;
    }

    /**
    * Date Type 데이터 변경시
    *
    *@param  event
    */
    handleDateChange(event) {
        let dateInputCmp = event.currentTarget;
        let questoinIdx = dateInputCmp.dataset.qidx;

        let inputName = dateInputCmp.name;
        console.log(inputName);
        
        let selectedValue = this.survey.questionList[questoinIdx].selectedValue;

        if('dateInput' == inputName) {
            //if(!selectedValue) selectedValue = undefined;
            selectedValue = dateInputCmp.value;
        }else {
            if(!selectedValue) selectedValue = [undefined, undefined];

            if('dateInputFrom' == inputName) {
                selectedValue[0] = dateInputCmp.value;
            }else if('dateInputTo' == inputName) {
                selectedValue[1] = dateInputCmp.value;
            }
        }

        this.survey.questionList[questoinIdx].selectedValue = selectedValue;
        this.survey.questionList[questoinIdx].isSelected    = true;
    }

    /**
    * 시간 값 변경
    *
    *@param  event
    */
    handleTimeChange(event) {
        let timeInputCmp = event.currentTarget;
        let questoinIdx = timeInputCmp.dataset.qidx;

        let inputName = timeInputCmp.name;
        
        let selectedValue = this.survey.questionList[questoinIdx].selectedValue;

        if(!selectedValue) selectedValue = [undefined, undefined];

        if('timeInputFrom' == inputName) {
            selectedValue[0] = timeInputCmp.value;
        }else if('timeInputTo' == inputName) {
            selectedValue[1] = timeInputCmp.value;
        }
        
        this.survey.questionList[questoinIdx].selectedValue = selectedValue;
        this.survey.questionList[questoinIdx].isSelected    = true;
    }

    /**
    * 객관식 다건 값 변경
    *
    *@param  event
    */
    handleMultipleChange(event) {
        let checkBoxCmp= event.currentTarget;
        let qIdx = checkBoxCmp.dataset.qidx;
        if(!this.survey.questionList[qIdx].selectedValue) this.survey.questionList[qIdx].selectedValue = [];
        // console.log(qIdx);
        // console.log(checkBoxCmp.value);
        // console.log(
        //     JSON.parse(JSON.stringify(this.survey.questionList[qIdx]))
        // );
        if(checkBoxCmp.checked) {
            this.survey.questionList[qIdx].selectedValue.push(event.currentTarget.value);
            this.survey.questionList[qIdx].isSelected = true;
        }else {
            let selectedValues = this.survey.questionList[qIdx].selectedValue;
            selectedValues.forEach((selectedValue, idx)=>{
                if(selectedValue == checkBoxCmp.value) {
                    selectedValues.splice(idx, 1);
                }
            });
            this.survey.questionList[qIdx].selectedValue = selectedValues;
            this.survey.questionList[qIdx].isSelected = true;
        }
        
        console.log(
            JSON.parse(JSON.stringify(this.survey.questionList[qIdx]))
        );
    }

    /**
    * 객관식 단건 값 변경
    *
    *@param  event
    */
    handleSingleChange(event) {
        //console.log('handleSingleChange!!');

        let qIdx = event.currentTarget.dataset.qidx;
        const result = this.survey.questionList[qIdx].optionList.filter((option) => option.value == event.currentTarget.value);
        //console.log('result : ', JSON.parse(JSON.stringify(result)));
        result[0].isFollowUp = true;
        this.survey.questionList[qIdx].selectedValue = JSON.parse(JSON.stringify(result[0]));
        this.survey.questionList[qIdx].isSelected = true;

    }

    /**
    * destroy method
    *
    */
    disconnectedCallback() {
        removeCustomStyle('surveyCmp');
    }

    /**
    * 랜더할 html 화면 설정
    *
    */
    render() {
        if(this._isCategorySelected) {
             return cjfwSurvey;
        }else {
            this._selectedSurveyType = undefined;
            return cjfwSurveyType;
        }
    }

    @api
    setSelectedSurveyType() {
        //console.log('변경')
        this._selectedSurveyType = this.template.querySelector('c-comm-custom-select').getSelectedValue().selectedData;
    }
    
    async renderedCallback() {
        //console.log('cjfwSurvey renderedCallback');
        // 프로토타입 시현용 [s]
        if(this._fristSurveyTypeComplete) {

            
            this.setSelectedSurveyType();
            let params = {
                recordId:this._selectedSurveyType.value
            };
            //console.log(JSON.stringify(this._selectedSurveyType))
            await this._getSurvey(params);

            //this.isCategorySelected = true;

            this._fristSurveyTypeComplete = false;
        }
        // 프로토타입 시현용 [e]


        if(!this.isCategorySelected) {
            this.setSelectedSurveyType();
        }
    }

}