trigger Trigger_Meeting on Meeting__c (before insert, before update, before delete) {
    if(Trigger.isInsert){
        //List<Room__c> usedRooms = new List<Room__c>();
        Map<ID, Room__c> mapRooms = new Map<ID, Room__c>();
        
        Meeting__c[] insertedMeeting = Trigger.New;
        
        for(Meeting__c m : insertedMeeting){
            mapRooms.put(m.Room__c, new Room__c(Id = m.Room__c, Status__c = 'Booked'));            
            //usedRooms.add(new Room__c(Id = m.Room__c, Status__c = 'Booked'));    
        }
        
        //update usedRooms;
        update mapRooms.values();
    }else if(Trigger.isUpdate){
        Map<ID, Meeting__c> newMeeting = new Map<ID, Meeting__c>(Trigger.New);
        Map<ID, Meeting__c> oldMeeting = new Map<ID, Meeting__c>(Trigger.Old);
        
        Map<ID, Room__c> updatedRooms = new Map<ID, Room__c>();
        
        for(ID mId : newMeeting.keySet()){
            if(newMeeting.get(mId).Room__c != oldMeeting.get(mId).Room__c){
                /**
                 * change to booked
                 */
                updatedRooms.put(newMeeting.get(mId).Room__c, new Room__c(Id = newMeeting.get(mId).Room__c, Status__c = 'Booked'));
                    
                /**
                 * change to free
                 */
                updatedRooms.put(oldMeeting.get(mId).Room__c, new Room__c(Id = oldMeeting.get(mId).Room__c, Status__c = 'Free'));
            }
        }
        
        update updatedRooms.values();
    }else if(Trigger.isDelete){
        Map<ID, Room__c> mapRooms = new Map<ID, Room__c>();
        Meeting__c[] deletedMeeting = Trigger.Old;
        
        for(Meeting__c m : deletedMeeting){
            mapRooms.put(m.Room__c, new Room__c(Id = m.Room__c, Status__c = 'Free'));
        }
        
        update mapRooms.values();
    }
}