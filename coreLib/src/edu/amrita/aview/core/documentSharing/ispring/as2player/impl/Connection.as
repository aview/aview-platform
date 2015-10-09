
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import flash.events.*;
	import flash.net.LocalConnection;
	
	public class Connection extends LocalConnection
	{
		private var m_commandName:String;
		
		public function Connection(commandName:String, eventName:String)
		{
			allowDomain("*");
			allowInsecureDomain("*");
			
			connect(eventName);
			m_commandName=commandName;
		}
		
		//// commands
		// playback controller
		public function play():void
		{
			send(m_commandName, "play");
		}
		
		public function pause():void
		{
			send(m_commandName, "pause");
		}
		
		public function gotoNextSlide(autoStart:Boolean):void
		{
			send(m_commandName, "gotoNextSlide", autoStart);
		}
		
		public function gotoPreviousSlide(autoStart:Boolean):void
		{
			send(m_commandName, "gotoPreviousSlide", autoStart);
		}
		
		public function gotoLastViewedSlide(autoStart:Boolean):void
		{
			send(m_commandName, "gotoLastViewedSlide", autoStart);
		}
		
		public function gotoSlide(slideIndex:Number, autoStart:Boolean):void
		{
			send(m_commandName, "gotoSlide", slideIndex, autoStart);
		}
		
		public function pauseCurrentSlideAt(position:Number):void
		{
			send(m_commandName, "pauseCurrentSlideAt", position);
		}
		
		public function playCurrentSlideFrom(position:Number):void
		{
			send(m_commandName, "playCurrentSlideFrom", position);
		}
		
		public function seek(position:Number):void
		{
			send(m_commandName, "seek", position);
		}
		
		public function endSeek(resumePlayback:Boolean):void
		{
			send(m_commandName, "endSeek", resumePlayback);
		}
		
		public function gotoNextStep():void
		{
			send(m_commandName, "gotoNextStep");
		}
		
		public function gotoPreviousStep():void
		{
			send(m_commandName, "gotoPreviousStep");
		}
		
		public function setAnimationStepPause(pause:Number):void
		{
			send(m_commandName, "setAnimationStepPause", pause);
		}
		
		public function playFromStep(stepIndex:Number):void
		{
			send(m_commandName, "playFromStep", stepIndex);
		}
		
		public function pauseAtStepStart(stepIndex:Number):void
		{
			send(m_commandName, "pauseAtStepStart", stepIndex);
		}
		
		public function pauseAtStepEnd(stepIndex:Number):void
		{
			send(m_commandName, "pauseAtStepEnd", stepIndex);
		}
		
		public function enableAutomaticSlideSwitching(autoSwitch:Boolean):void
		{
			send(m_commandName, "enableAutomaticSlideSwitching", autoSwitch);
		}
		
		public function gotoVisibleSlide(visibleSlideIndex:Number, autoStart:Boolean):void
		{
			send(m_commandName, "gotoVisibleSlide", visibleSlideIndex, autoStart);
		}
		
		public function gotoFirstSlide(autoStart:Boolean):void
		{
			send(m_commandName, "gotoFirstSlide", autoStart);
		}
		
		public function gotoLastSlide(autoStart:Boolean):void
		{
			send(m_commandName, "gotoLastSlide", autoStart);
		}
		
		// sound controller
		public function setVolume(value:Number):void
		{
			send(m_commandName, "setVolume", value);
		}
		
		// events
		public function onPlayerInit():void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.PLAYER_INIT));
		}
		
		public function onPausePlayback():void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.PAUSE_PLAYBACK));
		}
		
		public function onStartPlayback():void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.START_PLAYBACK));
		}
		
		public function onAnimationStepChanged(stepIndex:Number):void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.ANIMATION_STEP_CHANGED, stepIndex));
		}
		
		public function onSlidePositionChanged(position:Number):void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.SLIDE_POSITION_CHANGED, position));
		}
		
		public function onCurrentSlideIndexChanged(slideIndex:Number, previousSlideIndex:Number, nextSlideIndex:Number):void
		{
			var obj:Object=new Object();
			obj.slideIndex=slideIndex;
			obj.previousSlideIndex=previousSlideIndex;
			obj.nextSlideIndex=nextSlideIndex;
			dispatchEvent(new ConnectionEvent(ConnectionEvent.CURRENT_SLIDE_INDEX_CHANGED, obj));
		}
		
		public function onSlideLoadingComplete(slideIndex:String):void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.SLIDE_LOADING_COMPLETE, slideIndex));
		}
		
		public function onPresentationPlaybackComplete():void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.PRESENTATION_PLAYBACK_COMPLETE));
		}
		
		public function onSoundVolumeChanged(volume:Number):void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.SOUND_VOLUME_CHANGED, volume));
		}
		
		public function onKeyboardFocusStateChanged(acquireFocus:Boolean):void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.KEYBOARD_FOCUS_STATE_CHANGED, acquireFocus));
		}
		
		public function onInfo(info:String):void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.INFO, info));
		}
		
		public function onSeekingComplete():void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.SEEKING_COMPLETE));
		}
		
		public function onPlaybackSuspended():void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.PLAYBACK_SUSPENDED));
		}
		
		public function onPlaybackResumed():void
		{
			dispatchEvent(new ConnectionEvent(ConnectionEvent.PLAYBACK_RESUMED));
		}
	}
}
