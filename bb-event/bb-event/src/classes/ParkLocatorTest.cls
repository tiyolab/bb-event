@isTest
public class ParkLocatorTest {
	@isTest
    public static void testByCountry(){
        Test.setMock(WebServiceMock.class, new ParkServiceMock());
        System.assert(ParkLocator.country('Germany').size() > 0);
    }
}