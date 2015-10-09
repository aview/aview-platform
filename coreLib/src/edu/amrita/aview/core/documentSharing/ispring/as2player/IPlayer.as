
package edu.amrita.aview.core.documentSharing.ispring.as2player
{
	import flash.events.IEventDispatcher;
	
	public interface IPlayer extends IEventDispatcher
	{
		function get initialized():Boolean;
		function get playbackController():IPresentationPlaybackController;
		function get soundController():ISoundController;
		function get presentationInfo():IPresentationInfo;
		function get settings():Object;
	}
}
