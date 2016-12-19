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
			$('#message_info').html(message.join());            
        }else{
            displayMessage = 'none';
            $('#message_info').html('');
        }
        
		$('#loading_info').css('display', displayLoading);
        $('#message_info').css('display', displayMessage);
	},
    
    showSpinner : function(component, isShow){
        var event = component.getEvent('toggle_spinner');
        event.setParams({
            'isShow' : isShow
        });
        event.fire();
    },
    
    sendToRest : function(requestUrl, method, meetings){
        /*var xHttp;
        if(window.XMLHttpRequest){
            xHttp = new XMLHttpRequest();
        }else{
            xHttp = new ActiveXObject('Microsoft.XMLHTTP');
        }
        xHttp.onreadystatechange = function(){
            if(this.readyState == 4 && this.status == 200){
                //response
            }
        };
        xHttp.open(method, url, true);
        xHttp.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
        xHttp.send(JSON.stringify(meetings));*/
        console.log(JSON.parse(meetings));
        $.ajax({
            url: requestUrl,
            type: method,
            contentType: 'application/json',
            xhrFields: {
                withCredentials: false
            },
            data: JSON.parse(meetings),
            success: function(response){
                console.log(response);
            },
            error: function(error){
                console.log(error)
            }
        });
    }
})