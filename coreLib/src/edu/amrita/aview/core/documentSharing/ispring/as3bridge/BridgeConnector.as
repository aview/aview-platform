package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	import flash.net.LocalConnection;
	
	internal class BridgeConnector extends LocalConnection
	{
		private var m_callFunctions:Object;
		private var m_eventConnectionName:String;
		private var m_commandConnectionName:String;
		private var m_log:LogConsole;
		
		public function BridgeConnector(eventConnectionName:String, commandConnectionName:String)
		{
			m_log=LogConsole.getInstance();
			
			m_eventConnectionName=eventConnectionName;
			m_commandConnectionName=commandConnectionName;
			
			m_callFunctions=new Object();
			
			this.client=this;
			this.allowDomain("*");
			this.connect(m_eventConnectionName);
		}
		
		public function sendCommand(methodName:String, ... arguments):void
		{
			switch (arguments.length)
			{
				case 0:
					super.send(m_commandConnectionName, methodName);
					break;
				case 1:
					super.send(m_commandConnectionName, methodName, arguments[0]);
					break;
				case 2:
					super.send(m_commandConnectionName, methodName, arguments[0], arguments[1]);
					break;
				case 3:
					super.send(m_commandConnectionName, methodName, arguments[0], arguments[1], arguments[2]);
					break;
			}
		}
		
		public function setOnBridgeLoadedCallback(f:Function):void
		{
			m_callFunctions.onBridgeLoadedCallback=f;
		}
		
		// set callback functions (sound controller) >
		public function setOnSoundVolumeChangedCallback(f:Function):void
		{
			m_callFunctions.onSoundVolumeChangedCallback=f;
		}
		
		public function setOnVolumeChangingCompleteCallback(f:Function):void
		{
			m_callFunctions.onVolumeChangingCompleteCallback=f;
		}
		
		// set callback functions (sound controller) <
		
		// set callback functions (playback controller) >
		public function setOnPausePlaybackCallback(f:Function):void
		{
			m_callFunctions.onPausePlaybackCallback=f;
		}
		
		public function setOnStartPlaybackCallback(f:Function):void
		{
			m_callFunctions.onStartPlaybackCallback=f;
		}
		
		public function setOnAnimationStepChangedCallback(f:Function):void
		{
			m_callFunctions.onAnimationStepChangedCallback=f;
		}
		
		public function setOnSlidePositionChangedCallback(f:Function):void
		{
			m_callFunctions.onSlidePositionChangedCallback=f;
		}
		
		public function setOnCurrentSlideIndexChangedCallback(f:Function):void
		{
			m_callFunctions.onCurrentSlideIndexChangedCallback=f;
		}
		
		public function setOnSlideLoadingCompleteCallbackPlaybackController(f:Function):void
		{
			m_callFunctions.onSlideLoadingCompleteCallbackPlaybackController=f;
		}
		
		public function setOnPresentationPlaybackCompleteCallback(f:Function):void
		{
			m_callFunctions.onPresentationPlaybackCompleteCallback=f;
		}
		
		public function setOnSeekingCompleteCallback(f:Function):void
		{
			m_callFunctions.onSeekingCompleteCallback=f;
		}
		
		// set callback functions (playback controller) <
		
		// set callback functions (player) >
		public function setOnPresentationLoadedCallbackPlayer(f:Function):void
		{
			m_callFunctions.onPresentationLoadedCallbackPlayer=f;
		}
		
		// set callback functions (player) <
		
		// set callback functions (presentation info) >
		public function setOnPresentationLoadedCallbackPresentationInfo(f:Function):void
		{
			m_callFunctions.onPresentationLoadedCallbackPresentationInfo=f;
		}
		
		// set callback functions (presentation info) <
		
		// set callback functions (slides collection) >
		public function setOnSlideMetadataLoadCallback(f:Function):void
		{
			m_callFunctions.onSlideMetadataLoadCallback=f;
		}
		
		public function removeOnSlideMetadataLoadCallback():void
		{
			m_callFunctions.onSlideMetadataLoadCallback=null;
		}
		
		public function setOnSlideLoadingCompleteSlidesCollection(f:Function):void
		{
			m_callFunctions.onSlideLoadingCompleteSlidesCollection=f;
		}
		
		public function removeOnSlideLoadingCompleteSlidesCollection():void
		{
			m_callFunctions.onSlideLoadingCompleteSlidesCollection=null;
		}
		
		// set callback functions (slides collection) >
		
		
		// local connection functions (playback listener) >
		public function onPausePlayback():void
		{
			m_callFunctions.onPausePlaybackCallback();
		}
		
		public function onStartPlayback():void
		{
			m_callFunctions.onStartPlaybackCallback();
		}
		
		public function onAnimationStepChanged(stepIndex:Number):void
		{
			m_callFunctions.onAnimationStepChangedCallback(stepIndex);
		}
		
		public function onSlidePositionChanged(position:Number):void
		{
			m_callFunctions.onSlidePositionChangedCallback(position);
		}
		
		public function onCurrentSlideIndexChanged(slideIndex:Number, slideDuration:Number):void
		{
			m_callFunctions.onCurrentSlideIndexChangedCallback(slideIndex, slideDuration);
		}
		
		public function onSlideLoadingComplete(slideIndex:Number):void
		{
			m_callFunctions.onSlideLoadingCompleteCallbackPlaybackController(slideIndex);
			m_callFunctions.onSlideLoadingCompleteSlidesCollection(slideIndex);
		}
		
		public function onPresentationPlaybackComplete():void
		{
			m_callFunctions.onPresentationPlaybackCompleteCallback();
		}
		
		// local connection functions (playback listener) <
		
		// local connection functions (sound listener) >
		public function onSoundVolumeChanged(volume:Number):void
		{
			m_callFunctions.onSoundVolumeChangedCallback(volume);
		}
		
		// local connection functions (sound listener) <
		
		// local connection functions >
		public function onPresentationLoaded(succeeded:Boolean, presentationInfo:Object):void
		{
			if (succeeded)
				m_callFunctions.onPresentationLoadedCallbackPresentationInfo(presentationInfo);
			
			m_callFunctions.onPresentationLoadedCallbackPlayer(succeeded);
		}
		
		public function onBridgeLoaded():void
		{
			m_callFunctions.onBridgeLoadedCallback();
		}
		
		public function onSeekingComplete():void
		{
			m_callFunctions.onSeekingCompleteCallback();
		}
		
		public function onVolumeChangingComplete():void
		{
			m_callFunctions.onVolumeChangingCompleteCallback();
		}
		
		public function onSlideMetadataLoad(slideIndex:Number, slideInfo:Object):void
		{
			m_callFunctions.onSlideMetadataLoadCallback(slideIndex, slideInfo);
		}
		
		public function onUnloadPresentationComplete():void
		{
			m_callFunctions.onUnloadPresentationCompleteCallback();
		}
		
		public function onPrintString(msg:String):void
		{
			m_log.writeLine(">>> " + msg);
		}
		
		public function onPrintObject(obj:Object):void
		{
			m_log.printObject(obj);
		}
		// local connection functions <
	}
}
