({
	search : function(component, event, helper) {
		helper.doSearch(component);
	},
    
    select : function(component, event, helper){
    	console.log("--- inside select ---");
        helper.doSelection(component, event);
	}
})