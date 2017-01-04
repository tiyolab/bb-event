public class ContactSearch {
    public static List<Contact> searchForContacts(String lastName, String mailingPostalCode){
        return [select Id, Name from Contact where LastName =: lastName and MailingPostalCode =: mailingPostalCode];
    }
}