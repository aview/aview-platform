<!-- Video Full screen starts -->
	//Pop-out window for video fullscreen
	var aviewVideoPopOutWindow;
	//Array of popout windows
	var popOuts = new Array();
	var videoStreamName = "";
	var userType = "";
	<!-- Video Full screen ends -->
	//Variable to store java is enabled or not
	var isJavaEnable = false;
	//Variable to set window close prevent flag.
	var preventClose = false;
	//Check whether to ask window close confirmation alert message.
    var needToConfirmWindowClose = true;
    //Variable to store whether duplicate login happens or not
	var isDuplicateLogin = false;
	//Variable to store logged in user is a Guest or not
	var isGuestUser = false;
	//Fix for issue #20122
	var isDirectClassEntry=false;
	var closedByAVIEW = false;
	//For checking whether presenter pop-out is closed, when user gets presenter control
	var isPopOutClosedByAview = false;
	//Fix for issue #17085
	var browser="";
	
	window.onload = function()
	{
		//Check java is enabled or not
		if(navigator.javaEnabled())
		{
			isJavaEnable = true;
		}
		else
		{
			isJavaEnable = false;
		}
		window.document.getElementsByTagName("body")[0].style.overFlow="auto";
		window.document.getElementsByTagName("html")[0].style.minWidth="600px";
	 	window.document.getElementsByTagName("html")[0].style.minHeight="279px";
	 	window.document.getElementsByTagName("body")[0].style.minWidth="600px";
	 	window.document.getElementsByTagName("body")[0].style.minHeight="279px";
	 	//Fix for issue #17085
		getOSDetails();
	}
	//Fix for issue #17085
	//retrievs OS and browser details
	function getOSDetails()
	{
		browser = BrowserDetect.browser;
	}
	
	//To send version of the application
	function getApplicationVersion()
	{
		var versionTimeOut=setTimeout(function()
		{
			//Fix for issue #17085
			getFlexApp("mainWeb").setApplicationVersion(appVersion,browser);
			clearTimeout(versionTimeOut);
		},500);
	}
	
	//Callback from flex by calling function getDetailsOfJavaPluginEnabled()
	function checkJavaPlugin()
	{
		var delayJavaPluginStatus=setTimeout(function(){
			getFlexApp("mainWeb").isJavaPluginEnabled(isJavaEnable);clearTimeout(delayJavaPluginStatus);},1000)
	}

	window.onunload = function()
	{
		//Callback to flex by calling function closeApplication()
		getFlexApp("mainWeb").closeApplication();
		
		// Close Full screen windows
  		closePopOuts();	
	 }
	 //Fix for issue #11561
	 //Function is used to set the application size.
	 function setAppSize()
	 {
	 	window.document.getElementsByTagName("html")[0].style.minWidth="1024px";
	 	window.document.getElementsByTagName("html")[0].style.minHeight="768px";
	 	window.document.getElementsByTagName("body")[0].style.minWidth="1024px";
	 	window.document.getElementsByTagName("body")[0].style.minHeight="768px";
	 	window.document.getElementsByTagName("body")[0].style.overFlow="auto";
	 }
				 
	 function closePopOuts()
	 {
  		//Closing Child PopOut Windows When Parent Window is Closed
	    if(popOuts.length == 0) return; 
		for(i=0; i<popOuts.length; i++) 
		{
			popOuts[i].close(); 
		}
	 }
				 
	window.onbeforeunload = function() 
    {
    	//Guest Login: Restrict browser reload/close confirmation alert for Guest users
    	if(isGuestUser ==  false && isDuplicateLogin == false && isDirectClassEntry == false)
        {
        	if(preventClose == true)
            {
            	if (needToConfirmWindowClose)
                {
                	// Message to be displayed in Warning.
                    return "You will be logged out from A-VIEW.";
                    preventClose = false;
                }
           	}
        }
     }
     
     //Function to set value for preventClose variable.
     function preventWindowClose()
     {
     	preventClose = true;
     }

	//Function to get the application name
    function getFlexApp(appName)
    {
   	   if (navigator.appName.indexOf ("Microsoft") !=-1)
       {
       		return window[appName];
       } 
       else 
       {
       		return document[appName];
       }
    }
    <!-- Video Full screen starts -->
    //Open the pop out window
	function openPopOutWindow(usertype,streamName,uniqueID)
	{
		userType = usertype;
		videoStreamName = streamName;
		//Changed aviewVideoPopOutWindow width and height as ScreenWidth and ScreenHeight.
		 aviewVideoPopOutWindow = window.open('AVIEWModuleLoader.html','videoWindow','toolbar=no,location=no,directories=no,status=no,scrollbars=yes,resizable=yes,width=640px,height=400px');
	 	 aviewVideoPopOutWindow.focus();
	 	 popOuts.push(aviewVideoPopOutWindow);
	 	 //Callback from flex by calling function createSelectedViewerFullScreenArray()  
	 	 getFlexApp("mainWeb").getFullScreenStream(streamName,userType,"moduleLoaded");
	 	 //To detect browser
		 var browserName = navigator.userAgent.toLowerCase();
		 
		 //In Opera browser 'window.onunload()' method will not be triggered when we close the child window. 
		 //So, added following logic to close pop out window only for opera browser users.
		 if(browserName.indexOf("opera") > -1)
		 {
			 //Start timer to check when child pop out window is getting closed.
			 var timer = setInterval(function()
			 {   
			 	if(aviewVideoPopOutWindow.closed)
			    { 
				  	clearInterval(timer);
				  	getFlexApp("mainWeb").addUserVideo(videoStreamName,userType);
			   }  
			 }, 1000);
		 }
		 //To prevent refresh the pop-out window, when user clicks F5
		 aviewVideoPopOutWindow.onkeydown=function(e) {
			 var event = window.event || e;
		 	if (event.keyCode == 116) 
		 	{
				event.preventDefault();
			}
		}
	 }
	 //Callback from flex by calling function getVideoFullscreenDetailsFromLSO()
	 function getLSOInParentApp(videoStreamName,userType)
	 {
	 	getFlexApp("mainWeb").getLSOValues(videoStreamName,userType);
	 }
	 
     //Invoked from child window when child window is getting closed.
	 function startStreamInNormalMode(streamName,userType)
	 {
	 	if(!isPopOutClosedByAview)
	 	{
	 		getFlexApp("mainWeb").getStreamClose(streamName,userType);
	 		getFlexApp("mainWeb").addUserVideo(streamName,userType);
	 	}
	 	else
	 	{
	 		isPopOutClosedByAview = false;
	 		getFlexApp("mainWeb").addUserVideo("isPopOutClosedByAview",userType);
	 	}
	 }
	<!-- Video Full screen ends -->
	
	//To avoid local video move issue when user resizes the browser window.
	window.onresize = function resize()
	{
	 	getFlexApp("mainWeb").resizeApplication();
	}
	function setCloseMode(data)
	{
		//data will be 'true' if duplicate login happens
		closedByAVIEW = data;
	}
	//Guest Login: Function to set whether the logged in user is guest or not
	function guestUser(value)
	{
		//value will be 'true' when guest user is logged into the application.
		isGuestUser = value;
	}
	//Fix for issue #20122 
	function directClassEntry(value)
	{
		//value will be 'true' when user is logged into the application using direct class entry method.
		isDirectClassEntry = value;
	}
	//To close presenter pop-out window, when user gets presenter control
	function closePresenterPopOutWindow()
	{
		isPopOutClosedByAview = true; 
		aviewVideoPopOutWindow.close();
	}
	function appLoadedMsgFromPopoutWindow()
	{
		getFlexApp("mainWeb").popoutLoadedMessage();
	}
	function focusPopOutWindow()
	{
		aviewVideoPopOutWindow.focus();
	}
	//To reload the application from server
	function refreshApplication()
	{
		preventClose = false;
		window.location.reload(true);
	}
	//Fix for issue #17755
	function moveIFrame(x,y,w,h)
	{
	    var frameRef=document.getElementById("myFrame");
	    frameRef.style.left=x;
	    frameRef.style.top=y;
	    var iFrameRef=document.getElementById("myIFrame");	
		iFrameRef.width=w;
		iFrameRef.height=h;
	}
	function showIFrame()
	{
		document.getElementById('outer').style.display="block";
	    document.getElementById("myFrame").style.visibility="visible";
	    document.getElementById("outer").style.visibility="visible";
	}	
	function loadIFrame(url)
	{
		document.getElementById("myFrame").innerHTML = "<iframe id='myIFrame' src='" + url + "'frameborder='0'></iframe>";
	}
	//Fix for issue #19163
	function closeBandwidth()
	{
		document.getElementById("outer").style.display='none';
		getFlexApp("mainWeb").closeBandwidth();
	}