({
	openModal : function(component, event, helper) {
		$('#detail-meeting-modal').css('display', 'block');
        /**
         * show spinner
         */
        helper.showSpinner(component, true);
        
        var eventId = event.getParam('eventId');
        component.set('v.eventId', eventId);
        
        var action = component.get('c.getMeeting');
        action.setParams({
            'eventId' : eventId
        });
        action.setCallback(this, function(response){
            console.log(response);
            console.log(response.getReturnValue());
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null && response.getReturnValue().length>0){
					var meetings = response.getReturnValue();
                    component.set('v.meetings', meetings);
                    component.set('v.subject', meetings[0].Subject__c);
                    component.set('v.description', meetings[0].Description__c);
                    component.set('v.startMeeting', meetings[0].Start_Meeting__c);
                    component.set('v.endMeeting', meetings[0].End_Meeting__c);
                    component.set('v.room', meetings[0].Room__r.Name);
                }
            }
            /**
             * hide spinner
             */
            helper.showSpinner(component, false);
            
        });
        $A.enqueueAction(action);
	},
    
    closeModal : function(component, event, helper){
        helper.closeModal(component);
    },
    
    edit : function(component, event, helper){
        helper.closeModal(component);
        
        var event = $A.get('e.c:event_open_edit_meeting');
        event.setParams({
            'eventId' : component.get('v.eventId')
        });
        event.fire();
    },
    
    handleDeleteMeeting : function(component, event, helper){
        /**
         * show spinner
         */
        helper.showSpinner(component, true);
        
        var action = component.get('c.deleteMeeting');
        action.setParams({
            'eventId' : component.get('v.eventId')
        });
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue()){
           			var eventDelete = component.getEvent('delete_meeting');
                    eventDelete.setParams({
                        'eventId' : component.get('v.eventId')
                    });
                    eventDelete.fire();
                    
                    helper.closeModal(component);
                }else{
                    alert('failed delete Meeting');
                }
            }
            
            /**
             * hide spinner
             */
            helper.showSpinner(component, false);
        });
        $A.enqueueAction(action);
	}
})