({
	doInit : function(component, event, helper) {
		var action = component.get('c.getRegistrants');
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                    component.set('v.registrants', response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action);
	}
})