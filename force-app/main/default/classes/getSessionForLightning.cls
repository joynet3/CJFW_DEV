/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 10-27-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
global class getSessionForLightning {
    global static String getSession(){
        Boolean isTest = Test.isRunningTest();
        String pageContent = 'SESSION_ID_START_SampleSessionId_SESSION_ID_END';
        if(!isTest) pageContent = Page.getSessionIdFromVFPageFprLightning.getContent().toString();

        Integer s = pageContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = pageContent.indexOf('End_Of_Session_Id');
        return pageContent.substring(s, e);
    }
}