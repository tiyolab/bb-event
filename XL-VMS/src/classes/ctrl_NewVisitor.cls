public class ctrl_NewVisitor {
	@AuraEnabled
    public static List<Contact> searchContact(String searchString){
        List<List<sObject>> result = [FIND :searchString + '*' IN ALL FIELDS RETURNING Contact(Id, FirstName, LastName, Email)];
        
        if(result.size() > 0){
            return (List<Contact>) result[0];
        }
        
        return null;
    }
}