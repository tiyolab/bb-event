({
	_onAttendeesKeyUp : function(component, event, helper){
        var searchValue = $('#edit_attendees_search').val();
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
            $('#edit_attendees_search').val('');
            guests.push(contact_maps[contactId]);
            contacts = [];
            
            component.set('v.guests', guests);
            component.set('v.contacts', contacts);
            
        }
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
    
    change_room : function(component, event, helper){
        component.set('v.selected_room', component.find('selected_room').get('v.value'));
        console.log(component.get('v.selected_room'));
    },
    
    closeModal : function(component, event, helper){
        $("#edit-meeting-modal").css('display', 'none');
        /**
         * clear variable
         */
        component.set('v.event_id', '');
        component.find('subject').set('v.value', '');
        component.find('description').set('v.value', '');
        component.set('v.guests', []);
        component.set('v.old_meeting', []);
        component.set('v.selected_room', '');
    },
    
    openModal : function(component, event, helper){
        $("#edit-meeting-modal").css('display', 'block');
        
        var eventId = event.getParam('eventId');
        component.set('v.event_id', eventId);
        
      	var action = component.get('c.getMeeting');
        action.setParams({
            'eventId' : eventId
        });
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                    component.set('v.old_meeting', response.getReturnValue());
                    
                    var guests = component.get('v.guests');
                    response.getReturnValue().forEach(function(value){
                        guests.push({
                            'Id' : value.Guest__r.Id,
                            'Email' : value.Guest__r.Email,
                            'FirstName' : value.Guest__r.FirstName,
                            'LastName' : value.Guest__r.LastName
                        });
                    });
                    component.set('v.guests', guests);
                    
                    component.find('subject').set('v.value', response.getReturnValue()[0].Subject__c);
                    component.find('description').set('v.value', response.getReturnValue()[0].Description__c);
                    component.find('start_meeting').set('v.value', response.getReturnValue()[0].Start_Meeting__c);
                    component.find('end_meeting').set('v.value', response.getReturnValue()[0].End_Meeting__c);
                    component.set('v.selected_room', response.getReturnValue()[0].Room__c);
                }
            }
        });
        $A.enqueueAction(action);
        
         /**
         * get available room
         */
        var action2 = component.get('c.searchRoom');
        action2.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                    component.set('v.rooms', response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action2);
    },
    
    save_changes : function(component, event, helper){
        var action = component.get('c.saveChanges');
        action.setParams({
            'eventId' : component.get('v.event_id'),
            'subject' : component.find('subject').get('v.value'),
            'description' : component.find('description').get('v.value'),
            'startMeeting' : component.find('start_meeting').get('v.value'),
            'endMeeting' : component.find('end_meeting').get('v.value'),
            'attendees' : component.get('v.guests'),
            'room' : component.get('v.selected_room'),
            'oldMeeting' : component.get('v.old_meeting')
        });
        action.setCallback(this, function(response){
            console.log(response.getReturnValue());
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                    var meetings = response.getReturnValue().meetings;
                    var timezone = response.getReturnValue().timezone;
                    
                    var guest = component.get('v.guests');
                    var guestEmail = [];
                    guest.forEach(function(value){
                        guestEmail.push({
                            'email' : value.Email
                        });
                    });
                    
                    var event = component.getEvent('response_edit_meeting');
                    event.setParams({
                        'meetings' : meetings,
                        'timezone' : timezone,
                        'guests_email' : JSON.stringify(guestEmail)
                    });
                    event.fire();
                    
                    alert('update success');
                }
            }
        });
        $A.enqueueAction(action);
        console.log(action);
    }
})