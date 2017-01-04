trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
    List<Task> newTask = new List<Task>();
    
    for(Opportunity o : Trigger.New){
        if(o.StageName == 'Closed Won'){
    		newTask.add(new Task(WhatId = o.Id, Subject = 'Follow Up Test Task'));       
        }
    }
    
    insert newTask;
}