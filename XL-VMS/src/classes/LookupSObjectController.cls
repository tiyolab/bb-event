/**
* Apex Controller for fetching the records as per search String inputted by user
*/
public with sharing class LookupSObjectController {
    /**
    * Aura enabled method to search a specified SObject for a specific string
    */
    @AuraEnabled
    public static SearchResult[] lookup(String searchString, String sObjectAPIName) {
        // escaped the input String
        String escapedSearchString = String.escapeSingleQuotes(searchString);
        String escapedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
         
        List<SearchResult> results = new List<SearchResult>();
         
        // Build our SOQL query
        String searchQuery = 'SELECT Id, Name FROM ' + escapedSObjectAPIName + ' WHERE Name LIKE ' + '\'%' + escapedSearchString + '%\'' + ' Limit 50';
        List<SObject> searchList = DataBase.query(searchQuery);
        // Create a list of matches to return
        for (SObject so : searchList)
        {
        results.add(new SearchResult((String)so.get('Name'), so.Id));
        }
         
        return results;
	}
 
    /**
    * Inner class to wrap up an SObject Label and its Id
    */
    public class SearchResult {
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}
         
        public SearchResult(String sObjectLabel, Id sObjectId) {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
}