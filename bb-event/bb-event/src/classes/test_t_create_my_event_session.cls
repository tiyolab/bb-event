@isTest
public class test_t_create_my_event_session {
	/**
	 * this test to make sure that when initial create available sit is equal to limit
	 * scenario :
	 * create new my_event_session__c,
	 * when created available_sit initial equal to limit
	 */
    @isTest
    public static void test_one_insert_one(){
        /**
         * construct data needed
         */
        Venue__c v = test_data_factory.getVenue();
        My_Event__c[] me = test_data_factory.getEvents(1, v.Id);
        
        My_Event_Session__c mes = new My_Event_Session__c(Name='mes1', Start_Session__c = me[0].Start_Date__c, End_Session__c = me[0].End_Date__c, Limit__c = 10, My_Event__c = me[0].Id);
        
        Test.startTest();
        
        Database.SaveResult result = Database.insert(mes);
            
        Test.stopTest();
        
        My_Event_Session__c newMes = [select Available_Sit__c from My_Event_Session__c where Id = :mes.Id];
        System.assertEquals(mes.Limit__c, newMes.Available_Sit__c);
    }
    
    /**
     * this test with scenario
     * new limit change to higher (NL > OL) and available sit in not 0 (US < OL)
     * 
     * single data
     */
    @isTest
    public static void test_Nl_h_Ol_Us_l_Ol(){
        Venue__c v = test_data_factory.getVenue();
        My_Event__c[] me = test_data_factory.getEvents(1, v.Id);
        
        /**
         * create my event session which has limit = 10, and available sit = 10
         */
        My_Event_Session__c mes = new My_Event_Session__c(Name='mes1', Start_Session__c = me[0].Start_Date__c, End_Session__c = me[0].End_Date__c, Limit__c = 10, My_Event__c = me[0].Id);
        insert mes;
        
        /**
         * image that 5 registrant register to this session so available sit become to 5
         */
        mes.Available_Sit__c = 5;
        update mes;
        
        /**
         * change limit to greater to 15
         */
        mes.Limit__c = 15;
        update mes;
        
        My_Event_Session__c mes2 = [select Limit__c, Available_Sit__c from My_Event_Session__c where Id = :mes.Id];
        System.assertEquals(15, mes2.Limit__c);
        System.assertEquals(10, mes2.Available_Sit__c);
    }
    
	/**
     * this test with scenario
     * new limit change to higher (NL > OL) and available sit is 0 (US = OL)
     * 
     * single data
     */
    @isTest
    public static void test_Nl_h_Ol_Us_e_Ol(){
        Venue__c v = test_data_factory.getVenue();
        My_Event__c[] me = test_data_factory.getEvents(1, v.Id);
        
        /**
         * create my event session which has limit = 10, and available sit = 10
         */
        My_Event_Session__c mes = new My_Event_Session__c(Name='mes1', Start_Session__c = me[0].Start_Date__c, End_Session__c = me[0].End_Date__c, Limit__c = 10, My_Event__c = me[0].Id);
        insert mes;
        
        /**
         * image that 10 registrant register to this session so no available sit
         */
        mes.Available_Sit__c = 0;
        update mes;
        
        /**
         * change limit to greater to 15
         */
        mes.Limit__c = 15;
        update mes;
        
        My_Event_Session__c mes2 = [select Limit__c, Available_Sit__c from My_Event_Session__c where Id = :mes.Id];
        System.assertEquals(15, mes2.Limit__c);
        System.assertEquals(5, mes2.Available_Sit__c);
    }
    
    /**
     * this test with scenario
     * new limit change to lower (NL < OL) and available sit is not 0 (US < OL) and new limit higer than used sit (NL >= US)
     * 
     * single data
     */
    @isTest
    public static void test_NL_l_OL_US_l_OL_NL_h_US(){
        Venue__c v = test_data_factory.getVenue();
        My_Event__c[] me = test_data_factory.getEvents(1, v.Id);
        
        /**
         * create my event session which has limit = 10, and available sit = 10
         */
        My_Event_Session__c mes = new My_Event_Session__c(Name='mes1', Start_Session__c = me[0].Start_Date__c, End_Session__c = me[0].End_Date__c, Limit__c = 10, My_Event__c = me[0].Id);
        insert mes;
        
        /**
         * image that 5 registrant register to this session so no available sit
         */
        mes.Available_Sit__c = 5;
        update mes;
        
        /**
         * change limit to lower to 8
         */
        mes.Limit__c = 8;
        update mes;
        
        My_Event_Session__c mes2 = [select Limit__c, Available_Sit__c from My_Event_Session__c where Id = :mes.Id];
        System.assertEquals(8, mes2.Limit__c);
        System.assertEquals(3, mes2.Available_Sit__c);
    }
    
    /**
     * this test with scenario
     * new limit change to lower (NL < OL) and available sit is not 0 (US < OL) and new limit higer than used sit (NL < US)
     * 
     * single data
     */
    @isTest
    public static void test_NL_l_OL_US_l_OL_NL_l_US(){
        Venue__c v = test_data_factory.getVenue();
        My_Event__c[] me = test_data_factory.getEvents(1, v.Id);
        
        /**
         * create my event session which has limit = 10, and available sit = 10
         */
        My_Event_Session__c mes = new My_Event_Session__c(Name='mes1', Start_Session__c = me[0].Start_Date__c, End_Session__c = me[0].End_Date__c, Limit__c = 10, My_Event__c = me[0].Id);
        insert mes;
        
        /**
         * image that 6 registrant register to this session so now available sit
         */
        mes.Available_Sit__c = 4;
        update mes;
        
        /**
         * change limit to lower to 4
         */
        mes.Limit__c = 4;
        
        try{
        	Database.SaveResult result = Database.update(mes);    
        }catch(DMLException e){
            System.assertEquals(c_event_constants.msg_unable_change_limit, e.getDmlMessage(0));
        }
        
        My_Event_Session__c mes2 = [select Limit__c, Available_Sit__c from My_Event_Session__c where Id = :mes.Id];
        System.assertEquals(10, mes2.Limit__c);
        System.assertEquals(4, mes2.Available_Sit__c);
    }
    
    /**
     * this test with scenario
     * new limit change to lower (NL < OL) and available sit is 0 (US = OL)
     * 
     * single data
     */
    @isTest
    public static void test_NL_l_OL_US_e_OL(){
        Venue__c v = test_data_factory.getVenue();
        My_Event__c[] me = test_data_factory.getEvents(1, v.Id);
        
        /**
         * create my event session which has limit = 10, and available sit = 10
         */
        My_Event_Session__c mes = new My_Event_Session__c(Name='mes1', Start_Session__c = me[0].Start_Date__c, End_Session__c = me[0].End_Date__c, Limit__c = 10, My_Event__c = me[0].Id);
        insert mes;
        
        /**
         * image that 10 registrant register to this session so now available sit
         */
        mes.Available_Sit__c = 0;
        update mes;
        
        /**
         * change limit to lower to 4
         */
        mes.Limit__c = 4;
        
        try{
        	Database.SaveResult result = Database.update(mes);    
        }catch(DMLException e){
            System.assertEquals(c_event_constants.msg_unable_change_limit, e.getDmlMessage(0));
        }
        
        My_Event_Session__c mes2 = [select Limit__c, Available_Sit__c from My_Event_Session__c where Id = :mes.Id];
        System.assertEquals(10, mes2.Limit__c);
        System.assertEquals(0, mes2.Available_Sit__c);
    }
}