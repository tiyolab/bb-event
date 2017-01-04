@IsTest
public class AccountProcessorTest{
	@isTest(SeeAllData = true)
	public static void testCountContact(){
        
        String id = '0012800000vSp3Q';
		
		AggregateResult[] ar = [select count(Id)cnt from Contact group by AccountId having AccountId = :id];
        
        Test.startTest();
		AccountProcessor.countContacts(new String[]{'0012800000vSp3Q'});
		Test.stopTest();
        
        Account[] ac = [select Number_of_Contacts__c, Id from Account where Id = :id];
		System.assertEquals((Integer)ar[0].get('cnt'), ac[0].Number_of_Contacts__c);
		
	}
}