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
        List<Meeting__c> meetings = new List<Meeting__c>();
        
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
         * merge saved contact and new contact
         */
        savedContact.addAll(newContact);
        
        /**
         * save meeting data
         */
        String userEmail = UserInfo.getUserEmail();
        Contact[] host = [select Id from Contact where Email = :userEmail];
        
        if(host.size() > 0){
            for(Contact ct : savedContact){
                meetings.add(
                    new Meeting__c(
                        Host__c = host[0].Id, 
                        Guest__c = ct.Id,
                        Subject__c = subject, 
                        Description__c = description, 
                        Start_Meeting__c = startMeeting,
                        End_Meeting__c = endMeeting, 
                        Room__c = room));
            }
            
            try{
            	insert meetings;
            }catch(DMLException e){
            	Database.rollback(sp);
            	return null;    
            }
        }else{
            Database.rollback(sp);
            return null;
        }
        
        User u = [select TimeZoneSidKey from User where Id =:UserInfo.getUserId()];
        Map<String, object> toReturn = new Map<String, object>();
        toReturn.put('timezone', u.TimeZoneSidKey);
        toReturn.put('meetings', meetings);
        
        return toReturn;
    }
    
    @AuraEnabled
    public static ID getMeetingId(String eventId){
        Meeting__c m = [select Id from Meeting__c where Event_Id__c = :eventId];
        return m.Id;
    }
    
    @AuraEnabled
    public static Boolean sendEmailInvitation(Meeting__c[] meetings){
        List<Related_Access__c> access = new List<Related_Access__c>();
        List<Map<String, Object>> datas = new List<Map<String, Object>>();
        
        /**
         * get access item data
         */
        access = [select Access_Item__r.Id, Access_Item__r.Name from Related_Access__c where Room__c = :meetings[0].Room__c];
        
        /**
         * set calendar event id to meetings data
         */
        List<Meeting__c> ms = new List<Meeting__c>();
        try{
            for(Meeting__c m : meetings){
                ms.add(m);
            }
            update ms;
        }catch(DMLException e){
            return false;
        }
        
        /**
         * send email invitation to guests
         */
        for(Meeting__c g : meetings){
            System.debug(g);
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
            mail.setTargetObjectId(g.Guest__c);
            mail.setTemplateId('00X28000001G2ZQ');
            mail.setSenderDisplayName('XL Meeting Invitation');
            mail.setWhatId(g.Id);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
        
        return true;
    }
    
    private static Boolean sendToGallagher(Meeting__c[] meetings){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('uri');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(JSON.serialize(meetings));
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            return true;
        }
        return false;
    }
}