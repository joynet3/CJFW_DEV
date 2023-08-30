/************************************************************************************
 * File Name        : Account.trigger
 * Author           : Minje.Kim
 * Date             : 2022.08.19
 * Tester           : Account_tr_test.cls
 * Description      : Account Trigger Handler Class
 * Modification Log
 * ===================================================================================
 * Ver      Date            Author          Modification
 * ===================================================================================
   1.0      2022.08.19      Minje.Kim       Create
*************************************************************************************/
trigger Account on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Account_tr().run();
}