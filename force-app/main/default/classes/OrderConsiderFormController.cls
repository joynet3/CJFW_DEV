/**
 * @description       : 하위 품의서에 노출시킬 데이터 가져오는 용도의 Controller
 * 
    (외식)_수주심의양식(신규) page : CJFW_OrderConsiderNewForm

 * @author            : seol.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 10-16-2023
 * @last modified by  : seol.kim@dkbmc.com
**/
public with sharing class OrderConsiderFormController {
    public Account accountInfo {get;set;}

    public String AccountId { get; set; }
    public String opportunityId { get; set; }

    public OrderConsiderFormController(){
        getAccountInfo();
    }

    /* 
    Oppty 에 있는 Account 값을 가져오는 메소드
    */
    public void getAccountInfo() {

        
        AccountId = '0010w000017AdRyAAK';
        opportunityId = '0060w00000D8uikAAB'; // opportunityId 값을 변경

        System.debug('# getAccountInfo oppty id ->' + opportunityId );
        System.debug('# getAccountInfo AccountId id ->' + AccountId );
        
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
}