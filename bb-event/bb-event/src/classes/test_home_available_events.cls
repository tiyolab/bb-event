@isTest
public class test_home_available_events {
    
    /**
     * this method test is to test ability to query correct event
     * it's mean event which registration deadline isn't passed and place is still available
     */
	@isTest
    public static void testEventEvailibility(){
        /**
         * create venue
         */
        Venue__c v = test_data_factory.getVenue();
        
        List<My_Event__c> events = new List<My_Event__c>();
        datetime tmpStartDate, tmpEndDate, tmpRegDeadline;
        String availibility = '';
        
        Integer available = 0, inAvailable = 0;
        
        for(Integer i = 1; i <= 100; i++){
            
            /**
             * random number between 0 and 9
             * if random result if odd so registration deadline is passed and increase inavailable counter
             * else if result is even registration deadline is soon
             */ 
            if(Math.mod((Integer)(Math.random()*10), 2) == 0){
                tmpRegDeadline = Datetime.now() + 1;
                tmpStartDate = tmpRegDeadline + 1;
                tmpEndDate = tmpStartDate + 2;
               	
                /**
                 * random number between 0 and 9
                 * if random result if odd so event is availibility is full and place was not yet available and increase inavailable counter
                 * else place is stil available and increment available counter
                 */ 
                if(Math.mod((Integer)(Math.random()*10), 2) == 0){
                    availibility = 'Available';
                    available++;
                }else{
                    availibility = 'Full';
                    inAvailable++;
                }
            }else{
            	tmpRegDeadline = Datetime.now() - 1;
                tmpStartDate = tmpRegDeadline + 1;
                tmpEndDate = tmpStartDate + 2;
                availibility = 'Available';
                
                inAvailable++;
            }
            
        	My_Event__c me = new My_Event__c(
                Availability_Status__c = availibility,
                End_Date__c = tmpEndDate,
                Limit__c = 100,
                Name = 'event ' + i,
                Registration_Deadline__c = tmpRegDeadline,
                Start_Date__c = tmpStartDate,
                Venue__c = v.Id,
                Enable_VR__c = 'disable'
            );
            
            events.add(me);
        }
        
        insert events;
        
        List<My_Event__c> availableEvents = new List<My_Event__c>();
        
        Test.startTest();
        
        c_home_controller c = new c_home_controller();
        availableEvents = c.getEvents();
        
        Test.stopTest();
        
        System.assert(availableEvents.size() == available);
    }
    
    /**
     * this method is to test number of column of event on page
     */
    
    /**
     * no events available
     */
    @isTest
    public static void testNumberColumnOf0Event(){
        
        /**
         * no event available
         */
        Test.startTest();
        
        c_home_controller c = new c_home_controller();
        c.getEvents();
        
        Test.stopTest();
        
        System.assert(c.sizeMin == 1);
        System.assert(c.sizeMedium == 1);
        System.assert(c.sizeLarge == 1);
    }
    
    /**
     * a event available
     */
    @isTest
    public static void testNumberColumnOf1Event(){
        /**
         * create venue
         */
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate a event
         */
        test_data_factory.getEvents(1, v.Id);
        
        /**
         * a event available
         */
        Test.startTest();
        
        c_home_controller c = new c_home_controller();
        c.getEvents();
        
        Test.stopTest();
        
        System.assert(c.sizeMin == 1);
        System.assert(c.sizeMedium == 1);
        System.assert(c.sizeLarge == 1);
    }
    
    /**
     * 2 events available
     */
    @isTest
    public static void testNumberColumnOf2Event(){
        /**
         * create venue
         */
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate a event
         */
        test_data_factory.getEvents(2, v.Id);
        
        /**
         * a event available
         */
        Test.startTest();
        
        c_home_controller c = new c_home_controller();
        c.getEvents();
        
        Test.stopTest();
        
        System.assert(c.sizeMin == 1);
        System.assert(c.sizeMedium == 2);
        System.assert(c.sizeLarge == 2);
    }
    
    /**
     * 3 events available
     */
    @isTest
    public static void testNumberColumnOf3Event(){
        /**
         * create venue
         */
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate a event
         */
        test_data_factory.getEvents(3, v.Id);
        
        /**
         * a event available
         */
        Test.startTest();
        
        c_home_controller c = new c_home_controller();
        c.getEvents();
        
        Test.stopTest();
        
        System.assert(c.sizeMin == 1);
        System.assert(c.sizeMedium == 2);
        System.assert(c.sizeLarge == 3);
    }
    
    /**
     *more 3 events available
     */
    @isTest
    public static void testNumberColumnOfMore3Event(){
        /**
         * create venue
         */
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * generate a event
         */
        test_data_factory.getEvents(5, v.Id);
        
        /**
         * a event available
         */
        Test.startTest();
        
        c_home_controller c = new c_home_controller();
        c.getEvents();
        
        Test.stopTest();
        
        System.assert(c.sizeMin == 1);
        System.assert(c.sizeMedium == 2);
        System.assert(c.sizeLarge == 4);
    }
    
    /**
     * test success login
     */
    @isTest
    public static void testSuccessLogin(){
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
        registrants[0].Code__c = 'myCode';
        update registrants;
        
        c_home_controller c = new c_home_controller();
        c.bookingCode = registrants[0].Code__c;
        
        PageReference page = c.login();
        System.assertEquals(System.Page.c_my_event.getUrl()+'?id='+registrants[0].Id, page.getUrl());
        System.assertEquals(registrants[0].Id, page.getParameters().get('id'));
    }
    
    /**
     * test failed login
     */
    @isTest
    public static void testFailedLogin(){
        c_home_controller c = new c_home_controller();
        c.bookingCode = 'fake_code';
        System.assert(null == c.Login());
    }
}