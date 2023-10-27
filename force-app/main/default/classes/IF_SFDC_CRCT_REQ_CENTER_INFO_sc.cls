/**
 * @description       : 
 * @author            : AhnTaeJin(tj.ahn@daeunextier.com)
 * @group             : 
 * @last modified on  : 03-14-2023
 * @last modified by  : admin
**/
global with sharing class IF_SFDC_CRCT_REQ_CENTER_INFO_sc implements Schedulable{
    global IF_SFDC_CRCT_REQ_CENTER_INFO_sc() {
    }

    global void execute(SchedulableContext sc) {
        IF_SFDC_CRCT_REQ_CENTER_INFO_ba b = new IF_SFDC_CRCT_REQ_CENTER_INFO_ba(false,null);
        Database.executeBatch(b,1);

        /*
        //11350 : 노원구 - 건수만은거 샘플 1.6메가

        //List<String> failSidoList = new List<String>{'11350'};
        List<String> failSidoList = new List<String>{'11530'};
        
        IF_SFDC_CRCT_REQ_CENTER_INFO_ba b = new IF_SFDC_CRCT_REQ_CENTER_INFO_ba(true, failSidoList);
        Database.executeBatch(b,1);

        */
    }

    global class Input{
        public String item;
        public Res response;
    }

    global class Res{
        public List<Items> item;
    }

    global class Items{
        public String sidoname;
        public String sigunguname;
        public String sigunname;
        public String stcode;
        public String crname;
        public String crtypename;
        public String zipcode;
        public String craddr;
        public String crtelno;
        public String crfaxno;
        public String crhome;
        public String chcrtescnt;
        public String crcapat;
        public String crchcnt;
        public String la;
        public String lo;
        public String CRREPNAME;
        public String crcnfmdt;
        public String crpausebegindt;
        public String crpauseenddt;
        public String crabldt;
        public String datastdrdt;
    }

}