global with sharing class new_meeting {
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
    public static Map<String, Object> createNewMeeting(String subject, 
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
        /*for(Meeting__c g : meetings){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                mail.setTargetObjectId(g.Guest__c);
                mail.setTemplateId('00X28000001G2ZQ');
                mail.setSenderDisplayName('XL Meeting Invitation');
                mail.setWhatId(g.Id);
                mail.setSaveAsActivity(false);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }*/
        
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
        
        List<String> generatedParam = generateUrlParam(meetingDatas, relatedAccessList);
                           
        //return meetingDatas;
        Map<String, Object> returnValue = new Map<String, Object>();
		returnValue.put('meetings', meetingDatas);
		returnValue.put('params', generatedParam);
                                                            
		return returnValue;
    }
    
    @AuraEnabled
    public static Map<String, Object> actionGallagher(List<String> params){
        Map<String, Object> sfmxMap = new Map<String, Object>();
        
        for(String param : params){
            String response = sendToGallagher(param, '');
            if( response != ''){
                Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(response);
                Map<String, Object> CreateVMSMEETINGResponse = (Map<String, Object>)jsonData.get('CreateVMSMEETINGResponse');
                Map<String, Object> VMSMEETINGSet = (Map<String, Object>)CreateVMSMEETINGResponse.get('VMSMEETINGSet');
                Map<String, Object> TALMEETING = (Map<String, Object>)VMSMEETINGSet.get('TALMEETING');
                Map<String, Object> Attributes = (Map<String, Object>)TALMEETING.get('Attributes');
                Map<String, Object> SFMEETINGID = (Map<String, Object>)Attributes.get('SFMEETINGID');
                Map<String, Object> MEETINGID = (Map<String, Object>)Attributes.get('MEETINGID');
                
                sfmxMap.put((String)SFMEETINGID.get('content'), MEETINGID.get('content'));
            }
        }
        
        return sfmxMap;
    }
    
    @AuraEnabled
    public static List<String> updateToGallagher(List<String> params, List<String> maximoIds){
        List<String> response = new List<String>();
        Integer i = 0;
        
        for(String param : params){
            response.add(sendToGallagher(param, maximoIds.get(i)));
            i++;
        }
        
        return response;
    }
    
    @AuraEnabled
    public static Boolean setMxMeetingId(Map<String, Object> sfmxMeetingIds){
        List<Meeting__c> meetings = [select Id, Mx_Meeting_Id__c from Meeting__c where Id in :sfmxMeetingIds.keySet()];
        for(Meeting__c m : meetings){
            m.Mx_Meeting_Id__c = Integer.valueOf(sfmxMeetingIds.get(m.Id));
        }
        
        update meetings;
        return true;
    }
    
    @AuraEnabled
    public static ID getMeetingId(String eventId){
        Meeting__c m = [select Id from Meeting__c where Event_Id__c = :eventId];
        return m.Id;
    }
    
    //@future(callout=true)
    public static String sendToGallagher(String param, String maximoId){
        System.debug('calling request');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://182.253.1.69:9080/maximo/rest/os/VMSMEETING/'+ maximoId +'?_format=json&_lid=wilson&_lpwd=wilson&action=addChange&' + param);
        //request.setEndpoint('http://xl-wms.hol.es/get.php?test=test');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(30000);
        
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        if(response.getStatusCode() == 200){
            return response.getBody();
        }
        
        return '';
    }
    
    public static List<String> generateUrlParam(Meeting__c[] meetings, Related_Access__c[] relatedAccess){
        //String data = 'roomname=' +  EncodingUtil.urlEncode(meetings[0].Room__r.Name, 'UTF-8') + '&';
        List<String> params = new List<String>();
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
            params.add(toSend);
        }
        
        return params;
    }
    
    @AuraEnabled
    public static boolean test(){
        return true;
    }
    
    public static String parsing(Datetime mtime){
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