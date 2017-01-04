@isTest
public class test_schedule_report {
	@isTest
    public static void testSchedule(){
        Test.startTest();
        
        String cronName = 'report_'+System.now().getTime();
        
        schedule_report_to_director_marketing s = new schedule_report_to_director_marketing();
        System.schedule(cronName, '0 0 10 ? * 6', s);
        
        CronTrigger[] ct1 = [select State, NextFireTime, CronExpression from CronTrigger where CronJobDetail.Name = :cronName];
        
        System.assert(ct1.size() > 0);
        Datetime dt = System.now();
        String dayOfWeek = dt.format('EEE');
        if(dayOfWeek != 'Fri'){
            System.assertEquals('WAITING', ct1[0].State);
        }
        System.assertEquals('0 0 10 ? * 6', ct1[0].CronExpression);
        
        Test.stopTest();
    }
}