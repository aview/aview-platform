////////////////////////////////////////////////////////////////////////////////
//
// Copyright  © 2013 E-Learning Research Lab, 
// Amrita Vishwa Vidyapeetham. All rights reserved. 
// E-Learning Research Lab and the A-VIEW logo are trademarks or
// registered trademarks of E-Learning Research Lab. 
// All other names used are the trademarks of their respective owners.
//
////////////////////////////////////////////////////////////////////////////////
/**
 *
 * File			: DragFinish.as
 * Module		: Common
 * Developer(s)	: Haridasan
 * Reviewer(s)	: Veena Gopal K.V
 * DragFinish is a custom event class for Draging process.
 *
 *
 */
package edu.amrita.aview.core.shared.components.fileManager.events
{
	import flash.events.Event;
	/**
	 * 	DragFinish is a custom event class for Draging process.
	 *  This calss is extends from Event class.
	 *  User can dispatch DragFinish after drag finish.
	 *  Along with this event we send drop path for each drag.
	 */
	public class DragFinish extends Event
	{
		/**
		 * Event Type
		 */
		public static var DRAG_FINSISHED:String="dragFinish";
		/**
		 *For store the value of Drop path
		 */		
		private var _dropPath:String;
		
		/**
		 * @public 
		 * Set value of Drop path
		 * @param str of type String
		 * 
		 */
		public function set dropPath(str:String):void
		{
			_dropPath=str;
		}
		
		/**
		 * @public
		 * Get value of Drop path
		 * @return String
		 * 
		 */
		public function get dropPath():String
		{
			return _dropPath;
		}
		
		/**
		 * @public 
		 * Constructor
		 * @param type of type String
		 * @param bubbles of type Boolean default value = false
		 * @param cancelable of type Boolean default value= false
		 * 
		 */
		public function DragFinish(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
