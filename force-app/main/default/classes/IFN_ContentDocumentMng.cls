/**
 * @Class : IFN_ContentDocumentMng.cls
 * @group Framework : 파일 저장
 * @Author : 
 * @Date : 2023-07-27
 * @Version : 1.0
 * @Description : 
 * @Modified : 
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.07.27 |  | 최초작성
 * */
public  class IFN_ContentDocumentMng {

    /**
     * fileInfoMapList : 저장될 파일 명 및 마일 컨텐츠 Map List
     * LinkObjRecordId : 연결 오브젝트 레코드 ID
     */
    public static String insertContentDocumentList(Map< String,Object> fileMap,String LinkObjRecordId,String fileCategory){
        List< ContentVersion> cvList = new List< ContentVersion>();
        String ErrYn = 'N';
        try{

            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            String fileSeqKey = (String)fileMap.get('fileSeqKey');// 파일 저장 키
            String fileName = (String)fileMap.get('fileFullName');// File name with extention
            String fileShareYn = fileMap.get('fileShareYn') == null ? 'N' : (String)fileMap.get('fileShareYn');// File 공유여부

            cVersion.PathOnClient = fileName;
            cVersion.Origin = 'C';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = UserInfo.getUserId();//Owner of the file

            String fileName2 = '';
            if(fileName.contains('.')) {
                Integer i =0; 
                for(i = 0 ; i < fileName.split('\\.').size() -1;i++) {
                    fileName2 += '.'+fileName.split('\\.')[i];
                    
                }
                fileName2 = fileName2.substring(1);
            } else {
                fileName2 = fileName;
            }
            

            cVersion.Title = fileName2;
            cVersion.VersionData = EncodingUtil.base64Decode((String)fileMap.get('base64Data')); 
            
            cVersion.FileLinkExtKey__c = fileSeqKey;

            if('Y'.equals(fileShareYn)) {
                cVersion.IsChannel__c = true;
            } else {
                cVersion.IsChannel__c = false;
            }
            cvList.add(cVersion);
            
            
            if(cvList.size()>0) insert cvList;

        } catch (Exception e) {
            System.debug(e.getMessage());
            ErrYn = 'Y';
        }

       
         if('N'.equals(ErrYn)) {

            try{
                Set< Id> cvIdSet = new Set< Id>();
                for(ContentVersion cv : cvList){
                    cvIdSet.add(cv.Id);
                }
                //Save File info to LGC_CategoryFile__c
                List<Map<String, String>> files = new List<Map<String, String>>();

                Map< String,ContentVersion> cvIdMap = new Map< String,ContentVersion>([SELECT id, ContentDocumentId , PathOnClient, Title,IsChannel__c,FileLinkExtKey__c  FROM ContentVersion where Id IN :cvIdSet]);                
                List< ContentDocumentLink> cdlList = new List< ContentDocumentLink>();
                for(Integer i=0; i<  cvList.size(); i++){
                    ContentVersion cv = cvIdMap.get(cvList[i].Id);
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    Map<String, String> fcate = new Map<String, String>();

                    cDocLink.ContentDocumentId = cv.ContentDocumentId;//Add ContentDocumentId
                    cDocLink.LinkedEntityId = LinkObjRecordId;//Add attachment parentId
                    cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                    if(cv.IsChannel__c) {
                        cDocLink.Visibility = 'AllUsers';//AllUsers(고객에 공유할 경우), InternalUsers(공유하지 않을 경우), SharedUsers            
                        fcate.put('fileShareYn','Y');
                    } else {
                        cDocLink.Visibility = 'InternalUsers'; //AllUsers(고객에 공유할 경우), InternalUsers(공유하지 않을 경우), SharedUsers            
                        fcate.put('fileShareYn','N');
                    }
                    

                    cdlList.add(cDocLink);

                    
                    fcate.put('contentVersionId',cv.Id);
                    fcate.put('documentId',cv.ContentDocumentId);
                    fcate.put('name',cv.PathOnClient);
                    fcate.put('fileKey',cv.FileLinkExtKey__c);
                    files.add(fcate);
                    
                }
                if(cdlList.size()>0) {
                    insert cdlList;  
                    saveNewFiles(files,LinkObjRecordId,fileCategory);
                }   

            } catch (Exception e) {
                System.debug(e.getMessage());                
                ErrYn = 'Y';
            }
         }


        return ErrYn;
    }



    /**
     * LGC_CategoryFile__c 파일 업로드 정보 저장 * category : CategoryFileSetting__mdt 에 정의 되어있어야 함
     */
    public static String saveNewFiles(List<Map<String, String>> files, String recordId, String category) {
        System.debug('saveNewFiles.files : ' + files);
        String result = '';
        
        try {
            // record id로 SObject name, label 가져오기
            Id myId = Id.valueOf(recordId);
            String sObjName = myId.getSObjectType().getDescribe().getName();
            String sObjLabel = myId.getSObjectType().getDescribe().getLabel();
            system.debug('Object Name is [' + sObjName+']');
            system.debug('Object Label is [' + sObjLabel+']');
            
            System.debug('files.size() : ' + files.size());

            // categoryfile 오브젝트 생성
            List<LGC_CategoryFile__c> newFiles = new List<LGC_CategoryFile__c>();
            // contentdocumentId Set
            Set<Id> contents = new Set<Id>();

            for(Map<String, String> f : files) {
                String contentId = f.get('contentVersionId');
                String documentId = f.get('documentId');
                String fileName = f.get('name');
                String fileKey = f.get('fileKey');
                Boolean AccessCust = 'Y'.equals(f.get('fileShareYn')) ? true : false;

                contents.add(documentId);
                
                // [filetest.jpg] .뒤에 확장자명 가져오기
                List<String> sList = fileName.split('\\.');
                String fileType = sList[sList.size()-1];

                LGC_CategoryFile__c cf = new LGC_CategoryFile__c(
                    AccessCustomer__c = AccessCust ,//공유여부에 따라 지정
                    Category__c =  category,
                    ContentsVersion__c = contentId ,
                    Extention__c = fileType ,
                    RelatedRecord__c = recordId ,
                    SObjectAPI__c = sObjName ,
                    SObject__c = sObjLabel ,
                    Title__c = fileName ,
                    ContentDocumentId__c = documentId ,
                    IsDelete__c = false,
                    FileLinkExtKey__c = fileKey
                );
                
                newFiles.add(cf);
            }
            System.debug('newFiles.size() : ' + newFiles.size());
            
            if(newFiles.size() > 0) {
                insert newFiles;

            }

            
            // ContentDocument와 categoryfile 연결
            List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
            
            for(LGC_CategoryFile__c cf : newFiles) {
                
                ContentDocumentLink cd = new ContentDocumentLink(
                    LinkedEntityId = cf.Id ,
                    ContentDocumentId = cf.ContentDocumentId__c ,
                    ShareType = 'I' ,
                    Visibility = 'InternalUsers'
                );
                newLinks.add(cd);
            }
            
            if(newLinks.size() > 0) {
                insert newLinks;
            }

            // distribution 확인
            Map<String, ContentDistribution> dMap = new Map<String, ContentDistribution>();
            List<ContentDistribution> dList = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution WHERE ContentDocumentId IN :contents];
            if(dList.size() > 0) {
                for(ContentDistribution cd : dList) {
                    dMap.put(cd.ContentDocumentId, cd);
                }
    
                for(LGC_CategoryFile__c cf : newFiles) {
                    ContentDistribution cd = dMap.get(cf.ContentDocumentId__c);
                    cf.PublicUrl__c = cd.DistributionPublicUrl;
                }
 
                update newFiles;
            }

            
            result = 'SUCCESS';
            
        } catch(Exception e) {
            System.debug(e.getMessage());                            
        }
        
        return result;
    }




    
    /**
     * 기존 파일 삭제
     */
    public static void exFileRemove(String delKey)
    {
        try{
            //list로 수정
            
            List<LGC_CategoryFile__c> filelist = [SELECT Id, Category__c, ContentDocumentId__c
            FROM LGC_CategoryFile__c 
            where FileLinkExtKey__c = :delKey];


            if(!filelist.isEmpty())
            {
                Set<Id> contentDocumentIds = new Set<Id>();
                for(LGC_CategoryFile__c cdl : filelist)
                {
                    contentDocumentIds.add(cdl.ContentDocumentId__c);
                }

                if(!contentDocumentIds.isEmpty())
                {
                    List<ContentDocument> listCd = [SELECT Id                   
                        FROM ContentDocument
                        WHERE Id IN:contentDocumentIds];

                    if(!listCd.isEmpty()) Delete listCd;
                }
                delete filelist;
            }
        } catch(Exception e) {
            
        }
        
    }
   
    
}