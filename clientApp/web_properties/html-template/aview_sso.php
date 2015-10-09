<?php
    $uname = "";
	$pwd = "";
	$udn = "";
	$lrid = "";
	
	$uname = (isset($_POST['uname']) ? $_POST['uname'] : "");
	$pwd = (isset($_POST['pwd']) ? $_POST['pwd'] : "");
	$udn = (isset($_POST['udn']) ? $_POST['udn'] : "");
	$lrid = (isset($_POST['lrid']) ? $_POST['lrid'] : "");	
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- saved from url=(0014)about:internet -->
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en"> 
    <!-- 
    Smart developers always View Source. 
    
    This application was built using Adobe Flex, an open source framework
    for building rich Internet applications that get delivered via the
    Flash Player or to desktops via Adobe AIR. 
    
    Learn more about Flex at http://flex.org 
    // -->
    <head>
    	<link REL="Shortcut Icon" HREF="favicon.png"/>
        <title>A-VIEW</title>
		<!-- Denying the usage of iFrames for embedding the application in some other page, this is applicable only for Chrome -->
		<meta http-equiv="X-Frame-Options" content="deny">
        <meta name="google" value="notranslate" />
        <!-- To avoid ie8 compatibility button -->
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
		<!-- To avoid cache -->
        <meta http-equiv="Cache-Control" content="no-cache">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <!-- Include CSS to eliminate any default margins/padding and set the height of the html element and 
             the body element to 100%, because Firefox, or any Gecko based browser, interprets percentage as 
             the percentage of the height of its parent container, which has to be set explicitly.  Fix for
             Firefox 3.6 focus border issues.  Initially, don't display flashContent div so it won't show 
             if JavaScript disabled.
        -->
        <link rel="stylesheet" type="text/css" href="styles.css">
        <style type="text/css" media="screen"> 
            html, body  {height:100%; width:100%; position:absolute;}
            body { margin:0; padding:0; overflow:auto; text-align:center; 
                   background-color: "FFFFFF"; }   
            object:focus { outline:none; }
            #flashContent { display:none; }
            applet {display:block; position:absolute; left:0px; top:0px; z-index:-1;}
        </style>

        <!-- In firefox, if the application is tried to be embed inside some other page using iFrame, this script will redirect the page to actual website/url-->
		<script>
			if (window !== top) top.location = window.location;
		</script>
		
        <!-- Enable Browser History by replacing useBrowserHistory tokens with two hyphens -->
        <!-- BEGIN Browser History required section ${useBrowserHistory}>
        <link rel="stylesheet" type="text/css" href="history/history.css" />
        <script type="text/javascript" src="history/history.js"></script>
        <!${useBrowserHistory} END Browser History required section -->  
        
        <!--Screen Sharing script begins-->
         <script type="text/javascript" src="screenshare.js"></script>  
         <script type="text/javascript" src="BrowserDetect.js"></script>  
        <!--Screen Sharing script ends-->
            
        <script type="text/javascript" src="swfobject.js"></script>
        <script type="text/javascript">
            // For version detection, set to min. required Flash Player version, or 0 (or 0.0.0), for no version detection. 
            var swfVersionStr = "11.2.0";
            // To use express install, set to playerProductInstall.swf, otherwise the empty string. 
            var xiSwfUrlStr = "playerProductInstall.swf";
            var flashvars = {};
            var params = {};
            <!-- No cache variable starts -->
			var appVersion = "4.0.11317";
			var serverXMLVersion = "001";
			<!-- No cache variable ends -->
			flashvars.serverXMLVersion = serverXMLVersion;
			<!-- SSO Login starts -->
			flashvars.lrid = "<?php echo $lrid; ?>";
			flashvars.udn = "<?php echo $udn; ?>";
			flashvars.uname = "<?php echo $uname; ?>";
			flashvars.pwd = "<?php echo $pwd; ?>";
			<!-- SSO Login ends -->
			params.quality = "high";
            params.bgcolor = "#e0effb";
            params.allowscriptaccess = "sameDomain";
            params.allowfullscreen = "true";
            //To Load 3D file.
            params.wmode = "direct";
            var attributes = {};
            attributes.id = "mainWeb";
            attributes.name = "mainWeb";
            attributes.align = "middle";
            swfobject.embedSWF(
                "mainWeb.swf?nocache="+ appVersion, "flashContent", 
                "100%", "100%", 
                swfVersionStr, xiSwfUrlStr, 
                flashvars, params, attributes);
            // JavaScript enabled so display the flashContent div in case it is not replaced with a swf object.
            swfobject.createCSS("#flashContent", "display:block;text-align:left;");
        </script>
    </head>
    <body>

		<!--Screen Sharing applet begins-->
   		<applet codebase="http://cms001.aview.in/DeskShare/" code="CToolkitUIStarter.class" name="ScreenShare" archive="JScrCapUI.jar?3.5.1401.0701,JScrCapEngine.jar?3.5.1401.0701" width="0.1" height="0.1" id="JScrCap" mayscript="yes" scriptable="true">
		</applet>
    	<applet codebase="http://cms001.aview.in/DeskShare/" code="CToolkitSWStarter.class" name="AppShare" archive="JScrCapSW.jar?3.5.1401.0701,JScrCapEngine.jar?3.5.1401.0701" id="JScrCapsw" mayscript="yes" scriptable="true" height="0.1" width="0.1">
		</applet>
		<!--Screen Sharing applet ends-->
   		
   		<script type="text/javascript" src="main.js"></script>
   		<!--Fix for issue #17755-->
   		<!-- Add a iframe container for checking bandwidth-->
		<div class="container" id="outer">
			<div class="header">
				<h1>Check Bandwidth</h1>
				<img class="close_icon" src="close_icon.png" alt="Close" onclick="closeBandwidth();"/>
			</div>
			<div class="section">
				<div id="myFrame" class="myFrame"></div>
			</div>
		</div>
		
        <!-- SWFObject's dynamic embed method replaces this alternative HTML content with Flash content when enough 
             JavaScript and Flash plug-in support is available. The div is initially hidden so that it doesn't show
             when JavaScript is disabled.
        -->
        <div id="flashContent">
            <p>
                To view this page ensure that Adobe Flash Player version 
                11.2.0 or greater is installed. 
            </p>
            <script type="text/javascript">
			    var pageHost = ((document.location.protocol == "https:") ? "https://" : "http://");
			    document.write("<a href='http://www.adobe.com/go/getflashplayer'>Get Adobe Flash player</a>" );
			</script>
        </div>
        
        <noscript>
            <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" height="100%" id="mainWeb">
                <param name="movie" value="mainWeb.swf" />
                <param name="quality" value="high" />
                <param name="bgcolor" value="#e0effb" />
                <param name="allowScriptAccess" value="sameDomain" />
                <param name="allowFullScreen" value="true" />
                <param name="allowFullscreenInteractive" value="true" />
                <!--To Load 3D file-->
                <param name="wmode" value="direct" />
                <!--[if !IE]>-->
                <object type="application/x-shockwave-flash" data="mainWeb.swf" width="100%" height="100%">
                    <param name="quality" value="high" />
                    <param name="bgcolor" value="#e0effb" />
                    <param name="allowScriptAccess" value="sameDomain" />
                    <param name="allowFullScreen" value="true" />
                    <param name="allowFullscreenInteractive" value="true" />
                    <!--To Load 3D file-->
                	<param name="wmode" value="direct" />
                <!--<![endif]-->
                <!--[if gte IE 6]>-->
                    <p> 
                        Either scripts and active content are not permitted to run or Adobe Flash Player version
                        11.2.0 or greater is not installed.
                    </p>
                <!--<![endif]-->
                    <a href="http://www.adobe.com/go/getflashplayer">Get Adobe Flash Player</a>
                <!--[if !IE]>-->
                </object>
                <!--<![endif]-->
            </object>
        </noscript>     
   </body>
</html>
