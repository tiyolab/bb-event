@isTest
public class test_my_event_attachment {
    /**
     * this test to ensure that data of event that send to director of marketing is valid
     */
	@isTest
    public static void testGetData(){
        Integer inProgSize = 0;
        Integer onGoingSize = 0;
        
        List<My_Event__c> events = new List<My_Event__c>();
        
        datetime tmpRegDeadline = datetime.now() + 1;
        datetime tmpStartDate = tmpRegDeadline + 1;
        datetime tmpEndDate = tmpStartDate + 1;
        
        Venue__c v = test_data_factory.getVenue();
        
        for(Integer i = 0; i < 10; i++){
            My_Event__c me = new My_Event__c(
                        Availability_Status__c = 'Available',
                        End_Date__c = tmpEndDate,
                        Limit__c = 100,
                        Name = 'event ' + i,
                        Registration_Deadline__c = tmpRegDeadline,
                        Start_Date__c = tmpStartDate,
                        Venue__c = v.Id
                    );
            
            Integer x = Integer.valueOf(Math.random() * 10);
            
            if(Math.mod(x, 2) == 0){
                me.Status__c = 'On Going';
                onGoingSize++;
            }else{
                me.Status__c = 'In Progress';
                inProgSize++;
            }
            
            events.add(me);
        }
        
        insert events;
        
        c_my_event_attachment_controller cn = new c_my_event_attachment_controller();
        cn.init();
        
        System.assertEquals(onGoingSize, cn.event_size.get('on Going Events'));
        System.assertEquals(inProgSize, cn.event_size.get('in Progress Events'));
    }
}