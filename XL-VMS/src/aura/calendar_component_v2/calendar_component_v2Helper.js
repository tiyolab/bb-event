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
        var action = component.get('c.getMeetingId');
        action.setParams({
            'eventId' : event_id
        });
        action.setCallback(this, function(response){
            if(component.isValid() &&response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                 	var id = response.getReturnValue();
                    var navEvt = $A.get('e.force:navigateToSObject');
                    navEvt.setParams({
                        "recordId" : id
                    });
                    navEvt.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})