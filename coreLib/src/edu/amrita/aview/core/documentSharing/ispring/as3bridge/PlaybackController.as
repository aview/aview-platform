package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	import flash.events.EventDispatcher;
	
	public class PlaybackController extends EventDispatcher
	{
		private var m_bridgeConnector:BridgeConnector;
		
		private var m_isPlaying:Boolean;
		private var m_currentStepIndex:Number;
		private var m_currentSlidePlaybackPosition:Number;
		private var m_currentSlideIndex:Number;
		private var m_currentSlideDuration:Number;
		
		public function PlaybackController(internalClass:InternalClass, bridgeConnector:BridgeConnector)
		{
			m_bridgeConnector=bridgeConnector;
			initEventFunctions();
		}
		
		// playback controller functions >
		public function gotoNextSlide(autoStart:Boolean=true):void
		{
			m_bridgeConnector.sendCommand("gotoNextSlide", autoStart);
		}
		
		public function gotoPreviousSlide(autoStart:Boolean=true):void
		{
			m_bridgeConnector.sendCommand("gotoPreviousSlide", autoStart);
		}
		
		public function play():void
		{
			m_bridgeConnector.sendCommand("play");
		}
		
		public function pause():void
		{
			m_bridgeConnector.sendCommand("pause");
		}
		
		public function get isPlaying():Boolean
		{
			return m_isPlaying;
		}
		
		public function get currentSlideDuration():Number
		{
			return m_currentSlideDuration;
		}
		
		public function gotoLastViewedSlide(autoStart:Boolean=true):void
		{
			m_bridgeConnector.sendCommand("gotoLastViewedSlide", autoStart);
		}
		
		public function get currentSlideIndex():Number
		{
			return m_currentSlideIndex;
		}
		
		public function gotoSlide(slideIndex:Number, autoStart:Boolean=true):void
		{
			m_bridgeConnector.sendCommand("gotoSlide", slideIndex, autoStart);
		}
		
		public function get currentSlidePlaybackPosition():Number
		{
			return m_currentSlidePlaybackPosition;
		}
		
		public function pauseCurrentSlideAt(position:Number):void
		{
			m_bridgeConnector.sendCommand("pauseCurrentSlideAt", position);
		}
		
		public function playCurrentSlideFrom(position:Number):void
		{
			m_bridgeConnector.sendCommand("playCurrentSlideFrom", position);
		}
		
		public function seek(position:Number):void
		{
			m_bridgeConnector.sendCommand("seek", position);
		}
		
		public function endSeek(resumePlayback:Boolean=true):void
		{
			m_bridgeConnector.sendCommand("endSeek", resumePlayback);
		}
		
		public function get currentStepIndex():Number
		{
			return m_currentStepIndex;
		}
		
		public function gotoNextStep():void
		{
			m_bridgeConnector.sendCommand("gotoNextStep");
		}
		
		public function gotoPreviousStep():void
		{
			m_bridgeConnector.sendCommand("gotoPreviousStep");
		}
		
		public function playFromStep(stepIndex:Number):void
		{
			m_bridgeConnector.sendCommand("playFromStep", stepIndex);
		}
		
		public function pauseAtStepStart(stepIndex:Number):void
		{
			m_bridgeConnector.sendCommand("pauseAtStepStart", stepIndex);
		}
		
		public function pauseAtStepEnd(stepIndex:Number):void
		{
			m_bridgeConnector.sendCommand("pauseAtStepEnd", stepIndex);
		}
		
		// playback controller functions <
		
		// playback events >
		private function onSeekingCompleteCallback():void
		{
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.SEEKING_COMPLETE);
			e.playbackController=this;
			e.position=m_currentSlidePlaybackPosition;
			dispatchEvent(e);
		}
		
		private function onPausePlayback():void
		{
			m_isPlaying=false;
			
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.PAUSE);
			e.playbackController=this;
			dispatchEvent(e);
		}
		
		private function onStartPlayback():void
		{
			m_isPlaying=true;
			
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.PLAY);
			e.playbackController=this;
			dispatchEvent(e);
		
		}
		
		private function onAnimationStepChanged(stepIndex:Number):void
		{
			m_currentStepIndex=stepIndex;
			
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.STEP_CHANGE);
			e.playbackController=this;
			e.stepIndex=stepIndex;
			dispatchEvent(e);
		}
		
		private function onSlidePositionChanged(position:Number):void
		{
			m_currentSlidePlaybackPosition=position;
			
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.POSITION_CHANGE);
			e.playbackController=this;
			e.position=position;
			dispatchEvent(e);
		}
		
		private function onCurrentSlideIndexChanged(slideIndex:Number, slideDuration:Number):void
		{
			m_currentSlideIndex=slideIndex;
			m_currentSlideDuration=slideDuration;
			
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.SLIDE_CHANGE);
			e.playbackController=this;
			e.slideIndex=slideIndex;
			dispatchEvent(e);
		}
		
		private function onSlideLoadingComplete(slideIndex:Number):void
		{
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.SLIDE_LOAD_COMPLETE);
			e.playbackController=this;
			e.slideIndex=slideIndex;
			dispatchEvent(e);
		}
		
		private function onPresentationPlaybackComplete():void
		{
			var e:BridgeEvent=new BridgeEvent(BridgeEvent.PLAYBACK_COMPLETE);
			e.playbackController=this;
			dispatchEvent(e);
			//Alert.show("");
		}
		
		// playback events <
		
		private function initEventFunctions():void
		{
			m_bridgeConnector.setOnPausePlaybackCallback(this.onPausePlayback);
			m_bridgeConnector.setOnStartPlaybackCallback(this.onStartPlayback);
			m_bridgeConnector.setOnAnimationStepChangedCallback(this.onAnimationStepChanged);
			m_bridgeConnector.setOnSlidePositionChangedCallback(this.onSlidePositionChanged);
			m_bridgeConnector.setOnCurrentSlideIndexChangedCallback(this.onCurrentSlideIndexChanged);
			m_bridgeConnector.setOnSlideLoadingCompleteCallbackPlaybackController(this.onSlideLoadingComplete);
			m_bridgeConnector.setOnPresentationPlaybackCompleteCallback(this.onPresentationPlaybackComplete);
			m_bridgeConnector.setOnSeekingCompleteCallback(this.onSeekingCompleteCallback);
		}
	}
}
