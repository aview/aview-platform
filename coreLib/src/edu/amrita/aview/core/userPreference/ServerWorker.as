package edu.amrita.aview.core.userPreference
{
	/**
	 * Three API's for getting server information
	 * 	1) using the plain http object
	 * 	2) using the URLRequestHeader() option
	 *  3) using the native option (TODO)
	 * 
	 */
	
	import flash.events.*;
	import flash.net.SecureSocket;
	import flash.net.Socket;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.*;
	import mx.utils.ObjectUtil;
	import mx.utils.URLUtil;	
	import mx.logging.ILogger;
	import mx.logging.Log;	

	
	
	/**
	 * 
	 * @author kashwini
	 */
	public class ServerWorker extends EventDispatcher
	{
		private var log:ILogger=Log.getLogger("aview.main.CheckServers");
		internal static var serverSettingsContext:Object = {
			"timeoutSetting" : 5
			,"resultFormat"  : "text"
			,"requestMethod" : "HEAD"
			,"resourceContext":"/aview/"
			,"preferredServerIndex" : 0
			,"retryCount"    : 3
		};
		var defServerCtx: Function = function():Object {
			return { "isHttpsEnabled" : 0, 
					 "isUp" : -1 ,
				     "preferredAviewURL" : ""
					};
		};
		var defProtocolCtx: Function= function():Object {return {
			"isReachable" : 0
			,"statusCode" : 0
			,"url" : ""
			,"errMsg" : ""
			,"retryCount" : serverSettingsContext["retryCount"]
		};};
		
		/**
		 * 
		 */
		public function ServerWorker()
		{
			_readServersFromFile();
		}
		
		internal function serverStatusData(server:String):int
		{
			var status:int = -2;
			if (server != null && serverSettingsContext.hasOwnProperty(server))
				status = serverSettingsContext[server].isUp;
			return status;
		}

		internal function serverIPDataCheck(server:String):Boolean
		{
			var isExist:Boolean = false;
			if (server != null && !serverSettingsContext.hasOwnProperty(server))
				isExist = true;
			
			return isExist;
		}
		/**
		 * Any server I pass here, will be added to the 
		 * server context.
		 * Status code: -1 : server data initiated 
		 * Status code: 0 : server not reachable 
		 * Status code: 1 : server reachable 
		 * for each server that is passed in an argument, 
		 * a well defined structure is created and stored in memory
		 * TODO: define a static JSON structure or XSD/XML to store this information
		 **/
		
		internal function createServerContextScaffold(servers:ArrayCollection):void
		{
			for (var i:int=0; i < servers.length; i++){
				var server:String=servers.getItemAt(i).toString();
				if(null != serverSettingsContext[server] ){
					// this consition will occur when the client manually retries. 
					// in that case, resetting the retry count to its original valus
					serverSettingsContext[server].http.retryCount = serverSettingsContext["retryCount"];
					serverSettingsContext[server].https.retryCount = serverSettingsContext["retryCount"];
					break;
				}
				serverSettingsContext[server] = defServerCtx();
				
				var protocols:Array=["http", "https"];
				for (var j:int=0; j < protocols.length; j++) {
					serverSettingsContext[server][protocols[j]] = defProtocolCtx();
					serverSettingsContext[server][protocols[j]].url = encodeURI(protocols[j] + "://" + server + serverSettingsContext["resourceContext"]);
				}
			}
		}
	
		/**
		 * 
		 */
		private function _readServersFromFile():void{
			// TODO: read the servers from the file
			// read the stored preferences for the server
			// create the default scaffolding
			/*var servers:ArrayCollection = new ArrayCollection();
			servers.addItem("cms006.aview.in");
			servers.addItem("aps003.aview.in");
			servers.addItem("aps006.aview.in");
			this.createServerContextScaffold(servers);		
			// TODO: call ping servers here
			pingServers(servers);*/
		}
		
		
		/**
		 * This function would ping the http & https urls (with aview 
		 * context) of servers that are passed in as arguments
		 * This function should be called after the scaffold for
		 * a particular server has been created
		 * 
		 * TODO: 1) implement URLload option
		 * TODO: 2) implement a native option to avoid un-necessary popups
		 * TODO: 3) change the declaration to accept a context as parameter /aview/
		 */
		internal function pingServers(servers:ArrayCollection):void{
			for (var i:int=0; i < servers.length; i++){
				var server:String = servers.getItemAt(i).toString();
				this._pingServer(server, "http");
				this._pingServer(server, "https");
			}
		}
		
		/**
		 * This method uses the HTTP mechanism to check for server availability
		 * @param server
		 * @param protocol
		 */
		private var socketMode: Boolean = false;
		private function _pingServer(server:String, protocol:String): void{
			
			applicationType::desktop{
				socketMode = true;
			}
			if (socketMode){
				_pingSocket(server, protocol);
			} else {
				var http:HTTPService = getHttpObject(server, protocol);
				http.addEventListener(FaultEvent.FAULT, httpHeadReqFaultHandler);
				http.addEventListener(ResultEvent.RESULT, httpHeadReqResultHandler);
				http.send();
			}
		}
		
		/**
		 * Helper function to create the HTTP object with some defaults
		 */
		protected function getHttpObject(server:String, protocol:String):HTTPService
		{
			var http:HTTPService=new HTTPService();
			http.resultFormat=serverSettingsContext["resultFormat"];
			http.url=serverSettingsContext[server][protocol].url;
			http.method=serverSettingsContext["requestMethod"];
			http.requestTimeout=serverSettingsContext["timeoutSetting"];
			http.headers["Pragma"] = "no-cache";
			applicationType::desktop{
				http.headers["Cache-Control"] = "no-cache";
				http.headers["Content-Length"] = 0;
			}
			return http;
		}
		
		
		/**
		 * Update the server settings context with the information present
		 * in the response from the servers
		 */
		private function httpHeadReqResultHandler(successEvent:ResultEvent):void
		{
			// populate the serverContext with information
			var statusCode:int=successEvent.statusCode;
			var protocol:String=mx.utils.URLUtil.getProtocol(successEvent.target.url);
			var contextKey:String=mx.utils.URLUtil.getServerNameWithPort(successEvent.target.url);
			
			serverSettingsContext[contextKey][protocol].statusCode=statusCode;
			
			if (serverSettingsContext[contextKey][protocol].statusCode == 200)
			{
				serverSettingsContext[contextKey][protocol].isReachable=1;
				serverSettingsContext[contextKey][protocol].errMsg = "";
				serverSettingsContext[contextKey].isUp=1;
				// TODO: instead of below, create a function setServerPreferences()
				if (protocol.toLowerCase() == "https")
					serverSettingsContext[contextKey].isHttpsEnabled = 1;
				
				serverSettingsContext[contextKey].preferredAviewURL = 
					(serverSettingsContext[contextKey].isHttpsEnabled == 1) ? 
					serverSettingsContext[contextKey].https.url :
					serverSettingsContext[contextKey].http.url;
			}
			log.info("["+contextKey+"] form success handler+++++++++++++++++++++++++++++++++++++++\n", ObjectUtil.toString(serverSettingsContext[contextKey][protocol]));
		}
		
		/**
		 * Update the server settings context with the information from
		 * fault data received
		 * -1 implies, havent received a response
		 * 0 implies, failure of some sort
		 * 1 implies success
		 */
		private function httpHeadReqFaultHandler(faultEvent:FaultEvent):void
		{
			var protocol:String=mx.utils.URLUtil.getProtocol(faultEvent.target.url);
			var contextKey:String=mx.utils.URLUtil.getServerNameWithPort(faultEvent.target.url);
			if(serverSettingsContext[contextKey].isUp== -1)
				serverSettingsContext[contextKey].isUp = 0;
			
			//if the call has failed, retry for X (refer context for the number of retries) number of times
			serverSettingsContext[contextKey][protocol].retryCount --;
			if (serverSettingsContext[contextKey][protocol].retryCount > 0){
				this._pingServer(contextKey, protocol);
			}
			serverSettingsContext[contextKey][protocol].errMsg=(faultEvent.fault.message).toString();
			log.info("["+contextKey+"] form fault handler============================================\n", ObjectUtil.toString(serverSettingsContext[contextKey][protocol]));
		}
		
		

		/**
		 * This method will save the server context into a local file
		 */
		private function serlializeServerContext():void{
			// TODO: save the server settings on :
		}
//		+++++++++++++++++++++++++++++begin socket implementation================================
		
		private function _pingSocket(server:String, proto: String): void{
			var temp:Array = server.split(":");
			var host:String = temp[0];
			var gotport:int = (temp[1]) ? int(temp[1]): 0;
			var port: int = 80;
			if (proto == "https") {
				if (gotport == 0 || gotport == 80)
					port = 443;
				else
					port = gotport;
			} else {
				if (gotport == 0)
					port = 80;
				else 
					port = int(gotport);
			}
			var timeout : uint = int(serverSettingsContext.timeoutSetting) * 1000;
			if (proto == "http"){
				var sock: Socket = new Socket();
				sock.timeout = timeout;
//				sock.addEventListener(Event.ACTIVATE, sockActivateHandler);
//				sock.addEventListener(Event.CLOSE, sockCloseHandler);
//				sock.addEventListener(Event.CONNECT, sockConnectHandler(proto,host));
				sock.addEventListener(Event.CONNECT, function onblah(e:Event){sockConnectHandler(e,proto,server)});
//				sock.addEventListener(Event.DEACTIVATE, sockDeactivateHandler);
				sock.addEventListener(IOErrorEvent.IO_ERROR, sockIOErrorHandler);
				sock.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, sockOutputProgressHandler);
//				sock.addEventListener(ProgressEvent.SOCKET_DATA, sockDataHandler);
//				sock.addEventListener(SecurityErrorEvent.SECURITY_ERROR, sockSecurityErrorHandler);
				sock.addEventListener(flash.events.ErrorEvent.ERROR, sockErrorHandler); 
				sock.connect(host, port);
				trace ("sending request to server: " + host + " : "+ port + " : " +proto );
			}
			else if (proto == "https") {
				var secureSock : SecureSocket = new SecureSocket();
				secureSock.timeout = timeout;
				secureSock.addEventListener(Event.CONNECT,function onblah(e:Event){secsockConnectHandler(e,proto,server)});
//				secureSock.addEventListener(Event.CONNECT,secsockConnectHandler);
				secureSock.addEventListener(IOErrorEvent.IO_ERROR, function onblah(e:Event){secsockIOErrorHandler(e,proto,server)});
				secureSock.addEventListener(SecurityErrorEvent.SECURITY_ERROR, secsockSecurityErrorHandler);
				secureSock.connect(host, port);
				trace ("sending request to server: " + host + " : "+ port + " : " +proto );
			}
		}
		
		protected function sockErrorHandler(event:Event):void
		{
			// TODO Auto-generated method stub
			trace ("in sock Error Handler");
		}
		
		protected function sockOutputProgressHandler(event:OutputProgressEvent):void
		{
			// TODO Auto-generated method stub
			trace ("in OutputProgressEvent");
		}
		
		protected function sockDeactivateHandler(event:Event):void
		{
			// TODO Auto-generated method stub
			trace ("in deactivate");
		}
		
		protected function sockActivateHandler(event:Event):void
		{
			// TODO Auto-generated method stub
			trace ("in sockActivateHandler");

		}
		
		protected function sockCloseHandler(event:Event):void
		{
			// TODO Auto-generated method stub
			trace ("in sockCloseHandler");

		}
		
		protected function sockDataHandler(event:ProgressEvent):void
		{
			// TODO Auto-generated method stub
			trace ("in sockDataHandler");

		}
		
		
		protected function sockSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			// TODO Auto-generated method stub
			trace ("in SecurityErrorEvent");
		}
		
		protected function sockConnectHandler(event:Event, proto:String, server:String):void
		{
			log.info("sockConnectHandler - " + proto + " " + server);
			trace ("in connect handler" + proto +":" + server);
			var result:String   = event.target.connected;
			var protocol:String  = proto;
			var contextKey:String= server;
			
			serverSettingsContext[contextKey][protocol].statusCode = result;
			
			if (serverSettingsContext[contextKey][protocol].statusCode.toLowerCase() == "true")
			{
				serverSettingsContext[contextKey][protocol].isReachable=1;
				serverSettingsContext[contextKey][protocol].errMsg = "";
				serverSettingsContext[contextKey].isUp=1;
				// TODO: instead of below, create a function setServerPreferences()
				if (protocol.toLowerCase() == "https")
					serverSettingsContext[contextKey].isHttpsEnabled = 1;
				
				serverSettingsContext[contextKey].preferredAviewURL = 
					(serverSettingsContext[contextKey].isHttpsEnabled == 1) ? 
					serverSettingsContext[contextKey].https.url :
					serverSettingsContext[contextKey].http.url;
			}
			log.info("["+contextKey+"] form success handler+++++++++++++++++++++++++++++++++++++++\n", ObjectUtil.toString(serverSettingsContext[contextKey][protocol]));
		}
		
		protected function sockIOErrorHandler(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			log.error ("in IOErrorEvent");
		}
		
// ==============================================================================		
		
		protected function secsockSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			// TODO Auto-generated method stub
			log.error ("in secure SecurityErrorEvent");
		}
		
		protected function secsockIOErrorHandler(event:Event, proto:String, server:String):void
		{
			// TODO Auto-generated method stub
			log.error ("in secure IOErrorEvent " + proto + ": " + server);
			// serverCertificateStatus	 = invalid
		}
		
		protected function secsockConnectHandler(event:Event, proto:String, server:String):void
		{
			// TODO Auto-generated method stub
			trace ("in secure connect handler");
//			event.target.remoteAddress;
//			event.target.serverCertificateStatus
			var statusCode:String   = event.target.serverCertificateStatus;
			var protocol:String  = proto;
			var contextKey:String= server;
			
			serverSettingsContext[contextKey][protocol].statusCode=statusCode;
			
			if (serverSettingsContext[contextKey][protocol].statusCode.toLowerCase() == "trusted")
			{
				serverSettingsContext[contextKey][protocol].isReachable=1;
				serverSettingsContext[contextKey][protocol].errMsg = "";
				serverSettingsContext[contextKey].isUp=1;
				// TODO: instead of below, create a function setServerPreferences()
				if (protocol.toLowerCase() == "https")
					serverSettingsContext[contextKey].isHttpsEnabled = 1;
				
				serverSettingsContext[contextKey].preferredAviewURL = 
					(serverSettingsContext[contextKey].isHttpsEnabled == 1) ? 
					serverSettingsContext[contextKey].https.url :
					serverSettingsContext[contextKey].http.url;
			}
			log.info("["+contextKey+"] form success handler+++++++++++++++++++++++++++++++++++++++\n", ObjectUtil.toString(serverSettingsContext));
		
		}

	}
}