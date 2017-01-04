({
	cancel : function(component, event, helper) {
        var registrant = component.get('v.registrant');
        registrant.Status__c = 'Canceled';
        
        var action = component.get('c.cancelRegistration');
        action.setParams({
            'registrant' : registrant
        });
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue()){
                    alert('Success cancel the current registration.');
                }else{
                    alert('Failed cancel the current registration.');
                }
                
                component.set('v.registrant', registrant);
            }
        });
        
        $A.enqueueAction(action);
	},
    
    detail : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get('v.registrant').Id,
        });
        navEvt.fire();
    }
})