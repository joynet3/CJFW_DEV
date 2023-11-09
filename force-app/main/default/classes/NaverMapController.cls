/**
 * @description       : 
 * @author            : yejoo.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : yejoo.lee@dkbmc.com
**/
public with sharing class NaverMapController {

    // public String sido {get;set;}
    // public String name {get;set;}

    public string lexOrigin {get{ 
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
        } set;}

    public NaverMapController() {
        // name = 'test';
    }

    // public void show(){
    //     this.name = '22';
    // }

    // public List<SelectOption> getSidoval() {
    //     List<SelectOption> options = new List<SelectOption>();
    //     options.add(new SelectOption('US','US'));
    //     options.add(new SelectOption('CANADA','Canada'));
    //     options.add(new SelectOption('MEXICO','Mexico'));
    //     return options;
    // }

    @AuraEnabled(cacheable=true)
    public static String getVFOrigin() {
        String vfOrigin = '';
        String baseURL = URL.getOrgDomainUrl().toExternalForm(); // Expected Format = https://domain.my.salesforce.com
        // Expected Format for DE, Sandbox & Production ORgs = https://domain--c.vf.force.com
        if(baseURL.contains('sandbox')){
            vfOrigin = baseURL.split('.sandbox.')[0] + '--c.' + 'sandbox.vf.force.com';
        } else {
            vfOrigin = baseURL.split('.my.')[0] + '--c.' + 'vf.force.com';
        }
        return vfOrigin;
    }

}