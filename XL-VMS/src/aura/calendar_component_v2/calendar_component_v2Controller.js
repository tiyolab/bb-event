({  
    initCalendar : function(component, event, helper) {
        $("#calendar").fullCalendar({
            header: {
                right: 'month,agendaWeek,agendaDay',
                left: 'prev,next today',
                center: 'title'
            },
            timezone: false,
            selectable: true,
			selectHelper: true,
            editable: true,
            select : function(start, end){
                /**
                 * open create meeting modal
                 */
                var event = $A.get('e.c:event_open_create_meeting');
                event.setParams({
                    'startMeeting' : start.format('YYYY-MM-DD'),
                    'endMeeting' : helper.fromFullCalendar(end.format('YYYY-MM-DD'))
                });
                event.fire();
                
                $('#calendar').fullCalendar('unselect');
            },
            eventClick: function(event){
                helper.detailMeeting(component, event.id);
            }
        })
	},
    
    handle_response_create_meeting : function(component, event, helper){
        var that = this;
        /**
         * show spinner
         */
        component.set('v.showSpinner', true);
        
        var meetings = event.getParam('meetings');
        var attendees = JSON.parse(event.getParam('guests_email'));
        var timezone = event.getParam('timezone');
        
        var meetingMetadata = {
            'subject' : meetings[0].Subject__c,
            'room' : meetings[0].Room__c,
            'description' : meetings[0].Description__c,
            'start_meeting' : meetings[0].Start_Meeting__c,
            'end_meeting' : meetings[0].End_Meeting__c,
            'attendees' : attendees,
            'timezone' : timezone
        }
        
        /**
         * send meeting metadata to iframe to save to google calendar api
         */
        document.getElementById('iframe').contentWindow.createCalendarEvent(meetingMetadata, component, function(status, eventCreated){
            if(status){
            	/**
            	 * save event id from calendar api to related meetings
            	 */
                meetings.forEach(function(meeting, index){
                	meeting.Event_Id__c = eventCreated.id;    
                });
                
                helper.updateEventId(meetings);
                
            	/**
            	 * render event to calendar
                 */
                var start_meeting = eventCreated.start.dateTime;
                var end_meeting = eventCreated.end.dateTime;
                            
                if(!start_meeting){
                    start_meeting = eventCreated.start.date;
                }
                            
                if(!end_meeting){
                    end_meeting = eventCreated.end.date;
                }
                            
                var newMeeting = {
                    title : eventCreated.summary,
                    start : start_meeting,
                    end : end_meeting,
                    id : eventCreated.id
                }
                
                $("#calendar").fullCalendar('renderEvent', newMeeting, true);
                
            }else{
                /**
                 * close spinner
                 */
                component.set('v.showSpinner', false);
                alert('Meeting not created');
            }
        });
    },
    
    handle_response_edit_meeting : function(component, event, helper){
        /**
         * show spinner
         */
        component.set('v.showSpinner', true);
        
        var meetings = event.getParam('meetings');
        var attendees = JSON.parse(event.getParam('guests_email'));
        var timezone = event.getParam('timezone');
        var full_calendar_event = event.getParam('full_calendar_event');
        
        var meetingMetadata = {
            'eventId' : meetings[0].Event_Id__c,
            'subject' : meetings[0].Subject__c,
            'room' : meetings[0].Room__c,
            'description' : meetings[0].Description__c,
            'start_meeting' : meetings[0].Start_Meeting__c,
            'end_meeting' : meetings[0].End_Meeting__c,
            'attendees' : attendees,
            'timezone' : timezone
        }
        
        /**
         * send meeting metadata to iframe to save to google calendar api
         */
        document.getElementById('iframe').contentWindow.updateCalendarEvent(meetingMetadata, function(status, eventCreated){
            if(status){
                /**
                 * render event to calendar
                 */
                var start_meeting = eventCreated.start.dateTime;
                var end_meeting = eventCreated.end.dateTime;
                            
                if(!start_meeting){
                    start_meeting = eventCreated.start.date;
                }
                            
                if(!end_meeting){
                    end_meeting = eventCreated.end.date;
                }
                
                var newMeeting = {
                    title : eventCreated.summary,
                    start : start_meeting,
                    end : end_meeting,
                    id : eventCreated.id
                }
                
                $("#calendar").fullCalendar('removeEvents', eventCreated.id);
                $("#calendar").fullCalendar('renderEvent', newMeeting, true);
                
                console.log('update finished');
            }
            
            /**
             * hide spinner
             */
            component.set('v.showSpinner', false);
        });
    },
    
    handle_delete_meeting : function(component, event, helper){
        /**
         * show spinner
         */
        component.set('v.showSpinner', true);
        
        var eventId = event.getParam('eventId');
        console.log(eventId);
        document.getElementById('iframe').contentWindow.deleteEvent(eventId, function(status){
            if(status){
                console.log('delete success');
                $("#calendar").fullCalendar('removeEvents', eventId);
            }
            
            /**
             * hide spinner
             */
            component.set('v.showSpinner', false);
        });
    },
    
    calendar_data_loaded : function(component, event, helper){
        component.set('v.showSpinner', false);
    },
    
    handle_toggle_spinner : function(component, event, handler){
        component.set('v.showSpinner', event.getParam('isShow'));
    },
    
    test_function : function(component){
        console.log(component.get('v.showSpinner'));
    }
})