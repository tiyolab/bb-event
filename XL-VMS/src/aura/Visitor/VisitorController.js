({

	doInit : function(component, event, helper) {
	var action = component.get("c.getCurrentUserProfile");
	action.setCallback(this, function(response) {
	var state=response.getState();
	component.set("v.currentUserProfile", response.getReturnValue());
	});
    $A.enqueueAction(action);
	}
})