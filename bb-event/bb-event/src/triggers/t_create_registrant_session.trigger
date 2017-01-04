trigger t_create_registrant_session on Registrant_Session__c (after insert) {
	List<My_Event_Session__c> list_mes = new List<My_Event_Session__c>();
    List<My_Event__c> list_me = new List<My_Event__c>();
    Set<ID> myEventSetId = new Set<ID>();
    /**
     * is_event_full = Map<Event Id, Boolean>
     */
    Map<ID, Boolean> is_event_full = new Map<ID, Boolean>();
    Map<ID, My_Event_Session__c> mapIdMyEventSession = new Map<ID, My_Event_Session__c>();
    
    Set<ID> set_mes_id = new Set<ID>();
    Map<ID, Integer> mapMesIdCount = new Map<ID, Integer>();
    
    for(Registrant_Session__c rs : Trigger.New){
        set_mes_id.add(rs.My_Event_Session__c);
        if(mapMesIdCount.get(rs.My_Event_Session__c) == null){
            mapMesIdCount.put(rs.My_Event_Session__c, 0);
        }
        
        /**
         * increment based number of My Event Session existing
         */
        mapMesIdCount.put(rs.My_Event_Session__c, (mapMesIdCount.get(rs.My_Event_Session__c) + 1));
    }
    
    /**
     * collect data
     */
    for(My_Event_Session__c mes : [select Id, Available_Sit__c, My_Event__c from My_Event_Session__c where Id in :set_mes_id]){
        mapIdMyEventSession.put(mes.Id, mes);
        myEventSetId.add(mes.My_Event__c);
        /**
         * imagine that event going to full
         */
        is_event_full.put(mes.My_Event__c, true);
    }
    
    /**
     * get All My Event Session of Event
     */
    for(My_Event_Session__c mes : [select Id, Available_Sit__c, My_Event__c from My_Event_Session__c where My_Event__c in :myEventSetId]){
        if(mapIdMyEventSession.get(mes.Id) != null){
            mes.Available_Sit__c = mes.Available_Sit__c - mapMesIdCount.get(mes.Id);
            list_mes.add(mes);
        }
        
        /**
         * if there is still available sit in my event session of event, so event not going to full
         */
        if(mes.Available_Sit__c > 0){
            is_event_full.put(mes.My_Event__c, false);
        }
    }
    
    update list_mes;
    
    for(My_Event__c me : [select Id, Availability_Status__c from My_Event__c where id in :myEventSetId]){
        if(is_event_full.get(me.Id)){
            me.Availability_Status__c = 'Full';
            list_me.add(me);
        }
    }
    
    update list_me;
}