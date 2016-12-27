({
	displayLoadingInfo : function(isDisplay, message) {
        var displayLoading = '';
        var displayMessage = '';
        
        if(isDisplay){
            displayLoading = 'block';
        }else{
            displayLoading = 'none';
        }
        
        if(message.length > 0){
            displayMessage = 'block';
			$('#edit_message_info').html(message.join());            
        }else{
            displayMessage = 'none';
            $('#edit_message_info').html('');
        }
        
		$('#edit_loading_info').css('display', displayLoading);
        $('#edit_message_info').css('display', displayMessage);
	},
    
    showSpinner : function(component, isShow){
        var event = component.getEvent('toggle_spinner');
        event.setParams({
            'isShow' : isShow
        });
        event.fire();
    },
    
    closeModal : function(component){
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
	}
})