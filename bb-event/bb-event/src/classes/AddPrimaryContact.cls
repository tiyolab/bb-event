public class AddPrimaryContact implements Queueable{
    private Contact contact;
    private String state;
    public AddPrimaryContact(Contact contact, String state){
        this.contact = contact;
        this.state = state;
    }
    
    public void execute(QueueableContext qc){
        List<Contact> contacts = new List<Contact>();
        
        for(Account c : [select Id from Account where BillingState = :this.state]){
            Contact clone = this.contact.clone(false);
            clone.AccountId = c.Id;
            contacts.add(clone);
        }
        
        insert contacts;
    }

}