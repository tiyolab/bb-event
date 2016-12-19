({
    searchHost : function(component, event, helper){
        var searchString = $('#host').val();
        
        if(searchString.length < 2 && searchString.length > 0) {
            helper.displayLoadingInfo(false, 'At least 2 characters');
            return;
        }else if(searchString.length == 0){
            $('#loading_info').css('display', 'none');
        	$('#message_info').css('display', 'none');
            $('#listContact').css('display', 'none');
            searchString = '';
            return;
        }else{
            $('#listContact').css('display', 'block');
            helper.displayLoadingInfo(true, '');
        }
        
        var action = component.get('c.searchContact');
        action.setParams({
            'searchString' : searchString 
        });
        
        action.setCallback(this, function(response){
            console.log("State = " + response.getState());
            console.log("Valid = " + component.isValid());
            if(component.isValid() && (response.getState != 'ERROR')){
                console.log("opo");
                if(response.getReturnValue != null){
                    var contactMaps = component.get("v.contactMaps");
                    
                    component.set("v.contacts", response.getReturnValue());
                    var contacts = component.get("v.contacts");
                    
                    contacts.forEach(function(value, index){
                       contactMaps[value.Id] = value; 
                    });
                    
                    component.set("v.contactMaps", contactMaps);
                }
            }
            helper.displayLoadingInfo(false, '');
        });
        
        $A.enqueueAction(action);
    },
    
    onFilterClicked : function(component, event, helper){
        
    }
	
})