public class AccountHandler {
    public static Account insertNewAccount(String name){
        Account act = new Account(Name = name);
        try{
            insert act;
            return [select Name from Account where Id =: act.Id];
        }catch(DmlException e){
            return null;
        }
    }
}