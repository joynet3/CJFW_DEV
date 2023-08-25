/**
 * @description       : 공통으로 사용하는 ExcelCopyAndPaste 컴포넌트 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-23-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-21-2023   eunyoung.choi@dkbmc.com   Initial Version
**/
import { LightningElement , track } from 'lwc';
import { utilShowToast } from 'c/commUtils';
import cjfwMenualChooseModal from 'c/cjfwMenualChooseModal';

export default class cjfwExcelCopyPasteCmp extends LightningElement {

    showColumCnt='';
    maxColumn=20; // 노출시킬 colum Max값 

    @track textValue = '';
    @track excelData = [];
    
    @track showA=false;
    @track showB=false;
    @track showC=false;
    @track showD=false;
    @track isTextareaDisabled=true;


    @track orgOptionList = [
        { label: 'A 메뉴얼'     , value: 'Amanual' },
        { label: 'B 메뉴얼'     , value: 'Bmanual' },
        { label: 'C 메뉴얼'     , value: 'Cmanual' },
        { label: 'D 메뉴얼'     , value: 'Dmanual' },
    ];

    openOne = false;
    openTwo = false;
    openThree = false;
    openFour = false;
    openFive = false;
    openSix = false;
    openSeven = false;
    openEight = false;
    openNine = false;
    openTen = false;

    numberToWordMap = {
        1: 'One',
        2: 'Two',
        3: 'Three',
        4: 'Four',
        5: 'Five',
        6: 'Six',
        7: 'Seven',
        8: 'Eight',
        9: 'Nine',
        10: 'Ten',
        11: 'Eleven',
        12: 'Twelve',
        13: 'Thirteen',
        14: 'Fourteen',
        15: 'Fifteen',
        16: 'Sixteen',
        17: 'Seventeen',
        18: 'Eighteen',
        19: 'Nineteen',
        20: 'Twenty'
    };

    Title='Excel Copy Paste';

    /* 안쓸듯 - 추후 필요없을 시 삭제 */
    chooseMenual(){
        console.log('#cjfwExcelCopyPasteCmp #chooseMenual');
        this.openMenualCooseModal();
    }

    /* 안쓸듯 - 추후 필요없을 시 삭제  */
    async openMenualCooseModal(){
        this.result = await cjfwMenualChooseModal.open({
            size: 'small',
            //searchKey : this.searchKey,
            //accountType : this.accountType,
            // onclose : this.handleClose,
            // message : 'FilterToCmp'
        }).then(result => {

        });

    }

    /* 
    textbox 에 양식데이터 넣을때 , value값 담아두기
    */
    handleInputChange(event){
        this.textValue = event.target.value;
    }

    /*
    적용버튼을 클릭했을 때 
    validation : 
    1. 값이 입력되지 않을경우
    2. 1000 행 초과시 (로딩이 길어짐을 방지하기위해 1000개로 제한)
    3. 메뉴얼마다 정해진 column size 와 비교하여 초과혹은 미달시 validate
    */
   validationCheck(){
        this.excelData = this.parseExcelData(this.textValue);

        if(this.excelData.length > 1000){
            utilShowToast('양식확인확인', '1,000 행을 초과하여 입력할 수 없습니다 ', 'warning');
            this.resetbutton();
        }else if(this.textValue.length === 0){
            utilShowToast('양식확인', '입력된 데이터가 없습니다', 'warning');
        }else{
            const excelData = JSON.parse(JSON.stringify(this.excelData));
            const firstObject = excelData[0];
            const firstObjectLength = Object.keys(firstObject).length;

            // 입력받은 데이터 
            console.log('firstObjectLength 행 사이즈->', firstObjectLength);
            console.log('firstObjectLength 열 사이즈 ->', excelData.length);
            // 메뉴얼마다 정해진 column
            console.log('Menual Colum Cnt ->', this.showColumCnt );

            if (firstObjectLength !== this.showColumCnt) {
                const missingColumns = this.showColumCnt - firstObjectLength;
                const addColumns = firstObjectLength - this.showColumCnt;
                if(firstObjectLength>this.showColumCnt){
                    utilShowToast('필수항목 미입력', addColumns + '개를 추가로 입력하셨습니다', 'warning');
                }else if(firstObjectLength<this.showColumCnt){
                    utilShowToast('필수항목 미입력', missingColumns + '개를 추가적으로 입력하세요', 'warning');
                }
                this.resetbutton();
            }
        }
    }


    /* 메뉴얼 selectbox 선택시 */
    handleSelected(event){
        let flagValue = {};
        this.isTextareaDisabled = false;
        
        console.log('#cjfwExcelCopyPasteCmp #handleSelected');
        this.teamComboVal = this.template.querySelector('c-comm-custom-select').getSelectedValue();

        this.teamComboVal =JSON.stringify(this.teamComboVal);
        console.log('>>> Main Team : ' + this.teamComboVal);
        // {"selectedData":{"label":"A 메뉴얼","value":"Amanual","selected":true},"name":""}
        const teamComboObj = JSON.parse(this.teamComboVal);
        const selectedValue = teamComboObj.selectedData.value;
        const selectedLabel = teamComboObj.selectedData.label;
        this.Title = selectedLabel;
        console.log('>>> Selected Value : ' + selectedValue);
        console.log('>>> Selected Value : ' + selectedLabel);
        
        switch(selectedValue){
            case "Amanual":
            flagValue = {showA : true};
            this.showColumCnt = 14;
            break;

            case "Bmanual":
            flagValue = {showB : true};
            this.showColumCnt = 9;
            break;

            case "Cmanual":
            flagValue = {showC : true};
            this.showColumCnt = 4;
            break;

            case "Dmanual":
            flagValue = {showD : true};
            this.showColumCnt = 7;
            break;
        }

        this.setShowFlags(flagValue);
    }
    
    /* 
    메뉴얼에 따라서 다르게 Excel Data 노출영역에  Show 
    */
    setShowFlags(flagValue) {
        console.log('flagValue ->' , flagValue);
        this.showA = flagValue.showA || false;
        this.showB = flagValue.showB || false;
        this.showC = flagValue.showC || false;
        this.showD = flagValue.showD || false;

        this.comboBoxChange();
    }


    /* 
    reset 버튼 클릭시 
    */
    resetbutton(){
        console.log ('#resetbutton');
        const inputFields = this.template.querySelectorAll('lightning-textarea');
        inputFields.forEach(field => {
            field.value = '';
        });
        this.excelData =[];
    }

    /* 
    TextArea에 붙인 텍스트를 Data형식으로 파싱 
    */
    parseExcelData(data) {
        const rows = data.trim().split('\n');
        const parsedData = [];

        for (const row of rows) {
            const cells = row.split('\t'); // Assuming tab-separated data
            const rowData = {};
            for (let i = 0; i < cells.length; i++) {
                const columnName = `column${i + 1}`;
                rowData[columnName] = cells[i];
            }
            parsedData.push(rowData);
        }
        console.log('parsedData',parsedData);
        return parsedData;
    }


    /*
    메뉴얼별 노출컬럼 리스트만큼 open 
    */
    openList(){
        console.log('#openList');
        for (let i = 1; i <= this.showColumCnt; i++) {
         const stateVariable = 'open' + this.numberToWordMap[i];
         this[stateVariable] = true;
         console.log('stateVariable ' , stateVariable);
         console.log('this[stateVariable] ' , this[stateVariable] );
        }
    }


    /* 
    콤보박스가 바뀔때 전체적으로 columlist 영역 show false 만들기
     */ 
    comboBoxChange(){
        console.log('#cjfwExcelCopyPasteCmp #comboBoxChange');

        for (let i = 1; i <= this.maxColumn; i++) {
            const stateVariable = 'open' + this.numberToWordMap[i];
            this[stateVariable] = false;
        }

        this.openList();
    }

    
}