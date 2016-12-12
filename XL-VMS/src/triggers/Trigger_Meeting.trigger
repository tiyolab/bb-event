trigger Trigger_Meeting on Meeting__c (after insert, after update, after delete) {
    if(Trigger.isInsert){
        List<Room__c> usedRooms = new List<Room__c>();
        Meeting__c[] insertedMeeting = Trigger.New;
        
        for(Meeting__c m : insertedMeeting){
            usedRooms.add(new Room__c(Id = m.Room__c, Status__c = 'Booked'));    
        }
        
        update usedRooms;
    }else if(Trigger.isUpdate){
        
        
    }else if(Trigger.isDelete){
        
    }
}