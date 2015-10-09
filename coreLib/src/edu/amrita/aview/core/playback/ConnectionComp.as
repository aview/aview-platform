package edu.amrita.aview.core.playback
{
	import flash.events.EventDispatcher;
	import flash.net.NetConnection;

	public class ConnectionComp extends EventDispatcher
	{
		public var netConnection:NetConnection
		public function ConnectionComp(fmsPath:String)
		{
			netConnection= new NetConnection(); 
	 		/* netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onVideoConnectError) 
	  	  	netConnection.addEventListener(NetStatusEvent.NET_STATUS, onVideoConnect)  */
			netConnection.connect(fmsPath); 
			netConnection.client=new VodCustomClient();
		}
		
		
	}
}