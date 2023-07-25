public with sharing class QuoteFileContainerController {

    ApexPages.StandardSetController ssc;
	public String selectedIdList{get;set;} 
	public String selectedId{get;set;} 
    
	public QuoteFileContainerController(ApexPages.StandardSetController controller) 
	{
        this.ssc = controller;
        
        // listview에서 선택된 id 리스트 형태로 반환 
        Id[] selectedIds = new Id[0];
    	for (Sobject t : ssc.getSelected())
    	{
        	selectedIds.add(t.Id);
    	}
        if (!selectedIds.isEmpty())
            selectedId = selectedIds[0];
        selectedIdList = JSON.serialize(selectedIds);
        system.debug('selectedIdList-->'+selectedIdList);
    }
    
}