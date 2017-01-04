@isTest
public class test_schedule_change_event_status {
	/**
	 * test to ensure that apex scheduled job run when new event create
	 * this scheduled apex job will change event status to in progress when start time is reised
	 */
    @isTest
    public static void testInsert(){
      	/**
         * generate venue
         */
        Venue__c v = test_data_factory.getVenue();
        
        datetime tmpRegDeadline = datetime.now();
        datetime tmpStartTime = datetime.now().addSeconds(2);
        datetime tmpEndTime = tmpStartTime + 1;
        
        My_Event__c e = new My_Event__c(
                Availability_Status__c = 'Available',
                End_Date__c = tmpEndTime,
                Limit__c = 2,
                Name = 'event',
                Registration_Deadline__c = tmpRegDeadline,
                Start_Date__c = tmpStartTime,
                Venue__c = v.Id
            );
        
        Test.startTest();
        
        insert e;
        
		String cronName = 'sch_' + e.Id;        
        CronTrigger ct1 = [select State, NextFireTime, CronExpression from CronTrigger where CronJobDetail.Name = :cronName];
        
        System.assertEquals(tmpStartTime.addSeconds(10), ct1.NextFireTime);
        
        Test.stopTest();
        
        CronTrigger ct2 = [select State, NextFireTime, CronExpression from CronTrigger where CronJobDetail.Name = :cronName];
        My_Event__c me = [select Status__c from My_Event__c where Id = :e.Id];
        
        System.assertEquals('WAITING', ct1.State);
        System.assertEquals('In Progress', me.Status__c);
    }
}