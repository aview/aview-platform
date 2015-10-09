
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import flash.events.EventDispatcher;
	
	import edu.amrita.aview.core.documentSharing.ispring.as2player.IPresentationPlaybackController;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISlideInfo;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.ISlidesCollection;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.AcquireFocusEvent;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.PlaybackEvent;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.PlaybackPositionEvent;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.SlidePlaybackEvent;
	import edu.amrita.aview.core.documentSharing.ispring.as2player.StepPlaybackEvent;
	
	public class PresentationPlaybackController extends EventDispatcher implements IPresentationPlaybackController
	{
		private var m_connection:Connection;
		
		private var m_playing:Boolean;
		private var m_currentSlideDuration:Number;
		private var m_currentSlideIndex:Number;
		private var m_currentSlidePlaybackPosition:Number;
		private var m_currentStepIndex:Number;
		private var m_automaticSlideSwitching:Boolean;
		private var m_currentVisibleSlideIndex:Number;
		private var m_nextSlideIndex:Number;
		private var m_previousSlideIndex:Number;
		private var m_slidesCollection:ISlidesCollection;
		
		public function PresentationPlaybackController(connection:Connection, obj:Object, slidesCollection:ISlidesCollection)
		{
			m_connection=connection;
			m_slidesCollection=slidesCollection;
			
			m_playing=obj.playing;
			m_currentSlideDuration=obj.currentSlideDuration;
			m_currentSlideIndex=obj.currentSlideIndex;
			m_currentSlidePlaybackPosition=obj.currentSlidePlaybackPosition;
			m_currentStepIndex=obj.currentStepIndex;
			m_automaticSlideSwitching=obj.automaticSlideSwitching;
			m_currentVisibleSlideIndex=obj.currentVisibleSlideIndex;
			m_nextSlideIndex=obj.nextSlideIndex;
			m_previousSlideIndex=obj.previousSlideIndex;
			
			m_connection.addEventListener(ConnectionEvent.SLIDE_LOADING_COMPLETE, slideLoadingComplete);
			m_connection.addEventListener(ConnectionEvent.CURRENT_SLIDE_INDEX_CHANGED, currentSlideIndexChanged);
			m_connection.addEventListener(ConnectionEvent.PRESENTATION_PLAYBACK_COMPLETE, presentationPlaybackComplete);
			m_connection.addEventListener(ConnectionEvent.START_PLAYBACK, startPlayback);
			m_connection.addEventListener(ConnectionEvent.PAUSE_PLAYBACK, pausePlayback);
			m_connection.addEventListener(ConnectionEvent.PLAYBACK_SUSPENDED, playbackSuspended);
			m_connection.addEventListener(ConnectionEvent.PLAYBACK_RESUMED, playbackResumed);
			m_connection.addEventListener(ConnectionEvent.ANIMATION_STEP_CHANGED, animationStepChanged);
			m_connection.addEventListener(ConnectionEvent.SLIDE_POSITION_CHANGED, slidePositionChanged);
			m_connection.addEventListener(ConnectionEvent.KEYBOARD_FOCUS_STATE_CHANGED, keyboardFocusStateChanged);
			m_connection.addEventListener(ConnectionEvent.SEEKING_COMPLETE, seekingComplete);
		}
		
		// IPresentationPlaybackController
		public function get playing():Boolean
		{
			return m_playing;
		}
		
		public function get currentSlideDuration():Number
		{
			return m_currentSlideDuration;
		}
		
		public function play():void
		{
			m_connection.play();
		}
		
		public function pause():void
		{
			m_connection.pause();
		}
		
		public function gotoNextSlide(autoStart:Boolean=true):void
		{
			m_connection.gotoNextSlide(autoStart);
		}
		
		public function gotoPreviousSlide(autoStart:Boolean=true):void
		{
			m_connection.gotoPreviousSlide(autoStart);
		}
		
		public function gotoLastViewedSlide(autoStart:Boolean=true):void
		{
			m_connection.gotoLastViewedSlide(autoStart);
		}
		
		public function get currentSlideIndex():Number
		{
			return m_currentSlideIndex;
		}
		
		public function gotoSlide(slideIndex:Number, autoStart:Boolean=true):void
		{
			m_connection.gotoSlide(slideIndex, autoStart);
		}
		
		public function get currentSlidePlaybackPosition():Number
		{
			return m_currentSlidePlaybackPosition;
		}
		
		public function pauseCurrentSlideAt(position:Number):void
		{
			m_connection.pauseCurrentSlideAt(position);
		}
		
		public function playCurrentSlideFrom(position:Number):void
		{
			m_connection.playCurrentSlideFrom(position);
		}
		
		public function seek(position:Number):void
		{
			m_connection.seek(position);
		}
		
		public function endSeek(resumePlayback:Boolean=undefined):void
		{
			m_connection.endSeek(resumePlayback);
		}
		
		public function get currentStepIndex():Number
		{
			return m_currentStepIndex;
		}
		
		public function gotoNextStep():void
		{
			m_connection.gotoNextStep();
		}
		
		public function gotoPreviousStep():void
		{
			m_connection.gotoPreviousStep();
		}
		
		public function set animationStepPause(pause:Number):void
		{
			m_connection.setAnimationStepPause(pause);
		}
		
		public function playFromStep(stepIndex:Number):void
		{
			m_connection.playFromStep(stepIndex);
		}
		
		public function pauseAtStepStart(stepIndex:Number):void
		{
			m_connection.pauseAtStepStart(stepIndex);
		}
		
		public function pauseAtStepEnd(stepIndex:Number):void
		{
			m_connection.pauseAtStepEnd(stepIndex);
		}
		
		public function set automaticSlideSwitching(autoSwitch:Boolean):void
		{
			m_automaticSlideSwitching=autoSwitch;
			m_connection.enableAutomaticSlideSwitching(autoSwitch);
		}
		
		public function get automaticSlideSwitching():Boolean
		{
			return m_automaticSlideSwitching;
		}
		
		public function get currentVisibleSlideIndex():Number
		{
			return m_currentVisibleSlideIndex;
		}
		
		public function gotoVisibleSlide(visibleSlideIndex:Number, autoStart:Boolean=true):void
		{
			m_connection.gotoVisibleSlide(visibleSlideIndex, autoStart);
		}
		
		public function gotoFirstSlide(autoStart:Boolean=true):void
		{
			m_connection.gotoFirstSlide(autoStart);
		}
		
		public function gotoLastSlide(autoStart:Boolean=true):void
		{
			m_connection.gotoLastSlide(autoStart);
		}
		
		public function get nextSlideIndex():Number
		{
			return m_nextSlideIndex;
		}
		
		public function get previousSlideIndex():Number
		{
			return m_previousSlideIndex;
		}
		
		// events
		private function slideLoadingComplete(e:ConnectionEvent):void
		{
			dispatchEvent(new SlidePlaybackEvent(SlidePlaybackEvent.SLIDE_LOADING_COMPLETE, Number(e.parameter)));
		}
		
		private function currentSlideIndexChanged(e:ConnectionEvent):void
		{
			m_currentSlideIndex=e.parameter.slideIndex;
			var slideInfo:ISlideInfo=m_slidesCollection.getSlideInfo(m_currentSlideIndex);
			m_currentVisibleSlideIndex=slideInfo.visibleIndex;
			m_currentSlideDuration=slideInfo.duration;
			m_previousSlideIndex=e.parameter.previousSlideIndex;
			m_nextSlideIndex=e.parameter.nextSlideIndex;
			dispatchEvent(new SlidePlaybackEvent(SlidePlaybackEvent.CURRENT_SLIDE_INDEX_CHANGED, m_currentSlideIndex));
		}
		
		private function startPlayback(e:ConnectionEvent):void
		{
			m_playing=true;
			dispatchEvent(new PlaybackEvent(PlaybackEvent.START_PLAYBACK));
		}
		
		private function pausePlayback(e:ConnectionEvent):void
		{
			dispatchEvent(new PlaybackEvent(PlaybackEvent.PAUSE_PLAYBACK));
		}
		
		private function playbackSuspended(e:ConnectionEvent):void
		{
			dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_SUSPENDED));
		}
		
		private function playbackResumed(e:ConnectionEvent):void
		{
			dispatchEvent(new PlaybackEvent(PlaybackEvent.PLAYBACK_RESUMED));
		}
		
		private function presentationPlaybackComplete(e:ConnectionEvent):void
		{
			dispatchEvent(new PlaybackEvent(PlaybackEvent.PRESENTATION_PLAYBACK_COMPLETE));
		}
		
		private function animationStepChanged(e:ConnectionEvent):void
		{
			m_currentStepIndex=Number(e.parameter);
			dispatchEvent(new StepPlaybackEvent(StepPlaybackEvent.ANIMATION_STEP_CHANGED, m_currentStepIndex));
		}
		
		private function slidePositionChanged(e:ConnectionEvent):void
		{
			m_currentSlidePlaybackPosition=Number(e.parameter);
			dispatchEvent(new PlaybackPositionEvent(PlaybackPositionEvent.SLIDE_POSITION_CHANGED, m_currentSlidePlaybackPosition));
		}
		
		private function keyboardFocusStateChanged(e:ConnectionEvent):void
		{
			dispatchEvent(new AcquireFocusEvent(AcquireFocusEvent.KEYBOARD_FOCUS_STATE_CHANGED, e.parameter));
		}
		
		private function seekingComplete(e:ConnectionEvent):void
		{
			dispatchEvent(new PlaybackEvent(PlaybackEvent.SEEKING_COMPLETE));
		}
	}
}
