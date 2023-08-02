/**
 * 영업일을 확인하여 날짜를 계산하는 공통 Class
 * 
 * @group Common
 * @author 진현욱
 * @since 2023-08-02 
 * @example 
 *    Setup > Settings > Company Settings > Business Hours, Holidays를 활용
 *    (Singletone Pattern을 이용하여 인스턴스 재활용 : 메모리 낭비 줄이기 위함)
 *    사용 방법 : 1. 클래스 인스턴스 생성   
 *               2. 사용할 메소드 호출   
 *    * 메소드별 예시는 아래와 같은 기준으로 작성됨
 *    * Business Hours Timezone : Asia/Seoul 
 *      Business Hours          : 월-금 AM9:00 ~ PM6:00 
 *    
 *    참고
 *    * GMT : 그리니치평균시 
 *    * KST : 한국표준시 (GMT + 9 hour)
 * 
 * COMM_BusinessDay bDay  = COMM_BusinessDay.getInstance();  
 * COMM_BusinessDay bDay  = COMM_BusinessDay.getInstance(TimeZoneSidKey); 
 * Ex 1) 현재 시간으로부터 영업시간 10시간 후
 * Datetime dtAfterHour = bDay.calcADayWorkingDatetime(System.now(), 10);
 * Ex 2) 오늘부터 영업일 20일 후
 * Datetime dtAfterDay = bDay.calcTargetWorkingDatetime(System.now(), 20);
 * Ex 3) 오늘부터 영업일 20일 전 
 * Datetime dtBeforeDay = bDay.calcTargetminusWorkingDate(System.now(), -10);
 * Ex 4) 오늘~ 10일 뒤 날짜 사이 영업일 수 
 * Integer cntBDay = bDay.calcBusinessDay(System.now().addDays(10));
 * Ex 5) 오늘이 영업일인지 여부 확인
 * Boolean isBDay = bDay.isBusinessDay (System.now());
 * Ex 6) 다음 영업일 확인
 * Datetime dtNextBDay = bDay.nextBusinessDay(System.now());
 * Ex 7) 이전 영업일 확인
 * Datetime dtPrevBDay = bDay.prevBusinessDay(System.now());
 */

 public with sharing class COMM_BusinessDay {
    
    public static COMM_BusinessDay bDay = null;                     // Class 객체
    private BusinessHours bh {get;set;}                             // 영업일인지 확인할 Business Hour (Private으로 생성하여 외부에서 새로운 객체 생성을 막음)
    private BusinessHours[] bhLi {get;set;}                         // Query Exception 회피하기 위한 배열
    public final Time WORKING_TIME = Time.newInstance(9, 0, 0, 0);  // 기본 근무 시간

    /**
     * Default Instance 생성
     * 
     * @example 
     *      COMM_BusinessDay bDay  = COMM_BusinessDay.getInstance();  
     */  
    public static COMM_BusinessDay getInstance(){
        if( bDay == null ) bDay = new COMM_BusinessDay();
        return bDay;
    }

    /**
     * User Timezone SidKey를 활용한 Instance 생성
     * 
     * @param param User TimeZoneSidKey 
     * @example 
     *      COMM_BusinessDay bDay  = COMM_BusinessDay.getInstance('Asia/Seoul');  
     */ 
    public static COMM_BusinessDay getInstance(String param){
        if( bDay == null ) bDay = new COMM_BusinessDay(param);
        return bDay;
    }

    /**
     * 기본 생성자
     */
    private COMM_BusinessDay() {
        bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
    }

    /**
     * User Timezone SidKey를 활용한 생성자
     * @param param User TimeZone SidKey 
     */
    private COMM_BusinessDay(String param) {
        try {
            bhLi =   [SELECT Id FROM BusinessHours WHERE TimeZoneSidKey=:param AND isActive = true];
            if(bhLi.size() > 0){
                bh = [SELECT Id FROM BusinessHours WHERE TimeZoneSidKey=:param AND isActive = true LIMIT 1];
            } else {
                bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }

    /**
     * Target Date/Time에 afterHours를 더한 영업일
     * 
     * @param dt           Target 날짜/시간
     * @param afterHours   계산할 시간 
     * @return  `Datetime`
     * @example 
     *    Datetime dtAfterHour = bDay.calcTargetAfterHour()       
     */
    public Datetime calcTargetAfterHour(Datetime dt, Integer afterHours){
        Integer weekendHoursCnt = 0;
        Integer workingHours = 0;
        Integer t =1;

        do {
            if(!BusinessHours.isWithin(bh.id, dt.addHours(t))){
                weekendHoursCnt++;
                t++;
            } else {
                workingHours++;
                t++;
            }
        } while (workingHours <= afterHours);

        if(BusinessHours.isWithin(bh.id, dt.addHours(0)))weekendHoursCnt--;

        return dt.addHours(workingHours + weekendHoursCnt);
    }

    /**
     * Target Date/Time에 afterDays를 더한 영업일
     * 
     * @param dt         Target 날짜/시간
     * @param afterDays  계산할 일자
     * @return  `Datetime`
     * @example 
     *      
     */
    public Datetime calcTargetAfterDateTime(Datetime dt, Integer afterDays){
         // Integer weekendCnt = 0;
        dt = nextBusinessDay(dt);
        for( Integer i = 1; i <= afterDays; i++) {
            if(!BusinessHours.isWithin(bh.id, dt.addDays(i))){
                afterDays++;
            }
        }
        return dt.addDays(afterDays);
    }

    /**
     * Target Date에 afterDays를 더한 영업일
     * 
     * @param dt           Target 날짜/시간
     * @param afterDays    계산할 일자
     * @return  `Datetime`
     * @example 
     *      
     */
    public Datetime calcTargetAfterDate(Date dt, Integer afterDays){
        Datetime targetDt = Datetime.newInstance(dt.year(), dt.month(), dt.day());
        targetDt = nextBusinessDay(targetDt);
        Integer weekendCnt = 0;
        Integer workingDays = 0;
        for( Integer i = 1; i <= afterDays; i++) {
            if(!BusinessHours.isWithin(bh.id, targetDt.addDays(i))){
                weekendCnt++;
            } else {
                workingDays++;
            }
        }
        
        // Boolean isPassed = false;
        Integer t = 1;
        if (weekendCnt > 0) {
            do {
                if(!BusinessHours.isWithin(bh.id, targetDt.addDays(afterDays + t))){
                    weekendCnt++;
                } else {
                    workingDays++;
                    // isPassed = true;
                }
                t++;
            } while (workingDays < afterDays);
        }

        return targetDt.addDays(afterDays + weekendCnt);
     
    }

    /**
     * Target Date에 beforeDays를 뺀 영업일
     * 
     * @param dt          Target 날짜
     * @param beforeDays  계산할 일자 (negative)
     * @return  `Datetime` 
     * @example 
     *      
     */
    public Datetime calcTargetBeforeDate(Date dt, Integer beforeDays){
        Datetime targetDt = Datetime.newInstance(dt.year(), dt.month(), dt.day());
        targetDt = prevBusinessDay(targetDt);
        
        Integer weekendCnt = 0;
        Integer workingDays = 0;
        for( Integer i = -1; i >= beforeDays; i--) {
            if(!BusinessHours.isWithin(bh.id, targetDt.addDays(i))){
                weekendCnt++;
            } else {
                workingDays++;
            }
        }
        
        // Boolean isPassed = false;
        Integer t = -1;
        if (weekendCnt > 0) {
            do {
                if(!BusinessHours.isWithin(bh.id, targetDt.addDays(beforeDays + t))){
                    weekendCnt++;
                } else {
                    workingDays++;
                    // isPassed = true;
                }
                t--;
            } while (workingDays < math.abs(beforeDays));
        }

        return prevBusinessDay(targetDt.addDays(beforeDays - weekendCnt));
        
    }

    /**
     * Target Date와 Today 사이의 영업일 계산
     * 
     * @param dt           Target 날짜
     * @return  `Integer`
     * @example 
     *      
     */
    public Integer calcBusinessDay(Date dt) {
        Datetime targetDt = Datetime.newInstance(dt, WORKING_TIME);
        Integer betweenDays = daysBetween(dt, system.today());
        Integer weekendCnt = 0;

        // dt < system.today()
        if (betweenDays >= 0) {
            for (Integer i = 1; i <= betweenDays; i++) {
                if (!BusinessHours.isWithin(bh.id, targetDt.addDays(i))) {
                    weekendCnt++;
                }
            }
        // dt > system.today()
        } else {
            for (Integer i = 0; i > betweenDays; i--) {
                if (!BusinessHours.isWithin(bh.id, targetDt.addDays(i))) {
                    weekendCnt++;
                }
            }
        }
        

        return math.abs(betweenDays) - weekendCnt;
    }

    /**
     * Target Date와 Due Date 사이의 영업일 계산
     * 
     * @param targetDate  Target 날짜
     * @param dueDate     계산이 필요한 날짜
     * @return  `Integer`
     */
    public Integer calcBusinessDay(Date targetDate, Date dueDate) {
        Datetime targetDt = Datetime.newInstance(targetDate, WORKING_TIME);
        Datetime dueDt = Datetime.newInstance(dueDate, WORKING_TIME);
        Integer betweenDays = daysBetween(targetDate, dueDate);
        Integer weekendCnt = 0;

        for (Integer i = 1; i <= betweenDays; i++) {
            if (!BusinessHours.isWithin(bh.id, targetDt.addDays(i))) {
                weekendCnt++;
            }
        }
        

        return betweenDays - weekendCnt;
    }

    /**
     * 영업일 여부 확인 
     *   - true 영업일 / false 휴일
     * @param dt          Target 날짜/시간
     * @return  `Boolean` 
     * @example 
     *          
     */
    public Boolean isBusinessDay(Datetime dt) {
        return BusinessHours.isWithin(bh.id, dt);
    }
    
    /**
     * 다음 근무 시간 
     *   - dt가 영업일이면 dt, 영업일이 아니면 다음 영업일 Return
     * @param dt           Target 날짜/시간
     * @return  `DateTime`
     */
    public DateTime nextBusinessDay(Datetime dt) {
        if(!isBusinessDay(dt)) {
            return BusinessHours.nextStartDate(bh.id, dt);
        } else {
            return dt;
        }
    }

    /**
     * 이전 근무 시간
     *   - dt가 영업일이면 dt, 영업일이 아니면 이전 영업일 Return
     * 
     * @param dt            Target 날짜/시간
     * @return  `DateTime`
     */
    public DateTime prevBusinessDay(Datetime dt) {
        if(!isBusinessDay(dt)) {
            Datetime targetDt = dt;
            Boolean flag = true;
            Integer t = -1;
            while (flag) {
                targetDt = nextBusinessDay(targetDt.addDays(t));
                if(targetDt < dt) {
                    flag = false;
                } else {
                    t--;
                }
            }
            return targetDt;
        } else {
            return dt;
        }
    }

    /**
     * 다음 근무 시간 List
     *   - target datetime 부터 n영업일 계산
     * @param dt           Target 날짜/시간
     * @param businessDays    계산할 일자
     * @param withHoliday    휴일 포함여부
     * @return  `List<DateTime>`
     */
    public List<DateTime> nextBusinessDays(Datetime dt, Integer businessDays, Boolean withHoliday) {
        List<Datetime> result = new List<Datetime>();
        dt = Date.valueOf(dt.format('yyyy-MM-dd'));
        Integer i = 0, j = 0;
        while(j <= businessDays) {
            if(BusinessHours.isWithin(bh.id, dt.addDays(i))){
                result.add(dt.addDays(i));
                j++;
            } else if(withHoliday) {
                result.add(dt.addDays(i));
            }
            i++;
        }
        return result;
    }

    /**
     * 두 일자간 차이 계산
     * 
     * @param targetDate 시작일
     * @param dueDate    종료일
     * @return  `Integer`
     */
    public static Integer daysBetween(Date targetDate, Date dueDate) {
        return targetDate.daysBetween(dueDate);
    }
}