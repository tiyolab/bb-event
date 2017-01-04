public class test_page_controller {
    public String lastName {set; get;}
    public String profileName {set; get;}
    
    public PageReference init(){
        ID id = UserInfo.getProfileId();
        Profile f = [select Name from Profile where Id = :id];
        profileName = f.Name;
        
        return null;
    }
    
    public PageReference test(){
        Contact c = [select LastName from Contact where id = '0032800000gzVPcAAM'];
        c.LastName = lastName;
        c.FirstName = lastName;
        upsert c;
        return null;
    }
}