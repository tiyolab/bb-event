@isTest
public class test_my_event {
	/**
     * this test prevent user to add null id or no id passed to my event page
     * if null/no id passed page will redirect to c_home
     */
    @isTest
    public static void testIdNull(){
        PageReference retValue;
        
        /**
         * pass page reference without id
         */
        PageReference page = System.Page.c_my_event;
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_my_event_controller c = new c_my_event_controller();
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
        PageReference page = System.Page.c_my_event;
        page.getParameters().put('id', '');
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_my_event_controller c = new c_my_event_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assert(retValue.getUrl() == System.Page.c_home.getUrl());
    }
    
    /**
     * This test is prevent access page by give invalid data (registrant id, code booking, hash token) from email
     */
    @isTest
    public static void testInvalidFromEmail(){
        PageReference retValue;
     	/**
         * pass page reference with invalid data id
         */
        PageReference page = System.Page.c_my_event;
        page.getParameters().put('id', generateUrl('registrantId', 'bookingCode', 'hash', 'delimeter'));
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_my_event_controller c = new c_my_event_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assert(retValue.getUrl() == System.Page.c_home.getUrl());
    }
    
    /**
     * this test is prevent access page by give invalid id from website
     */
    @isTest
    public static void testInvalidFromWebsite(){
     	PageReference retValue;
     	/**
         * pass page reference with invalid data id
         */
        PageReference page = System.Page.c_my_event;
        page.getParameters().put('id', 'registrantId');
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_my_event_controller c = new c_my_event_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assert(retValue.getUrl() == System.Page.c_home.getUrl());   
    }
    
    /**
     * test valid access from email for the first time (Completing regisration process)
     */
    @isTest
    public static void testValidFromEmail1(){
        PageReference retValue;
        
     	/**
     	 * setup data
     	 */
        Map<String, sObject> data = setupData();
        
     	/**
         * pass page reference with valid data id
         */
        PageReference page = System.Page.c_my_event;
        Registrant__c r = (Registrant__c)data.get('Registrant__c');
        page.getParameters().put('id', generateUrl(r.Id, r.Code__c, r.Hash__c, '@~@'));
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_my_event_controller c = new c_my_event_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assertEquals(true, c.showCompleteMessage);
        System.assertEquals(false, c.showIncompleteMessage);
    }
    
    /**
     * test valid access from email not for the firt time (registration process already completed)
     */
    @isTest
    public static void testValidFromEmail2(){
        PageReference retValue;
        
     	/**
     	 * setup data
     	 */
        Map<String, sObject> data = setupData();
        
     	/**
         * pass page reference with valid data id
         */
        PageReference page = System.Page.c_my_event;
        Registrant__c r = (Registrant__c)data.get('Registrant__c');
        page.getParameters().put('id', generateUrl(r.Id, r.Code__c, r.Hash__c, '@~@'));
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        /** first visit */
        c_my_event_controller c = new c_my_event_controller();
        c.validate();
        
        /** next visit */
        c_my_event_controller c2 = new c_my_event_controller();
        c2.validate();
        
        Test.stopTest();
        
        System.assertEquals(false, c2.showCompleteMessage);
        System.assertEquals(false, c2.showIncompleteMessage);
    }
    
    /**
     * test valid access from website and registration process is incomplete
     */
    @isTest
    public static void testValidFromWebsiteIncomplete(){
        PageReference retValue;
        
     	/**
     	 * setup data
     	 */
        Map<String, sObject> data = setupData();
        
     	/**
         * pass page reference with invalid data id
         */
        PageReference page = System.Page.c_my_event;
        Registrant__c r = (Registrant__c)data.get('Registrant__c');
        page.getParameters().put('id', r.Id);
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_my_event_controller c = new c_my_event_controller();
        retValue = c.validate();
        
        Test.stopTest();
        
        System.assertEquals(false, c.showCompleteMessage);
        System.assertEquals(true, c.showIncompleteMessage);
    }
    
    /**
     * test valid access from website and registration process already completed
     */
    @isTest
    public static void testValidFromWebsiteCompleted(){
        PageReference retValue;
        
     	/**
     	 * setup data
     	 */
        Map<String, sObject> data = setupData();
        
     	/**
         * pass page reference with valid data id
         */
        PageReference page = System.Page.c_my_event;
        PageReference page2 = System.Page.c_my_event;
        
        Registrant__c r = (Registrant__c)data.get('Registrant__c');
        
        page.getParameters().put('id', generateUrl(r.Id, r.Code__c, r.Hash__c, '@~@'));
        page2.getParameters().put('id', r.Id);
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        /** first visit */
        c_my_event_controller c = new c_my_event_controller();
        c.validate();
        
        /** next visit */
        Test.setCurrentPage(page2);
        c_my_event_controller c2 = new c_my_event_controller();
        c2.validate();
        
        Test.stopTest();
        
        System.assertEquals(false, c2.showCompleteMessage);
        System.assertEquals(false, c2.showIncompleteMessage);
    }
    
    private static String generateUrl(String registrantId, String bookingCode, String hash, String delimeter ){
        return EncodingUtil.base64Encode(Blob.valueOf(hash + delimeter + registrantId + delimeter + bookingCode));
    }
    
    private static Map<String, sObject> setupData(){
        /**
         * VALIDATE PROCESS
         * ======================================
         */
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
        My_Event_Session__c[] mes = test_data_factory.getEventSessions(1, me[0].Id);
        
        /**
         * generate contact
         */
        Contact c = new Contact(LastName = c_event_constants.contact_last_name, Email = 'tiyo.lab@gmail.com');
        insert c;
        
        /**
         * generate registrant
         */
        Registrant__c r = new Registrant__c(Name = 'rname', Contact__c = c.Id, My_Event__c = me[0].Id, Code__c = 'code123', Hash__c = 'hash123');
        insert r;
        
        /**
         * generate registrant session
         */
        List<Registrant_Session__c> lrs = new List<Registrant_Session__c>();
        for(My_Event_Session__c tmpMes : mes){
            lrs.add(new Registrant_Session__c(My_Event_Session__c = tmpMes.Id, Registrant__c = r.Id));
        }
        insert lrs;
        
        Map<String, sObject> rValue = new Map<String, sObject>();
        rValue.put('My_Event__c', me[0]);
        rValue.put('My_Event_Session__c', mes[0]);
        rValue.put('Contact', c);
        rValue.put('Registrant__c', r);
        rValue.put('Registrant_Session__c', lrs[0]);
        
        return rValue;
    }
    
    @isTest
    public static void testSuccessCallout(){
        /**
     	 * setup data
     	 */
        PageReference retValue;
        
     	/**
     	 * setup data
     	 */
        Map<String, sObject> data = setupData();
        
     	/**
         * pass page reference with valid data id
         */
        PageReference page = System.Page.c_my_event;
        PageReference page2 = System.Page.c_my_event;
        
        Registrant__c r = (Registrant__c)data.get('Registrant__c');
        
        page.getParameters().put('id', generateUrl(r.Id, r.Code__c, r.Hash__c, '@~@'));
        page2.getParameters().put('id', r.Id);
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_my_event_controller c = new c_my_event_controller();
        c.validate();
        
        //invoke the continuation
        Continuation con = (Continuation) c.requestHotel();
        
        //verify that continuation has the proper request
        Map<String, HttpRequest> request = con.getRequests();
        System.assert(request.size() == 1);
        System.assert(request.get(c.requestLabel) != null);
        
        Test.setContinuationResponse(c.requestLabel, c_http_mock.respond());
        Test.invokeContinuationMethod(c, con);
        
        Map<String, c_my_event_controller.Hotel> hotel = c.hotel;
        System.debug('hotel = ' + hotel);
        
        System.assertEquals('Chow Kit', hotel.get('94248').neighborhood.name);
        System.assertEquals('Kuala Lumpur', hotel.get('93618').neighborhood.city);
        System.assertEquals('USD', hotel.get('93618').currencyCode);
        System.assertEquals(2, c.hotel.size());
    }
}