// barcodeScannerExample.js
import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';

export default class BarcodeScannerExample extends LightningElement {

    //recordId, buttonType은 Lightning Component에서 넘겨줌
    @api recordId;
    @api buttonType;
    @api returnBarcode;
    myScanner;
    scanButtonDisabled = false;
    scannedBarcode = '';

    handleReturnBarcode(){
        var recordId = this.recordId;
        var value = this.scannedBarcode;
        const selectEvent = new CustomEvent('returnBarcode',
        {
            detail: { recordId, value }
        }); 
        //alert('####After select event');
        this.dispatchEvent(selectEvent);
        //alert('####After dispatch event');
    }
    
    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner == null && !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }
    }
    
    handleBeginScanClick(event) {
        this.scannedBarcode = '';

        if (this.myScanner != null && this.myScanner.isAvailable()) {
            const scanningOptions = { 
                barcodeTypes: 
                [
                    this.myScanner.barcodeTypes.CODE_128,
                    this.myScanner.barcodeTypes.CODE_39,
                    this.myScanner.barcodeTypes.CODE_93,
                    this.myScanner.barcodeTypes.DATA_MATRIX,
                    this.myScanner.barcodeTypes.EAN_13,
                    this.myScanner.barcodeTypes.EAN_8,
                    this.myScanner.barcodeTypes.ITF,
                    this.myScanner.barcodeTypes.PDF_417,
                    this.myScanner.barcodeTypes.QR,
                    this.myScanner.barcodeTypes.UPC_E
                ]
            };
            this.myScanner
                .beginCapture(scanningOptions)
                .then((result) => {
                    this.scannedBarcode = result.value;
                    this.handleReturnBarcode();
                })
                .catch((error) => {
                    alert(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '바코드를 인식 할 수 없습니다.',
                                message:
                                    ' 다시 인식해주세요',
                                variant: 'error',
                                mode: 'sticky' 
                            })
                        );
                })
                .finally(() => {
                    console.log('#finally');
                    this.myScanner.endCapture();
                });
        } else {
            // BarcodeScanner is not available
            // Not running on hardware with a camera, or some other context issue
            console.log(
                'Scan Barcode button should be disabled and unclickable.'
            );
            console.log('Somehow it got clicked: ');
            console.log(event);

            // Let user know they need to use a mobile phone with a camera
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Barcode Scanner Is Not Available',
                    message:
                        'Try again from the Salesforce app on a mobile device.',
                    variant: 'error'
                })
            );
        }
    }
}