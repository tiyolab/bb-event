public class c_http_mock{
    public static HTTPResponse respond(){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'applicaton/json');
        res.setBody(generate());
        res.setStatusCode(200);
        
        return res;
    }
    
    public static String generate(){
        Map<Object, Object> data = new Map<Object, Object>();
        data.put('StatusDesc', 'success');
        data.put('StatusCode', '0');
        
        Map<Object, Object> MetaData = new Map<Object, Object>();
        Map<Object, Object> HotelMetaData = new Map<Object, Object>();
        
        List<Map<Object, Object>> Amenities = new List<Map<Object, Object>>();
        Map<Object, Object> Amenities0 = new Map<Object, Object>();
 		Amenities0.put('Code', 'BC');
        Amenities0.put('Description', 'Guests have access to business equipment and services; an additional charge may apply.');
        Amenities0.put('Name', 'Business center');
        
        Map<Object, Object> Amenities1 = new Map<Object, Object>();
 		Amenities1.put('Code', 'CI');
        Amenities1.put('Description', 'Property offers free internet access in all rooms');
        Amenities1.put('Name', 'Free Internet');
        
        Amenities.add(Amenities0);
        Amenities.add(Amenities1);
        
        List<Map<Object, Object>> Neighborhoods = new List<Map<Object, Object>>();
        Map<Object, Object> Neighborhoods0 = new Map<Object, Object>();
        Neighborhoods0.put('City', 'Kuala Lumpur');
        Neighborhoods0.put('Country', 'MY');
        Neighborhoods0.put('Id', '93618');
        Neighborhoods0.put('Name', 'Golden Triangle South - Bukit Bintang');
        Neighborhoods0.put('State', 'MY');
        
        Map<Object, Object> Neighborhoods1 = new Map<Object, Object>();
        Neighborhoods1.put('City', 'Kuala Lumpur');
        Neighborhoods1.put('Country', 'MY');
        Neighborhoods1.put('Id', '94248');
        Neighborhoods1.put('Name', 'Chow Kit');
        Neighborhoods1.put('State', 'MY');
        
        Neighborhoods.add(Neighborhoods0);
        Neighborhoods.add(Neighborhoods1);
        
        HotelMetaData.put('Amenities', Amenities);
        HotelMetaData.put('Neighborhoods', Neighborhoods);
        
        MetaData.put('HotelMetaData', HotelMetaData);
        data.put('MetaData', MetaData);
        
        List<Map<Object, Object>> Result = new List<Map<Object, Object>>();
        Map<Object, Object> Result0 = new Map<Object, Object>();
        Result0.put('CurrencyCode', 'USD');
        Result0.put('AveragePricePerNight', '40.00');
        Result0.put('StarRating', '4.0');
        Result0.put('NeighborhoodId', '93618');
        
        Map<Object, Object> Result1 = new Map<Object, Object>();
        Result1.put('CurrencyCode', 'USD');
        Result1.put('AveragePricePerNight', '45.00');
        Result1.put('StarRating', '3.5');
        Result1.put('NeighborhoodId', '94248');
        
        Result.add(Result0);
        Result.add(Result1);
        
        data.put('Result', Result);
        
        return JSON.serialize(data);
    }
}