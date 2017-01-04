trigger t_create_my_event_session on My_Event_Session__c (before insert, before update) {
    /**
     * iterate to all inputed data
     */
    for(My_Event_Session__c new_mes : Trigger.New){
       /**
        * if operation is update
        */
        if(Trigger.isUpdate){
            /**
             * if update also change the limit of event session (new limit different with old limit)
             */
            if(new_mes.Limit__c != Trigger.oldMap.get(new_mes.Id).Limit__c){
                /**
                 * probability 
                 * NL > OL	---> US < OL = allowed
                 * 			---> US = OL = allowed
                 * NL < OL	---> US < OL = allowed if NL > US else not allowed
                 * 			---> US = OL not allowed
                 */
                Integer old_limit = (Integer)Trigger.oldMap.get(new_mes.Id).Limit__c;
                Integer new_limit = (Integer)new_mes.Limit__c;
                Integer used_sit = (Integer)(Trigger.oldMap.get(new_mes.Id).Limit__c - Trigger.oldMap.get(new_mes.Id).Available_Sit__c);
                
                /**
                 * if limit change to larger (NL > OL)
                 */
                if(new_limit > old_limit){
                    /* US < OL or US = OL */
                    new_mes.Available_Sit__c = new_mes.Available_Sit__c + (new_limit - old_limit);
                /**
                 * if limit change to smaller (NL < OL)
                 */
                }else if(new_limit < old_limit){
                    /**
                     * if US < OL
                     */
                    if(used_sit < old_limit){
                        if(new_limit >= used_sit){
                            new_mes.Available_Sit__c = new_limit - used_sit;
                        }else{
                            //not allowed
                            new_mes.addError(c_event_constants.msg_unable_change_limit);
                        }                     
                    }else{
                        //not allowed
                        new_mes.addError(c_event_constants.msg_unable_change_limit);
                    } 
                }
            }
        }
        
        if(Trigger.isInsert){
            new_mes.Available_Sit__c = new_mes.Limit__c;
        }
    }
}