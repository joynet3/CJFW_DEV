/**
 * @Class : IFN_EIF1003_RE001_MD002_Scheduler.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023.09.15
 * @Version : 1.0
 * @Description : 리멤버 명함첩 데이터 리드 등록 스케쥴러
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.15 | 박지오          | 최초작성
 * */
public with sharing class IFN_EIF1003_RE001_MD002_Scheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new Que(1, new List<IFN_EIF1003_RE001_MD001.Stack>()));
    }
    public class Que implements Queueable, Database.AllowsCallouts {
        private Integer pageNumber;
        private List<IFN_EIF1003_RE001_MD001.Stack> rememberStacks;

        public Que(Integer pageNumber, List<IFN_EIF1003_RE001_MD001.Stack> rememberStacks) {
            this.pageNumber = pageNumber;
            this.rememberStacks = rememberStacks;
        }
        public void execute(QueueableContext context) {
            // Callout 수행
            IFN_EIF1003_RE001_MD001 RE001 = new IFN_EIF1003_RE001_MD001();
            IFN_EIF1003_RE001_MD001.RE001RequestWrapper request = new IFN_EIF1003_RE001_MD001.RE001RequestWrapper();
            IFN_EIF1003_RE001_MD001.RE001SuccessWrapper response;
            request.page = pageNumber;
            RE001.param = request;
            IFN_CalloutResult getRemember = RE001.callout();
            if ('S'.equals(getRemember.result)) {
                response = (IFN_EIF1003_RE001_MD001.RE001SuccessWrapper) ((IFN_EIF1003_RE001_MD001.RE001ResultWrapper) getRemember.response).result;
                List<IFN_EIF1003_RE001_MD001.Stack> addStacks = response.stacks;
                rememberStacks.addAll(addStacks);
            }

            // 다음 페이지가 있으면 다음 Queueable 작업을 예약
            if (pageNumber < response.metainfo.total_pages) {
                System.enqueueJob(new IFN_EIF1003_RE001_MD002_Scheduler.Que(pageNumber + 1, rememberStacks));
            } else if(pageNumber == response.metainfo.total_pages){
                IFN_EIF1003_RE001_MD002_Batch RE002 = new IFN_EIF1003_RE001_MD002_Batch(this.rememberStacks);
                Database.executeBatch(RE002);
            }
        }
    }

}