/**
 * @description       : 하위 품의서에 노출시킬 데이터 가져오는 용도의 Controller
 * 
    (외식)_수주심의양식(신규) page : CJFW_OrderConsiderNewForm

 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
public with sharing class OrderConsiderFormController {
    public static String SaveDataList;

    public String opportunityId { get; set; }
    public String incomeExpensesId { get; set;} // 신규개설품의 id
    public Decimal versionCheck { get; set; }
    public Boolean reportCheck { get; set; }
    public String showtable { get; set; }

    /* 가져온 데이터 담는 object */
    public Opportunity opptyInfo {get;set;}
    public Account accountInfo {get;set;}
    public CJFW_ExpectedIncomeExpenses__c IncomeExpensesInfo {get;set;}

    public OrderConsiderFormController(){
        this.opportunityId = '0060w00000D9x0BAAR'; //임의로 설정 
        this.incomeExpensesId = 'a1l0w000001N1yUAAS'; //신규개설품의 Id (임의로 설정)

        getAccountInfo();    // 고객사 정보 가져오기
        getIncomeExpenses(); // 신규개설품의 obj 값 가져오기
    }

    /* 
    Oppty 에 있는 Account 값을 가져오는 메소드
    */
    public void getAccountInfo() {


        
        // 기회 레코드에서 계정 ID 가져오기
        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1].AccountId;
        
        if (accountId != null) {
            // 계정 정보를 쿼리
            accountInfo = [SELECT 
                                Id,
                                Name,
                                RepresentativeName__c,
                                BusinessPath__c,
                                SalesMonthly__c, // 포뮬라
                                OurSales__c,
                                Address__c,
                                Phone ,
                                PV_EXISTSUP__c 
                            FROM Account 
                            WHERE Id = :accountId 
                        ];
    
            String[] defaultValSet = new String[] {
                'RepresentativeName__c',
                'BusinessPath__c',
                'Address__c',
                'PV_EXISTSUP__c'
            };
    
            for (String defaultSet : defaultValSet) {
                Object fieldValue = accountInfo.get(defaultSet);
                // 필드 값이 null이면 기본값을 공백
                if (fieldValue == null)  fieldValue = ''; 
                accountInfo.put(defaultSet, fieldValue);
            }
    
            System.debug('# 잘 가져왔니 ?->' + accountInfo );
        } else {
            System.debug('# 계정 ID를 찾을 수 없습니다.');
        }
    }

    /* 
    예산손익(CJFW_ExpectedIncomeExpenses__c) 에서 값 가져오기
    VF Page 초기호출시  
    */
    public void getIncomeExpenses() {
        System.debug('# ReportFormController # getIncomeExpenses');
        try {
            String query = 'SELECT Id, ' +
            'Version__c, ' +                        
            'IsReportCheck__c, ' +                        
            'KeyMan__c, ' +                         //키맨    
            'Sales__c, ' +                          //매출
            'ExclusiveSaveSkuSales__c, ' +           //전용저장 sku매출
            'DropSize__c, ' +                        //회당 Drop Size
            'AverageSales__c, ' +                    //점당 평균매출
            'DeliveryNumber__c, ' +                  //배송 횟수
            'ContributionMargin__c, ' +              //공헌이익%
            'KgExclusiveProduct__c, ' +              //전용상품
            'KgGeneralProduct__c, ' +                //일반상품
            'KgTotalAmount__c ' +                   //계
            'FROM CJFW_ExpectedIncomeExpenses__c';

            if (incomeExpensesId != null) {
                query += ' WHERE id = :incomeExpensesId ';
            }else if (opportunityId != null) {
                query += ' WHERE Opportunity__c = :opportunityId ';
            }

            if(showtable =='true'){
                query += ' ORDER BY IsReportCheck__c DESC LIMIT 1';
            }else{
                query += ' ORDER BY Version__c DESC LIMIT 1';
            }


            System.debug('# query ->' + query );
            List<CJFW_ExpectedIncomeExpenses__c> incomeExpensesList = Database.query(query);

            if (!incomeExpensesList.isEmpty()) {    //값이 있을때 
                IncomeExpensesInfo = incomeExpensesList[0];
                versionCheck = ( incomeExpensesList[0].Version__c ) + 1 ;
                reportCheck = ( incomeExpensesList[0].IsReportCheck__c );
            } else {    //값이 없을때 
                versionCheck = 1;
                IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c();
            }

        }catch (QueryException e) {
            IncomeExpensesInfo = new CJFW_ExpectedIncomeExpenses__c(); // 빈 레코드로 초기화
            System.debug('message => ' + e.getMessage());
            System.debug('trace => ' + e.getStackTraceString());
        }

        System.debug('IncomeExpensesInfo 결과 = '+ IncomeExpensesInfo);
        
        /* number 타입 갑이 없을 경우 0.00으로 초기값 세팅 */
        String[] defaultValSet = new String[] {
            'Sales__c',                          //매출
            'ExclusiveSaveSkuSales__c',          //전용저장 sku매출
            'DropSize__c',                       //회당 Drop Size
            'AverageSales__c',                   //점당 평균매출
            'DeliveryNumber__c',                 //배송 횟수
            'ContributionMargin__c',             //공헌이익%
            'KgExclusiveProduct__c',             //전용상품
            'KgGeneralProduct__c',               //일반상품
            'KgTotalAmount__c'                   //계
        };

        for (String defaultSet : defaultValSet) {
            Object fieldValue = IncomeExpensesInfo.get(defaultSet);

            if (fieldValue == null) fieldValue = 0.00; 
            IncomeExpensesInfo.put(defaultSet, fieldValue);
        }
    }




    /* 
    CJFW_OrderConsiderNewForm (VF Page) 에서 입력받은 값 update   
    */
    @RemoteAction
    public static String saveIncomeExpenses(String DataList, String opportunityId, Decimal versionCheck, String incomeExpensesId) {
        try {
            System.debug('DataList ' + DataList);
            System.debug('opportunityId ' + opportunityId);
            System.debug('versionCheck ' + versionCheck);
            System.debug('incomeExpensesId ' + incomeExpensesId);
            
            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(DataList);
            System.debug('넘어온 데이터! ' + dataMap);
            
            CJFW_ExpectedIncomeExpenses__c expectIncome;

            if (incomeExpensesId != null && incomeExpensesId != '') {
                System.debug('update ★-> ' + incomeExpensesId);
                expectIncome = [SELECT Id FROM CJFW_ExpectedIncomeExpenses__c WHERE Id = :incomeExpensesId];
            } else { // insert 
                System.debug('insert ★-> ');
                expectIncome = new CJFW_ExpectedIncomeExpenses__c();
                expectIncome.Version__c = versionCheck; // 필수값
                expectIncome.Opportunity__c = opportunityId; //필수값
                if(versionCheck == 1) expectIncome.IsReportCheck__c = true; // 초기 insert 시에 품의지정 default 세팅
            }

            expectIncome.saveResult__c = DataList;

            /* ===== 4. 수주가이드 충족 여부 ===== */     
            if (dataMap.containsKey('sales')) { // 매출
                expectIncome.Sales__c = convertToDecimal(dataMap.get('sales'));
            }
            if (dataMap.containsKey('exclusiveSaveSkuSales')) { //전용 저장 SKU 매출
                expectIncome.ExclusiveSaveSkuSales__c = convertToDecimal(dataMap.get('exclusiveSaveSkuSales'));
            }
            if (dataMap.containsKey('dropSize')) { // 회당 Drop Size
                expectIncome.DropSize__c = convertToDecimal(dataMap.get('dropSize'));
            }
            if (dataMap.containsKey('averageSales')) { // 점당 평균매출매출
                expectIncome.AverageSales__c = convertToDecimal(dataMap.get('averageSales'));
            }
            if (dataMap.containsKey('deliveryNumber')) { // 배송 횟수
                expectIncome.DeliveryNumber__c = convertToDecimal(dataMap.get('deliveryNumber'));
            }
            if (dataMap.containsKey('contributionMargin')) { // 공헌이익%
                expectIncome.ContributionMargin__c = convertToDecimal(dataMap.get('contributionMargin'));
            }
            if (dataMap.containsKey('kgExclusiveProduct')) { // 전용상품
                expectIncome.KgExclusiveProduct__c = convertToDecimal(dataMap.get('kgExclusiveProduct'));
            }
            if (dataMap.containsKey('kgGeneralProduct')) { // 일반상품
                expectIncome.KgGeneralProduct__c = convertToDecimal(dataMap.get('kgGeneralProduct'));
            }
            if (dataMap.containsKey('kgTotalAmount')) { // 계
                expectIncome.KgTotalAmount__c = convertToDecimal(dataMap.get('kgTotalAmount'));
            }
            upsert expectIncome;
            return 'success';
        } catch (Exception e) {
            String errorMessage = e.getMessage(); 
            String errorStackTrace = e.getStackTraceString(); 
            System.debug('에러 메시지: ' + errorMessage);
            System.debug('에러 라인: ' + errorStackTrace);

            return 'error';
        }
    }
    /* 
    Decimal 값으로 변환하기위해 사용되는 메소드
    */
    public static Decimal convertToDecimal(Object objValue) {  
        Decimal decimalValue = 0.0; // 기본값 설정
    
        if (objValue != null || objValue != '') {
            if (objValue instanceof Decimal) {
                decimalValue = (Decimal)objValue;
            } else if (objValue instanceof String) {
                // 문자열로 된 값을 Decimal로 변환
                decimalValue = Decimal.valueOf((String)objValue);
            }
        }
    
        return decimalValue;
    }
}