var globalComponent;
var globalHelper;

function setEventsToCalendar(calendarEvents){
	$("#calendar").fullCalendar('addEventSource', calendarEvents);
}

function synchronizeWithCalendar(mapMeeting){
	globalHelper.synchronize(globalComponent, mapMeeting);
}