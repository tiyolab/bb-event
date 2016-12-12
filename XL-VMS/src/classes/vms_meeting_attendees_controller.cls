public class vms_meeting_attendees_controller {
    public Id meetingId {set; get;}
    public Id me{set; get;}
    
    public Guest__c[] getAttendees(){
        return [select Contact__r.Email, Contact__r.FirstName,  Contact__r.LastName  from Guest__c where Meeting__c = :meetingId and Id != :me];
    }
}