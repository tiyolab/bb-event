@isTest
public class test_register_event {
	
    /**
     * this test to validate if data(first name, last name and email) blank, registration will fail and return null and error message
     */
    @isTest
    public static void testBlankData(){
        PageReference retValue;
       	c_detail_controller c = new c_detail_controller();
        retValue = c.register();
        
        System.assertEquals(retValue, null);
        System.assertEquals(c_event_constants.msg_cannot_blank, ApexPages.getMessages()[0].getDetail());
    }
    
    /**
     * this test to validate if email invalid, registration will fail and return null and error message
     */
    @isTest
    public static void testInvalidEmail(){
        PageReference retValue;
       	c_detail_controller c = new c_detail_controller();
        c.firstName = 'my first name';
        c.lastName = 'my last name';
        c.email = 'tiyo@123';
        
        retValue = c.register();
        
        System.assertEquals(retValue, null);
        System.assertEquals(c_event_constants.msg_email_invalid, ApexPages.getMessages()[0].getDetail());
    }
    
    /**
     * this method to test that minimal a event session must selected,
     * if no event session selected, registration will fail and return null and error message
     */
    @isTest
    public static void testNonSelectedEventSession(){
        PageReference retValue;
        
        /**
         * setup data
         */
        PageReference page = setupData();
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        c.validate();
        c.email = 'tiyo.lab@gmail.com';
        c.firstName = 'my first name';
        c.lastName = 'my last name';
        retValue = c.register();
        
        Test.stopTest();
        
        System.assertEquals(retValue, null);
        System.assertEquals(c_event_constants.msg_must_select_min_a_event_session, ApexPages.getMessages()[0].getDetail());
    }
    
    /**
     * This is test to register with new contact
     */
    @isTest
    public static void testNewContact(){
        /**
         * setup data
         */
        PageReference page = setupData();
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        c.validate();
        c.email = 'tiyo.lab@gmail.com';
        c.firstName = 'my first name';
        c.lastName = 'my last name';
        /**
         * set selected event session to true for each event session
         */
        for(String mesId : c.selectedSessions.keySet()){
            c.selectedSessions.put(mesId, true);
        }
        c.register();
        
        Test.stopTest();
        
        Contact ctc = [select LastName, FirstName from Contact where Email = :c.email];
        System.assertEquals(c.firstName, ctc.FirstName);
        System.assertEquals(c.lastName, ctc.LastName);
    }
    
    /**
     * this is test to register with exists contact
     */
    @isTest
    public static void testAvailableContact(){
        /**
         * setup data
         */
        
        String tmpEmail = 'tiyo.lab@gmail.com';
        PageReference page = setupData();
        
        Contact ctc1 = new Contact(FirstName = '1st fname', LastName = '1st lname', Email = tmpEmail);
        insert ctc1;
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        c.validate();
        c.firstName = 'Muhammad';
        c.lastName = 'Sulistiyo';
        c.email = tmpEmail;
        /**
         * set selected event session to true for each event session
         */
        for(String mesId : c.selectedSessions.keySet()){
            c.selectedSessions.put(mesId, true);
        }
        c.register();
        
        Test.stopTest();
        
        Contact ctc = [select FirstName, LastName from Contact where email = :c.email];
        System.assertEquals(c.firstName, ctc.FirstName);
        System.assertEquals(c.lastName, ctc.LastName);
    }
    
    /**
     * this is test to register with failed error operation in contact
     */
    public static void testFailedContact(){
        
    }
    
    /**
     * This is test to register with new registrant
     */
    @isTest
    public static void testNewRegistrant(){
        AggregateResult arBefore = [select count(Id) count_ from Registrant__c];
        Integer numberRegistrantBefore = Integer.valueOf(arBefore.get('count_'));
        
        /**
         * setup data
         */
        PageReference page = setupData();
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        c.validate();
        c.firstName = 'Muhammad';
        c.lastName = 'Sulistiyo';
        c.email = 'tiyo.lab@gmail.com';
        
        /**
         * set selected event session to true for each event session
         */
        for(String mesId : c.selectedSessions.keySet()){
            c.selectedSessions.put(mesId, true);
        }
        c.register();
        
        Test.stopTest();
        
        AggregateResult arAfter = [select count(Id) count_ from Registrant__c];
        Integer numberRegistrantAfter = Integer.valueOf(arAfter.get('count_'));
        
        System.assertEquals(numberRegistrantAfter, numberRegistrantBefore + 1);
    }
    
    /**
     * This is test to register with exists registrant (ever regisration)
     */
    @isTest
    public static void testExistsRegistrant(){
        String tmpEmail = 'tiyo.lab@gmail.com';
        
        /**
         * setup data
         */
        PageReference page = setupData();
        
        /**
         * create contact
         */
        Contact ctc1 = new Contact(LastName = 'last_name', Email = tmpEmail);
        insert ctc1;
        
        /**
         * create registrant
         */
        insert new Registrant__c(Name = 'test', Contact__c = ctc1.Id, My_Event__c = page.getParameters().get('id'), Code__c = 'booking', Hash__c = 'hash');
        
        AggregateResult arBefore = [select count(Id) count_ from Registrant__c];
        Integer numberRegistrantBefore = Integer.valueOf(arBefore.get('count_'));
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        c.validate();
        c.firstName = 'Muhammad';
        c.lastName = 'Sulistiyo';
        c.email = tmpEmail;
        /**
         * set selected event session to true for each event session
         */
        for(String mesId : c.selectedSessions.keySet()){
            c.selectedSessions.put(mesId, true);
        }
        c.register();
        
        Test.stopTest();
        
        AggregateResult arAfter = [select count(Id) count_ from Registrant__c];
        Integer numberRegistrantAfter = Integer.valueOf(arAfter.get('count_'));
        
        System.assertEquals(numberRegistrantAfter, numberRegistrantBefore);
    }
    
    
   /**
     * this is test to register with failed error operation insert new registrant
     */
    public static void testFailedNewRegistrant(){
        
    }
    
    /**
     * this is test to register which registrant ever registration to event session and select/register it again
     */
    @isTest
    public static void testRegisterTryRegisterEventSessionAgain(){
        String tmpEmail = 'tiyo.lab@gmail.com';
        
        /**
         * setup data
         */
        PageReference page = setupData();
        
        /**
         * create contact
         */
        Contact ctc1 = new Contact(LastName = 'last_name', Email = tmpEmail);
        insert ctc1;
        
        /**
         * create registrant
         */
        Registrant__c r = new Registrant__c(Name = 'test', Contact__c = ctc1.Id, My_Event__c = page.getParameters().get('id'), Code__c = 'booking', Hash__c = 'hash');
        insert r;
        
        /**
         * insert new Registrant_Session__c
         */
        insert new Registrant_Session__c(My_Event_Session__c = page.getParameters().get('mes_id'), Registrant__c = r.Id);
        
        AggregateResult arBefore = [select count(Id) count_ from Registrant_Session__c];
        Integer numberRSBefore = Integer.valueOf(arBefore.get('count_'));
        
        Test.setCurrentPage(page);
        Test.startTest();
        
        c_detail_controller c = new c_detail_controller();
        c.validate();
        c.firstName = 'Muhammad';
        c.lastName = 'Sulistiyo';
        c.email = tmpEmail;
        /**
         * set selected event session to true for each event session
         */
        for(String mesId : c.selectedSessions.keySet()){
            c.selectedSessions.put(mesId, true);
        }
        c.register();
        
        Test.stopTest();
        
        AggregateResult arAfter = [select count(Id) count_ from Registrant_Session__c];
        Integer numberRSAfter = Integer.valueOf(arAfter.get('count_'));
        
        System.assertEquals(numberRSBefore + c.selectedSessions.size(), numberRSAfter);
    }
    
    private static PageReference setupData(){
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
        My_Event_Session__c[] mes = test_data_factory.getEventSessions(5, me[0].Id);
        
        /**
         * pass page reference with valid id
         */
        PageReference page = System.Page.c_detail;
        page.getParameters().put('id', me[0].Id);
        page.getParameters().put('mes_id', mes[0].Id);
        
        return page;
    }
}