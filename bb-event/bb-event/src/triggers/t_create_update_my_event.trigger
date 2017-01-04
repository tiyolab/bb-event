/**
 * this trigger to handle updating status of event to In Progress (on Duty)
 * if inserted this trigger then starting apex sceduling to change status of event to In Progress at starting date of event 
 * and recalculate apex scheduling when starting date of event is updated
 * 
 * time cron = seconds minutes hours day_of_months months day_of_week optional_year
 */
trigger t_create_update_my_event on My_Event__c (after insert, after update) {
    
    for(My_Event__c me : Trigger.New){
        Datetime newTime = me.Start_Date__c.addSeconds(10);
        
        /*Integer second = me.Start_Date__c.second();
        Integer minute = me.Start_Date__c.second();
        Integer hour = me.Start_Date__c.second();
        Integer day = me.Start_Date__c.second();
        Integer month = me.Start_Date__c.second();
        Integer year = me.Start_Date__c.second();
        
        second += 10;
        if(second > 59){
            second -= 59;
            minute += 1;
        }
        
        if(minute > 59){
            minute = 0;
            hour += 1;
        }*/
        
        if(Trigger.isUpdate){
            if(me.Start_Date__c != Trigger.oldMap.get(me.Id).Start_Date__c && me.Status__c == 'On Going'){
                String cron_job_detail_name = 'sch_' + me.Id;
                for(CronTrigger ct : [select Id from CronTrigger  where CronJobDetail.Name = :cron_job_detail_name]){
                    System.abortJob(ct.Id);
                            
                    /*String timeCron = me.Start_Date__c.second() + ' '+ (me.Start_Date__c.minute()+1) +' '+ me.Start_Date__c.hour() +' ';
                    timeCron += me.Start_Date__c.day() + ' ';
                    timeCron += me.Start_Date__c.month() + ' ';
                    timeCron += '? ';
                    timeCron += me.Start_Date__c.year() + ' ';*/
                    String timeCron = newTime.second() + ' '+ newTime.minute() +' '+ newTime.hour() +' ';
                    timeCron += newTime.day() + ' ';
                    timeCron += newTime.month() + ' ';
                    timeCron += '? ';
                    timeCron += newTime.year() + ' ';
                            
                    schedule_change_event_status sse = new schedule_change_event_status(me.Id);
                    System.schedule('sch_'+me.Id, timeCron, sse); 
                }
            }   
        }
        
        if(Trigger.isInsert){
            /*String timeCron = me.Start_Date__c.second() + ' '+ (me.Start_Date__c.minute()+1) +' '+ me.Start_Date__c.hour() +' ';
            timeCron += me.Start_Date__c.day() + ' ';
            timeCron += me.Start_Date__c.month() + ' ';
            timeCron += '? ';
            timeCron += me.Start_Date__c.year() + ' ';*/
            String timeCron = newTime.second() + ' '+ newTime.minute() +' '+ newTime.hour() +' ';
                    timeCron += newTime.day() + ' ';
                    timeCron += newTime.month() + ' ';
                    timeCron += '? ';
                    timeCron += newTime.year() + ' ';
            
            schedule_change_event_status sse = new schedule_change_event_status(me.Id);
            System.schedule('sch_'+me.Id, timeCron, sse);
                
        }
    }
    
    
}