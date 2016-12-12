({
	initCalendar : function(component, event, helper) {
        $("#calendar").fullCalendar({})
	},
    
    test : function(component, event, helper){
        console.log('run');
        
        var frames = window.frames || window.document.frames;
        frames["iframe"].window.test(this.frameSizeCallback);
        console.log('hello');
    },
    
    setFrameSize : function(component, event, helper){
        console.log('loaded');
        
        var frames = window.frames || window.document.frames;
        frames["iframe"].window.test(frameSizeCallback);
        console.log('hello');
    },
    
    frameSizeCallback : function(_height){
        console.log('height = ' + _height);
    }
})