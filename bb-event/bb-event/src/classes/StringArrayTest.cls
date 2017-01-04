public class StringArrayTest {
    public static List<String> generateStringArray(Integer size){
        List<String> toReturn = new List<String>();
        for(Integer x = 0; x < size; x++){
            toReturn.add('Test '+x);
        }
        
        return toReturn;
    }
}