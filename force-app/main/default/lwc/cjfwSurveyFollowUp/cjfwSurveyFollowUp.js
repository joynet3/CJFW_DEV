import { LightningElement, api, track } from 'lwc';

export default class CjfwSurveyFollowUp extends LightningElement {
    @track _questions;
    @api parentOptionId;

    @api get questions() {
        return this._questions;
    }

    set questions(value) {
        this._questions = JSON.parse(JSON.stringify(value));
        console.log(this._questions);
    }

    /**
    * 상위 컴포넌트로 변경된 데이터 전송 (재귀)-1
    *
    *@param  question 변경된 Question
    *@param  optionId 부모 OptionId
    */
    handleDataChangeTo(question, optionId) {
        console.log('handleDataChangeTo');
        let tmpData = {
            question:question
            ,optionId:optionId
        }

        let changeEvent = new CustomEvent('changeddata', {
            detail: tmpData
        });

        this.dispatchEvent(changeEvent);
    }

    /**
    * 하위 컴포넌트로 변경된 데이터 수신 (재귀)-2
    *
    *@param  event
    */
    handleDataChangeFrom(event) {
        console.log('handleDataChangeFrom');
        let changeQuestion = event.detail.question;   //자식 question;
        let optionId = event.detail.optionId;         //optionId;

        let subQuestionList;
        let changeOption;

        this.questions.forEach((thisQuestion, idx)=>{
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

        this.questions.forEach((thisQuestion, idx)=>{
            thisQuestion.optionList.forEach((option, idx) => {
                if(option.id == optionId) {
                    option.subQuestionList = subQuestionList;

                    //selectedValue
                    thisQuestion.selectedValue = changeOption;
                    thisChangeQuestion = thisQuestion;
                }
            });

            
        });

        this.handleDataChangeTo(thisChangeQuestion, this.parentOptionId);

        // ????????????
    }

    /**
    * Accordion Click 시
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
        console.log(JSON.parse(JSON.stringify(this.questions)));
        if(!subQuestionIdx) {
            console.log('this.questions[parentQuestionIdx].isShowDetail :: ',this.questions[parentQuestionIdx].isShowDetail);
            let isShowDetail = this.questions[parentQuestionIdx].isShowDetail;
            this.questions[parentQuestionIdx].isShowDetail = isShowDetail;
            console.log('this.questions[parentQuestionIdx].isShowDetail2 :: ',this.questions[parentQuestionIdx].isShowDetail);
        }
        else {
            this.questions[parentQuestionIdx].optionList.forEach((option)=>{
                if(option.id == optionInfo.id) {
                    let isShowDetail = option.subQuestionList[subQuestionIdx].isShowDetail;
                    option.subQuestionList[subQuestionIdx].isShowDetail = !isShowDetail;
                }
            });
        }
    }

    /**
    * 주관식 데이터 변경시
    *
    *@param  event
    */
    handleTextChange(event) {
        let textInputCmp = event.currentTarget;
        let questionIdx = textInputCmp.dataset.qidx;

        this.questions[questionIdx].selectedValue = textInputCmp.value;
        this.questions[questionIdx].isSelected = true;

        this.handleDataChangeTo(this.questions[questionIdx], this.parentOptionId);
    }

    /**
    * Date Type 데이터 변경시
    *
    *@param  event
    */
    handleDateChange(event) {
        let dateInputCmp = event.currentTarget;
        let questionIdx = dateInputCmp.dataset.qidx;

        let inputName = dateInputCmp.name;
        console.log(inputName);
        
        let selectedValue = this.questions[questionIdx].selectedValue;

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

        this.questions[questionIdx].selectedValue = selectedValue;
        this.questions[questionIdx].isSelected    = true;

        this.handleDataChangeTo(this.questions[questionIdx], this.parentOptionId);
    }

    /**
    * 시간 값 변경
    *
    *@param  event
    */
    handleTimeChange(event) {
        let timeInputCmp = event.currentTarget;
        let questionIdx = timeInputCmp.dataset.qidx;

        let inputName = timeInputCmp.name;
        
        let selectedValue = this.questions[questionIdx].selectedValue;

        if(!selectedValue) selectedValue = [undefined, undefined];

        if('timeInputFrom' == inputName) {
            selectedValue[0] = timeInputCmp.value;
        }else if('timeInputTo' == inputName) {
            selectedValue[1] = timeInputCmp.value;
        }
        
        this.questions[questionIdx].selectedValue = selectedValue;
        this.questions[questionIdx].isSelected    = true;

        this.handleDataChangeTo(this.questions[questionIdx], this.parentOptionId);
    }

    handleSingleChange(event) {
        console.log('handleSingleChange!!');
        let qIdx = event.currentTarget.dataset.qidx;

        // console.log(qIdx);
        // console.log(event.currentTarget.value);
        // console.log(' 선택 후 1');
        // console.log(
        //     JSON.parse(JSON.stringify(this.questions[qIdx]))
        // );

        const result = this.questions[qIdx].optionList.filter((option) => option.value == event.currentTarget.value);
        result[0].isFollowUp = true;
        this.questions[qIdx].selectedValue = JSON.parse(JSON.stringify(result[0]));
        this.questions[qIdx].isSelected = true;

        this.handleDataChangeTo(this.questions[qIdx], this.parentOptionId);

        // console.log(' 선택 후 2');
        // console.log(
        //     JSON.parse(JSON.stringify(this.questions[qIdx]))
        // );
    }

    handleMultipleChange(event) {
        let checkBoxCmp= event.currentTarget;
        let qIdx = checkBoxCmp.dataset.qidx;
        if(!this.questions[qIdx].selectedValue) this.questions[qIdx].selectedValue = [];
        // console.log(qIdx);
        // console.log(checkBoxCmp.value);
        // console.log(
        //     JSON.parse(JSON.stringify(this.questions[qIdx]))
        // );
        if(checkBoxCmp.checked) {
            this.questions[qIdx].selectedValue.push(event.currentTarget.value);
            this.questions[qIdx].isSelected = true;
        }else {
            let selectedValues = this.questions[qIdx].selectedValue;
            selectedValues.forEach((selectedValue, idx)=>{
                if(selectedValue == checkBoxCmp.value) {
                    selectedValues.splice(idx, 1);
                }
            });
            this.questions[qIdx].selectedValue = selectedValues;
            this.questions[qIdx].isSelected = true;
        }
        
        this.handleDataChangeTo(this.questions[qIdx], this.parentOptionId);

        // console.log(
        //     JSON.parse(JSON.stringify(this.questions[qIdx]))
        // );
    }
    
    connectedCallback() {
    }
}