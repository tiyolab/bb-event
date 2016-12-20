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
    public static String getTimeZone(){
        /**
         * get host timezone
         */
        User u = [select TimeZoneSidKey from User where Id =:UserInfo.getUserId()];
        
        return u.TimeZoneSidKey;
    }
    
    @AuraEnabled
    public static List<Meeting__c> createNewMeeting2(String subject, 
                                                        String description, 
                                                        DateTime startMeeting, 
                                                        DateTime endMeeting, 
                                                        Contact[] attendees, 
                                                        String room,
                                                        String eventId,
                                                        String updatedAt){
        List<Contact> newContact = new List<Contact>();
        List<Contact> savedContact = new List<Contact>();
        List<Meeting__c> meetings = new List<Meeting__c>();
        
        /**
         * data send to gallgher
         */
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
                        Room__c = room,
                        Event_Id__c = eventId,
                        Last_Updated_At__c = updatedAt));
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
         * send email invitation to guests
         */
        for(Meeting__c g : meetings){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                mail.setTargetObjectId(g.Guest__c);
                mail.setTemplateId('00X28000001G2ZQ');
                mail.setSenderDisplayName('XL Meeting Invitation');
                mail.setWhatId(g.Id);
                mail.setSaveAsActivity(false);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
        
        /**
         * get access item data
         */
        List<Related_Access__c> relatedAccessList = [select Id, Access_Item__c, Access_Item__r.Name, Room__c, Room__r.Name from Related_Access__c where Room__c = :room];
        
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
                                         from Meeting__c where Id in :meetings
                                        ];
        
        generateUrlParam(meetingDatas, relatedAccessList);
                           
        return meetingDatas;
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
        List<Related_Access__c> relatedAccessList = [select Id, Access_Item__c, Access_Item__r.Name, Room__c, Room__r.Name from Related_Access__c where Room__c = :room];
        /*for(Related_Access__c r : relatedAccessList){
            Map<String, Object> tmp = new Map<String, Object>();
            tmp.put('id', r.Id);
            tmp.put('accessItem', r.Access_Item__c);
            tmp.put('room', r.Room__c);
            
            relatedAccesses.add(tmp);
        }*/
        
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
        
        /*System.debug(String.valueOf(datas));
        System.debug(EncodingUtil.urlEncode(String.valueOf(datas), 'UTF-8'));
        System.debug(JSON.serialize(datas));
        sendToGallagher(JSON.serialize(datas));*/
        
        generateUrlParam(meetingDatas, relatedAccessList);
        
        /*String urlParam = generateUrlParam(meetingDatas, relatedAccessList);
        System.debug(urlParam);
        sendToGallagher(urlParam);*/
        System.debug('pass');
        
        /**
         * get host timezone
         */
        User u = [select TimeZoneSidKey from User where Id =:UserInfo.getUserId()];
        
        Map<String, object> toReturn = new Map<String, object>();
        toReturn.put('timezone', u.TimeZoneSidKey);
        //toReturn.put('meetings', meetings);
        toReturn.put('meetings', meetingDatas);
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
    private static void sendToGallagher(String param){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://182.253.1.69:9080/maximo/rest/os/VMSMEETING/?_format=json&_lid=wilson&_lpwd=wilson&action=addChange&' + param);
        //request.setEndpoint('http://xl-wms.hol.es/get.php?test=test');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        if(response.getStatusCode() == 200){
            System.debug('rest success');
        }
    }
    
    private static void generateUrlParam(Meeting__c[] meetings, Related_Access__c[] relatedAccess){
        //String data = 'roomname=' +  EncodingUtil.urlEncode(meetings[0].Room__r.Name, 'UTF-8') + '&';
        String data = '';
        
        /**
         * generate related access
         */
        for(Related_Access__c r : relatedAccess){
            data += 'talrelatedaccess.' + r.Id + '.room=' + EncodingUtil.urlEncode(r.Room__r.Name, 'UTF-8') + '&';
            data += 'talrelatedaccess.' + r.Id + '.accessItem=' + EncodingUtil.urlEncode(r.Access_Item__r.Name, 'UTF-8') + '&';
            data += 'talrelatedaccess.' + r.Id + '.id=' + EncodingUtil.urlEncode(r.Id, 'UTF-8') + '&';
        }
        
        /**
         * generate meeting
         */
        for(Meeting__c m : meetings){
            String toSend = data;
            
            String address = '';
            String hostName = '';
            String idNumber = '';
            
            if(m.Guest__r.MailingStreet != null){
                address += EncodingUtil.urlEncode(', ' + m.Guest__r.MailingStreet, 'UTF-8');
            }
            
            if(m.Guest__r.MailingCity != null){
                address += EncodingUtil.urlEncode(', ' + m.Guest__r.MailingCity, 'UTF-8');
            }
            
            if(m.Guest__r.MailingState != null){
                address += EncodingUtil.urlEncode(', ' + m.Guest__r.MailingState, 'UTF-8');
            }
            
            if(m.Guest__r.MailingCountry != null){
                address += EncodingUtil.urlEncode(', ' + m.Guest__r.MailingCountry, 'UTF-8');
            }
            
            if(m.Host__r.LastName != null){
                hostName += EncodingUtil.urlEncode(', ' + m.Host__r.LastName, 'UTF-8');
            }
            
            if(m.Host__r.FirstName != null){
                hostName += EncodingUtil.urlEncode(', ' + m.Host__r.FirstName, 'UTF-8');
            }
            
            if(m.Guest__r.ID_Number__c != null){
                idNumber += EncodingUtil.urlEncode(m.Guest__r.ID_Number__c, 'UTF-8');
            }
            
            toSend += 'roomnumber=' + EncodingUtil.urlEncode(m.Room__r.Name, 'UTF-8') + '&';
            toSend += 'address=' +  address + '&';
            toSend += 'idnumber=' + idNumber + '&';
            toSend += 'host=' + hostName + '&';
            toSend += 'description=' + EncodingUtil.urlEncode(m.Description__c, 'UTF-8') + '&';
            toSend += 'subject=' + EncodingUtil.urlEncode(m.Subject__c, 'UTF-8') + '&';
            toSend += 'fromdate=' + EncodingUtil.urlEncode(parsing(m.Start_Meeting__c), 'UTF-8') + '&';
            toSend += 'todate=' + EncodingUtil.urlEncode(parsing(m.End_Meeting__c), 'UTF-8') + '&';
            toSend += 'sfmeetingId=' + EncodingUtil.urlEncode(m.Id, 'UTF-8') + '&';
            
            System.debug(toSend);
            sendToGallagher(toSend);
        }
    }
    
    @AuraEnabled
    public static boolean test(){
        return true;
    }
    
    private static String parsing(Datetime mtime){
        String day = mtime.dayGMT()+'';
        String month = mtime.monthGMT()+'';
        String year = mtime.yearGMT()+'';
        String hour = mtime.hourGMT()+'';
        String minute = mtime.minuteGMT()+'';
        String second = mtime.secondGMT()+'';
        
        if(day.length() == 1){
            day = '0'+day;
        }
        
        if(month.length() == 1){
            month = '0'+month;
        }
        
        if(hour.length() == 1){
            hour = '0'+hour;
        }
        
        if(minute.length() == 1){
            minute = '0'+minute;
        }
        
        if(second.length() == 1){
            second = '0'+second;
        }
        
        return year + '-' + month + '-' + day + 'T' + hour + ':' + minute + ':' + second + '+00:00';
    }
}