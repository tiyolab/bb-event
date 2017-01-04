({
	submitForm : function(component, event, helper) {
		var validCampingItem = true;
        
        var nameField = component.find("ci_name");
        var quantityField = component.find("ci_quantity");
        var priceField = component.find("ci_price");
        
        //validate name field
        if($A.util.isEmpty(nameField.get("v.value"))){
            validCampingItem = (validCampingItem) ? false : validCampingItem;
            nameField.set("v.errors", [{message:"Camping item name can't be blank."}]);
        }else{
            nameField.set("v.errors", null);
        }
        
        //validate quantity field
        if($A.util.isEmpty(quantityField.get("v.value"))){
            validCampingItem = (validCampingItem) ? false : validCampingItem;
            quantityField.set("v.errors", [{message:"Camping item quantity can't be blank."}]);
        }else{
            quantityField.set("v.errors", null);
        }
        
        //validate price field
        if($A.util.isEmpty(priceField.get("v.value"))){
            validCampingItem = (validCampingItem) ? false : validCampingItem;
            priceField.set("v.errors", [{message:"Camping item price can't be blank."}]);
        }else{
            priceField.set("v.errors", null);
        }
        
        if(validCampingItem){
            helper.createItem(component, component.get("v.newItem"));
        }
	}
})