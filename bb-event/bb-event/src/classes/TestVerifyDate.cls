@isTest
private class TestVerifyDate {
    @isTest static void testCheckDatesInPast(){
        Date myDate = VerifyDate.CheckDates(Date.today(), Date.today().addDays(-2));
        System.assertEquals(
            Date.newInstance(
                Date.today().year(), 
                Date.today().month(), 
                Date.daysInMonth(Date.today().year(), Date.today().month())),
            myDate
        );
    }
    
    @isTest static void testCheckDatesWithin(){
        Date myDate = VerifyDate.CheckDates(Date.today(), Date.today().addDays(3));
        System.assertEquals(
            Date.today().addDays(3),
            myDate
        );
    }
}