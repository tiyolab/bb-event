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
        
        /**
         * data send to gallgher
         */
        List<Map<String, Object>> datas = new List<Map<String, Object>>();
        List<Map<String, Object>> relatedAccesses = new List<Map<String, Object>>();
        
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
        
        /**
         * get access item data
         */
        for(Related_Access__c r : [select Id, Access_Item__c, Room__c from Related_Access__c where Room__c = :room]){
            Map<String, Object> tmp = new Map<String, Object>();
            tmp.put('id', r.Id);
            tmp.put('accessItem', r.Access_Item__c);
            tmp.put('room', r.Room__c);
            
            relatedAccesses.add(tmp);
        }
        
        /**
         * get meeting data send to gallagher
         */
        List<Meeting__c> meetingDatas = [select 
                                         Id, 
                                         Start_Meeting__c, 
                                         End_Meeting__c, 
                                         Subject__c, 
                                         Description__c, 
                                         Host__c, 
                                         Guest__c,
                                         Guest__r.ID_Number__c, 
                                         Guest__r.MailingStreet, 
                                         Guest__r.MailingCity, 
                                         Guest__r.MailingState, 
                                         Guest__r.MailingCountry, 
                                         Room__c
                                         from Meeting__c where Id in :meetings
                                        ];
        for(Meeting__c m : meetingDatas){
            Map<String, Object> maps = new Map<String, Object>();
            maps.put('visitorId', m.Id);
            maps.put('fromdate', m.Start_Meeting__c);
            maps.put('todate', m.End_Meeting__c);
            maps.put('subject', m.Subject__c);
            maps.put('description', m.Description__c);
            maps.put('host', m.Host__c);
            maps.put('roomnumber', m.Room__c);
            maps.put('idnumber', m.Guest__r.ID_Number__c);
            maps.put('address', m.Guest__r.MailingStreet +', '+ m.Guest__r.MailingCity +', '+ m.Guest__r.MailingState +', '+ m.Guest__r.MailingCountry);
            maps.put('access', relatedAccesses);
            
            datas.add(maps);
        }
        
        System.debug(JSON.serialize(datas));
        sendToGallagher(JSON.serialize(datas));
        
        /**
         * get host timezone
         */
        User u = [select TimeZoneSidKey from User where Id =:UserInfo.getUserId()];
        
        Map<String, object> toReturn = new Map<String, object>();
        toReturn.put('timezone', u.TimeZoneSidKey);
        toReturn.put('meetings', meetings);
        toReturn.put('sendGallagher', JSON.serialize(datas));
        
        return toReturn;
    }
    
    @AuraEnabled
    public static ID getMeetingId(String eventId){
        Meeting__c m = [select Id from Meeting__c where Event_Id__c = :eventId];
        return m.Id;
    }
    
    @AuraEnabled
    public static Boolean sendEmailInvitation(Meeting__c[] meetings){
        System.debug(meetings);
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
        System.debug('true');
        return true;
    }
    
    @future(callout=true)
    private static void sendToGallagher(String meetings){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://182.253.1.69:9080/maximo/rest/os/VMSMEETING/?_format=json&_lid=wilson&_lpwd=wilson');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(meetings);
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        if(response.getStatusCode() == 200){
            System.debug('rest success');
            //return true;
        }
        //return false;
    }
}