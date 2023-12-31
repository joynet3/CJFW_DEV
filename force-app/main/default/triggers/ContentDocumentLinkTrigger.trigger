/**
* ContentDocumentLink Trigger
*
*@group  프로젝트 내부에서 사용하는 업무 그룹 작성
*@author 조형준
*@since 2023-08-16  내용 작성
*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
    new ContentDocumentLinkTriggerHandler().run();
}