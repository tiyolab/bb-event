({
	fromFullCalendar : function(calendar) {
		var tmpCalendar = calendar.split('-');
        var year = parseInt(tmpCalendar[0]);
        var month = parseInt(tmpCalendar[1]);
        var day = parseInt(tmpCalendar[2]);
        
        if(day == 1){
            /**
             * if january
             */
            if(month == 1){
                day = 31;
                month = 12;
                year = year - 1;
            /**
             * if march
             */
            }else if(month == 3){
                /**
                 * if kabisat
                 */
                if(year % 400 == 0 || year % 4 == 0){
                    day = 29;
                }else{
                    day = 28;
                }
                month = month - 1;
            }else{
             	if(month <= 7){
                    if(month % 2 == 0){
                        day = 31;
                    }else{
                        day = 30;
                    }
                }else if(month == 8){
                    day = 31;
                }else{
                    if(month % 2 == 0){
                        day = 30;
                    }else{
                        day = 31;
                    }
                }
                month = month - 1;
            } 
        }else{
            day = day - 1 ;
        }
        
        var strDay = day + '';
        if(strDay.length == 1){
            strDay = '0'+strDay;
        }
        
        return year + '-' + month + '-' + strDay;
	},
    
    toFullCalendar : function(calendar){
        
    },
    
    detailMeeting : function(component, event_id){
        /**
         * open detail modal
         */
        var event = $A.get('e.c:event_open_detail_meeting');
        event.setParams({
            'eventId' : event_id
        });
        event.fire();
    },
    
    saveToServer : function(eventId, updatedAt){
        var event = $A.get('e.c:eventSendEventIdAndUpdatedTime');
        event.setParams({
            'eventId' : eventId,
            'updatedAt' : updatedAt
        });
        event.fire();
    },
    
    synchronize : function(component, mapMeeting){
        var action = component.get('c.synchronizeWithCalendar');
        action.setParams({
            'sdata' : JSON.stringify(mapMeeting)
        });
        action.setCallback(this, function(response){
           console.log('response' + response.getReturnValue()); 
        });
        $A.enqueueAction(action);
        
        console.log('fired');
    }
})