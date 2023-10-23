/**
 * @Class : IFN_EIF1003_RE001_MD001_que.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023.09.18
 * @Version : 1.0
 * @Description : Remember 명함 데이터
 *               - 페이징 처리 된 데이터를 통합 리드등록 배치 실행
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.18 | 박지오         | 최초작성
 * */
public with sharing class IFN_EIF1003_RE001_MD001_que implements Queueable, Database.AllowsCallouts {

    public String interfaceId = 'IFN_EIF1003_RE001_MD001';
    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;

    private Integer pageNumber;
    private List<IFN_EIF1003_RE001_MD001.Stack> rememberStacks;

    public IFN_EIF1003_RE001_MD001_que(Integer pageNumber, List<IFN_EIF1003_RE001_MD001.Stack> rememberStacks) {
        this.pageNumber = pageNumber;
        this.rememberStacks = rememberStacks;
        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();
    }

    public void execute(QueueableContext context) {
        // Callout 수행
        IFN_EIF1003_RE001_MD001 RE001 = new IFN_EIF1003_RE001_MD001();
        IFN_EIF1003_RE001_MD001.RE001RequestWrapper request = new IFN_EIF1003_RE001_MD001.RE001RequestWrapper();
        IFN_EIF1003_RE001_MD001.RE001SuccessWrapper response;
        request.page = pageNumber;
        RE001.param = request;
        try {
            IFN_CalloutResult getRemember = RE001.callout();
            if ('S'.equals(getRemember.result)) {
                response = (IFN_EIF1003_RE001_MD001.RE001SuccessWrapper) ((IFN_EIF1003_RE001_MD001.RE001ResultWrapper) getRemember.response).result;
                if (response.stacks.size() > 0) {
                    List<IFN_EIF1003_RE001_MD001.Stack> addStacks = response.stacks;
                    rememberStacks.addAll(addStacks);
                    // 다음 페이지가 있으면 다음 Queueable 작업을 예약
                    if (pageNumber < response.metainfo.total_pages) {
                        System.enqueueJob(new IFN_EIF1003_RE001_MD001_que(pageNumber + 1, rememberStacks));
                    } else if (pageNumber == response.metainfo.total_pages) {
                        IFN_EIF1003_RE001_MD001_ba RE002 = new IFN_EIF1003_RE001_MD001_ba(this.rememberStacks);
                        Database.executeBatch(RE002, 500);
                    }
                } else if (response.stacks.size() == 0) {
                    System.debug('해당 날짜에 등록된 명함첩이 없습니다.');
                }
            } else {
                // 인터페이스 처리 오류 Or Http 오류 결과 수신
                System.debug(getRemember.message);
            }
        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber() + e.getMessage() + e.getStackTraceString());
            this.logWrap.Status = 'ERROR';
        }
    }
}