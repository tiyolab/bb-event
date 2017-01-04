public class ContactAndLeadSearch {
    public static List<List<SObject>> searchContactsAndLeads(String target){
        return [FIND :target IN ALL FIELDS RETURNING Contact, Lead];
    }
}