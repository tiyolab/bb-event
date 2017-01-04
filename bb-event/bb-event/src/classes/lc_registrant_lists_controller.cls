public with sharing class lc_registrant_lists_controller {
    
    @AuraEnabled
    public static List<Registrant__c> getRegistrants(){
        return [select Contact__r.FirstName, Contact__r.LastName, My_Event__r.Name, Registration_Status__c, Status__c from Registrant__c];
    }
    
    @AuraEnabled
    public static boolean cancelRegistration(Registrant__c registrant){
        Registrant_Session__c[] rs = [select Id from Registrant_Session__c where Registrant__c = :registrant.Id];
        try{
            update registrant;
            delete rs;
            return true;
        }catch(DMLException e){
            return false;
        }
    }
}