({
	createItem : function(component, newItem) {
		var items = component.get("v.items");
        var action = component.get("c.saveItem");
        
        action.setParams({
            "item" : newItem
        });
        action.setCallback(this, function(response){
            console.log(response.getError());
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                items.push(response.getReturnValue());
                component.set("v.items", items);
                
                newItem = {sobjectType:'Camping_Item__c', Name : ''};
        		component.set("v.newItem", newItem);
            }else{
                console.log("failed with state "+state);
            }
        });
        
        $A.enqueueAction(action);
	},
})