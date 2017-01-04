@isTest
public class test_data_factory {
    public static Venue__c getVenue(){
        Venue__c v = new Venue__c(
            Address__c = 'address',
            Capacity__c = 100,
            City__c = 'city',
            Country__c = 'country',
            Name = 'name',
            Phone__c = 'phone',
            State_Province__c = 'state/province'
        );
        insert v;
        
        return v;
    }
    
    public static List<My_Event__c> getEvents(Integer count, String venueId){
        List<My_Event__c> events = new List<My_Event__c>();
        datetime tmpRegDeadline = datetime.now() + 1;
        datetime tmpStartDate = tmpRegDeadline + 1;
        datetime tmpEndDate = tmpStartDate + 1;
        
        for(Integer i = 0; i < count; i++){
            events.add(new My_Event__c(
                Availability_Status__c = 'Available',
                End_Date__c = tmpEndDate,
                Limit__c = 100,
                Name = 'event ' + i,
                Registration_Deadline__c = tmpRegDeadline,
                Start_Date__c = tmpStartDate,
                Venue__c = venueId
            ));
        }
        
        insert events;
        
        return events;
    }
    
    public static List<My_Event__c> getEvents(Integer count, String venueId, Integer eventLimit){
        List<My_Event__c> events = new List<My_Event__c>();
        datetime tmpRegDeadline = datetime.now() + 1;
        datetime tmpStartDate = tmpRegDeadline + 1;
        datetime tmpEndDate = tmpStartDate + 1;
        
        for(Integer i = 0; i < count; i++){
            events.add(new My_Event__c(
                Availability_Status__c = 'Available',
                End_Date__c = tmpEndDate,
                Limit__c = eventLimit,
                Name = 'event ' + i,
                Registration_Deadline__c = tmpRegDeadline,
                Start_Date__c = tmpStartDate,
                Venue__c = venueId
            ));
        }
        
        insert events;
        
        return events;
    }
   
    public static List<My_Event_Session__c> getEventSessions(Integer count, String eventId){
        My_Event__c me = [select Start_Date__c from My_Event__c where Id = :eventId];
        datetime startSession = me.Start_Date__c;
        datetime endSession = startSession;
        List<My_Event_Session__c> eventSessions = new List<My_Event_Session__c>();
        
        for(Integer i = 0; i < count; i++){
            eventSessions.add(new My_Event_Session__c(
                Available_Sit__c = 1,
                End_Session__c = endSession,
                Limit__c = 1,
                My_Event__c = eventId,
                Name = 'session '+i,
                Start_Session__c = startSession
            ));
        }
        
        insert eventSessions;
        return eventSessions;
    }
    
    public static List<My_Event_Session__c> getEventSessions(Integer count, My_Event__c me){
        datetime startSession = me.Start_Date__c;
        datetime endSession = startSession;
        List<My_Event_Session__c> eventSessions = new List<My_Event_Session__c>();
        
        for(Integer i = 0; i < count; i++){
            eventSessions.add(new My_Event_Session__c(
                Available_Sit__c = 1,
                End_Session__c = endSession,
                Limit__c = me.Limit__c,
                My_Event__c = me.Id,
                Name = 'session '+i,
                Start_Session__c = startSession
            ));
        }
        
        insert eventSessions;
        return eventSessions;
    }
    
    public static void sleep(integer milliseconds){
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do{
            timeDiff = System.now().getTime() - firstTime.getTime();
        }while(timeDiff <= milliseconds);      
    }
    
    public static List<Contact> getContacts(Integer count){
        List<Contact> c = new List<Contact>();
        for(Integer i = 0; i < count; i++){
            c.add(new Contact(LastName = 'last_name '+i, Email = 'test'+i+'@mail.com'));
        }
        
        insert c;
        return c;
    }
    
    public static List<Registrant__c> getRegistrants(Contact c, List<My_Event__c> events){
        List<Registrant__c> registrants = new List<Registrant__c>();
        Integer i = 0;
        for(My_Event__c me : events){
            System.debug(me.Id);
            registrants.add(new Registrant__c(Name = 'test '+i, Contact__c = c.Id, My_Event__c = me.Id, Code__c = 'booking'+ i, Hash__c = 'hash'));
            i++;
        }
        insert registrants;
        return registrants;
    }
    
    public static List<Registrant__c> getRegistrants(Integer count, Contact c, List<My_Event__c> events){
        List<Registrant__c> registrants = new List<Registrant__c>();
        Integer i = 0;
        Integer j = 0;
        for(My_Event__c me : events){
            for(j=0; j < count; j++){
            	registrants.add(new Registrant__c(Name = 'test '+i+'_'+ j, Contact__c = c.Id, My_Event__c = me.Id, Code__c = 'booking'+ i +'_'+ j, Hash__c = 'hash'));    
            }
            i++;
        }
        insert registrants;
        return registrants;
    }
    
    public static List<Registrant_Session__c> getRegistrantSessions(List<Registrant__c> registrants, List<My_Event_Session__c> mes){
        List<Registrant_Session__c> rs = new List<Registrant_Session__c>();
        Integer i = 0;
        for(Registrant__c r : registrants){
            for(My_Event_Session__c nmes : mes){
            	rs.add(new Registrant_Session__c(My_Event_Session__c = nmes.Id, Registrant__c = r.Id));
            }
        }
        insert rs;
        return rs;
    }
    
    public static List<Registrant_Session__c> getMultipleRegistrantSessionsOfAMES(List<Registrant__c> registrants, My_Event_Session__c mes){
        List<Registrant_Session__c> rs = new List<Registrant_Session__c>();
        Integer i = 0;
        for(Registrant__c r : registrants){
            rs.add(new Registrant_Session__c(My_Event_Session__c = mes.Id, Registrant__c = r.Id));   
            /*for(Integer j = 0; j < mes.Available_Sit__c; j++){
             	rs.add(new Registrant_Session__c(My_Event_Session__c = mes.Id, Registrant__c = r.Id));   
            }*/
            i++;
        }
        insert rs;
        return rs;
    }
    	
}