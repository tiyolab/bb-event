@RestResource(urlMapping='/Accounts/*')
global with sharing class AccountManager {
	@HttpGet
    global static Account getAccount(){
        RestRequest request = RestContext.request;
        String[] uriPath = request.requestURI.split('/', 0);
        String accountId = uriPath[uriPath.size() - 2];
        Account result = [SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account WHERE Id = :accountId];
        return result;
    }
}