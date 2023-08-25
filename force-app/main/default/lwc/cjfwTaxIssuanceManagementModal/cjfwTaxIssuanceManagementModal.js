import { track, api, wire} from 'lwc';
import LightningModal from 'lightning/modal';

export default class CjfwTaxIssuanceManagementModal extends LightningModal {
    @track showModal = true;
    @track issuanceTypeVal;
    /**
     * Main에서 전달 받을 데이터
     */
    @api selectedOption;
    @api headComboVal;
    @api suComboVal;
    @api teamComboVal;
    @api searchKey;
    @api searchEmpNum;
    @api firstDayOfMonthDate;
    @api todayDate;
    @api fromCreatdDate;
    @api toCreatedDate;
    @api typeComboVal;
    @api statusComboVal;
    

    
    connectedCallback(){
      /**
       * 부모(Main)에서 보내준 데이터 확인
       */
      console.log('>>> This Is New Modal : headComboVal' + this.headComboVal);
      console.log('>>> This Is New Modal : suComboVal' + this.suComboVal);
      console.log('>>> This Is New Modal : teamComboVal' + this.teamComboVal);
      console.log('>>> This Is New Modal : searchKey' + this.searchKey);
      console.log('>>> This Is New Modal : searchEmpNum' + this.searchEmpNum);
      console.log('>>> This Is New Modal : firstDayOfMonthDate' + this.firstDayOfMonthDate);
      console.log('>>> This Is New Modal : todayDate' + this.todayDate);
      console.log('>>> This Is New Modal : fromCreatdDate' + this.fromCreatdDate);
      console.log('>>> This Is New Modal : toCreatedDate' + this.toCreatedDate);
      console.log('>>> This Is New Modal : typeComboVal' + this.typeComboVal);
      console.log('>>> This Is New Modal : statusComboVal' + this.statusComboVal);
      
    }
  
    /**
    * 취소 버튼 클릭 시 
    */  
    handleClose(){
      this.close();
    }
    /**
    * 고객사 List Data
    */  
    @track customerListData = [
      {id: '1', customerCode: '12345', customerName : "A고객사"},
      {id: '2', customerCode: '67891', customerName : "B고객사"}
    ];
    /**
    * 수령자 정보 등록 Data
    */  
    @track recipientInfoData = [
      { id: '1', name: '김길동', department: 'A부서', email: 'rlfehd@cj.net', phone: '0101231233', officeNumber: 'DOC-456', taxIssuance: 'SELLER-001', isRepresentative: '판매처 1', lastInputDate: 'MANAGER-001', lasModifiedCDate: '관리처 1', lastModified: 'SU-001' },
      { id: '2', name: '윤미라', department: 'B부서', email: 'alfk@cj.net', phone: '0101234333', officeNumber: 'DOC-789', taxIssuance: 'SELLER-002', isRepresentative: '판매처 2', lastInputDate: 'MANAGER-002', lasModifiedCDate: '관리처 2', lastModified: 'SU-002' },
      { id: '3', name: '김소라', department: 'C부서', email: 'thfk@cj.net', phone: '010122343', officeNumber: 'DOC-123', taxIssuance: 'SELLER-003', isRepresentative: '판매처 3', lastInputDate: 'MANAGER-003', lasModifiedCDate: '관리처 3', lastModified: 'SU-003' },
      { id: '4', name: '안진국', department: 'D부서', email: 'wlsrmr@cj.net', phone: '012343231233', officeNumber: 'DOC-123', taxIssuance: 'SELLER-003', isRepresentative: '판매처 3', lastInputDate: 'MANAGER-003', lasModifiedCDate: '관리처 3', lastModified: 'SU-003' },
      { id: '5', name: '소이현', department: 'E부서', email: 'dlgus@cj.net', phone: '01023431233', officeNumber: 'DOC-123', taxIssuance: 'SELLER-003', isRepresentative: '판매처 3', lastInputDate: 'MANAGER-003', lasModifiedCDate: '관리처 3', lastModified: 'SU-003' },

    ];
}