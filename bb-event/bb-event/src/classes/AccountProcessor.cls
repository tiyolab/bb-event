public class AccountProcessor {
	@Future
    public static void countContacts(List<String> accountIds){
        List<Account> listAccount = new List<Account>();
        Map<String, Integer> data = new Map<String, Integer>();
        
        for(AggregateResult a : [select AccountId, count(Id)cnt from Contact group by AccountId having AccountId in :accountIds]){
            data.put((String)a.get('AccountId'), (Integer)a.get('cnt'));
        }
        
        /*System.debug(data.size());*/
        
        for(String id : data.keySet()){
            Account a = [select Number_of_Contacts__c, Id from Account where Id = :id];
            /*System.debug(id +' = '+ data.get(id));
            System.debug(a.Id +' =1 '+ a.Number_of_Contacts__c);*/
            a.Number_of_Contacts__c = data.get(id);
            /*System.debug(a.Id +' =2 '+ a.Number_of_Contacts__c);*/
            listAccount.add(a);
        }
        update listAccount;
        
        /*for(Account a : [select Id, Number_of_Contacts__c from Account where Id in :accountIds]){
            System.debug(a.Id +' =again '+ a.Number_of_Contacts__c);
        }*/
    }
}