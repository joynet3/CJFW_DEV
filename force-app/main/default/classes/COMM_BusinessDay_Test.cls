/**
 * 영업일을 확인하여 날짜를 계산하는 공통 Class
 * 
 * @group Common
 * @author 진현욱
 * @since 2023-08-02 
 * 
 *  주말만 공휴일로 계산하기 위해 과거 Date 사용
 *  calcBusinessDay(targetD)는 테스트를 실행하는 날짜에 따라 값이 변경되어 주석 처리
*/
@isTest
public class COMM_BusinessDay_Test {

    static DateTime targetDt = DateTime.newInstanceGMT(1999, 1, 1);
    static Date targetD = Date.newInstance(1999, 1, 1);
    
    static void setup() {
        
    }

    @IsTest
    static void testUserTimeZone(){
        Test.startTest();
        
        COMM_BusinessDay bDayKR = COMM_BusinessDay.getInstance('Asia/Seoul');
        
        DateTime dtAfterHour = bDayKR.calcTargetAfterHour(targetDt, 4);
        // System.assertEquals('1999-01-01 04:00:00 AM', makeGMTFormatStr(dtAfterHour));

        DateTime dtAfterDateTime = bDayKR.calcTargetAfterDateTime(targetDt, 10);
        // System.assertEquals('1999-01-15 00:00:00 AM', makeGMTFormatStr(dtAfterDateTime));

        DateTime dtAfterDate = bDayKR.calcTargetAfterDate(targetD, 4);
        // System.assertEquals('1999-01-07 00:00:00 AM', makeGMTFormatStr(dtAfterDate));

        DateTime dtBeforeDate = bDayKR.calcTargetBeforeDate(targetD, -4);
        // System.assertEquals('1998-12-25 00:00:00 AM', makeGMTFormatStr(dtBeforeDate));

        Integer cntBDay = bDayKR.calcBusinessDay(targetD);
        //System.assertEquals(9999, cntBDay);

        Integer cntDueDate = bDayKR.calcBusinessDay(targetD, targetD.addDays(5));
        // System.assertEquals(4, cntDueDate);

        Boolean isBday = bDayKR.isBusinessDay(targetDt);
        // System.assertEquals(true, isBday);

        DateTime dtNextBday = bDayKR.nextBusinessDay(targetDt);
        // System.assertEquals('1999-01-01 00:00:00 AM', makeGMTFormatStr(dtNextBday));

        DateTime dtPrevBday = bDayKR.prevBusinessDay(targetDt.addDays(1));
        // System.assertEquals('1999-01-01 00:00:00 AM', makeGMTFormatStr(dtNextBday));

        List<DateTime> dtNextWorkdays = bDayKr.nextBusinessDays(targetDt, 2, false);

        List<DateTime> dtNextWorkday2s = bDayKr.nextBusinessDays(targetDt, 0, false);

        

        Test.stopTest();
        
    }

    @IsTest
    static void testUserTimeZone2(){
        Test.startTest();

        COMM_BusinessDay bDay = COMM_BusinessDay.getInstance();

        System.debug(bDay.isBusinessDay (System.now()));

        //bDay.prevBusinessDay(System.now());

        Test.stopTest();
    }

    /**
     * yyyy-MM-dd HH:mm:ss a 형태로 DateTime을 변환
     * 
     * @param dt         GMT Formatted String 으로 변환할 Dt
     * @return  `String`
     */
    private static String makeGMTFormatStr(DateTime dt) {
        String format = 'yyyy-MM-dd HH:mm:ss a';
        return dt.formatGMT(format);
    }
}