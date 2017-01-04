trigger t_delete_registrant_session on Registrant_Session__c (before delete) {
	List<My_Event__c> list_me = new List<My_Event__c>();
    List<My_Event_Session__c> list_mes = new List<My_Event_Session__c>();
    
    Set<Id> set_me = new Set<Id>();
    List<Id> set_mes = new List<Id>();
    Map<Id, Integer> mapMesIdCount = new Map<Id, Integer>();
    
    for(Registrant_Session__c rs : Trigger.Old){
        set_mes.add(rs.My_Event_Session__c);
        
        if(mapMesIdCount.get(rs.My_Event_Session__c) == null){
            mapMesIdCount.put(rs.My_Event_Session__c, 0);
        }
        
        /**
         * increment based number of My Event Session existing
         */
        mapMesIdCount.put(rs.My_Event_Session__c, (mapMesIdCount.get(rs.My_Event_Session__c) + 1));
    }
    
    for(My_Event_Session__c mes : [select Available_Sit__c, My_Event__c from My_Event_Session__c where Id in :set_mes]){
        mes.Available_Sit__c = mes.Available_Sit__c + mapMesIdCount.get(mes.Id);
        list_mes.add(mes);
        set_me.add(mes.My_Event__c);
    }
    
    for(ID id : set_me){
		list_me.add(new My_Event__c(Id=id, Availability_Status__c = 'Available'));        
    }
    
    update list_mes;
    update list_me;
}