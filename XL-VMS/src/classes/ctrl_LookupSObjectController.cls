public with sharing class ctrl_LookupSObjectController {
	@AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName){
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        
        List<Result> results = new List<Result>();
        
        String searchQuery = 'FIND {' + sanitizedSearchString + '} IN Contact RETURNING ' + sanitizedSObjectAPIName + '(Id, Name)';
        
        List<List<SObject>> searchList = search.query(searchQuery);
        
        for(SObject so : searchList[0]){
            results.add(new Result((String)so.get('Name'), so.Id));
        }
        
        return results;
    }
    
    public class Result{
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}
        
        public Result(String sObjectLabel, Id sObjectId){
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
}