public class vms_meeting_attendees_controller {
    public String meeting_id{set; get;}
    public String event_id{set; get;}
    
    public Meeting__c[] getAttendees(){
        return [select Guest__r.Email, Guest__r.FirstName, Guest__r.LastName, Event_Id__c from Meeting__c where Event_Id__c = :event_id and Id != :meeting_id];
    }
}