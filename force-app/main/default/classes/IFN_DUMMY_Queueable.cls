/**
 * @Class : IFN_DUMMY_Queueable.cls
 * @group Framework : 
 * @Author :  조일근 
 * @Date : 2023.09.05
 * @Version : 1.0
 * @Description :
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.05 | 조일근  | 최초작성
 * */
global class IFN_DUMMY_Queueable  implements Queueable   {
    global String SDATE;
    global String EDATE;
    public IFN_DUMMY_Queueable() {
        DateTime sDate = System.now().addDays(-2);
        DateTime eDate = System.now().addDays(-1);

        this.SDATE = sDate.format('yyyyMMdd');
        this.EDATE = eDate.format('yyyyMMdd');
    }
    global void execute(QueueableContext sc) {
        System.debug('this.SDATE : ' + this.SDATE);
    }
}