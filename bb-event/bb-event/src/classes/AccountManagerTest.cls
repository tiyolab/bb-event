@isTest
public class AccountManagerTest {
	@isTest
    public static void testAccountManager(){
        Id accountId = createNewAccount();
        Id contactId1 = createNewContact(accountId);
        Id contactId2 = createNewContact(accountId);
        
        System.debug(accountId);
        
        RestRequest request = new RestRequest();
        request.requestURI = 'https://tiyolab-dev-ed.lightning.force.com/services/apexrest/Accounts/'+ accountId + '/contacts';
        request.httpMethod = 'GET';
        RestContext.request = request;
        Account account = AccountManager.getAccount();
        System.assert(account != null);
        System.assertEquals(account.Id, accountId);
        
        Contact[] tmp = [select Id from contact where AccountId = :account.Id];
        System.assert(tmp.size() > 0);
    }
    
    static Id createNewAccount(){
        Account account = new Account(Name = 'account-'+System.currentTimeMillis());
        insert account;
        
        return account.Id;
    }
    
    static Id createNewContact(Id accountId ){
        Contact c = new Contact(accountId = accountId, LastName = 'contact-'+System.currentTimeMillis());
        insert c;
        return c.Id;
    }
}