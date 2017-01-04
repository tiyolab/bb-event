({
	packItem : function(component, event, helper) {
		var tmpItem = component.get("v.item");
        tmpItem.Packed__c = true;
        component.set("v.item", tmpItem);
        event.getSource().set("v.disabled", true);
	}
})