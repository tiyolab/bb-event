({  
    _onAttendeesKeyUp : function(component, event, helper){
        var searchValue = $('#attendees_search').val();
        if(searchValue.length <= 1){
            helper.displayLoadingInfo(false, ['Search key must more than a character']);
            return;
        }
        helper.displayLoadingInfo(true, []);
        
        
        var action = component.get('c.searchContact');
        action.setParams({
            'searchValue' : searchValue
        });
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                    var contact_maps = component.get('v.contact_maps');
                    
                    component.set("v.contacts", response.getReturnValue());
                    var contacts = component.get('v.contacts');
                    
                    contacts.forEach(function(value, index){
                        contact_maps[value.Id] = value;
                    });
                    
                    component.set("v.contact_maps", contact_maps);
                }
            }
            helper.displayLoadingInfo(false, []);
        });
        $A.enqueueAction(action);
    },
    
    _onFilterResultClicked : function(component, event, helper){
        var contacts = component.get('v.contacts');
        var contact_maps = component.get('v.contact_maps');
        var guests = component.get('v.guests');
        var contactId = '';
        var x = event.getSource().get('v.body');
        
        x.forEach(function(value, index){
            if(value.getLocalId() == 'filter-result-value'){
                contactId = value.get('v.value');
            }
        });
        
        if(contactId != ''){
            $('#attendees_search').val('');
            guests.push(contact_maps[contactId]);
            contacts = [];
            
            component.set('v.guests', guests);
            component.set('v.contacts', contacts);
            
        }
    },
    
    openModal : function(component, event, helper){
        var isRoomLoaded = false;
        var isTimeZoneLoaded = false;
        
        /**
         * show spinner
         */
        helper.showSpinner(component, true);
        
        component.set('v.start_meeting', event.getParam('startMeeting'));
        component.set('v.end_meeting', event.getParam('endMeeting'));
        /**
         * get available room
         */
        var action = component.get('c.searchRoom');
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                    component.set('v.rooms', response.getReturnValue());
                    
                    var roomMap = {};
                    response.getReturnValue().forEach(function(room, index){
                        roomMap[room.Id] = room.Name;
                    });
                    
                    component.set('v.roomMap', roomMap);
                }
            }
            
            /**
             * hide spinner
             */
            isRoomLoaded = true;
            if(isRoomLoaded && isTimeZoneLoaded){
            	helper.showSpinner(component, false);    
            }
            
        });
        $A.enqueueAction(action);
        
        /**
         * Get User Timezone
         */
        if(component.get('v.timeZone') == ''){
            var action2 = component.get('c.getTimeZone');
            action2.setCallback(this, function(response){
                if(component.isValid() && response.getState() == 'SUCCESS'){
                    if(response.getReturnValue() != null && response.getReturnValue() != ''){
                        component.set('v.timeZone', response.getReturnValue());
                    }else{
                        component.set('v.timeZone', 'Asia/Jakarta');
                    }
                }else{
                    component.set('v.timeZone', 'Asia/Jakarta');
                }
                
                /**
                 * hide spinner
                 */
                isTimeZoneLoaded = true;
                if(isRoomLoaded && isTimeZoneLoaded){
                    helper.showSpinner(component, false);    
                }
            });
            $A.enqueueAction(action2);
        }
        
        $("#create-meeting-modal").css('display', 'block');
    },
    
    closeModal : function(component){
      	$("#create-meeting-modal").css('display', 'none');  
        component.find('subject').set('v.value', '');
        component.find('description').set('v.value', '');
        component.set('start_meeting', '');
        component.set('end_meeting', '');
        component.set('v.guests', []);
    },
    
    selectRoom : function(component, event, helper){
        console.log(event.getSource().get('v.label'));
        return false;
        component.set('v.selectedRoomName', event.getSource().get('v.label'));
    },
    
    sendToCalendar : function(component, event, helper){
        /**
         * show spinner
         */
        helper.showSpinner(component, true);
        
        var newMeeting = {};
        newMeeting['sobjectType'] = 'Meeting__c';
        newMeeting['Subject__c'] = component.find('subject').get('v.value');
        newMeeting['Room_Name'] = component.get('v.roomMap')[component.find('selected_room').get('v.value')];
        newMeeting['Description__c'] = component.find('description').get('v.value');
        newMeeting['Start_Meeting__c'] = component.find('start_meeting').get('v.value');
        newMeeting['End_Meeting__c'] = component.find('end_meeting').get('v.value');
        
        /**
         * generate guest
         */
        var guests_contact = component.get('v.guests');
        var guestsEmail = [];            
        guests_contact.forEach(function(guest, index){
            guestsEmail.push({'email' : guest.Email});
        });
        
        /**
         * send event to calendar_component_v2
         */
        var evt = component.getEvent('createMeeting');
        evt.setParams({
            'meeting' : newMeeting,
            'guests_email' : JSON.stringify(guestsEmail),
            'timezone' : component.get('v.timeZone')
        });
        evt.fire();
    },
    
    saveToServer : function(component, event, helper){
        var eventId = event.getParam('eventId');
        var updatedAt = event.getParam('updatedAt');
        
        var meetings = [];
        
        var action = component.get('c.createNewMeeting');
        action.setParams({
            'subject' : component.find('subject').get('v.value'),
            'description' : component.find('description').get('v.value'),
            'startMeeting' : component.find('start_meeting').get('v.value'),
            'endMeeting' : component.find('end_meeting').get('v.value'),
            'attendees' : component.get('v.guests'),
            'room' : component.find('selected_room').get('v.value'),
            'eventId' : eventId,
            'updatedAt' : updatedAt
        });
        
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                    /**
                     * render event to calendar
                     */
                    var start_meeting = response.getReturnValue()[0].Start_Meeting__c;
                    var end_meeting = response.getReturnValue()[0].End_Meeting__c;
                                
                    var newMeeting = {
                        title : component.find('subject').get('v.value'),
                        start : start_meeting,
                        end : end_meeting,
                        id : eventId
                    }
                    
                    $("#calendar").fullCalendar('renderEvent', newMeeting, true);
                    
                    /**
                     * clear guest
                     */
                    component.set('v.guests', []);
                    
                    /**
                     * clear input field
                     */
                    component.find('subject').set('v.value', '');
                    component.find('description').set('v.value', '');
                    
                    /**
                     * close dialog
                     */
                    $("#create-meeting-modal").css('display', 'none');
                }else{
                    alert('Meeting not created');
                }
            }
            
            /**
             * hide spinner
             */
            helper.showSpinner(component, false);
        });
        
        $A.enqueueAction(action);
    },
    
    unselect_attendess : function(component, event, helper){
        var guestId = '';
        var body = event.getSource().get('v.body');
        body.forEach(function(value, index){
            if(value.getLocalId() == 'candidate-attendees'){
                guestId = value.get('v.value');
                return false;
            }
        });
        
    	var guests = component.get('v.guests');
        var i = 0;
        guests.forEach(function(value, index){
            if(value.Id == guestId){
                i = index;
                return false;
            }
        });
        guests.splice(i, 1);
        component.set('v.guests', guests);
	},
    
    add_new_guest : function(component, event, helper){
        var newGuest = {
            sobjectType: 'Contact',
            Email: $('#attendees_search').val(),
            LastName: 'Guest',
            ID_Type__c: 'Government ID'
        }
        
        var guests = component.get('v.guests');
        
        guests.push(newGuest);
        component.set('v.guests', guests);
        
        $('#attendees_search').val('');
    }
})