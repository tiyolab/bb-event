({
    init : function(component, event, helper){
				/**
                 * get available room
                 */
                var action = component.get('c.searchRoom');
                action.setCallback(this, function(response){
                    if(component.isValid() && response.getState() == 'SUCCESS'){
                        if(response.getReturnValue() != null){
                            console.log(response.getReturnValue());
                            component.set('v.rooms', response.getReturnValue());
                        }
                    }
                });
                $A.enqueueAction(action);    
    },
    
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
                component.set('v.start_meeting', start.format('YYYY-MM-DD'));
                component.set('v.end_meeting', helper.fromFullCalendar(end.format('YYYY-MM-DD')));
                
                /**
                 * open modal
                 */
                $("#create-meeting-modal").css('display', 'block');
                
                $('#calendar').fullCalendar('unselect');
            },
            eventClick: function(event){
                helper.detailMeeting(component, event.id);
            }
        })
	},
    
    close_create_meeting_modal : function(){
        $("#create-meeting-modal").css('display', 'none');
    },
    
    handle_response_create_meeting : function(component, event, helper){
        /**
         * show spinner
         */
        component.set('v.show_spinner', true);
        
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
        document.getElementById('iframe').contentWindow.createCalendarEvent(meetingMetadata, function(status, eventCreated){
            if(status){
                /**
                 * close dialog
                 */
                $("#create-meeting-modal").css('display', 'none');
                
            	/**
            	 * save event id from calendar api to related meetings
            	 */
                meetings.forEach(function(meeting, index){
                	meeting.Event_Id__c = eventCreated.id;    
                });
            	
            	var action = component.get('c.sendEmailInvitation');
            	action.setParams({
            		'meetings' : meetings
            	});
            	action.setCallback(this, function(response){
            		if(component.isValid() && response.getState() == 'SUCCESS'){
                        console.log('send email response = ' + response.getReturnValue());
            			if(response.getReturnValue() != null && response.getReturnValue() == true){
            				/**
                             * close spinner
                             */
                            component.set('v.show_spinner', false);
                            
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
                                title : meeting.Subject__c,
                                start : start_meeting,
                                end : end_meeting,
                                id : eventCreated.id
                            }
                            
                            $("#calendar").fullCalendar('renderEvent', newMeeting, true);
            			}
            		}
            	});
            	$A.enqueueAction(action);
            	
            }else{
                alert('Meeting not created');
            }
        });
    },
    
    calendar_data_loaded : function(component, event, helper){
        component.set('v.show_spinner', false);
    },
    
    test_function : function(){
        
    }
})