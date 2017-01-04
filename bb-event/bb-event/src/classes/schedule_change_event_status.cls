global class schedule_change_event_status implements Schedulable{
	private String event_id;
    
    public schedule_change_event_status(String event_id){
        this.event_id = event_id;
    }
    
    global void execute(SchedulableContext sc){
        My_Event__c me = [select Status__c from My_Event__c where Id = :this.event_id];
        me.Status__c = 'In Progress';
        
        update me;
    }
}