({
	createItem : function(component, item) {
        var event = component.getEvent("addItem");
        event.setParams({"item" : item});
        event.fire();
        
		item = {sobjectType:'Camping_Item__c', Name : ''};
        component.set("v.newItem", item);
	}
})