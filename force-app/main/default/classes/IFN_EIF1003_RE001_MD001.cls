/**
 * @Class : IFN_EIF1003_RE001_MD001.cls
 * @group Framework :
 * @Author : 박지오
 * @Date : 2023-09-11
 * @Version : 1.0
 * @Description : Remember 명함 데이터 GET
 * @Modified :
 * ----------------------------------------------
 *  NO | Date       | Modifier       | Description
 * ----------------------------------------------
 *  1. | 2023.09.11 | 박지오          | 최초작성
 * */
public class IFN_EIF1003_RE001_MD001 {
    public String interfaceId = 'IFN_EIF1003_RE001_MD001';

    public IFN_CommonLog.LogWrap logWrap { get; set; }
    public IFN_CommonLog commlog;
    public IFN_EIF1003_RE001_MD001.RE001RequestWrapper param;

    public IFN_CalloutResult callout() {
        IFN_CalloutResult calloutResult = new IFN_CalloutResult();

        this.logWrap = new IFN_CommonLog.logWrap(this.interfaceId, 'Real');
        this.commlog = new IFN_CommonLog();

        try {
            IFN_EIF1003_Callout callout = new IFN_EIF1003_Callout(this.interfaceId, 'Real');
            calloutResult = callout.getResponse(this.interfaceId, JSON.serialize(this.param));
        } catch (Exception e) {
            this.logWrap.ErrorCode = '-1';
            this.logWrap.ErrorText.add(e.getLineNumber() + e.getMessage() + e.getStackTraceString());
            this.logWrap.Status = 'ERROR';
        }

        commlog.insertLog(this.logWrap);
        return calloutResult;
    }

    public class RE001RequestWrapper {
        public String start_at = String.valueOf(System.today().addDays(-1));        //-1Day까지 등록된 데이터를 가져오기 위해 today - 1로 날짜 지정
//        public String start_at = '2023-09-10';
        public Integer page {get;set;}
        public Integer per = 200;                                                   // 한 페이지에 나타낼 명함첩 갯수
    }

    public class RE001ResultWrapper {
        public Object result { get; set; }
    }

    public class RE001SuccessWrapper {
        public List<Stack> stacks { get; set; }
        public Metainfo metainfo { get; set; }
    }
    public class RE001ErrorWrapper {
        public String code { get; set; }
        public String message { get; set; }
    }

    //Remember 데이터 response DTO
    public class Stack {
        public Integer id{ get; set; }
        public Card main_card{ get; set; }
        public List<Card> sub_cards{ get; set; }
        public List<Memo> memos{ get; set; }
        public List<Info> groups{ get; set; }
        public Info team{ get; set; }
        public Info book{ get; set; }
        public String created_at{ get; set; }
        public String trashed_at{ get; set; }
        public String deleted_at{ get; set; }
    }

    public class Card {
        public Integer id{ get; set; }
        public String name{ get; set; }
        public String company{ get; set; }
        public String department{ get; set; }
        public String position{ get; set; }
        public Phone mobile{ get; set; }
        public Phone fax{ get; set; }
        public Phone tel{ get; set; }
        public String email{ get; set; }
        public Address address{ get; set; }
        public ImageUrl image_url{ get; set; }
        public User user{ get; set; }
    }
    public class Phone {
        public String international_code{ get; set; }
        public String national_number{ get; set; }
        public String normalized_number{ get; set; }
    }
    public class Address {
        public String defaultVal{get; set;}
        public String detail{ get; set; }
    }
    public class ImageUrl {
        public String front{ get; set; }
        public String back{ get; set; }
    }
    public class User {
        public Integer id{ get; set; }
        public String email{ get; set; }
    }
    public class Memo {
        public Integer id{ get; set; }
        public String value{ get; set; }
        public User user{ get; set; }
        public String created_at{ get; set; }
        public String updated_at{ get; set; }
    }
    public class Info {
        public Integer id{ get; set; }
        public String name{ get; set; }
    }
    public class Metainfo {
        public Integer page { get; set; }
        public Integer per { get; set; }
        public Integer total_count { get; set; }
        public Integer total_pages { get; set; }
    }
}