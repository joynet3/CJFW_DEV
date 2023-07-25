/************************************************************************************
 * File Name   		: ContentDocument.trigger
 * Author	  		: Seoyoung.Lee
 * Date				: 2023.04.14
 * Tester	  		: ContentDocument_tr_test.cls
 * Description 		: ContentDocument Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
 * 1.0      2023.04.14      Seoyoung.Lee       Create
*************************************************************************************/
trigger ContentDocument on ContentDocument (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ContentDocument_tr().run();
}