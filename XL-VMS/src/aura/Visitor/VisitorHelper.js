({
	doSearch : function(component) {
		var searchString = component.get("v.searchString");
        var lookuplist = component.find('lookup-list');
        
        //if search string < 2 char then hide lookup
        if(typeof searchString === 'undefined' || searchString.length < 2){
            $A.util.addClass(lookuplist, 'slds-hide');
        }
        
        $A.util.removeClass(lookuplist, 'slds-hide');
        var action = component.get("c.lookup");
        
        //prevent multiple event to keyup
        action.setAbortable();
        
        action.setParams({
            "searchString" : searchString,
            "sObjectAPIName" : "Contact"
        });
        
        //Set callback
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() == 'SUCCESS'){
                if(response.getReturnValue() != null){
                    var matchingResult = response.getReturnValue();
                    
                    //no match
                    if(matchingResult.length == 0){
                        component.set("v.matchingResult", null);
                        console.log("MISSMATCH");
                        return;
                    }
                    
                    //if match
                    component.set("v.matchingResult", matchingResult);
                    console.log("MATCH");
                }
            }else if(response.getState() == 'ERROR'){
                var error = response.getError();
                
                if(error){
                    console.log(error[0].message);
                }
            }
        });
        
        //Enqueue action
        $A.enqueueAction(action);
	},
    
    doSelection : function(component, event){
        console.log("--- Inside doSelection ---");
        var recId = this.getSelectedRecordId(event.currentTarget.id);
    }
})