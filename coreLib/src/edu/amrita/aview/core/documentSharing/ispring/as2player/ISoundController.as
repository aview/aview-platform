
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import flash.events.IEventDispatcher;
	
	public interface ISoundController extends IEventDispatcher
	{
		function get volume():Number;
		function set volume(value:Number):void;
	}
}
