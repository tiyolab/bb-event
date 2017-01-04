public class c_my_event_attachment_controller {
    public Map<String, Integer> event_size {set; get;}
    public Map<String, List<My_Event__c>> myEvents {set; get;}
    public String timeSend {set; get;}
    
    public PageReference init(){
        timeSend = System.now().format();
        
        List<My_Event__c> onGoingEvents = new List<My_Event__c>();
        List<My_Event__c> inProgressEvents = new List<My_Event__c>();
        Map<String, Integer> tmp_event_size = new Map<String, Integer>();
        
        for(My_Event__c me : [select 
                Id, 
                Name, 
                Start_Date__c,
                End_Date__c,
                Status__c,
                Venue__r.Name,
                (select 
                 Id, 
                 Name,
                 Start_Session__c,
                 End_session__c from My_Event_Sessions__r),
                (select
                 Contact__r.Name,
                 Contact__r.Email from Registrants__r)
                from My_Event__c
                              where Status__c = 'In Progress' or Status__c = 'On Going']){
                                 if(me.Status__c == 'In Progress'){
                                     inProgressEvents.add(me);
                                 }else if(me.Status__c == 'On Going'){
                                     onGoingEvents.add(me);
                                 }
                             }
        Map<String, List<My_Event__c>> result = new Map<String, List<My_Event__c>>();
        
        result.put('on Going Events', onGoingEvents);
        result.put('in Progress Events', inProgressEvents);
        
        tmp_event_size.put('on Going Events', onGoingEvents.size());
        tmp_event_size.put('in Progress Events', inProgressEvents.size());
        event_size = tmp_event_size; 
        
        myEvents = result;
        
        return null;
    }
    
}