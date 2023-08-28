@isTest
private class Testextension-output-salesforce{

	@testSetup static void setup(){

		Ifmaster__c ifmastercObj = new Ifmaster__c (
			Name = 'test value', 
			ContentType__c ='text/plain', 
			Description__c = 'Test Value', 
			Method__c ='GET', 
			ClassName__c = 'test value', 
			Param1__c = 'test value', 
			Param2__c = 'test value', 
			Param3__c = 'test value', 
			Param4__c = 'test value', 
			IsRealLogInsert__c = TRUE, 
			Header__c = 'test value'
		);
		insert ifmastercObj;
		 Apexclass apexclassObj = new Apexclass (
			Name = 'test value', 
			ApiVersion = 1.1, 
			Status ='Inactive', 
			LengthWithoutComments = 12
		);
		insert apexclassObj;
		
	}

	@isTest static void testMethod1() {
		// code_block	
	}

	@isTest static void testMethod2() {
		// code_block	
	}
}