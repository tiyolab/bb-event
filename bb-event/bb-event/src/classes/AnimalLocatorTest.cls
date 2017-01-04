@isTest
public class AnimalLocatorTest {
	@isTest
    public static void testAnimalSuccess(){
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        System.assertEquals('ayam', AnimalLocator.getAnimalNameById(1));
    }
    
    @isTest
    public static void testAnimalFailed(){
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        System.assertEquals(null, AnimalLocator.getAnimalNameById(0));
    }
}