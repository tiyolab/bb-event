/**
 * how to run this scheduling report
 * by user this code on execute anonymous window
 * schedule every Friday at 10 am
 * 
 * schedule_report_to_director_marketing s = new schedule_report_to_director_marketing();
 * System.schedule('name you want', '0 0 10 ? * 6', s);
 **/

global class schedule_report_to_director_marketing implements Schedulable{
    global void execute(SchedulableContext ctx){
        PageReference pdf = System.Page.my_event_attachment;
        pdf.setRedirect(true);
        
        Blob b;
        if(Test.isRunningTest()){
            b = Blob.valueOf('UNIT.TEST');
        }else{
        	b = pdf.getContent();    
        }
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Global Telecom Company Event Report.pdf');
        efa.setBody(b);
        
        List<String> destination = new List<String>();
        for(User user : [select Email from User where UserRoleId in (select id from UserRole where Name = 'Director of Marketing')]){
            destination.add(user.Email);
        }
            
        Messaging.reserveSingleEmailCapacity(destination.size());
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	mail.setToAddresses(destination);
    	mail.setSenderDisplayName('Event Management of Global Telecom Company');
    	mail.setSubject('Event report');
        mail.setHtmlBody('<h3>Global Telecom Company</h3>');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});   
    }
}