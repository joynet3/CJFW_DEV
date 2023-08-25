/**
 * @description       : 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-25-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-21-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
import { track } from 'lwc';
import { utilShowToast } from 'c/commUtils';
import LightningModal from 'lightning/modal';
import cjfwOpenReportModal from 'c/cjfwNewOpenReportModal';

export default class cjfwMenualChooseModal extends LightningModal {

    Title = '품의 생성';
    // chooseReportShow = false ; // 품의서생성 모달 (TEST용 > 나중에 버튼빼고 삭제예정)
    orgOptionList =[];

    comboLabel='';
    comboValue='';

/*  
    (급식솔루션,헬씨,아이누리)_신규개설품의 page : CJFW_NewOpenReport
    (아이누리)_신규개설품의 page : CJFW_NewInuriOpenReport
    (급식)_보증금양식 page : CJFW_DepositForm
    (외식)_수주심의운영 page : CJFW_OrderConsiderManage
    (외식)_수주심의양식(신규) page : CJFW_OrderConsiderNewForm
    (외식)_수주심의양식(재계약) page : CJFW_OrderConsiderReContractForm 
*/
  
    @track orgOptionList = [
        { label: '(아이누리) 신규개설 사전품의'          , value: 'inuri'    },
        { label: '(급식/헬씨) 신규개설 및 재계약'        , value: 'healthy'  },
        { label: '(급식)_보증금양식'                    , value: 'Deposit' },
        { label: '수주심의양식(재계약)'                 , value: 'strategy' },
        { label: '(외식)_수주심의운영'                  , value: 'OrderConsider' },
        { label: '(외식)_수주심의양식(신규)'            , value: 'OrderConsiderNew' },
        { label: '(외식)_수주심의양식(재계약)'          , value: 'OrderConsiderReContract' },
    ];

    connectedCallback() {
        console.log('#cjfwMenualChooseCmp #connectedCallback');
    }

    /* customSelectBox 클릭시 */
    handleSelected(event){
        console.log('#cjfwMenualChooseCmp # handleSelected');
        this.comboLabel='';
        this.comboValue='';
        this.comboList = this.template.querySelector('c-comm-custom-select').getSelectedValue();
        const comboList =JSON.parse(JSON.stringify(this.comboList));

        // "label" 값과 "value" 값을 추출
        this.comboLabel = comboList.selectedData.label;
        this.comboValue = comboList.selectedData.value;

        console.log('label 값', this.comboLabel);
        console.log('value 값', this.comboValue);

    }

    comboBoxChange(){
        console.log('#cjfwMenualChooseCmp #comboBoxChange');
    }

    /* 
            { label: '(아이누리) 신규개설 사전품의'          , value: 'inuri'    },
        { label: '(급식/헬씨) 신규개설 및 재계약'        , value: 'healthy'  },
        { label: '(급식)_보증금양식'                    , value: 'Deposit' },
        { label: '수주심의양식(재계약)'                 , value: 'strategy' },
        { label: '(외식)_수주심의운영'                  , value: 'OrderConsider' },
        { label: '(외식)_수주심의양식(신규)'            , value: 'OrderConsiderNew' },
        { label: '(외식)_수주심의양식(재계약)'          , value: 'OrderConsiderReContract' },
    
    */
    nextbutton(){
        if(this.comboValue ==='healthy'){
            this.openReportModal();
        }else if(this.comboValue ==='inuri'){
            this.openReportModal();
        }else if(this.comboValue ==='Deposit'){
            this.openReportModal();
        }else if(this.comboValue ==='strategy'){
            utilShowToast('개발중','현재 개발중입니다','info');
        }else if(this.comboValue ==='OrderConsider'){
            utilShowToast('개발중','현재 개발중입니다','info');
        }else if(this.comboValue ==='OrderConsiderNew'){
            this.openReportModal();
        }else if(this.comboValue ==='OrderConsiderReContract'){
            utilShowToast('개발중','현재 개발중입니다','info');
        }else{
            utilShowToast('품의유형 선택','품의유형을 선택해주세요','warning');
        }
        //https://cjck--devsales--c.sandbox.vf.force.com/apex/CJFW_NEWOpenReport
        //const vfPageUrl = '/apex/CJFW_NEWOpenReport'; // Replace with your Visualforce page name
        //window.location.href = vfPageUrl;
    }

    /* 아이누리 품의서 OPEN  */
    async openReportModal(){
        this.result = await cjfwOpenReportModal.open({
            size: 'large',
            selectValue : this.comboValue
        }).then(result => {
            this.handleClose(); //새로운 모달 열리면 기존모달 꺼줘야함
        });

    }

    /* 
    취소 클릭시
    */
    handleClose(){
        console.log('# handleClose');
        this.close();
    }

}