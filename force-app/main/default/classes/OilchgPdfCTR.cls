public with sharing class OilchgPdfCTR {
    public String myParam { get; set; }
    private final String versionData;

    public OilchgPdfCTR() {
        myParam = ApexPages.currentPage().getParameters().get('myParam');
        // ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE id ='0680w000002253iAAA'];
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion LIMIT 1];
        versionData = EncodingUtil.base64Encode(cv.VersionData);
        System.debug('versionData>>'+versionData);

    }

    public String getVersionData() {
        return versionData;
    }

    public List<Integer> getPages() {
        List<Integer> pages = new List<Integer>();
        Integer totalPages = 3;
        for(Integer i = 1; i <= totalPages; i++) {
            pages.add(i);
        }
        return pages;
    }
    

    
}