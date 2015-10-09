package edu.amrita.aview.core.login {
	import com.adobe.crypto.SHA1;
	
	import edu.amrita.aview.core.entry.AVCEnvironment;
	import edu.amrita.aview.core.entry.ClassroomContext;
	import edu.amrita.aview.core.entry.Constants;
	import edu.amrita.aview.core.gclm.GCLMContext;
	import edu.amrita.aview.core.gclm.helper.InstituteHelper;
	import edu.amrita.aview.core.gclm.helper.UserHelper;
	import edu.amrita.aview.core.gclm.vo.InstituteVO;
	import edu.amrita.aview.core.gclm.vo.UserVO;
	import edu.amrita.aview.core.logfilecheck.LogFileRandomCheck;
	import edu.amrita.aview.core.login.boilerplate.Strings;
	import edu.amrita.aview.core.login.boilerplate.events.ApplicationStatusEvent;
	import edu.amrita.aview.core.login.boilerplate.events.LoginStatusEvent;
	import edu.amrita.aview.core.login.helper.VersionHelper;
	import edu.amrita.aview.core.shared.components.messageBox.MessageBox;
	import edu.amrita.aview.core.shared.components.messageBox.events.MessageBoxEvent;
	import edu.amrita.aview.core.shared.helper.AbstractHelper;
	import edu.amrita.aview.core.userPreference.RemoteServerPreferenceFac;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.ObjectProxy;
	import mx.utils.StringUtil;
	import mx.utils.object_proxy;
	
	public class PrepareLogin extends EventDispatcher 
	{
		/**Platform specific imports*/
		applicationType::desktop {
			import flash.data.EncryptedLocalStore;
			import flash.external.ExtensionContext;
			import flash.filesystem.File;
			import flash.filesystem.FileMode;
			import flash.filesystem.FileStream;
		}
		applicationType::DesktopMobile {
			import flash.desktop.NativeApplication;
			import flash.filesystem.File;
			import flash.filesystem.FileMode;
			import flash.filesystem.FileStream;
		}
		/** Variable declaration */
		[Bindable]
		private var writeString_user:String="";
		//JHCR: Move the version logic from MainHandler.as to here  
		//public static const AVIEW_VERSION:String="3.0.2176";
		public static var BIOMETRIC_SERVER:String="";
		
		/*
		[Bindable]
		public static var moduleNames:ArrayCollection=new ArrayCollection();
		private var versionCheckerRO:RemoteObject;
		private var moduleLoaderRO:RemoteObject;
		*/
		
		private var getservervalue:HTTPService
		private var getUserEnteredServerValue:HTTPService;
		[Bindable]
		public var loginTypeIndex:int=0;
		[Bindable]
		public var saveUserSelect:Boolean=false;
		[Bindable]
		public var logInButtonState:Boolean=true;
		private var _userName:String=null;
		private var _password:String=null;
		/**
		 * For Log API
		 */
		private var log:ILogger=Log.getLogger("aview.main.PrepareLogin");
		[Bindable]
		private var loginFailedCount:int=0;
		private var loginProtocol:String=null;
		private var loginFailCount:int=0;
		private var aviewEndPoint:String="";
		private const MAX_LOGIN_ATTEMPT:int=3;
		private var userSelectedServer:String;
		private var saveTheseServers:ArrayCollection=new ArrayCollection();
		private var userSelectedIP:String;
		applicationType::DesktopWeb {
			import edu.amrita.aview.core.shared.components.CaptchaComponent;
			private var captchaComp:CaptchaComponent;
			public var mainApp:MainApp;
		}
		/**Platform specific variables*/
		applicationType::desktop {
			//Since there is no File related class for web application.
			[Bindable]
			private var _file_user:File; //TODO: not used
			[Bindable]
			private var _fileStream_user:FileStream; //TODO: not used
		}
		applicationType::web {
			//Fix for issue #8867.
			private var stageCheckTimeOutID:uint;
		}
		applicationType::mobile {
			import edu.amrita.aview.core.entry.MainMobileApplication;
			public var cameraActivation:Boolean=false;
			public var cameraIndex:String;
			public var video:Video=new Video();
			public var open_helpEvent_flag:int=0;
			public var videoFrame:Video=new Video(640, 480);
			[Bindable]
			public var serverInput:String="";
			private var timerServerResponseIconCount:int=0;
			public var serverResponse:String;
			public static const AVIEW_VERSION:String=getAppVersion();
			[Bindable]
			public var selectedServerIP:String = "";
			[Bindable]
			public var ISPRING_SERVER:String="";
			public var mainApp:MainMobileApplication;
			private var isLoginSuccess:Boolean = false;
		}
		applicationType::DesktopWeb {
			public function PrepareLogin(caller:MainApp) {
				this.mainApp = (caller != null) ? caller: FlexGlobals.topLevelApplication.mainApp;
				//ashwini: todo : revisit this code later. Not everyone is following the function call strictly
			}
		}
		applicationType::mobile {
			public function PrepareLogin(caller:MainMobileApplication) {
				this.mainApp = caller; 
			}
		}
		
		[Bindable]
		public function get password():String {
			return _password;
		}
		
		public function set password(value:String):void {
			_password=value;
		}
		
		[Bindable]
		public function get userName():String {
			return _userName;
		}
		
		public function set userName(name:String):void {
			_userName=name;
		}
		applicationType::DesktopMobile {
			//Since there is no NativeApplication related class for web application.
			public static function getAppVersion():String {
				var appXml:XML=NativeApplication.nativeApplication.applicationDescriptor;
				var ns:Namespace=appXml.namespace();
				var appVersion:String=appXml.ns::versionLabel[0];
				return appVersion;
			}
		}
		public var serverInfo:RemoteServerPreferenceFac=new RemoteServerPreferenceFac();

		public function createDataServices():void 
		{
			/*
			moduleLoaderRO=new RemoteObject();
			moduleLoaderRO.destination="mysqladmin";
			//moduleLoaderRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			moduleLoaderRO.showBusyCursor=true;
			versionCheckerRO.addEventListener("result", versionCheckHandler);
			versionCheckerRO.addEventListener("fault", faultHandler);
			moduleLoaderRO.addEventListener("result", getModuleNamesResult);
			moduleLoaderRO.addEventListener("fault", getModuleNamesFault);
			*/
			getDatabaseServer();				
		}

		public function getDatabaseServer():void {
			/** Specify the location of the xml file to be read. */
			applicationType::DesktopMobile {
				var serverConfigFile:File=new File();
				if (AVCEnvironment.os == AVCEnvironment.WINDOWS) {
					serverConfigFile.nativePath=File.applicationStorageDirectory.nativePath + "\\" + Strings.SERVER_DETAIL_FILENAME;
				} else //Assumes MAC
				{
					serverConfigFile.nativePath=File.applicationStorageDirectory.nativePath + "/" + Strings.SERVER_DETAIL_FILENAME;
				}
			}
			getservervalue=new HTTPService();
			applicationType::web {
				//Fix for Issue #6586
				getservervalue.url="config/ServerDetails.xml?nocache=" + mainApp.serverXMLVersion;
			}
			applicationType::DesktopWeb {
				applicationType::desktop {
					// read from the local storage first, if it is present
					if (serverConfigFile.exists) {
						getservervalue.url=serverConfigFile.url;
						getservervalue.send();
						getservervalue.addEventListener(ResultEvent.RESULT, databaseServerResultHandler);
						getservervalue.addEventListener(FaultEvent.FAULT, databaseServerFaultHandler);
					}
				}
				// now read local config file 
				getservervalue.url="config/ServerDetails.xml";
				getservervalue.send();
				//getsaveduser_details();
				getservervalue.addEventListener(ResultEvent.RESULT, databaseServerResultHandler);
				getservervalue.addEventListener(FaultEvent.FAULT, databaseServerFaultHandler);
			}
			applicationType::mobile{
				if (serverConfigFile.exists) {
					getservervalue.url=serverConfigFile.url;
				}else{
					getservervalue.url="config/ServerDetails.xml";
				}
				getservervalue.send();
				getservervalue.addEventListener(ResultEvent.RESULT, databaseServerResultHandler);
				getservervalue.addEventListener(FaultEvent.FAULT, databaseServerFaultHandler);
			}
		}
		//bugfix #14643
		private var serverReadFromCfg:Object={};
		
		/**
		 * The function is used to get the serverDetails like the name of the server to connect to,
		 * and stores the details in an array.
		 *
		 * @param event type ResultEvent
		 * @return void
		 */
		public function databaseServerResultHandler(event:ResultEvent):void {
			var myServers:ArrayCollection=new ArrayCollection();
			if (event.result.servers.server is ObjectProxy) {
				if (!_doesServerExist(event.result.servers.server)) {
					var myObj1:Object=event.result.servers.server.object_proxy::object;
					myServers.addItem(myObj1);
				}
			} else {
				var count:int=event.result.servers.server.length;
				for (var i:int=0; i < count; i++) {
					if (!_doesServerExist(event.result.servers.server[i])) {
						var myObj2:Object=event.result.servers.server[i].object_proxy::object;
						myServers.addItem(myObj2);
					}
				}
			}
			if (myServers.length > 0) {
				mainApp.loginServerTypearr.addAll(myServers);
				saveTheseServers.addAll(myServers); // this arraycollection will be saved
				applicationType::DesktopMobile{
					serverInfo.checkServersBatch(myServers);
				}
				// TODO: by default passing the first value
				serverEndPointValues(myServers[0].domain);
			}
			BIOMETRIC_SERVER=event.result.servers.BiometricServer.biometricserverip;
			ClassroomContext.HELP_DOCUMENT_URL = event.result.servers.help.url;
			applicationType::mobile {
				ISPRING_SERVER = event.result.servers.ispring.url;
				if(userName != "" && userName != null && password != "" && password != null){
					setTimeout(loginCheckfn,2000,userName,password,selectedServerIP,true);
				}
			}
			applicationType::web {
				//Set ip and protocol, to fix application hosting and database server issue
				ClassroomContext.NATIONAL_SERVER_IP = myServers[0].ip;
				userSelectedIP = ClassroomContext.NATIONAL_SERVER_IP;
				userSelectedServer = ClassroomContext.NATIONAL_SERVER_IP;
				ClassroomContext.AVIEW_PROTOCOL = myServers[0].protocol;
				setProtocolData();
				//For Guest Login
				if(mainApp.ssoMode == Strings.guestLogin){
					var userHelper:UserHelper = new UserHelper();
					userHelper.getGuestUserForTheClass(FlexGlobals.topLevelApplication.parameters.lrid,getGuestUserForTheClassResultHandler,getGuestUserForTheClassFaultHandler);	
				}
				//For Web: User login or direct class entry
				else if (mainApp.ssoMode == Strings.userLogin || mainApp.ssoMode == Strings.classEntry) {
					var userHelper:UserHelper=new UserHelper();
					userHelper.getUserByUserNamePassword(StringUtil.trim(FlexGlobals.topLevelApplication.parameters.uname), SHA1.hash(StringUtil.trim(FlexGlobals.topLevelApplication.parameters.pwd)), getUserByUserNameResultHandler, getUserByUserNamePasswordFaultHandler);
				} else {
				}
			}
		}
		
		applicationType::web{
			//For Guest Login: Guest user details result handler
			public function getGuestUserForTheClassResultHandler(userVO:UserVO):void
			{
				//If userVo have user details
				if(userVO != null)
				{
					//If Flashvars contain user display name,then we replace first name
					if(mainApp.ssoMode == Strings.guestLogin && FlexGlobals.topLevelApplication.parameters.udn !="")
					{
						userVO.fname = FlexGlobals.topLevelApplication.parameters.udn;
					}
					//Assign user details to ClassroomContext.userVO
					ClassroomContext.userVO = userVO;
					getAllInitialData();
				}
					//userVo have no values
				else
				{
					
				}
			}
			//For Guest Login: Guest user details fault handler
			public function getGuestUserForTheClassFaultHandler(event:FaultEvent):void{
				
			}
		}
		
		//bugfix #14643
		private function _doesServerExist(s:*):Boolean {
			if (serverReadFromCfg[s.name]) { //if there is an existing entry, then dont add it
				return true;
			} else {
				serverReadFromCfg[s.name]=1;
				return false;
			}
		}
		
		private function serverEndPointValues(value:String):void {
			ClassroomContext.DATABASE_SERVER=value;
			ClassroomContext.WEBAPP_AVIEW_STREAMING_END_POINT=encodeURI(Strings.PROTOCOL_HTTP + "://" + ClassroomContext.DATABASE_SERVER + "/" + ClassroomContext.WEBAPP_AVIEW + "/messagebroker/streamingamf");
			ClassroomContext.WEBAPP_AVIEW_POLLING_END_POINT=encodeURI(Strings.PROTOCOL_HTTP + "://" + ClassroomContext.DATABASE_SERVER + "/" + ClassroomContext.WEBAPP_AVIEW + "/messagebroker/amfpolling");
			aviewEndPointValues();
		}
		
		public function aviewEndPointValues():void {
			aviewEndPoint=ClassroomContext.DATABASE_SERVER + "/" + ClassroomContext.WEBAPP_AVIEW + "/messagebroker/amf";
			ClassroomContext.WEBAPP_AVIEW_END_POINT=encodeURI(ClassroomContext.AVIEW_PROTOCOL + "://" + aviewEndPoint);
		}
		
		/**
		 * The function is used to handle faults while reading the xml file with user details.
		 * It displays an error message if a fault occurs.
		 *
		 * @param event type FaultEvent
		 * @return void
		 */
		private function databaseServerFaultHandler(event:FaultEvent):void {
			if (Log.isError())
				log.error("entry::PrepareLogin::databaseServerFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
			MessageBox.show("Sorry no server was retreived,Contact A-VIEW Administrator", "INFO", MessageBox.MB_OK);
		}
		
		/*applicationType::web {
		//Guest Login: Guest user details result handler
		public function getGuestUserForTheClassResultHandler(userVO:UserVO):void {
		
		//If userVo have user details
		if (userVO != null) {
		//If Flashvars contain user display name,then we replace first name
		if (mainApp.ssoMode == Constants.guestLogin && FlexGlobals.topLevelApplication.parameters.udn != "") {
		userVO.fname=FlexGlobals.topLevelApplication.parameters.udn;
		}
		//Assign user details to ClassroomContext.userVO
		ClassroomContext.userVO=userVO;
		getAllInitialData();
		}
		//userVo have no values
		else {
		
		}
		}
		}*/
		private function getUserEnteredDatabaseServer():void {
			getUserEnteredServerValue=new HTTPService();
			applicationType::desktop {
				//File method not available for web.
				getUserEnteredServerValue.url=File.applicationDirectory.nativePath + "\\\config\\\UserEnteredServerDetails.xml";
			}
			getUserEnteredServerValue.send();
			getUserEnteredServerValue.addEventListener(ResultEvent.RESULT, userEnteredDatabaseServerResultHandler);
			getUserEnteredServerValue.addEventListener(FaultEvent.FAULT, userEnteredDatabaseServerFaultHandler);
		}
		
		public function userEnteredDatabaseServerResultHandler(event:ResultEvent):void {
			try {
				if (getUserEnteredServerValue.lastResult.servers.server.ip is ObjectProxy) {
					acUserSelectedServers=new ArrayCollection(mx.utils.ArrayUtil.toArray(getUserEnteredServerValue.lastResult.servers.server.ip));
				} else {
					acUserSelectedServers=getUserEnteredServerValue.lastResult.servers.server.ip;
				}
				if (acUserSelectedServers.length > 0) {
					var index:int=-1;
					for (var i:int=0; i < acUserSelectedServers.length; i++) {
						//acUserSelectedServers.addItem(acServers[i]);
						mainApp.loginServerTypearr.addItem(acUserSelectedServers[i]);
						/*if (acUserSelectedServers[i].defaultValue == true) {
						index=i;
						acUserSelectedServers[i].defaultValue=false;
						}*/
					}
					applicationType::DesktopWeb{
						mainApp.cmbServerType.dataProvider=null;
						mainApp.cmbServerType.dataProvider=mainApp.loginServerTypearr;
						if (index != -1) {
							//mainApp.setLoginStatus(false);
							mainApp.cmbServerType.selectedIndex=index + 1;
						}
					}
				}
			} catch (er:Error) {
				if (Log.isError())
					log.error("Error in userEnteredDatabaseServerResultHandler method:" + er.getStackTrace());
			}
			try {
				loginProtocol=getUserEnteredServerValue.lastResult.servers.protocol;
			} catch (er:Error) {
				if (Log.isError())
					log.error("Error in userEnteredDatabaseServerResultHandler method::loginProtocol:" + er.getStackTrace());
			}
			applicationType::DesktopWeb{
				mainApp.cmbServerType.textInput.text=Strings.PROMPT_SERVER_DROPDOWN;
			}
		}
		
		public function userEnteredDatabaseServerFaultHandler(event:FaultEvent):void {
			if (Log.isError())
				log.error("entry::PrepareLogin::userEnteredDatabaseServerFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
		}
		internal var txtServerInput:String;
		//Fix for Bug #18586,18593
		public function _validateComboServerEntry(server:String):Boolean {
			if(server != null && server != '' && server != Strings.PROMPT_SERVER_DROPDOWN){
				userSelectedServer = server ;
				applicationType::DesktopWeb{
					mainApp.btn_ForgotPassword.enabled=true;
				}
			} else {
				return false;
			}
			// TODO: the below check is possibly dead code, please revisit and delete
			if (userSelectedServer.length == 0) {
				userSelectedServer=txtServerInput;
			}
			var serverIP:String="";
			for (var i:int=0; i < mainApp.loginServerTypearr.length; i++) {
				var temp:String=mainApp.loginServerTypearr[i].name;
				if (userSelectedServer.toLowerCase() == temp.toLowerCase())
					serverIP=mainApp.loginServerTypearr[i].domain;
			}
			if (serverIP == "" || serverIP == null)
				serverIP=userSelectedServer;
			// function call
			serverEndPointValues(serverIP);
			userSelectedIP=serverIP;
			applicationType::mobile{
				selectedServerIP = userSelectedIP;
			}
			return true;
		}
		
		public function loginCheckfn(uName:String, pass:String, selectedServer:String=null, isAutoLogin:Boolean=false):void {
			applicationType::DesktopMobile{
				var logFile:LogFileRandomCheck=new LogFileRandomCheck();
			    logFile.initFileRandomCheck();
				if (!this._validateComboServerEntry(selectedServer)) {
					//logInButtonState=false;
					//Alert.show("Please select the server", "Login Failed", Alert.OK,this,resetServerName );
					MessageBox.show("Please select the server.", "Login Failed", MessageBox.MB_OK);
					return;
				}
			}
			ClassroomContext.resetUserContextValues();
			if (logInButtonState) {
				logInButtonState=false;
			} else {
				return;
			}
			userName=StringUtil.trim(uName);
			//password=SHA1.hash(pass);
			password=StringUtil.trim(pass);
			if (loginTypeIndex == 0) {
				if (_userName.length == 0 || _password.length == 0) {
					MessageBox.show("Please check your username and password", "ERROR", MessageBox.MB_OK, null, null, null, MessageBox.IC_ALERT);
					dispatchEvent(new LoginStatusEvent(LoginStatusEvent.LOGIN_FAILED));
				} else {
					applicationType::mobile {
						if (!isAutoLogin) {
							password=SHA1.hash(pass);
						}
					}
					retriveData();
				}
			} else {
				if (_userName.length == 0) {
					MessageBox.show("Please check your username.", "Login Failed", MessageBox.MB_OK);
					dispatchEvent(new LoginStatusEvent(LoginStatusEvent.LOGIN_FAILED));
				} else {
					retriveData();
				}
			}
		}
		
		public function retriveData():void {
			if (AVCEnvironment.deviceType == AVCEnvironment.DESKTOP) {
				saveUser(saveUserSelect, _userName, _password);
			}
			checkServerIP();
		}
		internal var timerServerResponseCount:int=0;
		
		private function checkServerResponseStatus():void {
			timerServerResponseCount++;
			if (timerServerResponseCount < 6) {
				if (!serverInfo.isReachable(userSelectedIP)) {
					applicationType::mobile{
						FlexGlobals.topLevelApplication.callLater(checkServerResponseStatus);
					}
					applicationType::desktop{
						setTimeout(checkServerResponseStatus, 500);
					}
				} else {
					setProtocolData();
				}
			} else {
				setProtocolData();
				timerServerResponseCount=0;
			}
		}
		private var bruteForceRetryCount:int = 3;
		private function setProtocolData():void {
			applicationType::mobile{
				if (!serverInfo.isReachable(userSelectedIP)) {
					if (userSelectedServer == Strings.NATIONAL_SERVER) {
						MessageBox.show("Connection Failed: Network may be down or server may be down", "Server Error", MessageBox.MB_OK);
					} else {
						MessageBox.show("Connection failed: wrong IP address or Network may be down or Server may be down", "Server Error", MessageBox.MB_OK);
						isLoginSuccess = true;
					}
					if (Log.isInfo())
						log.info("Fault occured while performing a remote operation. Please contact the administrator. Fault string:");
					logInButtonState=true;
				}else{
					ClassroomContext.AVIEW_PROTOCOL = serverInfo.getPreferredAviewProtocol(userSelectedIP);
					serverEndPointValues(userSelectedIP);
					aviewEndPointValues();
					checkClientToServerCompatibility();
				}
			}
			
			applicationType::desktop{
				if (!serverInfo.isReachable(userSelectedIP))
				{
					var status:int = serverInfo.serverStatus(userSelectedIP);
					if (status == 0 ) { // server were pinged
						try {
							throw new Error("Logging");
						} catch (e: Error) {
							log.error("Server was not reachable earlier, trying brute force approach for one last time now.....");
						}
						bruteForceRetryCount-- ;
					}
					// Made the call, but immedeate response has not come yet...so I need to keep the user engaged
					if (bruteForceRetryCount >= 0 ){ // if I am out of retry count 
						applicationType::DesktopWeb{
							Alert.show("Failed to connect due to network error. Please check your internet connectivity and try logging in again", "Network Error: code APPRETY");
						}
						applicationType::mobile{
							MessageBox.show("Failed to connect due to network error. Please check your internet connectivity and try logging in again", "Network Error: code APPRETY", MessageBox.MB_OK);
						}
						//						serverInfo.forceReEvaluateServerSync(userSelectedIP); // force a call after user clicks on the pop-up
						serverInfo.checkServer(userSelectedIP);
					} else {
						//						Alert.show("Tried several times, but failed to connect. \n Please restart your application and try again after some time. \n If error persists, then please contact your system administrator", "Unknown Network Error : code APPNR", Alert.OK, this, application_closeapp);
						applicationType::DesktopWeb{
							Alert.show("Tried several times, but failed to connect. \n Please restart your application and try again after some time. \n If error persists, then please contact your system administrator", "Unknown Network Error : code APPNR", Alert.OK);
						}
						applicationType::mobile{
							MessageBox.show("Tried several times, but failed to connect. \n Please restart your application and try again after some time. \n If error persists, then please contact your system administrator", "Unknown Network Error : code APPNR", MessageBox.MB_OK);
						}
					}
					applicationType::DesktopWeb{
						mainApp.btn_login.enabled=true;
					}
					logInButtonState = true;
				}
				else
				{
					ClassroomContext.AVIEW_PROTOCOL = serverInfo.getPreferredAviewProtocol(userSelectedIP);
					aviewEndPointValues();
					checkClientToServerCompatibility();
				}
			}
			//To fix application hosting and database server issue
			applicationType::web{
				aviewEndPointValues();
				//versionCheckerRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
				checkClientToServerCompatibility();
			}
		}
		
		private function checkServerIP():void {
			applicationType::DesktopMobile{
				applicationType::mobile{
					setTimeout(enableLogin,20000);
				}
				if (!serverInfo.serverDataCheck(userSelectedIP) && userSelectedServer != Strings.NATIONAL_SERVER) {
					timerServerResponseCount=0;
					serverInfo.checkServer(userSelectedIP);
					setTimeout(checkServerResponseStatus, 500);
				} else {
					setProtocolData();
					//var value:int=serverPreference.serverStatus(userSelectedIP);
				}
			}
			//To fix application hosting and database server issue
			applicationType::web{
				setProtocolData();
			}
		}
		internal var acUserSelectedServers:ArrayCollection=new ArrayCollection();
		
		//bugfix #14643
		private function saveUserEnteredIPData():void {
			var isDataPresent:Boolean=false;
			// ensure that there are uniq entries only
			for (var i:int=0; i < saveTheseServers.length; i++) {
				if (userSelectedServer == saveTheseServers[i].name) {
					isDataPresent=true;
					saveTheseServers[i].isDefault=0;
					break;
				}
			}
			if (!isDataPresent) {
				var obj:Object=new Object();
				obj.name=userSelectedServer;
				obj.domain=escapeRegexChars(userSelectedServer);
				obj.ip=escapeRegexChars(userSelectedServer);
				obj.isDefault=1;
				saveTheseServers.addItem(obj);
			}
			saveUserEnteredXML();
		}
		
		//bugfix #14643
		private function escapeRegexChars(s:String):String {
			var newString:String;
			newString=s.replace(new RegExp("([{}\(\)\^$&\*\?\/\+\|\[\\\\]|\]|\-| )", "g"), "\_");
			return newString;
		}
		
		//bugfix #14643
		public function saveUserEnteredXML():void {
			try {
				var mainTag:XML=<servers></servers>;
				for (var i:int=0; i < saveTheseServers.length; i++) {
					var serverBlock:XML=<server></server>
					var nameTag:XML=<name>{saveTheseServers[i].name}</name>;
					var domainTag:XML=<domain>{saveTheseServers[i].domain}</domain>;
					var ipTag:XML=<ip>{saveTheseServers[i].ip}</ip>;
					var defaultTag:XML=<isDefault>{saveTheseServers[i].isDefault}</isDefault>;
					serverBlock.appendChild(nameTag);
					serverBlock.appendChild(domainTag);
					serverBlock.appendChild(ipTag);
					serverBlock.appendChild(defaultTag);
					mainTag.appendChild(serverBlock);
				}
				var helpBlock:XML=<help><url>aview.in</url></help>;
				var bioBlock:XML=<BiometricServer><biometricserverip>biometric.aview.in</biometricserverip></BiometricServer>;
				mainTag.appendChild(helpBlock);
				mainTag.appendChild(bioBlock);
				applicationType::mobile{
					var ispringBlock:XML=<ispring><url>10.3.3.45</url></ispring>;
					mainTag.appendChild(ispringBlock);
				}
				var data:String=mainTag.toString();
				applicationType::DesktopMobile {
					if (AVCEnvironment.os == AVCEnvironment.WINDOWS) {
						var filePath:String=File.applicationStorageDirectory.nativePath + "\\" + Strings.SERVER_DETAIL_FILENAME;
					} else //Assumes MAC
					{
						var filePath:String=File.applicationStorageDirectory.nativePath + "/" + Strings.SERVER_DETAIL_FILENAME;
					}
					var file:File=new File(filePath);
					var fileStream:FileStream=new FileStream();
					fileStream.openAsync(file, FileMode.WRITE);
					fileStream.writeUTFBytes(data);
					fileStream.close();
				}
			} catch (er:Error) {
				if (Log.isError())
					log.error("Error in saveUserEnteredXML method:" + er.getStackTrace());
			}
		}
		
		/**
		 * The function is not used.
		 *
		 *
		 * @return void
		 */
		private function saveUser(selcted:Boolean=false, userName:String=null, password:String=null):void  //TODO: This function requires modification (password needs to be encrypted and stored 
		{
			applicationType::desktop {
				//Since there is no File related class for web application.			
				try {
					if (selcted == true) {
						_file_user=File.documentsDirectory.resolvePath("A-VIEW/config/UserDetails.xml");
						_fileStream_user=new FileStream();
						var str:String=password;
						var bytes:ByteArray=new ByteArray();
						bytes.writeUTFBytes(str);
						EncryptedLocalStore.setItem("amma", bytes);
						writeString_user="<user>\n<username>" + userName + "</username>\n</user>\n";
						_fileStream_user.open(_file_user, FileMode.WRITE);
						_fileStream_user.writeUTFBytes(writeString_user);
						_fileStream_user.close();
					} else {
						//EncryptedLocalStore.reset();
						_file_user=File.documentsDirectory.resolvePath("A-VIEW/config/UserDetails.xml");
						_fileStream_user=new FileStream();
						writeString_user="<user>\n<username></username>\n</user>\n";
						_fileStream_user.open(_file_user, FileMode.WRITE);
						_fileStream_user.writeUTFBytes(writeString_user);
						_fileStream_user.close();
					}
				} catch (e:Error) {
					if (Log.isError())
						log.error("Error in saveUser method:" + e.getStackTrace());
				}
			}
		}
		
		//#Issue #297 START
		/**
		 * Checks for compatibility of client's software version with server version,
		 * by checking in the version table with the current client's version
		 */
		private function checkClientToServerCompatibility():void 
		{
			var versionHelper : VersionHelper = new VersionHelper();
			var clientVersion : String = "";
			applicationType::DesktopWeb 
			{
				//versionCheckerRO.executeSQL(database, "select latest from version where client_version = 'A-VIEW_Classroom-" + MainApp.AVIEW_VERSION + "' and supported = '1'");
				clientVersion = MainApp.AVIEW_VERSION;
			}
			applicationType::mobile 
			{
				//versionCheckerRO.executeSQL(database, "select latest from version where client_version = 'A-VIEW_Classroom-" + AVIEW_VERSION + "' and supported = '1'");
				clientVersion = AVIEW_VERSION;			
			}
			versionHelper.checkClientServerCompatibility(clientVersion, versionCheckHandler, faultHandler);
		}

		/**
		 * The function is the result handler of RemoteObject 'versionCheckerRO'.
		 * Based on the version check, it either displays an error box and closes the application
		 * OR
		 * Proceeds to check for the login details
		 *
		 * @param event of type ResultEvent
		 * @return void
		 */
		private function versionCheckHandler(event:ResultEvent):void 
		{
			var versionCheckResult : Boolean = event.result as Boolean;
			// If the version check result is true then proceed with login to the application
			if (versionCheckResult) 
			{
				applicationType::desktop
				{
					saveUserEnteredIPData();
				}
				var userHelper:UserHelper=new UserHelper();
				if (loginTypeIndex == 0) 
				{
					applicationType::DesktopWeb
					{
						if(userName != null)
						{
							userHelper.getUserByUserNamePassword(userName, SHA1.hash(password), getUserByUserNameResultHandler, getUserByUserNamePasswordFaultHandler);
						}						
					}
					applicationType::mobile 
					{
						if(userName!= null && userName!= "" && password!= null && password!= "")
						{
							userHelper.getUserByUserNamePassword(userName, password, getUserByUserNameResultHandler, getUserByUserNamePasswordFaultHandler);
							saveUserEnteredIPData();
						}
						else
						{
							this.dispatchEvent(new LoginStatusEvent(LoginStatusEvent.SERVER_CREATION_COMPLETE));
						}
					}
				} 
				else 
				{
					userHelper.getUserByUserName(userName, getUserByUserNameResultHandler);
				}				
			}
			else // if the version is out dated
			{
				applicationType::desktop
				{
					//Fix for #5200
					MessageBox.show("This A-View Client version " + MainApp.AVIEW_VERSION + " is no longer supported. \n" + "Please install the latest version from http://www.aview.in/ and try again.", "Alert", MessageBox.MB_OK, null, closeApplication, null, MessageBox.IC_ALERT);
				}
				applicationType::web{
					MessageBox.show("There is a new version of A-VIEW!!! \n Please click OK to load the latest version.", "Alert", MessageBox.MB_OK, null, applicationReload, null, MessageBox.IC_ALERT);
				}
				applicationType::mobile
				{
					//Fix for #5200
					MessageBox.show("This A-View Client version " + AVIEW_VERSION + " is no longer supported. \n" + "Please install the latest version from http://www.aview.in/ and try again.", "Alert", MessageBox.MB_OK, null, closeApplication, null, MessageBox.IC_ALERT);
				}				
			}
			loginFailCount=0;
		}
		
		/**
		 * The function is the fault handler of RemoteObject 'remoteObj'.
		 *  If an error occurs it displays an error message
		 *
		 * @param event of type FaultEvent
		 * @return void
		 */
		// The function is the fault handler
		// of RemoteObject 'remoteObj'.
		// If an error occurs it displays an error message 
		private function faultHandler(event:FaultEvent):void {
			/*if(loginFailCount == 0)
			{
			loginFailCount++;
			checkVersionCompatibility();
			return;
			}
			loginFailCount = 0;*/
			var faultMessage:String;
			if (userSelectedServer == Strings.NATIONAL_SERVER) {
				faultMessage="Connection Failed: Network may be down or server may be down"
				MessageBox.show(faultMessage, "Server Error", MessageBox.MB_OK); //SVRS-Issue no 159
			} else {
				faultMessage="Connection failed: wrong IP address or Network may be down or Server may be down"
				MessageBox.show(faultMessage, "Server Error", MessageBox.MB_OK); //SVRS-Issue no 159
			}
			//MessageBox.show("Fault occured while performing a remote operation. Please contact the administrator. Fault string:" + event.fault.faultString, "Server Error", MessageBox.MB_OK); //SVRS-Issue no 159
			//			if (Log.isInfo())	log.info(faultMessage + " Fault string:" + event.fault.faultString);
			if (Log.isError())
				log.error("entry::PrepareLogin::faultHandler:" + AbstractHelper.getStaticFaultMessage(event));
			logInButtonState=true; //enable login button if the user is not able to connect to server.
			applicationType::mobile {
				isLoginSuccess = true;
			}
		}
		
		private function closeApplication(event:MessageBoxEvent):void {
		}
		applicationType::web{
			//Fix for flexglobals cleanup in login
			public function applicationReload(event:MessageBoxEvent):void
			{
				ExternalInterface.call("refreshApplication");
			}
		}
		
		public function getUserByUserNameResultHandler(userVO:UserVO):void {
			if (userVO != null) {
				ClassroomContext.userVO=userVO;
				/*applicationType::web {
				//SSO - Overriding of user display name
				if (mainApp.ssoMode == Constants.guestLogin && FlexGlobals.topLevelApplication.parameters.udn != "") {
				userVO.fname=FlexGlobals.topLevelApplication.parameters.udn;
				}
				}*/
				getAllInitialData();
			} else {
				MessageBox.show("Please check your username and password", "Login Failed", MessageBox.MB_OK);
				if (Log.isInfo())
					log.info("Please check your username and password. Login failed");
				dispatchEvent(new LoginStatusEvent(LoginStatusEvent.LOGIN_FAILED));
			}
		}
		
		public function getAllInitialData():void {
			GCLMContext.getAllInitialData();
			//getAllModuleNames();
			var instituteHelper:InstituteHelper=new InstituteHelper();
			instituteHelper.getInstituteById(ClassroomContext.userVO.instituteId, getInstituteByIdResultHandler);
		}
		
		public function getUserByUserNamePasswordFaultHandler(event:FaultEvent):void {
			if (Log.isError())
				log.error("entry::PrepareLogin::getUserByUserNamePasswordFaultHandler:" + AbstractHelper.getStaticFaultMessage(event));
			loginFailedCount+=1;
			//Check if the failed login attempt reaches the MAX_LOGIN_ATTEMPT
			if (loginFailedCount >= MAX_LOGIN_ATTEMPT) {
				applicationType::DesktopWeb {
					mainApp.txtLoginPass.text='';
					captchaComp=new CaptchaComponent();
					PopUpManager.addPopUp(captchaComp, mainApp as DisplayObject, true);
					PopUpManager.centerPopUp(captchaComp);
				}
				//mainApp.createCaptcha(true);
			} else {
				applicationType::DesktopWeb {
					mainApp.txtLoginPass.text='';
					mainApp.txtLoginPass.setFocus();
					MessageBox.show(AbstractHelper.getStaticFaultMessage(event), "Error", MessageBox.MB_OK);
				}
				applicationType::mobile {
					isLoginSuccess = true;
					MessageBox.show("Please check your username and password", "ERROR", MessageBox.MB_OK, null, null, null, MessageBox.IC_ALERT);
					dispatchEvent(new LoginStatusEvent(LoginStatusEvent.LOGIN_FAILED));
				}
			}
			logInButtonState=true;
		}
		
		public function getInstituteByIdResultHandler(instituteVO:InstituteVO):void {
			ClassroomContext.userInstituteVO=instituteVO;
			applicationType::web {
				//Fix for issue #8867;
				//If stage is available then directly call function loginSuccess(), else call loginSuccess() after 1 second.
				if (FlexGlobals.topLevelApplication.stage) {
					loginSuccess();
				} else {
					stageCheckTimeOutID=setTimeout(loginSuccess, 1000);
				}
			}
			applicationType::DesktopMobile {
				applicationType::mobile {
					isLoginSuccess = true;
				}
				dispatchEvent(new LoginStatusEvent(LoginStatusEvent.LOGIN_SUCCESS));
			}
		}
		applicationType::web {
			//For Web:For temporary purpose. 
			private function loginSuccess():void {
				dispatchEvent(new LoginStatusEvent(LoginStatusEvent.LOGIN_SUCCESS));
			}
		}

		/*
		private function getAllModuleNames():void 
		{
			moduleLoaderRO.endpoint=ClassroomContext.WEBAPP_AVIEW_END_POINT;
			moduleLoaderRO.executeSQL(database, "select module_id, module_name from module where status_id = 1 order by module_name;");
		}
		
		private function getModuleNamesResult(event:ResultEvent):void {
			moduleNames=event.result as ArrayCollection;
			moduleNames.addItemAt({ module_name: 'Select module' }, 0);
			if (Log.isDebug())
				log.debug("Module name length is " + moduleNames.length);
		}
		
		private function getModuleNamesFault(event:FaultEvent):void {
			if (Log.isError())
				log.error("entry::PrepareLogin::getModuleNamesFault:" + AbstractHelper.getStaticFaultMessage(event));
			//			if (Log.isDebug()) 				log.debug("Module names could not be retrieved");
		}
		*/
		public function removeUserEnteredData():void {
			applicationType::DesktopWeb {
				for (var i:int=0; i < acUserSelectedServers.length; i++) {
					if (acUserSelectedServers[i].name == mainApp.cmbServerType.textInput.text.toString()) {
						acUserSelectedServers.removeItemAt(i);
						break;
					}
				}
				saveUserEnteredXML();
			}
		}
		applicationType::DesktopMobile {
			public function checkServerIsReachable(server:String):void {
				if (!serverInfo.serverDataCheck(server) && server != Strings.NATIONAL_SERVER) {
					applicationType::mobile{
						userSelectedIP = server;
					}
					timerServerResponseCount=0;
					serverInfo.checkServer(server);
					applicationType::mobile{
						FlexGlobals.topLevelApplication.callLater(checkServerResponseStatus);
					}
					applicationType::desktop{
						setTimeout(checkServerResponseStatus, 500);
					}
				} else {
					if (!serverInfo.isReachable(server)) {
						if (userSelectedServer == Strings.NATIONAL_SERVER) {
							MessageBox.show("Connection Failed: Network may be down or server may be down", "Server Error", MessageBox.MB_OK);
						} else {
							MessageBox.show("Connection failed: wrong IP address or Network may be down or Server may be down", "Server Error", MessageBox.MB_OK);
							applicationType::mobile {
								isLoginSuccess = true;
							}
						}
						logInButtonState=true;
					}
					else{
						this.dispatchEvent(new LoginStatusEvent(LoginStatusEvent.SERVER_CREATION_COMPLETE));
					}
				}
			}
		}
		private function enableLogin():void{
			applicationType::mobile {
				if(!isLoginSuccess){
					this.dispatchEvent(new LoginStatusEvent(LoginStatusEvent.SERVER_ERROR));
					MessageBox.show("Couldnot connect to server, Please try again", "Server Error", MessageBox.MB_OK);
				}
			}
		}
	}
}
