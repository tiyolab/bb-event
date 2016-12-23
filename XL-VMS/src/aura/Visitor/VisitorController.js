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
            if(component.isValid() && (response.getState != 'ERROR')){
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
    	var contacts = component.get("v.contacts");
        var contactMaps = component.get("v.contactMaps");
        var contactId = '';
        var sourceId = event.getSource().get("v.body");
        var toMeet = component.get("v.toMeet");
        var toMeetName = component.get("v.toMeetName");
        
        sourceId.forEach(function(value, index){
            if(value.getLocalId() == 'filter-result-value'){
                contactId = value.get("v.value");
            } 
        });
        
        if(contactId != ''){
            $('#host').val('');
            toMeet.push(contactMaps[contactId]);
            contacts = [];
            component.set("v.toMeet", toMeet);
            component.set("v.toMeetName", toMeet[0].FirstName + " " + toMeet[0].LastName);
            component.set("v.contacts", contacts);
            $('#toMeet').removeClass("slds-hide");
            $('#host').addClass("slds-hide");
        }
    },
    
    removeToMeet : function(component, event, helper){
        var toMeet = component.get("v.toMeet");
        var toMeetName = component.get("v.toMeetName");
        var contacts = component.get("v.contacts");
        
        toMeet = [];
        contacts = [];
        
        component.set("v.toMeet", toMeet);
        component.set("v.toMeetName", toMeetName);
        component.set("v.contacts", contacts);
        
        $('#toMeet').addClass("slds-hide");
        $('#host').removeClass("slds-hide");
    }
	
})