import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import updateContentVersion from '@salesforce/apex/CategoryFileUploadContorller.updateContentVersion';
import getFileList from '@salesforce/apex/CategoryFileUploadContorller.getFileList';

const columns =[
    {label: 'Title' , fieldName: 'Title', type: 'text'},
    {label: 'FileType' , fieldName: 'FileType', type: 'text'},
    {label: 'CreatedDate' , fieldName: 'CreatedDate', type: 'date'}
];

export default class CjfwCategoryFileUploadList extends LightningElement {

    @api category; // 카테고리 이름
    @api recordId;
    @track error;
    @track data;
    @track wireResult;
    columns = columns;
    saveFile;
    data = []; 
    totalCount = 0; 

    get acceptedFormats() {
        return ['.pdf','.png','.jpg'];
    }

    // renderedCallback(){
    //     this.ChangeStyle();
    // }
    // ChangeStyle(){
    //     const style = document.createElement('style');
    //     style.innerText = `
    //     .fileuploder .slds-file-selector__body {
    //         display: none !important;
    //     }
    //     .fileuploder .slds-file-selector__dropzone {
    //         border: none !important;
    //     }
    //     .fileuploder .slds-file-element .slds-file-element__label {
    //         display: none !important;
    //     }
    //     .fileuploder lightning-primitive-icon {
    //         display: none !important;
    //     } `;
    
    // }

    @wire(getFileList, { recordId: '$recordId', category: '$category'})
    wireData(result){
        this.wireResult=result;
        if(result.data){
            this.data = result.data;
            this.totalCount = result.data.length; // 카테고리 파일 개수 
        } else if(result.error){
            this.error = result.error;
        }
    }

    handleUploadFinished(event) {
        
        const uploadedFiles = event.detail.files;
        // 등록할 파일 이름 넣을 때 사용
        // let uploadedFileNames = ''; 
        // for(let i = 0; i < uploadedFiles.length; i++) { 
        //     uploadedFileNames += uploadedFiles[i].name + ', '; 
        // } 
        this.dispatchEvent( 
            new ShowToastEvent({ 
                title: 'Success', 
                message: uploadedFiles.length + ' 개의 파일 등록 성공', 
                //message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames, 
                variant: 'success', 
            }), 
        ); 
        console.log('event.detail.files => ' + JSON.stringify(event.detail.files));

        updateContentVersion({uploadedFiles : JSON.stringify(uploadedFiles), category: this.category})
        .then(() => {
            refreshApex(this.wireResult); // 파일 등록하면 새로고침 안해도 카테고리마다 파일 들어감
            
        }).catch((error) => {
            this.error = error;
        });
        console.log('uploadedFiles => ' + JSON.stringify(uploadedFiles));

    } 


}