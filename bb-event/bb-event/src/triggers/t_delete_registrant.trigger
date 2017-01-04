trigger t_delete_registrant on Registrant__c (before delete) {
	List<My_Event__c> list_me = new List<My_Event__c>();
    List<My_Event_Session__c> list_mes = new List<My_Event_Session__c>();
 	List<ID> list_me_id = new List<ID>();
    
    for(Registrant__c r : Trigger.Old){
        list_me_id.add(r.My_Event__c);
    }
    
    for(My_Event__c me : [select Availability_Status__c, (select Available_Sit__c from My_Event_Sessions__r) from My_Event__c where Id in :list_me_id]){
        for(My_Event_Session__c mes : me.My_Event_Sessions__r){
            mes.Available_Sit__c = mes.Available_Sit__c + 1;
            list_mes.add(mes);
        }
        
        me.Availability_Status__c = 'Available';
     	list_me.add(me);   
    }
    
    update list_mes;
    update list_me;
}