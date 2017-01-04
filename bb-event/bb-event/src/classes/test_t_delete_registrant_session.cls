@isTest
public class test_t_delete_registrant_session {
	/**
	 * test delete a registrant session of a my event session of a my event
	 * which limit 1
	 */
    @isTest
    public static void testSingleRegistrantSession1(){
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate event (count, venue, limit);
         */
        List<My_Event__c> me = test_data_factory.getEvents(1, v.Id, 1);
        
        /**
         * generate my event session (count, event);
         */
        List<My_Event_Session__c> mes = test_data_factory.getEventSessions(1, me[0]);
        
        /**
         * create contact
         */
        List<Contact> cts = test_data_factory.getContacts(1);
        
        /**
         * create registrant (contact, list event)
         */
        List<Registrant__c> registrants = test_data_factory.getRegistrants(cts[0], me);
        
        /**
         * insert new Registrant_Session__c (list registrant, list my event session)
         */
        List<Registrant_Session__c> registrant_sessions = test_data_factory.getRegistrantSessions(registrants, mes);
        
		/**
		 * ensure that my event session sit no available
		 */
        for(My_Event_Session__c tmes : [select Available_Sit__c from My_Event_Session__c where Id in :mes]){
            System.assertEquals(0, tmes.Available_Sit__c);
        }
        
        /**
		 * ensure that event full
		 */
        for(My_Event__c tme : [select Availability_Status__c from My_Event__c where Id in :me]){
            System.assertEquals('Full', tme.Availability_Status__c);
        }
        
        delete registrant_sessions;
        
        /**
		 * ensure that my event session sit  available
		 */
        for(My_Event_Session__c tmes : [select Available_Sit__c from My_Event_Session__c where Id in :mes]){
            System.assertEquals(1, tmes.Available_Sit__c);
        }
        
        /**
		 * ensure that event available
		 */
        for(My_Event__c tme : [select Availability_Status__c from My_Event__c where Id in :me]){
            System.assertEquals('Available', tme.Availability_Status__c);
        }
    }
    
    /**
	 * test delete multiple registrant session of multiple my event session of a my event
	 * which limit 2
	 */
    
    @isTest
    public static void testSingleRegistrantSession2(){
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate a event (count, venue, limit);
         * which limit = 2
         */
        List<My_Event__c> me = test_data_factory.getEvents(1, v.Id, 2);
        
        /**
         * generate my event session (count, event);
         * will generate 5 event session which has 2 available sit
         */
        List<My_Event_Session__c> mes = test_data_factory.getEventSessions(5, me[0]);
        
        /**
         * create contact
         */
        List<Contact> cts = test_data_factory.getContacts(1);
        
        /**
         * create registrant (contact, list event);
         * will generate 5 registrant of each event
         */
        List<Registrant__c> registrants = test_data_factory.getRegistrants(5, cts[0], me);
        
        /**
         * insert new multiple Registrant_Session__c (list registrant, my event session) of a my event session;
         * will generate 5 registrant session of each my event session
         */
        List<Registrant_Session__c> registrant_sessions = new List<Registrant_Session__c>();
        //System.debug('before = ' + [select Available_Sit__c from My_Event_Session__c where Id = :mes[0].Id]);
        registrant_sessions.addAll(test_data_factory.getMultipleRegistrantSessionsOfAMES(new List<Registrant__c>{registrants[0], registrants[1]}, mes[0]));
        
        /**
         * ensure that mes[0] has no availbale sit (available sit = 0)
         */
        
        for(My_Event_Session__c lmes : [select Available_Sit__c from My_Event_Session__c where Id = :mes[0].id]){
            System.assertEquals(0, lmes.Available_Sit__c);
        }
        
        /**
         * ensure that another mes (ather than mes[0]) still have 2 sit;
         */
        for(My_Event_Session__c lmes : [select Available_Sit__c from My_Event_Session__c where Id != :mes[0].id]){
            System.assertEquals(2, lmes.Available_Sit__c);
        }
        
        /**
         * register event session to all free my event session (mes which have index > 0)
         */
        for(Integer i = 1; i < mes.size(); i++){
            registrant_sessions.addAll(test_data_factory.getMultipleRegistrantSessionsOfAMES(new List<Registrant__c>{registrants[0], registrants[1]}, mes[i]));
        }
        
        /**
         * ensure that all mes has no sit available
         */
        for(My_Event_Session__c lmes : [select Available_Sit__c from My_Event_Session__c where Id in :mes]){
            System.assertEquals(0, lmes.Available_Sit__c);
        }
        
        /**
         * ensure that status of event is full
         */
        for(My_Event__c lme : [select Availability_Status__c from My_Event__c where id in :me]){
            System.assertEquals('Full', lme.Availability_Status__c);
        }
        
        delete registrant_sessions;
        
        /**
		 * ensure that my event session sit  available
		 */
        for(My_Event_Session__c tmes : [select Available_Sit__c from My_Event_Session__c where Id in :mes]){
            System.assertEquals(2, tmes.Available_Sit__c);
        }
        
        /**
		 * ensure that event available
		 */
        for(My_Event__c tme : [select Availability_Status__c from My_Event__c where Id in :me]){
            System.assertEquals('Available', tme.Availability_Status__c);
        }
    }
}