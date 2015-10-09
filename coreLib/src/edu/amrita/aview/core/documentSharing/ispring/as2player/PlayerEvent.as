
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import flash.events.Event;
	
	public class PlayerEvent extends Event
	{
		public static const PLAYER_INIT:String="playerInit";
		
		public function PlayerEvent(type:String){
			super(type);
		}
		
		public override function clone():Event{
			return new PlayerEvent(type);
		}
	}
}
