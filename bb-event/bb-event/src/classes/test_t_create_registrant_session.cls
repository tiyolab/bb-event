@isTest
public class test_t_create_registrant_session {
	@isTest
    public static void registerASession(){
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate a event (count, venue, limit);
         */
        List<My_Event__c> me = test_data_factory.getEvents(1, v.Id, 2);
        
        /**
         * generate a my event session (count, event);
         * which have 2 available sit
         */
        List<My_Event_Session__c> mes = test_data_factory.getEventSessions(1, me[0]);
        
        /**
         * create contact
         */
        List<Contact> cts = test_data_factory.getContacts(1);
        
        /**
         * create a registrant (contact, list event)
         */
        List<Registrant__c> registrants = test_data_factory.getRegistrants(cts[0], me);
        
        /**
         * register a registrant to a event session
         */
        Registrant_Session__c rs1 = new Registrant_Session__c(My_Event_Session__c = mes[0].Id, Registrant__c = registrants[0].Id);
        insert rs1;
        
        /**
         * ensure that sit availabe decrement one
         */
        for(My_Event_Session__c lmes : [select Available_Sit__c from My_Event_Session__c where Id = :mes[0].Id]){
            System.assertEquals(1, lmes.Available_Sit__c);
        }
        
        /**
         * ensure that event availablity still available
         */
        for(My_Event__c lme : [select Availability_Status__c from My_Event__c where Id in :me]){
            System.assertEquals('Available', lme.Availability_Status__c);
        }
    }
    
    @isTest
    public static void registerMultipleSession(){
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate 5 event (count, venue, limit);
         */
        List<My_Event__c> me = test_data_factory.getEvents(5, v.Id, 5);
        
        /**
         * generate a my event session (count, event);
         * which have 5 available sit
         */
        List<My_Event_Session__c> mes = test_data_factory.getEventSessions(1, me[0]);
        
        /**
         * create contact
         */
        List<Contact> cts = test_data_factory.getContacts(1);
        
        /**
         * create 5 registrant (contact, list event)
         */
        List<Registrant__c> registrants = test_data_factory.getRegistrants(cts[0], me);
        
        /**
         * register 5 registrant to a event session
         */
        List<Registrant_Session__c> listRs = new List<Registrant_Session__c>();
        for(Integer i = 0; i < 5; i++){
        	listRs.add(new Registrant_Session__c(My_Event_Session__c = mes[0].Id, Registrant__c = registrants[i].Id));    
        }
        insert listRs;
        
        /**
         * ensure that sit not availabe
         */
        for(My_Event_Session__c lmes : [select Available_Sit__c from My_Event_Session__c where Id = :mes[0].Id]){
            System.assertEquals(0, lmes.Available_Sit__c);
        }
        
        /**
         * ensure that event availablity not available
         */
        for(My_Event__c lme : [select Availability_Status__c from My_Event__c where Id = :me[0].Id]){
            System.assertEquals('Full', lme.Availability_Status__c);
        }
    }
}