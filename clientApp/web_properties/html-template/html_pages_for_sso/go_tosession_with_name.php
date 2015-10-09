<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title>A-VIEW WEB</title>
        <meta name="description" content="">
        <meta name="viewport" content="width=device-width">
        <link rel="stylesheet" href="css/normalize.css">
        <link rel="stylesheet" href="css/main.css">
        <script src="js/vendor/modernizr-2.6.2.min.js"></script>
    </head>
	<body>
        <!--[if lt IE 7]>
            <p class="chromeframe">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">activate Google Chrome Frame</a> to improve your experience.</p>
        <![endif]-->
        <!-- start:header -->
        <header class="header-pane">
            <section class="header-main-content">
                <h1 class="logo"><a href="http://www.aview.in">A-VIEW</a></h1>
            </section>
        </header>
        <!-- end:header -->
        <!-- start:Content -->
        <section class="content-pane">
            <!-- Start:Left Panel -->
            <section class="left-block">
                <!-- Start:Heading 01 -->
                <hgroup class="head01">
                    <h3>1</h3>
                    <h2>A-VIEW Registered User</h2>
                    <div class="clear"></div>
                </hgroup>
                <section class="inside-section-pane">
                    <input type="button" class="btn-main" id="loginAviewBtn" value="Login to A-VIEW"/>
					<div id="loginForm" style="display:none;">
						<form method="post" action="../aview_sso.php">
						   <input type="hidden" value="<?php echo $_POST['lrid']; ?>" name="lrid"/>
						   <input id="uname" class="text-input" name="uname" placeholder="Username" />
						   <input type="password" id="pwd" class="text-input" name="pwd" placeholder="Password" />
						   <section class="inside-section-pane"></section>
						   <input type="submit" class="btn-main toleft spacer01" value="Login" />
						   <section class="inside-section-pane"></section>
						</form>
					</div>
                </section>
                <!-- End:Heading 01 -->
                <!-- Start:Heading 02 -->
                <hgroup class="head01">
                    <h3>2</h3>
                    <h2>Are you a new user?</h2>
                    <div class="clear"></div>
                </hgroup>
                <section class="inside-section-pane">
                    <input type="button" class="btn-main" value="Register to A-VIEW" onclick="registerToAVIEW(event);"/>
                </section>
                <!-- End:Heading 02 -->
                <!-- Start:Heading 03 -->
                <hgroup class="head01">
                    <h3>3</h3>
                    <h2>For guest user</h2>
                    <div class="clear"></div>
                </hgroup>
                <section class="inside-section-pane">
                   <form method="post" action="../aview_sso.php">
	                   <label>Guest Name</label><div class="clear"></div>
					   <input type="hidden" value="<?php echo $_POST['lrid']; ?>" name="lrid"/>
					   <input type="text" id="udn" class="text-input" name="udn" placeholder="Display name"  />
	                   <input type="submit" class="btn-main toleft spacer01" value="Enter as Guest" />
				   </form>
                   <div class="clear"></div>
                </section>
                <!-- End:Heading 03 -->
            </section>
            <!-- End:Left Panel -->
            <!-- Start:Right Panel -->
            <aside class="right-block">
                <ul>
                    <li>Deliver engaging classes live and recorded</li>
                    <li>Provide access to lectures at varying bandwidths to multiple devices</li>
                    <li>Multiple teacher and student interaction through video and chat sessions</li>
                    <li>Simple click to share any kind of file and even your desktop</li>
                    <li>Content can be displayed across multiple displays enabling a rich viewing experience</li>
                    <li>Multi-Device compatible whiteboard</li>
                    <li>Handraise option for students to interact with teacher </li>
                </ul>
            </aside>
            <!-- Start:Right Panel -->
            <div class="clear"></div>
        </section>
        <!-- end:Content -->
        <!-- start:footer -->
        <footer class="footer">
            <section class="footer-con">
                © 2013 aview.in, All rights reserved.
            </section>
        </footer>
        <!-- end:footer -->
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
        <script>window.jQuery || document.write('<script src="js/vendor/jquery-1.9.1.min.js"><\/script>')</script>
        <script src="js/plugins.js"></script>
        <script src="js/main.js"></script> 
		<script type="text/javascript"> 
			$(document).ready(function(){
				$('#loginAviewBtn').click(function(){
					$('#loginForm').fadeIn();
					$('#loginAviewBtn').hide();
				});
			});
		</script>
    </body>
</html>
