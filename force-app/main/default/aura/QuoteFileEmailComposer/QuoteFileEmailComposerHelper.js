({
    getQuoteFile : function(component, searchKey) {

        let action = component.get("c.getQuoteFile");
        action.setParams({
            "quoteFileId" : component.get("v.quoteFileId")
        });

		action.setCallback(this, function(response) {
            let state = response.getState();

            if(state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                let objQuoteFile = returnValue.objQuoteFile;
                component.set("v.objQuoteFile", objQuoteFile);
                // 선택된 견적파일의 DocumentId 인입
                console.log( ' objQuoteFile ::: ' + JSON.stringify(objQuoteFile));
                let filesTobeAttached = component.get('v.filesTobeAttached');
                let objfile = { 		            
                    documentId : objQuoteFile.ContentDocumentId__c	
                };		
                filesTobeAttached.push(objfile);
                component.set('v.filesTobeAttached', filesTobeAttached);
                console.log( ' filesTobeAttached ::: ' + JSON.stringify(filesTobeAttached));
            }
            else if(state === "ERROR") {
                let errors = response.getError();
                console.log("errors", JSON.stringify(errors));
                if(errors) {
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }else if(errors[0] && errors[0].pageErrors[0].message){
                        this.showToast("error", errors[0].pageErrors[0].message);
                    }else {
                        this.showToast("error", "Unknown error");
                    }
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
    },

    delUploadedfiles : function(component,documentId) {  
        console.log('in deletefiles');
        var action = component.get("c.deleteFiles");           
        action.setParams({
            "sdocumentId":documentId            
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state === 'SUCCESS'){  
                console.log('in delete success');
                component.set("v.showSpinner", false); 
            }else if(state === 'ERROR'){
                helper.showErrorToast(component, response);
            }  
        });  
        $A.enqueueAction(action);  
    },
    convertTo18 : function(component) {
        var idParts = component.get("v.emailTemplateId").match(/(.{5})(.{5})(.{5})/)
        var base36 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.split('')
        var output = []
        var outer, inner, subparts, buffer
        
        for(outer = 1; outer <= 3; outer++) {
            subparts = idParts[outer].split('')
            buffer = 0
            for(inner = 4; inner >= 0; inner--) {
                buffer = (buffer << 1) | (subparts[inner].match(/[A-Z]/) ? 1 : 0)
            }
            output.push(base36[buffer])
        }
        
        component.set("v.emailTemplateId",component.get("v.emailTemplateId") + output.join(''));
    },
    displayAttachments: function(templateId,component,event,helper) {  
        var emailTemplates = component.get('v.emailTemplates');
        component.set('v.attachmentsFromTemplate', []);
        var selTemplate = emailTemplates.filter(template => template.Id === templateId);
        if(selTemplate && selTemplate.length > 0){
            if(selTemplate[0].Attachments && selTemplate[0].Attachments.length > 0){
                component.set('v.attachmentsFromTemplate', selTemplate[0].Attachments);
            }
        }
    },
    getEmailTemplateBody: function(templateId, whatId, component, helper){
        var action = component.get('c.getTemplateDetails');
        action.setParams({
            "templateId" : templateId,
            "whoId" : component.get('v.whoId'),
            "whatId" : component.get('v.whatId')
        });
        action.setCallback(this, function(response){ 
            var emailmsg = response.getReturnValue();
            console.log('email**'+JSON.stringify(emailmsg));
            component.set('v.subject', emailmsg.subject);
            component.set('v.emailBody', emailmsg.body);
            component.set('v.attachmentsFromTemplate', emailmsg.fileAttachments);
            //helper.displayAttachments(templateId,component,event,helper);
            component.set('v.showSpinner', false);            
        });
        $A.enqueueAction(action);
    },
    showErrorToast : function(component, response){
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " + errors[0].message);
                component.find('notifLib').showToast({
                    variant : 'error',
                    "title": "Error!",
                    "message": errors[0].message
                });
            }
        } else {
            console.log("Unknown error");
        }
    }
    
})