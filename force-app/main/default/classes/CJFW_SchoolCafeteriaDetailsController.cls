/**
* 두탑 BID 학교별 급식 정보
*
*@author 진현욱
*@since 2023-11-09  최초 작성
*/
public with sharing class CJFW_SchoolCafeteriaDetailsController {
    
    @AuraEnabled
    public static Map<String,Object> getRegionalShoolInfo(Map<String,Object> params) {
        try {
            Map<String,Object> result = new Map<String,Object>();
            String citiyCountry = (String) params.get('citiyCountry');        // 시/도
            String districtCounty;                                            // 동/군/구
            String schoolName;                                                // 학교명

            if(params.get('districtCounty') != null) districtCounty = (String) params.get('districtCounty');
            if(params.get('schoolName') != null) schoolName = (String) params.get('schoolName');
            
            IFN_EIF1004_DT001_MD001.Output              outputObj   = new IFN_EIF1004_DT001_MD001.Output();
            IFN_EIF1004_DT001_MD001                     ifCon       = new IFN_EIF1004_DT001_MD001();
            IFN_EIF1004_DT001_MD001.MD001RequstWrapper  reqmap      = new IFN_EIF1004_DT001_MD001.MD001RequstWrapper();

            reqmap.Address1     = citiyCountry;     // 시/도 정보
            reqmap.Address2     = districtCounty;   // 동/군/구 정보
            reqmap.Keyword      =  schoolName;      // 학교명
            outputObj = ifCon.callout(reqmap);

            // I/F 성공시
            if('0'.equals(outputObj.meta[0].result_code)) {
                List<schoolInfo> schoolInfoList = new List<schoolInfo>();

                for(IFN_EIF1004_DT001_MD001.item ifShoolInfo : outputObj.item) {
                    schoolInfo schoolInfo = new schoolInfo();
                    schoolInfo.schoolName      = ifShoolInfo.SchoolTitle;
                    schoolInfo.neisCodeStd     = ifShoolInfo.NeisCodeStd; 
                    schoolInfo.districtCounty  = ifShoolInfo.Address2; 
                    schoolInfo.tel             = ifShoolInfo.tel; 
                    schoolInfo.fax             = ifShoolInfo.fax; 
                    schoolInfo.countRoom       = ifShoolInfo.CountRoom; 
                    schoolInfo.countStudent    = ifShoolInfo.CountStudent; 
                    schoolInfo.countTeacher    = ifShoolInfo.CountTeacher; 
                    schoolInfoList.add(schoolInfo);
                }

                result.put('schoolInfoList', schoolInfoList);
            }

            return result;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }


    public class schoolInfo {
        @AuraEnabled public String schoolName;          // 학교명
        @AuraEnabled public String neisCodeStd;         // 학교코드
        @AuraEnabled public String citiyCountry;        // 시/도
        @AuraEnabled public String districtCounty;      // 동/군/구 코드값
        @AuraEnabled public String districtCountyLabel; // 동/군/구
        @AuraEnabled public String tel;                 // 행정실전화
        @AuraEnabled public String fax;                 // fax
        @AuraEnabled public String countRoom;           // 학급수
        @AuraEnabled public String countStudent;        // 학생수
        @AuraEnabled public String countTeacher;        // 교직원수
    }
}