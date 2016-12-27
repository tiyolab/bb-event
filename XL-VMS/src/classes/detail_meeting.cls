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
    public static List<Object> deleteMeeting(String eventId){
        /**
         * Map<maximo_id, param> toReturn
         */
        List<Object> toReturn = new List<Object>();
        List<Meeting__c> meetingDatas = [select 
                                         Id,
                                         Mx_Meeting_Id__c
                                         from Meeting__c where Event_Id__c = :eventId
                                        ];
        
        for(Meeting__c mt : meetingDatas){
            toReturn.add(mt.Mx_Meeting_Id__c);
        }
        
        delete meetingDatas;
        
        return toReturn;
    }
    
    @AuraEnabled
    /**
     * Map<maximo_id, param> toReturn
     */
    public static Boolean sendGallagher(List<Object> listMaxId){
        for(Object maxId : listMaxId){
            new_meeting.sendToGallagher('description=canceled', String.valueOf(maxId));
        }
        
        return true;
    }
}