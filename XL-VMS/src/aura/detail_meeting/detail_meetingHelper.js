({
	closeModal : function(component) {
        $('#detail-meeting-modal').css('display', 'none');
        
        component.set('v.meetings', []);
        component.set('v.subject', '');
        component.set('v.description', '');
        component.set('v.startMeeting', '');
        component.set('v.endMeeting', '');
        component.set('v.room', '');
	},
    
    showSpinner : function(component, isShow){
        var event = component.getEvent('toggle_spinner');
        event.setParams({
            'isShow' : isShow
        });
        event.fire();
    }
})