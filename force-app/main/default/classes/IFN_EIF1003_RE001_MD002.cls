/**
 * @Class : IFN_EIF1003_RE001_MD002.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023.09.18
 * @Version : 1.0
 * @Description : 리멤버 명함첩 리드등록 - 지정된 시간에 스케쥴러 실행
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.18 | 박지오         | 최초작성
 * */
public with sharing class IFN_EIF1003_RE001_MD002 {
    public void SchedulerStart() {
        IFN_EIF1003_RE001_MD002_Scheduler sc = new IFN_EIF1003_RE001_MD002_Scheduler();
        String cronExp = '0 5 0 * * ?';                    // 매일 오전 12시 5분 실행
//        System.schedule('IFN_EIF_RE001_MD002_Scheduler',cronExp, sc);
    }

}