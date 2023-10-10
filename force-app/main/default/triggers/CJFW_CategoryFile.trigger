/**
 * @description       : 
 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-10-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
trigger CJFW_CategoryFile on ContentVersion (after update) {
    List<ContentDocumentLink> linksToUpdate = new List<ContentDocumentLink>();
    List<ContentVersion> toProcess = null;

    switch on Trigger.operationType {
        when AFTER_UPDATE {
            toProcess = Trigger.new;
            updateValue();
        }
    }
    public Static void updateValue(){

        try {

            Set<Id> documentId = new Set<Id>(); 
            for (ContentVersion cv : toProcess) {
                if (cv.Category__c == '계약 참고자료')documentId.add(cv.ContentDocumentId);
            } 
            // ContentVersion 레코드의 Id를 기반으로 ContentDocumentLink 레코드 조회
            List<ContentDocumentLink> existingLinks = [SELECT Id, ShareType, Visibility, ContentDocumentId
                                                        FROM ContentDocumentLink
                                                        WHERE ContentDocumentId = :documentId];
                                                        System.debug('existingLinks =>' + existingLinks);
            // ShareType와 Visibility 업데이트
            for (ContentDocumentLink link : existingLinks) {
                // link.ShareType = 'I';
                // link.Visibility = 'AllUsers';
                linksToUpdate.add(link);
                System.debug('트리거link =>' + link);
            }
                
            // 변경된 내용을 저장
            if (!linksToUpdate.isEmpty()) {
                update linksToUpdate;
                System.debug('linksToUpdate =>' + linksToUpdate);
            }
        } catch (Exception e) {
            // 예외 처리
            System.debug('예외가 발생했습니다: ' + e.getMessage());

        }
    }
}