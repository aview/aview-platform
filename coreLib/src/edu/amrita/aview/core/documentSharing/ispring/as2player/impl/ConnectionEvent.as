
package edu.amrita.aview.core.documentSharing.ispring.as2player.impl
{
	import flash.events.Event;
	
	public class ConnectionEvent extends Event
	{
		public static const PLAYER_INIT:String="playerInit";
		public static const PAUSE_PLAYBACK:String="pausePlayback";
		public static const START_PLAYBACK:String="startPlayback";
		public static const PLAYBACK_SUSPENDED:String="playbackSuspended";
		public static const PLAYBACK_RESUMED:String="playbackResumed";
		public static const ANIMATION_STEP_CHANGED:String="animationStepChanged";
		public static const SLIDE_POSITION_CHANGED:String="slidePositionChanged";
		public static const CURRENT_SLIDE_INDEX_CHANGED:String="currentSlideIndexChanged";
		public static const SLIDE_LOADING_COMPLETE:String="slideLoadingComplete";
		public static const PRESENTATION_PLAYBACK_COMPLETE:String="presentationPlaybackComplete";
		public static const KEYBOARD_FOCUS_STATE_CHANGED:String="keyboardFocusStateChanged";
		public static const SOUND_VOLUME_CHANGED:String="soundVolumeChanged";
		public static const INFO:String="info";
		public static const SEEKING_COMPLETE:String="seekingComplete";
		
		private var m_parameter:Object;
		
		public function ConnectionEvent(type:String, parameter:Object=null)
		{
			super(type);
			m_parameter=parameter;
		}
		
		public function get parameter():Object
		{
			return m_parameter;
		}
	}
}
