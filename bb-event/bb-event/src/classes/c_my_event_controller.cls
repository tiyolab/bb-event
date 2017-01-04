public class c_my_event_controller {
	private String registrantId = '';
    private String hash = '';
    private String bookingCode = '';
    private boolean fromEmail = false;
    
    // Unique label corresponding to the continuation
    public String requestLabel;
    
    public boolean showCompleteMessage {set; get;}
    public boolean showIncompleteMessage {set; get;}
    public Map<String, Hotel> hotel {set; get;}
    public String responseBody {set; get;}
    
    public Registrant__c registrant {set; get;}
    
    public PageReference validate(){
        String tmpId = ApexPages.currentPage().getParameters().get('id');
        //String tmpId = 'a0I2800000DVKodEAH';
        
        /**
         * prevent blank/null id at url parameter
         */
        if(tmpId == null || string.isBlank(tmpId)){
            return redirect(System.Page.c_home);
        }
        
        /**
         * if decode not null so it come from email otherwise it come from website
         * if come from email decode the id to get hash, registrantId and booking code
         * if come from website it just registrant id
         */
        String[] part = decodeId(tmpId);
        Registrant__c[] tmpRegistrants = new List<Registrant__c>();
        if(part != null){
            fromEmail = true;
            
            hash = part[0];
            registrantId = part[1];
            bookingCode = part[2];
            
            /**
             * validate if registrantId, booking code and hash is valid
             */
            tmpRegistrants = [select Id, Registration_Status__c,
                                                My_Event__r.Name, My_Event__r.Start_Date__c, My_Event__r.End_Date__c,
                                                My_Event__r.Venue__r.Name, My_Event__r.Venue__r.Address__c, My_Event__r.Venue__r.City__c, 
                                                  My_Event__r.Venue__r.State_Province__c, My_Event__r.Venue__r.Country__c, My_Event__r.Venue__r.Phone__c,
                                                (select My_Event_Session__r.Name, My_Event_Session__r.Start_Session__c, My_Event_Session__r.End_Session__c from Registrant_Sessions__r)
                                                from Registrant__c
                                                where Id = :registrantId and Code__c = :bookingCode and Hash__c = :hash];
        }else{
            fromEmail = false;
            
            registrantId = tmpId;
            
            /**
             * validate if registrantId is valid
             */
            tmpRegistrants = [select Id, Registration_Status__c,
                                                My_Event__r.Name, My_Event__r.Start_Date__c, My_Event__r.End_Date__c,
                                                My_Event__r.Venue__r.Name, My_Event__r.Venue__r.Address__c, My_Event__r.Venue__r.City__c, 
                                                  My_Event__r.Venue__r.State_Province__c, My_Event__r.Venue__r.Country__c, My_Event__r.Venue__r.Phone__c,
                                                (select My_Event_Session__r.Name, My_Event_Session__r.Start_Session__c, My_Event_Session__r.End_Session__c from Registrant_Sessions__r)
                                                from Registrant__c
                                                where Id = :registrantId];
        }
        
        /**
         * prevent invalid registrant
         */
        if(tmpRegistrants.size() == 0){
            return redirect(System.Page.c_home);
        }
        registrant = tmpRegistrants[0];
        
        /**
         * change registration status Complete if incomplete
         */
        if(registrant.Registration_Status__c == 'Incomplete' && fromEmail){
            Registrant__c toUpdateRegsitrant = new Registrant__c(Id = registrant.Id, Registration_Status__c = 'Complete');
            upsert(toUpdateRegsitrant);
            
            showCompleteMessage = true;
            showIncompleteMessage = false;
        }else if(registrant.Registration_Status__c == 'Incomplete' && !fromEmail){
            showCompleteMessage = false;
            showIncompleteMessage = true;
        }else{
            showCompleteMessage = false;
            showIncompleteMessage = false;
        }
        
        return null;
    }
    
    public Object requestHotel(){
		// Create continuation with a timeout
		Continuation con = new Continuation(40);
        
        // Set callback method
        con.continuationMethod='processResponse';
        
        Datetime startDate = registrant.My_Event__r.Start_Date__c;
        Datetime endDate = registrant.My_Event__r.End_Date__c;
        
        System.debug('start ' + startDate);
        
        String strStartDate = 
            (((String.valueOf(startDate.month())).length()==1) ? '0' + String.valueOf(startDate.month()) : String.valueOf(startDate.month())) +'/'+
            (((String.valueOf(startDate.day())).length()==1) ? '0' + String.valueOf(startDate.day()) : String.valueOf(startDate.day())) +'/'+
            (((String.valueOf(startDate.year())).length()==1) ? '0' + String.valueOf(startDate.year()) : String.valueOf(startDate.year()));
        
        String strEndDate = 
            (((String.valueOf(endDate.month())).length()==1) ? '0' + String.valueOf(endDate.month()) : String.valueOf(endDate.month())) +'/'+
            (((String.valueOf(endDate.day())).length()==1) ? '0' + String.valueOf(endDate.day()) : String.valueOf(endDate.day())) +'/'+
            (((String.valueOf(endDate.year())).length()==1) ? '0' + String.valueOf(endDate.year()) : String.valueOf(endDate.year()));
        
        // Create callout request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String url = '?apikey=sn2g78gu9nbh672ar4qedxux'+
                            '&dest='+registrant.My_Event__r.Venue__r.Address__c+'&format=JSON&rooms=1'+
                            '&startdate='+strStartDate+
                            '&enddate='+strEndDate+'&children=0&adults=1';
        url = 'http://api.hotwire.com/v1/search/hotel' + url.replace(' ', '+').replace('/', '%2F');
        System.debug(url);
        request.setEndpoint(url);
        //request.setEndpoint('http://api.hotwire.com/v1/search/hotel?apikey=sn2g78gu9nbh672ar4qedxux&dest=kuala+lumpur&format=JSON&rooms=1&startdate=10%2F31%2F2016&enddate=11%2F01%2F2016&children=0&adults=1');
        request.setMethod('GET');
        
        // Add callout request to continuation
        this.requestLabel = con.addHttpRequest(request);
		// Return the continuation        
        return con;
    }
    
    public Object processResponse() {
        HttpResponse response = Continuation.getResponse(this.requestLabel);
        System.debug('response code = ' + response.getStatusCode());
        System.debug('response body = ' + response.getBody());
        
        if(response.getStatusCode() == 200){
            
            responseBody = response.getBody();
            System.debug('response body = ' + response.getBody());
            
            Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            if(jsonResponse.get('StatusDesc') == 'success'){
                Map<String, Amenity> resultAmenity = new Map<String, Amenity>();
                Map<String, Neighborhood> resultNeighborhood = new Map<String, Neighborhood>();
                Map<String, Hotel> resultHotel = new Map<String, Hotel>();
                
                //parse metadata
                Map<String, Object> metaData = (Map<String, Object>)jsonResponse.get('MetaData');
                Map<String, Object> hotelMetadata = (Map<String, Object>)metaData.get('HotelMetaData');
                List<Object> amenities = (List<Object>)hotelMetadata.get('Amenities');
                List<Object> neighborhoods = (List<Object>)hotelMetadata.get('Neighborhoods');
                
                for(Object x : amenities){
                    Map<String, Object> amenitie = (Map<String, Object>)x;
                    Amenity a = new Amenity();
                    
                    a.code = (String)amenitie.get('Code');
                    a.description = (String)amenitie.get('Description');
                    a.name = (String)amenitie.get('Name');
                    resultAmenity.put((String)amenitie.get('Code'), a);
                }
                
                for(Object x : neighborhoods){
                    Map<String, Object> neighborhood = (Map<String, Object>)x;
                    Neighborhood n = new Neighborhood();
                    
                    n.id = (String)neighborhood.get('Id');
                    n.city = (String)neighborhood.get('City');
                    n.country = (String)neighborhood.get('Country');
                    n.name = (String)neighborhood.get('Name');
                    n.state = (String)neighborhood.get('State');
                    resultNeighborhood.put((String)neighborhood.get('Id'), n);
                }
                
                //parse hotel
                List<Object> results = (List<Object>)jsonResponse.get('Result');
                for(Object x : results){
                    Map<String, Object> result = (Map<String, Object>)x;
                    Hotel h = new Hotel();
                    List<Amenity> tmpAmenity =  new List<Amenity>();
                    
                    h.currencyCode = (String)result.get('CurrencyCode');
                    h.pricePerNight = (String)result.get('AveragePricePerNight');
                    h.rating = (String)result.get('StarRating');
                    h.neighborhood = resultNeighborhood.get((String)result.get('NeighborhoodId'));
                    /*for(Object amenityCode : (List<Object>)result.get('AmenityCodes')){
                        tmpAmenity.add(resultAmenity.get((String)amenityCode));
                    }*/
                    h.amenity = tmpAmenity;
                    if(resultHotel.get(h.neighborhood.id) == null){
                      resultHotel.put(h.neighborhood.id, h);    
                    }
                    
                }
                
                hotel = resultHotel; 
                System.debug('hotel = '+hotel);
            }
        }
        return null;
    }
    
    public class Hotel {
        public Neighborhood neighborhood {set; get;}
        public List<Amenity> amenity {set; get;}
        public String currencyCode {set; get;}
        public String pricePerNight {set; get;}
        public String rating {set; get;}
    }
    
    public class Neighborhood{
        public String id {set; get;}
        public String city {set; get;}
        public String country {set; get;}
        public String name {set; get;}
        public String state {set; get;}
    }
    
    public class Amenity{
        public String code {set; get;}
        public String description {set; get;}
        public String name {set; get;}
    }
    
    private String[] decodeId(String id){
        String tmpId = '';
        try{
        	tmpId = EncodingUtil.base64Decode(id).toString();    
        }catch(StringException e){
            return null;
        }
        
        if(tmpId.contains('@~@')){
            return tmpId.split('@~@');
        }
        return null;
    }
    
    private PageReference redirect(PageReference destination){
		PageReference redirect = destination;
		redirect.setRedirect(true);
      	return redirect;        
    }
}