public class AnimalLocator {
    public static String getAnimalNameById(Integer id){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/'+id);
        if(id == 0){
            request.setMethod('POST');
        }else{
        	request.setMethod('GET');    
        }
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> animal = (Map<String, Object>)result.get('animal');
            return animal.get('name')+'';
            
        }
        return null;
    }
}