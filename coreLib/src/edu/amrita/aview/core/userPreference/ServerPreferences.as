package edu.amrita.aview.core.userPreference
{
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.*;
	import mx.utils.ObjectUtil;
	import mx.utils.URLUtil;
	
	public class ServerPreferences extends EventDispatcher
	{
		public var serverSettingsContext:Dictionary;
		private var loader:URLLoader;
		
		
		public function ServerPreferences()
		{
			initServerContext();
		}
		
		public function pingServers(servers:ArrayCollection):void
		{
			if (servers.length == 0)
				return;
			// todo: update context, if the server is not already in the context
			if(serverSettingsContext[servers.getItemAt(0)] == null) {
				readServers(servers);
			}
			
			for (var i:int=0; i < servers.length; i++)
			{
				// ping server for http request
				var http:HTTPService=httpFactory();
				http.url=serverSettingsContext[servers.getItemAt(i)].http.url;
				http.addEventListener(FaultEvent.FAULT, faultHandler);
				http.addEventListener(ResultEvent.RESULT, resultHandler);
				http.send();
				// ping server for https request
				var https:HTTPService=httpFactory();
				https.url=serverSettingsContext[servers.getItemAt(i)].https.url;
				https.addEventListener(FaultEvent.FAULT, faultHandler);
				https.addEventListener(ResultEvent.RESULT, resultHandler);
				https.send();
			}
			
		}
		
		public function readServers(servers:ArrayCollection):void
		{
			// TODO: read from the local settings file instead of hardcoding server names
			/*var servers:ArrayList=new ArrayList();
			servers.addItem("cms006.aview.in");
			servers.addItem("aview.in");
			servers.addItem("172.17.9.137:8080");
			servers.addItem("aps003.aview.in");*/
			this.createServerContextScaffold(servers);
		}
		
		private function initServerContext():void
		{
			serverSettingsContext=new Dictionary();
			serverSettingsContext["timeoutSetting"]=5;
			serverSettingsContext["resultFormat"]="text";
			serverSettingsContext["requestMethod"]="HEAD";
			serverSettingsContext["resourceContext"]="/aview/";
			serverSettingsContext["preferredServerIndex"]=0;
		}
		
		protected function httpFactory():HTTPService
		{
			var http:HTTPService=new HTTPService();
			http.resultFormat=serverSettingsContext["resultFormat"];
			http.method=serverSettingsContext["requestMethod"];
			http.requestTimeout=serverSettingsContext["timeoutSetting"];
			return http;
		}
		
		/**
		 *Status code: -1 : server data initiated 
		 *Status code: 0 : server not reachable 
		 *Status code: 1 : server reachable 
		 * 
		 **/
		
		private function createServerContextScaffold(servers:ArrayCollection):void
		{
			for (var i:int=0; i < servers.length; i++)
			{
				var server:String=servers.getItemAt(i).toString();
				serverSettingsContext[server]=new Object();
				serverSettingsContext[server].isHttpsEnabled=0;
				serverSettingsContext[server].isUp=-1;
				serverSettingsContext[server].preferredAviewURL=0;
				
				var protocols:Array=["http", "https"];
				for (var j:int=0; j < protocols.length; j++)
				{
					var ds:Object=new Object();
					ds.isReachable=0;
					ds.statusCode=0;
					ds.url=encodeURI(protocols[j] + "://" + server + serverSettingsContext["resourceContext"]);
					ds.errMsg="";
					serverSettingsContext[server][protocols[j]]=ds;
				}
			}
			pingServers(servers);
			
		}
		
		private function resultHandler(successEvent:ResultEvent):void
		{
			// populate the serverContext with information
			var statusCode:int=successEvent.statusCode;
			var protocol:String=mx.utils.URLUtil.getProtocol(successEvent.target.url);
			var contextKey:String=mx.utils.URLUtil.getServerNameWithPort(successEvent.target.url);
			
			serverSettingsContext[contextKey][protocol].statusCode=statusCode;

			if (serverSettingsContext[contextKey][protocol].statusCode == 200)
			{
				serverSettingsContext[contextKey][protocol].isReachable=1;
				serverSettingsContext[contextKey].isUp=1;
				// TODO: instead of below, create a function setServerPreferences()
				if (protocol.toLowerCase() == "https")
					serverSettingsContext[contextKey].isHttpsEnabled = 1;
				
				serverSettingsContext[contextKey].preferredAviewURL = (serverSettingsContext[contextKey].isHttpsEnabled == 1) ? 
					serverSettingsContext[contextKey].https.url :
				serverSettingsContext[contextKey].http.url;
			}

			trace("form success handler============================================\n", ObjectUtil.toString(serverSettingsContext));
		}
		
		
		private function faultHandler(faultEvent:FaultEvent):void
		{
			trace("in the fault handler, ", faultEvent);
			var protocol:String=mx.utils.URLUtil.getProtocol(faultEvent.target.url);
//			serverSettingsContext[contextKey].isReachable = 0;
			var contextKey:String=mx.utils.URLUtil.getServerNameWithPort(faultEvent.target.url);
			if(serverSettingsContext[contextKey].isUp== -1)
				serverSettingsContext[contextKey].isUp=0;
			serverSettingsContext[contextKey][protocol].errMsg=(faultEvent.fault.message).toString();
			trace("form fault handler============================================\n", ObjectUtil.toString(serverSettingsContext));
		}
		
		

		
		
		private function serlializeServerContext():void{
			// TODO: save the server settings on :
			// correct login
			// change the preferred server to the last login server
		}
	}
}