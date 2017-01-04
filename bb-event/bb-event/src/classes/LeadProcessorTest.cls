@isTest
public class LeadProcessorTest {
    
	@isTest(SeeAllData = false)
    public static void testLead(){
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < 200; i++){
            leads.add(new Lead(LastName = 'last lead '+i, Company = 'The', Status = 'Open - Not Contacted'));
        }
        
        insert leads;
        
        Test.startTest();
        LeadProcessor lp = new LeadProcessor();
        Id batchId = Database.executeBatch(lp);
        Test.stopTest();
        
        
        System.assertEquals(200, [select count() from Lead where LeadSource = 'Dreamforce']);
    }
}