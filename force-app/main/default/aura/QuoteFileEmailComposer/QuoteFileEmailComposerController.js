({
    doInit : function(component, event, helper) {
        console.log ('11111');
        component.set('v.showSpinner', true);
        
        var actionAPI = component.find("quickActionAPI");

        // var args = {actionName: "SendEmail",recordId:cmp.get('v.recordId')};
        var targetFields = {
            Subject:{
                value:"Sets by lightning:quickActionAPI component"
            }, 
            HtmlBody:{
                value:'HTML BODY'
            },
            ToAddress:{
                value:'devid@testgmail.com'
            },
            // recordId:{

            // }
            
            // ContentDocumentIds:{
            //     value:['0691D000001cgXXXX']
            // }
        };
        var args = {actionName: "Quote.SendEmail", recordId:'0Q00w000000I8THCA0', targetFields: targetFields};

    //    actionAPI.setActionFieldValues(args).then(function(){
    //        actionAPI.invokeAction(args);
    //    }).catch(function(e){
    //        console.error(e.errors);
    //    });



        actionAPI.getAvailableActions().then(function(result){
            console.log('##getAvailableActions#result==', JSON.stringify(result));
        }).catch(function(e){
            
            console.error(e.errors);
        });
        
        actionAPI.getAvailableActions().then(function(result){
            console.log('##getAvailableActions#result==', JSON.stringify(result));
        }).catch(function(e){
            
            console.error(e.errors);
        });
        
        // actionAPI.getAvailableActionFields().then(function(result){
        //     console.log('##getAvailableActionFields#result==', JSON.stringify(result));
        // }).catch(function(e){
            
        //     console.error(e.errors);
        // });
        
        // actionAPI.setActionFieldValues().then(function(response){
        //     console.log('##WORKING#setActionFieldValues##', response, args);
        //     //actionAPI.invokeAction(args);
        //     console.log('##WORKING#setActionFieldValues##');
        // }).catch(function(e){
        //     console.error(e.errors);
        // });

        console.log ('quoteFileId ::' + component.get('v.quoteFileId'));
        console.log ('quoteId ::' + component.get('v.quoteId'));
        helper.getQuoteFile(component);

        var templateId = component.get('v.emailTemplateId');
        if(templateId && templateId.length==15){
            helper.convertTo18(component);
            templateId = component.get('v.emailTemplateId');
        }
        var whatId = component.get('v.whatId');
        var whoId = component.get('v.whoId');
        var action = component.get('c.getEmailTemplates');

        
        if($A.util.isEmpty(whatId) && $A.util.isEmpty(whoId)){
            component.set('v.uploadRefId', $A.get("$SObjectType.CurrentUser.Id"));
        }else if(!($A.util.isEmpty(whatId))){
            component.set('v.uploadRefId', whatId);
        }else if(!($A.util.isEmpty(whoId))){
            component.set('v.uploadRefId', whoId);
        }
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var templates = response.getReturnValue();
                var folders = [];
                templates.forEach(function(template, index){
                    let existingFolders = [];
                    let folder = {};
                    if(folders.length > 0){
                        existingFolders = folders.filter(fold => fold.Id === template.FolderId);
                    }
                    if(existingFolders.length == 0){
                        folder.Id = template.FolderId;
                        folder.Name = (template.hasOwnProperty('Folder') && 
                                       template.Folder.hasOwnProperty('Name') && 
                                       !($A.util.isEmpty(template.Folder.Name))) ? template.Folder.Name : 'No Folder Name';
                        folders.push(folder);
                    }
                });
                component.set('v.folders', folders);
                component.set('v.emailTemplates', templates);
                
                if((!$A.util.isEmpty(whatId) || !$A.util.isEmpty(whoId)) && templateId){
                    helper.getEmailTemplateBody(templateId,whatId, component, helper);
                }else{
                    component.set('v.showSpinner', false);
                }
            }else if (state === "ERROR") {
                helper.showErrorToast(component,response);
            }
        });
        $A.enqueueAction(action);
    },
    changeBody : function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.getEmailTemplateBody(component.get("v.selTemplateId"), 
                                    component.get('v.whatId'), component, helper);
    },
    filterEmailTemplates:function(component, event, helper) {
        var selFolderId = component.get('v.selFolderId');
        var templates = component.get('v.emailTemplates');
        var filteredTemplates = templates.filter(template => template.FolderId === selFolderId);
        component.set('v.filteredTemplateList', filteredTemplates);
        component.set('v.attachmentsFromTemplate', []);
    },
    sendEmail : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.sendAnEmailMsg');
        console.log(component.get("v.selTemplateId"));
        var filestoAttach = component.get('v.filesTobeAttached');
        var docIds = [];
        var attIds = [];
        for(var i=0; i<filestoAttach.length; i++){
            docIds.push(filestoAttach[i].documentId);
        }
        // var attsFromTemplate = component.get('v.attachmentsFromTemplate');
        // for(var j=0; j<attsFromTemplate.length;j++){
        //     if(attsFromTemplate[j].isContentDocument == false){
        //     	attIds.push(attsFromTemplate[j].attachId);
        //     }else{
        //         docIds.push(attsFromTemplate[j].attachId);
        //     }
        // }
        console.log ( 'docIds ::' + docIds);
        action.setParams({
            "fromAddress"	: component.get('v.fromAddress'),
            "toAddressesStr" : component.get('v.toAddresses'),
            "ccAddressesStr" : component.get('v.ccAddresses'),
            "bccAddressesStr" : component.get('v.bccAddresses'),
            "subject" : component.get('v.subject'),
            "whoId" : component.get('v.whoId'),
            "whatId" : component.get('v.whatId'),
            "body" : component.get('v.emailBody'),
            "senderDisplayName" : component.get('v.senderName'),
            "contentDocumentIds": docIds,
            "attachmentIds" : attIds,
            "createActivity" :component.get('v.logEmail')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find('notifLib').showToast({
                    variant : 'success',
                    "title": "Success!",
                    "message": "이메일이 정상적으로 전송되었습니다."
                });
                setTimeout(function(){ 
                    window.location.href = "/" + component.get("v.quoteId");
                }, 2000);
            }else if(state === "ERROR"){
                helper.showErrorToast(component,response);
                component.set('v.showSpinner', false);
                return;
            }
            // component.set('v.emailBody', '');
            // component.set('v.attachmentsFromTemplate',[]);
            // component.set('v.subject', '');
            // component.set('v.selTemplateId', '');
            // component.set('v.selFolderId', '');
            // component.set('v.filteredTemplateList',[]);
            // component.set('v.filesTobeAttached', []);
            // component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    UploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");  
        var currentFiles = component.get('v.filesTobeAttached');
        if(currentFiles && currentFiles.length > 0){
            currentFiles.push(...uploadedFiles);
            component.set("v.filesTobeAttached",currentFiles);
        }else{
            component.set("v.filesTobeAttached",uploadedFiles);
            component.set('v.filesTobeAttached', uploadedFiles);
        }
    },
    previewFile :function(component,event,helper){  
        var recId = event.getSource().get('v.name');  
        component.set("v.hasModalOpen", true);
        component.set("v.selectedDocumentId" , recId); 
    },
    closeModel: function(component, event, helper) {
        component.set("v.hasModalOpen", false);
        component.set("v.selectedDocumentId" , null); 
    },
    delFiles:function(component,event,helper){
        component.set("v.showSpinner", true); 
        var documentId = event.getSource().get('v.name');
        var uploadedFiles = component.get('v.filesTobeAttached');
        var remainingFiles = uploadedFiles.filter(file => file.documentId != documentId);
        component.set('v.filesTobeAttached', remainingFiles);
        helper.delUploadedfiles(component,documentId);  
    },
    removeAtt : function(component,event,helper){
        var attId = event.getSource().get('v.name');
        var attachments = component.get('v.attachmentsFromTemplate');
        var remainingFiles = attachments.filter(att => att.attachId != attId);
        component.set('v.attachmentsFromTemplate', remainingFiles);
    },
    showcc : function(component,event,helper){
        component.set('v.showCCField', true);
    },
    showbcc : function(component,event,helper){
        component.set('v.showBccField', true);
    },
    fnCancel : function(component, event, helper) {
        window.location.href = "/" + component.get("v.quoteId");
    },
})