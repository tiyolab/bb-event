@isTest
public class test_t_create_update_my_event {
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
        datetime tmpStartTime = datetime.now().addSeconds(10);
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
        insert e;
        
        /*String timeCron = tmpStartTime.second() + ' '+ (tmpStartTime.minute()+1) +' '+ tmpStartTime.hour() +' ';
        timeCron += tmpStartTime.day() + ' ';
        timeCron += tmpStartTime.month() + ' ';
        timeCron += '? ';
        timeCron += tmpStartTime.year() + ' ';*/
        Datetime newTime = tmpStartTime.addSeconds(10);
        String timeCron = newTime.second() + ' '+ newTime.minute() +' '+ newTime.hour() +' ';
        timeCron += newTime.day() + ' ';
        timeCron += newTime.month() + ' ';
        timeCron += '? ';
        timeCron += newTime.year() + ' ';
	
		String cronName = 'sch_' + e.Id;        
        CronTrigger ct = [select CronExpression from CronTrigger where CronJobDetail.Name = :cronName];
        System.assertEquals(true, ct.CronExpression.replace(' ', '').equals(timeCron.replace(' ', '')));
    }
    
    @isTest
    public static void testUpdate(){
        /**
         * generate venue
         */
        Venue__c v = test_data_factory.getVenue();
        
        datetime tmpRegDeadline = datetime.now();
        datetime tmpStartTime = datetime.now().addSeconds(10);
        datetime tmpNewStartTime = datetime.now().addMinutes(10).addSeconds(10);
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
        insert e;
        
        e.Start_Date__c  = tmpNewStartTime;
        update e;
        
        /*String timeCron = tmpNewStartTime.second() + ' '+ (tmpNewStartTime.minute()+1) +' '+ tmpNewStartTime.hour() +' ';
        timeCron += tmpNewStartTime.day() + ' ';
        timeCron += tmpNewStartTime.month() + ' ';
        timeCron += '? ';
        timeCron += tmpNewStartTime.year() + ' ';*/
        Datetime newTime = tmpNewStartTime.addSeconds(10);
        String timeCron = newTime.second() + ' '+ newTime.minute() +' '+ newTime.hour() +' ';
        timeCron += newTime.day() + ' ';
        timeCron += newTime.month() + ' ';
        timeCron += '? ';
        timeCron += newTime.year() + ' ';
	
		String cronName = 'sch_' + e.Id;        
        CronTrigger ct = [select CronExpression from CronTrigger where CronJobDetail.Name = :cronName];
        System.assertEquals(true, ct.CronExpression.replace(' ', '').equals(timeCron.replace(' ', '')));
    }
}