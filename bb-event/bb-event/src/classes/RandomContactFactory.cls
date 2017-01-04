public class RandomContactFactory {
    public static List<Contact> generateRandomContacts(Integer numContc, String lastName){
        List<Contact> returnContc = new List<Contact>();
        for(Integer i = 0; i < numContc; i++){
            returnContc.add(new Contact(FirstName = 'Contact '+i, LastName = lastName));
        }
        
        return returnContc;
    }
}