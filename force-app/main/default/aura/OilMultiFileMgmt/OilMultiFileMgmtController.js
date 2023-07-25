({
    fnInit : function(component, event, helper) {
        component.set("v.isReady", false);
        // window.pdfjsLib.GlobalWorkerOptions.workerSrc = '/resource/pdf.worker.js';
        helper.doSearchAttachments(component);
    },

    fnOpenModal : function(component, event, helper) {
        var objWrapFile = component.get("v.objWrapFile");

        // Delete modal
        var param = {
            "sHeader"       : "파일 삭제",
            "sContent"      : "<b>'" + objWrapFile.fileName + "'</b>을(를) 삭제하시겠습니까?",
            "sConfirmBtn"   : "삭제",
            "sCancelBtn"    : "취소",
            "confirmAction" : component.getReference("c.fnDelete")
        };

        helper.doCreateConfirmComponent(component, param);
    },
			
    fnDeleteA : function(component, event, helper) {		
        component.set("v.showSpinner", true);	
        component.set("v.isReady", false);	
        var typeAversionId = component.get('v.objWrapFile').typeAversionId;
        console.log('typeAversionId>>'+typeAversionId);
        var option = event.getParam("value");
        console.log('option>>'+option);
        if(option == 'downloadFile'){
            // Create a download link element
            var downloadLink = document.createElement('a');
            downloadLink.href = '/sfc/servlet.shepherd/version/download/' + typeAversionId + '?rendition=PDF';  // Replace with the actual file URL
            downloadLink.download = 'file.pdf';  // Replace with the desired file name    
            downloadLink.click();
            component.set("v.showSpinner", false);      
            component.set("v.isReady", true);	      
            
        }else if(option == 'deleteFile'){
            helper.doDeleteFile(component,'A');	
            component.set("v.isReady", true);	
        }else if(option == 'ocrtest'){
            helper.doOcrTest(component);	
            component.set("v.isReady", true);	
        }else if(option == 'naverOcrtest'){
            helper.doNaverOcrTest(component);	
            component.set("v.isReady", true);	
        }
        	
    },
    fnDeleteB : function(component, event, helper) {		
        component.set("v.showSpinner", true);	
        component.set("v.isReady", false);	
        helper.doDeleteFile(component,'B');	
    },
    fnDeleteC : function(component, event, helper) {		
        component.set("v.showSpinner", true);	
        component.set("v.isReady", false);	
        helper.doDeleteFile(component,'C');
    },
    fnUploadAFinished : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.isReady", false);
        console.log('fnUploadAFinished controller');
        var files = event.getParam("files");
        console.log('files[0].documentId >>'+files[0].documentId);
        helper.doUpdateAttach(component, files[0].documentId, 'A');
    },
    fnUploadBFinished : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.isReady", false);

        var files = event.getParam("files");
        helper.doUpdateAttach(component, files[0].documentId, 'B');
    },
    fnUploadCFinished : function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.isReady", false);

        var files = event.getParam("files");
        helper.doUpdateAttach(component, files[0].documentId, 'C');
    },

    fnFilePreview : function(component, event, helper) {
        var documentId = component.get("v.objWrapFile").typeAfileId;

        var evt = $A.get("e.lightning:openFiles");
        evt.setParams({
            "recordIds" : [documentId]
        });
        evt.fire();
    },
    // afterScriptsLoaded: function(component, event, helper) {
    //     // Wait for the Visualforce page to load
    //     var pdfFrame = component.find("pdfFrame").getElement();
    //     pdfFrame.onload = function() {
    //         // Disable right-click context menu on the PDF iframe
    //         pdfFrame.contentDocument.oncontextmenu = function() { return false; };
    //     };
    // }
})