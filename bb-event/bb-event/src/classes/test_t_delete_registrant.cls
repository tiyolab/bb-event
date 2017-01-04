@isTest
public class test_t_delete_registrant {
	/**
	 * test delete registrant which register to a event session and a event
	 * if no event session sit available, the event availibility status will full
	 * and if registrant deleted it will alseo delete registrant session and increase the available sit of my event session
	 *  and the event availibility status will available
	 */
    @isTest
    public static void testDeleteRegistrantASession(){
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
         * create registrant
         */
        List<Registrant__c> registrants = test_data_factory.getRegistrants(cts[0], me);
        
        /**
         * insert new Registrant_Session__c
         */
        List<Registrant_Session__c> registrant_sessions = test_data_factory.getRegistrantSessions(registrants, mes);
        
        My_Event__c nme = [select Availability_Status__c from My_Event__c where Id = :me[0].Id];
        My_Event_Session__c nmes = [select Available_Sit__c from My_Event_Session__c where Id = :mes[0].Id];
        
        System.assertEquals('Full', nme.Availability_Status__c);
        System.assertEquals(0, nmes.Available_Sit__c);
        
        delete registrants;
        
        My_Event__c nme2 = [select Availability_Status__c from My_Event__c where Id = :me[0].Id];
        My_Event_Session__c nmes2 = [select Available_Sit__c from My_Event_Session__c where Id = :mes[0].Id];
        
        System.assertEquals('Available', nme2.Availability_Status__c);
        System.assertEquals(1, nmes2.Available_Sit__c);
        
    }
    
    /**
     * test delete registrant which register to multiple event sessions and a event
     */
    @isTest
    public static void testDeleteRegistrantMultipleSession(){
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate event (count, venue, limit);
         */
        List<My_Event__c> me = test_data_factory.getEvents(1, v.Id, 1);
        
        /**
         * generate 5 my event session (count, event);
         */
        List<My_Event_Session__c> mes1 = test_data_factory.getEventSessions(4, me[0]);
        List<My_Event_Session__c> mes2 = test_data_factory.getEventSessions(1, me[0]);
        
        System.debug('mes = ' + [select count() from My_Event_Session__c where My_Event__c = :me[0].Id]);
        
        /**
         * create contact
         */
        List<Contact> cts = test_data_factory.getContacts(1);
        
        /**
         * create registrant (contact, list event)
         */
        List<Registrant__c> registrants1 = test_data_factory.getRegistrants(cts[0], me);
        
        /**
         * insert new Registrant_Session__c (list registrant, list my event session)
         */
        List<Registrant_Session__c> registrant_sessions1 = test_data_factory.getRegistrantSessions(registrants1, mes1);
        
        /**
         * ensure that event still available because still a event sessesion availabe sit
         */
        My_Event__c sme1 = [select Availability_Status__c from My_Event__c where Id = :me[0].Id];
        System.assertEquals('Available', sme1.Availability_Status__c);
        
        /**
         * all event session has been book
         */
        List<Registrant_Session__c> registrant_sessions2 = test_data_factory.getRegistrantSessions(registrants1, mes2);
        
        /**
         * ensure that event still available because still a event sessesion availabe sit
         */
        My_Event__c sme2 = [select Availability_Status__c from My_Event__c where Id = :me[0].Id];
        System.assertEquals('Full', sme2.Availability_Status__c);
        
        List<My_Event_Session__c> smes1 = [select Available_Sit__c from My_Event_Session__c where My_Event__c = :me[0].Id];
        for(My_Event_Session__c tmes : smes1){
            System.assertEquals(0, tmes.Available_Sit__c);
        }
        
        delete registrants1;
        
        My_Event__c sme3 = [select Availability_Status__c from My_Event__c where Id = :me[0].Id];
        List<My_Event_Session__c> smes2 = [select Available_Sit__c from My_Event_Session__c where My_Event__c = :me[0].Id];
        
        System.assertEquals('Available', sme3.Availability_Status__c);
        for(My_Event_Session__c tmes : smes2){
            System.assertEquals(1, tmes.Available_Sit__c);
        }
        
    }
    
    /**
	 * test delete registrants which register to a event session in each event
	 */
    @isTest
    public static void testDeleteRegistrantaSessionMultipleEvent(){
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate 5 event (count, venue, limit);
         */
        List<My_Event__c> me = test_data_factory.getEvents(5, v.Id, 1);
        
        /**
         * generate a my event session (count, event) in each event
         * which available sit = 1
         */
        Integer i = 0;
        Map<Integer, List<My_Event_Session__c>> eventMyEventSession = new Map<Integer, List<My_Event_Session__c>>();
        for(My_Event__c tme : me){
            eventMyEventSession.put(i, test_data_factory.getEventSessions(1, tme));
            i++;
        }
        
        /**
         * create contact
         */
        List<Contact> cts = test_data_factory.getContacts(1);
        
        /**
         * create 5 registrant (contact, list event)
         */
        List<Registrant__c> registrants = test_data_factory.getRegistrants(cts[0], me);
        
        /**
         * insert new Registrant_Session__c (list registrant, list my event session)
         */
        /*for(Integer j : eventMyEventSession.keySet()){
            test_data_factory.getRegistrantSessions(registrants, eventMyEventSession.get(j));
        }*/
        List<Registrant_Session__c> lRs1 = new List<Registrant_Session__c>();
        for(Integer j : eventMyEventSession.keySet()){
            lRs1.add(new Registrant_Session__c(My_Event_Session__c = eventMyEventSession.get(j).get(0).Id, Registrant__c = registrants.get(j).Id));
        }
        
        insert lRs1;
        
        /**
         * ensure that event full because still a event session of event has been book
         */
        for(My_Event__c tme : [select Availability_Status__c from My_Event__c where Id in :me]){
        	System.assertEquals('Full', tme.Availability_Status__c);    
        }
        
        for(My_Event_Session__c tmes : [select Available_Sit__c from My_Event_Session__c where My_Event__c in :me]){
            System.assertEquals(0, tmes.Available_Sit__c);
        }
        
        delete registrants;
        
        for(My_Event__c tme : [select Availability_Status__c from My_Event__c where Id in :me]){
        	System.assertEquals('Available', tme.Availability_Status__c);    
        }
        for(My_Event_Session__c tmes : [select Available_Sit__c from My_Event_Session__c where My_Event__c in :me]){
            System.assertEquals(1, tmes.Available_Sit__c);
        }
        
    }
    
    /**
	 * test delete registrants which register to multiple event session in each event
	 */
    @isTest
    public static void testDeleteRegistrantMultipleSessionAndEvent(){
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate 5 event (count, venue, limit);
         */
        List<My_Event__c> me = test_data_factory.getEvents(5, v.Id, 1);
        
        /**
         * generate 5 my event session (count, event) in each event
         * which has available sit = 1
         */
        Integer i = 0;
        Map<Integer, List<My_Event_Session__c>> eventMyEventSession = new Map<Integer, List<My_Event_Session__c>>();
        for(My_Event__c tme : me){
            eventMyEventSession.put(i, test_data_factory.getEventSessions(5, tme));
            i++;
        }
        
        /**
         * create contact
         */
        List<Contact> cts = test_data_factory.getContacts(1);
        
        /**
         * create 5 registrant (contact, list event)
         */
        List<Registrant__c> registrants = test_data_factory.getRegistrants(cts[0], me);
        
        /**
         * insert new Registrant_Session__c (list registrant, list my event session)
         */
        List<Registrant_Session__c> lRs1 = new List<Registrant_Session__c>();
        for(Integer j : eventMyEventSession.keySet()){
            lRs1.add(new Registrant_Session__c(My_Event_Session__c = eventMyEventSession.get(j).get(0).Id, Registrant__c = registrants.get(j).Id));
            lRs1.add(new Registrant_Session__c(My_Event_Session__c = eventMyEventSession.get(j).get(1).Id, Registrant__c = registrants.get(j).Id));
            lRs1.add(new Registrant_Session__c(My_Event_Session__c = eventMyEventSession.get(j).get(2).Id, Registrant__c = registrants.get(j).Id));
            lRs1.add(new Registrant_Session__c(My_Event_Session__c = eventMyEventSession.get(j).get(3).Id, Registrant__c = registrants.get(j).Id));
            /*test_data_factory.getRegistrantSessions(registrants, new List<My_Event_Session__c>{
                                                       eventMyEventSession.get(j).get(0),
                                                       eventMyEventSession.get(j).get(1),
                									   eventMyEventSession.get(j).get(2),
                									   eventMyEventSession.get(j).get(3)
                                                    });*/
        }
        
        insert lRs1;
        
        /**
         * ensure that event still available because still a event sessesion availabe sit
         */
        for(My_Event__c tme : [select Availability_Status__c from My_Event__c where Id in :me]){
        	System.assertEquals('Available', tme.Availability_Status__c);    
        }
        
        /**
         * all event session has been book
         */
        List<Registrant_Session__c> lRs2 = new List<Registrant_Session__c>();
        for(Integer j : eventMyEventSession.keySet()){
            lRs2.add(new Registrant_Session__c(My_Event_Session__c = eventMyEventSession.get(j).get(4).Id, Registrant__c = registrants.get(j).Id));
            /*test_data_factory.getRegistrantSessions(registrants, new List<My_Event_Session__c>{
                									   eventMyEventSession.get(j).get(4)
                                                    });*/
        }
        insert lRs2;
        
        /**
         * ensure that event Full because all event sessesion has been book
         */
        for(My_Event__c tme : [select Availability_Status__c from My_Event__c where Id in :me]){
        	System.assertEquals('Full', tme.Availability_Status__c);    
        }
        
        for(My_Event_Session__c tmes : [select Available_Sit__c from My_Event_Session__c where My_Event__c in :me]){
            System.assertEquals(0, tmes.Available_Sit__c);
        }
        
        delete registrants;
        
        for(My_Event__c tme : [select Availability_Status__c from My_Event__c where Id in :me]){
        	System.assertEquals('Available', tme.Availability_Status__c);    
        }
        for(My_Event_Session__c tmes : [select Available_Sit__c from My_Event_Session__c where My_Event__c in :me]){
            System.assertEquals(1, tmes.Available_Sit__c);
        }
        
    }
}