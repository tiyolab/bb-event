public class BusinessCardController_c {
    public String toEmail {set; get;}
    
    public PageReference send(){
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{toEmail});
        mail.setSenderDisplayName(User.Name + '');
        mail.setSubject('My Contact');
        mail.setPlainTextBody('First Name : ' + User.FirstName + '\nLast Name : ' + User.LastName + '\nEmail : ' + User.Email + '\nPhone : ' + User.Phone + '\nTitle : ' + User.Title);
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        
        
        return null;
    }
}