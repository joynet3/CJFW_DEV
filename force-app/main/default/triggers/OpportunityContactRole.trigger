/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-31-2023
 * @last modified by  : yeonji.lim@dkbmc.com
 * Modification Log
 * Ver      Date            Author                  Modification
 * 1.0      10-31-2023      yeonji.lim@dkbmc.com    Create
**/
trigger OpportunityContactRole on OpportunityContactRole (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new OpportunityContactRole_tr().run();
}