public class c_event_helper {
	
    public static Boolean isEmailValid(String email) {
        Boolean res = true;
            
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: https://developer.salesforce.com/forums/?id=906F000000092GXIAY
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (!MyMatcher.matches()) 
            res = false;
        return res;	
	}
    
    public static String generateRandomCode(){
        Long tmp = DateTime.now().getTime();
        //Long tmp = num;
        String hexa = '';
        Long result = 0;
        Long reminder = 0;
        while(true){
            if(tmp <= 0){
                break;
            }
            
            result = tmp / 16;
            reminder = Math.mod(tmp, 16);
            
            hexa += numberToString(reminder);
            tmp = result;
        }
        System.debug('hexa'+hexa);
        return hexa;
    }
    
    public static String generateHashCode(){
        String feed = (DateTime.now().getTime() * DateTime.now().year()) + '';
        return EncodingUtil.base64Encode(Blob.valueOf(feed));
    }
    
    private static String numberToString(Long num){
        if(num == 10){
            return 'O';
        }else if(num == 11){
            return 'B';
        }else if(num == 12){
            return 'Z';
        }else if(num == 13){
            return 'H';
        }else if(num == 14){
            return 'E';
        }else if(num == 15){
            return 'L';
        }else{
         	return num+'';   
        }
    }
}