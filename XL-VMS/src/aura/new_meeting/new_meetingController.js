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
                }
            }
        });
        $A.enqueueAction(action);
        
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
    
    create_new_meeting : function(component, event, helper){
        /**
         * show spinner
         */
        component.set('v.show_spinner', true);
        
        var action = component.get('c.createNewMeeting');
        action.setParams({
            'subject' : component.find('subject').get('v.value'),
            'description' : component.find('description').get('v.value'),
            'startMeeting' : component.find('start_meeting').get('v.value'),
            'endMeeting' : component.find('end_meeting').get('v.value'),
            'attendees' : component.get('v.guests'),
            'room' : component.find('selected_room').get('v.value')
        });
        
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                    var guests_contact = component.get('v.guests');
                    var guestsEmail = [];
                    
                    guests_contact.forEach(function(guest, index){
                        guestsEmail.push({'email' : guest.Email});
                    });
                    
                    /**
                     * send event to calendar_component_v2
                     */
                    var evt = component.getEvent('response_create_meeting');
                    evt.setParams({
                        'meetings' : response.getReturnValue().meetings,
                        'guests_email' : JSON.stringify(guestsEmail),
                        'timezone' : response.getReturnValue().timezone
                    });
                    evt.fire();
                    
                    /**
                     * show spinner
                     */
                    component.set('v.show_spinner', false);
                    
                    /**
                     * clear guest
                     */
                    component.set('v.guests', []);
                    
                    /**
                     * clear input field
                     */
                    component.find('subject').set('v.value', '');
                    component.find('description').set('v.value', '');
                }
            }
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
    },
    
    sendToServer : function(data){
        
    }
})