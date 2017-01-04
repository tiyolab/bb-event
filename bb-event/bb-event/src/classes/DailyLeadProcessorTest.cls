@isTest
public class DailyLeadProcessorTest {
	@isTest(SeeAllData = false)
    public static void testLead(){
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < 200; i++){
            leads.add(new Lead(LastName = 'Last daily lead processor', Company = 'The Daily', Status = 'Open - Not Contacted'));
        }
        
        insert leads;
        
        System.assertEquals(0, [select count() from Lead where LeadSource = 'Dreamforce']);
        
        Test.startTest();
        DailyLeadProcessor dl = new DailyLeadProcessor();
        System.schedule('test lead', '0 0 0 11 7 ?', dl);
        Test.stopTest();
        
        System.assert([select count() from Lead where LeadSource = 'Dreamforce'] > 0);
    }
}