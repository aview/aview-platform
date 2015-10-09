/*String that includes connectionstring and parameters for streaming
parameters include capRect,codec and bitrate */
var streamparams="";
//screen area that is captured to share
var capRect="0,0,320,240";
//set to true if screen is shared
var isStreaming=false;
//saves the current capRect (streamingDimensions) for comparison when capturing frame is resized
var streamDimensions ="" ;
//the new frame that needs to be captured after resizing
var resizeRect="";
//FullScreen/application/screen Area
var streamingOption="";
//OS of client
var os="";
//version of browser
var version="";
//browser
var browser="";
//moviename/flex application name
var thisMovie="";
//connection string
var connectionString="";

/* 
   This function will be invoked from the flex application
   The connection string (link to rtmp server /application/instance+streamname),screenarea(x,y,width height)
   and selected option(fullscreen/selected area/application) will be passed to this function
*/
function shareScreen(connectString,screenCapRect,option)
{
  streamingOption=option;
  var connectParams=connectString.split("\\");
  connectionString=connectParams[0];
  switch(option)
  {
    // if fullscreen is selected by the user then the area of whole desktop will be calculated  and saved into "capRect"
    case "FullScreen":
    			//Fix for issue #17747
				capRect=screenCapRect;
				streamparams=connectString;
	break;
	//if selected area is selected by the user then the value of screencapRect will be saved into capRect
	case "Selected Area":
				capRect=screenCapRect;
				streamparams=connectString;	         
	break;
	case "Application":
	            capRect=screenCapRect;
	            streamparams=connectString;
	            
	break;	
	
  }
  // saves the current screen area 
   streamDimensions=capRect;
   
   //start screen sharing
   startStreaming();
}

//Function is used to call the methods that starts streaming.
function startStreaming()
{
    //if sharing application   
	if(streamingOption=="Application")
	{
		//the method that starts publishing application
		document.JScrCapsw.start_streaming("0", streamparams);
	}
	//else sharing selected area/full of screen
	else
	{
		//the method that starts publishing screen
		document.JScrCap.start_streaming("0", streamparams);
 	}
}

//Function is used to call the methods that stops streaming.
function stopStreaming()
{
	//the method that stops publishing
	if(streamingOption=="Application")
	{
		document.JScrCapsw.stop_streaming("0");
	}
	else
	{
		document.JScrCap.stop_streaming("0");
	}
}

//This method will be invoked when the capture area is resized
function resizeJScrCap() 
{
	isResizing = true;	
	stopStreaming();
	capRect=resizeRect;
	streamparams=connectionString+"\\\\vsrc:screen:"+capRect+"\\vid:-svc2&bits:4";
	startStreaming();
}

//This method will be invoked when the capture area is moved
function moveJScrCap() 
{
    document.JScrCap.move_area("0", capRect);
}

/* Invoked from flex application and returns the running applications list to flex application
param movieName- name of the flex application swf file eg.main*/
function getAppsList(movieName)
{
	//retrieves the applicationList
	var windowList=document.JScrCapsw.getApplicationsList();

	//retrieves the desktop  area 
	var rect=document.JScrCapsw.get_fulldesktoprect();

	//sends the applications list to flex
	getFlashMovie(movieName).sendAppList(windowList,rect);
}

//not used now; it was used for their player (SMLPlayer) sets the stream configuration in player.
/*function sendPlayerConfiguration(movieName,configuration)
{
	getFlashMovie(movieName).SetConfiguration(configuration);
}
//function to send the local connection name to player
function setLocalConnection(movieName,lid)
{
	getFlashMovie(movieName).SetConnectionChannel(lid);
}*/

/*
Event Listener for jscrcap events
The Event handler for jscrcap event
Each event consist of an operation,code and description
Event					Opreation				code						Description
Loaded 					Load 					succeeded 					load succeeded
Connecting 				Connection 				open
Disconnecting 			Connection 				close
Connected 				connect result 			** 							**
Publish 				publish status 			(status of netstream)		**
Click button 			frame_action 			Id 							frame button id clicked
Click panel 			frame_bounds 			x,y,width,height			new frame bounds start
																			new frame bounds end
Move panel 				frame_bounds 			x,y,width,height 			new frame bounds move
Resize capture area 	frame_bounds 			x,y,width,height 			new frame bounds resize
Countdown done 			count down 				finished 					wizard dialog
Error 					init 					exception
*/
function JScrCap_Event(operation, code, desc) 
{
	//operation 
	switch(operation)
	{
		case "load":
				//TODO: check whether OS details are needed
				getOSDetails();
			break;
		case "connection":
				//code : open/close/bandwidthusage
				if(code=="close")
				{
					//if connection is closing and the screen is getting shared which means the frame is displayed on your screen remove the frame
					if(isStreaming )
					{
						if(streamingOption!="Application")
						{
							document.JScrCap.update_frame("0,4,000000,16776960,320x240,1918x1198",capRect);
						}
						isStreaming=false;
						//TODO: get moviename from flex app
						getFlashMovie("mainWeb").sendPublishStatus(code,capRect);
					}
				}
			break;
		case "publish status":
				//code: Netstream status
				if(code=="NetStream.Publish.Start" && !isStreaming)
				{
					if(streamingOption!="Application")
					{
						//if the streaming is started ,display the frame in client's screen 
						//when a user stops and starts streaming, the connection is not created again.
						//so the frame needs to be displayed when it starts publishing
						document.JScrCap.update_frame("11,4,000000,16776960,320x240,1918x1198",capRect);
					}
					isStreaming=true;
					//TODO: get moviename from flex app
					getFlashMovie("mainWeb").sendPublishStatus(code,capRect);
				}
			break;
		//when  user clicks on  button that displayed on the selected window
		case "SkinButton Clicked":
	    		//if user chooses to stop streaming
				if (code == "ScreenShare:Stop")
				{
					stopStreaming();
				}
				//user clicks on the button to restart sharing the current window
				else if (code == "ScreenShare:Start")
				{
					document.JScrCapsw.startSharingThisWindow(desc);
				}
				//user clicks on the down arrow in the skin button which displays a popup menu
				else if (code == "ScreenShare:Down")
				{
					document.JScrCapsw.showPopupMenu(code, desc);
				}
				getFlashMovie("mainWeb").stopSharingAppWindowCallBack(code);
			break;
		//when user selects an item in the popup menu on skin button
		case "MenuItem Clicked":
				//if user is selected to stop sharing all selected windows
				if (code == "ScreenShare:StopPop")
				{
					stopStreaming();
				}
			    //if user is selected to stop sharing a selected window
				else if (code == "ScreenShare:StopThisWindowPop")
				{ 
					document.JScrCapsw.stopSharingThisWindow(desc);
				}	
				getFlashMovie("mainWeb").stopSharingAppWindowCallBack(code);
			break;
		case "frame_bounds":
				// code for this opertaion is the new selected screen area: x,y,width,height
				//if the frame is moved/resized 
				if(desc == "new frame bounds end")
				{
				    //get new dimensions
					var newDimensions = code.split(',');
					//get old dimensions
					var oldDimensions = streamDimensions.split(',');
					resizeRect=code;
					//if the area is resized (width or height is changed)
					if(newDimensions[2] != oldDimensions[2] || newDimensions[3] != oldDimensions[3])
					{
						resizeJScrCap();
					}
					//else the area is moved 
					else
					{
						//gets the new area
						capRect=code;
						moveJScrCap();
					}
				}
				// the area is moved
				else
				{
					capRect=code;
					moveJScrCap();
				}
			break;
	}
}

//retrieves the flashmovie using name of the movie
function getFlashMovie(movieName) 
{
	var isIE = navigator.appName.indexOf("Microsoft") != -1;
	return (isIE) ? window[movieName] : document[movieName];
}
    
//retrievs OS and browser details
function getOSDetails()
{
	os = BrowserDetect.OS;
	browser = BrowserDetect.browser;
	version = BrowserDetect.version;
	version = !isNaN(version) ? parseFloat(version) : 4;
}

//-------------------------------------------
//code is not using now
function togglePlayer(toggleOption)
{
	if(toggleOption=="server")
	{
		getFlashMovie("mainWeb").ToggleServerPanning();
	}
	else if(toggleOption=="client")
	{
		getFlashMovie("mainWeb").ToggleClientPanning();
	}
}
//for testing
var player=null;
function openWindow(url,name,options)
{
	player=window.open(url,name,options);
}
function closeWindow()
{
	player.close();
}
//for testing
//----------------------------------------------