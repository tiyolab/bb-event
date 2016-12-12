public class vms_meeting_time_controller {
    public DateTime t_start{set; get;}
    public DateTime t_end{set; get;}
    
    public String getTime(){
        String t_time = '';
        if(t_start == t_end){
            t_time = t_start.format();
        }else{
        	t_time = t_start.format() + ' - ' + t_end.format();    
        }
        
        return t_time;
    }
}