/**
 * @Class : IFN_EIF1002_FS001_MD001_sc.cls
 * @group Framework : 
 * @Author : sancho
 * @Date : 2023.08.30
 * @Version : 1.0
 * @Description : 식품(첨가물)품목제조보고-전용유 조회 스케쥴러
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.08.30 | sancho         | 최초작성
 * */
global class IFN_EIF1002_FS001_MD001_ba_sc implements Schedulable {
    global void execute(SchedulableContext sc) {
        IFN_EIF1002_FS001_MD001_ba ba = new IFN_EIF1002_FS001_MD001_ba();
        Database.executeBatch(ba, 1);
    }
}