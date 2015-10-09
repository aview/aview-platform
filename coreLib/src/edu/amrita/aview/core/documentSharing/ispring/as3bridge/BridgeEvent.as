package edu.amrita.aview.core.documentSharing.ispring.as3bridge
{
	import flash.events.Event;
	
	public class BridgeEvent extends Event
	{
		public static const PAUSE:String="pause";
		public static const PLAY:String="play";
		public static const STEP_CHANGE:String="stepChange";
		public static const POSITION_CHANGE:String="positionChange";
		public static const SLIDE_CHANGE:String="slideChange";
		public static const SLIDE_LOAD_COMPLETE:String="slideLoadComplete";
		public static const PLAYBACK_COMPLETE:String="playbackComplete";
		public static const BRIDGE_LOADED:String="bridgeLoaded";
		public static const PRESENTATION_LOADED:String="presentationLoaded";
		public static const PLAYER_INIT:String="playerInit";
		public static const VOLUME_CHANGE:String="volumeChange";
		public static const SEEKING_COMPLETE:String="seekingComplete";
		public static const VOLUME_CHANGING_COMPLETE:String="volumeChangingComplete";
		public static const SLIDE_METADATA_LOAD:String="slideMetadataLoad";
		
		private var m_playbackController:PlaybackController;
		private var m_slideIndex:Number;
		private var m_stepIndex:Number;
		private var m_position:Number;
		private var m_succeeded:Boolean;
		private var m_player:Player;
		private var m_volume:Number;
		private var m_slideInfo:SlideInfo;
		private var m_soundController:SoundController;
		
		public function BridgeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set playbackController(pc:PlaybackController):void
		{
			m_playbackController=pc;
		}
		
		public function get playbackController():PlaybackController
		{
			return m_playbackController;
		}
		
		public function set slideIndex(si:Number):void
		{
			m_slideIndex=si;
		}
		
		public function get slideIndex():Number
		{
			return m_slideIndex;
		}
		
		public function set stepIndex(si:Number):void
		{
			m_stepIndex=si;
		}
		
		public function get stepIndex():Number
		{
			return m_stepIndex;
		}
		
		public function set position(p:Number):void
		{
			m_position=p;
		}
		
		public function get position():Number
		{
			return m_position;
		}
		
		public function set succeeded(s:Boolean):void
		{
			m_succeeded=s;
		}
		
		public function get succeeded():Boolean
		{
			return m_succeeded;
		}
		
		public function set player(p:Player):void
		{
			m_player=p;
		}
		
		public function get player():Player
		{
			return m_player;
		}
		
		public function set volume(v:Number):void
		{
			m_volume=v;
		}
		
		public function get volume():Number
		{
			return m_volume;
		}
		
		public function set slideInfo(si:SlideInfo):void
		{
			m_slideInfo=si;
		}
		
		public function get slideInfo():SlideInfo
		{
			return m_slideInfo;
		}
		
		public function set soundController(sc:SoundController):void
		{
			m_soundController=sc;
		}
		
		public function get soundController():SoundController
		{
			return m_soundController;
		}
	}
}
