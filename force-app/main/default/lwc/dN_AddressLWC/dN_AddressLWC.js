import { LightningElement, api } from 'lwc';

export default class DN_AddressLWC extends LightningElement {
    @api hasSaveFunc;
    @api objAddress;
    @api headerName;
    get getHeaderName() {
        return this.headerName;
    }
    @api bIsSearchAddr;
    @api bIsShowSpinner;
    @api sErrorCode;
    @api intTotalCount;
    @api intTotalPage;
    @api intCntPerPage;
    @api intCurrentPage;
    @api intPageIdx;
    @api listAddress;
    @api AddrInputDiv;
    @api btnSave;
    @api searchForm;

    @api recordId;
    @api objName;
    @api zipCodeField;
    @api addressField;
    @api addressDetailField;
    @api labelPostalCode;
    @api labelAddress;
    @api labelAddressDetail;

    @api dupConfirmStatus;
    @api alertType;
    @api alertMessage;
    @api isShowWarning;
    @api bolAddrDetailCheckBox;







    


}