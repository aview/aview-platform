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
 * File			: V2DEvents.as
 * Module		: 2DViewer
 * Developer(s)	: Manjith CM, Deepu Diwakar, Jayakrishnan R
 * Reviewer(s)	: Remya T
 *
 * For custom events
 *
 */
package edu.amrita.aview.twoDSharing {
	import flash.events.Event;

	public class V2DEvent extends Event {
		/**
		 * Variables for custom events
		 */
		public static var MODULE_CLOSE:String="moduleclose";
		public static var SUPPORTED_FILE:String="SuppportedFile";
		/**
		 * For store the breakpoint object value
		 */
		private var _data:Object;

		/**
		 *
		 * @public
		 *
		 *
		 * @param type of type String
		 * @param bubbles of type Boolean
		 * @param cancelable of type String
		 * @param data of type * as null
		 * @return void
		 *
		 ***/
		public function V2DEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:*=null) {
			super(type, bubbles, cancelable);
			_data=data;
		}

		/**
		 *
		 * @public
		 *
		 *
		 *
		 * @return Event
		 *
		 ***/
		override public function clone():Event {
			return new V2DEvent(type, bubbles, cancelable, data);
		}

		/**
		 *
		 * @public
		 *
		 *
		 *
		 * @return Object
		 *
		 ***/
		public function get data():Object {

			return _data;

		}
	}
}
