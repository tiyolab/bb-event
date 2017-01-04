public class c_detail_controller {
    private String registrantId = '';
    private String eventId = '';
    private String hash = '';
    private String bookingCode = '';
    
    public String myUrl {set; get{return URL.getSalesforceBaseUrl().toExternalForm();}}
    public String email {set; get;}
    public String firstName {set; get;}
    public String lastName {set; get;}
    public Map<ID, Boolean> selectedSessions {set; get;}
    public My_Event__c event {set; get;}
    
    public PageReference validate(){
        String id = ApexPages.currentPage().getParameters().get('id');
		//String id = 'a0G2800000Y3HQOEA3';
        
        My_Event__c[] tmpEvent = null;
        Map<ID, Boolean> tmpSelectedSessions = new Map<ID, Boolean>();
        
        /**
         * prevent blank/null id at url parameter
         */
        if(id == null || string.isBlank(id)){
            return redirect(System.Page.c_home);
        }
        
        eventId = id;
        
        tmpEvent = [select Name, Registration_Deadline__c, Start_Date__c, End_Date__c, 
                                        Venue__r.Name, Venue__r.Address__c, Venue__r.City__c, Venue__r.State_Province__c, Venue__r.Country__c, Venue__r.Phone__c,
                                        (select Id, Name, Start_Session__c, End_Session__c, Available_Sit__c from My_Event_Sessions__r)
                                   from My_Event__c
                                   where Id = :eventId];
        
        /**
         * prevent invalid event id
         */
        if(tmpEvent.size() == 0){
            return redirect(System.Page.c_home);
        }
        
        event = tmpEvent[0];
        
        for(My_Event_Session__c mes : event.My_Event_Sessions__r){
            tmpSelectedSessions.put(mes.Id, false);
        }
        selectedSessions = tmpSelectedSessions;
        
        return null;
    }
    
    public PageReference register(){
        /**
         * set database save point
         */
        SavePoint savePoint = Database.setSavepoint();
        
        Boolean isNewRegistrant = false;
        Map<Id, Registrant_Session__c> tmpRS = new Map<Id, Registrant_Session__c>();
        
        /**
         * prevent user input blank email
         */
        if(string.isBlank(email) || string.isBlank(firstName) || string.isBlank(lastName)){
            return failedRegisterMessage(c_event_constants.msg_cannot_blank);
        }
        
        /**
         * prevent user input invalid email
         */
        if(!c_event_helper.isEmailValid(email)){
            return failedRegisterMessage(c_event_constants.msg_email_invalid);
        }
        
        /**
         * prevent user unselect all session
         */
        for(My_Event_Session__c mes: event.My_Event_Sessions__r){
            if(selectedSessions.get(mes.Id)){
                tmpRS.put(mes.Id, new Registrant_Session__c(My_Event_Session__c = mes.Id));
            }
        }
        
        if(tmpRS.size() == 0){
            return failedRegisterMessage(c_event_constants.msg_must_select_min_a_event_session);
        }
        
		/**
		 * add to contact if new
		 */
        Contact[] c = [select Id, FirstName, LastName from Contact where Email = :email];
        if(c.size() == 0){
            try{
                c.add(new Contact(LastName = lastName, FirstName = firstName, Email = email));
             	insert c;   
            }catch(DMLException e){
                return failedRegisterMessage(c_event_constants.msg_failed_save_data);
            }
        }else{
            try{
                c[0].FirstName = firstName;
                c[0].LastName = lastName;
                upsert c;
            }catch(DMLException e){
                return failedRegisterMessage(c_event_constants.msg_failed_save_data);
            }
        }
        
        /**
         * Create new registrant data if not exist
         */
        Registrant__c[] registrants = [select Id, Code__c, Hash__c from Registrant__c where Contact__r.Email = :email and My_Event__c = :eventId];
        if(registrants.size() == 0){
            try{
                /**
                 * generate booking code
                 */
                bookingCode = c_event_helper.generateRandomCode();
                /**
                 * generate Hash
                 */
                hash = c_event_helper.generateHashCode();
                
            	registrants.add(new Registrant__c(Name = hash, Contact__c = c[0].Id, My_Event__c = eventId, Code__c = bookingCode, Hash__c = hash));
            	insert registrants;    
            }catch(DMLException e){
                /**
                 * roolback to saved savePoint
                 */
                Database.rollback(savePoint);
                return failedRegisterMessage('Register event failed');
            }
            
            isNewRegistrant = true;
        }
        registrantId = registrants[0].Id;
        bookingCode = registrants[0].Code__c;
		hash = registrants[0].Hash__c;
        
        /**
         * Create registrant session data
         */
        
        /**
         * check and retrieve registrant session which registrant ever registered in same event session
         */
        List<Registrant_Session__c> savedRs = new List<Registrant_Session__c>();
        if(!isNewRegistrant){
            savedRs = [select Id, My_Event_Session__c, Registrant__c from Registrant_Session__c where Registrant__c = :registrantId];
        }
        
        /**
         * If registrant ever register to same event session. remove that selected event session
         */
        for(Registrant_Session__c rs : savedRs){
            if(tmpRS.get(rs.My_Event_Session__c) != null){
                tmpRS.remove(rs.My_Event_Session__c);
                selectedSessions.remove(rs.My_Event_Session__c);
            }
        }
        
        for(Id id : tmpRS.keySet()){
            tmpRS.get(id).Registrant__c = registrantId;
        }
        
        try{
        	insert tmpRS.values();    
        }catch(DMLException e){
            /**
        	 * roolback to saved savePoint
             */
      		Database.rollback(savePoint);
         	return failedRegisterMessage('Register event failed');
        }
        
        
        if(sendEmail()){
            return redirect(System.Page.c_registration_info);
        }else{
            Database.rollback(savePoint);
            return failedRegisterMessage('Register event failed');
        }
        
    }
    
    private PageReference failedRegisterMessage(String strMsg){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, strMsg);
        ApexPages.addMessage(msg);
       	return null;
    }
    
    private PageReference redirect(PageReference destination){
		PageReference redirect = destination;
		redirect.setRedirect(true);
      	return redirect;        
    }
    
    private String generateUrl(){
        String delimeter = '@~@';
        String tmpId = EncodingUtil.base64Encode(Blob.valueOf(hash + delimeter + registrantId + delimeter + bookingCode));
        
        return myUrl + '/c_my_event?id='+tmpId;
    }
    
    private boolean sendEmail(){
        try{
            String link = generateUrl();
            Messaging.reserveSingleEmailCapacity(10);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{email});
            mail.setSenderDisplayName('Global Telecom Company');
            mail.setSubject('Event registration confirmation');
            mail.setHtmlBody(
                '<h3>Thank you for joining our event</h3>.'+
                '<p>This is your secret booking code <h2><b>'+bookingCode+'</b></h2> , <i>please keep it secret.</i></p>'+
                '<font style="color:red">Please click link below to complete registration proccess.</font><br/>'+
                '<a href="'+link+'">'+link+'</a>');
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            if(results[0].success){
                return true;
            }else{
                return false;
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            return false;
        }       
    }
}