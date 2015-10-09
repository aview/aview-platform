package edu.amrita.aview.core.userPreference
{
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;	
	/**
	 * 
	 * @author kashwini
	 */
	public class RemoteServerPreferenceFac
	{
		public var sp:ServerWorker;
		/**
		 * 
		 */
		public function RemoteServerPreferenceFac()
		{
			// perform initialization operations here
			sp = new ServerWorker();
		}
		
		public function getPreferredProtocol(server:String, context:String):String{
			return (true == this.isReachable(server)) ? 
				((true == this.isHttpsEnabled(server)) ? "https" : "http") : 
				"http";
		}
		
		public function serverDataCheck(server:String):Boolean
		{
			return sp.serverIPDataCheck(server);
		}
		
		/**
		 * Check one server for availability status (and other 
		 * relavant information)
		 * This function would get information of a particular server 
		 * and set the relevant details in its local cache.
		 * To get the server status, call the isReachable() and
		 * isHttpsEnabled() methods
		 * 
		 * @param server  this is the domain name
		 */
		public function checkServer(server:String):void{
			var servers:ArrayCollection = new ArrayCollection();
			if (server != "" && server != null) {
				if (!ServerWorker.serverSettingsContext.hasOwnProperty(server)){
					servers.addItem(server);
					sp.createServerContextScaffold(servers);
					sp.pingServers(servers);
				}
			}
		}
		
		/**
		 * This function would ping all servers passed in and get details;
		 * then store it in the local cache. 
		 * This is an async function. For synchronous blocking calls
		 * please use the foceReEvaluateServerSync() method
		 * @param servers
		 */
		public function checkServersBatch(servers:ArrayCollection):void{
			var domains: ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < servers.length; i++) {
				domains.addItem(servers[i].domain);
			}
			
			sp.createServerContextScaffold(domains);			
			sp.pingServers(domains);
		}
		
		public function serverStatus(server:String):int{
			var status: int = -1 ;
			status = sp.serverStatusData(server);
			return status;
		}
		
		/**
		 * This function checks the local cache and returns
		 * Please dont call this function unless you have already made one of 
		 * the following calls:  checkServer, checkServers or foceReEvaluateServerSync
		 * true: if the server is up
		 * false: if the server is not up
		 */
		
		public function isReachable(server:String):Boolean{
			var status: Boolean = false ;
			if (server != null && ServerWorker.serverSettingsContext.hasOwnProperty(server))
				status = (1 == ServerWorker.serverSettingsContext[server].isUp) ? true : false;
			return status;
		}
		
		/**
		 * This function checks the local cache and returns
		 * true: if the server supports https
		 * false: if the server is not enabled for https
		 */
		
		public function isHttpsEnabled(server:String):Boolean{
			var status:Boolean = false;
			if (server != null && ServerWorker.serverSettingsContext.hasOwnProperty(server))
				status = (1 == ServerWorker.serverSettingsContext[server].isHttpsEnabled) ? true : false
			return status;
		}
		
		
		public function getPreferredAviewProtocol(server:String):String{
			var protocol : String = "http";
			if(this.isReachable(server))
				protocol = this.isHttpsEnabled(server) ? "https" : "http";
			return protocol;
		}
		/**
		 * This function can be called on certain events, 
		 * and the details of the context can be dumped
		 * to a local file.
		 */
		public function sereializeServerPreference():void{
			
		}
		
		/**
		 * This function can will re-read server preferences from the local file
		 */
		public function reloadServerPreference():void{
			// get all servers from the server context
			// re-initialize serverContext
			// ping all the servers obtained from 1)
		}		
		
		/**
		 * This is a future functionality. Based on the successful login count
		 * a preferred server can be highlighted for the end user
		 * 
		 */		
		public function setPreferredServer():void{
			
		}
		
		/**
		 * This is a future functionality. Based on the successful login count
		 * a preferred server can be highlighted for the end user
		 * 
		 */		
		public function getPreferredServer():void{
			
		}
		
		public function dumpInfo():void{
			trace("dump local context============================================\n", ObjectUtil.toString(ServerWorker.serverSettingsContext));
		}
	}
}