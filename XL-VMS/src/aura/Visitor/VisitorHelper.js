({
	displayLoadingInfo : function(isDisplay, message) {
		var displayLoading = '';
        var displayMessage = '';
        
        if(isDisplay){
            displayLoading = 'block';
        }else{
            displayLoading = 'none';
        }
        
        if(message.length > 0){
            displayMessage = 'block';
            $('#message_info').html(message);
        }else{
            displayMessage = 'none';
            $('#message_info').html('');
        }
        
        $('#loading_info').css('display', displayLoading);
        $('#message_info').css('display', displayMessage);
	}
})