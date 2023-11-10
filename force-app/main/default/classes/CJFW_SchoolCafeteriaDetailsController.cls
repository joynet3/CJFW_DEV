/**
* 두탑 BID 학교별 급식 정보
*
*@author 진현욱
*@since 2023-11-09  최초 작성
*/
public with sharing class CJFW_SchoolCafeteriaDetailsController {
    
    @AuraEnabled
    public static Map<String,Object> getInitOptionList() {
        try {
            Map<String,Object> result = new Map<String,Object>();
            
            List<SelectOption> citiyCountryOptionList = new List<SelectOption>{
                new SelectOption('지역선택', ''),
                new SelectOption('강원도'         ,'강원'),
                new SelectOption('경기도'         ,'경기'),
                new SelectOption('경상남도'       ,'경남'),
                new SelectOption('경상북도'       ,'경북'),
                new SelectOption('광주광역시'     ,'광주'),
                new SelectOption('대구광역시'     ,'대구'),
                new SelectOption('대전광역시'     ,'대전'),
                new SelectOption('부산광역시'     ,'부산'),
                new SelectOption('서울특별시'     ,'서울'),
                new SelectOption('세종특별자치시' ,'세종'),
                new SelectOption('인천광역시'     ,'인천'),
                new SelectOption('전라남도'       ,'전남'),
                new SelectOption('전라북도'       ,'전북'),
                new SelectOption('제주특별자치도' ,'제주'),
                new SelectOption('충청남도'       ,'충남'),
                new SelectOption('충청북도'       ,'충북'),
                new SelectOption('울산광역시'     ,'울산')            
            };
            result.put('citiyCountryOptionList', citiyCountryOptionList);
           

            return result;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

    @AuraEnabled
    public static Map<String,Object> getDistrictCountryOptionList(String dependencyValue) {
        try {
            Map<String,Object> result = new Map<String,Object>();
            List<SelectOption> districtCountyOptionList = new List<SelectOption>{
                new SelectOption('전지역','none','')
                ,new SelectOption('전지역','none','강원')
                ,new SelectOption('강릉시','강릉시','강원')
                ,new SelectOption('고성군','고성군','강원')
                ,new SelectOption('동해시','동해시','강원')
                ,new SelectOption('삼척시','삼척시','강원')
                ,new SelectOption('속초시','속초시','강원')
                ,new SelectOption('양구군','양구군','강원')
                ,new SelectOption('양양군','양양군','강원')
                ,new SelectOption('영월군','영월군','강원')
                ,new SelectOption('원주시','원주시','강원')
                ,new SelectOption('인제군','인제군','강원')
                ,new SelectOption('정선군','정선군','강원')
                ,new SelectOption('철원군','철원군','강원')
                ,new SelectOption('춘천시','춘천시','강원')
                ,new SelectOption('태백시','태백시','강원')
                ,new SelectOption('평창군','평창군','강원')
                ,new SelectOption('홍천군','홍천군','강원')
                ,new SelectOption('화천군','화천군','강원')
                ,new SelectOption('횡성군','횡성군','강원')
                ,new SelectOption('전지역','none','경기')
                ,new SelectOption('가평군','가평군','경기')
                ,new SelectOption('고양시','고양시','경기')
                ,new SelectOption('과천시','과천시','경기')
                ,new SelectOption('광명시','광명시','경기')
                ,new SelectOption('광주시','광주시','경기')
                ,new SelectOption('구리시','구리시','경기')
                ,new SelectOption('군포시','군포시','경기')
                ,new SelectOption('김포시','김포시','경기')
                ,new SelectOption('남양주시','남양주시','경기')
                ,new SelectOption('동두천시','동두천시','경기')
                ,new SelectOption('부천시','부천시','경기')
                ,new SelectOption('성남시','성남시','경기')
                ,new SelectOption('수원시','수원시','경기')
                ,new SelectOption('시흥시','시흥시','경기')
                ,new SelectOption('안산시','안산시','경기')
                ,new SelectOption('안성시','안성시','경기')
                ,new SelectOption('안양시','안양시','경기')
                ,new SelectOption('양주시','양주시','경기')
                ,new SelectOption('양평군','양평군','경기')
                ,new SelectOption('여주시','여주시','경기')
                ,new SelectOption('연천군','연천군','경기')
                ,new SelectOption('오산시','오산시','경기')
                ,new SelectOption('용인시','용인시','경기')
                ,new SelectOption('의왕시','의왕시','경기')
                ,new SelectOption('의정부시','의정부시','경기')
                ,new SelectOption('이천시','이천시','경기')
                ,new SelectOption('파주시','파주시','경기')
                ,new SelectOption('평택시','평택시','경기')
                ,new SelectOption('포천시','포천시','경기')
                ,new SelectOption('하남시','하남시','경기')
                ,new SelectOption('화성시','화성시','경기')
                ,new SelectOption('전지역','none','경남')
                ,new SelectOption('거제시','거제시','경남')
                ,new SelectOption('거창군','거창군','경남')
                ,new SelectOption('고성군','고성군','경남')
                ,new SelectOption('김해시','김해시','경남')
                ,new SelectOption('남해군','남해군','경남')
                ,new SelectOption('밀양시','밀양시','경남')
                ,new SelectOption('사천시','사천시','경남')
                ,new SelectOption('산청군','산청군','경남')
                ,new SelectOption('양산시','양산시','경남')
                ,new SelectOption('의령군','의령군','경남')
                ,new SelectOption('진주시','진주시','경남')
                ,new SelectOption('창녕군','창녕군','경남')
                ,new SelectOption('창원시','창원시','경남')
                ,new SelectOption('통영시','통영시','경남')
                ,new SelectOption('하동군','하동군','경남')
                ,new SelectOption('함안군','함안군','경남')
                ,new SelectOption('함양군','함양군','경남')
                ,new SelectOption('합천군','합천군','경남')
                ,new SelectOption('전지역','none','경북')
                ,new SelectOption('경산시','경산시','경북')
                ,new SelectOption('경주시','경주시','경북')
                ,new SelectOption('고령군','고령군','경북')
                ,new SelectOption('구미시','구미시','경북')
                ,new SelectOption('김천시','김천시','경북')
                ,new SelectOption('문경시','문경시','경북')
                ,new SelectOption('봉화군','봉화군','경북')
                ,new SelectOption('상주시','상주시','경북')
                ,new SelectOption('성주군','성주군','경북')
                ,new SelectOption('안동시','안동시','경북')
                ,new SelectOption('영덕군','영덕군','경북')
                ,new SelectOption('영양군','영양군','경북')
                ,new SelectOption('영주시','영주시','경북')
                ,new SelectOption('영천시','영천시','경북')
                ,new SelectOption('예천군','예천군','경북')
                ,new SelectOption('울릉군','울릉군','경북')
                ,new SelectOption('울진군','울진군','경북')
                ,new SelectOption('의성군','의성군','경북')
                ,new SelectOption('청도군','청도군','경북')
                ,new SelectOption('청송군','청송군','경북')
                ,new SelectOption('칠곡군','칠곡군','경북')
                ,new SelectOption('포항시','포항시','경북')
                ,new SelectOption('전지역','none','광주')
                ,new SelectOption('광산구','광산구','광주')
                ,new SelectOption('남구','남구','광주')
                ,new SelectOption('동구','동구','광주')
                ,new SelectOption('북구','북구','광주')
                ,new SelectOption('서구','서구','광주')
                ,new SelectOption('전지역','none','대구')
                ,new SelectOption('군위군','군위군','대구')
                ,new SelectOption('남구','남구','대구')
                ,new SelectOption('달서구','달서구','대구')
                ,new SelectOption('달성군','달성군','대구')
                ,new SelectOption('동구','동구','대구')
                ,new SelectOption('북구','북구','대구')
                ,new SelectOption('서구','서구','대구')
                ,new SelectOption('수성구','수성구','대구')
                ,new SelectOption('중구','중구','대구')
                ,new SelectOption('전지역','none','대전')
                ,new SelectOption('대덕구','대덕구','대전')
                ,new SelectOption('동구','동구','대전')
                ,new SelectOption('서구','서구','대전')
                ,new SelectOption('유성구','유성구','대전')
                ,new SelectOption('중구','중구','대전')
                ,new SelectOption('전지역','none','부산')
                ,new SelectOption('강서구','강서구','부산')
                ,new SelectOption('금정구','금정구','부산')
                ,new SelectOption('기장군','기장군','부산')
                ,new SelectOption('남구','남구','부산')
                ,new SelectOption('동구','동구','부산')
                ,new SelectOption('동래구','동래구','부산')
                ,new SelectOption('부산진구','부산진구','부산')
                ,new SelectOption('북구','북구','부산')
                ,new SelectOption('사상구','사상구','부산')
                ,new SelectOption('사하구','사하구','부산')
                ,new SelectOption('서구','서구','부산')
                ,new SelectOption('수영구','수영구','부산')
                ,new SelectOption('연제구','연제구','부산')
                ,new SelectOption('영도구','영도구','부산')
                ,new SelectOption('중구','중구','부산')
                ,new SelectOption('해운대구','해운대구','부산')
                ,new SelectOption('전지역','none','서울')
                ,new SelectOption('강남구','강남구','서울')
                ,new SelectOption('강동구','강동구','서울')
                ,new SelectOption('강북구','강북구','서울')
                ,new SelectOption('강서구','강서구','서울')
                ,new SelectOption('관악구','관악구','서울')
                ,new SelectOption('광진구','광진구','서울')
                ,new SelectOption('구로구','구로구','서울')
                ,new SelectOption('금천구','금천구','서울')
                ,new SelectOption('노원구','노원구','서울')
                ,new SelectOption('도봉구','도봉구','서울')
                ,new SelectOption('동대문구','동대문구','서울')
                ,new SelectOption('동작구','동작구','서울')
                ,new SelectOption('마포구','마포구','서울')
                ,new SelectOption('서대문구','서대문구','서울')
                ,new SelectOption('서초구','서초구','서울')
                ,new SelectOption('성동구','성동구','서울')
                ,new SelectOption('성북구','성북구','서울')
                ,new SelectOption('송파구','송파구','서울')
                ,new SelectOption('양천구','양천구','서울')
                ,new SelectOption('영등포구','영등포구','서울')
                ,new SelectOption('용산구','용산구','서울')
                ,new SelectOption('은평구','은평구','서울')
                ,new SelectOption('종로구','종로구','서울')
                ,new SelectOption('중구','중구','서울')
                ,new SelectOption('중랑구','중랑구','서울')
                ,new SelectOption('세종','','세종')
                ,new SelectOption('세종시','세종시','세종')
                ,new SelectOption('울산','','울산')
                ,new SelectOption('남구','남구','울산')
                ,new SelectOption('동구','동구','울산')
                ,new SelectOption('북구','북구','울산')
                ,new SelectOption('울주군','울주군','울산')
                ,new SelectOption('중구','중구','울산')
                ,new SelectOption('인천','','인천')
                ,new SelectOption('강화군','강화군','인천')
                ,new SelectOption('계양구','계양구','인천')
                ,new SelectOption('미추홀구','미추홀구','인천')
                ,new SelectOption('남동구','남동구','인천')
                ,new SelectOption('동구','동구','인천')
                ,new SelectOption('부평구','부평구','인천')
                ,new SelectOption('서구','서구','인천')
                ,new SelectOption('연수구','연수구','인천')
                ,new SelectOption('옹진군','옹진군','인천')
                ,new SelectOption('중구','중구','인천')
                ,new SelectOption('전지역','none','전남')
                ,new SelectOption('강진군','강진군','전남')
                ,new SelectOption('고흥군','고흥군','전남')
                ,new SelectOption('곡성군','곡성군','전남')
                ,new SelectOption('광양시','광양시','전남')
                ,new SelectOption('구례군','구례군','전남')
                ,new SelectOption('나주시','나주시','전남')
                ,new SelectOption('담양군','담양군','전남')
                ,new SelectOption('목포시','목포시','전남')
                ,new SelectOption('무안군','무안군','전남')
                ,new SelectOption('보성군','보성군','전남')
                ,new SelectOption('순천시','순천시','전남')
                ,new SelectOption('신안군','신안군','전남')
                ,new SelectOption('여수시','여수시','전남')
                ,new SelectOption('영광군','영광군','전남')
                ,new SelectOption('영암군','영암군','전남')
                ,new SelectOption('완도군','완도군','전남')
                ,new SelectOption('장성군','장성군','전남')
                ,new SelectOption('장흥군','장흥군','전남')
                ,new SelectOption('진도군','진도군','전남')
                ,new SelectOption('함평군','함평군','전남')
                ,new SelectOption('해남군','해남군','전남')
                ,new SelectOption('화순군','화순군','전남')
                ,new SelectOption('전지역','none','전북')
                ,new SelectOption('고창군','고창군','전북')
                ,new SelectOption('군산시','군산시','전북')
                ,new SelectOption('김제시','김제시','전북')
                ,new SelectOption('남원시','남원시','전북')
                ,new SelectOption('무주군','무주군','전북')
                ,new SelectOption('부안군','부안군','전북')
                ,new SelectOption('순창군','순창군','전북')
                ,new SelectOption('완주군','완주군','전북')
                ,new SelectOption('익산시','익산시','전북')
                ,new SelectOption('임실군','임실군','전북')
                ,new SelectOption('장수군','장수군','전북')
                ,new SelectOption('전주시','전주시','전북')
                ,new SelectOption('정읍시','정읍시','전북')
                ,new SelectOption('진안군','진안군','전북')
                ,new SelectOption('전지역','none','제주')
                ,new SelectOption('서귀포시','서귀포시','제주')
                ,new SelectOption('제주시','제주시','제주')
                ,new SelectOption('전지역','none','충남')
                ,new SelectOption('계룡시','계룡시','충남')
                ,new SelectOption('공주시','공주시','충남')
                ,new SelectOption('금산군','금산군','충남')
                ,new SelectOption('논산시','논산시','충남')
                ,new SelectOption('당진시','당진시','충남')
                ,new SelectOption('보령시','보령시','충남')
                ,new SelectOption('부여군','부여군','충남')
                ,new SelectOption('서산시','서산시','충남')
                ,new SelectOption('서천군','서천군','충남')
                ,new SelectOption('아산시','아산시','충남')
                ,new SelectOption('예산군','예산군','충남')
                ,new SelectOption('천안시','천안시','충남')
                ,new SelectOption('청양군','청양군','충남')
                ,new SelectOption('태안군','태안군','충남')
                ,new SelectOption('홍성군','홍성군','충남')
                ,new SelectOption('전지역','none','충북')
                ,new SelectOption('괴산군','괴산군','충북')
                ,new SelectOption('단양군','단양군','충북')
                ,new SelectOption('보은군','보은군','충북')
                ,new SelectOption('영동군','영동군','충북')
                ,new SelectOption('옥천군','옥천군','충북')
                ,new SelectOption('음성군','음성군','충북')
                ,new SelectOption('제천시','제천시','충북')
                ,new SelectOption('증평군','증평군','충북')
                ,new SelectOption('진천군','진천군','충북')
                ,new SelectOption('청원군','청원군','충북')
                ,new SelectOption('청주시','청주시','충북')
                ,new SelectOption('충주시','충주시','충북')
            };
            
            List<SelectOption> dependencyOptionList = new List<SelectOption>();

            for(SelectOption districtCountyOption : districtCountyOptionList) {
                if(districtCountyOption.dependencyValue == dependencyValue) {
                    dependencyOptionList.add(districtCountyOption);
                }
            }
            result.put('dependencyOptionList', dependencyOptionList);

            return result;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }

    @AuraEnabled
    public static Map<String,Object> getRegionalShoolInfo(Map<String,Object> params) {
        try {
            Map<String,Object> result = new Map<String,Object>();
            String citiyCountry = (String) params.get('citiyCountry');        // 시/도
            String districtCounty;                                            // 동/군/구
            String schoolName;                                                // 학교명

            Map<String,SelectOption> districtCountyOptionMap = new Map<String,SelectOption>();
            List<SelectOption> districtCountyOptionList = (List<SelectOption>) getDistrictCountryOptionList(citiyCountry).get('dependencyOptionList');
            for(SelectOption districtCountyOption : districtCountyOptionList) {
                districtCountyOptionMap.put(districtCountyOption.value, districtCountyOption);
            }

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
                result.put('totalCount',outputObj.meta[0].total_count);
                System.debug('I/F 성공');
                System.debug(
                    JSON.serializePretty(outputObj)
                );
                List<SchoolInfo> schoolInfoList = new List<SchoolInfo>();

                for(IFN_EIF1004_DT001_MD001.item ifShoolInfo : outputObj.item) {
                    SchoolInfo schoolInfo = new SchoolInfo();
                    schoolInfo.schoolName      = ifShoolInfo.SchoolTitle;
                    schoolInfo.neisCodeStd     = ifShoolInfo.NeisCodeStd; 
                    schoolInfo.citiyCountry    = ifShoolInfo.Address1;
                    schoolInfo.districtCounty  = ifShoolInfo.Address2;
                    schoolInfo.districtCountyLabel  = districtCountyOptionMap.get(ifShoolInfo.Address2)?.label;
                    schoolInfo.tel             = ifShoolInfo.tel; 
                    schoolInfo.fax             = ifShoolInfo.fax; 
                    schoolInfo.countRoom       = ifShoolInfo.CountRoom; 
                    schoolInfo.countStudent    = ifShoolInfo.CountStudent; 
                    schoolInfo.countTeacher    = ifShoolInfo.CountTeacher; 
                    schoolInfoList.add(schoolInfo);
                    //if(schoolInfoList.size() == 500) break;
                }

                result.put('schoolInfoList', schoolInfoList);
            }

            return result;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' (Line : ' + e.getLineNumber() + ')');
        }
    }


    public class SchoolInfo {
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

    public class SelectOption {
        @AuraEnabled public String label;         
        @AuraEnabled public String value;         
        @AuraEnabled public String dependencyValue; 
        public SelectOption() {}       
        public SelectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
        public SelectOption(String label, String value, String dependencyValue) {
            this(label, value);
            this.dependencyValue = dependencyValue;
        }       
    }
}