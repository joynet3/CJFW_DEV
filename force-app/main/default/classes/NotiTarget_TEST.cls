@isTest
public with sharing class NotiTarget_TEST {
    
    @isTest
    static void execute() {
        NotiTarget target = new NotiTarget();
        target.setType('email');
        System.assert( 'email'.equals(target.getType()));
        target.setAttachmentIds(new Set<String>());
        System.debug(target.getAttachmentIds());
        //System.assert(  == target.getAttachmentIds());
        target.setLang('en_US');
        System.assert('en_US'.equals(target.getLang()));
        target.setToAddresses(new Set<String>{'test@test.com'});
        System.assert('test@test.com'.equals(new List<String>(target.getToAddresses())[0]));
        target.setCcAddresses(new Set<String>{'test2@test.com'});
        System.assert('test2@test.com'.equals(new List<String>(target.getCcAddresses())[0]));
        target.setBccAddresses(new Set<String>{'test3@test.com'});
        System.assert('test3@test.com'.equals(new List<String>(target.getBccAddresses())[0]));

        new NotiTarget('id');
    }
}