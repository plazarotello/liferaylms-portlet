<script src="https://player.vimeo.com/api/player.js"></script>

<script>
	document.addEventListener('DOMContentLoaded', function() { 		
		var iframe = document.getElementById('player_1');
		var player = new Vimeo.Player(iframe);
		
</script>

<c:forEach items="${questions }" var="questionElement">
	<script>
		player.addCuePoints('${questionElement.text}',{
			questionId: '${questionElement.name}'
		}).then(function(id){
			console.log(id);
			//player.pause();
		}).catch(function(error){
			switch(error.name){
				case 'UnsupportedError':
		            // cue points are not supported with the current player or browser
		            break;
	
		        case 'RangeError':
		            // the time was less than 0 or greater than the video’s duration
		            break;
	
		        default:
		            // some other error occurred
		            break;
			}
		});
	</script>
</c:forEach>

<script>
		
		var plays = parseInt('${plays}');
		var duration = 0;
		var currentTime = 0;
		var seekTo = parseInt('${seekTo}');
		var finished = false;
		
		player.ready().then(function() {
			console.log("ready ");
			player.getDuration().then(function(dur) {
				duration = dur;
			});	
			
			if (seekTo > 0){
				player.setCurrentTime(seekTo);
			}
		});
		   
		player.on('play',function(data) {
			finished = false;
			plays++;
		});	
		
		player.on('ended',function(data) {
			
			var serviceParameterTypes = [
			     	'long',
			     	'int',
			     	'double',
			    	'int'
			];
			
			var message = Liferay.Service.Lms.LearningActivityTry.update(
				{
					latId: '${latId}',
					score: 100,
					position: duration,
					plays: plays,
					serviceParameterTypes: JSON.stringify(serviceParameterTypes)
				}
			);
			      	
			var exception = message.exception;
			            
			if (!exception) {
				// Process Success - A LearningActivityResult returned
				finished = true;	
				Liferay.Portlet.refresh('#p_p_id_activityNavigator_WAR_liferaylmsportlet_');
				Liferay.Portlet.refresh('#p_p_id_lmsactivitieslist_WAR_liferaylmsportlet_');
				var src = 	document.getElementById("player_1").src;
				var index = src.indexOf("background");
				if(index > 0){
					src = src.substring(0,index-1);
					document.getElementById("player_1").src = src;
				}
			}									
		}
		
		var unloadEvent = function (e) {
			console.log("unload event vimeo");  
			if(!finished){
				player.getCurrentTime().then(function(time) {
					currentTime = time;
						
					var isDefaultScore = '${isDefaultScore}' == 'true';
					var positionToSave = parseFloat('${videoPosition}');
					var oldScore = parseInt('${oldScore}');
					if (currentTime > positionToSave)
						positionToSave = currentTime;
					var score = 100;														
					if (!isDefaultScore) score = Math.round((currentTime/duration)*100);
					//debugger;
					var serviceParameterTypes = [
				     	'long',
				     	'int',
				     	'double',
				    	'int'
				    ];
					var message = Liferay.Service.Lms.LearningActivityTry.update(
						{
							latId: '${latId}',
							score: score,
							position: positionToSave,
							plays: plays,
							serviceParameterTypes: JSON.stringify(serviceParameterTypes)
						}
					);
					
					var exception = message.exception;
							
					if (!exception) {
						// Process Success - A LearningActivityResult returned
					}														
				});	
			  
			}
		};
		
		window.addEventListener("beforeunload", unloadEvent);										
	
	});

</script>					
							