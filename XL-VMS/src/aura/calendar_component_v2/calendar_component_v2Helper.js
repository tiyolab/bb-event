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
        
        /**
         * open edit modal
         */
        //$("#edit-meeting-modal").css('display', 'block');
        
        /**
         * send event to edit_meeting component
         */
        /*var event_edit_meeting = $A.get('e.c:event_edit_meeting');
        event_edit_meeting.setParams({
            'event_id' : event_id
        });
        event_edit_meeting.fire();*/
        
        
        
        /*var action = component.get('c.getMeetingId');
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
        $A.enqueueAction(action);*/
    },
    
    sendToRest : function(Meetings){
        var xHttp;
        if(window.XMLHttpRequest){
            xHttp = new XMLHttpRequest();
        }else{
            xHttp = new ActiveXObject('Microsoft.XMLHTTP');
        }
        xHttp.onreadystatechange = function(){
            if(this.readyState == 4 && this.status == 200){
                //response
            }
        };
        xHttp.open('POST', 'url', true);
        xHttp.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
        xHttp.send(JSON.stringify(Meetings));
    },
    
    updateEventId : function(meetings){
        var event = $A.get('e.c:event_update_eventid');
        event.setParams({
            'meetings' : meetings
        });
        event.fire();
    }
})