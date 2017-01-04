@isTest
private class TestRestrictContactByName {
    @isTest static void testInvalidContact(){
        Test.startTest();
        Database.SaveResult r  = Database.insert(new Contact(LastName = 'INVALIDNAME'), false);
        Test.stopTest();
        
        System.assert(!r.isSuccess());
        System.assert(r.getErrors().size() > 0);
        System.assertEquals('The Last Name "INVALIDNAME" is not allowed for DML', r.getErrors()[0].getMessage());
    }
    
    @isTest static void testValidContact(){
        Test.startTest();
        Database.SaveResult r  = Database.insert(new Contact(LastName = 'Another'), false);
        Test.stopTest();
        
        System.assert(r.isSuccess());
        System.assert(r.getErrors().size() == 0);
    }
    
    @isTest static void testInvalidBulk(){
        Test.startTest();
        Database.SaveResult[] r  = Database.insert(
            new Contact[]{
                new Contact(LastName = 'Valid'),
                new Contact(LastName = 'INVALIDNAME'),
                new Contact(LastName = 'Another valid')
            }
            , false);
        Test.stopTest();
        
        System.assert(!r[1].isSuccess());
        System.assert(r[1].getErrors().size() > 0);
        System.assertEquals('The Last Name "INVALIDNAME" is not allowed for DML', r[1].getErrors()[0].getMessage());
    }
}