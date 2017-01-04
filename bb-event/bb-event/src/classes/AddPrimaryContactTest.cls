@isTest
public class AddPrimaryContactTest {
    
	@isTest(SeeAllData = false)
    public static void testContact(){
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 50; i++){
            Account NYa = new Account(Name = 'aNY-'+i, BillingState = 'NY');
            Account CAa = new Account(Name = 'aCA-'+i, BillingState = 'CA');
            
            accounts.add(NYa);
            accounts.add(CAa);
        }
        
        insert accounts;
        
        Test.startTest();
        AddPrimaryContact aq = new AddPrimaryContact(new Contact(LastName = 'The-last-CA'), 'CA');
        System.enqueueJob(aq);
        Test.stopTest();
        
        System.assertEquals(50, [select count() from Contact where LastName = 'The-last-CA']);
    }
}