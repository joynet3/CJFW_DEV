/**
 * @description       :
 * @author            : JeonKwanWoo(kwanwoo.jeon@daeunextier.com)
 * @group             :
 * @last modified on  : 01-02-2023
 * @last modified by  : JeonKwanWoo(kwanwoo.jeon@daeunextier.com)
**/
public with sharing class SalesDecreaseNotice_sc implements Schedulable{

    /*
    매주 월요일 8시
    SalesDecreaseNotice_sc sc = new SalesDecreaseNotice_sc;
    System.schedule('Sales Decrease Noti','0 0 8 ? * MON *', sc);
     */

    public void execute(SchedulableContext sc) {
        SalesDecreaseNotice_ba ba = new SalesDecreaseNotice_ba();
        Database.executeBatch(ba, 30);
    }
}