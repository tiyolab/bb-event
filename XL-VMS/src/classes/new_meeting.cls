public with sharing class new_meeting {
	@AuraEnabled
    public static List<Contact> searchContact(String searchValue){
        List<List<sObject>> result =  [find :searchValue+'*' in all fields returning Contact(id, FirstName, LastName, Email)];
        if(result.size() > 0){
            return (List<Contact>)result[0];
        }
        
        return null;
    }
    
    @AuraEnabled
    public static List<Room__c> searchRoom(){
        return [select Id, Name from Room__c where Status__c = 'Free'];
    }
    
    @AuraEnabled
    public static Map<String, object> createNewMeeting(String subject, String description, DateTime startMeeting, DateTime endMeeting, Contact[] attendees, String room){
        List<Contact> newContact = new List<Contact>();
        List<Contact> savedContact = new List<Contact>();
        List<Guest__c> guest = new List<Guest__c>();
        
        Savepoint sp = Database.setSavepoint();
        
        /**
         * filter between saved contact and todo saved contact (new contact as guest)
         */
        for(Contact c : attendees){
            String tmpId = String.valueOf(c.Id);
            if(tmpId == null || tmpId == ''){
                c.LastName = 'Guest';
                c.ID_Type__c = 'Government ID';
                newContact.add(c);
            }else{
                savedContact.add(c);
            }
        }
        
        /**
         * save new contact
         */
        try{
        	insert newContact;    
        }catch(DMLException e){
            Database.rollback(sp);
            return null;
        }
        
        
        /**
         * merge saved contact and saved new contact
         */
        savedContact.addAll(newContact);
        
        /**
         * save meeting data
         */
        String userEmail = UserInfo.getUserEmail();
        Contact[] host = [select Id from Contact where Email = :userEmail];
        
        Meeting__c meeting = null;
        
        System.debug('user email ' + userEmail);
        if(host.size() > 0){
            
            meeting = new Meeting__c(Host__c = host[0].Id, Subject__c = subject, Description__c = description, Start_Meeting__c = startMeeting, 
                                     End_Meeting__c = endMeeting, Room__c = room);
            
            try{
            	insert meeting;
            }catch(DMLException e){
            	Database.rollback(sp);
            	return null;    
            }
        }else{
            Database.rollback(sp);
            return null;
        }
        
        
        /**
         * create guest
         */
        for(Contact ct : savedContact){
            guest.add(new Guest__c(Contact__c = ct.Id, Meeting__c = meeting.Id));
        }
        
        try{
         	insert guest;   
        }catch(DMLException e){
			Database.rollback(sp);
            return null;            
        }
        
        User u = [select TimeZoneSidKey from User where Id =:UserInfo.getUserId()];
        Map<String, object> toReturn = new Map<String, object>();
        toReturn.put('timezone', u.TimeZoneSidKey);
        toReturn.put('meeting', meeting);
        toReturn.put('guests', guest);
        
        return toReturn;
    }
    
    @AuraEnabled
    public static ID getMeetingId(String eventId){
        Meeting__c m = [select Id from Meeting__c where Event_Id__c = :eventId];
        return m.Id;
    }
    
    @AuraEnabled
    public static Boolean sendEmailInvitation(Meeting__c meeting, Guest__c[] guests){
        /**
         * set calendar event to meeting data
         */
        try{
            update meeting;
        }catch(DMLException e){
            return false;
        }
        
        /**
         * send email invitation to guests
         */
        for(Guest__c g : guests){
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
            mail.setTargetObjectId(g.Contact__c);
            mail.setTemplateId('00X28000001G2ZQ');
            mail.setSenderDisplayName('XL Meeting Invitation');
            mail.setWhatId(g.Id);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
        
        return true;
    }
}