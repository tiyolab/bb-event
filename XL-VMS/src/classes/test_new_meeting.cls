@isTest
public class test_new_meeting {
	@isTest
    public static void testNewMeeting_with_new_contact(){
        /*<start_code>
        List<Contact> lc = new List<Contact>();
        
        Contact c1 = new Contact(Email='email@email.com');
        lc.add(c1);
        
        System.debug('user email test ' + UserInfo.getUserEmail());
        
        Meeting__c me = new_meeting.createNewMeeting('test', System.now(), System.now(), lc, 'a042800000bS2U3AAK');
		<end_code>*/        

        /**
         * evaluate that new contact create
         */
        /*<start_code>
        Contact[] c2 = [select Id from Contact where Email = :c1.Email];
        System.assertEquals(true, c2.size() > 0);
		<end_code>*/
        
        /**
         * evaluate that new guest created
         */
        /*<start_code>
        Guest__c[] g1 = [select Id from Guest__c where Meeting__c = :me.Id and Contact__c = :c2[0].Id];
        System.assertEquals(true, g1.size() > 0);
		<end_code>*/
    }
}