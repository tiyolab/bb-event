public class c_home_controller {
    public Integer sizeMin {set; get;}
    public Integer sizeMedium {set; get;}
    public Integer sizeLarge {set; get;}
    public String bookingCode {set; get;}
    
    public My_Event__c[] getEvents(){
        DateTime today = System.now();
        My_Event__c[] data = [select Id, Name, Start_Date__c, End_Date__c, Registration_Deadline__c, Venue__r.City__c, Venue__r.State_Province__c, Venue__r.Country__c 
                from My_Event__c
                where Registration_Deadline__c >= :today and Availability_Status__c = 'Available'];
        
        if(data.size() > 0){
         	if(data.size() == 1){
                sizeMin = 1;
                sizeMedium = 1;
                sizeLarge = 1;
            }else if(data.size() == 2){
                sizeMin = 1;
                sizeMedium = 2;
                sizeLarge = 2;
            }else if(data.size() == 3){
                sizeMin = 1;
                sizeMedium = 2;
                sizeLarge = 3;
            }else{
                sizeMin = 1;
                sizeMedium = 2;
                sizeLarge = 4;
            }   
        }else{
            sizeMin = 1;
			sizeMedium = 1;
			sizeLarge = 1;
        }
        
        return data;
    }
    
    public PageReference Login(){
        Registrant__c[] r = [select Id from Registrant__c where Code__c = :bookingCode];
        
        if(r.size() == 0){            
        	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, c_event_constants.msg_invalid_booking_code);
        	ApexPages.addMessage(msg);    
            
            return null;
        }
        
        PageReference page = System.Page.c_my_event;
        page.getParameters().put('id', r[0].Id);
        page.setRedirect(true);
        
        return page;
    }
}