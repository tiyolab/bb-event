public with sharing class detail_meeting {
	@AuraEnabled
    public static List<Meeting__c> getMeeting(String eventId){
        return [select Id,
               Event_Id__c,
               Subject__c,
               Description__c,
               Host__c,
               Start_Meeting__c,
               End_Meeting__c,
               Guest__c,
               Guest__r.FirstName,
               Guest__r.LastName,
               Guest__r.Email,
               Room__r.Name
               from Meeting__c where Event_Id__c = :eventId];
    }
    
    @AuraEnabled
    public static Boolean deleteMeeting(String eventId){
        Meeting__c[] m = [select Id from Meeting__c where Event_Id__c = :eventId];
        delete m;
        
        return true;
    }
}