/**
 * @description       : 
 * @author            : yeonji.lim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : yeonji.lim@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   09-18-2023   yeonji.lim@dkbmc.com      Initial Version
**/
public with sharing class CJFW_CreateNewReportPageController {
    
    public String OpptyId { get; set; }
    public DecisionProcess__c decProRecord { get; set; }
    public CJFW_ExpectedIncomeExpenses__c saveResult { get; set; }
    public Map<String,Object> saveResultMap { get; set; }
    public DataWrapper dataWrapper { get; set; }
    
    /* 
     * 생성자
     */
    public CJFW_CreateNewReportPageController() {
        
        OpptyId = '0060w00000D8yoKAAR'; // 추후 url에서 Id값 가져오는 걸로 변경예정 
        // OpptyId = ApexPages.currentPage().getParameters().get('recordId');
        // System.debug('Id = ' + OpptyId);
        
        getRecord();
        System.debug('saveResult = '+ saveResult);
        System.debug('saveResultMap = '+ saveResultMap);

        this.dataWrapper = new DataWrapper(saveResultMap);
        System.debug('dataWrapper = '+ dataWrapper);
    }

    /* 
     * 품의이력Obj에서 해당 레코드 데이터 가져오기
     */
    public void getRecord(){
        decProRecord = [SELECT Id,
                                        ReportSignature__c,
                                        Summary__c,
                                        ClientCompanyName__c,
                                        RepresentativeName__c,
                                        BusinessPath__c,
                                        SalesMonthly__c,
                                        OurSales__c,
                                        InitialDate__c,
                                        Address__c,
                                        RepresentativePhone__c,
                                        PV_EXISTSUP__c,
                                        ExceptionPrice__c,
                                        OpptyDescription__c,
                                        AttachedDocument__c
                                FROM DecisionProcess__c 
                                WHERE Opportunity__c =: OpptyId
                                ORDER BY CreatedDate DESC
                                LIMIT 1]; 


        saveResult = [SELECT saveResult__c
                        FROM CJFW_ExpectedIncomeExpenses__c 
                        WHERE Id = 'a1l0w000001MmAMAA0'
                        // WHERE Opportunity__c =: OpptyId AND IsReportCheck__c = true
                        LIMIT 1];

        saveResultMap = new Map<String,Object>();
        if (saveResult != null) {
            saveResultMap = (Map<String, Object>)JSON.deserializeUntyped(saveResult.saveResult__c);
        }
    }

    /* 
     * 손익계산 Obj에서 넘어온 saveResult 데이터 값 담긴 변수 선언 & 데이터 넣어주기
     */
    private class DataWrapper {
    // ====[거래 상세 내용]=====
        public String collateralKind {get;set;}    // 담보종류
        public String collateralAmount {get;set;}    // 담보금액
        public String collateralPeriod {get;set;}    // 담보제공기간
        public String creditLoanAmount {get;set;}    // 신용여신 금액
        public String deprecAmount {get;set;}    // 약정감가
        public String incentiveAmount {get;set;}    // 장려금
        public String feeAmount {get;set;}    // 판매수수료
        public String donationAmount {get;set;}    // 후원금
        public String otherAmount {get;set;}    // 기타지원
        public String paymentPicklist {get;set;}    // 결제수단
        public String ContractPaymentDate {get;set;}    // 약정결제일
        public String chefSupport {get;set;}    // 쉐프지원

    // ====[신규 개설 예상 손익]=====
        // 매출 합계 라인
        public String beforeTotal {get;set;}    // 지원전월
        public String deprecTotal {get;set;}    // 약점감가
        public String incentiveTotal {get;set;}    // 장려금
        public String feeTotal {get;set;}    // 판매수수료
        public String donationTotal {get;set;}    // 후원금
        public String otherTotal {get;set;}    // 기타지원
        public String afterTotal {get;set;}    // 지원후 월예산 합
        public String yearTotal {get;set;}    // 연간 예상 실적
        // 매출라인 / 농산물
        public String farmBefore {get;set;}    // 농산물 * 지원전월
        public String farmDeprec {get;set;}    // 농산물 * 약정감가
        public String farmIncentive {get;set;}    // 농산물 * 장려금
        public String farmSalesAfter {get;set;}    // 농산물 * 지원 後 월예상
        public String farmSalesYear {get;set;}    // 농산물 * 연간예상실적
        public String detailDeprec {get;set;}    // 약정감가(실제)
        // 매출라인 / 수산물
        public String marinBefore {get;set;}    // 수산물 * 지원전월
        public String marinDeprec {get;set;}    // 수산물 * 약정감가
        public String marinIncentive {get;set;}    // 수산물 * 장려금
        public String marinSalesAfter {get;set;}    // 수산물 * 지원 後 월예상
        public String marinSalesYear {get;set;}    // 수산물 * 연간예상실적
        public String detailIncentive {get;set;}    // 장려금(실제)
        // 매출라인 / 축산물
        public String livestockBefore {get;set;}    // 축산물 * 지원전월
        public String livestockDeprec {get;set;}    // 축산물 * 약정감가
        public String livestockIncentive {get;set;}    // 축산물 * 장려금
        public String livestockSalesAfter {get;set;}    // 축산물 * 지원 後 월예상
        public String livestockSalesYear {get;set;}    // 축산물 * 연간예상실적
        public String detailFee {get;set;}    // 판매수수료(실제)
        // 매출라인 / 가공식품
        public String manufactureBefore {get;set;}    // 가공식품 * 지원전월
        public String manufactureDeprec {get;set;}    // 가공식품 * 약정감가
        public String manufactureIncentive {get;set;}    // 가공식품 * 장려금
        public String manufactureSalesAfter {get;set;}    // 가공식품 * 지원 後 월예상
        public String manufactureSalesYear {get;set;}    // 가공식품 * 연간예상실적
        // 매출라인 / 비식품
        public String nonfoodBefore {get;set;}    // 비식품 * 지원전월
        public String nonfoodDeprec {get;set;}    // 비식품 * 약정감가
        public String nonfoodIncentive {get;set;}    // 비식품 * 장려금
        public String nonfoodSalesAfter {get;set;}    // 비식품 * 지원 後 월예상
        public String nonfoodSalesYear {get;set;}    // 비식품 * 연간예상실적

        // 매출이익 합계라인
        public String salesSupportBefore {get;set;}    // 지원 前月 예상 매출이익
        public String salesSupportDeprec {get;set;}    // 약정감가 매출이익
        public String salesSupportIncentive {get;set;}    // 장려금 매출이익
        public String salesSupportFee {get;set;}    // 판매수수료 매출이익
        public String salesSupportAfter {get;set;}    // 지원 後 월 예상
        public String salesSupportYear {get;set;}    // 연간예상실적
        // 매출이익 / 데이터
        public String salesSupport {get;set;}    // 지원 前月 예상 매출이익 데이터
        public String salesSupportDeprecRate {get;set;}    // 약정감가 매출이익률
        public String salesSupportIncentiveRate {get;set;}    // 장려금 매출이익률
        public String salesSupportFeeRate {get;set;}    // 판매수수료 매출이익률
        public String salesSupportAfterRate {get;set;}    // 지원 後 월 예상
        public String salesSupportYearRate {get;set;}    // 연간예상실적률

        // 판관비 계
        public String sgaTotal {get;set;}    // sga 지원 前月 예상 물류비 + 지원 前月 예상 인건비 + 지원 前月 예상 그룹공통비 + 지원 前月 예상 기타판관비
        public String sgaCostTotal {get;set;}    // 지원 後월 예상
        public String sgaCostYear {get;set;}    // 연간예상실적률
        // 판관비 (%)
        public String sgaBeforeTotal {get;set;}    // 지원 前月 예상
        public String sgaRateAfter {get;set;}    // 지원 後월 예상
        public String sgaRateYear {get;set;}    // 연간예상실적률
        // 판관비 / 물류비
        public String distributeBefore {get;set;}    // 지원 前月 예상
        public String distributeAfter {get;set;}    // 지원 後월 예상
        public String distributeYear {get;set;}    // 연간예상실적률
        public String detailDistributeFee {get;set;}    // 물류비(계획)
        // 판관비 / 인건비
        public String laborBefore {get;set;}    // 지원 前月 예상
        public String laborAfter {get;set;}    // 지원 後월 예상
        public String laborYear {get;set;}    // 연간예상실적률
        public String detailLaborFee {get;set;}    // 인건비(계획)
        // 판관비 / 그룹공통비
        public String groupcostBefore {get;set;}    // 지원 前月 예상
        public String groupcostAfter {get;set;}    // 지원 後월 예상
        public String groupcostYear {get;set;}    // 연간예상실적률
        public String detailGroupcostFee {get;set;}    // 인건비(계획)
        // 판관비 / 기타판관비
        public String otherSgaBefore {get;set;}    // 지원 前月 예상
        public String otherSgaDonationTotal {get;set;}    // 기타판관비 후원금 합
        public String otherSgaTotal {get;set;}    // 기타 지원합
        public String otherSgaAfter {get;set;}    // 지원 後월 예상
        public String otherSgaYear {get;set;}    // 연간예상실적률
        // 판관비 / 카드수수료
        public String cardFeeOtherSga {get;set;}    // 지원 前月 예상
        public String cardFeeOther {get;set;}    // 카드수수료 기타지원
        public String cardFeeAfter {get;set;}    // 지원 後월 예상
        public String cardFeeYear {get;set;}    // 연간예상실적률
        public String detailCardFee {get;set;}    // 카드수수료(실제)
        // 판관비 / 보증보험수수료
        public String suretyOtherSga {get;set;}    // 지원 前月 예상
        public String collateralOther {get;set;}    // 보증보험 기타지원
        public String collateralAfter {get;set;}    // 지원 後월 예상
        public String collateralYear {get;set;}    // 연간예상실적률
        public String detailCollateralFee {get;set;}    // 담보수수료(실제)
        // 판관비 / 판촉비
        public String promotionOtherSga {get;set;}    // 지원 前月 예상
        public String supportOther {get;set;}    // 판촉비 기타지원
        public String supportAfter {get;set;}    // 지원 後월 예상
        public String supportYear {get;set;}    // 연간예상실적률
        public String detailOther {get;set;}    // 판촉비(실제)
        // 판관비 / 기부금(후원)
        public String donationOtherSga {get;set;}    // 지원 前月 예상
        public String donationOther {get;set;}    // 기부금 * 후원금
        public String donationAfter {get;set;}    // 지원 後월 예상
        public String donationYear {get;set;}    // 연간예상실적률
        public String detailDonation {get;set;}    // 기부금(실제)
        // 판관비 / 쉐프지원
        public String chefOtherSga {get;set;}    // 지원 前月 예상
        public String chefOther {get;set;}    // 쉐프 기타지원
        public String chefAfter {get;set;}    // 지원 後월 예상
        public String chefYear {get;set;}    // 연간예상실적률
        public String detailChef {get;set;}    // 회당 20만원 산정
        // 판관비 / 기타    
        public String otherOtherSga {get;set;}    // 지원 前月 예상
        public String otherOtherAfter {get;set;}    // 지원 後월 예상
        public String otherYear {get;set;}    // 연간예상실적률
        public String detailOtherFee {get;set;}    // 기타(계획)

        // 공헌이익 계
        public String contributeBefore {get;set;}    // 지원 前月 예상
        public String contributeAfter {get;set;}    // 지원 後월 예상
        public String contributeYear {get;set;}    // 연간예상실적률
        // 공헌이익 / 데이터
        public String contributeRateBefore {get;set;}    // 지원 前月 예상
        public String contributeRateAfter {get;set;}    // 지원 後월 예상
        public String contributeRateYear {get;set;}    // 연간예상실적률

        // 지원수수료
        public String contributeSupportBefore {get;set;}    // 지원 前月 예상
        public String contributeSupportAfter {get;set;}    // 지원 後월 예상
        public String contributeSupportYear {get;set;}    // 연간예상실적률
        public String detailSupportFee {get;set;}    // 지원수수료(계획)
        
        // 영업이익 계
        public String salesProfitBefore {get;set;}    // 지원 前月 예상
        public String salesProfitAfter {get;set;}    // 지원 後월 예상
        public String salesProfitYear {get;set;}    // 연간예상실적률
        // 영업이익 데이터
        public String salesProfitRateBefore {get;set;}    // 지원 前月 예상
        public String salesProfitRateAfter {get;set;}    // 지원 後월 예상
        public String salesProfitRateYear {get;set;}    // 연간예상실적률

        /* 
        * 생성자 - 데이터 넣기
        */
        public DataWrapper(Map<String, Object> saveResultMap){
        // ====[거래 상세 내용]=====
            this.collateralKind = saveResultMap.get('detail-collateral-kind')!=null ? String.valueOf(saveResultMap.get('detail-collateral-kind')) : '';
            this.collateralAmount = saveResultMap.get('detail-collateral-amount')!=null ? String.valueOf(saveResultMap.get('detail-collateral-amount')) : '';
            this.collateralPeriod = saveResultMap.get('collateral-period')!=null ? String.valueOf(saveResultMap.get('collateral-period')) : '';
            this.creditLoanAmount = saveResultMap.get('detail-creditLoan-amount')!=null ? String.valueOf(saveResultMap.get('detail-creditLoan-amount')) : '';
            this.deprecAmount = saveResultMap.get('detail-deprec-amount')!=null ? String.valueOf(saveResultMap.get('detail-deprec-amount')) : '';
            this.incentiveAmount = saveResultMap.get('detail-incentive-amount')!=null ? String.valueOf(saveResultMap.get('detail-incentive-amount')) : '';
            this.feeAmount = saveResultMap.get('detail-fee-amount')!=null ? String.valueOf(saveResultMap.get('detail-fee-amount')) : '';
            this.donationAmount = saveResultMap.get('detail-donation-amount')!=null ? String.valueOf(saveResultMap.get('detail-donation-amount')) : '';
            this.otherAmount = saveResultMap.get('detail-other-amount')!=null ? String.valueOf(saveResultMap.get('detail-other-amount')) : '';
            this.paymentPicklist = saveResultMap.get('payment-picklist')!=null ? String.valueOf(saveResultMap.get('payment-picklist')) : '';
            this.ContractPaymentDate = saveResultMap.get('contract-payment-period')!=null ? String.valueOf(saveResultMap.get('contract-payment-period')) : '';
            this.chefSupport = saveResultMap.get('chef-support')!=null ? String.valueOf(saveResultMap.get('chef-support')) : '';
            
        // ====[신규 개설 예상 손익]=====
            // 매출 합계 라인
            this.beforeTotal = saveResultMap.get('before-total')!=null ? String.valueOf(saveResultMap.get('before-total')) : '';
            this.deprecTotal = saveResultMap.get('deprec-total')!=null ? String.valueOf(saveResultMap.get('deprec-total')) : '';
            this.incentiveTotal = saveResultMap.get('incentive-total')!=null ? String.valueOf(saveResultMap.get('incentive-total')) : '';
            this.feeTotal = saveResultMap.get('fee-total')!=null ? String.valueOf(saveResultMap.get('fee-total')) : '';
            this.donationTotal = saveResultMap.get('donation-total')!=null ? String.valueOf(saveResultMap.get('donation-total')) : '';
            this.otherTotal = saveResultMap.get('other-total')!=null ? String.valueOf(saveResultMap.get('other-total')) : '';
            this.afterTotal = saveResultMap.get('after-total')!=null ? String.valueOf(saveResultMap.get('after-total')) : '';
            this.yearTotal = saveResultMap.get('year-total')!=null ? String.valueOf(saveResultMap.get('year-total')) : '';
            // 매출라인 / 농산물
            this.farmBefore = saveResultMap.get('farm-before')!=null ? String.valueOf(saveResultMap.get('farm-before')) : '';
            this.farmDeprec = saveResultMap.get('farm-deprec')!=null ? String.valueOf(saveResultMap.get('farm-deprec')) : '';
            this.farmIncentive = saveResultMap.get('farm-incentive')!=null ? String.valueOf(saveResultMap.get('farm-incentive')) : '';
            this.farmSalesAfter = saveResultMap.get('farm-sales-after')!=null ? String.valueOf(saveResultMap.get('farm-sales-after')) : '';
            this.farmSalesYear = saveResultMap.get('farm-sales-year')!=null ? String.valueOf(saveResultMap.get('farm-sales-year')) : '';
            this.detailDeprec = saveResultMap.get('detail-deprec')!=null ? String.valueOf(saveResultMap.get('detail-deprec'))+' %' : '';
            // 매출라인 / 수산물
            this.marinBefore = saveResultMap.get('marin-before')!=null ? String.valueOf(saveResultMap.get('marin-before')) : '';
            this.marinDeprec = saveResultMap.get('marin-deprec')!=null ? String.valueOf(saveResultMap.get('marin-deprec')) : '';
            this.marinIncentive = saveResultMap.get('marin-incentive')!=null ? String.valueOf(saveResultMap.get('marin-incentive')) : '';
            this.marinSalesAfter = saveResultMap.get('marin-sales-after')!=null ? String.valueOf(saveResultMap.get('marin-sales-after')) : '';
            this.marinSalesYear = saveResultMap.get('marin-sales-year')!=null ? String.valueOf(saveResultMap.get('marin-sales-year')) : '';
            this.detailIncentive = saveResultMap.get('detail-incentive')!=null ? String.valueOf(saveResultMap.get('detail-incentive'))+' %' : '';
            // 매출라인 / 축산물
            this.livestockBefore = saveResultMap.get('livestock-before')!=null ? String.valueOf(saveResultMap.get('livestock-before')) : '';
            this.livestockDeprec = saveResultMap.get('livestock-deprec')!=null ? String.valueOf(saveResultMap.get('livestock-deprec')) : '';
            this.livestockIncentive = saveResultMap.get('livestock-incentive')!=null ? String.valueOf(saveResultMap.get('livestock-incentive')) : '';
            this.livestockSalesAfter = saveResultMap.get('livestock-sales-after')!=null ? String.valueOf(saveResultMap.get('livestock-sales-after')) : '';
            this.livestockSalesYear = saveResultMap.get('livestock-sales-year')!=null ? String.valueOf(saveResultMap.get('livestock-sales-year')) : '';
            this.detailFee = saveResultMap.get('detail-fee')!=null ? String.valueOf(saveResultMap.get('detail-fee'))+' %' : '';
            // 매출라인 / 가공식품
            this.manufactureBefore = saveResultMap.get('manufacture-before')!=null ? String.valueOf(saveResultMap.get('manufacture-before')) : '';
            this.manufactureDeprec = saveResultMap.get('manufacture-deprec')!=null ? String.valueOf(saveResultMap.get('manufacture-deprec')) : '';
            this.manufactureIncentive = saveResultMap.get('manufacture-incentive')!=null ? String.valueOf(saveResultMap.get('manufacture-incentive')) : '';
            this.manufactureSalesAfter = saveResultMap.get('manufacture-sales-after')!=null ? String.valueOf(saveResultMap.get('manufacture-sales-after')) : '';
            this.manufactureSalesYear = saveResultMap.get('manufacture-sales-year')!=null ? String.valueOf(saveResultMap.get('manufacture-sales-year')) : '';
            // 매출라인 / 비식품
            this.nonfoodBefore = saveResultMap.get('nonfood-before')!=null ? String.valueOf(saveResultMap.get('nonfood-before')) : '';
            this.nonfoodDeprec = saveResultMap.get('nonfood-deprec')!=null ? String.valueOf(saveResultMap.get('nonfood-deprec')) : '';
            this.nonfoodIncentive = saveResultMap.get('nonfood-incentive')!=null ? String.valueOf(saveResultMap.get('nonfood-incentive')) : '';
            this.nonfoodSalesAfter = saveResultMap.get('nonfood-sales-after')!=null ? String.valueOf(saveResultMap.get('nonfood-sales-after')) : '';
            this.nonfoodSalesYear = saveResultMap.get('nonfood-sales-year')!=null ? String.valueOf(saveResultMap.get('nonfood-sales-year')) : '';
            
            // 매출이익 
            this.salesSupportBefore = saveResultMap.get('sales-support-before')!=null ? String.valueOf(saveResultMap.get('sales-support-before')) : '';
            this.salesSupportDeprec = saveResultMap.get('sales-support-deprec')!=null ? String.valueOf(saveResultMap.get('sales-support-deprec')) : '';
            this.salesSupportIncentive = saveResultMap.get('sales-support-Incentive')!=null ? String.valueOf(saveResultMap.get('sales-support-Incentive')) : '';
            this.salesSupportFee = saveResultMap.get('sales-support-fee')!=null ? String.valueOf(saveResultMap.get('sales-support-fee')) : '';
            this.salesSupportAfter = saveResultMap.get('sales-support-after')!=null ? String.valueOf(saveResultMap.get('sales-support-after')) : '';
            this.salesSupportYear = saveResultMap.get('sales-support-year')!=null ? String.valueOf(saveResultMap.get('sales-support-year')) : '';
            // 매출이익 / 데이터
            this.salesSupport = saveResultMap.get('sales-support')!=null ? String.valueOf(saveResultMap.get('sales-support')) : '';
            this.salesSupportDeprecRate = saveResultMap.get('sales-support-deprec-rate')!=null ? String.valueOf(saveResultMap.get('sales-support-deprec-rate'))+' %' : '';
            this.salesSupportIncentiveRate = saveResultMap.get('sales-support-Incentive-rate')!=null ? String.valueOf(saveResultMap.get('sales-support-Incentive-rate'))+' %' : '';
            this.salesSupportFeeRate = saveResultMap.get('sales-support-fee-rate')!=null ? String.valueOf(saveResultMap.get('sales-support-fee-rate'))+' %' : '';
            this.salesSupportAfterRate = saveResultMap.get('sales-support-after-rate')!=null ? String.valueOf(saveResultMap.get('sales-support-after-rate'))+' %' : '';
            this.salesSupportYearRate = saveResultMap.get('sales-support-year-rate')!=null ? String.valueOf(saveResultMap.get('sales-support-year-rate'))+' %' : '';
            
            // 판관비 계
            this.sgaTotal = saveResultMap.get('sga-total')!=null ? String.valueOf(saveResultMap.get('sga-total')) : '';
            this.sgaCostTotal = saveResultMap.get('sga-cost-total')!=null ? String.valueOf(saveResultMap.get('sga-cost-total')) : '';
            this.sgaCostYear = saveResultMap.get('sga-cost-year')!=null ? String.valueOf(saveResultMap.get('sga-cost-year')) : '';
            // 판관비 (%) 
            this.sgaBeforeTotal = saveResultMap.get('sga-before-total')!=null ? String.valueOf(saveResultMap.get('sga-before-total'))+' %' : '';
            this.sgaRateAfter = saveResultMap.get('sga-rate-after')!=null ? String.valueOf(saveResultMap.get('sga-rate-after'))+' %' : '';
            this.sgaRateYear = saveResultMap.get('sga-rate-year')!=null ? String.valueOf(saveResultMap.get('sga-rate-year'))+' %' : '';
            // 판관비 / 물류비
            this.distributeBefore = saveResultMap.get('distribute-before')!=null ? String.valueOf(saveResultMap.get('distribute-before')) : '';
            this.distributeAfter = saveResultMap.get('distribute-after')!=null ? String.valueOf(saveResultMap.get('distribute-after')) : '';
            this.distributeYear = saveResultMap.get('distribute-year')!=null ? String.valueOf(saveResultMap.get('distribute-year')) : '';
            this.detailDistributeFee = saveResultMap.get('detail-distribute-fee')!=null ? String.valueOf(saveResultMap.get('detail-distribute-fee'))+' %' : '';
            // 판관비 / 인건비
            this.laborBefore = saveResultMap.get('labor-before')!=null ? String.valueOf(saveResultMap.get('labor-before')) : '';
            this.laborAfter = saveResultMap.get('labor-after')!=null ? String.valueOf(saveResultMap.get('labor-after')) : '';
            this.laborYear = saveResultMap.get('labor-year')!=null ? String.valueOf(saveResultMap.get('labor-year')) : '';
            this.detailLaborFee = saveResultMap.get('detail-labor-fee')!=null ? String.valueOf(saveResultMap.get('detail-labor-fee'))+' %' : '';
            // 판관비 / 그룹공통비
            this.groupcostBefore = saveResultMap.get('groupcost-before')!=null ? String.valueOf(saveResultMap.get('groupcost-before')) : '';
            this.groupcostAfter = saveResultMap.get('groupcost-after')!=null ? String.valueOf(saveResultMap.get('groupcost-after')) : '';
            this.groupcostYear = saveResultMap.get('groupcost-year')!=null ? String.valueOf(saveResultMap.get('groupcost-year')) : '';
            this.detailGroupcostFee = saveResultMap.get('detail-groupcost-fee')!=null ? String.valueOf(saveResultMap.get('detail-groupcost-fee'))+' %' : '';
            // 판관비 / 기타판관비
            this.otherSgaBefore = saveResultMap.get('other-sga-before')!=null ? String.valueOf(saveResultMap.get('other-sga-before')) : '';
            this.otherSgaDonationTotal = saveResultMap.get('other-sga-donation-total')!=null ? String.valueOf(saveResultMap.get('other-sga-donation-total')) : '';
            this.otherSgaTotal = saveResultMap.get('other-sga-total')!=null ? String.valueOf(saveResultMap.get('other-sga-total')) : '';
            this.otherSgaAfter = saveResultMap.get('other-sga-after')!=null ? String.valueOf(saveResultMap.get('other-sga-after')) : '';
            this.otherSgaYear = saveResultMap.get('other-sga-year')!=null ? String.valueOf(saveResultMap.get('other-sga-year')) : '';
            // 판관비 / 카드수수료
            this.cardFeeOtherSga = saveResultMap.get('cardFee-other-sga')!=null ? String.valueOf(saveResultMap.get('cardFee-other-sga')) : '';
            this.cardFeeOther = saveResultMap.get('cardFee-other')!=null ? String.valueOf(saveResultMap.get('cardFee-other')) : '';
            this.cardFeeAfter = saveResultMap.get('cardFee-after')!=null ? String.valueOf(saveResultMap.get('cardFee-after')) : '';
            this.cardFeeYear = saveResultMap.get('cardFee-year')!=null ? String.valueOf(saveResultMap.get('cardFee-year')) : '';
            this.detailCardFee = saveResultMap.get('detail-card-fee')!=null ? String.valueOf(saveResultMap.get('detail-card-fee'))+' %' : '';
            // 판관비 / 보증보험수수료
            this.suretyOtherSga = saveResultMap.get('surety-other-sga')!=null ? String.valueOf(saveResultMap.get('surety-other-sga')) : '';
            this.collateralOther = saveResultMap.get('collateral-other')!=null ? String.valueOf(saveResultMap.get('collateral-other')) : '';
            this.collateralAfter = saveResultMap.get('collateral-after')!=null ? String.valueOf(saveResultMap.get('collateral-after')) : '';
            this.collateralYear = saveResultMap.get('collateral-year')!=null ? String.valueOf(saveResultMap.get('collateral-year')) : '';
            this.detailCollateralFee = saveResultMap.get('detail-collateral-fee')!=null ? String.valueOf(saveResultMap.get('detail-collateral-fee'))+' %' : '';
            // 판관비 / 판촉비
            this.promotionOtherSga = saveResultMap.get('promotion-other-sga')!=null ? String.valueOf(saveResultMap.get('promotion-other-sga')) : '';
            this.supportOther = saveResultMap.get('support-other')!=null ? String.valueOf(saveResultMap.get('support-other')) : '';
            this.supportAfter = saveResultMap.get('support-after')!=null ? String.valueOf(saveResultMap.get('support-after')) : '';
            this.supportYear = saveResultMap.get('support-year')!=null ? String.valueOf(saveResultMap.get('support-year')) : '';
            this.detailOther = saveResultMap.get('detail-other')!=null ? String.valueOf(saveResultMap.get('detail-other'))+' %' : '';
            // 판관비 / 기부금(후원)
            this.donationOtherSga = saveResultMap.get('donation-other-sga')!=null ? String.valueOf(saveResultMap.get('donation-other-sga')) : '';
            this.donationOther = saveResultMap.get('donation-other')!=null ? String.valueOf(saveResultMap.get('donation-other')) : '';
            this.donationAfter = saveResultMap.get('donation-after')!=null ? String.valueOf(saveResultMap.get('donation-after')) : '';
            this.donationYear = saveResultMap.get('donation-year')!=null ? String.valueOf(saveResultMap.get('donation-year')) : '';
            this.detailDonation = saveResultMap.get('detail-donation')!=null ? String.valueOf(saveResultMap.get('detail-donation'))+' %' : '';
            // 판관비 / 쉐프지원
            this.chefOtherSga = saveResultMap.get('chef-other-sga')!=null ? String.valueOf(saveResultMap.get('chef-other-sga')) : '';
            this.chefOther = saveResultMap.get('chef-other')!=null ? String.valueOf(saveResultMap.get('chef-other')) : '';
            this.chefAfter = saveResultMap.get('chef-after')!=null ? String.valueOf(saveResultMap.get('chef-after')) : '';
            this.chefYear = saveResultMap.get('chef-year')!=null ? String.valueOf(saveResultMap.get('chef-year')) : '';
            this.detailChef = saveResultMap.get('detail-chef')!=null ? String.valueOf(saveResultMap.get('detail-chef')) : '';
            // 판관비 / 기타
            this.otherOtherSga = saveResultMap.get('other-other-sga')!=null ? String.valueOf(saveResultMap.get('other-other-sga')) : '';
            this.otherOtherAfter = saveResultMap.get('other-other-after')!=null ? String.valueOf(saveResultMap.get('other-other-after')) : '';
            this.otherYear = saveResultMap.get('other-year')!=null ? String.valueOf(saveResultMap.get('other-year')) : '';
            this.detailOtherFee = saveResultMap.get('detail-other-fee')!=null ? String.valueOf(saveResultMap.get('detail-other-fee'))+' %' : '';
        
            // 공헌이익 계
            this.contributeBefore = saveResultMap.get('contribute-after')!=null ? String.valueOf(saveResultMap.get('contribute-after')) : '';
            this.contributeAfter = saveResultMap.get('contribute-after')!=null ? String.valueOf(saveResultMap.get('contribute-after')) : '';
            this.contributeYear = saveResultMap.get('contribute-year')!=null ? String.valueOf(saveResultMap.get('contribute-year')) : '';
            // 공헌이익 / 데이터
            this.contributeRateBefore = saveResultMap.get('contribute-rate-before')!=null ? String.valueOf(saveResultMap.get('contribute-rate-before'))+' %' : '';
            this.contributeRateAfter = saveResultMap.get('contribute-rate-after')!=null ? String.valueOf(saveResultMap.get('contribute-rate-after'))+' %' : '';
            this.contributeRateYear = saveResultMap.get('contribute-rate-year')!=null ? String.valueOf(saveResultMap.get('contribute-rate-year'))+' %' : '';
            
            // 지원수수료
            this.contributeSupportBefore = saveResultMap.get('contribute-support-before')!=null ? String.valueOf(saveResultMap.get('contribute-support-before')) : '';
            this.contributeSupportAfter = saveResultMap.get('contribute-support-after')!=null ? String.valueOf(saveResultMap.get('contribute-support-after')) : '';
            this.contributeSupportYear = saveResultMap.get('contribute-support-year')!=null ? String.valueOf(saveResultMap.get('contribute-support-year')) : '';
            this.detailSupportFee = saveResultMap.get('detail-support-fee')!=null ? String.valueOf(saveResultMap.get('detail-support-fee'))+' %' : '';
            
            // 영업이익 계
            this.salesProfitBefore = saveResultMap.get('sales-profit-before')!=null ? String.valueOf(saveResultMap.get('sales-profit-before')) : '';
            this.salesProfitAfter = saveResultMap.get('sales-profit-after')!=null ? String.valueOf(saveResultMap.get('sales-profit-after')) : '';
            this.salesProfitYear = saveResultMap.get('sales-profit-year')!=null ? String.valueOf(saveResultMap.get('sales-profit-year')) : '';
            // 영업이익 데이터
            this.salesProfitRateBefore = saveResultMap.get('sales-profit-rate-before')!=null ? String.valueOf(saveResultMap.get('sales-profit-rate-before'))+' %' : '';
            this.salesProfitRateAfter = saveResultMap.get('sales-profit-rate-after')!=null ? String.valueOf(saveResultMap.get('sales-profit-rate-after'))+' %' : '';
            this.salesProfitRateYear = saveResultMap.get('sales-profit-rate-year')!=null ? String.valueOf(saveResultMap.get('sales-profit-rate-year'))+' %' : '';
        }
    }

}