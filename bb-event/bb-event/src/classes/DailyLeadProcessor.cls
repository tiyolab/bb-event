global class DailyLeadProcessor implements Schedulable{
    global void execute(SchedulableContext sc){
        List<Lead> leads = new List<Lead>();
        for(Lead l : [select Id from Lead where LeadSource = '']){
            l.LeadSource = 'Dreamforce';
            leads.add(l);
        }
        
        update leads;
    }
}