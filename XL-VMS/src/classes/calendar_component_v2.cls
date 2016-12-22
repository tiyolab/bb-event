global with sharing class calendar_component_v2 {
    public static String requestLabel;
    
    /**
     * action request
     */
    @RemoteAction
    global static Object startRequest(Boolean tmp){
        Continuation con = new Continuation(60);
        //assign the callback method
        con.continuationMethod = 'responseMethod';
        
        //create callout request
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('http://xl-wms.hol.es/test.php');
        
        //add http request to continuation
        requestLabel = con.addHttpRequest(request);
        
        return con;
    }
    
    /**
     * callback method
     */
    @RemoteAction
    global static Object responseMethod(){
        HttpResponse response = Continuation.getResponse(requestLabel);
        System.debug('response = ' + response.getBody());
        return null;
    }
}