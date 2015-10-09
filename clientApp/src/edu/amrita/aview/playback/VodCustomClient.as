package edu.amrita.aview.playback
{
	import mx.logging.ILogger;
	import mx.logging.Log;

	//VVCR: If this file is being used, it needs clear documentation which not present now.
	public class VodCustomClient
	{
		/**
		 * For debug log
		 */
		private var log:ILogger=Log.getLogger("aview.modules.playback.VodCustomClient.as");
		
		public function VodCustomClient()
		{
		}
		public function onBWDone ( ...args ):void
		{
		
		}

		public function onLastSecond ( ...args ):void
		{
		
		}

        public function onPlayStatus(info:Object):void 
		{
			if(Log.isDebug()) log.debug("onPlay");
        }
        public function onMetaData(info:Object):void {
               
        }
        public function onCuePoint(info:Object):void 
		{
			if(Log.isDebug()) log.debug("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
        } 
	}
}