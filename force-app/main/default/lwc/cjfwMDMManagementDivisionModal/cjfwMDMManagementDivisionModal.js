import { track, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import CjfwAccountSearchModal from 'c/cjfwAccountSearchModal';
import CjfwMDMManagementSearchModal from 'c/cjfwMDMManagementSearchModal';
import CjfwAddressSearchModal from 'c/cjfwAddressSearchModal';
import CjfwManagerSearchModal from 'c/cjfwManagerSearchModal';
import CjfwMDMAlertBeforeReference from 'c/cjfwMDMAlertBeforeReference';
import setDefaultInfo from '@salesforce/apex/CJFW_MDMManagementController.setDefaultInfo';
import getAccountInfo from '@salesforce/apex/CJFW_MDMManagementController.getAccountInfo';
import { utilShowToast } from 'c/commUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe , unsubscribe, MessageContext , publish } from 'lightning/messageService';
import CJFW_ACCREFERENCETOMANAGEMENT_CHANNEL from '@salesforce/messageChannel/accReferenceToManagement__c';
import doGetFirstDayOfMonth from '@salesforce/apex/CJFW_MDMManagementController.getFirstDayOfMonthDate';

export default class CjfwMDMManagementDivisionModal extends LightningModal {
    @api recordId; //recordId 여부에 따라 생성/편집 
    @track RecordTypeId; //생성 할 때 '관리처'입력해줌
    mdmCustomerType = 'MDMManagement';

    // 위랑 아래랑 같음
    // Map<String, String> objCustomer = new Map<String, String>{ 
    // sobjectType => 'MDMRegRequestCustomer__c',
    // PV_CESSION_KZ__c => '',
    // PV_KTOKD__c => 'Z300'
    // };
    // objCustomer.put('PV_STCDT_lu__c','');



    /**
    * LMS
    */
    @wire(MessageContext)
    messageContext;
    subscriptionReferenceToDivision = null; 
    referenceToDivisionAccId; //참조생성에서 선택한 AccountId(판매처)
    
    /**
    * 유효성검사
    */
    listRequriedErrorKey = [];
    @track isReadOnlyHKUNNR = false;

    @track showModal = true; 

    /**
    * 검색모달
    */
    @track searchKey = '';
    @track accountType = '';
    
    /**
    * Tab 활성화 
    */
    @track basicInfo = true;
    @track financialInfo = true;
    @track salesInfo = true;
   
    /**
    * 필수, 활성화 Attr
    */
    //@api PV_KEYYN__c; //입장여부
    @track isDisableKEYINFO = true; //입장여부정보
    //@api PV_KXOTD__c;
    @track isRequiredKXOTDTIME = true; //KX OTD 요청시간 
    //@api PV_FDINFO__c; //초도배송 정보공유
    @track isRequiredFDINFO = true;
    @track PV_ISFDFTF__c = false;
    @track requiredField = true;

   
    


    /**
    * [메세지 구독] 
    * 발행처에서 가져온 데이터 확인 
    */
    handleSubscribe(){
        console.log('>>> cjfwMDMManagementDivisionModal # handleSubscribe');
        if (!this.subscription){
            console.log('>>> cjfwMDMManagementDivisionModal # handleSubscribe # Reference to Division 구독');
            
        this.subscriptionReferenceToDivision = subscribe(
            this.messageContext,
            CJFW_ACCREFERENCETOMANAGEMENT_CHANNEL,
            (message)=>{
                this.dataMessage(message);
                console.log('>>> cjfwMDMManagementDivisionModal # message' + message);
            }
        );
    }

    }
    /**
    * 참조생성에서 받아 온 Account의 RecordId로 데이터 조회해서 뿌려주기
    */
    accontId = '';
    dataMessage(message){
        console.log('>>> cjfwMDMManagementDivisionModal # dataMessage');

        let referencToDivisionAccData = message.referencToDivisionAccId; 
        this.accontId = referencToDivisionAccData;
        if(this.accontId) {
            console.log('this.accontId ' + this.accontId );
            getAccountInfo({
            selectedId : this.accontId,
            })
            .then(result => {
                if (result && result.length > 0) {
                    console.log('>>> cjfwMDMManagementDivisionModal # dataMessage # this.objCustomer = result[0]' + JSON.stringify(this.objCustomer = result[0]));
                    this.objCustomer = result[0];
                }
            })
            .catch(error => {
                console.error('>>> error '+error);
            });
        }
    }
    @track defaultObjCustomer = {
        PV_KTOKD : ''
       ,PV_CUSTTYPE : ''
       ,PVRA_VKGRP : ''
       ,PVRA_PERNR : ''
       ,PVRA_LOGISCENTER : ''
       ,PV_LAND1 : ''
       ,PV_WAERS : ''
       ,PVRA_CUHR1 : ''
       ,PVRA_KONDA : ''
       ,PVRA_KVGR1 : ''
       ,PVRA_OLD_BIZPLACE_NEW : ''
       ,PV_DELIGROUP : ''
       ,PV_BUSAB : ''
       ,PV_CESSION_KZ : ''
       ,PV_ZUAWA : ''
       ,PV_AKONT : ''
       ,PV_FDGRV : ''
       ,PV_TAXKDD : ''
       ,PV_KATR5 : ''
       ,PV_SHIPTYPE : ''
   };

    connectedCallback(){
        console.log('>>> Division #connectedCallback # this.objCustomer ' + JSON.stringify(this.objCustomer));
        this.handleSubscribe();
        /**
         *  생성 시, recordType : 관리처 로 저장
         * */        
        setDefaultInfo({
            recordTypeName : this.mdmCustomerType
        }).then(result => { 
            let data = JSON.parse(JSON.stringify(result));
            if(data.strStatus='SUCCESS'){
                this.objCustomer.RecordTypeId = data.MDMRecordTypeId;
            }
        }).catch(e => {
            console.log('error -> ', e);
        })
        
        /**
         * [기본/회계/영업]날짜 필드들 모두 오늘날짜로 Setting
         */
        doGetFirstDayOfMonth()
        .then(result => {
        console.log(JSON.stringify(result));
        this.defaultObjCustomer.PVRA_PERNR = result;
        this.defaultObjCustomer.PVRA_VKGRP = result;
        this.defaultObjCustomer.PVRA_LOGISCENTER = result;
        this.defaultObjCustomer.PVRA_CUHR1 = result;
        this.defaultObjCustomer.PVRA_KONDA = result;
        this.defaultObjCustomer.PVRA_KVGR1 = result;
        this.defaultObjCustomer.PVRA_OLD_BIZPLACE_NEW = result;
        })
        .catch(error => {
        })

        /**
         *  생성 시, Default 값 넣어주기 
         * */
        
        //1. recordId 여부 관련 없이 Default
        this.defaultObjCustomer.PV_KTOKD = '관리처';
        this.defaultObjCustomer.PV_CUSTTYPE = '관리처-분할';
        this.defaultObjCustomer.PV_LAND1 = '[KR]한국';
        //[회계정보] ALL 필드
        this.defaultObjCustomer.PV_BUSAB = '01';
        this.defaultObjCustomer.PV_CESSION_KZ = '01';
        this.defaultObjCustomer.PV_ZUAWA = 'External doc.number'; //'009';
      
        this.defaultObjCustomer.PV_AKONT = '외상매출금-국판_일반'; //'11311010';
        this.defaultObjCustomer.PV_FDGRV = '거래처코드공통'; //'C1';
        this.defaultObjCustomer.PV_TAXKDD = '1';
        this.defaultObjCustomer.PV_KATR5 = '개별납부사업장';

        console.log('>>> PV_BUSAB ' + this.defaultObjCustomer.PV_BUSAB);
        console.log('>>> PV_CESSION_KZ ' + this.defaultObjCustomer.PV_CESSION_KZ);
        console.log('>>> PV_ZUAWA ' + this.defaultObjCustomer.PV_ZUAWA);
        console.log('>>> PV_KATR5 ' + this.defaultObjCustomer.PV_KATR5);
        //[영업정보]
        this.defaultObjCustomer.PV_WAERS = 'KRW';
        this.defaultObjCustomer.PV_DELIGROUP = '통합배송그룹';
        this.defaultObjCustomer.PV_SHIPTYPE = '배송';

        //2. 생성 시,
        if (!this.recordId) {
            //요청타입(RequestType__c)
            this.objCustomer.requestType = 'create';
            //필수값 체크
            this.objCustomer.PV_NAME1 = '';
        }else{
        }
    }
   
    renderedCallback() {
        console.log('>>> cjfwMDMManagementDivisionModal #renderedCallback');
        /**
        * 관리처 생성 시(=recordId없음)
        * 필수값표시(*)는 고객명(영문명 포함)만 해당 됨 
        * (MDM 고객 등록 및 수정 요청 Obj에 생성 된 후 편집시에는 적용X)
        */
       // 신규 MDM 생성 시
        if (!this.recordId) {
            this.requiredField = false;
        // 기존 MDM 수정 시
        }else{

        }
    }

    /**
    * ==================================================================================
    *  날짜 Validation Start
    * ==================================================================================
    * AMA 정보 변경 이벤트 추가해야 함.
    */
    // 영업그룹(유효기간 관리) Validation  
    grpChanged(event) {
        console.log('>>> 영업그룹 (유효기간 관리) 클릭 ');
        const fields = event.detail.value;
    
        if (fields !== "") {
            const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
            if (fields <= today) {
                alert('영업그룹의 유효날짜는 오늘보다 커야 합니다.');
                this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
                return;
            } else {
                this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
            }
        }
    }

    // 고객그룹(유효기간 관리) Validation
    cuhrChanged(event) {
        console.log('>>> 고객그룹(유효기간 관리) 클릭 ');
        const fields = event.detail.value;
    
        if (fields !== "") {
            const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
            if (fields > today) {
                alert('고객분류의 유효날짜는 오늘보다 같거나 작아야 합니다.');
                //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
                return;
            } else {
                this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
            }
        }
    }
    
    // 가격그룹(유효기간 관리) Validation
    cuhrChanged(event) {
        console.log('>>> 가격그룹(유효기간 관리) 클릭 ');
        const fields = event.detail.value;
    
        if (fields !== "") {
            const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
            if (fields > today) {
                alert('가격그룹의 유효날짜는 오늘보다 같거나 작아야 합니다.');
                //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
                return;
            } else {
                this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
            }
        }
    }

    // 단가그룹(유효기간 관리) Validation
    kvgr1Changed(event) {
        console.log('>>> 단가그룹(유효기간 관리) 클릭 ');
        const fields = event.detail.value;
    
        if (fields !== "") {
            const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
            if (fields < today) {
                alert('단가그룹의 유효날짜는 오늘보다 같거나 커야 합니다.');
                //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
                return;
            } else {
                this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
            }
        }
    }

    // FW 출고센터(유효기간 관리) Validation
    logiscenterChanged(event) {
        console.log('>>> FW 출고센터(유효기간 관리) 클릭 ');
        const fields = event.detail.value;
    
        if (fields !== "") {
            const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
            if (fields <= today) {
                alert('FW 출고센터 유효날짜는 오늘보다 커야 합니다.');
                //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
                return;
            } else {
                this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
            }
        }
    }
    // 경로사업부-(유효기간 관리) Validation
    oldbizplzceChanged(event) {
        console.log('>>> 경로사업부-(유효기간 관리) 클릭 ');
        const fields = event.detail.value;
    
        if (fields !== "") {
            const today = new Date().toISOString().slice(0, 10); // 오늘 날짜를 YYYY-MM-DD 형식으로 가져옴
            if (fields > today) {
                alert('경로사업부의 유효날짜는 오늘보다 같거나 작아야 합니다.');
                //this.objCustomer.PVRA_VKGRP__c = ''; // 필요시 상태 변수 업데이트
                return;
            } else {
                this.objCustomer.PVRA_VKGRP__c = fields; // 상태 변수 업데이트
            }
        }
    }
    //MA 정보 변경시
    pvChanged(event){
        console.log('>>> MA 정보 변경 시 ');
        const fields = event.detail.value;
    }
    /**
     * End
     */

    /**
    * ==================================================================================
    *  체크박스(checkBox)의 여부에따라, 필드값 활성화 및 Disable 활성화시키기 Start
    * ==================================================================================
    */
    handlerChangeKEYYN(event){
        this.PV_KEYYN__c = event.target.checked;

        if (this.PV_KEYYN__c) {
            // 체크되었을 때의 동작 처리
            this.isDisableKEYINFO = false;
        } else {
            // 체크 해제되었을 때의 동작 처리
            this.isDisableKEYINFO = true;
        }
    }
    handlerChangeKXOTD(event){
        console.log('여기 key Check1');
        this.PV_KXOTD__c = event.target.checked;
        console.log('key ' + this.PV_KXOTD__c);
        console.log('여기 key Check2');
        if (this.PV_KXOTD__c) {
            // 체크되었을 때의 동작 처리
            this.isRequiredKXOTDTIME = false;

        } else {
            // 체크 해제되었을 때의 동작 처리
            this.isRequiredKXOTDTIME = true;
        }
    }

    handlerChangeFDINFO(event){
        this.PV_FDINFO__c = event.target.checked;
        console.log('key ' + this.PV_FDINFO__c);
        console.log('여기 key Check2');
        if (this.PV_FDINFO__c) {
            // 체크되었을 때의 동작 처리
            this.isRequiredFDINFO = false;
            this.PV_ISFDFTF__c = true;
        } else {
            // 체크 해제되었을 때의 동작 처리
            this.isRequiredFDINFO = true;
        }
    }
    /**
     * End
     */



    /**
    * ==================================================================================
    *  필드 선택 시 Modal 호출 Start
    * ==================================================================================
    */
    handleEnter(event){
        if(event.key === 'Enter'){
            this.openSearchModal();
        }
    }
 
    //조회 Modal
    async openSearchModal() {
        this.result = await CjfwMDMManagementSearchModal.open({
            size: 'small',
            searchKey : this.searchKey,
            accountType : this.accountType,
            // onclose : this.handleClose,
            message : 'FilterToCmp'
        }).then(result => {
            if( result !=undefined ){
                // if(result.length > 0) this.searchKey = result[0].CustomerID__c;
                if(result.length > 0) this.searchKey = result[0].searchKey__c;
            }
        });
        console.log(this.result);
    }
    /**
     * End
     */

    /**
    * ==================================================================================
    *  버튼 선택 시 Modal 호출 Start
    * ==================================================================================
    */
    addressSearch(){
        console.log('>>> 주소검색 버튼 ');
        this.addressSearchModal();
    }

    
    // 주소 검색 Component 호출 
    async addressSearchModal() {
        this.result = await CjfwAddressSearchModal.open({
            size: 'small',
            
            message : 'FilterToCmp'
        }).then(result => {
            
        });
        console.log(this.result);
    }
    
    // 담당자 Btn 클릭 시 Modal 호출
    managerSearch(){
        console.log('>>> 주소검색 버튼 ');
        this.managerSearchModal();
    }

    // 담당자 검색 Component 호출 
    async managerSearchModal() {
        this.result = await CjfwManagerSearchModal.open({
            size: 'small',
            
            message : 'FilterToCmp'
        }).then(result => {
            
        });
        console.log(this.result);
    }
    // 참조생성 Btn 클릭 시 Modal 호출
    referenceCreate(){
        console.log('>>> 주소검색 버튼 ');
        this.beforeReferenceModal();
    }

    // 참조생성 Component 호출 
    async beforeReferenceModal() {
        this.result = await CjfwMDMAlertBeforeReference.open({
            size: 'small',
            
            message : 'FilterToCmp'
        }).then(result => {
            
        });
        console.log(this.result);
    }
    /**
     * End
     */

    
    /**
     * 취소 버튼 클릭 시 
     */  
    fnCancel(){
        console.log('>>> 취소 Btn');
        // window.history.back();
        const baseUrl = window.location.origin;
        window.location.href = baseUrl+'/lightning/o/MDMRegRequestCustomer__c/list?filterName=Recent';
    }
    /**
     * 유효성 Onchange 
     */  
    handleInputFieldChange(event) {
        const fieldName = event.target.fieldName.replace('__c', '');
        this.objCustomer[fieldName] = event.target.value;
        console.log('값 확인1 ' + this.objCustomer.PV_OLDCD);
    }
    handleDefaultInputFieldChange(event) {
        const fieldName = event.target.fieldName.replace('__c', '');
        this.defaultObjCustomer[fieldName] = event.target.value;
        console.log('this.defaultObjCustomer[fieldName] ' +  event.target.value);
        console.log('값 확인1 ' + this.defaultObjCustomer.PVRA_CUHR1);
    }

    @track objCustomer = {  //현재 ObjectCustomer 사용
        PV_OLDCD : ''
       ,PV_KEYYN : ''
       ,PV_KXOTD : ''
       ,PV_FDINFO : ''
 
   };

    // submit으로 하는 방법
    fnSave(event){
        console.log('>>> Save');
        console.log('>>> this.objCustomer.PV_NAME1__c ' + this.objCustomer.PV_NAME1);
        console.log('>>> this.objCustomer.PV_ZUAWA ' + this.defaultObjCustomer.PV_ZUAWA);
        console.log('값 확인2 ' + this.defaultObjCustomer.PVRA_CUHR1);

        if(this.objCustomer.PV_NAME1 != '' && this.objCustomer.PV_NAME1 != undefined){

            var isError = false;
            var isSelectbox = false;
            var errorMsg = '';
            const fields = event.detail.fields;
            var errorKey;
            var targetDiv = '';
            var listRequriedErrorKey = this.listRequriedErrorKey;
            
            //구코드 1
            var regex1 = /^(\d{0,10}|)$/; 
            //사업자등록번호 제어 1
            var regex2 = /^(\d{10}|)$/;
            //법적상태 제어 1
            var regex3 = /^(\d{13}|)$/;
            //생년월일 1
            var regex4 = /^(?:[0-9]{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[1,2][0-9]|3[0,1]))$|^$/;
            //전화번호 1
            var regex5 = /^\d{2,3}-\d{3,4}-\d{4}$/;;
            //팩스번호 1
            var regex6 = /^\d{2,3}-\d{3,4}-\d{4}$/;
            //약정회전일 X
            var regex7 = /^\d{1,3}$|^$/;
            //외형(정원) X
            var regex8 = /^\d{0,11}$/;
            //종사업자번호 제어 1
            var regex9 = /^(\d{4}|)$/;
    
            // fields = event.getParam('fields');
            var isErrorTab = '';
            var basicErrorCount = 0;
            var finErrorCount = 0;
            var salesErrorCount = 0;
            errorKey = '';
            //유효성 검사
            listRequriedErrorKey = [];
            //Error가 발생한 Data-id를 담아놓는 List(다건 에러 처리시 포문 돌려서 사용)
            let errorDataidList = [];
            //입력한값에 대한 Validation
            //기본정보

            /**
             * 입력한값에 대한 Validation
             */
            //[기본정보 && 정규식 검사] 
            if (this.objCustomer.PV_OLDCD !== "" && this.objCustomer.PV_OLDCD !== undefined && !regex1.test(this.objCustomer.PV_OLDCD)) {
                console.log('구코드 찍히나');
                 isError = true;
                 isErrorTab = 'basic';
                 errorMsg = '구코드(As-Is): 구코드는 10자리 이하의 숫자만 입력이 가능합니다.';
                 errorKey = 'PV_OLDCD__c';
                 if (!targetDiv) {
                     targetDiv = 'PV_OLDCD__c';
                 }
                 errorDataidList.push(errorKey);
            }
            else  if(this.objCustomer.PV_STCD2 !== "" && this.objCustomer.PV_STCD2 !== undefined && !regex2.test(this.objCustomer.PV_STCD2)) {
                isError = true;
                isErrorTab = 'basic';
                errorMsg = '올바른 형식의 사업자등록번호가 아닙니다. 10자리 숫자만 입력이 가능합니다.';
                errorKey = 'PV_STCD2__c';
                if (!targetDiv) {
                    targetDiv = 'PV_STCD2__c';
                }
                errorDataidList.push(errorKey);
            }


            else  if(this.objCustomer.PV_STCD4 !== "" && this.objCustomer.PV_STCD4 !== undefined && !regex9.test(this.objCustomer.PV_STCD4)) {
                isError = true;
                isErrorTab = 'basic';
                errorMsg = '올바른 형식의 종사업자번호가 아닙니다. 4자리 숫자만 입력이 가능합니다.';
                errorKey = 'PV_STCD4__c';
                if (!targetDiv) {
                    targetDiv = 'PV_STCD4__c';
                }
                errorDataidList.push(errorKey);
            }
            else  if(this.objCustomer.PV_STCD3 !== "" && this.objCustomer.PV_STCD3 !== undefined && !regex3.test(this.objCustomer.PV_STCD3)) {
                isError = true;
                isErrorTab = 'basic';
                errorMsg = '올바른 형식의 법인코드가 아닙니다. 13자리 숫자만 입력이 가능합니다.';
                errorKey = 'PV_STCD3__c';
                if (!targetDiv) {
                    targetDiv = 'PV_STCD3__c';
                }
                errorDataidList.push(errorKey);
            }
            else  if(this.objCustomer.PV_STCD1 !== "" && this.objCustomer.PV_STCD1 !== undefined && !regex4.test(this.objCustomer.PV_STCD1)) {
                isError = true;
                isErrorTab = 'basic';
                errorMsg = '올바른 형식의 대표자 생년월일이 아닙니다. 6자리만 입력이 가능합니다. 예시) 750101';
                errorKey = 'PV_STCD1__c';
                if (!targetDiv) {
                    targetDiv = 'PV_STCD1__c';
                }
            }
            else  if(this.objCustomer.PV_TELF1 !== "" && this.objCustomer.PV_TELF1 !== undefined && !regex5.test(this.objCustomer.PV_TELF1)) {
                isError = true;
                isErrorTab = 'basic';
                errorMsg = '올바른 형식의 전화번호가 아닙니다. "-" 값을 포함하여 입력';
                errorKey = 'PV_TELF1__c';
                if (!targetDiv) {
                    targetDiv = 'PV_TELF1__c';
                }
                errorDataidList.push(errorKey);
            }
            else  if(this.objCustomer.PV_TELFX !== "" && this.objCustomer.PV_TELFX !== undefined && !regex6.test(this.objCustomer.PV_TELFX)) {
                isError = true;
                isErrorTab = 'basic';
                errorMsg = '올바른 형식의 팩스번호가 아닙니다. "-" 값을 포함하여 입력';
                errorKey = 'PV_TELFX__c';
                if (!targetDiv) {
                    targetDiv = 'PV_TELFX__c';
                }
                errorDataidList.push(errorKey);
            }
            //[체크된 값에대한 유효성 검사] tr
            else  if(this.template.querySelector("[data-id='PV_SUBSIDIARYYN__c']").checked &&  this.objCustomer.PV_VBUND == undefined ) {
                console.log('여기 왜 안찍히징');
                alert('여기요!');
                isError = true;
                isErrorTab = 'basic';
                errorMsg = '관계사 코드 필드를 입력해 주세요.';
                errorKey = 'PV_VBUND__c';
                if (!targetDiv) {
                    targetDiv = 'PV_VBUND__c';
                }
                errorDataidList.push(errorKey);
            }



             if(isError) {
                console.log('==============> isErrorTab : '+isErrorTab);
                console.log('==============> errorKey : '+errorKey);
                console.log('==============> isError : '+isError);
                console.log('==============> errorMsg : '+errorMsg);
                utilShowToast(errorMsg,'','warning');

                const style = document.createElement('style');

                style.innerText = `
                    c-meeting-modal .modal-container {
                        max-width: 1500px;
                    }
                `;

                // 에러 발생한 error-id로 스크롤 하는 메소드 추가
                this.errorScollMove(targetDiv);

                //에러 발생한 error-id에 slds-has-error class 할당 (단건 처리시)
                this.errorBoxChangeColor(targetDiv);
                
                // 에러 발생한 error-id에 slds-has-error class 할당 (다건 처리시)
                // this.errorBoxListChangeColor(errorDataidList);
            }else{

            //코드추가전
            //const fields = event.detail.fields;
            console.log('>>> 저장 Btn ' + JSON.stringify(event.detail.fields));
            console.log('>>> fields 값? ' + JSON.stringify(fields));
            console.log('값 확인2 ' + this.defaultObjCustomer.PVRA_CUHR1);
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            
            console.log('>>> 저장 Btn fields ' + fields);
            const baseUrl = window.location.origin;
            window.location.href = baseUrl+'/lightning/o/MDMRegRequestCustomer__c/list?filterName=Recent';
            }
        }else{
            utilShowToast('필수값을 입력해주세요','','warning');
            
            //utilShowToast('필수항목 미입력', missingColumns + '개를 추가적으로 입력하세요', 'warning');
        }
    }

       /**
     * 에러 발생한 data-id로 스크롤 이동하는 기능 담당 
     * @param {에러가 발생한 data-id값 전달} targetDiv 
     */
       errorScollMove(targetDiv)
       {
           let currentIdxRow = this.template.querySelector("[data-id='" + targetDiv + "']");
           if(currentIdxRow) {
               // 해당 돔으로 이동
               currentIdxRow.scrollIntoView({behavior: "smooth", block: "start", inline: "start"});
           }else {
               console.log('not!!');
           }
       }
       
       /**
        * 에러 발생한 data-id에 slds-has-error class 할당(단일)
        * @param {에러가 발생한 data-id값 전달} targetDiv 
        */
       errorBoxChangeColor(targetDiv){
           let targetComp = this.template.querySelector("[data-id='" + targetDiv + "']");
   
           if(targetComp) {
               // classList라는걸 쓰면 data-id로 찾은 dom에 class를 Add 할 수 있음
               targetComp.classList.add("slds-has-error");
   
           }else {
               console.log('==============> none target');
           }
       }
       /**
        * 에러 발생한 data-id에 slds-has-error class 할당(다건)
        * @param {에러가 발생한 data-id List 전달} targetDiv 
        */
       errorBoxListChangeColor(errorDataidList){
           if (errorDataidList.length > 0) {
               // errorDataidList 배열이 비어있지 않은 경우에만 루프 실행
               errorDataidList.forEach(dataId => {
                   let targetComp = this.template.querySelector("[data-id='" + dataId + "']");
                   if(targetComp) {
                       // classList라는걸 쓰면 data-id로 찾은 dom에 class를 Add 할 수 있음
                       targetComp.classList.add("slds-has-error");
                   }
               });
             } else {
               console.log("errorDataidList 배열이 비어있습니다.");
             }
       }

}