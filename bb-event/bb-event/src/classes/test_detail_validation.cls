@isTest
public class test_detail_validation {
    
    /**
     * this test prevent user to add null id or no id passed to detail event page
     * if null/no id passed page will redirect to c_home
     */
    @isTest
    public static void testIdNull(){
        PageReference retValue;
        
        /**
         * pass page reference without id
         */
        PageReference page = System.Page.c_detail;
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assert(retValue.getUrl() == System.Page.c_home.getUrl());
    }
    
    /**
     * this test prevent user to add blank id (?id=) passed to detail event page
     * if blank id passed page will redirect to c_home
     */
    @isTest
    public static void testIdBlank(){
        PageReference retValue;
        
        /**
         * pass page reference with blank id
         */
        PageReference page = System.Page.c_detail;
        page.getParameters().put('id', '');
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assert(retValue.getUrl() == System.Page.c_home.getUrl());
    }
    
    /**
     * this test is to check response of invalid event id or not exist event id
     * if event id invalid/not exists page will redirect to c_home
     */
    @isTest
    public static void testInvalidEventId(){
        String eventId = 'invalidId';
        PageReference retValue;
        
        /**
         * pass page reference with invalid id
         */
        PageReference page = System.Page.c_detail;
        page.getParameters().put('id', eventId);
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assert(retValue.getUrl() == System.Page.c_home.getUrl());
    }
    
    /**
     * this test id to test response of valid id passed
     * if id valid/exists page will return null even event session each event not exits 
     */
    @isTest
    public static void testValidEventId(){
        PageReference retValue;
        /**
         * generate venue
         */
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * genereate event
         */
        My_Event__c[] me = test_data_factory.getEvents(1, v.Id);
        
        /**
         * pass page reference with valid id
         */
        PageReference page = System.Page.c_detail;
        page.getParameters().put('id', me[0].Id);
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assert(c.selectedSessions.size() == 0);
        System.assert(retValue == null);
    }
    
    /**
     * this test to validate that initial selected event session is false
     */
    @isTest
    public static void testInitialSelectedEventSession(){
        PageReference retValue;
        /**
         * generate venue
         */
        Venue__c v = test_data_factory.getVenue();
        
        /**
         * genereate event
         */
        My_Event__c[] me = test_data_factory.getEvents(1, v.Id);
        
        /**
         * generate event session
         */
        My_Event_Session__c[] mes = test_data_factory.getEventSessions(5, me[0].Id);
        
        /**
         * pass page reference with valid id
         */
        PageReference page = System.Page.c_detail;
        page.getParameters().put('id', me[0].Id);
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assert(c.selectedSessions.size() == mes.size());
        for(My_Event_Session__c m : mes){
            System.assertEquals(c.selectedSessions.get(m.Id), false);
        }
        System.assert(retValue == null);
    }
}