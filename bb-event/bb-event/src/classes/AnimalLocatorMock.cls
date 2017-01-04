global class AnimalLocatorMock implements HttpCalloutMock{
    global HTTPResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"animal":{"id":1,"name":"ayam","eats":"ayam","says":"cukruyuk"}}');
        if (request.getMethod() == 'GET'){
        	response.setStatusCode(200);	    
        }else{
            response.setStatusCode(500);
        }
		
        
        return response;
    }
}