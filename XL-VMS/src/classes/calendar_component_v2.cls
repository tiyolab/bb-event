global with sharing class calendar_component_v2 {
    @AuraEnabled  
    public static List<String> synchronizeWithCalendar(String sdata){
        Map<String, Object> dataJSON = (Map<String, Object>)JSON.deserializeUntyped(sdata);
        
        /**
         * generate temporary meeting object
         * data = dataNewMeeting = Map<Event_Id__c, List<Meeting__c>>
         * dataEmailMeeting = Map<Event_Id__c, Map<Email, Meeting__c>>
         * mapEmail = Map<Event_Id__c, List<email>>
         * mapRoom = Map<Event_Id__c, Room name>
         */
        Map<String, List<Meeting__c>> data = new Map<String, List<Meeting__c>>();
        Map<String, List<Meeting__c>> dataNewMeeting = new Map<String, List<Meeting__c>>();
        Map<String, Map<String, Meeting__c>> dataEmailMeeting = new Map<String, Map<String, Meeting__c>>();
        Map<String, List<String>> mapEmail = new Map<String, List<String>>();
        Map<String, String> mapRoom = new Map<String, String>();
        
        for(String eventId : dataJSON.keySet()){
            String roomName = '';
            List<Meeting__c> tmpListMeeting = new List<Meeting__c>();
            Map<String, Meeting__c> tmpMapMeeting = new Map<String, Meeting__c>();
            List<String> tmpListEmail = new List<String>();
            List<Object> jsonListMeeting = (List<Object>)dataJSON.get(eventId);
            
            for(Object jlm : jsonListMeeting){
                Map<String, Object> meeting = (Map<String, Object>)jlm;
                Meeting__c tmpMeeting = new Meeting__c(
                    Status__c = String.valueOf(meeting.get('Status__c')),
                    Subject__c = String.valueOf(meeting.get('Subject__c')),
                    Description__c = String.valueOf(meeting.get('Description__c')),
                    Start_Meeting__c = Datetime.valueOfGmt(String.valueOf(meeting.get('Start_Meeting__c')).replace('T', ' ')),
                    End_Meeting__c = Datetime.valueOfGmt(String.valueOf(meeting.get('End_Meeting__c')).replace('T', ' ')),
                    Event_Id__c = String.valueOf(meeting.get('Event_Id__c')),
                    Last_Updated_At__c = String.valueOf(meeting.get('Last_Updated_At__c')));
                
                roomName = String.valueOf(meeting.get('Room__c'));
            	tmpListMeeting.add(tmpMeeting);
                tmpMapMeeting.put(String.valueOf(meeting.get('Guest__r.Email')), tmpMeeting);
                tmpListEmail.add(String.valueOf(meeting.get('Guest__r.Email')));
            }
            
            mapRoom.put(eventId, roomName);
            data.put(eventId, tmpListMeeting);
            dataNewMeeting.put(eventId, tmpListMeeting);
            dataEmailMeeting.put(eventId, tmpMapMeeting);
            mapEmail.put(eventId, tmpListEmail);
        }
        
        System.debug('size 1 = ' + dataNewMeeting.size());
        
        /**
         * emailMeeting = Map<Event_Id__c, Map<email, Meeting__c>>
         * oldData = Map<Event_Id__c, List<Meeting__c>> 
         * eventIdChangedData = Set<Event_Id__c>
         */
        Map<String, Map<String, Meeting__c>> emailMeeting = new Map<String, Map<String, Meeting__c>>();
        Map<String, List<Meeting__c>> oldData = new Map<String, List<Meeting__c>>();
        Set<String> eventIdChangedData = new Set<String>();
        
        List<Meeting__c> toDelete = new List<Meeting__c>();
        List<Meeting__c> toCreate = new List<Meeting__c>();
        List<Meeting__c> toUpdate = new List<Meeting__c>();
        List<String> toCreateEmail = new List<String>();
        
        /**
         * get saved meeting datas based on meeting event id from google calendar
         */
        
        String userEmail = UserInfo.getUserEmail();
        Contact[] host = [select Id from Contact where Email = :userEmail];
        
        for(Meeting__c m : [select 
                            Last_updated_At__c, 
                            Id, 
                            Event_Id__c, 
                            Guest__r.Email, 
                            Guest__c, 
                            Host__c, 
                            Room__c 
                            from Meeting__c where Host__c = :host[0].Id]){
                            //from Meeting__c where Event_Id__c in :data.keySet()]){
            /**
             * if oldData which have key eventId still null constract it
             */                    
            if(oldData.get(m.Event_Id__c) == null){
                oldData.put(m.Event_Id__c, new List<Meeting__c>());
            }
                                
			/**
			 * save saved meeting to oldData
			 */
            oldData.get(m.Event_Id__c).add(m);

			/**
             * if emailMeeting which have key eventId still null constract it
             */                    
			if(emailMeeting.get(m.Event_Id__c) == null){
                emailMeeting.put(m.Event_Id__c, new Map<String, Meeting__c>());
            }

            emailMeeting.get(m.Event_Id__c).put(m.Guest__r.Email, m);
			
			/**
			 * if Last_Updated_At__c time of data from google calendar different with data meeting in SFDC, so there is changed
			 */
			if(data.get(m.Event_Id__c) == null){    
            	toDelete.add(m);
            }else if(m.Last_Updated_At__c != data.get(m.Event_Id__c)[0].Last_Updated_At__c){
                eventIdChangedData.add(m.Event_Id__c);
            }
			
			dataNewMeeting.remove(m.Event_Id__c);
        }
        System.debug('size 2 = ' + dataNewMeeting.size());
        
        /**
         * created new meeting based on new event created in google calendar
         */
        System.debug('test ' + dataNewMeeting);
        System.debug('rooms ' + mapRoom.values());
        
        Map<String, Id> tmpRoom = new Map<String, Id>();
        for(Room__c r : [select Name, Id from Room__c where Name in :mapRoom.values()]){
            tmpRoom.put(r.Name, r.Id);
            System.debug('inside ' + r.Name);
        }                             
        
        for(String eventId : dataNewMeeting.keySet()){
            /**
             * make sure that room available in system (valid)
             */
            if(mapRoom.get(eventId) != null && mapRoom.get(eventId) != ''){
             	Integer i = 0;
                for(Meeting__c m : (List<Meeting__c>)dataNewMeeting.get(eventId)){
                    toCreateEmail.add(mapEmail.get(eventId).get(i));
                    toCreate.add(new Meeting__c(
                        Description__c = m.Description__c,
                        End_Meeting__c = m.End_Meeting__c,
                        Event_Id__c = m.Event_Id__c,
                        Host__c = host[0].Id,
                        Last_Updated_At__c = m.Last_Updated_At__c,
                        Room__c = tmpRoom.get(mapRoom.get(eventId)),
                        Start_Meeting__c = m.Start_Meeting__c,
                        Status__c = m.Status__c,
                        Subject__c = m.Subject__c
                    ));
                    
                    i++;
                }   
            }
        }

		/**
		 * updated event in google calendar
		 * it could be add new guest or delete guest which mean add or delete meeting object in SFDC
		 */        
        for(String eventId : eventIdChangedData){
            /**
             * filter to create new meeting
             */
            Integer i = 0;
            for(Meeting__c m : (List<Meeting__c>)data.get(eventId)){
                if(emailMeeting.get(eventId).get(mapEmail.get(eventId).get(i)) == null){
                    toCreateEmail.add(mapEmail.get(eventId).get(i));
                    toCreate.add(new Meeting__c(
                        Description__c = m.Description__c,
                        End_Meeting__c = m.End_Meeting__c,
                        Event_Id__c = m.Event_Id__c,
                        Host__c = oldData.get(eventId)[0].Host__c,
                        Last_Updated_At__c = m.Last_Updated_At__c,
                        Room__c = oldData.get(eventId)[0].Room__c,
                        Start_Meeting__c = m.Start_Meeting__c,
                        Status__c = m.Status__c,
                        Subject__c = m.Subject__c
                    ));
                }
                
                i++;
            }
            
            /**
             * filter to delete and update meeting
             */
            for(Meeting__c m : oldData.get(eventId)){
                if(dataEmailMeeting.get(eventId).get(m.Guest__r.Email) == null){
                    toDelete.add(m);
                }else{
                    toUpdate.add(new Meeting__c(
                        Id = m.Id,
                        Description__c = data.get(EventId)[0].Description__c,
                        End_Meeting__c = data.get(EventId)[0].End_Meeting__c,
                        Event_Id__c = data.get(EventId)[0].Event_Id__c,
                        Guest__c = m.Guest__c,
                        Host__c = m.Host__c,
                        Last_Updated_At__c = data.get(EventId)[0].Last_Updated_At__c,
                        Room__c = m.Room__c,
                        Start_Meeting__c = data.get(EventId)[0].Start_Meeting__c,
                        Status__c = data.get(EventId)[0].Status__c,
                        Subject__c = data.get(EventId)[0].Subject__c
                    ));
                }
            }
        }
        
        System.debug('to create');
        System.debug(toCreate);
        List<String> paramsSendToGallagher = createSynchronizedMeeting(toCreateEmail, toCreate);
        
        
        System.debug('to update');
        System.debug(toUpdate);
        update toUpdate;
        
        System.debug('to delete');
        System.debug(toDelete);
        delete toDelete;
        
        return paramsSendToGallagher;
    }
    
    private static List<String> createSynchronizedMeeting(List<String> emailMeeting, List<Meeting__c> meetings){
        Set<Id> roomIds = new Set<Id>();
        Map<String, List<Related_Access__c>> relatedAccessOfRoom = new Map<String, List<Related_Access__c>>();
        Map<String, List<Meeting__c>> meetingsEachEvent = new Map<String, List<Meeting__c>>();
        
        /**
         * prepare variable
         */
        List<Contact> toSaveContact = new List<Contact>();
        Map<String, Id> mapEmail = new Map<String, Id>();
        
        /**
         * get saved contact list that exists in created meeting from calendar
         */
        for(Contact ct : [select Id, Email from Contact where Email in :emailMeeting]){
            mapEmail.put(ct.Email, ct.Id);
        }
        
        /**
         * create new contact if email is new or not exists in saved contact
         */
        for(String email : emailMeeting){
            if(mapEmail.get(email) == null){
                toSaveContact.add(new Contact(
                    LastName = 'Guest',
                    ID_Type__c = 'Government ID',
                    Email = email
                ));
            }
        }
        
        insert toSaveContact;
        
        /**
         * collect already saved new contact to map
         */
        for(Contact ct : toSaveContact){
            mapEmail.put(ct.Email, ct.Id);
        }
        
        /**
         * create new meeting
         */
        Integer i = 0;
        for(Meeting__c m : meetings){
            m.Guest__c = mapEmail.get(emailMeeting.get(i));
            i++;
        }
        
        insert meetings;
        
        /**
         * send email invitation to guests
         */
        for(Meeting__c g : meetings){
            roomIds.add(g.Room__c);
            
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
            mail.setTargetObjectId(g.Guest__c);
            mail.setTemplateId('00X28000001G2ZQ');
            mail.setSenderDisplayName('XL Meeting Invitation');
            mail.setWhatId(g.Id);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
        
        /**
         * get related access based on rooms
         */
        for(Related_Access__c r : [select Id, Access_Item__c, Access_Item__r.Name, Room__c, Room__r.Name from Related_Access__c where Room__c in :roomIds]){
            if(relatedAccessOfRoom.get(r.Room__c) == null){
                relatedAccessOfRoom.put(r.Room__c, new List<Related_Access__c>());
            }
            
            relatedAccessOfRoom.get(r.Room__c).add(r);
        }
        
        /**
         * constranct related access
         */
        for(Meeting__c m : [select 
                            Id, 
                            Event_Id__c,
                            Start_Meeting__c, 
                            End_Meeting__c, 
                            Subject__c, 
                            Description__c,
                            Host__c, 
                            Host__r.LastName,
                            Host__r.FirstName,
                            Guest__c,
                            Guest__r.LastName,
                            Guest__r.FirstName,
                            Guest__r.ID_Number__c, 
                            Guest__r.MailingStreet, 
                            Guest__r.MailingCity, 
                            Guest__r.MailingState, 
                            Guest__r.MailingCountry, 
                            Room__c,
                            Room__r.Name
                            from Meeting__c where Id in :meetings]){
                                if(meetingsEachEvent.get(m.Event_Id__c) == null){
                                    meetingsEachEvent.put(m.Event_Id__c, new List<Meeting__c>());
                                }
                                
                                meetingsEachEvent.get(m.Event_Id__c).add(m);
                            }
		System.debug('related access = ' + relatedAccessOfRoom);
        System.debug('meeting = ' + meetingsEachEvent);
        
        List<String> paramsSentToGallagher = new List<String>();
        
        for(String eventId : meetingsEachEvent.keySet()){
            paramsSentToGallagher.addAll(new_meeting.generateUrlParam(meetingsEachEvent.get(eventId), relatedAccessOfRoom.get(meetingsEachEvent.get(eventId)[0].Room__c)));
        }        
        return paramsSentToGallagher;
    }
    
    @AuraEnabled
    public static Boolean saveToGallagher(List<String> params){
        for(String param : params){
            new_meeting.sendToGallagher(param);
        }   
        
        return true;
    }
}